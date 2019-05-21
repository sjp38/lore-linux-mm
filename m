Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 819C5C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C31621019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C31621019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31B4B6B0269; Tue, 21 May 2019 00:53:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A7096B026B; Tue, 21 May 2019 00:53:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 083366B026C; Tue, 21 May 2019 00:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78A476B0269
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c24so28705251edb.6
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=go5Dz8Po2Ksq+kuxQmQq67VAxcYaEzBrmdzQ+AYtOfk=;
        b=ha/ZeHvSkfrw0rbo4jA0rwl8j1QGrgFhAuk3EHgI6/v9OPsh4CRRKuwr4cZT03fDU7
         ka02ub2uCVX0oPolvFdaW6fznQKQS60+/c4ETGqMUG5O1epy6yZ11zS0CoDVmQUcjeXz
         EM14XFp7DiCfRHx5fppjhy9/QDXKl22xOHdqi8TrA/VaESPF8M+6V1SA0h9sNEy2O/O7
         Hpnxl+QiWc6CiQuf17E+4Ct0Z6wQPmQx5VxS2UqHpoy5gRCFU29+9W3ePK05wbBe/8Kn
         HAhepqu2C0erDWe6EKk4+CZovAgRZDPFV3tmMwVCcd/ZpQa3KavTIBVjx/UxKU5gIE/V
         qKpw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAVNI/VGXn3Nx+1AiplWmd/OV0obbVYV6mpSkvQ1B2mzTI2Sdjgd
	4MYh6hGTGNDgaJS317x4FyRgPY4PWL0YHULobU9TJzfRO2PAsphKrm6tDtVRZYSiD9TcEHfJLl7
	keqC3cNeklma4NUZeppxH1xFh9vSKDXCSNQ+wI52clD+rFIOTITSNMWQiU3gHZtw=
X-Received: by 2002:a50:b797:: with SMTP id h23mr71391103ede.197.1558414421864;
        Mon, 20 May 2019 21:53:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEHvHYG+uA0Lvn+aPd7r8ejWxCsxwJPJTcMpoGDJF4Rq8giX9tnozcqCwlyFnK2+zPFvsb
X-Received: by 2002:a50:b797:: with SMTP id h23mr71390922ede.197.1558414418634;
        Mon, 20 May 2019 21:53:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414418; cv=none;
        d=google.com; s=arc-20160816;
        b=t/kqMhXtlBBHAdeV5GctsTZq0MuTh/J5p/sFCwGs8c7RjG5Qfsf6HsJkESMB4FZWC7
         LQcxoNZBGZOgin7fHwYH9skqByvIyZ+rJvXnEz8CwHRvxNAsfptJDhS8MuFIeeLvQtdj
         sskaT+X9CPpDGjbAEYkEf4buAA8PC+C9JSfRNXAP2d6qeYxr3K6E91hVD/GjmPOaby3d
         Kt7BH6YKHPtKFG1JMtRawcOTGWSHdWsy5wDLY8KoA4ClolMROrwFHb9/amBQO+3iU4YW
         0YnRu4IoSVyw8yupuIoLNMVMydLXe/QLDiFXeSp0oHCbgKzgwZZWxaWZLAORnWvAdOTk
         9yNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=go5Dz8Po2Ksq+kuxQmQq67VAxcYaEzBrmdzQ+AYtOfk=;
        b=KwVj9roGH++Dsa2K4IYPzJO0vaiv8wtyVMX7TRCHzbylPDqGv2RMEuCzH2M1s4Ana7
         VphtTrRdvMkrQERh/RUa4UeSe1r2W0sJJUhN59qXEAhKQKBtG5g2QdzYT7bJ1YycrD6K
         eKMypQzo1Uwl8owTNv8/RrW3qG/tnbSfRN30TFnWlYdVi3tzmd0UZcw9S8P7mHo7QIP9
         LX7dZABM7HFUc1RklBqrmCujEgsm9lnHLTvRxwq2WXKI7bt/VoqpIKe+m9ugYBc4izu7
         zZjzqoRwBFkvpDICnCu32SGvA6Lrh6+UacnLhTGOhRzSN01+6xwb8hV4RgiaUJu1vo0h
         HlPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id w57si4112491edd.169.2019.05.20.21.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:37 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:08 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 06/14] mm: teach the mm about range locking
Date: Mon, 20 May 2019 21:52:34 -0700
Message-Id: <20190521045242.24378-7-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Conversion is straightforward, mmap_sem is used within the
the same function context most of the time, and we already
have vmf updated. No changes in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/mm.h     |  8 +++---
 mm/filemap.c           |  8 +++---
 mm/frame_vector.c      |  4 +--
 mm/gup.c               | 21 +++++++--------
 mm/hmm.c               |  3 ++-
 mm/khugepaged.c        | 54 +++++++++++++++++++++------------------
 mm/ksm.c               | 42 +++++++++++++++++-------------
 mm/madvise.c           | 36 ++++++++++++++------------
 mm/memcontrol.c        | 10 +++++---
 mm/memory.c            | 10 +++++---
 mm/mempolicy.c         | 25 ++++++++++--------
 mm/migrate.c           | 10 +++++---
 mm/mincore.c           |  6 +++--
 mm/mlock.c             | 20 +++++++++------
 mm/mmap.c              | 69 ++++++++++++++++++++++++++++----------------------
 mm/mmu_notifier.c      |  9 ++++---
 mm/mprotect.c          | 15 ++++++-----
 mm/mremap.c            |  9 ++++---
 mm/msync.c             |  9 ++++---
 mm/nommu.c             | 25 ++++++++++--------
 mm/oom_kill.c          |  5 ++--
 mm/process_vm_access.c |  4 +--
 mm/shmem.c             |  2 +-
 mm/swapfile.c          |  5 ++--
 mm/userfaultfd.c       | 21 ++++++++-------
 mm/util.c              | 10 +++++---
 26 files changed, 252 insertions(+), 188 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 044e428b1905..8bf3e2542047 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1459,6 +1459,7 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *             right now." 1 means "skip the current vma."
  * @mm:        mm_struct representing the target process of page table walk
  * @vma:       vma currently walked (NULL if walking outside vmas)
+ * @mmrange:   mm address space range locking
  * @private:   private data for callbacks' usage
  *
  * (see the comment on walk_page_range() for more details)
@@ -2358,8 +2359,8 @@ static inline int check_data_rlimit(unsigned long rlim,
 	return 0;
 }
 
-extern int mm_take_all_locks(struct mm_struct *mm);
-extern void mm_drop_all_locks(struct mm_struct *mm);
+extern int mm_take_all_locks(struct mm_struct *mm, struct range_lock *mmrange);
+extern void mm_drop_all_locks(struct mm_struct *mm, struct range_lock *mmrange);
 
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
@@ -2389,7 +2390,8 @@ extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
 	struct list_head *uf);
 extern int __do_munmap(struct mm_struct *, unsigned long, size_t,
-		       struct list_head *uf, bool downgrade);
+		       struct list_head *uf, bool downgrade,
+		       struct range_lock *);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t,
 		     struct list_head *uf);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 959022841bab..71f0d8a18f40 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1388,7 +1388,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 		if (flags & FAULT_FLAG_RETRY_NOWAIT)
 			return 0;
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		if (flags & FAULT_FLAG_KILLABLE)
 			wait_on_page_locked_killable(page);
 		else
@@ -1400,7 +1400,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 
 			ret = __lock_page_killable(page);
 			if (ret) {
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, mmrange);
 				return 0;
 			}
 		} else
@@ -2317,7 +2317,7 @@ static struct file *maybe_unlock_mmap_for_io(struct vm_fault *vmf,
 	if ((flags & (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT)) ==
 	    FAULT_FLAG_ALLOW_RETRY) {
 		fpin = get_file(vmf->vma->vm_file);
-		up_read(&vmf->vma->vm_mm->mmap_sem);
+		mm_read_unlock(vmf->vma->vm_mm, vmf->lockrange);
 	}
 	return fpin;
 }
@@ -2357,7 +2357,7 @@ static int lock_page_maybe_drop_mmap(struct vm_fault *vmf, struct page *page,
 			 * mmap_sem here and return 0 if we don't have a fpin.
 			 */
 			if (*fpin == NULL)
-				up_read(&vmf->vma->vm_mm->mmap_sem);
+				mm_read_unlock(vmf->vma->vm_mm, vmf->lockrange);
 			return 0;
 		}
 	} else
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index 4e1a577cbb79..ef33d21b3f39 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -47,7 +47,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
 		nr_frames = vec->nr_allocated;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	locked = 1;
 	vma = find_vma_intersection(mm, start, start + 1);
 	if (!vma) {
@@ -102,7 +102,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
 out:
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	if (!ret)
 		ret = -EFAULT;
 	if (ret > 0)
diff --git a/mm/gup.c b/mm/gup.c
index cf8fa037ce27..70b546a01682 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -990,7 +990,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	}
 
 	if (ret & VM_FAULT_RETRY) {
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, mmrange);
 		if (!(fault_flags & FAULT_FLAG_TRIED)) {
 			*unlocked = true;
 			fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
@@ -1077,7 +1077,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		 */
 		*locked = 1;
 		lock_dropped = true;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, mmrange);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
 				       pages, NULL, NULL, NULL);
 		if (ret != 1) {
@@ -1098,7 +1098,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		 * We must let the caller know we temporarily dropped the lock
 		 * and so the critical section protected by it was lost.
 		 */
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		*locked = 0;
 	}
 	return pages_done;
@@ -1176,11 +1176,11 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 	if (WARN_ON_ONCE(gup_flags & FOLL_LONGTERM))
 		return -EINVAL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
 				      &locked, gup_flags | FOLL_TOUCH, &mmrange);
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	return ret;
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
@@ -1543,7 +1543,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG_ON_VMA(start < vma->vm_start, vma);
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+	VM_BUG_ON_MM(!mm_is_locked(mm, mmrange), mm);
 
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
 	if (vma->vm_flags & VM_LOCKONFAULT)
@@ -1596,7 +1596,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 */
 		if (!locked) {
 			locked = 1;
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &mmrange);
 			vma = find_vma(mm, nstart);
 		} else if (nstart >= vma->vm_end)
 			vma = vma->vm_next;
@@ -1628,7 +1628,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		ret = 0;
 	}
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	return ret;	/* 0 or negative error code */
 }
 
@@ -2189,17 +2189,18 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
 				   unsigned int gup_flags, struct page **pages)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * FIXME: FOLL_LONGTERM does not work with
 	 * get_user_pages_unlocked() (see comments in that function)
 	 */
 	if (gup_flags & FOLL_LONGTERM) {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		ret = __gup_longterm_locked(current, current->mm,
 					    start, nr_pages,
 					    pages, NULL, gup_flags);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	} else {
 		ret = get_user_pages_unlocked(start, nr_pages,
 					      pages, gup_flags);
diff --git a/mm/hmm.c b/mm/hmm.c
index 723109ac6bdc..a79a07f7ccc1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1118,7 +1118,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	do {
 		/* If range is no longer valid force retry. */
 		if (!range->valid) {
-			up_read(&hmm->mm->mmap_sem);
+			/*** BROKEN mmrange, we don't care about hmm (for now) */
+			mm_read_unlock(hmm->mm, NULL);
 			return -EAGAIN;
 		}
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 3eefcb8f797d..13d8e29f4674 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -488,6 +488,8 @@ void __khugepaged_exit(struct mm_struct *mm)
 		free_mm_slot(mm_slot);
 		mmdrop(mm);
 	} else if (mm_slot) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		/*
 		 * This is required to serialize against
 		 * khugepaged_test_exit() (which is guaranteed to run
@@ -496,8 +498,8 @@ void __khugepaged_exit(struct mm_struct *mm)
 		 * khugepaged has finished working on the pagetables
 		 * under the mmap_sem.
 		 */
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
+		mm_write_unlock(mm, &mmrange);
 	}
 }
 
@@ -908,7 +910,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, mmrange);
 			if (hugepage_vma_revalidate(mm, address, &vmf.vma)) {
 				/* vma is no longer available, don't continue to swapin */
 				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
@@ -961,7 +963,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * sync compaction, and we do not need to hold the mmap_sem during
 	 * that. We will recheck the vma after taking it again in write mode.
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, mmrange);
 	new_page = khugepaged_alloc_page(hpage, gfp, node);
 	if (!new_page) {
 		result = SCAN_ALLOC_HUGE_PAGE_FAIL;
@@ -973,11 +975,11 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, mmrange);
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		goto out_nolock;
 	}
 
@@ -985,7 +987,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!pmd) {
 		result = SCAN_PMD_NULL;
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		goto out_nolock;
 	}
 
@@ -997,17 +999,17 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!__collapse_huge_page_swapin(mm, vma, address, pmd,
 					 referenced, mmrange)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		goto out_nolock;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, mmrange);
 	/*
 	 * Prevent all access to pagetables with the exception of
 	 * gup_fast later handled by the ptep_clear_flush and the VM
 	 * handled by the anon_vma lock + PG_lock.
 	 */
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, mmrange);
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result)
 		goto out;
@@ -1091,7 +1093,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	khugepaged_pages_collapsed++;
 	result = SCAN_SUCCEED;
 out_up_write:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, mmrange);
 out_nolock:
 	trace_mm_collapse_huge_page(mm, isolated, result);
 	return;
@@ -1250,7 +1252,8 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 }
 
 #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
-static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
+static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff,
+				struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	unsigned long addr;
@@ -1275,12 +1278,12 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 		 * re-fault. Not ideal, but it's more important to not disturb
 		 * the system too much.
 		 */
-		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
+		if (mm_write_trylock(vma->vm_mm, mmrange)) {
 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
 			/* assume page table is clear */
 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
 			spin_unlock(ptl);
-			up_write(&vma->vm_mm->mmap_sem);
+			mm_write_unlock(vma->vm_mm, mmrange);
 			mm_dec_nr_ptes(vma->vm_mm);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
 		}
@@ -1307,8 +1310,9 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
  *    + unlock and free huge page;
  */
 static void collapse_shmem(struct mm_struct *mm,
-		struct address_space *mapping, pgoff_t start,
-		struct page **hpage, int node)
+			   struct address_space *mapping, pgoff_t start,
+			   struct page **hpage, int node,
+			   struct range_lock *mmrange)
 {
 	gfp_t gfp;
 	struct page *new_page;
@@ -1515,7 +1519,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		/*
 		 * Remove pte page tables, so we can re-fault the page as huge.
 		 */
-		retract_page_tables(mapping, start);
+		retract_page_tables(mapping, start, mmrange);
 		*hpage = NULL;
 
 		khugepaged_pages_collapsed++;
@@ -1566,8 +1570,9 @@ static void collapse_shmem(struct mm_struct *mm,
 }
 
 static void khugepaged_scan_shmem(struct mm_struct *mm,
-		struct address_space *mapping,
-		pgoff_t start, struct page **hpage)
+				  struct address_space *mapping,
+				  pgoff_t start, struct page **hpage,
+				  struct range_lock *mmrange)
 {
 	struct page *page = NULL;
 	XA_STATE(xas, &mapping->i_pages, start);
@@ -1633,7 +1638,8 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
 			result = SCAN_EXCEED_NONE_PTE;
 		} else {
 			node = khugepaged_find_target_node();
-			collapse_shmem(mm, mapping, start, hpage, node);
+			collapse_shmem(mm, mapping, start, hpage,
+				       node, mmrange);
 		}
 	}
 
@@ -1678,7 +1684,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	 * the next mm on the list.
 	 */
 	vma = NULL;
-	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
+	if (unlikely(!mm_read_trylock(mm, &mmrange)))
 		goto breakouterloop_mmap_sem;
 	if (likely(!khugepaged_test_exit(mm)))
 		vma = find_vma(mm, khugepaged_scan.address);
@@ -1723,10 +1729,10 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 				if (!shmem_huge_enabled(vma))
 					goto skip;
 				file = get_file(vma->vm_file);
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, &mmrange);
 				ret = 1;
 				khugepaged_scan_shmem(mm, file->f_mapping,
-						pgoff, hpage);
+						      pgoff, hpage, &mmrange);
 				fput(file);
 			} else {
 				ret = khugepaged_scan_pmd(mm, vma,
@@ -1744,7 +1750,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		}
 	}
 breakouterloop:
-	up_read(&mm->mmap_sem); /* exit_mmap will destroy ptes after this */
+	mm_read_unlock(mm, &mmrange); /* exit_mmap will destroy ptes after this */
 breakouterloop_mmap_sem:
 
 	spin_lock(&khugepaged_mm_lock);
diff --git a/mm/ksm.c b/mm/ksm.c
index ccc9737311eb..7f9826ea7dba 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -537,6 +537,7 @@ static void break_cow(struct rmap_item *rmap_item)
 	struct mm_struct *mm = rmap_item->mm;
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * It is not an accident that whenever we want to break COW
@@ -544,11 +545,11 @@ static void break_cow(struct rmap_item *rmap_item)
 	 */
 	put_anon_vma(rmap_item->anon_vma);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_mergeable_vma(mm, addr);
 	if (vma)
 		break_ksm(vma, addr);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 }
 
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
@@ -557,8 +558,9 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
 	struct page *page;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_mergeable_vma(mm, addr);
 	if (!vma)
 		goto out;
@@ -574,7 +576,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 out:
 		page = NULL;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return page;
 }
 
@@ -969,6 +971,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int err = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = list_entry(ksm_mm_head.mm_list.next,
@@ -978,7 +981,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	for (mm_slot = ksm_scan.mm_slot;
 			mm_slot != &ksm_mm_head; mm_slot = ksm_scan.mm_slot) {
 		mm = mm_slot->mm;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (ksm_test_exit(mm))
 				break;
@@ -991,7 +994,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 		}
 
 		remove_trailing_rmap_items(mm_slot, &mm_slot->rmap_list);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 
 		spin_lock(&ksm_mmlist_lock);
 		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
@@ -1014,7 +1017,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	return 0;
 
 error:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = &ksm_mm_head;
 	spin_unlock(&ksm_mmlist_lock);
@@ -1299,8 +1302,9 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	struct mm_struct *mm = rmap_item->mm;
 	struct vm_area_struct *vma;
 	int err = -EFAULT;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_mergeable_vma(mm, rmap_item->address);
 	if (!vma)
 		goto out;
@@ -1316,7 +1320,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	rmap_item->anon_vma = vma->anon_vma;
 	get_anon_vma(vma->anon_vma);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return err;
 }
 
@@ -2129,12 +2133,13 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	 */
 	if (ksm_use_zero_pages && (checksum == zero_checksum)) {
 		struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = find_mergeable_vma(mm, rmap_item->address);
 		err = try_to_merge_one_page(vma, page,
 					    ZERO_PAGE(rmap_item->address));
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		/*
 		 * In case of failure, the page was not really empty, so we
 		 * need to continue. Otherwise we're done.
@@ -2240,6 +2245,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
 	int nid;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (list_empty(&ksm_mm_head.mm_list))
 		return NULL;
@@ -2297,7 +2303,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	}
 
 	mm = slot->mm;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	if (ksm_test_exit(mm))
 		vma = NULL;
 	else
@@ -2331,7 +2337,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 					ksm_scan.address += PAGE_SIZE;
 				} else
 					put_page(*page);
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, &mmrange);
 				return rmap_item;
 			}
 			put_page(*page);
@@ -2369,10 +2375,10 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 
 		free_mm_slot(slot);
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		mmdrop(mm);
 	} else {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		/*
 		 * up_read(&mm->mmap_sem) first because after
 		 * spin_unlock(&ksm_mmlist_lock) run, the "mm" may
@@ -2571,8 +2577,10 @@ void __ksm_exit(struct mm_struct *mm)
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
 		mmdrop(mm);
 	} else if (mm_slot) {
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
+		mm_write_lock(mm, &mmrange);
+		mm_write_unlock(mm, &mmrange);
 	}
 }
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 628022e674a7..78a3f86d9c52 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -516,16 +516,16 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
 static long madvise_dontneed_free(struct vm_area_struct *vma,
 				  struct vm_area_struct **prev,
 				  unsigned long start, unsigned long end,
-				  int behavior)
+				  int behavior, struct range_lock *mmrange)
 {
 	*prev = vma;
 	if (!can_madv_dontneed_vma(vma))
 		return -EINVAL;
 
-	if (!userfaultfd_remove(vma, start, end)) {
+	if (!userfaultfd_remove(vma, start, end, mmrange)) {
 		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, mmrange);
 		vma = find_vma(current->mm, start);
 		if (!vma)
 			return -ENOMEM;
@@ -574,8 +574,9 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
  * This is effectively punching a hole into the middle of a file.
  */
 static long madvise_remove(struct vm_area_struct *vma,
-				struct vm_area_struct **prev,
-				unsigned long start, unsigned long end)
+			   struct vm_area_struct **prev,
+			   unsigned long start, unsigned long end,
+			   struct range_lock *mmrange)
 {
 	loff_t offset;
 	int error;
@@ -605,15 +606,15 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 * mmap_sem.
 	 */
 	get_file(f);
-	if (userfaultfd_remove(vma, start, end)) {
+	if (userfaultfd_remove(vma, start, end, mmrange)) {
 		/* mmap_sem was not released by userfaultfd_remove() */
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, mmrange);
 	}
 	error = vfs_fallocate(f,
 				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 				offset, end - start);
 	fput(f);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, mmrange);
 	return error;
 }
 
@@ -688,16 +689,18 @@ static int madvise_inject_error(int behavior,
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+	    unsigned long start, unsigned long end, int behavior,
+	    struct range_lock *mmrange)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
-		return madvise_remove(vma, prev, start, end);
+		return madvise_remove(vma, prev, start, end, mmrange);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_FREE:
 	case MADV_DONTNEED:
-		return madvise_dontneed_free(vma, prev, start, end, behavior);
+		return madvise_dontneed_free(vma, prev, start, end,
+					     behavior, mmrange);
 	default:
 		return madvise_behavior(vma, prev, start, end, behavior);
 	}
@@ -809,6 +812,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	int write;
 	size_t len;
 	struct blk_plug plug;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!madvise_behavior_valid(behavior))
 		return error;
@@ -836,10 +840,10 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 
 	write = madvise_need_mmap_write(behavior);
 	if (write) {
-		if (down_write_killable(&current->mm->mmap_sem))
+		if (mm_write_lock_killable(current->mm, &mmrange))
 			return -EINTR;
 	} else {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 	}
 
 	/*
@@ -872,7 +876,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 			tmp = end;
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
+		error = madvise_vma(vma, &prev, start, tmp, behavior, &mmrange);
 		if (error)
 			goto out;
 		start = tmp;
@@ -889,9 +893,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 out:
 	blk_finish_plug(&plug);
 	if (write)
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &mmrange);
 	else
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 	return error;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2535e54e7989..c822cea99570 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5139,10 +5139,11 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 		.pmd_entry = mem_cgroup_count_precharge_pte_range,
 		.mm = mm,
 	};
-	down_read(&mm->mmap_sem);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+	mm_read_lock(mm, &mmrange);
 	walk_page_range(0, mm->highest_vm_end,
 			&mem_cgroup_count_precharge_walk);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	precharge = mc.precharge;
 	mc.precharge = 0;
@@ -5412,6 +5413,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 
 static void mem_cgroup_move_charge(void)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct mm_walk mem_cgroup_move_charge_walk = {
 		.pmd_entry = mem_cgroup_move_charge_pte_range,
 		.mm = mc.mm,
@@ -5426,7 +5428,7 @@ static void mem_cgroup_move_charge(void)
 	atomic_inc(&mc.from->moving_account);
 	synchronize_rcu();
 retry:
-	if (unlikely(!down_read_trylock(&mc.mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mc.mm, &mmrange))) {
 		/*
 		 * Someone who are holding the mmap_sem might be waiting in
 		 * waitq. So we cancel all extra charges, wake up all waiters,
@@ -5444,7 +5446,7 @@ static void mem_cgroup_move_charge(void)
 	 */
 	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk);
 
-	up_read(&mc.mm->mmap_sem);
+	mm_read_unlock(mc.mm, &mmrange);
 	atomic_dec(&mc.from->moving_account);
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 73971f859035..8a5f52978893 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4347,8 +4347,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	void *old_buf = buf;
 	int write = gup_flags & FOLL_WRITE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
@@ -4397,7 +4398,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return buf - old_buf;
 }
@@ -4450,11 +4451,12 @@ void print_vma_addr(char *prefix, unsigned long ip)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * we might be running from an atomic context so we cannot sleep
 	 */
-	if (!down_read_trylock(&mm->mmap_sem))
+	if (!mm_read_trylock(mm, &mmrange))
 		return;
 
 	vma = find_vma(mm, ip);
@@ -4473,7 +4475,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 			free_page((unsigned long)buf);
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 }
 
 #if defined(CONFIG_PROVE_LOCKING) || defined(CONFIG_DEBUG_ATOMIC_SLEEP)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 975793cc1d71..8bf8861e0c73 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -378,11 +378,12 @@ void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new)
 void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 {
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
 		mpol_rebind_policy(vma->vm_policy, new);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 }
 
 static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
@@ -837,7 +838,7 @@ static int lookup_node(struct mm_struct *mm, unsigned long addr,
 		put_page(p);
 	}
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 	return err;
 }
 
@@ -871,10 +872,10 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		 * vma/shared policy at addr is NULL.  We
 		 * want to return MPOL_DEFAULT in this case.
 		 */
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = find_vma_intersection(mm, addr, addr+1);
 		if (!vma) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			return -EFAULT;
 		}
 		if (vma->vm_ops && vma->vm_ops->get_policy)
@@ -933,7 +934,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	if (pol_refcount)
 		mpol_put(pol_refcount);
 	return err;
@@ -1026,12 +1027,13 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	int busy = 0;
 	int err;
 	nodemask_t tmp;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	err = migrate_prep();
 	if (err)
 		return err;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	/*
 	 * Find a 'source' bit set in 'tmp' whose corresponding 'dest'
@@ -1112,7 +1114,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 		if (err < 0)
 			break;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (err < 0)
 		return err;
 	return busy;
@@ -1186,6 +1188,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	unsigned long end;
 	int err;
 	LIST_HEAD(pagelist);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (flags & ~(unsigned long)MPOL_MF_VALID)
 		return -EINVAL;
@@ -1233,12 +1236,12 @@ static long do_mbind(unsigned long start, unsigned long len,
 	{
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			down_write(&mm->mmap_sem);
+			mm_write_lock(mm, &mmrange);
 			task_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
 			task_unlock(current);
 			if (err)
-				up_write(&mm->mmap_sem);
+				mm_write_unlock(mm, &mmrange);
 		} else
 			err = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
@@ -1267,7 +1270,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	} else
 		putback_movable_pages(&pagelist);
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
  mpol_out:
 	mpol_put(new);
 	return err;
diff --git a/mm/migrate.c b/mm/migrate.c
index f2ecc2855a12..3a268b316e4e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1531,8 +1531,9 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 	struct page *page;
 	unsigned int follflags;
 	int err;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	err = -EFAULT;
 	vma = find_vma(mm, addr);
 	if (!vma || addr < vma->vm_start || !vma_migratable(vma))
@@ -1585,7 +1586,7 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 	 */
 	put_page(page);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return err;
 }
 
@@ -1686,8 +1687,9 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 				const void __user **pages, int *status)
 {
 	unsigned long i;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	for (i = 0; i < nr_pages; i++) {
 		unsigned long addr = (unsigned long)(*pages);
@@ -1714,7 +1716,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 		status++;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 }
 
 /*
diff --git a/mm/mincore.c b/mm/mincore.c
index c3f058bd0faf..c1d3a9cd2ba3 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -270,13 +270,15 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 
 	retval = 0;
 	while (pages) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		/*
 		 * Do at most PAGE_SIZE entries per iteration, due to
 		 * the temporary buffer size.
 		 */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 		if (retval <= 0)
 			break;
diff --git a/mm/mlock.c b/mm/mlock.c
index e492a155c51a..c5b5dbd92a3a 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -670,6 +670,7 @@ static int count_mm_mlocked_page_nr(struct mm_struct *mm,
 
 static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long locked;
 	unsigned long lock_limit;
 	int error = -ENOMEM;
@@ -684,7 +685,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	lock_limit >>= PAGE_SHIFT;
 	locked = len >> PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 
 	locked += atomic64_read(&current->mm->locked_vm);
@@ -703,7 +704,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = apply_vma_lock_flags(start, len, flags);
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	if (error)
 		return error;
 
@@ -733,15 +734,16 @@ SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 
 SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	int ret;
 
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 	ret = apply_vma_lock_flags(start, len, 0);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 
 	return ret;
 }
@@ -794,6 +796,7 @@ static int apply_mlockall_flags(int flags)
 
 SYSCALL_DEFINE1(mlockall, int, flags)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long lock_limit;
 	int ret;
 
@@ -806,14 +809,14 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 
 	ret = -ENOMEM;
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = apply_mlockall_flags(flags);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
 
@@ -822,12 +825,13 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 
 SYSCALL_DEFINE0(munlockall)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	int ret;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 	ret = apply_mlockall_flags(0);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	return ret;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index a03ded49f9eb..2eecdeb5fcd6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -198,9 +198,10 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	unsigned long min_brk;
 	bool populate;
 	bool downgraded = false;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	LIST_HEAD(uf);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	origbrk = mm->brk;
@@ -251,7 +252,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 		 * mm->brk will be restored from origbrk.
 		 */
 		mm->brk = brk;
-		ret = __do_munmap(mm, newbrk, oldbrk-newbrk, &uf, true);
+		ret = __do_munmap(mm, newbrk, oldbrk-newbrk, &uf, true, &mmrange);
 		if (ret < 0) {
 			mm->brk = origbrk;
 			goto out;
@@ -274,9 +275,9 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 success:
 	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
 	if (downgraded)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	else
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate)
 		mm_populate(oldbrk, newbrk - oldbrk);
@@ -284,7 +285,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 
 out:
 	retval = origbrk;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return retval;
 }
 
@@ -2726,7 +2727,8 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * Jeremy Fitzhardinge <jeremy@goop.org>
  */
 int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
-		struct list_head *uf, bool downgrade)
+		struct list_head *uf, bool downgrade,
+		struct range_lock *mmrange)
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
@@ -2824,7 +2826,7 @@ int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
 
 	if (downgrade)
-		downgrade_write(&mm->mmap_sem);
+		mm_downgrade_write(mm, mmrange);
 
 	unmap_region(mm, vma, prev, start, end);
 
@@ -2837,7 +2839,7 @@ int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	      struct list_head *uf)
 {
-	return __do_munmap(mm, start, len, uf, false);
+	return __do_munmap(mm, start, len, uf, false, NULL);
 }
 
 static int __vm_munmap(unsigned long start, size_t len, bool downgrade)
@@ -2845,21 +2847,22 @@ static int __vm_munmap(unsigned long start, size_t len, bool downgrade)
 	int ret;
 	struct mm_struct *mm = current->mm;
 	LIST_HEAD(uf);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
-	ret = __do_munmap(mm, start, len, &uf, downgrade);
+	ret = __do_munmap(mm, start, len, &uf, downgrade, &mmrange);
 	/*
 	 * Returning 1 indicates mmap_sem is downgraded.
 	 * But 1 is not legal return value of vm_munmap() and munmap(), reset
 	 * it to 0 before return.
 	 */
 	if (ret == 1) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		ret = 0;
 	} else
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
@@ -2884,6 +2887,7 @@ SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		unsigned long, prot, unsigned long, pgoff, unsigned long, flags)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -2906,7 +2910,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
 		return ret;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	vma = find_vma(mm, start);
@@ -2969,7 +2973,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 			prot, flags, pgoff, &populate, NULL);
 	fput(file);
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	if (populate)
 		mm_populate(ret, populate);
 	if (!IS_ERR_VALUE(ret))
@@ -3056,6 +3060,7 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
 
 int vm_brk_flags(unsigned long addr, unsigned long request, unsigned long flags)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct mm_struct *mm = current->mm;
 	unsigned long len;
 	int ret;
@@ -3068,12 +3073,12 @@ int vm_brk_flags(unsigned long addr, unsigned long request, unsigned long flags)
 	if (!len)
 		return 0;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	ret = do_brk_flags(addr, len, flags, &uf);
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate && !ret)
 		mm_populate(addr, len);
@@ -3098,6 +3103,8 @@ void exit_mmap(struct mm_struct *mm)
 	mmu_notifier_release(mm);
 
 	if (unlikely(mm_is_oom_victim(mm))) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		/*
 		 * Manually reap the mm to free as much memory as possible.
 		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
@@ -3117,8 +3124,8 @@ void exit_mmap(struct mm_struct *mm)
 		(void)__oom_reap_task_mm(mm);
 
 		set_bit(MMF_OOM_SKIP, &mm->flags);
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
+		mm_write_unlock(mm, &mmrange);
 	}
 
 	if (atomic64_read(&mm->locked_vm)) {
@@ -3459,14 +3466,15 @@ int install_special_mapping(struct mm_struct *mm,
 
 static DEFINE_MUTEX(mm_all_locks_mutex);
 
-static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
+static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma,
+			     struct range_lock *mmrange)
 {
 	if (!test_bit(0, (unsigned long *) &anon_vma->root->rb_root.rb_root.rb_node)) {
 		/*
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, mmrange);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->root->rwsem. If some other vma in this mm shares
@@ -3482,7 +3490,8 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 	}
 }
 
-static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
+static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping,
+			    struct range_lock *mmrange)
 {
 	if (!test_bit(AS_MM_ALL_LOCKS, &mapping->flags)) {
 		/*
@@ -3496,7 +3505,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, mmrange);
 	}
 }
 
@@ -3537,12 +3546,12 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  *
  * mm_take_all_locks() can fail if it's interrupted by signals.
  */
-int mm_take_all_locks(struct mm_struct *mm)
+int mm_take_all_locks(struct mm_struct *mm, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm, mmrange));
 
 	mutex_lock(&mm_all_locks_mutex);
 
@@ -3551,7 +3560,7 @@ int mm_take_all_locks(struct mm_struct *mm)
 			goto out_unlock;
 		if (vma->vm_file && vma->vm_file->f_mapping &&
 				is_vm_hugetlb_page(vma))
-			vm_lock_mapping(mm, vma->vm_file->f_mapping);
+			vm_lock_mapping(mm, vma->vm_file->f_mapping, mmrange);
 	}
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
@@ -3559,7 +3568,7 @@ int mm_take_all_locks(struct mm_struct *mm)
 			goto out_unlock;
 		if (vma->vm_file && vma->vm_file->f_mapping &&
 				!is_vm_hugetlb_page(vma))
-			vm_lock_mapping(mm, vma->vm_file->f_mapping);
+			vm_lock_mapping(mm, vma->vm_file->f_mapping, mmrange);
 	}
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
@@ -3567,13 +3576,13 @@ int mm_take_all_locks(struct mm_struct *mm)
 			goto out_unlock;
 		if (vma->anon_vma)
 			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
-				vm_lock_anon_vma(mm, avc->anon_vma);
+				vm_lock_anon_vma(mm, avc->anon_vma, mmrange);
 	}
 
 	return 0;
 
 out_unlock:
-	mm_drop_all_locks(mm);
+	mm_drop_all_locks(mm, mmrange);
 	return -EINTR;
 }
 
@@ -3617,12 +3626,12 @@ static void vm_unlock_mapping(struct address_space *mapping)
  * The mmap_sem cannot be released by the caller until
  * mm_drop_all_locks() returns.
  */
-void mm_drop_all_locks(struct mm_struct *mm)
+void mm_drop_all_locks(struct mm_struct *mm, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm, mmrange));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index ee36068077b6..028eaed031e1 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -244,6 +244,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 {
 	struct mmu_notifier_mm *mmu_notifier_mm;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
@@ -253,8 +254,8 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		goto out;
 
 	if (take_mmap_sem)
-		down_write(&mm->mmap_sem);
-	ret = mm_take_all_locks(mm);
+		mm_write_lock(mm, &mmrange);
+	ret = mm_take_all_locks(mm, &mmrange);
 	if (unlikely(ret))
 		goto out_clean;
 
@@ -279,10 +280,10 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
-	mm_drop_all_locks(mm);
+	mm_drop_all_locks(mm, &mmrange);
 out_clean:
 	if (take_mmap_sem)
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 	kfree(mmu_notifier_mm);
 out:
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 36c517c6a5b1..443b033f240c 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -458,6 +458,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 static int do_mprotect_pkey(unsigned long start, size_t len,
 		unsigned long prot, int pkey)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
 	int error = -EINVAL;
@@ -482,7 +483,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 
 	reqprot = prot;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 
 	/*
@@ -572,7 +573,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 		prot = reqprot;
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	return error;
 }
 
@@ -594,6 +595,7 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 {
 	int pkey;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* No flags supported yet. */
 	if (flags)
@@ -602,7 +604,7 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 	if (init_val & ~PKEY_ACCESS_MASK)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 	pkey = mm_pkey_alloc(current->mm);
 
 	ret = -ENOSPC;
@@ -616,17 +618,18 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 	}
 	ret = pkey;
 out:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	return ret;
 }
 
 SYSCALL_DEFINE1(pkey_free, int, pkey)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 	ret = mm_pkey_free(current->mm, pkey);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 
 	/*
 	 * We could provie warnings or errors if any VMA still
diff --git a/mm/mremap.c b/mm/mremap.c
index 37b5b2ad91be..9009210aea97 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -603,6 +603,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	bool locked = false;
 	bool downgraded = false;
 	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
 
@@ -626,7 +627,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	if (!new_len)
 		return ret;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 
 	if (flags & MREMAP_FIXED) {
@@ -645,7 +646,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		int retval;
 
 		retval = __do_munmap(mm, addr+new_len, old_len - new_len,
-				  &uf_unmap, true);
+				     &uf_unmap, true, &mmrange);
 		if (retval < 0 && old_len != new_len) {
 			ret = retval;
 			goto out;
@@ -717,9 +718,9 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		locked = 0;
 	}
 	if (downgraded)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	else
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &mmrange);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
 	userfaultfd_unmap_complete(mm, &uf_unmap_early);
diff --git a/mm/msync.c b/mm/msync.c
index ef30a429623a..2524b4708e78 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -36,6 +36,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	struct vm_area_struct *vma;
 	int unmapped_error = 0;
 	int error = -EINVAL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
@@ -55,7 +56,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, start);
 	for (;;) {
 		struct file *file;
@@ -86,12 +87,12 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			error = vfs_fsync_range(file, fstart, fend, 1);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &mmrange);
 			vma = find_vma(mm, start);
 		} else {
 			if (start >= end) {
@@ -102,7 +103,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		}
 	}
 out_unlock:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 out:
 	return error ? : unmapped_error;
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index b492fd1fcf9f..b454b0004fd2 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -183,10 +183,11 @@ static long __get_user_pages_unlocked(struct task_struct *tsk,
 			unsigned int gup_flags)
 {
 	long ret;
-	down_read(&mm->mmap_sem);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+	mm_read_lock(mm, &mmrange);
 	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
 				NULL, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return ret;
 }
 
@@ -249,12 +250,13 @@ void *vmalloc_user(unsigned long size)
 	ret = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	if (ret) {
 		struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm, &mmrange);
 		vma = find_vma(current->mm, (unsigned long)ret);
 		if (vma)
 			vma->vm_flags |= VM_USERMAP;
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &mmrange);
 	}
 
 	return ret;
@@ -1627,10 +1629,11 @@ int vm_munmap(unsigned long addr, size_t len)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	ret = do_munmap(mm, addr, len, NULL);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 EXPORT_SYMBOL(vm_munmap);
@@ -1716,10 +1719,11 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		unsigned long, new_addr)
 {
 	unsigned long ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	return ret;
 }
 
@@ -1790,8 +1794,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 {
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
@@ -1813,7 +1818,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		len = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return len;
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 539c91d0b26a..a8e3e6279718 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -558,8 +558,9 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	bool ret = true;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		trace_skip_task_reaping(tsk->pid);
 		return false;
 	}
@@ -590,7 +591,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 out_finish:
 	trace_finish_task_reaping(tsk->pid);
 out_unlock:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return ret;
 }
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index ff6772b86195..aaccb8972f83 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -110,12 +110,12 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 * access remotely because task/mm might not
 		 * current/current->mm
 		 */
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		pages = get_user_pages_remote(task, mm, pa, pages, flags,
 					      process_pages, NULL, &locked,
 					      &mmrange);
 		if (locked)
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 		if (pages <= 0)
 			return -EFAULT;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 1bb3b8dc8bb2..bae06efb293d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2012,7 +2012,7 @@ static vm_fault_t shmem_fault(struct vm_fault *vmf)
 			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
 			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				/* It's polite to up mmap_sem if we can */
-				up_read(&vma->vm_mm->mmap_sem);
+				mm_read_unlock(vma->vm_mm, vmf->lockrange);
 				ret = VM_FAULT_RETRY;
 			}
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index be36f6fe2f8c..dabe7d5391d1 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1972,8 +1972,9 @@ static int unuse_mm(struct mm_struct *mm, unsigned int type,
 {
 	struct vm_area_struct *vma;
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma) {
 			ret = unuse_vma(vma, type, frontswap,
@@ -1983,7 +1984,7 @@ static int unuse_mm(struct mm_struct *mm, unsigned int type,
 		}
 		cond_resched();
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return ret;
 }
 
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 9932d5755e4c..06daedcd06e6 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -177,7 +177,8 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 					      unsigned long dst_start,
 					      unsigned long src_start,
 					      unsigned long len,
-					      bool zeropage)
+					      bool zeropage,
+					      struct range_lock *mmrange)
 {
 	int vm_alloc_shared = dst_vma->vm_flags & VM_SHARED;
 	int vm_shared = dst_vma->vm_flags & VM_SHARED;
@@ -199,7 +200,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	 * feature is not supported.
 	 */
 	if (zeropage) {
-		up_read(&dst_mm->mmap_sem);
+		mm_read_unlock(dst_mm, mmrange);
 		return -EINVAL;
 	}
 
@@ -297,7 +298,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		cond_resched();
 
 		if (unlikely(err == -ENOENT)) {
-			up_read(&dst_mm->mmap_sem);
+			mm_read_unlock(dst_mm, mmrange);
 			BUG_ON(!page);
 
 			err = copy_huge_page_from_user(page,
@@ -307,7 +308,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 				err = -EFAULT;
 				goto out;
 			}
-			down_read(&dst_mm->mmap_sem);
+			mm_read_lock(dst_mm, mmrange);
 
 			dst_vma = NULL;
 			goto retry;
@@ -327,7 +328,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	}
 
 out_unlock:
-	up_read(&dst_mm->mmap_sem);
+	mm_read_unlock(dst_mm, mmrange);
 out:
 	if (page) {
 		/*
@@ -445,6 +446,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	unsigned long src_addr, dst_addr;
 	long copied;
 	struct page *page;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * Sanitize the command parameters:
@@ -461,7 +463,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	copied = 0;
 	page = NULL;
 retry:
-	down_read(&dst_mm->mmap_sem);
+	mm_read_lock(dst_mm, &mmrange);
 
 	/*
 	 * If memory mappings are changing because of non-cooperative
@@ -506,7 +508,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 */
 	if (is_vm_hugetlb_page(dst_vma))
 		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
-						src_start, len, zeropage);
+					       src_start, len, zeropage,
+					       &mmrange);
 
 	if (!vma_is_anonymous(dst_vma) && !vma_is_shmem(dst_vma))
 		goto out_unlock;
@@ -562,7 +565,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		if (unlikely(err == -ENOENT)) {
 			void *page_kaddr;
 
-			up_read(&dst_mm->mmap_sem);
+			mm_read_unlock(dst_mm, &mmrange);
 			BUG_ON(!page);
 
 			page_kaddr = kmap(page);
@@ -591,7 +594,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	}
 
 out_unlock:
-	up_read(&dst_mm->mmap_sem);
+	mm_read_unlock(dst_mm, &mmrange);
 out:
 	if (page)
 		put_page(page);
diff --git a/mm/util.c b/mm/util.c
index e2e4f8c3fa12..c410c17ddea7 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -350,6 +350,7 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long pgoff)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long ret;
 	struct mm_struct *mm = current->mm;
 	unsigned long populate;
@@ -357,11 +358,11 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
-		if (down_write_killable(&mm->mmap_sem))
+		if (mm_write_lock_killable(mm, &mmrange))
 			return -EINTR;
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
 				    &populate, &uf);
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 		userfaultfd_unmap_complete(mm, &uf);
 		if (populate)
 			mm_populate(ret, populate);
@@ -711,18 +712,19 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	int res = 0;
 	unsigned int len;
 	struct mm_struct *mm = get_task_mm(task);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long arg_start, arg_end, env_start, env_end;
 	if (!mm)
 		goto out;
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	len = arg_end - arg_start;
 
-- 
2.16.4

