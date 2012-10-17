Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id EDE576B0068
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 17:31:11 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so8652332pbb.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:31:11 -0700 (PDT)
Date: Wed, 17 Oct 2012 14:31:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-3.7 v2] mm, mempolicy: avoid taking mutex inside spinlock
 when reading numa_maps
In-Reply-To: <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <20121017181413.GA16805@redhat.com> <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com> <20121017193229.GC16805@redhat.com>
 <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com> <20121017194501.GA24400@redhat.com> <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As a result of commit 32f8516a8c73 ("mm, mempolicy: fix printing stack
contents in numa_maps"), the mutex protecting a shared policy can be
inadvertently taken while holding task_lock(task).

Recently, commit b22d127a39dd ("mempolicy: fix a race in 
shared_policy_replace()") switched the spinlock within a shared policy to 
a mutex so sp_alloc() could block.  Thus, a refcount must be grabbed on 
all mempolicies returned by get_vma_policy() so it isn't freed while being 
passed to mpol_to_str() when reading /proc/pid/numa_maps.

This patch only takes task_lock() while dereferencing task->mempolicy in 
get_vma_policy() if it's non-NULL in the lockess check to increment its 
refcount.  This ensures it will remain in memory until dropped by 
__mpol_put() after mpol_to_str() is called.

Refcounts of shared policies are grabbed by the ->get_policy() function of 
the vma, all others will be grabbed directly in get_vma_policy().  Now 
that this is done, all callers now unconditionally drop the refcount.

Tested-by: Dave Jones <davej@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: optimized task_lock() in get_vma_policy(): test for a non-NULL
     task->mempolicy before taking task_lock() and grabbing the reference
     so we don't take the lock unnecessarily.

 fs/proc/task_mmu.c        |    4 +--
 include/linux/mempolicy.h |   12 +------
 mm/hugetlb.c              |    4 +--
 mm/mempolicy.c            |   79 ++++++++++++++++++++-------------------------
 4 files changed, 39 insertions(+), 60 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 14df880..5709e70 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1178,11 +1178,9 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	walk.private = md;
 	walk.mm = mm;
 
-	task_lock(task);
 	pol = get_vma_policy(task, vma, vma->vm_start);
 	mpol_to_str(buffer, sizeof(buffer), pol, 0);
-	mpol_cond_put(pol);
-	task_unlock(task);
+	__mpol_put(pol);
 
 	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
 
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index e5ccb9d..f76f7e0 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -73,13 +73,7 @@ static inline void mpol_put(struct mempolicy *pol)
  */
 static inline int mpol_needs_cond_ref(struct mempolicy *pol)
 {
-	return (pol && (pol->flags & MPOL_F_SHARED));
-}
-
-static inline void mpol_cond_put(struct mempolicy *pol)
-{
-	if (mpol_needs_cond_ref(pol))
-		__mpol_put(pol);
+	return pol->flags & MPOL_F_SHARED;
 }
 
 extern struct mempolicy *__mpol_cond_copy(struct mempolicy *tompol,
@@ -211,10 +205,6 @@ static inline void mpol_put(struct mempolicy *p)
 {
 }
 
-static inline void mpol_cond_put(struct mempolicy *pol)
-{
-}
-
 static inline struct mempolicy *mpol_cond_copy(struct mempolicy *to,
 						struct mempolicy *from)
 {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 59a0059..5080808 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -568,13 +568,13 @@ retry_cpuset:
 		}
 	}
 
-	mpol_cond_put(mpol);
+	__mpol_put(mpol);
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
 	return page;
 
 err:
-	mpol_cond_put(mpol);
+	__mpol_put(mpol);
 	return NULL;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d04a8a5..a0bb463 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -906,7 +906,8 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	}
 
  out:
-	mpol_cond_put(pol);
+	if (mpol_needs_cond_ref(pol))
+		__mpol_put(pol);
 	if (vma)
 		up_read(&current->mm->mmap_sem);
 	return err;
@@ -1527,48 +1528,54 @@ asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
 }
 
 #endif
-
-/*
- * get_vma_policy(@task, @vma, @addr)
- * @task - task for fallback if vma policy == default
- * @vma   - virtual memory area whose policy is sought
- * @addr  - address in @vma for shared policy lookup
+/**
+ * get_vma_policy() - return effective policy for a vma at specified address
+ * @task: task for fallback if vma policy == default_policy
+ * @vma: virtual memory area whose policy is sought
+ * @addr: address in @vma for shared policy lookup
  *
- * Returns effective policy for a VMA at specified address.
  * Falls back to @task or system default policy, as necessary.
- * Current or other task's task mempolicy and non-shared vma policies must be
- * protected by task_lock(task) by the caller.
- * Shared policies [those marked as MPOL_F_SHARED] require an extra reference
- * count--added by the get_policy() vm_op, as appropriate--to protect against
- * freeing by another task.  It is the caller's responsibility to free the
- * extra reference for shared policies.
+ * Increments the reference count of the returned mempolicy, it is the caller's
+ * responsibility to decrement with __mpol_put().
+ * Requires vma->vm_mm->mmap_sem to be held for vma policies and takes
+ * task_lock(task) for task policy fallback.
  */
 struct mempolicy *get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
 
+	/*
+	 * Grab a reference before task has the potential to exit and free its
+	 * mempolicy.
+	 */
+	if (pol) {
+		task_lock(task);
+		pol = task->mempolicy;
+		mpol_get(pol);
+		task_unlock(task);
+	}
+
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
 			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
 									addr);
-			if (vpol)
+			if (vpol) {
+				mpol_put(pol);
 				pol = vpol;
+				if (!mpol_needs_cond_ref(pol))
+					mpol_get(pol);
+			}
 		} else if (vma->vm_policy) {
+			mpol_put(pol);
 			pol = vma->vm_policy;
-
-			/*
-			 * shmem_alloc_page() passes MPOL_F_SHARED policy with
-			 * a pseudo vma whose vma->vm_ops=NULL. Take a reference
-			 * count on these policies which will be dropped by
-			 * mpol_cond_put() later
-			 */
-			if (mpol_needs_cond_ref(pol))
-				mpol_get(pol);
+			mpol_get(pol);
 		}
 	}
-	if (!pol)
+	if (!pol) {
 		pol = &default_policy;
+		mpol_get(pol);
+	}
 	return pol;
 }
 
@@ -1919,30 +1926,14 @@ retry_cpuset:
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
-		mpol_cond_put(pol);
 		page = alloc_page_interleave(gfp, order, nid);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
-			goto retry_cpuset;
-
-		return page;
+		goto out;
 	}
 	zl = policy_zonelist(gfp, pol, node);
-	if (unlikely(mpol_needs_cond_ref(pol))) {
-		/*
-		 * slow path: ref counted shared policy
-		 */
-		struct page *page =  __alloc_pages_nodemask(gfp, order,
-						zl, policy_nodemask(gfp, pol));
-		__mpol_put(pol);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
-			goto retry_cpuset;
-		return page;
-	}
-	/*
-	 * fast path:  default or task policy
-	 */
 	page = __alloc_pages_nodemask(gfp, order, zl,
 				      policy_nodemask(gfp, pol));
+out:
+	__mpol_put(pol);
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
 	return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
