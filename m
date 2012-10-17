Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 65A316B005D
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 01:24:36 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so7626235pbb.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 22:24:35 -0700 (PDT)
Date: Tue, 16 Oct 2012 22:24:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
In-Reply-To: <20121017040515.GA13505@redhat.com>
Message-ID: <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com> <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com> <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Oct 2012, Dave Jones wrote:

> BUG: sleeping function called from invalid context at kernel/mutex.c:269
> in_atomic(): 1, irqs_disabled(): 0, pid: 8558, name: trinity-child2
> 3 locks on stack by trinity-child2/8558:
>  #0: held:     (&p->lock){+.+.+.}, instance: ffff88010c9a00b0, at: [<ffffffff8120cd1f>] seq_lseek+0x3f/0x120
>  #1: held:     (&mm->mmap_sem){++++++}, instance: ffff88013956f7c8, at: [<ffffffff81254437>] m_start+0xa7/0x190
>  #2: held:     (&(&p->alloc_lock)->rlock){+.+...}, instance: ffff88011fc64f30, at: [<ffffffff81254f8f>] show_numa_map+0x14f/0x610
> Pid: 8558, comm: trinity-child2 Not tainted 3.7.0-rc1+ #32
> Call Trace:
>  [<ffffffff810ae4ec>] __might_sleep+0x14c/0x200
>  [<ffffffff816bdf4e>] mutex_lock_nested+0x2e/0x50
>  [<ffffffff811c43a3>] mpol_shared_policy_lookup+0x33/0x90
>  [<ffffffff8118d5c3>] shmem_get_policy+0x33/0x40
>  [<ffffffff811c31fa>] get_vma_policy+0x3a/0x90
>  [<ffffffff81254fa3>] show_numa_map+0x163/0x610
>  [<ffffffff81255b10>] ? pid_maps_open+0x20/0x20
>  [<ffffffff81255980>] ? pagemap_hugetlb_range+0xf0/0xf0
>  [<ffffffff81255483>] show_pid_numa_map+0x13/0x20
>  [<ffffffff8120c902>] traverse+0xf2/0x230
>  [<ffffffff8120cd8b>] seq_lseek+0xab/0x120
>  [<ffffffff811e6c0b>] sys_lseek+0x7b/0xb0
>  [<ffffffff816ca088>] tracesys+0xe1/0xe6
> 

Hmm, looks like we need to change the refcount semantics entirely.  We'll 
need to make get_vma_policy() always take a reference and then drop it 
accordingly.  This work sif get_vma_policy() can grab a reference while 
holding task_lock() for the task policy fallback case.

Comments on this approach?
---
 fs/proc/task_mmu.c |    4 +---
 include/linux/mm.h |    3 +--
 mm/hugetlb.c       |    4 ++--
 mm/mempolicy.c     |   41 ++++++++++++++++++++++-------------------
 4 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
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
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -216,8 +216,7 @@ struct vm_operations_struct {
 	 * get_policy() op must add reference [mpol_get()] to any policy at
 	 * (vma,addr) marked as MPOL_SHARED.  The shared policy infrastructure
 	 * in mm/mempolicy.c will do this automatically.
-	 * get_policy() must NOT add a ref if the policy at (vma,addr) is not
-	 * marked as MPOL_SHARED. vma policies are protected by the mmap_sem.
+	 * vma policies are protected by the mmap_sem.
 	 * If no [shared/vma] mempolicy exists at the addr, get_policy() op
 	 * must return NULL--i.e., do not "fallback" to task or system default
 	 * policy.
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
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
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1536,39 +1536,41 @@ asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
  *
  * Returns effective policy for a VMA at specified address.
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
-	struct mempolicy *pol = task->mempolicy;
+	struct mempolicy *pol;
+
+	task_lock(task);
+	pol = task->mempolicy;
+	mpol_get(pol);
+	task_unlock(task);
 
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
 
@@ -1919,7 +1921,7 @@ retry_cpuset:
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
-		mpol_cond_put(pol);
+		__mpol_put(pol);
 		page = alloc_page_interleave(gfp, order, nid);
 		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 			goto retry_cpuset;
@@ -1943,6 +1945,7 @@ retry_cpuset:
 	 */
 	page = __alloc_pages_nodemask(gfp, order, zl,
 				      policy_nodemask(gfp, pol));
+	__mpol_put(pol);
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
 	return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
