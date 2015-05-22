Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0836B018F
	for <linux-mm@kvack.org>; Fri, 22 May 2015 10:21:47 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so41902692wic.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 07:21:46 -0700 (PDT)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id s5si6121646wix.78.2015.05.22.07.21.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 07:21:45 -0700 (PDT)
Received: by wgfl8 with SMTP id l8so19370860wgf.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 07:21:44 -0700 (PDT)
Date: Fri, 22 May 2015 16:21:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Message-ID: <20150522142143.GF5109@dhcp22.suse.cz>
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
 <20150521170909.GA12800@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150521170909.GA12800@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 21-05-15 13:09:09, Johannes Weiner wrote:
> On Thu, May 21, 2015 at 03:27:22PM +0200, Michal Hocko wrote:
> > hugetlb pages uses add_to_page_cache to track shared mappings. This
> > is OK from the data structure point of view but it is less so from the
> > NR_FILE_PAGES accounting:
> > 	- huge pages are accounted as 4k which is clearly wrong
> > 	- this counter is used as the amount of the reclaimable page
> > 	  cache which is incorrect as well because hugetlb pages are
> > 	  special and not reclaimable
> > 	- the counter is then exported to userspace via /proc/meminfo
> > 	  (in Cached:), /proc/vmstat and /proc/zoneinfo as
> > 	  nr_file_pages which is confusing at least:
> > 	  Cached:          8883504 kB
> > 	  HugePages_Free:     8348
> > 	  ...
> > 	  Cached:          8916048 kB
> > 	  HugePages_Free:      156
> > 	  ...
> > 	  thats 8192 huge pages allocated which is ~16G accounted as 32M
> > 
> > There are usually not that many huge pages in the system for this to
> > make any visible difference e.g. by fooling __vm_enough_memory or
> > zone_pagecache_reclaimable.
> > 
> > Fix this by special casing huge pages in both __delete_from_page_cache
> > and __add_to_page_cache_locked. replace_page_cache_page is currently
> > only used by fuse and that shouldn't touch hugetlb pages AFAICS but it
> > is more robust to check for special casing there as well.
> > 
> > Hugetlb pages shouldn't get to any other paths where we do accounting:
> > 	- migration - we have a special handling via
> > 	  hugetlbfs_migrate_page
> > 	- shmem - doesn't handle hugetlb pages directly even for
> > 	  SHM_HUGETLB resp. MAP_HUGETLB
> > 	- swapcache - hugetlb is not swapable
> > 
> > This has a user visible effect but I believe it is reasonable because
> > the previously exported number is simply bogus.
> > 
> > An alternative would be to account hugetlb pages with their real size
> > and treat them similar to shmem. But this has some drawbacks.
> > 
> > First we would have to special case in kernel users of NR_FILE_PAGES and
> > considering how hugetlb is special we would have to do it everywhere. We
> > do not want Cached exported by /proc/meminfo to include it because the
> > value would be even more misleading.
> > __vm_enough_memory and zone_pagecache_reclaimable would have to do
> > the same thing because those pages are simply not reclaimable. The
> > correction is even not trivial because we would have to consider all
> > active hugetlb page sizes properly. Users of the counter outside of the
> > kernel would have to do the same.
> > So the question is why to account something that needs to be basically
> > excluded for each reasonable usage. This doesn't make much sense to me.
> > 
> > It seems that this has been broken since hugetlb was introduced but I
> > haven't checked the whole history.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

> This makes a lot of sense to me.  The only thing I worry about is the
> proliferation of PageHuge(), a function call, in relatively hot paths.

I've tried that (see the patch below) but it enlarged the code by almost
1k
   text    data     bss     dec     hex filename
 510323   74273   44440  629036   9992c mm/built-in.o.before
 511248   74273   44440  629961   99cc9 mm/built-in.o.after

I am not sure the code size increase is worth it. Maybe we can reduce
the check to only PageCompound(page) as huge pages are no in the page
cache (yet).

---
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 205026175c42..2e36251ad31b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -84,7 +84,6 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
-void free_huge_page(struct page *page);
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2923a51979e9..5b6c49e55f80 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -531,23 +531,6 @@ void put_pages_list(struct list_head *pages);
 void split_page(struct page *page, unsigned int order);
 int split_free_page(struct page *page);
 
-/*
- * Compound pages have a destructor function.  Provide a
- * prototype for that function and accessor functions.
- * These are _only_ valid on the head of a PG_compound page.
- */
-
-static inline void set_compound_page_dtor(struct page *page,
-						compound_page_dtor *dtor)
-{
-	page[1].compound_dtor = dtor;
-}
-
-static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
-{
-	return page[1].compound_dtor;
-}
-
 static inline int compound_order(struct page *page)
 {
 	if (!PageHead(page))
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8d37e26a1007..a9ecaebb5392 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -226,6 +226,23 @@ struct page_frag {
 #endif
 };
 
+/*
+ * Compound pages have a destructor function.  Provide a
+ * prototype for that function and accessor functions.
+ * These are _only_ valid on the head of a PG_compound page.
+ */
+
+static inline void set_compound_page_dtor(struct page *page,
+						compound_page_dtor *dtor)
+{
+	page[1].compound_dtor = dtor;
+}
+
+static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
+{
+	return page[1].compound_dtor;
+}
+
 typedef unsigned long __nocast vm_flags_t;
 
 /*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 91b7f9b2b774..41329fbb5890 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -547,7 +547,21 @@ static inline void ClearPageCompound(struct page *page)
 #endif /* !PAGEFLAGS_EXTENDED */
 
 #ifdef CONFIG_HUGETLB_PAGE
-int PageHuge(struct page *page);
+void free_huge_page(struct page *page);
+
+/*
+ * PageHuge() only returns true for hugetlbfs pages, but not for normal or
+ * transparent huge pages.  See the PageTransHuge() documentation for more
+ * details.
+ */
+static inline int PageHuge(struct page *page)
+{
+	if (!PageCompound(page))
+		return 0;
+
+	page = compound_head(page);
+	return get_compound_page_dtor(page) == free_huge_page;
+}
 int PageHeadHuge(struct page *page);
 bool page_huge_active(struct page *page);
 #else
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 54f129dc37f6..406913f3b234 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1041,21 +1041,6 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 }
 
 /*
- * PageHuge() only returns true for hugetlbfs pages, but not for normal or
- * transparent huge pages.  See the PageTransHuge() documentation for more
- * details.
- */
-int PageHuge(struct page *page)
-{
-	if (!PageCompound(page))
-		return 0;
-
-	page = compound_head(page);
-	return get_compound_page_dtor(page) == free_huge_page;
-}
-EXPORT_SYMBOL_GPL(PageHuge);
-
-/*
  * PageHeadHuge() only returns true for hugetlbfs head page, but not for
  * normal or transparent huge pages.
  */

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
