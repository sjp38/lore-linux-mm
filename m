Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id D18FD6B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 14:50:45 -0400 (EDT)
Received: by ierf6 with SMTP id f6so96213084ier.2
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 11:50:45 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id d197si7847670ioe.54.2015.04.03.11.50.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Apr 2015 11:50:45 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 3 Apr 2015 12:50:44 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 230A119D8040
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 12:41:48 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t33Iogj634013288
	for <linux-mm@kvack.org>; Fri, 3 Apr 2015 11:50:42 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t33IofVm031145
	for <linux-mm@kvack.org>; Fri, 3 Apr 2015 12:50:42 -0600
Date: Fri, 3 Apr 2015 11:50:39 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm: vmscan: do not throttle based on pfmemalloc
 reserves if node has no reclaimable pages
Message-ID: <20150403185039.GB38424@linux.vnet.ibm.com>
References: <20150327192850.GA18701@linux.vnet.ibm.com>
 <5515BAF7.6070604@intel.com>
 <20150327222350.GA22887@linux.vnet.ibm.com>
 <20150331094829.GE9589@dhcp22.suse.cz>
 <20150403174357.GE32318@linux.vnet.ibm.com>
 <20150403182445.GA31900@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150403182445.GA31900@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On 03.04.2015 [20:24:45 +0200], Michal Hocko wrote:
> On Fri 03-04-15 10:43:57, Nishanth Aravamudan wrote:
> > On 31.03.2015 [11:48:29 +0200], Michal Hocko wrote:
> [...]
> > > I would expect kswapd would be looping endlessly because the zone
> > > wouldn't be balanced obviously. But I would be wrong... because
> > > pgdat_balanced is doing this:
> > > 		/*
> > > 		 * A special case here:
> > > 		 *
> > > 		 * balance_pgdat() skips over all_unreclaimable after
> > > 		 * DEF_PRIORITY. Effectively, it considers them balanced so
> > > 		 * they must be considered balanced here as well!
> > > 		 */
> > > 		if (!zone_reclaimable(zone)) {
> > > 			balanced_pages += zone->managed_pages;
> > > 			continue;
> > > 		}
> > > 
> > > and zone_reclaimable is false for you as you didn't have any
> > > zone_reclaimable_pages(). But wakeup_kswapd doesn't do this check so it
> > > would see !zone_balanced() AFAICS (build_zonelists doesn't ignore those
> > > zones right?) and so the kswapd would be woken up easily. So it looks
> > > like a mess.
> > 
> > My understanding, and I could easily be wrong, is that kswapd2 (node 2
> > is the exhausted one) spins endlessly, because the reclaim logic sees
> > that we are reclaiming from somewhere but the allocation request for
> > node 2 (which is __GFP_THISNODE for hugepages, not GFP_THISNODE) will
> > never complete, so we just continue to reclaim.
> 
> __GFP_THISNODE would be waking up kswapd2 again and again, that is true.

Right, one idea I had for this was ensuring that we perform reclaim with
somehow some knowledge of __GFP_THISNODE -- that is it needs to be
somewhat targetted in order to actually help satisfy the current
allocation. But it got pretty hairy fast and I didn't want to break the
world :)

> I am just wondering whether we will have any __GFP_THISNODE allocations
> for a node without CPUs (numa_node_id() shouldn't return such a node
> AFAICS). Maybe if somebody is bound to Node2 explicitly but I would
> consider this as a misconfiguration.

Right, I'd need to check what happens if in our setup you taskset to
node2 and tried to force memory to be local -- I think you'd either be
killed immediately, or the kernel will just disagree with your binding
since it's invalid (e.g., that will happen if you try to bind to a
memoryless node, I think).

Keep in mind that although in my config node2 had no CPUs, that's not a
hard & fast requirement. I do believe in a previous iteration of this
bug, the exhausted node had no free memory but did have cpus assigned to
it.

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
