Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 561FA8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 10:37:13 -0500 (EST)
Received: by yxt33 with SMTP id 33so2599785yxt.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 07:37:11 -0800 (PST)
Date: Wed, 2 Mar 2011 00:35:58 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are
 disabled while isolating pages for migration
Message-ID: <20110301153558.GA2031@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 01, 2011 at 01:49:25PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 1 Mar 2011 13:11:46 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > On Tue, Mar 01, 2011 at 08:42:09AM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 28 Feb 2011 10:18:27 +0000
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > > BTW, can't we drop disable_irq() from all lru_lock related codes ?
> > > > > 
> > > > 
> > > > I don't think so - at least not right now. Some LRU operations such as LRU
> > > > pagevec draining are run from IPI which is running from an interrupt so
> > > > minimally spin_lock_irq is necessary.
> > > > 
> > > 
> > > pagevec draining is done by workqueue(schedule_on_each_cpu()). 
> > > I think only racy case is just lru rotation after writeback.
> > 
> > put_page still need irq disable.
> > 
> 
> Aha..ok. put_page() removes a page from LRU via __page_cache_release().
> Then, we may need to remove a page from LRU under irq context.
> Hmm...

But as __page_cache_release's comment said, normally vm doesn't release page in
irq context. so it would be rare.
If we can remove it, could we change all of spin_lock_irqsave with spin_lock?
If it is right, I think it's very desirable to reduce irq latency.

How about this? It's totally a quick implementation and untested. 
I just want to hear opinions of you guys if the work is valuable or not before
going ahead.

== CUT_HERE ==

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c71c487..5d17de6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1353,7 +1353,7 @@ extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern int after_bootmem;
 
 extern void setup_per_cpu_pageset(void);
-
+extern void setup_per_cpu_defer_free_pages(void);
 extern void zone_pcp_update(struct zone *zone);
 
 /* nommu.c */
diff --git a/init/main.c b/init/main.c
index 3627bb3..9c35fad 100644
--- a/init/main.c
+++ b/init/main.c
@@ -583,6 +583,7 @@ asmlinkage void __init start_kernel(void)
 	kmemleak_init();
 	debug_objects_mem_init();
 	setup_per_cpu_pageset();
+	setup_per_cpu_defer_free_pages();
 	numa_policy_init();
 	if (late_time_init)
 		late_time_init();
diff --git a/mm/swap.c b/mm/swap.c
index 1b9e4eb..62a9f3b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -37,10 +37,23 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
+/*
+ * This structure is to free pages which are deallocated
+ * by interrupt context for reducing irq disable time.
+ */
+#define DEFER_FREE_PAGES_THRESH_HOLD	32
+struct defer_free_pages_pcp {
+	struct page *next;
+	unsigned long count;
+	struct work_struct work;
+};
+
+static DEFINE_PER_CPU(struct defer_free_pages_pcp, defer_free_pages);
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
+static void __put_single_page(struct page *page);
 /*
  * This path almost never happens for VM activity - pages are normally
  * freed via pagevecs.  But it gets used by networking.
@@ -59,10 +72,76 @@ static void __page_cache_release(struct page *page)
 	}
 }
 
+void init_defer_free_pages(struct defer_free_pages_pcp *free_pages)
+{
+	free_pages->count = 0;
+	free_pages->next = NULL;
+}
+
+static void drain_cpu_defer_free_pages(int cpu)
+{
+	struct page *page;
+	struct defer_free_pages_pcp *free_pages = &per_cpu(defer_free_pages, cpu);
+	local_irq_disable();
+	while((page = free_pages->next)) {
+		free_pages->next = (struct page*)page_private(page);
+		__put_single_page(page);
+		free_pages->count--;
+	}
+	local_irq_enable();
+}
+
+static void defer_free_pages_drain(struct work_struct *dummy)
+{
+	drain_cpu_defer_free_pages(get_cpu());
+	put_cpu();
+}
+
+void __init setup_per_cpu_defer_free_pages(void)
+{
+	int cpu;
+	struct defer_free_pages_pcp *free_pages;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		free_pages = &per_cpu(defer_free_pages, cpu);
+		INIT_WORK(&free_pages->work, defer_free_pages_drain);
+		init_defer_free_pages(free_pages);
+	}
+	put_online_cpus();
+}
+
+static void defer_free(struct page *page, int cpu)
+{
+	struct defer_free_pages_pcp *free_pages = &per_cpu(defer_free_pages, cpu);
+
+	set_page_private(page, (unsigned long)free_pages->next);
+	free_pages->next = page;
+	free_pages->count++;
+
+	if (free_pages->count >= DEFER_FREE_PAGES_THRESH_HOLD) {
+		schedule_work_on(cpu, &free_pages->work);
+		flush_work(&free_pages->work);
+	}
+}
+
+static void __page_cache_release_defer(struct page *page)
+{
+	static int i = 0;
+	defer_free(page, get_cpu());
+	put_cpu();
+}
+
 static void __put_single_page(struct page *page)
 {
-	__page_cache_release(page);
-	free_hot_cold_page(page, 0);
+	if (in_irq())
+		__page_cache_release_defer(page);
+	else {
+		__page_cache_release(page);
+		free_hot_cold_page(page, 0);
+	}
 }
 
 static void __put_compound_page(struct page *page)


> 
> Thanks,
> -Kame
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
