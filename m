Date: Fri, 8 Jun 2007 14:40:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: memory unplug v4 intro [3/6] walk memory resources.
Message-Id: <20070608144057.64dfe83f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

A clean up patch for "scanning memory resource [start, end)" operation.

Now, find_next_system_ram() function is used in memory hotplug, but this 
interface is not easy to use and codes are complicated.

This patch adds walk_memory_resouce(start,len,arg,func) function.
The function 'func' is called per valid memory resouce range in [start,pfn).

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/ioport.h         |    3 --
 include/linux/memory_hotplug.h |    9 ++++++++
 kernel/resource.c              |   26 ++++++++++++++++++++++-
 mm/memory_hotplug.c            |   45 +++++++++++++++++------------------------
 4 files changed, 53 insertions(+), 30 deletions(-)

Index: devel-2.6.22-rc4-mm2/kernel/resource.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/kernel/resource.c
+++ devel-2.6.22-rc4-mm2/kernel/resource.c
@@ -244,7 +244,7 @@ EXPORT_SYMBOL(release_resource);
  * the caller must specify res->start, res->end, res->flags.
  * If found, returns 0, res is overwritten, if not found, returns -1.
  */
-int find_next_system_ram(struct resource *res)
+static int find_next_system_ram(struct resource *res)
 {
 	resource_size_t start, end;
 	struct resource *p;
@@ -277,6 +277,30 @@ int find_next_system_ram(struct resource
 		res->end = p->end;
 	return 0;
 }
+
+int walk_memory_resource(unsigned long start_pfn, unsigned long nr_pages,
+			 void *arg, walk_memory_callback_t func)
+{
+	struct resource res;
+	unsigned long pfn, len;
+	u64 orig_end;
+	int ret;
+	res.start = (u64) start_pfn << PAGE_SHIFT;
+	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
+	res.flags = IORESOURCE_MEM;
+	orig_end = res.end;
+	while ((res.start < res.end) && (find_next_system_ram(&res) >= 0)) {
+		pfn = (unsigned long)(res.start >> PAGE_SHIFT);
+		len = (unsigned long)(res.end + 1 - res.start) >> PAGE_SHIFT;
+		ret = (*func)(pfn, len, arg);
+		if (ret)
+			break;
+		res.start = res.end + 1;
+		res.end = orig_end;
+	}
+	return ret;
+}
+
 #endif
 
 /*
Index: devel-2.6.22-rc4-mm2/include/linux/ioport.h
===================================================================
--- devel-2.6.22-rc4-mm2.orig/include/linux/ioport.h
+++ devel-2.6.22-rc4-mm2/include/linux/ioport.h
@@ -110,9 +110,6 @@ extern int allocate_resource(struct reso
 int adjust_resource(struct resource *res, resource_size_t start,
 		    resource_size_t size);
 
-/* get registered SYSTEM_RAM resources in specified area */
-extern int find_next_system_ram(struct resource *res);
-
 /* Convenience shorthand with allocation */
 #define request_region(start,n,name)	__request_region(&ioport_resource, (start), (n), (name))
 #define request_mem_region(start,n,name) __request_region(&iomem_resource, (start), (n), (name))
Index: devel-2.6.22-rc4-mm2/include/linux/memory_hotplug.h
===================================================================
--- devel-2.6.22-rc4-mm2.orig/include/linux/memory_hotplug.h
+++ devel-2.6.22-rc4-mm2/include/linux/memory_hotplug.h
@@ -64,6 +64,15 @@ extern int online_pages(unsigned long, u
 extern int __add_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 
+/*
+ * Walk thorugh all memory which is registered as resource.
+ * arg is (start_pfn, nr_pages, private_arg_pointer)
+ */
+typedef int (*walk_memory_callback_t)(unsigned long, unsigned long, void *);
+extern int walk_memory_resource(unsigned long start_pfn,
+			unsigned long nr_pages,
+		    	void *arg, walk_memory_callback_t func);
+
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
 #else
Index: devel-2.6.22-rc4-mm2/mm/memory_hotplug.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/memory_hotplug.c
+++ devel-2.6.22-rc4-mm2/mm/memory_hotplug.c
@@ -161,14 +161,27 @@ static void grow_pgdat_span(struct pglis
 					pgdat->node_start_pfn;
 }
 
-int online_pages(unsigned long pfn, unsigned long nr_pages)
+static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
+			void *arg)
 {
 	unsigned long i;
+	unsigned long onlined_pages = *(unsigned long *)arg;
+	struct page *page;
+	if (PageReserved(pfn_to_page(start_pfn)))
+		for (i = 0; i < nr_pages; i++) {
+			page = pfn_to_page(start_pfn + i);
+			online_page(page);
+			onlined_pages++;
+		}
+	*(unsigned long *)arg = onlined_pages;
+	return 0;
+}
+
+
+int online_pages(unsigned long pfn, unsigned long nr_pages)
+{
 	unsigned long flags;
 	unsigned long onlined_pages = 0;
-	struct resource res;
-	u64 section_end;
-	unsigned long start_pfn;
 	struct zone *zone;
 	int need_zonelists_rebuild = 0;
 
@@ -191,28 +204,8 @@ int online_pages(unsigned long pfn, unsi
 	if (!populated_zone(zone))
 		need_zonelists_rebuild = 1;
 
-	res.start = (u64)pfn << PAGE_SHIFT;
-	res.end = res.start + ((u64)nr_pages << PAGE_SHIFT) - 1;
-	res.flags = IORESOURCE_MEM; /* we just need system ram */
-	section_end = res.end;
-
-	while ((res.start < res.end) && (find_next_system_ram(&res) >= 0)) {
-		start_pfn = (unsigned long)(res.start >> PAGE_SHIFT);
-		nr_pages = (unsigned long)
-                           ((res.end + 1 - res.start) >> PAGE_SHIFT);
-
-		if (PageReserved(pfn_to_page(start_pfn))) {
-			/* this region's page is not onlined now */
-			for (i = 0; i < nr_pages; i++) {
-				struct page *page = pfn_to_page(start_pfn + i);
-				online_page(page);
-				onlined_pages++;
-			}
-		}
-
-		res.start = res.end + 1;
-		res.end = section_end;
-	}
+	walk_memory_resource(pfn, nr_pages, &onlined_pages,
+		online_pages_range);
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
