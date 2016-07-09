Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83164828E1
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 13:17:41 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ts6so147453219pac.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 10:17:41 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id jy14si4937189pad.41.2016.07.09.10.17.38
        for <linux-mm@kvack.org>;
        Sat, 09 Jul 2016 10:17:39 -0700 (PDT)
From: chengang@emindsoft.com.cn
Subject: [PATCH] mm: gup: Re-define follow_page_mask output parameter page_mask usage
Date: Sun, 10 Jul 2016 01:17:05 +0800
Message-Id: <1468084625-26999-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com
Cc: kirill.shutemov@linux.intel.com, mingo@kernel.org, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, jack@suse.cz, iamjoonsoo.kim@lge.com, jmarchan@redhat.com, dingel@linux.vnet.ibm.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <chengang@emindsoft.com.cn>, Chen Gang <gang.chen.5i5j@gmail.com>

From: Chen Gang <chengang@emindsoft.com.cn>

For a pure output parameter:

 - When callee fails, the caller should not assume the output parameter
   is still valid.

 - And callee should not assume the pure output parameter must be
   provided by caller -- caller has right to pass NULL when caller does
   not care about it.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 include/linux/mm.h | 5 ++---
 mm/gup.c           | 6 +++---
 mm/mlock.c         | 2 +-
 mm/nommu.c         | 1 -
 4 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b21e5f3..5c560fd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2205,10 +2205,9 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned int *page_mask);
 
 static inline struct page *follow_page(struct vm_area_struct *vma,
-		unsigned long address, unsigned int foll_flags)
+				unsigned long address, unsigned int foll_flags)
 {
-	unsigned int unused_page_mask;
-	return follow_page_mask(vma, address, foll_flags, &unused_page_mask);
+	return follow_page_mask(vma, address, foll_flags, NULL);
 }
 
 #define FOLL_WRITE	0x01	/* check pte is writable */
diff --git a/mm/gup.c b/mm/gup.c
index 96b2b2f..9684b06 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -222,8 +222,6 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 
-	*page_mask = 0;
-
 	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
 	if (!IS_ERR(page)) {
 		BUG_ON(flags & FOLL_GET);
@@ -298,7 +296,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 
 	page = follow_trans_huge_pmd(vma, address, pmd, flags);
 	spin_unlock(ptl);
-	*page_mask = HPAGE_PMD_NR - 1;
+	if (page_mask)
+		*page_mask = HPAGE_PMD_NR - 1;
 	return page;
 }
 
@@ -574,6 +573,7 @@ retry:
 		if (unlikely(fatal_signal_pending(current)))
 			return i ? i : -ERESTARTSYS;
 		cond_resched();
+		page_mask = 0;
 		page = follow_page_mask(vma, start, foll_flags, &page_mask);
 		if (!page) {
 			int ret;
diff --git a/mm/mlock.c b/mm/mlock.c
index ef8dc9f..626eb58 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -438,7 +438,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 
 	while (start < end) {
 		struct page *page;
-		unsigned int page_mask;
+		unsigned int page_mask = 0;
 		unsigned long page_increm;
 		struct pagevec pvec;
 		struct zone *zone;
diff --git a/mm/nommu.c b/mm/nommu.c
index 95daf81..c1a0a89 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1749,7 +1749,6 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int flags,
 			      unsigned int *page_mask)
 {
-	*page_mask = 0;
 	return NULL;
 }
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
