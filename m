Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 187D16B0313
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so37624959wmf.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 1si3379605wrn.181.2017.05.24.04.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:23 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OB9kvO143639
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:22 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2an7evdhjd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:22 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:20 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 06/10] mm: Add a range lock parameter to lock_page_or_retry()
Date: Wed, 24 May 2017 13:19:57 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-7-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

As lock_page_or_retry() may release the mmap_sem, it has to know about
the range applying to the lock when using range locks.

This patch adds a new range parameter to __lock_page_or_retry() and
deals with the callers.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/pagemap.h | 17 +++++++++++++++++
 mm/filemap.c            |  9 +++++++--
 mm/memory.c             |  3 ++-
 3 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 316a19f6b635..efc62200d527 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -433,8 +433,13 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
+#ifdef CONFIG_MEM_RANGE_LOCK
+extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				unsigned int flags, struct range_lock *range);
+#else
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				unsigned int flags);
+#endif
 extern void unlock_page(struct page *page);
 
 static inline int trylock_page(struct page *page)
@@ -473,12 +478,24 @@ static inline int lock_page_killable(struct page *page)
  * Return value and mmap_sem implications depend on flags; see
  * __lock_page_or_retry().
  */
+#ifdef CONFIG_MEM_RANGE_LOCK
 static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				     unsigned int flags,
+				     struct range_lock *range)
+{
+	might_sleep();
+	return trylock_page(page) || __lock_page_or_retry(page, mm, flags,
+							  range);
+}
+#else
+static inline int _lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				     unsigned int flags)
 {
 	might_sleep();
 	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
 }
+#define lock_page_or_retry(p, m, f, r) _lock_page_or_retry(p, m, f)
+#endif /* CONFIG_MEM_RANGE_LOCK */
 
 /*
  * This is exported only for wait_on_page_locked/wait_on_page_writeback, etc.,
diff --git a/mm/filemap.c b/mm/filemap.c
index 6f1be573a5e6..adb7c15b8aa4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1053,7 +1053,11 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
  * with the page locked and the mmap_sem unperturbed.
  */
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
-			 unsigned int flags)
+			 unsigned int flags
+#ifdef CONFIG_MEM_RANGE_LOCK
+			 , struct range_lock *range
+#endif
+	)
 {
 	if (flags & FAULT_FLAG_ALLOW_RETRY) {
 		/*
@@ -2234,7 +2238,8 @@ int filemap_fault(struct vm_fault *vmf)
 			goto no_cached_page;
 	}
 
-	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
+	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags,
+				vmf->lockrange)) {
 		put_page(page);
 		return ret | VM_FAULT_RETRY;
 	}
diff --git a/mm/memory.c b/mm/memory.c
index aa080e9814d4..99f62156616e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2737,7 +2737,8 @@ int do_swap_page(struct vm_fault *vmf)
 	}
 
 	swapcache = page;
-	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
+	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags,
+				    vmf->lockrange);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
