Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F95E6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 21:24:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o811Od4P016154
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Sep 2010 10:24:39 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3054A45DE50
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:24:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C95045DE4D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:24:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3325E38003
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:24:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 912AEE38001
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:24:38 +0900 (JST)
Date: Wed, 1 Sep 2010 10:19:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-Id: <20100901101935.c2fedfe4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100831143649.GA31730@localhost>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
	<20100822004232.GA11007@localhost>
	<20100823092246.GA25772@tiehlicka.suse.cz>
	<20100831141942.GA30353@localhost>
	<20100831143649.GA31730@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Aug 2010 22:36:49 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Tue, Aug 31, 2010 at 10:19:42PM +0800, Wu Fengguang wrote:
> > On Mon, Aug 23, 2010 at 05:22:46PM +0800, Michal Hocko wrote:
> > > On Sun 22-08-10 08:42:32, Wu Fengguang wrote:
> > > > Hi Michal,
> > > 
> > > Hi,
> > > 
> > > > 
> > > > It helps to explain in changelog/code
> > > > 
> > > > - in what situation a ZONE_MOVABLE will contain !MIGRATE_MOVABLE
> > > >   pages? 
> > > 
> > > page can be MIGRATE_RESERVE IIUC.
> > 
> > Yup, it may also be set to MIGRATE_ISOLATE by soft_offline_page().
> 
> Ah a non-movable page allocation could fall back into the movable
> zone. See __rmqueue_fallback() and the fallbacks[][] array. So the
> 
>         if (type != MIGRATE_MOVABLE && !pageblock_free(page))
> 
> check in is_mem_section_removable() is correct. It is
> set_migratetype_isolate() that should be fixed to use the same check.
> 

Here is a patch for set_migratetype_isolate(). This is not a _fix_ but an
improvement.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At memory hotplug, we set pageblock's movable-type as ISOLATE. At failure,
we make it back to be MOVABLE. So,
	- pageblock's type shoule be movable before isolation.
	- pageblock's contents should be really movable before isolation.

Add document about it and add pageblock_free() call for fast-path.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mmzone.h |    4 ++++
 mm/memory_hotplug.c    |    2 +-
 mm/page_alloc.c        |   17 +++++++++++++----
 3 files changed, 18 insertions(+), 5 deletions(-)

Index: mmotm-0827/mm/page_alloc.c
===================================================================
--- mmotm-0827.orig/mm/page_alloc.c
+++ mmotm-0827/mm/page_alloc.c
@@ -5282,19 +5282,28 @@ int set_migratetype_isolate(struct page 
 	unsigned long immobile = 0;
 	struct memory_isolate_notify arg;
 	int notifier_ret;
-	int ret = -EBUSY;
+	int ret = 0;
 	int zone_idx;
 
 	zone = page_zone(page);
 	zone_idx = zone_idx(zone);
 
 	spin_lock_irqsave(&zone->lock, flags);
+	/*
+	 * At failure of hotplug, we turns this block to be MOVABLE if
+	 * isolation has been successfully done. So, if page-block is movable
+	 * or freed, we can try this without check contents..
+	 */
 	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
-	    zone_idx == ZONE_MOVABLE) {
-		ret = 0;
+	    pageblock_free(page) ||
+	    zone_idx == ZONE_MOVABLE)
 		goto out;
-	}
 
+	ret = -EBUSY;
+	/*
+	 * check contents, because we move this pageblocks type to be MOVABLE
+	 * at failure, the contents should be movable.
+	 */
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
 	arg.nr_pages = pageblock_nr_pages;
Index: mmotm-0827/include/linux/mmzone.h
===================================================================
--- mmotm-0827.orig/include/linux/mmzone.h
+++ mmotm-0827/include/linux/mmzone.h
@@ -54,6 +54,10 @@ static inline int get_pageblock_migratet
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+extern int pageblock_free(struct page *page);
+#endif
+
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
Index: mmotm-0827/mm/memory_hotplug.c
===================================================================
--- mmotm-0827.orig/mm/memory_hotplug.c
+++ mmotm-0827/mm/memory_hotplug.c
@@ -576,7 +576,7 @@ EXPORT_SYMBOL_GPL(add_memory);
  * Due to buddy contraints, a free page at least the size of a pageblock will
  * be located at the start of the pageblock
  */
-static inline int pageblock_free(struct page *page)
+int pageblock_free(struct page *page)
 {
 	return PageBuddy(page) && page_order(page) >= pageblock_order;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
