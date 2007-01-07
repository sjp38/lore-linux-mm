Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l078wYcA026399
	for <linux-mm@kvack.org>; Sun, 7 Jan 2007 03:58:34 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l078wX0q462744
	for <linux-mm@kvack.org>; Sun, 7 Jan 2007 01:58:34 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l078wXNJ013949
	for <linux-mm@kvack.org>; Sun, 7 Jan 2007 01:58:33 -0700
Subject: Re: [PATCH] Fix sparsemem on Cell (take 3)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1168059162.23226.1.camel@sinatra.austin.ibm.com>
References: <20061215165335.61D9F775@localhost.localdomain>
	 <200612182354.47685.arnd@arndb.de>
	 <1166483780.8648.26.camel@localhost.localdomain>
	 <200612190959.47344.arnd@arndb.de>
	 <1168045803.8945.14.camel@localhost.localdomain>
	 <1168059162.23226.1.camel@sinatra.austin.ibm.com>
Content-Type: text/plain
Date: Sun, 07 Jan 2007 00:58:27 -0800
Message-Id: <1168160307.6740.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Rose <johnrose@austin.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, External List <linuxppc-dev@ozlabs.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, kmannth@us.ibm.com, lkml <linux-kernel@vger.kernel.org>, hch@infradead.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, mkravetz@us.ibm.com, gone@us.ibm.com, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-01-05 at 22:52 -0600, John Rose wrote:
> > I dropped this on the floor over Christmas.  This has had a few smoke
> > tests on ppc64 and i386 and is ready for -mm.  Against 2.6.20-rc2-mm1.
> 
> Could this break ia64, given that it uses memmap_init_zone()?

You are right, I think it does.

Here's an updated patch to replace the earlier one.  I had to move the
enum definition over to a different header because ia64 evidently has a
different include order.

---

The following patch fixes an oops experienced on the Cell architecture
when init-time functions, early_*(), are called at runtime.  It alters
the call paths to make sure that the callers explicitly say whether the
call is being made on behalf of a hotplug even, or happening at
boot-time. 

It has been compile tested on ia64, s390, i386 and x86_64.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

---

 lxc-dave/arch/ia64/mm/init.c    |    5 +++--
 lxc-dave/arch/s390/mm/vmem.c    |    3 ++-
 lxc-dave/include/linux/mm.h     |    3 ++-
 lxc-dave/include/linux/mmzone.h |    8 ++++++--
 lxc-dave/mm/memory_hotplug.c    |    6 ++++--
 lxc-dave/mm/page_alloc.c        |   25 +++++++++++++++++--------
 6 files changed, 34 insertions(+), 16 deletions(-)

diff -puN arch/s390/mm/vmem.c~Re-_PATCH_Fix_sparsemem_on_Cell arch/s390/mm/vmem.c
--- lxc/arch/s390/mm/vmem.c~Re-_PATCH_Fix_sparsemem_on_Cell	2007-01-05 15:38:23.000000000 -0800
+++ lxc-dave/arch/s390/mm/vmem.c	2007-01-07 00:47:02.000000000 -0800
@@ -61,7 +61,8 @@ void memmap_init(unsigned long size, int
 
 		if (map_start < map_end)
 			memmap_init_zone((unsigned long)(map_end - map_start),
-					 nid, zone, page_to_pfn(map_start));
+					 nid, zone, page_to_pfn(map_start),
+					 MEMMAP_EARLY);
 	}
 }
 
diff -puN include/linux/mm.h~Re-_PATCH_Fix_sparsemem_on_Cell include/linux/mm.h
--- lxc/include/linux/mm.h~Re-_PATCH_Fix_sparsemem_on_Cell	2007-01-05 15:38:23.000000000 -0800
+++ lxc-dave/include/linux/mm.h	2007-01-06 23:57:59.000000000 -0800
@@ -979,7 +979,8 @@ extern int early_pfn_to_nid(unsigned lon
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 extern void set_dma_reserve(unsigned long new_dma_reserve);
-extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned long);
+extern void memmap_init_zone(unsigned long, int, unsigned long,
+				unsigned long, enum memmap_context);
 extern void setup_per_zone_pages_min(void);
 extern void mem_init(void);
 extern void show_mem(void);
diff -puN include/linux/mmzone.h~Re-_PATCH_Fix_sparsemem_on_Cell include/linux/mmzone.h
--- lxc/include/linux/mmzone.h~Re-_PATCH_Fix_sparsemem_on_Cell	2007-01-05 15:38:23.000000000 -0800
+++ lxc-dave/include/linux/mmzone.h	2007-01-06 23:58:15.000000000 -0800
@@ -471,9 +471,13 @@ void build_all_zonelists(void);
 void wakeup_kswapd(struct zone *zone, int order);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
-
+enum memmap_context {
+	MEMMAP_EARLY,
+	MEMMAP_HOTPLUG,
+};
 extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
-				     unsigned long size);
+				     unsigned long size,
+				     enum memmap_context context);
 
 #ifdef CONFIG_HAVE_MEMORY_PRESENT
 void memory_present(int nid, unsigned long start, unsigned long end);
diff -puN mm/memory_hotplug.c~Re-_PATCH_Fix_sparsemem_on_Cell mm/memory_hotplug.c
--- lxc/mm/memory_hotplug.c~Re-_PATCH_Fix_sparsemem_on_Cell	2007-01-05 15:38:23.000000000 -0800
+++ lxc-dave/mm/memory_hotplug.c	2007-01-05 15:38:23.000000000 -0800
@@ -67,11 +67,13 @@ static int __add_zone(struct zone *zone,
 	zone_type = zone - pgdat->node_zones;
 	if (!populated_zone(zone)) {
 		int ret = 0;
-		ret = init_currently_empty_zone(zone, phys_start_pfn, nr_pages);
+		ret = init_currently_empty_zone(zone, phys_start_pfn,
+						nr_pages, MEMMAP_HOTPLUG);
 		if (ret < 0)
 			return ret;
 	}
-	memmap_init_zone(nr_pages, nid, zone_type, phys_start_pfn);
+	memmap_init_zone(nr_pages, nid, zone_type,
+			 phys_start_pfn, MEMMAP_HOTPLUG);
 	return 0;
 }
 
diff -puN mm/page_alloc.c~Re-_PATCH_Fix_sparsemem_on_Cell mm/page_alloc.c
--- lxc/mm/page_alloc.c~Re-_PATCH_Fix_sparsemem_on_Cell	2007-01-05 15:38:23.000000000 -0800
+++ lxc-dave/mm/page_alloc.c	2007-01-07 00:35:27.000000000 -0800
@@ -2062,17 +2062,24 @@ static inline unsigned long wait_table_b
  * done. Non-atomic initialization, single-pass.
  */
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
-		unsigned long start_pfn)
+		unsigned long start_pfn, enum memmap_context context)
 {
 	struct page *page;
 	unsigned long end_pfn = start_pfn + size;
 	unsigned long pfn;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-		if (!early_pfn_valid(pfn))
-			continue;
-		if (!early_pfn_in_nid(pfn, nid))
-			continue;
+		/*
+		 * There can be holes in boot-time mem_map[]s
+		 * handed to this function.  They do not
+		 * exist on hotplugged memory.
+		 */
+		if (context == MEMMAP_EARLY) {
+			if (!early_pfn_valid(pfn))
+				continue;
+			if (!early_pfn_in_nid(pfn, nid))
+				continue;
+		}
 		page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
 		init_page_count(page);
@@ -2102,7 +2109,7 @@ void zone_init_free_lists(struct pglist_
 
 #ifndef __HAVE_ARCH_MEMMAP_INIT
 #define memmap_init(size, nid, zone, start_pfn) \
-	memmap_init_zone((size), (nid), (zone), (start_pfn))
+	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
 static int __cpuinit zone_batchsize(struct zone *zone)
@@ -2348,7 +2355,8 @@ static __meminit void zone_pcp_init(stru
 
 __meminit int init_currently_empty_zone(struct zone *zone,
 					unsigned long zone_start_pfn,
-					unsigned long size)
+					unsigned long size,
+					enum memmap_context context)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int ret;
@@ -2792,7 +2800,8 @@ static void __meminit free_area_init_cor
 		if (!size)
 			continue;
 
-		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
+		ret = init_currently_empty_zone(zone, zone_start_pfn,
+						size, MEMMAP_EARLY);
 		BUG_ON(ret);
 		zone_start_pfn += size;
 	}
diff -puN arch/ia64/mm/init.c~Re-_PATCH_Fix_sparsemem_on_Cell arch/ia64/mm/init.c
--- lxc/arch/ia64/mm/init.c~Re-_PATCH_Fix_sparsemem_on_Cell	2007-01-06 23:58:55.000000000 -0800
+++ lxc-dave/arch/ia64/mm/init.c	2007-01-07 00:08:01.000000000 -0800
@@ -541,7 +541,8 @@ virtual_memmap_init (u64 start, u64 end,
 
 	if (map_start < map_end)
 		memmap_init_zone((unsigned long)(map_end - map_start),
-				 args->nid, args->zone, page_to_pfn(map_start));
+				 args->nid, args->zone, page_to_pfn(map_start),
+				 MEMMAP_EARLY);
 	return 0;
 }
 
@@ -550,7 +551,7 @@ memmap_init (unsigned long size, int nid
 	     unsigned long start_pfn)
 {
 	if (!vmem_map)
-		memmap_init_zone(size, nid, zone, start_pfn);
+		memmap_init_zone(size, nid, zone, start_pfn, MEMMAP_EARLY);
 	else {
 		struct page *start;
 		struct memmap_init_callback_data args;
_


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
