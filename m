Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DD4856B0022
	for <linux-mm@kvack.org>; Mon, 23 May 2011 06:44:55 -0400 (EDT)
Date: Mon, 23 May 2011 11:44:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 35512] New: firefox hang, congestion_wait
Message-ID: <20110523104447.GK4743@csn.ul.ie>
References: <bug-35512-10286@https.bugzilla.kernel.org/>
 <20110520125147.a8baa51a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110520125147.a8baa51a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, urykhy@gmail.com

On Fri, May 20, 2011 at 12:51:47PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Fri, 20 May 2011 19:45:43 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=35512
> > 
> >            Summary: firefox hang, congestion_wait
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.39
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: urykhy@gmail.com
> >         Regression: No
> > 
> > 
> > Created an attachment (id=58822)
> >  --> (https://bugzilla.kernel.org/attachment.cgi?id=58822)
> > kernel config
> > 
> > some times FF is hang for a long time (10..20.. and more seconds)
> > 

Well.... that is unacceptable.

> > vmstat:
> > $vmstat 1
> > procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
> >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
> >  0  2   1232  82508     40 503448    0    0    46    21  505 1148 15  9 66  9
> >  1  2   1232  82384     40 503416    0    0     0     0  320 1424  9  5  0 86
> >  0  2   1232  82384     40 503416    0    0     0     0  358  716  3  2  0 95
> >  0  2   1232  82384     40 503416    0    0     0     8  705  692  3  6  0 91
> >  1  2   1232  82260     40 503652    0    0   236     0  728  763  2  2  0 96
> >  0  2   1232  82260     40 503652    0    0     0     0  459  620  3  1  0 96
> >  0  2   1232  82260     40 503652    0    0     0     0  249  642  2  2  0 96
> >  0  2   1232  82260     40 503652    0    0     0     0  250  662  2  3  0 95
> >  0  2   1232  82260     40 503652    0    0     0     0  267  667  2  4  0 94
> >  0  2   1232  82260     40 503652    0    0     0    16  285  707  3  1  0 96
> >  0  2   1232  82260     40 503652    0    0     0     0  259  691  3  3  0 94
> >  0  2   1232  82260     40 503652    0    0     0     0  254  623  2  4  0 94
> >  0  2   1232  83128     40 502576    0    0     0     0  344 1473  4 10  0 86
> > 
> > $iostat -x 1
> > avg-cpu:  %user   %nice %system %iowait  %steal   %idle
> >            4,04    0,00    9,09   86,87    0,00    0,00
> > 
> > Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz
> > avgqu-sz   await  svctm  %util
> > hda               0,00     0,00    0,00    0,00     0,00     0,00     0,00    
> > 0,00    0,00   0,00   0,00
> > dm-0              0,00     0,00    0,00    0,00     0,00     0,00     0,00    
> > 0,00    0,00   0,00   0,00
> > sda               0,00     0,00    0,00    0,00     0,00     0,00     0,00    
> > 0,00    0,00   0,00   0,00
> > dm-1              0,00     0,00    0,00    0,00     0,00     0,00     0,00    
> > 0,00    0,00   0,00   0,00
> > 
> > stack:
> > $cat /proc/4014/stack
> > [<c108ad00>] congestion_wait+0x5a/0xae
> > [<c109ba1b>] compact_zone+0xd6/0x583
> > [<c109bfc3>] compact_zone_order+0x88/0x90
> > [<c109c040>] try_to_compact_pages+0x75/0xc1
> > [<c107ef34>] __alloc_pages_direct_compact+0x6d/0x101
> > [<c107f2ee>] __alloc_pages_nodemask+0x326/0x5db
> > [<c10a2ca1>] do_huge_pmd_anonymous_page+0xb4/0x293
> > [<c108f6c6>] handle_mm_fault+0x72/0x129
> > [<c10195e9>] do_page_fault+0x32e/0x346
> > [<c12b1a09>] error_code+0x5d/0x64
> > [<ffffffff>] 0xffffffff
> > 

It's obviously not true congestion then with that output of iostat
and vmstat.

> > meminfo:
> > $cat /proc/meminfo 
> > MemTotal:        1271456 kB
> > MemFree:          117988 kB
> > Buffers:              40 kB
> > Cached:           472048 kB
> > SwapCached:          480 kB
> > Active:           514172 kB
> > Inactive:         531052 kB
> > Active(anon):     329116 kB
> > Inactive(anon):   347324 kB
> > Active(file):     185056 kB
> > Inactive(file):   183728 kB
> > Unevictable:           4 kB
> > Mlocked:               4 kB
> > HighTotal:        384968 kB
> > HighFree:          14476 kB
> > LowTotal:         886488 kB
> > LowFree:          103512 kB
> > SwapTotal:       1023996 kB
> > SwapFree:        1019724 kB
> > Dirty:                 4 kB
> > Writeback:             0 kB
> > AnonPages:        572684 kB
> > Mapped:            82244 kB
> > Shmem:            103304 kB
> > Slab:              45156 kB
> > SReclaimable:      27256 kB
> > SUnreclaim:        17900 kB
> > KernelStack:        2160 kB
> > PageTables:         3956 kB
> > NFS_Unstable:          0 kB
> > Bounce:                0 kB
> > WritebackTmp:          0 kB
> > CommitLimit:     1659724 kB
> > Committed_AS:    1343792 kB
> > VmallocTotal:     122880 kB
> > VmallocUsed:        8004 kB
> > VmallocChunk:      89032 kB
> > AnonHugePages:    110592 kB
> > DirectMap4k:       24568 kB
> > DirectMap4M:      884736 kB
> > 

/proc/vmstat at the time of the hang if you can but it's not critical.

I think what is happening here is that there are a number of allocations
in direct compaction trying to promote pages to huge pages. When too
many pages are isolated, processes stall waiting for others to complete.
This is the wrong decision because it should simply fail the hugepage
promotion.

There are two things I'd like to see tested please.

1. Can you try patch below please? It's untested unfortunately but is a
   combination of three patches. Two related to reclaim which I do not
   think are the problem but would like to see tested just in case.
   The third patch to compaction is unreleased but causes compaction to
   abort if too many pages are isolated and the caller is asynchronous
   which it will be in your call trace above.

2. Can a test be tried with booting with slub_maxorder=1 and retesting
   *without* the patch? I am wondering if the problem is SLUB and
   THP are both isolating too many pages and competing with each
   other. This is to satisfy my own curiousity only as slub_maxorder=1
   is not a long-term fix for anything. If this is difficult to
   reproduce or time is constrained, do not bother.

Here is the patch I'd like to see tested. Thanks.

diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..331a2ee 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -240,11 +240,20 @@ static bool too_many_isolated(struct zone *zone)
 	return isolated > (inactive + active) / 2;
 }
 
+/* possible outcome of isolate_migratepages */
+typedef enum {
+	ISOLATE_ABORT,		/* Abort compaction now */
+	ISOLATE_NONE,		/* No pages isolated, continue scanning */
+	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
+} isolate_migrate_t;
+
 /*
  * Isolate all pages that can be migrated from the block pointed to by
  * the migrate scanner within compact_control.
+ *
+ * Returns false if compaction should abort at this point due to congestion.
  */
-static unsigned long isolate_migratepages(struct zone *zone,
+static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
@@ -261,7 +270,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	/* Do not cross the free scanner or scan within a memory hole */
 	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
 		cc->migrate_pfn = end_pfn;
-		return 0;
+		return ISOLATE_NONE;
 	}
 
 	/*
@@ -270,10 +279,14 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	 * delay for some time until fewer pages are isolated
 	 */
 	while (unlikely(too_many_isolated(zone))) {
+		/* async migration should just abort */
+		if (!cc->sync)
+			return ISOLATE_ABORT;
+
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		if (fatal_signal_pending(current))
-			return 0;
+			return ISOLATE_ABORT;
 	}
 
 	/* Time to isolate some pages for migration */
@@ -358,7 +371,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
-	return cc->nr_migratepages;
+	return ISOLATE_SUCCESS;
 }
 
 /*
@@ -522,9 +535,15 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		unsigned long nr_migrate, nr_remaining;
 		int err;
 
-		if (!isolate_migratepages(zone, cc))
+		switch (isolate_migratepages(zone, cc)) {
+		case ISOLATE_ABORT:
+			goto out;
+		case ISOLATE_NONE:
 			continue;
-
+		case ISOLATE_SUCCESS:
+			;
+		}
+		
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				(unsigned long)cc, false,
@@ -547,6 +566,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	}
 
+out:
 	/* Release free pages and check accounting */
 	cc->nr_freepages -= release_freepages(&cc->freepages);
 	VM_BUG_ON(cc->nr_freepages != 0);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8bfd450..cc1470b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -230,8 +230,11 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
 
-	if (!down_read_trylock(&shrinker_rwsem))
-		return 1;	/* Assume we'll be able to shrink next time */
+	if (!down_read_trylock(&shrinker_rwsem)) {
+		/* Assume we'll be able to shrink next time */
+		ret = 1;
+		goto out;
+	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
@@ -282,6 +285,8 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
+out:
+	cond_resched();
 	return ret;
 }
 
@@ -2286,7 +2291,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 	 * must be balanced
 	 */
 	if (order)
-		return pgdat_balanced(pgdat, balanced, classzone_idx);
+		return !pgdat_balanced(pgdat, balanced, classzone_idx);
 	else
 		return !all_zones_ok;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
