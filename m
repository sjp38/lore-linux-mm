Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 161CA6B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:35:34 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u1-v6so3097324wrs.18
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 00:35:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r24-v6sor1147806wmh.0.2018.07.19.00.35.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 00:35:32 -0700 (PDT)
Date: Thu, 19 Jul 2018 09:35:31 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 3/3] mm/page_alloc: Split context in free_area_init_node
Message-ID: <20180719073531.GA8750@techadventures.net>
References: <20180718124722.9872-1-osalvador@techadventures.net>
 <20180718124722.9872-4-osalvador@techadventures.net>
 <CAGM2reY8ODmr=u4bsCrdEX3f-c6NkSuKuEcXowRy=SkuMppjiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reY8ODmr=u4bsCrdEX3f-c6NkSuKuEcXowRy=SkuMppjiw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, osalvador@suse.de

On Wed, Jul 18, 2018 at 10:34:19AM -0400, Pavel Tatashin wrote:
> On Wed, Jul 18, 2018 at 8:47 AM <osalvador@techadventures.net> wrote:
> >
> > From: Oscar Salvador <osalvador@suse.de>
> >
> > If free_area_init_node gets called from memhotplug code,
> > we do not need to call calculate_node_totalpages(),
> > as the node has no pages.
> 
> I am not positive this is safe. Some pgdat fields in
> calculate_node_totalpages() are set. Even if those fields are always
> set to zeros, pgdat may be reused (i.e. node went offline and later
> came back online), so we might still need to set those fields to
> zeroes.
> 

You are right, I do not know why, but I thought that we were zeroing pgdat struct
before getting in the function.

I will leave that part out.
Since we only should care about deferred pfns during the boot, maybe we can change 
it to something like:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 70fe4c80643f..89fc8f4240ca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6381,6 +6381,21 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 static void __ref alloc_node_mem_map(struct pglist_data *pgdat) { }
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+static void pgdat_set_deferred_range(pg_data_t *pgdat)
+{
+	/*
+	 * We start only with one section of pages, more pages are added as
+	 * needed until the rest of deferred pages are initialized.
+	 */
+	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
+						pgdat->node_spanned_pages);
+	pgdat->first_deferred_pfn = ULONG_MAX;
+}
+#else
+static void pgdat_set_deferred_range(pg_data_t *pgdat) {}
+#endif
+
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
@@ -6402,20 +6417,14 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 #else
 	start_pfn = node_start_pfn;
 #endif
-	calculate_node_totalpages(pgdat, start_pfn, end_pfn,
-				  zones_size, zholes_size);
 
+	calculate_node_totalpages(pgdat, start_pfn, end_pfn,
+					zones_size, zholes_size);
 	alloc_node_mem_map(pgdat);
 
-#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-	/*
-	 * We start only with one section of pages, more pages are added as
-	 * needed until the rest of deferred pages are initialized.
-	 */
-	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
-					 pgdat->node_spanned_pages);
-	pgdat->first_deferred_pfn = ULONG_MAX;
-#endif
+	if (system_state == SYSTEM_BOOTING)
+		pgdat_set_deferred_range(pgdat);
+
 	free_area_init_core(pgdat);
 }

Thanks
-- 
Oscar Salvador
SUSE L3
