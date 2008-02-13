Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1DHSpWL028522
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 12:28:51 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1DHSgWq120728
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:28:45 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1DHSgqZ026230
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:28:42 -0700
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080213120746.FB76.Y-GOTO@jp.fujitsu.com>
References: <1202853415.25604.59.camel@dyn9047017100.beaverton.ibm.com>
	 <1202853976.11188.86.camel@nimitz.home.sr71.net>
	 <20080213120746.FB76.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 13 Feb 2008 09:31:41 -0800
Message-Id: <1202923901.25604.100.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-13 at 14:09 +0900, Yasunori Goto wrote:
> Thanks Badari-san.
> 
> I understand what was occured. :-)
> 
> > On Tue, 2008-02-12 at 13:56 -0800, Badari Pulavarty wrote:
> > > > > +   /*
> > > > > +    * Its ugly, but this is the best I can do - HELP !!
> > > > > +    * We don't know where the allocations for section memmap and usemap
> > > > > +    * came from. If they are allocated at the boot time, they would come
> > > > > +    * from bootmem. If they are added through hot-memory-add they could be
> > > > > +    * from sla or vmalloc. If they are allocated as part of hot-mem-add
> > > > > +    * free them up properly. If they are allocated at boot, no easy way
> > > > > +    * to correctly free them :(
> > > > > +    */
> > > > > +   if (usemap) {
> > > > > +           if (PageSlab(virt_to_page(usemap))) {
> > > > > +                   kfree(usemap);
> > > > > +                   if (memmap)
> > > > > +                           __kfree_section_memmap(memmap, nr_pages);
> > > > > +           }
> > > > > +   }
> > > > > +}
> > > > 
> > > > Do what we did with the memmap and store some of its origination
> > > > information in the low bits.
> > > 
> > > Hmm. my understand of memmap is limited. Can you help me out here ?
> > 
> > Never mind.  That was a bad suggestion.  I do think it would be a good
> > idea to mark the 'struct page' of ever page we use as bootmem in some
> > way.  Perhaps page->private? 
> 
> I agree. page->private is not used by bootmem allocator.
> 
> I would like to mark not only memmap but also pgdat (and so on)
> for next step. It will be necessary for removing whole node. :-)
> 
> 
> >  Otherwise, you can simply try all of the
> > possibilities and consider the remainder bootmem.  Did you ever find out
> > if we properly initialize the bootmem 'struct page's?
> > 
> > Please have mercy and put this in a helper, first of all.
> > 
> > static void free_usemap(unsigned long *usemap)
> > {
> > 	if (!usemap_
> > 		return;
> > 
> > 	if (PageSlab(virt_to_page(usemap))) {
> > 		kfree(usemap)
> > 	} else if (is_vmalloc_addr(usemap)) {
> > 		vfree(usemap);
> > 	} else {
> > 		int nid = page_to_nid(virt_to_page(usemap));
> > 		bootmem_fun_here(NODE_DATA(nid), usemap);
> > 	}
> > }
> > 
> > right?
> 
> It may work. But, to be honest, I feel there are TOO MANY allocation/free
> way for memmap (usemap and so on). If possible, I would like to
> unify some of them. I would like to try it.

Thank you for the offer. Here is the latest patch, feel free to
rip it out.

Thanks,
Badari

Generic helper function to remove section mappings and sysfs entries
for the section of the memory we are removing.  offline_pages() correctly 
adjusted zone and marked the pages reserved.

Issue: Need help on freeing up allocation made from bootmem. 

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

---
 include/linux/memory_hotplug.h |    4 +++
 mm/memory_hotplug.c            |   34 +++++++++++++++++++++++++++++++
 mm/sparse.c                    |   44 ++++++++++++++++++++++++++++++++++++++---
 3 files changed, 79 insertions(+), 3 deletions(-)

Index: linux-2.6.24/mm/memory_hotplug.c
===================================================================
--- linux-2.6.24.orig/mm/memory_hotplug.c	2008-02-12 15:07:09.000000000 -0800
+++ linux-2.6.24/mm/memory_hotplug.c	2008-02-12 15:08:50.000000000 -0800
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
+		__remove_section(zone, __pfn_to_section(pfn));
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
--- linux-2.6.24.orig/mm/sparse.c	2008-02-12 15:07:09.000000000 -0800
+++ linux-2.6.24/mm/sparse.c	2008-02-12 17:10:16.000000000 -0800
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
 
@@ -363,6 +364,26 @@ static void __kfree_section_memmap(struc
 }
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
+static void free_section_usemap(struct page *memmap, unsigned long *usemap)
+{
+	if (!usemap)
+		return;
+
+	/*
+	 * Check to see if allocation came from hot-plug-add
+	 */
+	if (PageSlab(virt_to_page(usemap))) {
+		kfree(usemap);
+		if (memmap)
+			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
+		return;
+	}
+
+	/*
+	 * Allocations came from bootmem - how do I free up ?
+	 */
+}
+
 /*
  * returns the number of sections whose mem_maps were properly
  * set.  If this is <=0, then that means that the passed-in
@@ -415,4 +436,21 @@ out:
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
+	free_section_usemap(memmap, usemap);
+}
 #endif
Index: linux-2.6.24/include/linux/memory_hotplug.h
===================================================================
--- linux-2.6.24.orig/include/linux/memory_hotplug.h	2008-02-12 15:07:09.000000000 -0800
+++ linux-2.6.24/include/linux/memory_hotplug.h	2008-02-12 15:08:50.000000000 -0800
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
