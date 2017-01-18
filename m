Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92CEA6B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 11:20:32 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r144so3999263wme.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:20:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p75si2939824wmd.68.2017.01.18.08.20.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 08:20:31 -0800 (PST)
Subject: [RFC 5/4] mm, page_alloc: fix premature OOM due to vma mempolicy
 update
References: <20170117221610.22505-1-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7c459f26-13a6-a817-e508-b65b903a8378@suse.cz>
Date: Wed, 18 Jan 2017 17:20:27 +0100
MIME-Version: 1.0
In-Reply-To: <20170117221610.22505-1-vbabka@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Due to interactions between mempolicies and cpusets, it can happen that the
intersection of nodes allowed by both is empty. In that case, cpuset has a
higher priority, which can be seen in the code of policy_nodemask().

There's however a possible race when cpuset's mems_allowed is updated after
policy_nodemask() called from alloc_pages_vma() observes a non-empty
intersection, and then it becomes empty. This can be either a temporary state
until the vma's mempolicy gets updated as part of the cpuset change, or
permanent. In both cases, this leads to OOM's when all calls to
get_page_from_freelist() end up iterating over the empty intersection.

One part of the issue is that unlike task mempolicy, vma mempolicy rebinding
by cpuset isn't protected by the seqlock, so the allocation cannot detect the
race and retry. This patch adds the necessary protections.

The second part is that although alloc_pages_vma() performs the read-side
operations on the seqlock, the cookie is different than the one used by
__alloc_pages_slowpath(). This leaves a window where the cpuset update will
finish before we read the cookie in __alloc_pages_slowpath(), and thus we
won't detect it, and the OOM will happen before we can return to
alloc_pages_vma() and check its own cookie.

We could pass the first cookie down, but that would make things more
complicated, so this patch instead rechecks for the empty intersection in
__alloc_pages_slowpath() before OOM.

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
Unfortunately when working on the series I have suspected that when vma
mempolicies are added to the mix via mbind(), the previous patches won't help.
By changing the LTP cpuset01 testcase (will post patch as a reply) this was
confirmed and the problem is also older than the changes in 4.7.
This is one approach that seems to fix this in my tests, but it's not really
nice and just tries to plug more holes in the current design. I'm posting it
mainly for discussion.

 include/linux/mempolicy.h |  6 ++++--
 kernel/cpuset.c           |  4 ++--
 mm/mempolicy.c            | 16 +++++++++++++---
 mm/page_alloc.c           | 13 +++++++++++++
 4 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5e5b2969d931..c5519027eb6a 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -143,7 +143,8 @@ extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 				enum mpol_rebind_step step);
-extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
+extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new,
+						struct task_struct *tsk);
 
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
@@ -257,7 +258,8 @@ static inline void mpol_rebind_task(struct task_struct *tsk,
 {
 }
 
-static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
+static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new,
+						struct task_struct *tsk)
 {
 }
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 29f815d2ef7e..727ddf5d8222 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1117,7 +1117,7 @@ static void update_tasks_nodemask(struct cpuset *cs)
 
 		migrate = is_memory_migrate(cs);
 
-		mpol_rebind_mm(mm, &cs->mems_allowed);
+		mpol_rebind_mm(mm, &cs->mems_allowed, task);
 		if (migrate)
 			cpuset_migrate_mm(mm, &cs->old_mems_allowed, &newmems);
 		else
@@ -1559,7 +1559,7 @@ static void cpuset_attach(struct cgroup_taskset *tset)
 		struct mm_struct *mm = get_task_mm(leader);
 
 		if (mm) {
-			mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
+			mpol_rebind_mm(mm, &cpuset_attach_nodemask_to, leader);
 
 			/*
 			 * old_mems_allowed is the same with mems_allowed
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0b859af06b87..bc6983732333 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -437,13 +437,23 @@ void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
  * Call holding a reference to mm.  Takes mm->mmap_sem during call.
  */
 
-void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
+void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new,
+					struct task_struct *tsk)
 {
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
-		mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
+	task_lock(tsk);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->vm_policy) {
+			local_irq_disable();
+			write_seqcount_begin(&tsk->mems_allowed_seq);
+			mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
+			write_seqcount_end(&tsk->mems_allowed_seq);
+			local_irq_enable();
+		}
+	}
+	task_unlock(tsk);
 	up_write(&mm->mmap_sem);
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 89c8cf87eab5..36fe6742c276 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3699,6 +3699,19 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				&compaction_retries))
 		goto retry;
 
+	/*
+	 * It's possible that alloc_pages_vma() saw that nodemask is compatible
+	 * with cpuset's mems_allowed, but then the cpuset was updated and this
+	 * is no longer true.
+	 * It's also possible that the discrepancy was only visible during our
+	 * allocation attempts, and now nodemask has been updated to match the
+	 * cpuset and this check will pass. In that case the
+	 * cpuset_mems_cookie check below should catch that.
+	 */
+	if (ac->nodemask && (alloc_flags & ALLOC_CPUSET)
+			&& !cpuset_nodemask_valid_mems_allowed(ac->nodemask))
+		goto nopage;
+
 	/*
 	 * It's possible we raced with cpuset update so the OOM would be
 	 * premature (see below the nopage: label for full explanation).
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
