Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 326EB6B02A4
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 23:08:07 -0400 (EDT)
Date: Fri, 6 Aug 2010 11:08:05 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-ID: <20100806030805.GA10038@sli10-desk.sh.intel.com>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
 <20100723234938.88EB.A69D9226@jp.fujitsu.com>
 <20100726050827.GA24047@sli10-desk.sh.intel.com>
 <20100805140755.501af8a7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805140755.501af8a7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 06, 2010 at 05:07:55AM +0800, Andrew Morton wrote:
> On Mon, 26 Jul 2010 13:08:27 +0800
> Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > The zone->lru_lock is heavily contented in workload where activate_page()
> > is frequently used. We could do batch activate_page() to reduce the lock
> > contention. The batched pages will be added into zone list when the pool
> > is full or page reclaim is trying to drain them.
> > 
> > For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> > processes shared map to the file. Each process read access the whole file and
> > then exit. The process exit will do unmap_vmas() and cause a lot of
> > activate_page() call. In such workload, we saw about 58% total time reduction
> > with below patch.
> 
> What happened to the 2% regression that earlier changelogs mentioned?
The 2% regression tend to be a noise. I did a bunch of test later, and the regression
isn't stable and sometimes there is improvement and sometimes there is regression.
so I removed that changelog. I mentioned this in previous mail too.
 
> afacit the patch optimises the rare munmap() case.  But what effect
> does it have upon the common case?  How do we know that it is a net
> benefit?
Not just munmap() case. There are a lot of workloads lru_lock is heavilly contented
in activate_page(), for example some file io workloads.

> Because the impact on kernel footprint is awful.  x86_64 allmodconfig:
> 
>    text    data     bss     dec     hex filename
>    5857    1426    1712    8995    2323 mm/swap.o
>    6245    1587    1840    9672    25c8 mm/swap.o
> 
> and look at x86_64 allnoconfig:
> 
>    text    data     bss     dec     hex filename
>    2344     768       4    3116     c2c mm/swap.o
>    2632     896       4    3532     dcc mm/swap.o
> 
> that's a uniprocessor kernel where none of this was of any use!
> 
> Looking at the patch, I'm not sure where all this bloat came from.  But
> the SMP=n case is pretty bad and needs fixing, IMO.
updated the patch, which reduce the footprint a little bit for SMP=n
2472     768       4    3244     cac ../tmp/mm/swap.o
2600     768       4    3372     d2c ../tmp/mm/swap.o
we unified lru_add and activate_page, which adds a little footprint.

Thanks,
Shaohua



Subject: mm: batch activate_page() to reduce lock contention

The zone->lru_lock is heavily contented in workload where activate_page()
is frequently used. We could do batch activate_page() to reduce the lock
contention. The batched pages will be added into zone list when the pool
is full or page reclaim is trying to drain them.

For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
processes shared map to the file. Each process read access the whole file and
then exit. The process exit will do unmap_vmas() and cause a lot of
activate_page() call. In such workload, we saw about 58% total time reduction
with below patch.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

diff --git a/mm/swap.c b/mm/swap.c
index 3ce7bc3..744883f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -172,28 +172,93 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
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
+}
+
+static void pagevec_lru_move_fn(struct pagevec *pvec,
+				void (*move_fn)(struct page *page, void *arg),
+				void *arg)
+{
+	struct zone *last_zone = NULL;
+	int i, j;
+	DECLARE_BITMAP(pages_done, PAGEVEC_SIZE);
+
+	bitmap_zero(pages_done, PAGEVEC_SIZE);
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		if (test_bit(i, pages_done))
+			continue;
+
+		if (last_zone)
+			spin_unlock_irq(&last_zone->lru_lock);
+		last_zone = page_zone(pvec->pages[i]);
+		spin_lock_irq(&last_zone->lru_lock);
+
+		for (j = i; j < pagevec_count(pvec); j++) {
+			struct page *page = pvec->pages[j];
+
+			if (last_zone != page_zone(page))
+				continue;
+			(*move_fn)(page, arg);
+			__set_bit(j, pages_done);
+		}
+	}
+	if (last_zone)
+		spin_unlock_irq(&last_zone->lru_lock);
+	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+#ifdef CONFIG_SMP
+static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
+
+static void activate_page_drain(int cpu)
+{
+	struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
+
+	if (pagevec_count(pvec))
+		pagevec_lru_move_fn(pvec, __activate_page, NULL);
+}
+
+void activate_page(struct page *page)
+{
+	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
+
+		page_cache_get(page);
+		if (!pagevec_add(pvec, page))
+			pagevec_lru_move_fn(pvec, __activate_page, NULL);
+		put_cpu_var(activate_page_pvecs);
+	}
+}
+#else
+static void inline activate_page_drain(int cpu)
+{
+}
+
+void activate_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	__activate_page(page, NULL);
 	spin_unlock_irq(&zone->lru_lock);
 }
+#endif
 
 /*
  * Mark a page as having seen activity.
@@ -292,6 +357,8 @@ static void drain_cpu_pagevecs(int cpu)
 		pagevec_move_tail(pvec);
 		local_irq_restore(flags);
 	}
+
+	activate_page_drain(cpu);
 }
 
 void lru_add_drain(void)
@@ -398,46 +465,34 @@ void __pagevec_release(struct pagevec *pvec)
 
 EXPORT_SYMBOL(__pagevec_release);
 
+static void ____pagevec_lru_add_fn(struct page *page, void *arg)
+{
+	enum lru_list lru = (enum lru_list)arg;
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
 	VM_BUG_ON(is_unevictable_lru(lru));
 
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
+	pagevec_lru_move_fn(pvec, ____pagevec_lru_add_fn, (void *)lru);
 }
-
 EXPORT_SYMBOL(____pagevec_lru_add);
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
