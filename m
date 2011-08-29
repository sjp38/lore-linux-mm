From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 7/7] tracing/mm: add memcg field
Date: Mon, 29 Aug 2011 11:29:58 +0800
Message-ID: <20110829034932.531048150__44411.4969847307$1314590293$gmane$org@intel.com>
References: <20110829032951.677220552@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=memcg-page-id.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Dump the memcg id associated with a pagecache page.

The downside is, the page_memcg_id() is a pretty heavy weight function
that needs to lock/unlock the page..

CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/memcontrol.h |    6 ++++++
 include/trace/events/mm.h  |   16 +++++++++++-----
 kernel/trace/trace_mm.c    |   12 +++++++++---
 mm/memcontrol.c            |   18 ++++++++++++++++++
 4 files changed, 44 insertions(+), 8 deletions(-)

--- linux-mmotm.orig/include/linux/memcontrol.h	2011-08-29 10:55:48.000000000 +0800
+++ linux-mmotm/include/linux/memcontrol.h	2011-08-29 10:55:53.000000000 +0800
@@ -91,6 +91,7 @@ extern void mem_cgroup_uncharge_cache_pa
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
 
+extern unsigned short page_memcg_id(struct page *page);
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
@@ -199,6 +200,11 @@ static inline int mem_cgroup_try_charge_
 	return 0;
 }
 
+static inline unsigned short page_memcg_id(struct page *page)
+{
+	return 0;
+}
+
 static inline void mem_cgroup_commit_charge_swapin(struct page *page,
 					  struct mem_cgroup *ptr)
 {
--- linux-mmotm.orig/mm/memcontrol.c	2011-08-29 10:55:48.000000000 +0800
+++ linux-mmotm/mm/memcontrol.c	2011-08-29 10:59:28.000000000 +0800
@@ -591,6 +591,24 @@ mem_cgroup_largest_soft_limit_node(struc
 	return mz;
 }
 
+unsigned short page_memcg_id(struct page *page)
+{
+	struct mem_cgroup *memcg;
+	struct cgroup_subsys_state *css;
+	unsigned short id = 0;
+
+	lock_page(page);
+	memcg = try_get_mem_cgroup_from_page(page);
+	if (memcg) {
+		css = mem_cgroup_css(memcg);
+		id = css_id(css);
+		css_put(css);
+	}
+	unlock_page(page);
+
+	return id;
+}
+
 /*
  * Implementation Note: reading percpu statistics for memcg.
  *
--- linux-mmotm.orig/include/trace/events/mm.h	2011-08-29 10:55:52.000000000 +0800
+++ linux-mmotm/include/trace/events/mm.h	2011-08-29 10:55:53.000000000 +0800
@@ -34,6 +34,7 @@ TRACE_EVENT(dump_page_frame,
 		__field(	unsigned long,	flags		)
 		__field(	unsigned int,	count		)
 		__field(	unsigned int,	mapcount	)
+		__field(	unsigned int,	memcg		)
 		__field(	unsigned long,	private		)
 		__field(	unsigned long,	mapping		)
 		__field(	unsigned long,	index		)
@@ -46,17 +47,19 @@ TRACE_EVENT(dump_page_frame,
 		__entry->flags		= page->flags;
 		__entry->count		= atomic_read(&page->_count);
 		__entry->mapcount	= page_mapcount(page);
+		__entry->memcg		= page_memcg_id(page);
 		__entry->private	= page->private;
 		__entry->mapping	= (unsigned long)page->mapping;
 		__entry->index		= page->index;
 	),
 
 	TP_printk("pfn=%lu page=%p count=%u mapcount=%u "
-		  "private=%lx mapping=%lx index=%lx flags=%s",
+		  "memcg=%u private=%lx mapping=%lx index=%lx flags=%s",
 		  __entry->pfn,
 		  __entry->page,
 		  __entry->count,
 		  __entry->mapcount,
+		  __entry->memcg,
 		  __entry->private,
 		  __entry->mapping,
 		  __entry->index,
@@ -68,9 +71,9 @@ TRACE_EVENT(dump_page_frame,
 
 TRACE_EVENT(dump_page_cache,
 
-	TP_PROTO(struct page *page, unsigned long len),
+	TP_PROTO(struct page *page, unsigned long len, unsigned int memcg),
 
-	TP_ARGS(page, len),
+	TP_ARGS(page, len, memcg),
 
 	TP_STRUCT__entry(
 		__field(	unsigned long,	index		)
@@ -78,6 +81,7 @@ TRACE_EVENT(dump_page_cache,
 		__field(	u64,		flags		)
 		__field(	unsigned int,	count		)
 		__field(	unsigned int,	mapcount	)
+		__field(	unsigned int,	memcg		)
 	),
 
 	TP_fast_assign(
@@ -86,10 +90,11 @@ TRACE_EVENT(dump_page_cache,
 		__entry->flags		= stable_page_flags(page);
 		__entry->count		= atomic_read(&page->_count);
 		__entry->mapcount	= page_mapcount(page);
+		__entry->memcg		= memcg;
 	),
 
 	TP_printk("index=%lu len=%lu flags=%c%c%c%c%c%c%c%c%c%c%c "
-		  "count=%u mapcount=%u",
+		  "count=%u mapcount=%u memcg=%u",
 		  __entry->index,
 		  __entry->len,
 		  __entry->flags & (1ULL << KPF_MMAP)		? 'M' : '_',
@@ -104,7 +109,8 @@ TRACE_EVENT(dump_page_cache,
 		  __entry->flags & (1ULL << KPF_MAPPEDTODISK)	? 'd' : '_',
 		  __entry->flags & (1ULL << KPF_PRIVATE)	? 'P' : '_',
 		  __entry->count,
-		  __entry->mapcount)
+		  __entry->mapcount,
+		  __entry->memcg)
 );
 
 
--- linux-mmotm.orig/kernel/trace/trace_mm.c	2011-08-29 10:56:02.000000000 +0800
+++ linux-mmotm/kernel/trace/trace_mm.c	2011-08-29 11:01:04.000000000 +0800
@@ -155,6 +155,8 @@ static void dump_pagecache(struct addres
 	struct page *page;
 	unsigned long start = 0;
 	unsigned long len = 0;
+	unsigned int memcg0;
+	unsigned int memcg;
 	int i;
 
 	for (;;) {
@@ -165,23 +167,27 @@ static void dump_pagecache(struct addres
 
 		if (nr_pages == 0) {
 			if (len)
-				trace_dump_page_cache(page0, len);
+				trace_dump_page_cache(page0, len, memcg0);
 			return;
 		}
 
 		for (i = 0; i < nr_pages; i++) {
 			page = pages[i];
+			memcg = page_memcg_id(page);
 
 			if (len &&
 			    page->index == start + len &&
-			    pages_similar(page0, page))
+			    pages_similar(page0, page) &&
+			    memcg0 == memcg)
 				len++;
 			else {
 				if (len)
-					trace_dump_page_cache(page0, len);
+					trace_dump_page_cache(page0, len,
+							      memcg0);
 				page0 = page;
 				start = page->index;
 				len = 1;
+				memcg0 = memcg;
 			}
 		}
 		cond_resched();
