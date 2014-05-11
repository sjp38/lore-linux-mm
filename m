Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3BB6B0036
	for <linux-mm@kvack.org>; Sun, 11 May 2014 08:34:09 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so6395202pad.4
        for <linux-mm@kvack.org>; Sun, 11 May 2014 05:34:08 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id hu10si4920533pbc.100.2014.05.11.05.34.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 May 2014 05:34:08 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so6326265pab.21
        for <linux-mm@kvack.org>; Sun, 11 May 2014 05:34:07 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: Re: [PATCH 2/3] mm: use a light-weight __mod_zone_page_state in mlocked_vma_newpage()
Date: Sun, 11 May 2014 20:33:52 +0800
Message-Id: <1399811632-14712-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, aarcange@redhat.com, nasa4836@gmail.com, oleg@redhat.com, fabf@skynet.be, zhangyanfei@cn.fujitsu.com, mgorman@suse.de, sasha.levin@oracle.com, cldu@marvell.com, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, xemul@parallels.com, gorcunov@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

>I completely agree with Andrew's suggestion that you move the code
>from mm/internal.h to its sole callsite in mm/rmap.c; but I much
>prefer his "probably better ... open-coding its logic into
>page_add_new_anon_rmap()".
>
>That saves you from having to dream up a satisfactory alternative name,
>and a lengthy comment, and let's everybody see just what's going on.

 Hi, also thanks for the detailed comments!!!

 Yes, I also agree. But I just saw that mlocked_vma_newpage() is used 
 as a test stament in page_add_new_anon_rmap(), like:

    if (!mlocked_vma_newpage())
	...
    else
	...

 It is quite clear code logic for reading, so I think it is appropriate
 to still make it a function. But that's OK, I've folded it into 
 page_add_new_anon_rmap() in the new patch, see below. 
  
>The function-in-internal.h thing dates from an interim in which,
>running short of page flags, we were not confident that we wanted
>to dedicate one to PageMlocked: not all configs had it and internal.h
>was somewhere to hide the #ifdefs.  Well, PageMlocked is there only
>when CONFIG_MMU, but mm/rmap.c is only built for CONFIG_MMU anyway.
>In previous commit(mm: use the light version __mod_zone_page_state in
>mlocked_vma_newpage()) a irq-unsafe __mod_zone_page_state is used.
>And as suggested by Andrew, to reduce the risks that new call sites
>incorrectly using mlocked_vma_newpage() without knowing they are adding
>racing, this patch folds mlocked_vma_newpage() into its only call site,
>page_add_new_anon_rmap, to make it open-cocded.

 Thanks for telling me this, which be not be learned from code.

-----<8-----
mm: fold mlocked_vma_newpage() into its only call site
    
In previous commit(mm: use the light version __mod_zone_page_state in
mlocked_vma_newpage()) a irq-unsafe __mod_zone_page_state is used.
And as suggested by Andrew, to reduce the risks that new call sites
incorrectly using mlocked_vma_newpage() without knowing they are adding
racing, this patch folds mlocked_vma_newpage() into its only call site,
page_add_new_anon_rmap, to make it open-cocded.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/internal.h | 31 -------------------------------
 mm/rmap.c     | 22 +++++++++++++++++++---
 2 files changed, 19 insertions(+), 34 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 7140c9b..29f3dc8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -184,33 +184,6 @@ static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
 }
 
 /*
- * Called only in fault path, to determine if a new page is being
- * mapped into a LOCKED vma.  If it is, mark page as mlocked.
- */
-static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
-				    struct page *page)
-{
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-
-	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
-		return 0;
-
-	if (!TestSetPageMlocked(page)) {
-		/*
-		 * We use the irq-unsafe __mod_zone_page_stat because
-		 * 1. this counter is not modified in interrupt context, and
-		 * 2. pte lock is held, and this a newpage, which is initially
-		 *    only visible via the pagetables. So this would exclude
-		 *    racy processes from preemting us and to modify it.
-		 */
-		__mod_zone_page_state(page_zone(page), NR_MLOCK,
-				    hpage_nr_pages(page));
-		count_vm_event(UNEVICTABLE_PGMLOCKED);
-	}
-	return 1;
-}
-
-/*
  * must be called with vma's mmap_sem held for read or write, and page locked.
  */
 extern void mlock_vma_page(struct page *page);
@@ -252,10 +225,6 @@ extern unsigned long vma_address(struct page *page,
 				 struct vm_area_struct *vma);
 #endif
 #else /* !CONFIG_MMU */
-static inline int mlocked_vma_newpage(struct vm_area_struct *v, struct page *p)
-{
-	return 0;
-}
 static inline void clear_page_mlock(struct page *page) { }
 static inline void mlock_vma_page(struct page *page) { }
 static inline void mlock_migrate_page(struct page *new, struct page *old) { }
diff --git a/mm/rmap.c b/mm/rmap.c
index 0700253..b7bf67b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1030,11 +1030,27 @@ void page_add_new_anon_rmap(struct page *page,
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
 			hpage_nr_pages(page));
 	__page_set_anon_rmap(page, vma, address, 1);
-	if (!mlocked_vma_newpage(vma, page)) {
+
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
 		SetPageActive(page);
 		lru_cache_add(page);
-	} else
-		add_page_to_unevictable_list(page);
+		return;
+	}
+
+	if (!TestSetPageMlocked(page)) {
+		/*
+		 * We use the irq-unsafe __mod_zone_page_stat because
+		 * 1. this counter is not modified in interrupt context, and
+		 * 2. pte lock is held, and this a newpage, which is initially
+		 *    only visible via the pagetables. So this would exclude
+		 *    racy processes from preemting us and to modify it.
+		 */
+		__mod_zone_page_state(page_zone(page), NR_MLOCK,
+				    hpage_nr_pages(page));
+		count_vm_event(UNEVICTABLE_PGMLOCKED);
+	}
+	add_page_to_unevictable_list(page);
 }
 
 /**
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
