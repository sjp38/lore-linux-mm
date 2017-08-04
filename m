Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7922802FE
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 10:56:36 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m80so5989364wmd.4
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 07:56:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 48si3670910wrt.399.2017.08.04.07.56.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 07:56:34 -0700 (PDT)
Date: Fri, 4 Aug 2017 16:56:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: fix potential data corruption when oom_reaper
 races with writer
Message-ID: <20170804145631.GP26029@dhcp22.suse.cz>
References: <201708040646.v746kkhC024636@www262.sakura.ne.jp>
 <20170804074212.GA26029@dhcp22.suse.cz>
 <201708040825.v748Pkul053862@www262.sakura.ne.jp>
 <20170804091629.GI26029@dhcp22.suse.cz>
 <201708041941.JFH26516.HOMtSQFFFOLVJO@I-love.SAKURA.ne.jp>
 <20170804110047.GK26029@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170804110047.GK26029@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, wenwei.tww@alibaba-inc.com, oleg@redhat.com, rientjes@google.com, linux-kernel@vger.kernel.org

On Fri 04-08-17 13:00:47, Michal Hocko wrote:
> On Fri 04-08-17 19:41:42, Tetsuo Handa wrote:
[...]
> > Yes. Data corruption still happens.
> 
> I guess I managed to reproduce finally. Will investigate further.

One limitation of the current MMF_UNSTABLE implementation is that it
still keeps the new page mapped and only sends EFAULT/kill to the
consumer. If somebody tries to re-read the same content nothing will
really happen. I went this way because it was much simpler and memory
consumers usually do not retry on EFAULT. Maybe this is not the case
here.

I've been staring into iov_iter_copy_from_user_atomic which I
believe should be the common write path which reads the user buffer
where the corruption caused by the oom_reaper would come from.
iov_iter_fault_in_readable should be called before this function. If
this happened after MMF_UNSTABLE was set then we should get EFAULT and
bail out early. Let's assume this wasn't the case. Then we should get
down to iov_iter_copy_from_user_atomic and that one shouldn't copy any
data because __copy_from_user_inatomic says

 * If copying succeeds, the return value must be 0.  If some data cannot be
 * fetched, it is permitted to copy less than had been fetched; the only
 * hard requirement is that not storing anything at all (i.e. returning size)
 * should happen only when nothing could be copied.  In other words, you don't
 * have to squeeze as much as possible - it is allowed, but not necessary.

which should be our case.

I was testing with xfs (but generic_perform_write seem to be doing the
same thing) and that one does
		if (unlikely(copied == 0)) {
			/*
			 * If we were unable to copy any data at all, we must
			 * fall back to a single segment length write.
			 *
			 * If we didn't fallback here, we could livelock
			 * because not all segments in the iov can be copied at
			 * once without a pagefault.
			 */
			bytes = min_t(unsigned long, PAGE_SIZE - offset,
						iov_iter_single_seg_count(i));
			goto again;
		}

and that again will go through iov_iter_fault_in_readable again and that
will succeed now.

And that's why we still see the corruption. That, however, means that
the MMF_UNSTABLE implementation has to be more complex and we have to
hook into all anonymous memory fault paths which I hoped I could avoid
previously.

This is a rough first draft that passes the test case from Tetsuo on my
system. It will need much more eyes on it and I will return to it with a
fresh brain next week. I would appreciate as much testing as possible.

Note that this is on top of the previous attempt for the fix but I will
squash the result into one patch because the previous one is not
sufficient.
---
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86975dec0ba1..1fbc78d423d7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -550,6 +550,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
+	int ret;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
@@ -561,9 +562,8 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 	pgtable = pte_alloc_one(vma->vm_mm, haddr);
 	if (unlikely(!pgtable)) {
-		mem_cgroup_cancel_charge(page, memcg, true);
-		put_page(page);
-		return VM_FAULT_OOM;
+		ret = VM_FAULT_OOM;
+		goto release;
 	}
 
 	clear_huge_page(page, haddr, HPAGE_PMD_NR);
@@ -583,6 +583,15 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 	} else {
 		pmd_t entry;
 
+		/*
+		 * range could have been already torn down by
+		 * the oom reaper
+		 */
+		if (test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)) {
+			spin_unlock(vmf->ptl);
+			ret = VM_FAULT_SIGBUS;
+			goto release;
+		}
 		/* Deliver the page fault to userland */
 		if (userfaultfd_missing(vma)) {
 			int ret;
@@ -610,6 +619,13 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 	}
 
 	return 0;
+release:
+	if (pgtable)
+		pte_free(vma->vm_mm, pgtable);
+	mem_cgroup_cancel_charge(page, memcg, true);
+	put_page(page);
+	return ret;
+
 }
 
 /*
@@ -688,7 +704,14 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		ret = 0;
 		set = false;
 		if (pmd_none(*vmf->pmd)) {
-			if (userfaultfd_missing(vma)) {
+			/*
+			 * range could have been already torn down by
+			 * the oom reaper
+			 */
+			if (test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)) {
+				spin_unlock(vmf->ptl);
+				ret = VM_FAULT_SIGBUS;
+			} else if (userfaultfd_missing(vma)) {
 				spin_unlock(vmf->ptl);
 				ret = handle_userfault(vmf, VM_UFFD_MISSING);
 				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
diff --git a/mm/memory.c b/mm/memory.c
index e7308e633b52..7de9508e38e4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2864,6 +2864,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	struct page *page;
+	int ret = 0;
 	pte_t entry;
 
 	/* File mapping without ->vm_ops ? */
@@ -2896,6 +2897,14 @@ static int do_anonymous_page(struct vm_fault *vmf)
 				vmf->address, &vmf->ptl);
 		if (!pte_none(*vmf->pte))
 			goto unlock;
+		/*
+		 * range could have been already torn down by
+		 * the oom reaper
+		 */
+		if (test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)) {
+			ret = VM_FAULT_SIGBUS;
+			goto unlock;
+		}
 		/* Deliver the page fault to userland, check inside PT lock */
 		if (userfaultfd_missing(vma)) {
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2930,6 +2939,15 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	if (!pte_none(*vmf->pte))
 		goto release;
 
+	/*
+	 * range could have been already torn down by
+	 * the oom reaper
+	 */
+	if (test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)) {
+		ret = VM_FAULT_SIGBUS;
+		goto release;
+	}
+
 	/* Deliver the page fault to userland, check inside PT lock */
 	if (userfaultfd_missing(vma)) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2949,7 +2967,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 unlock:
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
-	return 0;
+	return ret;
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
@@ -3231,7 +3249,10 @@ int finish_fault(struct vm_fault *vmf)
 		page = vmf->cow_page;
 	else
 		page = vmf->page;
-	ret = alloc_set_pte(vmf, vmf->memcg, page);
+	if (!test_bit(MMF_UNSTABLE, &vmf->vma->vm_mm->flags))
+		ret = alloc_set_pte(vmf, vmf->memcg, page);
+	else
+		ret = VM_FAULT_SIGBUS;
 	if (vmf->pte)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 	return ret;
@@ -3871,24 +3892,6 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 			mem_cgroup_oom_synchronize(false);
 	}
 
-	/*
-	 * This mm has been already reaped by the oom reaper and so the
-	 * refault cannot be trusted in general. Anonymous refaults would
-	 * lose data and give a zero page instead e.g.
-	 */
-	if (unlikely(!(ret & VM_FAULT_ERROR)
-				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags))) {
-		/*
-		 * We are going to enforce SIGBUS but the PF path might have
-		 * dropped the mmap_sem already so take it again so that
-		 * we do not break expectations of all arch specific PF paths
-		 * and g-u-p
-		 */
-		if (ret & VM_FAULT_RETRY)
-			down_read(&vma->vm_mm->mmap_sem);
-		ret = VM_FAULT_SIGBUS;
-	}
-
 	return ret;
 }
 EXPORT_SYMBOL_GPL(handle_mm_fault);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
