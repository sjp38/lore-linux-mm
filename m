Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 277BC6B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 15:28:59 -0400 (EDT)
Received: by qgep97 with SMTP id p97so142773943qge.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 12:28:58 -0700 (PDT)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id n86si2802215qkh.107.2015.03.27.12.28.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 12:28:57 -0700 (PDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 27 Mar 2015 15:28:57 -0400
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 42F4938C804A
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 15:28:53 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2RJSrAG28639444
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 19:28:53 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2RJSpRt031944
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 15:28:51 -0400
Date: Fri, 27 Mar 2015 12:28:50 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH] mm: vmscan: do not throttle based on pfmemalloc reserves if
 node has no reclaimable zones
Message-ID: <20150327192850.GA18701@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

Based upon 675becce15 ("mm: vmscan: do not throttle based on pfmemalloc
reserves if node has no ZONE_NORMAL") from Mel.

We have a system with the following topology:

(0) root @ br30p03: /root
# numactl -H
available: 3 nodes (0,2-3)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
23 24 25 26 27 28 29 30 31
node 0 size: 28273 MB
node 0 free: 27323 MB
node 2 cpus:
node 2 size: 16384 MB
node 2 free: 0 MB
node 3 cpus: 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
node 3 size: 30533 MB
node 3 free: 13273 MB
node distances:
node   0   2   3 
  0:  10  20  20 
  2:  20  10  20 
  3:  20  20  10 

Node 2 has no free memory, because:

# cat /sys/devices/system/node/node2/hugepages/hugepages-16777216kB/nr_hugepages 
1

This leads to the following zoneinfo:

Node 2, zone      DMA
  pages free     0
        min      1840
        low      2300
        high     2760
        scanned  0
        spanned  262144
        present  262144
        managed  262144
...
  all_unreclaimable: 1

If one then attempts to allocate some normal 16M hugepages:

echo 37 > /proc/sys/vm/nr_hugepages

The echo enver returns and kswapd2 consumes CPU cycles.

This is because throttle_direct_reclaim ends up calling
wait_event(pfmemalloc_wait, pfmemalloc_watermark_ok...).
pfmemalloc_watermark_ok() in turn checks all zones on the node and see
if the there are any reserves, and if so, then indicates the watermarks
are ok, by seeing if there are sufficient free pages.

675becce15 added a condition already for memoryless nodes. In this case,
though, the node has memory, it is just all consumed (and not
recliamable). Effectively, though, the result is the same on this
call to pfmemalloc_watermark_ok() and thus seems like a reasonable
additional condition.

With this change, the afore-mentioned 16M hugepage allocation succeeds
and correctly round-robins between Nodes 1 and 3.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcd90c8..033c2b7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2585,7 +2585,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
        for (i = 0; i <= ZONE_NORMAL; i++) {
                zone = &pgdat->node_zones[i];
-               if (!populated_zone(zone))
+               if (!populated_zone(zone) || !zone_reclaimable(zone))
                        continue;
 
                pfmemalloc_reserve += min_wmark_pages(zone);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
