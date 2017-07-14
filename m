Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9590440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 06:51:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w4so6650572wrb.13
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 03:51:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si5972174wrb.115.2017.07.14.03.51.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 03:51:08 -0700 (PDT)
Date: Fri, 14 Jul 2017 12:51:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
Message-ID: <20170714105106.GF2618@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-7-mhocko@kernel.org>
 <20170714095534.53hpbi6uaszbtx5h@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714095534.53hpbi6uaszbtx5h@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri 14-07-17 10:55:34, Mel Gorman wrote:
> On Fri, Jul 14, 2017 at 10:00:03AM +0200, Michal Hocko wrote:
> >  
> >  	zonelist = &pgdat->node_zonelists[ZONELIST_NOFALLBACK];
> > -	j = build_zonelists_node(pgdat, zonelist, 0);
> > -	zonelist->_zonerefs[j].zone = NULL;
> > -	zonelist->_zonerefs[j].zone_idx = 0;
> > +	zoneref_idx = build_zonelists_node(pgdat, zonelist, zoneref_idx);
> > +	zonelist->_zonerefs[zoneref_idx].zone = NULL;
> > +	zonelist->_zonerefs[zoneref_idx].zone_idx = 0;
> >  }
> >  
> >  /*
> > @@ -4946,21 +4949,13 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
> >   * exhausted, but results in overflowing to remote node while memory
> >   * may still exist in local DMA zone.
> >   */
> > -static int node_order[MAX_NUMNODES];
> >  
> >  static void build_zonelists(pg_data_t *pgdat)
> >  {
> > -	int i, node, load;
> > +	static int node_order[MAX_NUMNODES];
> > +	int node, load, i = 0;
> 
> Emm, node_order can be large. The first distro config I checked
> indicated that this is 8K. I got hung up on that part and didn't look
> closely at the rest of the patch.

yes, that's why I kept it static. I just placed it into the function to
make it clear what the scope is.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
