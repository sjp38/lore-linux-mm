Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 32E394403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 05:15:52 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so204177681wmp.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 02:15:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y142si37193781wmd.54.2016.02.04.02.15.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 02:15:50 -0800 (PST)
Subject: Re: [PATCH] mm, hugetlb: don't require CMA for runtime gigantic pages
References: <1454521811-11409-1-git-send-email-vbabka@suse.cz>
 <20160204060221.GA14877@js1304-P5Q-DELUXE> <56B31A31.3070406@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56B324D4.6030703@suse.cz>
Date: Thu, 4 Feb 2016 11:15:48 +0100
MIME-Version: 1.0
In-Reply-To: <56B31A31.3070406@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Davidlohr Bueso <dave@stgolabs.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>

On 02/04/2016 10:30 AM, Vlastimil Babka wrote:
> On 02/04/2016 07:02 AM, Joonsoo Kim wrote:
>> On Wed, Feb 03, 2016 at 06:50:11PM +0100, Vlastimil Babka wrote:
>>> Commit 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at
>>> runtime") has added the runtime gigantic page allocation via
>>> alloc_contig_range(), making this support available only when CONFIG_CMA is
>>> enabled. Because it doesn't depend on MIGRATE_CMA pageblocks and the
>>> associated infrastructure, it is possible with few simple adjustments to
>>> require only CONFIG_MEMORY_ISOLATION instead of full CONFIG_CMA.
>>>
>>> After this patch, alloc_contig_range() and related functions are available
>>> and used for gigantic pages with just CONFIG_MEMORY_ISOLATION enabled. Note
>>> CONFIG_CMA selects CONFIG_MEMORY_ISOLATION. This allows supporting runtime
>>> gigantic pages without the CMA-specific checks in page allocator fastpaths.
>>
>> You need to set CONFIG_COMPACTION or CONFIG_CMA to use
>> isolate_migratepages_range() and others in alloc_contig_range().
> 
> Hm, right, thanks for catching this. I admit I didn't try disabling
> compaction during the tests.

Here's a v2. Not the prettiest thing, admittedly.

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Wed, 3 Feb 2016 17:45:26 +0100
Subject: [PATCH v2] mm, hugetlb: don't require CMA for runtime gigantic pages

Commit 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at
runtime") has added the runtime gigantic page allocation via
alloc_contig_range(), making this support available only when CONFIG_CMA is
enabled. Because it doesn't depend on MIGRATE_CMA pageblocks and the
associated infrastructure, it is possible with few simple adjustments to
require only CONFIG_MEMORY_ISOLATION and CONFIG_COMPACTION instead of full
CONFIG_CMA.

After this patch, alloc_contig_range() and related functions are available
and used for gigantic pages with just CONFIG_MEMORY_ISOLATION and
CONFIG_COMPACTION enabled (or CONFIG_CMA as before). Note CONFIG_CMA selects
CONFIG_MEMORY_ISOLATION. This allows supporting runtime gigantic pages without
the CMA-specific checks in page allocator fastpaths.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/gfp.h | 6 +++---
 mm/hugetlb.c        | 2 +-
 mm/page_alloc.c     | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 8942af0813e3..4cb589ae6c4b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -539,16 +539,16 @@ static inline bool pm_suspended_storage(void)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-#ifdef CONFIG_CMA
-
+#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype);
 extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
+#endif
 
+#ifdef CONFIG_CMA
 /* CMA stuff */
 extern void init_cma_reserved_pageblock(struct page *page);
-
 #endif
 
 #endif /* __LINUX_GFP_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ef6963b577fd..50700ec80009 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1002,7 +1002,7 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
 		nr_nodes--)
 
-#if defined(CONFIG_CMA) && defined(CONFIG_X86_64)
+#if defined(CONFIG_X86_64) && ((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA))
 static void destroy_compound_gigantic_page(struct page *page,
 					unsigned int order)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d666df5ef95..5fcfac52ca5a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6599,7 +6599,7 @@ bool is_pageblock_removable_nolock(struct page *page)
 	return !has_unmovable_pages(zone, page, 0, true);
 }
 
-#ifdef CONFIG_CMA
+#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
 
 static unsigned long pfn_max_align_down(unsigned long pfn)
 {
-- 
2.7.0





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
