Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68AD96B0379
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 02:37:04 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so29057687wma.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 23:37:04 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id o9si1201181wmo.50.2016.12.20.23.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 23:37:02 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id o3so1539785wjo.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 23:37:01 -0800 (PST)
Date: Wed, 21 Dec 2016 08:36:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161221073658.GC16502@dhcp22.suse.cz>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216184655.GA5664@boerne.fritz.box>
 <20161217000203.GC23392@dhcp22.suse.cz>
 <20161217125950.GA3321@boerne.fritz.box>
 <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161220020829.GA5449@boerne.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

TL;DR
there is another version of the debugging patch. Just revert the
previous one and apply this one instead. It's still not clear what
is going on but I suspect either some misaccounting or unexpeted
pages on the LRU lists. I have added one more tracepoint, so please
enable also mm_vmscan_inactive_list_is_low.

Hopefully the additional data will tell us more.

On Tue 20-12-16 03:08:29, Nils Holland wrote:
> On Mon, Dec 19, 2016 at 02:45:34PM +0100, Michal Hocko wrote:
> 
> > Unfortunatelly shrink_active_list doesn't have any tracepoint so we do
> > not know whether we managed to rotate those pages. If they are referenced
> > quickly enough we might just keep refaulting them... Could you try to apply
> > the followin diff on top what you have currently. It should add some more
> > tracepoint data which might tell us more. We can reduce the amount of
> > tracing data by enabling only mm_vmscan_lru_isolate,
> > mm_vmscan_lru_shrink_inactive and mm_vmscan_lru_shrink_active.
> 
> So, the results are in! I applied your patch and rebuild the kernel,
> then I rebooted the machine, set up tracing so that only the three
> events you mentioned were being traced, and captured the output over
> the network.
> 
> Things went a bit different this time: The trace events started to
> appear after a while and a whole lot of them were generated, but
> suddenly they stopped. A short while later, we get

It is possible that you are hitting multiple issues so it would be
great to focus at one at the time. The underlying problem might be
same/similar in the end but this is hard to tell now. Could you try to
reproduce and provide data for the OOM killer situation as well?
 
> [ 1661.485568] btrfs-transacti: page alloction stalls for 611058ms, order:0, mode:0x2420048(GFP_NOFS|__GFP_HARDWALL|__GFP_MOVABLE)
> 
> along with a backtrace and memory information, and then there was
> silence.

> When I walked up to the machine, it had completely died; it
> wouldn't turn on its screen on key press any more, blindly trying to
> reboot via SysRequest had no effect, but the caps lock LED also wasn't
> blinking, like it normally does when a kernel panic occurs. Good
> question what state it was in. The OOM reaper didn't really seem to
> kick in and kill processes this time, it seems.
> 
> The complete capture is up at:
> 
> http://ftp.tisys.org/pub/misc/teela_2016-12-20.log.xz

This is the stall report:
[ 1661.485568] btrfs-transacti: page alloction stalls for 611058ms, order:0, mode:0x2420048(GFP_NOFS|__GFP_HARDWALL|__GFP_MOVABLE)
[ 1661.485859] CPU: 1 PID: 1950 Comm: btrfs-transacti Not tainted 4.9.0-gentoo #4

pid 1950 is trying to allocate for a _long_ time. Considering that this
is the only stall report, this means that reclaim took really long so we
didn't get to the page allocator for that long. It sounds really crazy!

$ xzgrep -w 1950 teela_2016-12-20.log.xz | grep mm_vmscan_lru_shrink_inactive | sed 's@.*nr_reclaimed=\([0-9\]*\).*@\1@' | sort | uniq -c
    509 0
      1 1
      1 10
      5 11
      1 12
      1 14
      1 16
      2 19
      5 2
      1 22
      2 23
      1 25
      3 28
      2 3
      1 4
      4 5

It barely managed to reclaim something. While it has tried a lot. It
had hard times to actually isolate anything:

$ xzgrep -w 1950 teela_2016-12-20.log.xz | grep mm_vmscan_lru_isolate: | sed 's@.*nr_taken=@@' | sort | uniq -c
   8284 0 file=1
      8 11 file=1
      4 14 file=1
      1 1 file=1
      7 23 file=1
      1 25 file=1
      9 2 file=1
    501 32 file=1
      1 3 file=1
      7 5 file=1
      1 6 file=1

a typical mm_vmscan_lru_isolate looks as follows

btrfs-transacti-1950  [001] d...  1368.508008: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 nr_requested=32 nr_scanned=266727 nr_taken=0 file=1

so the whole inactive lru has been scanned it seems. But we couldn't
isolate a single page. There are two possibilities here. Either we skip
them all because they are from the highmem zone or we fail to
__isolate_lru_page them. Counters will not tell us because nr_scanned
includes skipped pages. I have updated the debugging patch to make this
distinction. I suspect we are skipping all of them...
The later option would be really surprising because the only way to fail
__isolate_lru_page with the 0 isolate_mode is if get_page_unless_zero(page)
fails which would mean we would have pages with 0 reference count on the
LRU list.

The stall message is from a later time so the situation might have
changed but
[ 1661.490170] Node 0 	active_anon:139296kB	inactive_anon:432kB	active_file:1088996kB	inactive_file:1114524kB
[ 1661.490745] DMA 	active_anon:0kB 	inactive_anon:0kB	active_file:9540kB	inactive_file:0kB
[ 1661.491528] Normal 	active_anon:0kB 	inactive_anon:0kB	active_file:530560kB	inactive_file:452kB
[ 1661.513077] HighMem 	active_anon:139296kB 	inactive_anon:432kB	active_file:548896kB	inactive_file:1114068kB

suggests our inactive file LRU is low:
file total_active 1088996 active 540100 total_inactive 1114524 inactive 456 ratio 1 low 1

and we should be rotating active pages. But

$ xzgrep -w 1950 teela_2016-12-20.log.xz | grep mm_vmscan_lru_shrink_active
$

Now inactive_list_is_low is racy but I doubt we can consistently see it
racing and give us a wrong answer. I also do not see it would miss lowmem
zones imbalanced but hidden by highmem zones (assuming those counters
are OK).

That being said, numbers do not make much sense to me, to be honest.
Could you try with the updated tracing patch please?
---
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4175dca4ac39..61aa9b49e86d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -503,7 +503,7 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, bool cold);
-extern void free_hot_cold_page_list(struct list_head *list, bool cold);
+extern int free_hot_cold_page_list(struct list_head *list, bool cold);
 
 struct page_frag_cache;
 extern void __page_frag_drain(struct page *page, unsigned int order,
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c88fd0934e7e..cbd2fff521f0 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -275,20 +275,22 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		int order,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
+		unsigned long nr_skipped,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
-		int file),
+		int lru),
 
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file),
+	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_skipped, nr_taken, isolate_mode, lru),
 
 	TP_STRUCT__entry(
 		__field(int, classzone_idx)
 		__field(int, order)
 		__field(unsigned long, nr_requested)
 		__field(unsigned long, nr_scanned)
+		__field(unsigned long, nr_skipped)
 		__field(unsigned long, nr_taken)
 		__field(isolate_mode_t, isolate_mode)
-		__field(int, file)
+		__field(int, lru)
 	),
 
 	TP_fast_assign(
@@ -296,19 +298,21 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->order = order;
 		__entry->nr_requested = nr_requested;
 		__entry->nr_scanned = nr_scanned;
+		__entry->nr_skipped = nr_skipped;
 		__entry->nr_taken = nr_taken;
 		__entry->isolate_mode = isolate_mode;
-		__entry->file = file;
+		__entry->lru = lru;
 	),
 
-	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
+	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_skipped=%lu nr_taken=%lu lru=%d",
 		__entry->isolate_mode,
 		__entry->classzone_idx,
 		__entry->order,
 		__entry->nr_requested,
 		__entry->nr_scanned,
+		__entry->nr_skipped,
 		__entry->nr_taken,
-		__entry->file)
+		__entry->lru)
 );
 
 DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
@@ -317,11 +321,12 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 		int order,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
+		unsigned long nr_skipped,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
-		int file),
+		int lru),
 
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
+	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_skipped, nr_taken, isolate_mode, lru)
 
 );
 
@@ -331,11 +336,12 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 		int order,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
+		unsigned long nr_skipped,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
-		int file),
+		int lru),
 
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
+	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_skipped, nr_taken, isolate_mode, lru)
 
 );
 
@@ -365,14 +371,27 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 
 	TP_PROTO(int nid,
 		unsigned long nr_scanned, unsigned long nr_reclaimed,
+		unsigned long nr_dirty, unsigned long nr_writeback,
+		unsigned long nr_congested, unsigned long nr_immediate,
+		unsigned long nr_activate, unsigned long nr_ref_keep,
+		unsigned long nr_unmap_fail,
 		int priority, int file),
 
-	TP_ARGS(nid, nr_scanned, nr_reclaimed, priority, file),
+	TP_ARGS(nid, nr_scanned, nr_reclaimed, nr_dirty, nr_writeback,
+		nr_congested, nr_immediate, nr_activate, nr_ref_keep,
+		nr_unmap_fail, priority, file),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_reclaimed)
+		__field(unsigned long, nr_dirty)
+		__field(unsigned long, nr_writeback)
+		__field(unsigned long, nr_congested)
+		__field(unsigned long, nr_immediate)
+		__field(unsigned long, nr_activate)
+		__field(unsigned long, nr_ref_keep)
+		__field(unsigned long, nr_unmap_fail)
 		__field(int, priority)
 		__field(int, reclaim_flags)
 	),
@@ -381,17 +400,100 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		__entry->nid = nid;
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_reclaimed = nr_reclaimed;
+		__entry->nr_dirty = nr_dirty;
+		__entry->nr_writeback = nr_writeback;
+		__entry->nr_congested = nr_congested;
+		__entry->nr_immediate = nr_immediate;
+		__entry->nr_activate = nr_activate;
+		__entry->nr_ref_keep = nr_ref_keep;
+		__entry->nr_unmap_fail = nr_unmap_fail;
 		__entry->priority = priority;
 		__entry->reclaim_flags = trace_shrink_flags(file);
 	),
 
-	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
+	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate=%ld nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d flags=%s",
 		__entry->nid,
 		__entry->nr_scanned, __entry->nr_reclaimed,
+		__entry->nr_dirty, __entry->nr_writeback,
+		__entry->nr_congested, __entry->nr_immediate,
+		__entry->nr_activate, __entry->nr_ref_keep,
+		__entry->nr_unmap_fail, __entry->priority,
+		show_reclaim_flags(__entry->reclaim_flags))
+);
+
+TRACE_EVENT(mm_vmscan_lru_shrink_active,
+
+	TP_PROTO(int nid, unsigned long nr_scanned, unsigned long nr_freed,
+		unsigned long nr_unevictable, unsigned long nr_deactivated,
+		unsigned long nr_rotated, int priority, int file),
+
+	TP_ARGS(nid, nr_scanned, nr_freed, nr_unevictable, nr_deactivated, nr_rotated, priority, file),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(unsigned long, nr_scanned)
+		__field(unsigned long, nr_freed)
+		__field(unsigned long, nr_unevictable)
+		__field(unsigned long, nr_deactivated)
+		__field(unsigned long, nr_rotated)
+		__field(int, priority)
+		__field(int, reclaim_flags)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->nr_scanned = nr_scanned;
+		__entry->nr_freed = nr_freed;
+		__entry->nr_unevictable = nr_unevictable;
+		__entry->nr_deactivated = nr_deactivated;
+		__entry->nr_rotated = nr_rotated;
+		__entry->priority = priority;
+		__entry->reclaim_flags = trace_shrink_flags(file);
+	),
+
+	TP_printk("nid=%d nr_scanned=%ld nr_freed=%ld nr_unevictable=%ld nr_deactivated=%ld nr_rotated=%ld priority=%d flags=%s",
+		__entry->nid,
+		__entry->nr_scanned, __entry->nr_freed, __entry->nr_unevictable,
+		__entry->nr_deactivated, __entry->nr_rotated,
 		__entry->priority,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
+TRACE_EVENT(mm_vmscan_inactive_list_is_low,
+
+	TP_PROTO(int nid, unsigned long total_inactive, unsigned long inactive,
+		unsigned long total_active, unsigned long active,
+		unsigned long ratio, int file),
+
+	TP_ARGS(nid, total_inactive, inactive, total_active, active, ratio, file),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(unsigned long, total_inactive)
+		__field(unsigned long, inactive)
+		__field(unsigned long, total_active)
+		__field(unsigned long, active)
+		__field(unsigned long, ratio)
+		__field(int, reclaim_flags)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->total_inactive = total_inactive;
+		__entry->inactive = inactive;
+		__entry->total_active = total_active;
+		__entry->active = active;
+		__entry->ratio = ratio;
+		__entry->reclaim_flags = trace_shrink_flags(file);
+	),
+
+	TP_printk("nid=%d total_inactive=%ld inactive=%ld total_active=%ld active=%ld ratio=%ld flags=%s",
+		__entry->nid,
+		__entry->total_inactive, __entry->inactive,
+		__entry->total_active, __entry->active,
+		__entry->ratio,
+		show_reclaim_flags(__entry->reclaim_flags))
+);
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1c24112308d6..77d204660857 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2487,14 +2487,18 @@ void free_hot_cold_page(struct page *page, bool cold)
 /*
  * Free a list of 0-order pages
  */
-void free_hot_cold_page_list(struct list_head *list, bool cold)
+int free_hot_cold_page_list(struct list_head *list, bool cold)
 {
 	struct page *page, *next;
+	int ret = 0;
 
 	list_for_each_entry_safe(page, next, list, lru) {
 		trace_mm_page_free_batched(page, cold);
 		free_hot_cold_page(page, cold);
+		ret++;
 	}
+
+	return ret;
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4abf08861d2..0c4707571762 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -902,6 +902,17 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
+struct reclaim_stat {
+	unsigned nr_dirty;
+	unsigned nr_unqueued_dirty;
+	unsigned nr_congested;
+	unsigned nr_writeback;
+	unsigned nr_immediate;
+	unsigned nr_activate;
+	unsigned nr_ref_keep;
+	unsigned nr_unmap_fail;
+};
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -909,22 +920,20 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct pglist_data *pgdat,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
-				      unsigned long *ret_nr_dirty,
-				      unsigned long *ret_nr_unqueued_dirty,
-				      unsigned long *ret_nr_congested,
-				      unsigned long *ret_nr_writeback,
-				      unsigned long *ret_nr_immediate,
+				      struct reclaim_stat *stat,
 				      bool force_reclaim)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
-	unsigned long nr_unqueued_dirty = 0;
-	unsigned long nr_dirty = 0;
-	unsigned long nr_congested = 0;
-	unsigned long nr_reclaimed = 0;
-	unsigned long nr_writeback = 0;
-	unsigned long nr_immediate = 0;
+	unsigned nr_unqueued_dirty = 0;
+	unsigned nr_dirty = 0;
+	unsigned nr_congested = 0;
+	unsigned nr_reclaimed = 0;
+	unsigned nr_writeback = 0;
+	unsigned nr_immediate = 0;
+	unsigned nr_ref_keep = 0;
+	unsigned nr_unmap_fail = 0;
 
 	cond_resched();
 
@@ -1063,6 +1072,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
+			nr_ref_keep++;
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
@@ -1100,6 +1110,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
 				(ttu_flags | TTU_BATCH_FLUSH))) {
 			case SWAP_FAIL:
+				nr_unmap_fail++;
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
@@ -1266,11 +1277,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
 
-	*ret_nr_dirty += nr_dirty;
-	*ret_nr_congested += nr_congested;
-	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
-	*ret_nr_writeback += nr_writeback;
-	*ret_nr_immediate += nr_immediate;
+	if (stat) {
+		stat->nr_dirty = nr_dirty;
+		stat->nr_congested = nr_congested;
+		stat->nr_unqueued_dirty = nr_unqueued_dirty;
+		stat->nr_writeback = nr_writeback;
+		stat->nr_immediate = nr_immediate;
+		stat->nr_activate = pgactivate;
+		stat->nr_ref_keep = nr_ref_keep;
+		stat->nr_unmap_fail = nr_unmap_fail;
+	}
 	return nr_reclaimed;
 }
 
@@ -1282,7 +1298,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 	};
-	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
+	unsigned long ret;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
 
@@ -1295,8 +1311,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	}
 
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
-			TTU_UNMAP|TTU_IGNORE_ACCESS,
-			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+			TTU_UNMAP|TTU_IGNORE_ACCESS, NULL, true);
 	list_splice(&clean_pages, page_list);
 	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1428,6 +1443,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_taken = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
+	unsigned long skipped = 0, total_skipped = 0;
 	unsigned long scan, nr_pages;
 	LIST_HEAD(pages_skipped);
 
@@ -1479,14 +1495,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	 */
 	if (!list_empty(&pages_skipped)) {
 		int zid;
-		unsigned long total_skipped = 0;
 
 		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 			if (!nr_skipped[zid])
 				continue;
 
 			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
-			total_skipped += nr_skipped[zid];
+			skipped += nr_skipped[zid];
 		}
 
 		/*
@@ -1494,13 +1509,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		 * close to unreclaimable. If the LRU list is empty, account
 		 * skipped pages as a full scan.
 		 */
-		scan += list_empty(src) ? total_skipped : total_skipped >> 2;
+		total_skipped = list_empty(src) ? skipped : skipped >> 2;
 
 		list_splice(&pages_skipped, src);
 	}
-	*nr_scanned = scan;
+	*nr_scanned = scan + total_skipped;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
-				    nr_taken, mode, is_file_lru(lru));
+				    skipped, nr_taken, mode, is_file_lru(lru));
 	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);
 	return nr_taken;
 }
@@ -1696,11 +1711,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
-	unsigned long nr_dirty = 0;
-	unsigned long nr_congested = 0;
-	unsigned long nr_unqueued_dirty = 0;
-	unsigned long nr_writeback = 0;
-	unsigned long nr_immediate = 0;
+	struct reclaim_stat stat = {};
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
@@ -1745,9 +1756,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, TTU_UNMAP,
-				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
-				&nr_writeback, &nr_immediate,
-				false);
+				&stat, false);
 
 	spin_lock_irq(&pgdat->lru_lock);
 
@@ -1781,7 +1790,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * of pages under pages flagged for immediate reclaim and stall if any
 	 * are encountered in the nr_immediate check below.
 	 */
-	if (nr_writeback && nr_writeback == nr_taken)
+	if (stat.nr_writeback && stat.nr_writeback == nr_taken)
 		set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 	/*
@@ -1793,7 +1802,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * Tag a zone as congested if all the dirty pages scanned were
 		 * backed by a congested BDI and wait_iff_congested will stall.
 		 */
-		if (nr_dirty && nr_dirty == nr_congested)
+		if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
 			set_bit(PGDAT_CONGESTED, &pgdat->flags);
 
 		/*
@@ -1802,7 +1811,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * the pgdat PGDAT_DIRTY and kswapd will start writing pages from
 		 * reclaim context.
 		 */
-		if (nr_unqueued_dirty == nr_taken)
+		if (stat.nr_unqueued_dirty == nr_taken)
 			set_bit(PGDAT_DIRTY, &pgdat->flags);
 
 		/*
@@ -1811,7 +1820,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (nr_immediate && current_may_throttle())
+		if (stat.nr_immediate && current_may_throttle())
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
@@ -1826,6 +1835,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
 			nr_scanned, nr_reclaimed,
+			stat.nr_dirty,  stat.nr_writeback,
+			stat.nr_congested, stat.nr_immediate,
+			stat.nr_activate, stat.nr_ref_keep, stat.nr_unmap_fail,
 			sc->priority, file);
 	return nr_reclaimed;
 }
@@ -1846,9 +1858,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  *
  * The downside is that we have to touch page->_refcount against each page.
  * But we had to alter page->flags anyway.
+ *
+ * Returns the number of pages moved to the given lru.
  */
 
-static void move_active_pages_to_lru(struct lruvec *lruvec,
+static int move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
@@ -1857,6 +1871,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 	unsigned long pgmoved = 0;
 	struct page *page;
 	int nr_pages;
+	int nr_moved = 0;
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
@@ -1882,11 +1897,15 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 				spin_lock_irq(&pgdat->lru_lock);
 			} else
 				list_add(&page->lru, pages_to_free);
+		} else {
+			nr_moved++;
 		}
 	}
 
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
+
+	return nr_moved;
 }
 
 static void shrink_active_list(unsigned long nr_to_scan,
@@ -1902,7 +1921,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	LIST_HEAD(l_inactive);
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-	unsigned long nr_rotated = 0;
+	unsigned long nr_rotated = 0, nr_unevictable = 0;
+	unsigned long nr_freed, nr_deactivate, nr_activate;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
@@ -1935,6 +1955,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 		if (unlikely(!page_evictable(page))) {
 			putback_lru_page(page);
+			nr_unevictable++;
 			continue;
 		}
 
@@ -1980,13 +2001,16 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
-	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
+	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
+	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
-	free_hot_cold_page_list(&l_hold, true);
+	nr_freed = free_hot_cold_page_list(&l_hold, true);
+	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_scanned, nr_freed,
+			nr_unevictable, nr_deactivate, nr_rotated,
+			sc->priority, file);
 }
 
 /*
@@ -2019,8 +2043,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 						struct scan_control *sc)
 {
 	unsigned long inactive_ratio;
-	unsigned long inactive;
-	unsigned long active;
+	unsigned long total_inactive, inactive;
+	unsigned long total_active, active;
 	unsigned long gb;
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	int zid;
@@ -2032,8 +2056,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	if (!file && !total_swap_pages)
 		return false;
 
-	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
-	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
+	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
+	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
 
 	/*
 	 * For zone-constrained allocations, it is necessary to check if
@@ -2062,6 +2086,9 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	else
 		inactive_ratio = 1;
 
+	trace_mm_vmscan_inactive_list_is_low(pgdat->node_id,
+			total_inactive, inactive,
+			total_active, active, inactive_ratio, file);
 	return inactive * inactive_ratio < active;
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
