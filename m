Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 74AB86B0089
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:37:07 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 32/34] cpusets: stall when updating mems_allowed for mempolicy or disjoint nodemask
Date: Thu, 19 Jul 2012 15:36:42 +0100
Message-Id: <1342708604-26540-33-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: David Rientjes <rientjes@google.com>

commit b246272ecc5ac68c743b15c9e41a2275f7ce70e2 upstream.

Stable note: Not tracked in Bugzilla. [get|put]_mems_allowed() is extremely
	expensive and severely impacted page allocator performance. This is
	part of a series of patches that reduce page allocator overhead.

Kernels where MAX_NUMNODES > BITS_PER_LONG may temporarily see an empty
nodemask in a tsk's mempolicy if its previous nodemask is remapped onto a
new set of allowed cpuset nodes where the two nodemasks, as a result of
the remap, are now disjoint.

c0ff7453bb5c ("cpuset,mm: fix no node to alloc memory when changing
cpuset's mems") adds get_mems_allowed() to prevent the set of allowed
nodes from changing for a thread.  This causes any update to a set of
allowed nodes to stall until put_mems_allowed() is called.

This stall is unncessary, however, if at least one node remains unchanged
in the update to the set of allowed nodes.  This was addressed by
89e8a244b97e ("cpusets: avoid looping when storing to mems_allowed if one
node remains set"), but it's still possible that an empty nodemask may be
read from a mempolicy because the old nodemask may be remapped to the new
nodemask during rebind.  To prevent this, only avoid the stall if there is
no mempolicy for the thread being changed.

This is a temporary solution until all reads from mempolicy nodemasks can
be guaranteed to not be empty without the get_mems_allowed()
synchronization.

Also moves the check for nodemask intersection inside task_lock() so that
tsk->mems_allowed cannot change.  This ensures that nothing can set this
tsk's mems_allowed out from under us and also protects tsk->mempolicy.

Reported-by: Miao Xie <miaox@cn.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Paul Menage <paul@paulmenage.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/cpuset.c |   29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index a995893..28d0bbd 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -123,6 +123,19 @@ static inline struct cpuset *task_cs(struct task_struct *task)
 			    struct cpuset, css);
 }
 
+#ifdef CONFIG_NUMA
+static inline bool task_has_mempolicy(struct task_struct *task)
+{
+	return task->mempolicy;
+}
+#else
+static inline bool task_has_mempolicy(struct task_struct *task)
+{
+	return false;
+}
+#endif
+
+
 /* bits in struct cpuset flags field */
 typedef enum {
 	CS_CPU_EXCLUSIVE,
@@ -949,7 +962,7 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
 static void cpuset_change_task_nodemask(struct task_struct *tsk,
 					nodemask_t *newmems)
 {
-	bool masks_disjoint = !nodes_intersects(*newmems, tsk->mems_allowed);
+	bool need_loop;
 
 repeat:
 	/*
@@ -962,6 +975,14 @@ repeat:
 		return;
 
 	task_lock(tsk);
+	/*
+	 * Determine if a loop is necessary if another thread is doing
+	 * get_mems_allowed().  If at least one node remains unchanged and
+	 * tsk does not have a mempolicy, then an empty nodemask will not be
+	 * possible when mems_allowed is larger than a word.
+	 */
+	need_loop = task_has_mempolicy(tsk) ||
+			!nodes_intersects(*newmems, tsk->mems_allowed);
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
 
@@ -981,11 +1002,9 @@ repeat:
 
 	/*
 	 * Allocation of memory is very fast, we needn't sleep when waiting
-	 * for the read-side.  No wait is necessary, however, if at least one
-	 * node remains unchanged.
+	 * for the read-side.
 	 */
-	while (masks_disjoint &&
-			ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
+	while (need_loop && ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
 		task_unlock(tsk);
 		if (!task_curr(tsk))
 			yield();
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
