Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3746B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 18:09:19 -0400 (EDT)
Received: by iecnq11 with SMTP id nq11so797161iec.3
        for <linux-mm@kvack.org>; Tue, 05 May 2015 15:09:19 -0700 (PDT)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id 7si489368igy.13.2015.05.05.15.09.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 05 May 2015 15:09:18 -0700 (PDT)
Received: from /spool/local
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 5 May 2015 18:09:18 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 184CD6E8045
	for <linux-mm@kvack.org>; Tue,  5 May 2015 18:01:04 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t45M9FTS60555270
	for <linux-mm@kvack.org>; Tue, 5 May 2015 22:09:15 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t45M9EIj006950
	for <linux-mm@kvack.org>; Tue, 5 May 2015 18:09:15 -0400
Date: Tue, 5 May 2015 15:09:13 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm: vmscan: do not throttle based on pfmemalloc
 reserves if node has no reclaimable pages
Message-ID: <20150505220913.GC32719@linux.vnet.ibm.com>
References: <20150327192850.GA18701@linux.vnet.ibm.com>
 <5515BAF7.6070604@intel.com>
 <20150327222350.GA22887@linux.vnet.ibm.com>
 <20150331094829.GE9589@dhcp22.suse.cz>
 <551E47EF.5030800@suse.cz>
 <20150403174556.GF32318@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150403174556.GF32318@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On 03.04.2015 [10:45:56 -0700], Nishanth Aravamudan wrote:
> On 03.04.2015 [09:57:35 +0200], Vlastimil Babka wrote:
> > On 03/31/2015 11:48 AM, Michal Hocko wrote:
> > >On Fri 27-03-15 15:23:50, Nishanth Aravamudan wrote:
> > >>On 27.03.2015 [13:17:59 -0700], Dave Hansen wrote:
> > >>>On 03/27/2015 12:28 PM, Nishanth Aravamudan wrote:
> > >>>>@@ -2585,7 +2585,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
> > >>>>
> > >>>>         for (i = 0; i <= ZONE_NORMAL; i++) {
> > >>>>                 zone = &pgdat->node_zones[i];
> > >>>>-               if (!populated_zone(zone))
> > >>>>+               if (!populated_zone(zone) || !zone_reclaimable(zone))
> > >>>>                         continue;
> > >>>>
> > >>>>                 pfmemalloc_reserve += min_wmark_pages(zone);
> > >>>
> > >>>Do you really want zone_reclaimable()?  Or do you want something more
> > >>>direct like "zone_reclaimable_pages(zone) == 0"?
> > >>
> > >>Yeah, I guess in my testing this worked out to be the same, since
> > >>zone_reclaimable_pages(zone) is 0 and so zone_reclaimable(zone) will
> > >>always be false. Thanks!
> > >>
> > >>Based upon 675becce15 ("mm: vmscan: do not throttle based on pfmemalloc
> > >>reserves if node has no ZONE_NORMAL") from Mel.
> > >>
> > >>We have a system with the following topology:
> > >>
> > >># numactl -H
> > >>available: 3 nodes (0,2-3)
> > >>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
> > >>23 24 25 26 27 28 29 30 31
> > >>node 0 size: 28273 MB
> > >>node 0 free: 27323 MB
> > >>node 2 cpus:
> > >>node 2 size: 16384 MB
> > >>node 2 free: 0 MB
> > >>node 3 cpus: 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
> > >>node 3 size: 30533 MB
> > >>node 3 free: 13273 MB
> > >>node distances:
> > >>node   0   2   3
> > >>   0:  10  20  20
> > >>   2:  20  10  20
> > >>   3:  20  20  10
> > >>
> > >>Node 2 has no free memory, because:
> > >># cat /sys/devices/system/node/node2/hugepages/hugepages-16777216kB/nr_hugepages
> > >>1
> > >>
> > >>This leads to the following zoneinfo:
> > >>
> > >>Node 2, zone      DMA
> > >>   pages free     0
> > >>         min      1840
> > >>         low      2300
> > >>         high     2760
> > >>         scanned  0
> > >>         spanned  262144
> > >>         present  262144
> > >>         managed  262144
> > >>...
> > >>   all_unreclaimable: 1
> > >
> > >Blee, this is a weird configuration.
> > >
> > >>If one then attempts to allocate some normal 16M hugepages via
> > >>
> > >>echo 37 > /proc/sys/vm/nr_hugepages
> > >>
> > >>The echo never returns and kswapd2 consumes CPU cycles.
> > >>
> > >>This is because throttle_direct_reclaim ends up calling
> > >>wait_event(pfmemalloc_wait, pfmemalloc_watermark_ok...).
> > >>pfmemalloc_watermark_ok() in turn checks all zones on the node if there
> > >>are any reserves, and if so, then indicates the watermarks are ok, by
> > >>seeing if there are sufficient free pages.
> > >>
> > >>675becce15 added a condition already for memoryless nodes. In this case,
> > >>though, the node has memory, it is just all consumed (and not
> > >>reclaimable). Effectively, though, the result is the same on this call
> > >>to pfmemalloc_watermark_ok() and thus seems like a reasonable additional
> > >>condition.
> > >>
> > >>With this change, the afore-mentioned 16M hugepage allocation attempt
> > >>succeeds and correctly round-robins between Nodes 1 and 3.
> > >
> > >I am just wondering whether this is the right/complete fix. Don't we
> > >need a similar treatment at more places?
> > >I would expect kswapd would be looping endlessly because the zone
> > >wouldn't be balanced obviously. But I would be wrong... because
> > >pgdat_balanced is doing this:
> > >		/*
> > >		 * A special case here:
> > >		 *
> > >		 * balance_pgdat() skips over all_unreclaimable after
> > >		 * DEF_PRIORITY. Effectively, it considers them balanced so
> > >		 * they must be considered balanced here as well!
> > >		 */
> > >		if (!zone_reclaimable(zone)) {
> > >			balanced_pages += zone->managed_pages;
> > >			continue;
> > >		}
> > >
> > >and zone_reclaimable is false for you as you didn't have any
> > >zone_reclaimable_pages(). But wakeup_kswapd doesn't do this check so it
> > >would see !zone_balanced() AFAICS (build_zonelists doesn't ignore those
> > >zones right?) and so the kswapd would be woken up easily. So it looks
> > >like a mess.
> > 
> > Yeah, looks like a much cleaner/complete solution would be to remove
> > such zones from zonelists. But that means covering all situations
> > when these hugepages are allocated/removed and the approach then
> > looks similar to memory hotplug.
> > Also I'm not sure if the ability to actually allocate the reserved
> > hugepage would be impossible due to not being reachable by a
> > zonelist...
> > 
> > >There are possibly other places which rely on populated_zone or
> > >for_each_populated_zone without checking reclaimability. Are those
> > >working as expected?
> > 
> > Yeah. At least the wakeup_kswapd case should be fixed IMHO. No point
> > in waking it up just to let it immediately go to sleep again.
> > 
> > >That being said. I am not objecting to this patch. I am just trying to
> > >wrap my head around possible issues from such a weird configuration and
> > >all the consequences.
> > >
> > >>Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> > >
> > >The patch as is doesn't seem to be harmful.
> > >
> > >Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > >
> > >>---
> > >>v1 -> v2:
> > >>   Check against zone_reclaimable_pages, rather zone_reclaimable, based
> > >>   upon feedback from Dave Hansen.
> > >
> > >Dunno, but shouldn't we use the same thing here and in pgdat_balanced?
> > >zone_reclaimable_pages seems to be used only from zone_reclaimable().
> > 
> > pgdat_balanced() has a different goal than pfmemalloc_watermark_ok()
> > and needs to match what balance_pgdat() does, which includes
> > considering NR_PAGES_SCANNED through zone_reclaimable(). For the
> > situation considered in this patch, result of zone_reclaimable()
> > will match the test zone_reclaimable_pages(zone) == 0, so it is fine
> > I think.
> 
> Right.
> 
> > What I find somewhat worrying though is that we could potentially
> > break the pfmemalloc_watermark_ok() test in situations where
> > zone_reclaimable_pages(zone) == 0 is a transient situation (and not
> > a permanently allocated hugepage). In that case, the throttling is
> > supposed to help system recover, and we might be breaking that
> > ability with this patch, no?
> 
> Well, if it's transient, we'll skip it this time through, and once there
> are reclaimable pages, we should notice it again.
> 
> I'm not familiar enough with this logic, so I'll read through the code
> again soon to see if your concern is valid, as best I can.

In reviewing the code, I think that transiently unreclaimable zones will
lead to some higher direct reclaim rates and possible contention, but
shouldn't cause any major harm. The likelihood of that situation, as
well, in a non-reserved memory setup like the one I described, seems
exceedingly low.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
