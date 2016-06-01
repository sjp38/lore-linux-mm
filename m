Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7CF6B0253
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 11:45:49 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id j12so11844181lbo.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:45:49 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id f66si21482137wma.11.2016.06.01.08.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 08:45:48 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so7965702wmg.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:45:48 -0700 (PDT)
Date: Wed, 1 Jun 2016 17:45:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 18/18] mm, vmscan: use proper classzone_idx in
 should_continue_reclaim()
Message-ID: <20160601154546.GZ26601@dhcp22.suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
 <20160531130818.28724-19-vbabka@suse.cz>
 <20160601142138.GX26601@dhcp22.suse.cz>
 <574EFCFE.1000903@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <574EFCFE.1000903@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Wed 01-06-16 17:19:26, Vlastimil Babka wrote:
> On 06/01/2016 04:21 PM, Michal Hocko wrote:
> > On Tue 31-05-16 15:08:18, Vlastimil Babka wrote:
> > [...]
> >> @@ -2364,11 +2350,12 @@ static inline bool should_continue_reclaim(struct zone *zone,
> >>  }
> >>  
> >>  static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> >> -			bool is_classzone)
> >> +			int classzone_idx)
> >>  {
> >>  	struct reclaim_state *reclaim_state = current->reclaim_state;
> >>  	unsigned long nr_reclaimed, nr_scanned;
> >>  	bool reclaimable = false;
> >> +	bool is_classzone = (classzone_idx == zone_idx(zone));
> >>  
> >>  	do {
> >>  		struct mem_cgroup *root = sc->target_mem_cgroup;
> >> @@ -2450,7 +2437,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> >>  			reclaimable = true;
> >>  
> >>  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
> >> -					 sc->nr_scanned - nr_scanned, sc));
> >> +			 sc->nr_scanned - nr_scanned, sc, classzone_idx));
> >>  
> >>  	return reclaimable;
> >>  }
> >> @@ -2580,7 +2567,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >>  			/* need some check for avoid more shrink_zone() */
> >>  		}
> >>  
> >> -		shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
> >> +		shrink_zone(zone, sc, classzone_idx);
> > 
> > this should be is_classzone, right?
> 
> No, this is shrink_zones() context, not shrink_zone().

Ohh, right. They read to similar. I didn't spot anything else.

Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
