Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E570B6B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 04:14:37 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6E8EYhe002141
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Jul 2010 17:14:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 27E3145DE4E
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 17:14:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0259A45DE51
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 17:14:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B8742E18003
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 17:14:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 665121DB805B
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 17:14:33 +0900 (JST)
Date: Wed, 14 Jul 2010 17:09:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-Id: <20100714170948.3eac9132.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <000e01cb2329$3d8c5770$b8a50650$%kim@samsung.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713093006.GB14504@cmpxchg.org>
	<20100713154335.GB2815@barrios-desktop>
	<1279038933.10995.9.camel@nimitz>
	<20100713164423.GC2815@barrios-desktop>
	<20100714092301.69e7e628.kamezawa.hiroyu@jp.fujitsu.com>
	<000e01cb2329$3d8c5770$b8a50650$%kim@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Kukjin Kim <kgene.kim@samsung.com>
Cc: 'Minchan Kim' <minchan.kim@gmail.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, linux@arm.linux.org.uk, 'Yinghai Lu' <yinghai@kernel.org>, "'H. Peter Anvin'" <hpa@zytor.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Shaohua Li' <shaohua.li@intel.com>, 'Yakui
 Zhao' <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, 'Mel Gorman' <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jul 2010 16:50:25 +0900
Kukjin Kim <kgene.kim@samsung.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > 
> > On Wed, 14 Jul 2010 01:44:23 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > > If you _really_ can't make the section size smaller, and the vast
> > > > majority of the sections are fully populated, you could hack something
> > > > in.  We could, for instance, have a global list that's mostly readonly
> > > > which tells you which sections need to be have their sizes closely
> > > > inspected.  That would work OK if, for instance, you only needed to
> > > > check a couple of memory sections in the system.  It'll start to suck
> if
> > > > you made the lists very long.
> > >
> > > Thanks for advise. As I say, I hope Russell accept 16M section.
> > >
> Hi,
> 
> Thanks for your inputs.
> > 
> > It seems what I needed was good sleep....
> > How about this if 16M section is not acceptable ?
> > 
> > == NOT TESTED AT ALL, EVEN NOT COMPILED ==
> 
> Yeah...
> 
> Couldn't build with s5pv210_defconfig when used mmotm tree,
> And couldn't apply your patch against latest mainline 35-rc5.
> 
> Could you please remake your patch against mainline 35-rc5?
> Or...please let me know how I can test on my board(smdkv210).
> 
Ahh..how brave you are.

my patch was against mmotm-07-01.
select SPARSEMEM_HAS_PIT in config.
(in menuconfig it will appear under Processor type and features.)

This is a fixed one, maybe mm/sparce.o can be compiled.
At least, arch-generic part is compiled.

(This config should be selected automatically via arm's config.
 this patch is just for test.)

Signed-off-by: KAMEZAWA hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/arm/mm/init.c     |   11 ++++++++++-
 include/linux/mmzone.h |   19 ++++++++++++++++++-
 mm/Kconfig             |    5 +++++
 mm/sparse.c            |   38 +++++++++++++++++++++++++++++++++++++-
 4 files changed, 70 insertions(+), 3 deletions(-)

Index: mmotm-2.6.35-0701/include/linux/mmzone.h
===================================================================
--- mmotm-2.6.35-0701.orig/include/linux/mmzone.h
+++ mmotm-2.6.35-0701/include/linux/mmzone.h
@@ -1047,11 +1047,28 @@ static inline struct mem_section *__pfn_
 	return __nr_to_section(pfn_to_section_nr(pfn));
 }
 
+#ifdef CONFIG_SPARSEMEM_HAS_PIT
+void mark_memmap_pit(unsigned long start, unsigned long end, bool valid);
+static inline int page_valid(struct mem_section *ms, unsigned long pfn)
+{
+	struct page *page = pfn_to_page(pfn);
+	struct page *__pg = virt_to_page(page);
+	return __pg->private == ms;
+}
+#else
+static inline int page_valid(struct mem_section *ms, unsigned long pfn)
+{
+	return 1;
+}
+#endif
+
 static inline int pfn_valid(unsigned long pfn)
 {
+	struct mem_section *ms;
 	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
 		return 0;
-	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
+	ms = __nr_to_section(pfn_to_section_nr(pfn));
+	return valid_section(ms) && page_valid(ms, pfn);
 }
 
 static inline int pfn_present(unsigned long pfn)
Index: mmotm-2.6.35-0701/mm/sparse.c
===================================================================
--- mmotm-2.6.35-0701.orig/mm/sparse.c
+++ mmotm-2.6.35-0701/mm/sparse.c
@@ -13,7 +13,6 @@
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
-
 /*
  * Permanent SPARSEMEM data:
  *
@@ -615,6 +614,43 @@ void __init sparse_init(void)
 	free_bootmem(__pa(usemap_map), size);
 }
 
+#ifdef CONFIG_SPARSEMEM_HAS_PIT
+/*
+ * Fill memmap's pg->private with a pointer to mem_section.
+ * pfn_valid() will check this later. (see include/linux/mmzone.h)
+ * The caller should call
+ * 	mark_memmap_pit(start, end, true) # for all allocated mem_map
+ * 	and, after that,
+ * 	mark_memmap_pit(start, end, false) # for all pits in mem_map.
+ * please see usage in ARM.
+ */
+void mark_memmap_pit(unsigned long start, unsigned long end, bool valid)
+{
+	struct mem_section *ms;
+	unsigned long pos, next;
+	struct page *pg;
+	void *memmap, *mapend;
+
+	for (pos = start;
+	     pos < end; pos = next) {
+		next = (pos + PAGES_PER_SECTION) & PAGE_SECTION_MASK;
+		ms = __pfn_to_section(pos);
+		if (!valid_section(ms))
+			continue;
+		for (memmap = (void*)pfn_to_page(pos),
+		     mapend = pfn_to_page(next-1); /* the last page in section*/
+		     memmap < mapend;
+		     memmap += PAGE_SIZE) {
+			pg = virt_to_page(memmap);
+			if (valid)
+				pg->private = (unsigned long)ms;
+			else
+				pg->private = 0;
+		}
+	}
+}
+#endif
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
Index: mmotm-2.6.35-0701/arch/arm/mm/init.c
===================================================================
--- mmotm-2.6.35-0701.orig/arch/arm/mm/init.c
+++ mmotm-2.6.35-0701/arch/arm/mm/init.c
@@ -234,6 +234,13 @@ static void __init arm_bootmem_free(stru
 	arch_adjust_zones(zone_size, zhole_size);
 
 	free_area_init_node(0, zone_size, min, zhole_size);
+
+#ifdef CONFIG_SPARSEMEM
+	for_each_bank(i, mi) {
+		mark_memmap_pit(bank_start_pfn(mi->bank[i]),
+				bank_end_pfn(mi->bank[i]), true);
+	}
+#endif
 }
 
 #ifndef CONFIG_SPARSEMEM
@@ -386,8 +393,10 @@ free_memmap(unsigned long start_pfn, uns
 	 * If there are free pages between these,
 	 * free the section of the memmap array.
 	 */
-	if (pg < pgend)
+	if (pg < pgend) {
+		mark_memap_pit(pg >> PAGE_SHIFT, pgend >> PAGE_SHIFT, false);
 		free_bootmem(pg, pgend - pg);
+	}
 }
 
 /*
Index: mmotm-2.6.35-0701/mm/Kconfig
===================================================================
--- mmotm-2.6.35-0701.orig/mm/Kconfig
+++ mmotm-2.6.35-0701/mm/Kconfig
@@ -128,6 +128,11 @@ config SPARSEMEM_VMEMMAP
 	 pfn_to_page and page_to_pfn operations.  This is the most
 	 efficient option when sufficient kernel resources are available.
 
+config SPAESEMEM_HAS_PIT
+	bool "allow holes in sparsemem's memmap"
+	depends on SPARSEMEM && !SPARSEMEM_VMEMMAP
+	default n
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
