Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 2EA426B005A
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 10:00:33 -0500 (EST)
Received: by wera13 with SMTP id a13so585742wer.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 07:00:31 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 13 Jan 2012 23:00:31 +0800
Message-ID: <CAJd=RBANeF+TTTtn=F_Yx3N5KkVb5vFPY6FNYEjVntB1pPSLBA@mail.gmail.com>
Subject: [PATCH] mm: vmscan: handle isolated pages with lru lock released
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

When shrinking inactive lru list, isolated pages are queued on locally private
list, which opens a window for pulling update_isolated_counts() out of the lock
protection to reduce the lock-hold time.

To achive that, firstly we have to delay updating reclaim stat, which is pointed
out by Hugh, but not over the deadline where fresh data is used for setting up
scan budget for shrinking zone in get_scan_count(). The delay is terminated in
the putback stage after reacquiring lru lock.

Secondly operations related to vm and zone stats, namely __count_vm_events() and
__mod_zone_page_state(), are proteced with preemption disabled as they
are per-cpu
operations.

Thanks for comments and ideas recieved.


Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Fri Jan 13 21:30:58 2012
+++ b/mm/vmscan.c	Fri Jan 13 22:07:14 2012
@@ -1408,6 +1408,13 @@ putback_lru_pages(struct mem_cgroup_zone
 	 * Put back any unfreeable pages.
 	 */
 	spin_lock(&zone->lru_lock);
+	/*
+	 * Here we finish updating reclaim stat that is delayed in
+	 * update_isolated_counts()
+	 */
+	reclaim_stat->recent_scanned[0] += nr_anon;
+	reclaim_stat->recent_scanned[1] += nr_file;
+
 	while (!list_empty(page_list)) {
 		int lru;
 		page = lru_to_page(page_list);
@@ -1461,9 +1468,19 @@ update_isolated_counts(struct mem_cgroup
 	unsigned long nr_active;
 	struct zone *zone = mz->zone;
 	unsigned int count[NR_LRU_LISTS] = { 0, };
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);

 	nr_active = clear_active_flags(isolated_list, count);
+	/*
+	 * Without lru lock held,
+	 * 1, we have to delay updating zone reclaim stat, and the deadline is
+	 *    when fresh data is used for setting up scan budget for another
+	 *    round shrinking, see get_scan_count(). It is actually updated in
+	 *    the putback stage after reacquiring the lock.
+	 *
+	 * 2, __count_vm_events() and __mod_zone_page_state() are protected
+	 *    with preempt disabled as they are per-cpu operations.
+	 */
+	preempt_disable();
 	__count_vm_events(PGDEACTIVATE, nr_active);

 	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
@@ -1479,9 +1496,7 @@ update_isolated_counts(struct mem_cgroup
 	*nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, *nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, *nr_file);
-
-	reclaim_stat->recent_scanned[0] += *nr_anon;
-	reclaim_stat->recent_scanned[1] += *nr_file;
+	preempt_enable();
 }

 /*
@@ -1577,15 +1592,12 @@ shrink_inactive_list(unsigned long nr_to
 			__count_zone_vm_events(PGSCAN_DIRECT, zone,
 					       nr_scanned);
 	}
+	spin_unlock_irq(&zone->lru_lock);

-	if (nr_taken == 0) {
-		spin_unlock_irq(&zone->lru_lock);
+	if (nr_taken == 0)
 		return 0;
-	}

 	update_isolated_counts(mz, sc, &nr_anon, &nr_file, &page_list);
-
-	spin_unlock_irq(&zone->lru_lock);

 	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
 						&nr_dirty, &nr_writeback);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
