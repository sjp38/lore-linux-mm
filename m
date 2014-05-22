Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1F16B0037
	for <linux-mm@kvack.org>; Thu, 22 May 2014 05:09:47 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so2371691eek.35
        for <linux-mm@kvack.org>; Thu, 22 May 2014 02:09:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si14002405eeo.84.2014.05.22.02.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 02:09:46 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] mm: vmscan: Use proportional scanning during direct reclaim and full scan at DEF_PRIORITY
Date: Thu, 22 May 2014 10:09:39 +0100
Message-Id: <1400749779-24879-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1400749779-24879-1-git-send-email-mgorman@suse.de>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Dave@kvack.org, "Chinner <david"@fromorbit.com, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

Commit "mm: vmscan: obey proportional scanning requirements for kswapd"
ensured that file/anon lists were scanned proportionally for reclaim from
kswapd but ignored it for direct reclaim. The intent was to minimse direct
reclaim latency but Yuanhan Liu pointer out that it substitutes one long
stall for many small stalls and distorts aging for normal workloads like
streaming readers/writers.  Hugh Dickins pointed out that a side-effect of
the same commit was that when one LRU list dropped to zero that the entirety
of the other list was shrunk leading to excessive reclaim in memcgs.
This patch scans the file/anon lists proportionally for direct reclaim
to similarly age page whether reclaimed by kswapd or direct reclaim but
takes care to abort reclaim if one LRU drops to zero after reclaiming the
requested number of pages.

Based on ext4 and using the Intel VM scalability test

                                              3.15.0-rc5            3.15.0-rc5
                                                shrinker            proportion
Unit  lru-file-readonce    elapsed      5.3500 (  0.00%)      5.4200 ( -1.31%)
Unit  lru-file-readonce time_range      0.2700 (  0.00%)      0.1400 ( 48.15%)
Unit  lru-file-readonce time_stddv      0.1148 (  0.00%)      0.0536 ( 53.33%)
Unit lru-file-readtwice    elapsed      8.1700 (  0.00%)      8.1700 (  0.00%)
Unit lru-file-readtwice time_range      0.4300 (  0.00%)      0.2300 ( 46.51%)
Unit lru-file-readtwice time_stddv      0.1650 (  0.00%)      0.0971 ( 41.16%)

The test cases are running multiple dd instances reading sparse files. The results are within
the noise for the small test machine. The impact of the patch is more noticable from the vmstats

                            3.15.0-rc5  3.15.0-rc5
                              shrinker  proportion
Minor Faults                     35154       36784
Major Faults                       611        1305
Swap Ins                           394        1651
Swap Outs                         4394        5891
Allocation stalls               118616       44781
Direct pages scanned           4935171     4602313
Kswapd pages scanned          15921292    16258483
Kswapd pages reclaimed        15913301    16248305
Direct pages reclaimed         4933368     4601133
Kswapd efficiency                  99%         99%
Kswapd velocity             670088.047  682555.961
Direct efficiency                  99%         99%
Direct velocity             207709.217  193212.133
Percentage direct scans            23%         22%
Page writes by reclaim        4858.000    6232.000
Page writes file                   464         341
Page writes anon                  4394        5891

Note that there are fewer allocation stalls even though the amount
of direct reclaim scanning is very approximately the same.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 32c661d..9d2dfe5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2037,13 +2037,27 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
-	bool scan_adjusted = false;
+	bool scan_adjusted;
 
 	get_scan_count(lruvec, sc, nr);
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
 
+	/*
+	 * Global reclaiming within direct reclaim at DEF_PRIORITY is a normal
+	 * event that can occur when there is little memory pressure e.g.
+	 * multiple streaming readers/writers. Hence, we do not abort scanning
+	 * when the requested number of pages are reclaimed when scanning at
+	 * DEF_PRIORITY on the assumption that the fact we are direct
+	 * reclaiming implies that kswapd is not keeping up and it is best to
+	 * do a batch of work at once. For memcg reclaim one check is made to
+	 * abort proportional reclaim if either the file or anon lru has already
+	 * dropped to zero at the first pass.
+	 */
+	scan_adjusted = (global_reclaim(sc) && !current_is_kswapd() &&
+			 sc->priority == DEF_PRIORITY);
+
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
@@ -2064,17 +2078,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 			continue;
 
 		/*
-		 * For global direct reclaim, reclaim only the number of pages
-		 * requested. Less care is taken to scan proportionally as it
-		 * is more important to minimise direct reclaim stall latency
-		 * than it is to properly age the LRU lists.
-		 */
-		if (global_reclaim(sc) && !current_is_kswapd())
-			break;
-
-		/*
 		 * For kswapd and memcg, reclaim at least the number of pages
-		 * requested. Ensure that the anon and file LRUs shrink
+		 * requested. Ensure that the anon and file LRUs are scanned
 		 * proportionally what was requested by get_scan_count(). We
 		 * stop reclaiming one LRU and reduce the amount scanning
 		 * proportional to the original scan target.
@@ -2082,6 +2087,15 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
 		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
 
+		/*
+		 * It's just vindictive to attack the larger once the smaller
+		 * has gone to zero.  And given the way we stop scanning the
+		 * smaller below, this makes sure that we only make one nudge
+		 * towards proportionality once we've got nr_to_reclaim.
+		 */
+		if (!nr_file || !nr_anon)
+			break;
+
 		if (nr_file > nr_anon) {
 			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
 						targets[LRU_ACTIVE_ANON] + 1;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
