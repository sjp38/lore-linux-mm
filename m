Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 915886B0009
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:04 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id a61so10003010pla.22
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 126si3238897pfe.390.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:03 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 08/64] mm: teach lock_page_or_retry() about range locking
Date: Mon,  5 Feb 2018 02:26:58 +0100
Message-Id: <20180205012754.23615-9-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

The mmap_sem locking rules for lock_page_or_retry() depends on
the page being locked upon return, and can get funky. As such
we need to teach the function about mmrange, which is passed
on via vm_fault.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/pagemap.h | 7 ++++---
 mm/filemap.c            | 5 +++--
 mm/memory.c             | 3 ++-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 34ce3ebf97d5..e41a734efbe0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -464,7 +464,7 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
-				unsigned int flags);
+				unsigned int flags, struct range_lock *mmrange);
 extern void unlock_page(struct page *page);
 
 static inline int trylock_page(struct page *page)
@@ -504,10 +504,11 @@ static inline int lock_page_killable(struct page *page)
  * __lock_page_or_retry().
  */
 static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
-				     unsigned int flags)
+				     unsigned int flags,
+				     struct range_lock *mmrange)
 {
 	might_sleep();
-	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+	return trylock_page(page) || __lock_page_or_retry(page, mm, flags, mmrange);
 }
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f62212a59..6124ede79a4d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1293,7 +1293,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
  * with the page locked and the mmap_sem unperturbed.
  */
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
-			 unsigned int flags)
+			 unsigned int flags, struct range_lock *mmrange)
 {
 	if (flags & FAULT_FLAG_ALLOW_RETRY) {
 		/*
@@ -2529,7 +2529,8 @@ int filemap_fault(struct vm_fault *vmf)
 			goto no_cached_page;
 	}
 
-	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
+	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags,
+				vmf->lockrange)) {
 		put_page(page);
 		return ret | VM_FAULT_RETRY;
 	}
diff --git a/mm/memory.c b/mm/memory.c
index 2d087b0e174d..5adcdc7dee80 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2986,7 +2986,8 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out_release;
 	}
 
-	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
+	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags,
+				    vmf->lockrange);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
