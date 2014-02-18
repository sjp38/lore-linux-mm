Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id F19C76B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 02:59:59 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so16443021pab.38
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 23:59:59 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id vw10si17406533pbc.137.2014.02.17.23.59.58
        for <linux-mm@kvack.org>;
        Mon, 17 Feb 2014 23:59:58 -0800 (PST)
Date: Tue, 18 Feb 2014 16:01:22 +0800
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: performance regression due to commit e82e0561("mm: vmscan: obey
 proportional scanning requirements for kswapd")
Message-ID: <20140218080122.GO26593@yliu-dev.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Commit e82e0561("mm: vmscan: obey proportional scanning requirements for
kswapd") caused a big performance regression(73%) for vm-scalability/
lru-file-readonce testcase on a system with 256G memory without swap.

That testcase simply looks like this:
     truncate -s 1T /tmp/vm-scalability.img
     mkfs.xfs -q /tmp/vm-scalability.img
     mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability

     SPARESE_FILE="/tmp/vm-scalability/sparse-lru-file-readonce"
     for i in `seq 1 120`; do
         truncate $SPARESE_FILE-$i -s 36G
         timeout --foreground -s INT 300 dd bs=4k if=$SPARESE_FILE-$i of=/dev/null
     done

     wait

Actually, it's not the newlly added code(obey proportional scanning)
in that commit caused the regression. But instead, it's the following
change:
+
+               if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
+                       continue;
+


-               if (nr_reclaimed >= nr_to_reclaim &&
-                   sc->priority < DEF_PRIORITY)
+               if (global_reclaim(sc) && !current_is_kswapd())
                        break;

The difference is that we might reclaim more than requested before
in the first round reclaimming(sc->priority == DEF_PRIORITY).

So, for a testcase like lru-file-readonce, the dirty rate is fast, and
reclaimming SWAP_CLUSTER_MAX(32 pages) each time is not enough for catching
up the dirty rate. And thus page allocation stalls, and performance drops:

   O for e82e0561
   * for parent commit

                                proc-vmstat.allocstall

     2e+06 ++---------------------------------------------------------------+
   1.8e+06 O+              O                O               O               |
           |                                                                |
   1.6e+06 ++                                                               |
   1.4e+06 ++                                                               |
           |                                                                |
   1.2e+06 ++                                                               |
     1e+06 ++                                                               |
    800000 ++                                                               |
           |                                                                |
    600000 ++                                                               |
    400000 ++                                                               |
           |                                                                |
    200000 *+..............*................*...............*...............*
         0 ++---------------------------------------------------------------+

                               vm-scalability.throughput

   2.2e+07 ++---------------------------------------------------------------+
           |                                                                |
     2e+07 *+..............*................*...............*...............*
   1.8e+07 ++                                                               |
           |                                                                |
   1.6e+07 ++                                                               |
           |                                                                |
   1.4e+07 ++                                                               |
           |                                                                |
   1.2e+07 ++                                                               |
     1e+07 ++                                                               |
           |                                                                |
     8e+06 ++              O                O               O               |
           O                                                                |
     6e+06 ++---------------------------------------------------------------+

I made a patch which simply keeps reclaimming more if sc->priority == DEF_PRIORITY.
I'm not sure it's the right way to go or not. Anyway, I pasted it here for comments.

---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 26ad67f..37004a8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1828,7 +1828,16 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
-	bool scan_adjusted = false;
+	/*
+	 * On large memory systems, direct reclamming of SWAP_CLUSTER_MAX
+	 * each time may not catch up the dirty rate in some cases(say,
+	 * vm-scalability/lru-file-readonce), which may increase the
+	 * page allocation stall latency in the end.
+	 *
+	 * Here we try to reclaim more than requested for the first round
+	 * (sc->priority == DEF_PRIORITY) to reduce such latency.
+	 */
+	bool scan_adjusted = sc->priority == DEF_PRIORITY;
 
 	get_scan_count(lruvec, sc, nr);
 
-- 
1.7.7.6


	--yliu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
