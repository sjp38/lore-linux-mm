Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1CHJeMW012562
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 12:19:40 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1CHJbvQ2351286
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 12:19:38 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1CHJbY1016818
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 10:19:37 -0700
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080212154309.F9DA.Y-GOTO@jp.fujitsu.com>
References: <20080211114818.74c9dcc7.akpm@linux-foundation.org>
	 <1202765553.25604.12.camel@dyn9047017100.beaverton.ibm.com>
	 <20080212154309.F9DA.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 12 Feb 2008 09:22:32 -0800
Message-Id: <1202836953.25604.42.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-12 at 17:06 +0900, Yasunori Goto wrote:
> > On Mon, 2008-02-11 at 11:48 -0800, Andrew Morton wrote:
> > > On Mon, 11 Feb 2008 09:23:18 -0800
> > > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > 
> > > > Hi Andrew,
> > > > 
> > > > While testing hotplug memory remove against -mm, I noticed
> > > > that unregister_memory() is not cleaning up /sysfs entries
> > > > correctly. It also de-references structures after destroying
> > > > them (luckily in the code which never gets used). So, I cleaned
> > > > up the code and fixed the extra reference issue.
> > > > 
> > > > Could you please include it in -mm ?
> > > > 
> > > > Thanks,
> > > > Badari
> > > > 
> > > > register_memory()/unregister_memory() never gets called with
> > > > "root". unregister_memory() is accessing kobject_name of
> > > > the object just freed up. Since no one uses the code,
> > > > lets take the code out. And also, make register_memory() static.  
> > > > 
> > > > Another bug fix - before calling unregister_memory()
> > > > remove_memory_block() gets a ref on kobject. unregister_memory()
> > > > need to drop that ref before calling sysdev_unregister().
> > > > 
> > > 
> > > I'd say this:
> > > 
> > > > Subject: [-mm PATCH] register_memory/unregister_memory clean ups
> > > 
> > > is rather tame.  These are more than cleanups!  These sound like
> > > machine-crashing bugs.  Do they crash machines?  How come nobody noticed
> > > it?
> > > 
> > 
> > No they don't crash machine - mainly because, they never get called
> > with "root" argument (where we have the bug). They were never tested
> > before, since we don't have memory remove work yet. All it does
> > is, it leave /sysfs directory laying around and causing next
> > memory add failure. 
> 
> Badari-san.
> 
> Which function does call unregister_memory() or unregister_memory_section()?
> I can't find its caller in current 2.6.24-mm1.
> 
> 
> ???????()
>   |
>   |nothing calls?
>   |
>   +-->unregister_memory_section()
>        |
>        |call
>        |
>        +---> remove_memory_block()
>               |
>               |call
>               |
>               +----> unregister_memory()
> 
> unregister_memory_section() is only externed in linux/memory.h.
> 
> Do you have any another patch to call it?
> I think it is necessary for physical memory removing.
> 
> If you have not posted it or it is not merged to -mm,
> I can understand why this bug remains.
> If you posted it, could you point it to me?

Yes. I am trying to complete the hotplug memory remove
support, so that I can use it for supporting it on ppc64
DLPAR environment.

Here is the patch to finish up some of the generic work
left. As you can see, I still need to finish up some work :(
Any help is appreciated :)

Thanks,
Badari

---
 include/linux/memory_hotplug.h |    4 ++++
 mm/memory_hotplug.c            |   33 +++++++++++++++++++++++++++++++++
 mm/sparse.c                    |   40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 77 insertions(+)

Index: linux-2.6.24/mm/memory_hotplug.c
===================================================================
--- linux-2.6.24.orig/mm/memory_hotplug.c	2008-02-07 17:16:52.000000000 -0800
+++ linux-2.6.24/mm/memory_hotplug.c	2008-02-07 17:17:57.000000000 -0800
@@ -81,6 +81,14 @@ static int __add_zone(struct zone *zone,
 	return 0;
 }
 
+static void __remove_zone(struct zone *zone, unsigned long phys_start_pfn)
+{
+	/*
+	 * TODO - Check to see if the zone is correctly adjusted
+	 * 	  Need to mark pages reserved ?
+	 */
+}
+
 static int __add_section(struct zone *zone, unsigned long phys_start_pfn)
 {
 	int nr_pages = PAGES_PER_SECTION;
@@ -102,6 +110,16 @@ static int __add_section(struct zone *zo
 	return register_new_memory(__pfn_to_section(phys_start_pfn));
 }
 
+static void __remove_section(struct zone *zone, unsigned long phys_start_pfn)
+{
+	if (!pfn_valid(phys_start_pfn))
+		return;
+
+	unregister_memory_section(__pfn_to_section(phys_start_pfn));
+	__remove_zone(zone, phys_start_pfn);
+	sparse_remove_one_section(zone, phys_start_pfn, PAGES_PER_SECTION);
+}
+
 /*
  * Reasonably generic function for adding memory.  It is
  * expected that archs that support memory hotplug will
@@ -135,6 +153,21 @@ int __add_pages(struct zone *zone, unsig
 }
 EXPORT_SYMBOL_GPL(__add_pages);
 
+void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
+		 unsigned long nr_pages)
+{
+	unsigned long i;
+	int start_sec, end_sec;
+
+	start_sec = pfn_to_section_nr(phys_start_pfn);
+	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
+
+	for (i = start_sec; i <= end_sec; i++)
+		__remove_section(zone, i << PFN_SECTION_SHIFT);
+
+}
+EXPORT_SYMBOL_GPL(__remove_pages);
+
 static void grow_zone_span(struct zone *zone,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
Index: linux-2.6.24/mm/sparse.c
===================================================================
--- linux-2.6.24.orig/mm/sparse.c	2008-02-07 17:16:52.000000000 -0800
+++ linux-2.6.24/mm/sparse.c	2008-02-11 14:12:28.000000000 -0800
@@ -415,4 +415,44 @@ out:
 	}
 	return ret;
 }
+
+void sparse_remove_one_section(struct zone *zone, unsigned long start_pfn,
+			   int nr_pages)
+{
+	unsigned long section_nr = pfn_to_section_nr(start_pfn);
+	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct mem_section *ms;
+	struct page *memmap = NULL;
+	unsigned long *usemap = NULL;
+	unsigned long flags;
+
+	pgdat_resize_lock(pgdat, &flags);
+	ms = __pfn_to_section(start_pfn);
+	if (ms->section_mem_map) {
+		memmap = ms->section_mem_map & SECTION_MAP_MASK;
+		usemap = ms->pageblock_flags;
+		memmap = sparse_decode_mem_map((unsigned long)memmap,
+				section_nr);
+		ms->section_mem_map = 0;
+		ms->pageblock_flags = NULL;
+	}
+	pgdat_resize_unlock(pgdat, &flags);
+
+	/*
+	 * Its ugly, but this is the best I can do - HELP !!
+	 * We don't know where the allocations for section memmap and usemap
+	 * came from. If they are allocated at the boot time, they would come
+	 * from bootmem. If they are added through hot-memory-add they could be
+	 * from sla or vmalloc. If they are allocated as part of hot-mem-add
+	 * free them up properly. If they are allocated at boot, no easy way
+	 * to correctly free them :(
+	 */
+	if (usemap) {
+		if (PageSlab(virt_to_page(usemap))) {
+			kfree(usemap);
+			if (memmap)
+				__kfree_section_memmap(memmap, nr_pages);
+		}
+	}
+}
 #endif
Index: linux-2.6.24/include/linux/memory_hotplug.h
===================================================================
--- linux-2.6.24.orig/include/linux/memory_hotplug.h	2008-02-07 17:16:52.000000000 -0800
+++ linux-2.6.24/include/linux/memory_hotplug.h	2008-02-07 17:17:57.000000000 -0800
@@ -64,6 +64,8 @@ extern int offline_pages(unsigned long, 
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
+extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
+	unsigned long nr_pages);
 
 /*
  * Walk thorugh all memory which is registered as resource.
@@ -188,5 +190,7 @@ extern int arch_add_memory(int nid, u64 
 extern int remove_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
+extern void sparse_remove_one_section(struct zone *zone,
+					unsigned long start_pfn, int nr_pages);
 
 #endif /* __LINUX_MEMORY_HOTPLUG_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
