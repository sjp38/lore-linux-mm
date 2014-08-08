Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFC56B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 02:45:47 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so6841731pab.29
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 23:45:47 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id zw9si5314864pac.145.2014.08.07.23.45.45
        for <linux-mm@kvack.org>;
        Thu, 07 Aug 2014 23:45:46 -0700 (PDT)
Date: Fri, 8 Aug 2014 15:45:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 5/8] mm/isolation: change pageblock isolation logic to
 fix freepage counting bugs
Message-ID: <20140808064544.GC6150@js1304-P5Q-DELUXE>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1407309517-3270-9-git-send-email-iamjoonsoo.kim@lge.com>
 <53E39805.4040503@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53E39805.4040503@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 07, 2014 at 05:15:17PM +0200, Vlastimil Babka wrote:
> On 08/06/2014 09:18 AM, Joonsoo Kim wrote:
> >Current pageblock isolation logic has a problem that results in incorrect
> >freepage counting. move_freepages_block() doesn't return number of
> >moved pages so freepage count could be wrong if some pages are freed
> >inbetween set_pageblock_migratetype() and move_freepages_block(). Although
> >we fix move_freepages_block() to return number of moved pages, the problem
> 
>     ^ could

Yes, but fixing that is not needed because this patch changes
isolation process and, after that, that behaviour have any problem.

> 
> >wouldn't be fixed completely because buddy allocator doesn't care if merged
> >pages are on different buddy list or not. If some page on normal buddy list
> >is merged with isolated page and moved to isolate buddy list, freepage
> >count should be subtracted, but, it didn't and can't now.
> 
> ... but it's not done now and doing that would impose unwanted
> overhead on buddy merging.

Yes, we don't want more overhead on buddy merging so this patch
introduces PageIsolated() in order to avoid merge problem.

> Also the analogous problem exists when undoing isolation?

There is no merge problem in new (un)isolation process of this patch except
for the page more than pageblock order. This case will be fixed in patch 7.

> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  include/linux/page-isolation.h |    2 +
> >  mm/internal.h                  |    3 ++
> >  mm/page_alloc.c                |   28 ++++++-----
> >  mm/page_isolation.c            |  107 ++++++++++++++++++++++++++++++++++++----
> >  4 files changed, 118 insertions(+), 22 deletions(-)
> >
> >diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> >index 3fff8e7..3dd39fe 100644
> >--- a/include/linux/page-isolation.h
> >+++ b/include/linux/page-isolation.h
> >@@ -21,6 +21,8 @@ static inline bool is_migrate_isolate(int migratetype)
> >  }
> >  #endif
> >
> >+void deactivate_isolated_page(struct zone *zone, struct page *page,
> >+				unsigned int order);
> >  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >  			 bool skip_hwpoisoned_pages);
> >  void set_pageblock_migratetype(struct page *page, int migratetype);
> >diff --git a/mm/internal.h b/mm/internal.h
> >index 81b8884..c70750a 100644
> >--- a/mm/internal.h
> >+++ b/mm/internal.h
> >@@ -110,6 +110,9 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
> >   */
> >  extern void zone_pcp_disable(struct zone *zone);
> >  extern void zone_pcp_enable(struct zone *zone);
> >+extern void __free_one_page(struct page *page, unsigned long pfn,
> >+		struct zone *zone, unsigned int order,
> >+		int migratetype);
> >  extern void __free_pages_bootmem(struct page *page, unsigned int order);
> >  extern void prep_compound_page(struct page *page, unsigned long order);
> >  #ifdef CONFIG_MEMORY_FAILURE
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 4517b1d..82da4a8 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -571,7 +571,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
> >   * -- nyc
> >   */
> >
> >-static inline void __free_one_page(struct page *page,
> >+void __free_one_page(struct page *page,
> >  		unsigned long pfn,
> >  		struct zone *zone, unsigned int order,
> >  		int migratetype)
> >@@ -738,14 +738,19 @@ static void free_one_page(struct zone *zone,
> >  				int migratetype)
> >  {
> >  	unsigned long nr_scanned;
> >+
> >+	if (unlikely(is_migrate_isolate(migratetype))) {
> >+		deactivate_isolated_page(zone, page, order);
> >+		return;
> >+	}
> >+
> 
> This would be more effectively done in the callers, which is where
> migratetype is determined - there are two:
> - free_hot_cold_page() already has this test, so just call deactivation
>   instead of free_one_page() - one test less in this path!
> - __free_pages_ok() could add the test to call deactivation, and
> since you remove another test in the hunk below, the net result is
> the same in this path.

Okay. Will do.

> >--- a/mm/page_isolation.c
> >+++ b/mm/page_isolation.c
> >@@ -9,6 +9,75 @@
> >  #include <linux/hugetlb.h>
> >  #include "internal.h"
> >
> >+#define ISOLATED_PAGE_MAPCOUNT_VALUE (-64)
> >+
> >+static inline int PageIsolated(struct page *page)
> >+{
> >+	return atomic_read(&page->_mapcount) == ISOLATED_PAGE_MAPCOUNT_VALUE;
> >+}
> >+
> >+static inline void __SetPageIsolated(struct page *page)
> >+{
> >+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> >+	atomic_set(&page->_mapcount, ISOLATED_PAGE_MAPCOUNT_VALUE);
> >+}
> >+
> >+static inline void __ClearPageIsolated(struct page *page)
> >+{
> >+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
> >+	atomic_set(&page->_mapcount, -1);
> >+}
> 
> Hmm wasn't the convention for atomic updates to be without the __ prefix?

I copy-and_paste code for PageBuddy(). :)
I guess that __ prefix here means that we should call it with holding
the zone lock. atomic operation is used to satisfy type definition of
page->_mapcount.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
