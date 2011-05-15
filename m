Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2EC4190010B
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:21:44 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 1/9] mm: export get_vma_policy()
Date: Sun, 15 May 2011 18:20:21 -0400
Message-Id: <1305498029-11677-2-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

In commit 48fce3429df84a94766fbbc845fa8450d0715b48 get_vma_policy() was
marked static as all clients were local to mempolicy.c.

However, the decision to generate /proc/pid/numa_maps in the numa memory
policy code and outside the procfs subsystem introduces an artificial
interdependency between the two systems.  Exporting get_vma_policy()
once again is the first step to clean up this interdependency.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/mempolicy.h |    3 +++
 mm/mempolicy.c            |    2 +-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 31ac26c..c2f6032 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -199,6 +199,9 @@ void mpol_free_shared_policy(struct shared_policy *p);
 struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 					    unsigned long idx);
 
+struct mempolicy *get_vma_policy(struct task_struct *tsk,
+		struct vm_area_struct *vma, unsigned long addr);
+
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8e57a72..6cc997d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1490,7 +1490,7 @@ asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
  * freeing by another task.  It is the caller's responsibility to free the
  * extra reference for shared policies.
  */
-static struct mempolicy *get_vma_policy(struct task_struct *task,
+struct mempolicy *get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
