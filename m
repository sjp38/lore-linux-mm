Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1CN0lVk027565
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 18:00:47 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1CN0cI6117362
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 16:00:41 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1CN0b0u001044
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 16:00:37 -0700
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1202854520.11188.90.camel@nimitz.home.sr71.net>
References: <20080211114818.74c9dcc7.akpm@linux-foundation.org>
	 <1202765553.25604.12.camel@dyn9047017100.beaverton.ibm.com>
	 <20080212154309.F9DA.Y-GOTO@jp.fujitsu.com>
	 <1202836953.25604.42.camel@dyn9047017100.beaverton.ibm.com>
	 <1202849972.11188.71.camel@nimitz.home.sr71.net>
	 <1202853415.25604.59.camel@dyn9047017100.beaverton.ibm.com>
	 <1202853434.11188.76.camel@nimitz.home.sr71.net>
	 <1202854031.25604.62.camel@dyn9047017100.beaverton.ibm.com>
	 <1202854520.11188.90.camel@nimitz.home.sr71.net>
Content-Type: text/plain
Date: Tue, 12 Feb 2008 15:03:35 -0800
Message-Id: <1202857416.25604.71.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-12 at 14:15 -0800, Dave Hansen wrote:
> On Tue, 2008-02-12 at 14:07 -0800, Badari Pulavarty wrote:
> > On Tue, 2008-02-12 at 13:57 -0800, Dave Hansen wrote:
> > > On Tue, 2008-02-12 at 13:56 -0800, Badari Pulavarty wrote:
> > > > 
> > > > +static void __remove_section(struct zone *zone, unsigned long
> > > > section_nr)
> > > > +{
> > > > +       if (!valid_section_nr(section_nr))
> > > > +               return;
> > > > +
> > > > +       unregister_memory_section(__nr_to_section(section_nr));
> > > > +       sparse_remove_one_section(zone, section_nr);
> > > > +}
> > > 
> > > I do think passing in a mem_section* here is highly superior.  It makes
> > > it impossible to pass a pfn in and not get a warning.
> > > 
> > 
> > Only problem is, I need to hold pgdat_resize_lock() if pass *ms. 
> > If I don't hold the resize_lock, I have to re-evaluate.
> 
> What's wrong with holding the resize lock?  What races, precisely, are
> you trying to avoid?
> 
> > And also,
> > I need to pass section_nr for decoding the mem_map anyway :(
> 
> See sparse.c::__section_nr().  It takes a mem_section* and returns a
> section_nr.

Here is the version with your suggestion. Do you like this better ?

Thanks,
Badari

Generic helper function to remove section mappings and sysfs entries
for the section of the memory we are removing.  offline_pages() correctly 
adjusted zone and marked the pages reserved.

Issue: If mem_map, usemap allocation could come from different places -
kmalloc, vmalloc, alloc_pages or bootmem. There is no easy way
to find and free up properly. Especially for bootmem, we need to
know which node the allocation came from.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

---
 include/linux/memory_hotplug.h |    4 ++++
 mm/memory_hotplug.c            |   34 ++++++++++++++++++++++++++++++++++
 mm/sparse.c                    |   39 ++++++++++++++++++++++++++++++++++++---
 3 files changed, 74 insertions(+), 3 deletions(-)

Index: linux-2.6.24/mm/memory_hotplug.c
===================================================================
--- linux-2.6.24.orig/mm/memory_hotplug.c	2008-02-07 17:16:52.000000000 -0800
+++ linux-2.6.24/mm/memory_hotplug.c	2008-02-12 14:49:07.000000000 -0800
@@ -102,6 +102,15 @@ static int __add_section(struct zone *zo
 	return register_new_memory(__pfn_to_section(phys_start_pfn));
 }
 
+static void __remove_section(struct zone *zone, struct mem_section *ms)
+{
+	if (!valid_section(ms))
+		return;
+
+	unregister_memory_section(ms);
+	sparse_remove_one_section(zone, ms);
+}
+
 /*
  * Reasonably generic function for adding memory.  It is
  * expected that archs that support memory hotplug will
@@ -135,6 +144,31 @@ int __add_pages(struct zone *zone, unsig
 }
 EXPORT_SYMBOL_GPL(__add_pages);
 
+void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
+		 unsigned long nr_pages)
+{
+	unsigned long i;
+	int sections_to_remove;
+	unsigned long flags;
+	struct pglist_data *pgdat = zone->zone_pgdat;
+
+	/*
+	 * We can only remove entire sections
+	 */
+	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
+	BUG_ON(nr_pages % PAGES_PER_SECTION);
+
+	sections_to_remove = nr_pages / PAGES_PER_SECTION;
+
+	for (i = 0; i < sections_to_remove; i++) {
+		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
+		pgdat_resize_lock(pgdat, &flags);
+		__remove_section(zone, pfn_to_section(pfn));
+		pgdat_resize_unlock(pgdat, &flags);
+	}
+}
+EXPORT_SYMBOL_GPL(__remove_pages);
+
 static void grow_zone_span(struct zone *zone,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
Index: linux-2.6.24/mm/sparse.c
===================================================================
--- linux-2.6.24.orig/mm/sparse.c	2008-02-07 17:16:52.000000000 -0800
+++ linux-2.6.24/mm/sparse.c	2008-02-12 14:51:07.000000000 -0800
@@ -198,12 +198,13 @@ static unsigned long sparse_encode_mem_m
 }
 
 /*
- * We need this if we ever free the mem_maps.  While not implemented yet,
- * this function is included for parity with its sibling.
+ * Decode mem_map from the coded memmap
  */
-static __attribute((unused))
+static
 struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pnum)
 {
+	/* mask off the extra low bits of information */
+	coded_mem_map &= SECTION_MAP_MASK;
 	return ((struct page *)coded_mem_map) + section_nr_to_pfn(pnum);
 }
 
@@ -415,4 +416,36 @@ out:
 	}
 	return ret;
 }
+
+void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
+{
+	struct page *memmap = NULL;
+	unsigned long *usemap = NULL;
+	unsigned long flags;
+
+	if (ms->section_mem_map) {
+		usemap = ms->pageblock_flags;
+		memmap = sparse_decode_mem_map(ms->section_mem_map,
+						__section_nr(ms));
+		ms->section_mem_map = 0;
+		ms->pageblock_flags = NULL;
+	}
+
+	/*
+	 * Its ugly, but this is the best I can do - HELP !!
+	 * We don't know where the allocations for section memmap and usemap
+	 * came from. If they are allocated at the boot time, they would come
+	 * from bootmem. If they are added through hot-memory-add they could be
+	 * from slab, vmalloc. If they are allocated as part of hot-mem-add
+	 * free them up properly. If they are allocated at boot, no easy way
+	 * to correctly free them :(
+	 */
+	if (usemap) {
+		if (PageSlab(virt_to_page(usemap))) {
+			kfree(usemap);
+			if (memmap)
+				__kfree_section_memmap(memmap, PAGES_PER_SECTION);
+		}
+	}
+}
 #endif
Index: linux-2.6.24/include/linux/memory_hotplug.h
===================================================================
--- linux-2.6.24.orig/include/linux/memory_hotplug.h	2008-02-07 17:16:52.000000000 -0800
+++ linux-2.6.24/include/linux/memory_hotplug.h	2008-02-12 14:54:40.000000000 -0800
@@ -8,6 +8,7 @@
 struct page;
 struct zone;
 struct pglist_data;
+struct mem_section;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
@@ -64,6 +65,8 @@ extern int offline_pages(unsigned long, 
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
+extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
+	unsigned long nr_pages);
 
 /*
  * Walk thorugh all memory which is registered as resource.
@@ -188,5 +191,6 @@ extern int arch_add_memory(int nid, u64 
 extern int remove_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
+extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
 
 #endif /* __LINUX_MEMORY_HOTPLUG_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
