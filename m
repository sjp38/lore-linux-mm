Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A295F6B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 06:17:56 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i16-v6so11798748wrr.9
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 03:17:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k16-v6sor5941452wru.68.2018.07.31.03.17.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 03:17:55 -0700 (PDT)
Date: Tue, 31 Jul 2018 12:17:52 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 4/4] mm/page_alloc: Introduce
 free_area_init_core_hotplug
Message-ID: <20180731101752.GA473@techadventures.net>
References: <20180730101757.28058-1-osalvador@techadventures.net>
 <20180730101757.28058-5-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730101757.28058-5-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

On Mon, Jul 30, 2018 at 12:17:57PM +0200, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
...
> Also, since free_area_init_core/free_area_init_node will now only get called during early init, let us replace
> __paginginit with __init, so their code gets freed up.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Andrew, could you please fold the following cleanup into this patch?
thanks

Pavel, since this has your Reviewed-by, are you ok with the following on top?

set_pageblock_order() is only called from free_area_init_core() and sparse_init().
sparse_init() is only called during early init, and the same applies for free_area_init_core()
from now on (with this patchset)

The same goes for calc_memmap_size().

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb11cc23b862..c1cf088607c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6142,7 +6142,7 @@ static inline void setup_usemap(struct pglist_data *pgdat, struct zone *zone,
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 
 /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
-void __paginginit set_pageblock_order(void)
+void __init set_pageblock_order(void)
 {
 	unsigned int order;
 
@@ -6170,13 +6170,13 @@ void __paginginit set_pageblock_order(void)
  * include/linux/pageblock-flags.h for the values of pageblock_order based on
  * the kernel config
  */
-void __paginginit set_pageblock_order(void)
+void __init set_pageblock_order(void)
 {
 }
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
-static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
+static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
 						   unsigned long present_pages)
 {
 	unsigned long pages = spanned_pages;
@@ -6448,7 +6448,7 @@ void __init free_area_init_node(int nid, unsigned long *zones_size,
  * may be accessed (for example page_to_pfn() on some configuration accesses
  * flags). We must explicitly zero those struct pages.
  */
-void __paginginit zero_resv_unavail(void)
+void __init zero_resv_unavail(void)
 {
 	phys_addr_t start, end;
 	unsigned long pfn;

Thanks
-- 
Oscar Salvador
SUSE L3
