Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B228C6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 08:52:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n2so43330083wma.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 05:52:56 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ty18si50577720wjb.23.2016.05.31.05.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 05:52:55 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so32436620wmg.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 05:52:55 -0700 (PDT)
Date: Tue, 31 May 2016 14:52:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160531125253.GK26128@dhcp22.suse.cz>
References: <20160520202817.GA22201@redhat.com>
 <20160523072904.GC2278@dhcp22.suse.cz>
 <20160523151419.GA8284@redhat.com>
 <20160524071619.GB8259@dhcp22.suse.cz>
 <20160524224341.GA11961@redhat.com>
 <20160525120957.GH20132@dhcp22.suse.cz>
 <20160529212540.GA15180@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160529212540.GA15180@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun 29-05-16 23:25:40, Oleg Nesterov wrote:
> sorry for delay,
> 
> On 05/25, Michal Hocko wrote:
[...]
> > This is a bit surprising but my testing shows that the result shouldn't
> > make much difference. I can see some discrepancies between lru_vec size
> > and zone_reclaimable_pages but they are too small to actually matter.
> 
> Yes, the difference is small but it does matter.
> 
> I do not pretend I understand this all, but finally it seems I understand
> whats going on on my system when it hangs. At least, why the change in
> lruvec_lru_size() or calculate_normal_threshold() makes a difference.
> 
> This single change in get_scan_count() under for_each_evictable_lru() loop
> 
> 	-	size = lruvec_lru_size(lruvec, lru);
> 	+	size = zone_page_state_snapshot(lruvec_zone(lruvec), NR_LRU_BASE + lru);
> 
> fixes the problem too.
> 
> Without this change shrink*() continues to scan the LRU_ACTIVE_FILE list
> while it is empty. LRU_INACTIVE_FILE is not empty (just a few pages) but
> we do not even try to scan it, lruvec_lru_size() returns zero.

OK, you seem to be really seeing a different issue than me. My debugging
patch was showing when nothing was really isolated from the LRU lists
(both for shrink_{in}active_list.

> Then later we recheck zone_reclaimable() and it notices the INACTIVE_FILE
> counter because it uses the _snapshot variant, this leads to livelock.
> 
> I guess this doesn't really matter, but in my particular case these
> ACTIVE/INACTIVE counters were screwed by the recent putback_inactive_pages()
> logic. The pages we "leak" in INACTIVE list were recently moved from ACTIVE
> to INACTIVE list, and this updated only the per-cpu ->vm_stat_diff[] counters,
> so the "non snapshot" lruvec_lru_size() in get_scan_count() sees the "old"
> numbers.

Hmm. I am not really sure we can use the _snapshot version in lruvec_lru_size.
It is called also outise of slow paths (like add_to_page_cache_lru).
Maybe a path like below would be acceptable for stable trees.

But I am thinking whether we should simply revert 0db2cb8da89d ("mm,
vmscan: make zone_reclaimable_pages more precise") in 4.6 stable tree.
Does that help as well? The patch is certainly needed for the oom
detection rework but it got merged one release cycle earlier.
--- 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3388ccbab7d6..9f46a29c06b6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -764,7 +764,8 @@ static inline struct zone *lruvec_zone(struct lruvec *lruvec)
 #endif
 }
 
-extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
+extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru,
+		bool precise);
 
 #ifdef CONFIG_HAVE_MEMORY_PRESENT
 void memory_present(int nid, unsigned long start, unsigned long end);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4a2f4512fca..84420045090b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -213,11 +213,13 @@ bool zone_reclaimable(struct zone *zone)
 		zone_reclaimable_pages(zone) * 6;
 }
 
-unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
+unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, bool precise)
 {
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_get_lru_size(lruvec, lru);
 
+	if (precise)
+		return zone_page_state_snapshot(lruvec_zone(lruvec), NR_LRU_BASE + lru);
 	return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
 }
 
@@ -1902,8 +1904,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file)
 	if (!file && !total_swap_pages)
 		return false;
 
-	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
-	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
+	inactive = lruvec_lru_size(lruvec, file * LRU_FILE, true);
+	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE, true);
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -2040,7 +2042,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_list_is_low(lruvec, true) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
+	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, true) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2066,10 +2068,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * anon in [0], file in [1]
 	 */
 
-	anon  = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON) +
-		lruvec_lru_size(lruvec, LRU_INACTIVE_ANON);
-	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE) +
-		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
+	anon  = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON, true) +
+		lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, true);
+	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, true) +
+		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, true);
 
 	spin_lock_irq(&zone->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
@@ -2107,7 +2109,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			unsigned long size;
 			unsigned long scan;
 
-			size = lruvec_lru_size(lruvec, lru);
+			size = lruvec_lru_size(lruvec, lru, true);
 			scan = size >> sc->priority;
 
 			if (!scan && pass && force_scan)
diff --git a/mm/workingset.c b/mm/workingset.c
index 8a75f8d2916a..509cdf7a6fc9 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -269,7 +269,7 @@ bool workingset_refault(void *shadow)
 	}
 	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
-	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
+	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, false);
 	rcu_read_unlock();
 
 	/*
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
