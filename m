Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CEB116B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 11:10:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6NFAo06010429
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 24 Jul 2010 00:10:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DCF245DE4F
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 00:10:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5971845DE55
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 00:10:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 34A341DB8044
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 00:10:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D056A1DB8043
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 00:10:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
In-Reply-To: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
Message-Id: <20100723234938.88EB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Sat, 24 Jul 2010 00:10:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> The zone->lru_lock is heavily contented in workload where activate_page()
> is frequently used. We could do batch activate_page() to reduce the lock
> contention. The batched pages will be added into zone list when the pool
> is full or page reclaim is trying to drain them.
> 
> For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> processes shared map to the file. Each process read access the whole file and
> then exit. The process exit will do unmap_vmas() and cause a lot of
> activate_page() call. In such workload, we saw about 58% total time reduction
> with below patch.

I'm not sure this. Why process exiting on your workload call unmap_vmas?
Can you please explain why we can't stop activate_page? Is this proper page activation?


> 
> But we did see some strange regression. The regression is small (usually < 2%)
> and most are from multithread test and none heavily use activate_page(). For
> example, in the same system, we create 64 threads. Each thread creates a private
> mmap region and does read access. We measure the total time and saw about 2%
> regression. But in such workload, 99% time is on page fault and activate_page()
> takes no time. Very strange, we haven't a good explanation for this so far,
> hopefully somebody can share a hint.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 3ce7bc3..4a3fd7f 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -39,6 +39,7 @@ int page_cluster;
>  
>  static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
>  
>  /*
>   * This path almost never happens for VM activity - pages are normally
> @@ -175,11 +176,10 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
>  /*
>   * FIXME: speed this up?
>   */
> -void activate_page(struct page *page)
> +static void __activate_page(struct page *page)
>  {
>  	struct zone *zone = page_zone(page);

this page_zone() can move in following branch.


> -	spin_lock_irq(&zone->lru_lock);
>  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
>  		int file = page_is_file_cache(page);
>  		int lru = page_lru_base_type(page);
> @@ -192,7 +192,46 @@ void activate_page(struct page *page)
>  
>  		update_page_reclaim_stat(zone, page, file, 1);
>  	}
> -	spin_unlock_irq(&zone->lru_lock);
> +}
> +
> +static void activate_page_drain_cpu(int cpu)
> +{
> +	struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
> +	struct zone *last_zone = NULL, *zone;
> +	int i, j;
> +
> +	for (i = 0; i < pagevec_count(pvec); i++) {
> +		zone = page_zone(pvec->pages[i]);
> +		if (zone == last_zone)
> +			continue;
> +
> +		if (last_zone)
> +			spin_unlock_irq(&last_zone->lru_lock);
> +		last_zone = zone;
> +		spin_lock_irq(&last_zone->lru_lock);
> +
> +		for (j = i; j < pagevec_count(pvec); j++) {
> +			struct page *page = pvec->pages[j];
> +
> +			if (last_zone != page_zone(page))
> +				continue;
> +			__activate_page(page);
> +		}
> +	}
> +	if (last_zone)
> +		spin_unlock_irq(&last_zone->lru_lock);
> +	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
> +	pagevec_reinit(pvec);
> +}

Can we unify this and ____pagevec_lru_add(). they are very similar.


> +
> +void activate_page(struct page *page)
> +{

activate_page() is called from few non mark_page_accessed() function.
so, 

	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page))

line slightly help.


> +	struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
> +
> +	page_cache_get(page);
> +	if (!pagevec_add(pvec, page))
> +		activate_page_drain_cpu(smp_processor_id());

seems no need smp_processor_id(). we can pass pvec directly.

> +	put_cpu_var(activate_page_pvecs);
>  }
>  
>  /*
> @@ -297,6 +336,7 @@ static void drain_cpu_pagevecs(int cpu)
>  void lru_add_drain(void)
>  {
>  	drain_cpu_pagevecs(get_cpu());
> +	activate_page_drain_cpu(smp_processor_id());
>  	put_cpu();
>  }
>  
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


Following code is the explanation of another way.



---
 mm/swap.c |  112 ++++++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 71 insertions(+), 41 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 3ce7bc3..48e6f54 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -39,6 +39,7 @@ int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
+static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -172,27 +173,65 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
 		memcg_reclaim_stat->recent_rotated[file]++;
 }
 
-/*
- * FIXME: speed this up?
- */
-void activate_page(struct page *page)
+static void __activate_page(struct page *page, void *arg)
 {
-	struct zone *zone = page_zone(page);
-
-	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+		struct zone *zone = page_zone(page);
 		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
+
 		del_page_from_lru_list(zone, page, lru);
 
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(zone, page, lru);
-		__count_vm_event(PGACTIVATE);
 
+		__count_vm_event(PGACTIVATE);
 		update_page_reclaim_stat(zone, page, file, 1);
 	}
-	spin_unlock_irq(&zone->lru_lock);
+}
+
+static void pagevec_lru_move_fn(struct pagevec *pvec,
+				void (*move_fn)(struct page *page, void *arg),
+				void *arg)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+
+		(*move_fn)(page, arg);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+static void activate_page_drain(struct pagevec *pvec)
+{
+	pagevec_lru_move_fn(pvec, __activate_page, NULL);
+}
+
+void activate_page(struct page *page)
+{
+	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
+
+		page_cache_get(page);
+		if (!pagevec_add(pvec, page))
+			activate_page_drain(pvec);
+		put_cpu_var(activate_page_pvecs);
+	}
 }
 
 /*
@@ -292,6 +331,10 @@ static void drain_cpu_pagevecs(int cpu)
 		pagevec_move_tail(pvec);
 		local_irq_restore(flags);
 	}
+
+	pvec = &per_cpu(activate_page_pvecs, cpu);
+	if (pagevec_count(pvec))
+		activate_page_drain(pvec);
 }
 
 void lru_add_drain(void)
@@ -398,46 +441,33 @@ void __pagevec_release(struct pagevec *pvec)
 
 EXPORT_SYMBOL(__pagevec_release);
 
+static void ____pagevec_lru_add_fn(struct page *page, void *arg)
+{
+	enum lru_list lru = (enum lru_list) arg;
+	struct zone *zone = page_zone(page);
+	int file = is_file_lru(lru);
+	int active = is_active_lru(lru);
+
+	VM_BUG_ON(PageActive(page));
+	VM_BUG_ON(PageUnevictable(page));
+	VM_BUG_ON(PageLRU(page));
+
+	SetPageLRU(page);
+	if (active)
+		SetPageActive(page);
+	update_page_reclaim_stat(zone, page, file, active);
+	add_page_to_lru_list(zone, page, lru);
+}
+
 /*
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
 void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 {
-	int i;
-	struct zone *zone = NULL;
-
-	VM_BUG_ON(is_unevictable_lru(lru));
+	pagevec_lru_move_fn(pvec, ____pagevec_lru_add_fn, (void*)lru);
 
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-		int file;
-		int active;
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		VM_BUG_ON(PageActive(page));
-		VM_BUG_ON(PageUnevictable(page));
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		active = is_active_lru(lru);
-		file = is_file_lru(lru);
-		if (active)
-			SetPageActive(page);
-		update_page_reclaim_stat(zone, page, file, active);
-		add_page_to_lru_list(zone, page, lru);
-	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
 }
-
 EXPORT_SYMBOL(____pagevec_lru_add);
 
 /*
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
