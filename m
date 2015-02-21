Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id D85506B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 18:53:15 -0500 (EST)
Received: by wevk48 with SMTP id k48so11816918wev.0
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 15:53:14 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id sd8si54054316wjb.100.2015.02.21.15.53.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Feb 2015 15:53:12 -0800 (PST)
Date: Sat, 21 Feb 2015 18:52:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150221235227.GA25079@phnom.home.cmpxchg.org>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150219225217.GY12722@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Fri, Feb 20, 2015 at 09:52:17AM +1100, Dave Chinner wrote:
> I will actively work around aanything that causes filesystem memory
> pressure to increase the chance of oom killer invocations. The OOM
> killer is not a solution - it is, by definition, a loose cannon and
> so we should be reducing dependencies on it.

Once we have a better-working alternative, sure.

> I really don't care about the OOM Killer corner cases - it's
> completely the wrong way line of development to be spending time on
> and you aren't going to convince me otherwise. The OOM killer a
> crutch used to justify having a memory allocation subsystem that
> can't provide forward progress guarantee mechanisms to callers that
> need it.

We can provide this.  Are all these callers able to preallocate?

---

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 51bd1e72a917..af81b8a67651 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -380,6 +380,10 @@ extern void free_kmem_pages(unsigned long addr, unsigned int order);
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
 
+void register_private_page(struct page *page, unsigned int order);
+int alloc_private_pages(gfp_t gfp_mask, unsigned int order, unsigned int nr);
+void free_private_pages(void);
+
 void page_alloc_init(void);
 void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 void drain_all_pages(struct zone *zone);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6d77432e14ff..1fe390779f23 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1545,6 +1545,8 @@ struct task_struct {
 #endif
 
 /* VM state */
+	struct list_head private_pages;
+
 	struct reclaim_state *reclaim_state;
 
 	struct backing_dev_info *backing_dev_info;
diff --git a/kernel/fork.c b/kernel/fork.c
index cf65139615a0..b6349b0e5da2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1308,6 +1308,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	memset(&p->rss_stat, 0, sizeof(p->rss_stat));
 #endif
 
+	INIT_LIST_HEAD(&p->private_pages);
+
 	p->default_timer_slack_ns = current->timer_slack_ns;
 
 	task_io_accounting_init(&p->ioac);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a47f0b229a1a..546db4e0da75 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -490,12 +490,10 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 static inline void set_page_order(struct page *page, unsigned int order)
 {
 	set_page_private(page, order);
-	__SetPageBuddy(page);
 }
 
 static inline void rmv_page_order(struct page *page)
 {
-	__ClearPageBuddy(page);
 	set_page_private(page, 0);
 }
 
@@ -617,6 +615,7 @@ static inline void __free_one_page(struct page *page,
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
 			rmv_page_order(buddy);
+			__ClearPageBuddy(buddy);
 		}
 		combined_idx = buddy_idx & page_idx;
 		page = page + (combined_idx - page_idx);
@@ -624,6 +623,7 @@ static inline void __free_one_page(struct page *page,
 		order++;
 	}
 	set_page_order(page, order);
+	__SetPageBuddy(page);
 
 	/*
 	 * If this is not the largest possible page, check if the buddy
@@ -924,6 +924,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		list_add(&page[size].lru, &area->free_list[migratetype]);
 		area->nr_free++;
 		set_page_order(&page[size], high);
+		__SetPageBuddy(page);
 	}
 }
 
@@ -1015,6 +1016,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 							struct page, lru);
 		list_del(&page->lru);
 		rmv_page_order(page);
+		__ClearPageBuddy(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
 		set_freepage_migratetype(page, migratetype);
@@ -1212,6 +1214,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 			/* Remove the page from the freelists */
 			list_del(&page->lru);
 			rmv_page_order(page);
+			__ClearPageBuddy(page);
 
 			expand(zone, page, order, current_order, area,
 					buddy_type);
@@ -1598,6 +1601,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	list_del(&page->lru);
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
+	__ClearPageBuddy(page);
 
 	/* Set the pageblock if the isolated page is at least a pageblock */
 	if (order >= pageblock_order - 1) {
@@ -2504,6 +2508,40 @@ retry:
 	return page;
 }
 
+/* Try to allocate from the caller's private memory reserves */
+static inline struct page *
+__alloc_pages_private(gfp_t gfp_mask, unsigned int order,
+		      const struct alloc_context *ac)
+{
+	unsigned int uninitialized_var(alloc_order);
+	struct page *page = NULL;
+	struct page *p;
+
+	/* Dopy, but this is a slowpath right before OOM */
+	list_for_each_entry(p, &current->private_pages, lru) {
+		int o = page_order(p);
+
+		if (o >= order && (!page || o < alloc_order)) {
+			page = p;
+			alloc_order = o;
+		}
+	}
+	if (!page)
+		return NULL;
+
+	list_del(&page->lru);
+	rmv_page_order(page);
+
+	/* Give back the remainder */
+	while (alloc_order > order) {
+		alloc_order--;
+		set_page_order(&page[1 << alloc_order], alloc_order);
+		list_add(&page[1 << alloc_order].lru, &current->private_pages);
+	}
+
+	return page;
+}
+
 /*
  * This is called in the allocator slow-path if the allocation request is of
  * sufficient urgency to ignore watermarks and take other desperate measures
@@ -2753,9 +2791,13 @@ retry:
 		/*
 		 * If we fail to make progress by freeing individual
 		 * pages, but the allocation wants us to keep going,
-		 * start OOM killing tasks.
+		 * dip into private reserves, or start OOM killing.
 		 */
 		if (!did_some_progress) {
+			page = __alloc_pages_private(gfp_mask, order, ac);
+			if (page)
+				goto got_pg;
+
 			page = __alloc_pages_may_oom(gfp_mask, order, ac,
 							&did_some_progress);
 			if (page)
@@ -3046,6 +3088,82 @@ void free_pages_exact(void *virt, size_t size)
 EXPORT_SYMBOL(free_pages_exact);
 
 /**
+ * alloc_private_pages - allocate private memory reserve pages
+ * @gfp_mask: gfp flags for the allocations
+ * @order: order of pages to allocate
+ * @nr: number of pages to allocate
+ *
+ * This allocates @nr pages of order @order as an emergency reserve of
+ * the calling task, to be used by the page allocator if an allocation
+ * would otherwise fail.
+ *
+ * The caller is responsible for calling free_private_pages() once the
+ * reserves are no longer required.
+ */
+int alloc_private_pages(gfp_t gfp_mask, unsigned int order, unsigned int nr)
+{
+	struct page *page, *page2;
+	LIST_HEAD(pages);
+	unsigned int i;
+
+	for (i = 0; i < nr; i++) {
+		page = alloc_pages(gfp_mask, order);
+		if (!page)
+			goto error;
+		set_page_order(page, order);
+		list_add(&page->lru, &pages);
+	}
+
+	list_splice(&pages, &current->private_pages);
+	return 0;
+
+error:
+	list_for_each_entry_safe(page, page2, &pages, lru) {
+		list_del(&page->lru);
+		rmv_page_order(page);
+		__free_pages(page, order);
+	}
+	return -ENOMEM;
+}
+
+/**
+ * register_private_page - register a private memory reserve page
+ * @page: pre-allocated page
+ * @order: @page's order
+ *
+ * This registers @page as an emergency reserve of the calling task,
+ * to be used by the page allocator if an allocation would otherwise
+ * fail.
+ *
+ * The caller is responsible for calling free_private_pages() once the
+ * reserves are no longer required.
+ */
+void register_private_page(struct page *page, unsigned int order)
+{
+	set_page_order(page, order);
+	list_add(&page->lru, &current->private_pages);
+}
+
+/**
+ * free_private_pages - free all private memory reserve pages
+ *
+ * Frees all (remaining) pages of the calling task's memory reserves
+ * established by alloc_private_pages() and register_private_page().
+ */
+void free_private_pages(void)
+{
+	struct page *page, *page2;
+
+	list_for_each_entry_safe(page, page2, &current->private_pages, lru) {
+		int order = page_order(page);
+
+		list_del(&page->lru);
+		rmv_page_order(page);
+		__free_pages(page, order);
+	}
+}
+
+/**
  * nr_free_zone_pages - count number of pages beyond high watermark
  * @offset: The zone index of the highest zone
  *
@@ -6551,6 +6669,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 		list_del(&page->lru);
 		rmv_page_order(page);
+		__ClearPageBuddy(page);
 		zone->free_area[order].nr_free--;
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
