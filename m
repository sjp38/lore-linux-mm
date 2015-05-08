Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 697236B0071
	for <linux-mm@kvack.org>; Fri,  8 May 2015 18:47:28 -0400 (EDT)
Received: by pdea3 with SMTP id a3so100310419pde.3
        for <linux-mm@kvack.org>; Fri, 08 May 2015 15:47:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d3si8848440pas.13.2015.05.08.15.47.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 15:47:27 -0700 (PDT)
Date: Fri, 8 May 2015 15:47:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: vmscan: do not throttle based on pfmemalloc
 reserves if node has no reclaimable pages
Message-Id: <20150508154726.9969933e6b5ebbb42e65ffae@linux-foundation.org>
In-Reply-To: <5549DEAC.6080709@suse.cz>
References: <20150327192850.GA18701@linux.vnet.ibm.com>
	<5515BAF7.6070604@intel.com>
	<20150327222350.GA22887@linux.vnet.ibm.com>
	<20150331094829.GE9589@dhcp22.suse.cz>
	<551E47EF.5030800@suse.cz>
	<20150403174556.GF32318@linux.vnet.ibm.com>
	<20150505220913.GC32719@linux.vnet.ibm.com>
	<5549DEAC.6080709@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On Wed, 06 May 2015 11:28:12 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 05/06/2015 12:09 AM, Nishanth Aravamudan wrote:
> > On 03.04.2015 [10:45:56 -0700], Nishanth Aravamudan wrote:
> >>> What I find somewhat worrying though is that we could potentially
> >>> break the pfmemalloc_watermark_ok() test in situations where
> >>> zone_reclaimable_pages(zone) == 0 is a transient situation (and not
> >>> a permanently allocated hugepage). In that case, the throttling is
> >>> supposed to help system recover, and we might be breaking that
> >>> ability with this patch, no?
> >>
> >> Well, if it's transient, we'll skip it this time through, and once there
> >> are reclaimable pages, we should notice it again.
> >>
> >> I'm not familiar enough with this logic, so I'll read through the code
> >> again soon to see if your concern is valid, as best I can.
> >
> > In reviewing the code, I think that transiently unreclaimable zones will
> > lead to some higher direct reclaim rates and possible contention, but
> > shouldn't cause any major harm. The likelihood of that situation, as
> > well, in a non-reserved memory setup like the one I described, seems
> > exceedingly low.
> 
> OK, I guess when a reasonably configured system has nothing to reclaim, 
> it's already busted and throttling won't change much.
> 
> Consider the patch Acked-by: Vlastimil Babka <vbabka@suse.cz>

OK, thanks, I'll move this patch into the queue for 4.2-rc1.

Or is it important enough to merge into 4.1?



From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: mm: vmscan: do not throttle based on pfmemalloc reserves if node has no reclaimable pages

Based upon 675becce15 ("mm: vmscan: do not throttle based on pfmemalloc
reserves if node has no ZONE_NORMAL") from Mel.

We have a system with the following topology:

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

If one then attempts to allocate some normal 16M hugepages via

echo 37 > /proc/sys/vm/nr_hugepages

The echo never returns and kswapd2 consumes CPU cycles.

This is because throttle_direct_reclaim ends up calling
wait_event(pfmemalloc_wait, pfmemalloc_watermark_ok...). 
pfmemalloc_watermark_ok() in turn checks all zones on the node if there
are any reserves, and if so, then indicates the watermarks are ok, by
seeing if there are sufficient free pages.

675becce15 added a condition already for memoryless nodes.  In this case,
though, the node has memory, it is just all consumed (and not
reclaimable).  Effectively, though, the result is the same on this call to
pfmemalloc_watermark_ok() and thus seems like a reasonable additional
condition.

With this change, the afore-mentioned 16M hugepage allocation attempt
succeeds and correctly round-robins between Nodes 1 and 3.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Anton Blanchard <anton@samba.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Streetman <ddstreet@ieee.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN mm/vmscan.c~mm-vmscan-do-not-throttle-based-on-pfmemalloc-reserves-if-node-has-no-reclaimable-pages mm/vmscan.c
--- a/mm/vmscan.c~mm-vmscan-do-not-throttle-based-on-pfmemalloc-reserves-if-node-has-no-reclaimable-pages
+++ a/mm/vmscan.c
@@ -2646,7 +2646,8 @@ static bool pfmemalloc_watermark_ok(pg_d
 
 	for (i = 0; i <= ZONE_NORMAL; i++) {
 		zone = &pgdat->node_zones[i];
-		if (!populated_zone(zone))
+		if (!populated_zone(zone) ||
+		    zone_reclaimable_pages(zone) == 0)
 			continue;
 
 		pfmemalloc_reserve += min_wmark_pages(zone);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
