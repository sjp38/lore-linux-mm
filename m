Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B2EA56B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 14:24:49 -0400 (EDT)
Received: by wizk4 with SMTP id k4so50924102wiz.1
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 11:24:49 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id ex5si4780751wic.96.2015.04.03.11.24.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Apr 2015 11:24:48 -0700 (PDT)
Received: by widjs5 with SMTP id js5so30698308wid.1
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 11:24:47 -0700 (PDT)
Date: Fri, 3 Apr 2015 20:24:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: do not throttle based on pfmemalloc
 reserves if node has no reclaimable pages
Message-ID: <20150403182445.GA31900@dhcp22.suse.cz>
References: <20150327192850.GA18701@linux.vnet.ibm.com>
 <5515BAF7.6070604@intel.com>
 <20150327222350.GA22887@linux.vnet.ibm.com>
 <20150331094829.GE9589@dhcp22.suse.cz>
 <20150403174357.GE32318@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150403174357.GE32318@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On Fri 03-04-15 10:43:57, Nishanth Aravamudan wrote:
> On 31.03.2015 [11:48:29 +0200], Michal Hocko wrote:
[...]
> > I would expect kswapd would be looping endlessly because the zone
> > wouldn't be balanced obviously. But I would be wrong... because
> > pgdat_balanced is doing this:
> > 		/*
> > 		 * A special case here:
> > 		 *
> > 		 * balance_pgdat() skips over all_unreclaimable after
> > 		 * DEF_PRIORITY. Effectively, it considers them balanced so
> > 		 * they must be considered balanced here as well!
> > 		 */
> > 		if (!zone_reclaimable(zone)) {
> > 			balanced_pages += zone->managed_pages;
> > 			continue;
> > 		}
> > 
> > and zone_reclaimable is false for you as you didn't have any
> > zone_reclaimable_pages(). But wakeup_kswapd doesn't do this check so it
> > would see !zone_balanced() AFAICS (build_zonelists doesn't ignore those
> > zones right?) and so the kswapd would be woken up easily. So it looks
> > like a mess.
> 
> My understanding, and I could easily be wrong, is that kswapd2 (node 2
> is the exhausted one) spins endlessly, because the reclaim logic sees
> that we are reclaiming from somewhere but the allocation request for
> node 2 (which is __GFP_THISNODE for hugepages, not GFP_THISNODE) will
> never complete, so we just continue to reclaim.

__GFP_THISNODE would be waking up kswapd2 again and again, that is true.
I am just wondering whether we will have any __GFP_THISNODE allocations
for a node without CPUs (numa_node_id() shouldn't return such a node
AFAICS). Maybe if somebody is bound to Node2 explicitly but I would
consider this as a misconfiguration.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
