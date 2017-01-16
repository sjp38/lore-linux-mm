Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4896B0069
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:29:59 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d140so26986776wmd.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 01:29:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 82si6991399wmo.19.2017.01.16.01.29.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 01:29:58 -0800 (PST)
Date: Mon, 16 Jan 2017 10:29:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: consider eligible zones in
 get_scan_count
Message-ID: <20170116092956.GC13641@dhcp22.suse.cz>
References: <20170110125552.4170-1-mhocko@kernel.org>
 <20170110125552.4170-2-mhocko@kernel.org>
 <20170114161236.GB26139@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114161236.GB26139@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat 14-01-17 11:12:36, Johannes Weiner wrote:
> On Tue, Jan 10, 2017 at 01:55:51PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > get_scan_count considers the whole node LRU size when
> > - doing SCAN_FILE due to many page cache inactive pages
> > - calculating the number of pages to scan
> > 
> > in both cases this might lead to unexpected behavior especially on 32b
> > systems where we can expect lowmem memory pressure very often.
> 
> The amount of retrofitting zones back into reclaim is disappointing :/

Agreed
 
> >  /*
> > + * Return the number of pages on the given lru which are eligible for the
> > + * given zone_idx
> > + */
> > +static unsigned long lruvec_lru_size_eligibe_zones(struct lruvec *lruvec,
> > +		enum lru_list lru, int zone_idx)
> > +{
> > +	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> > +	unsigned long lru_size;
> > +	int zid;
> > +
> > +	lru_size = lruvec_lru_size(lruvec, lru);
> > +	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
> > +		struct zone *zone = &pgdat->node_zones[zid];
> > +		unsigned long size;
> > +
> > +		if (!managed_zone(zone))
> > +			continue;
> > +
> > +		size = lruvec_zone_lru_size(lruvec, lru, zid);
> > +		lru_size -= min(size, lru_size);
> > +	}
> > +
> > +	return lru_size;
> 
> The only other use of lruvec_lru_size() is also in get_scan_count(),
> where it decays the LRU pressure balancing ratios. That caller wants
> to operate on the entire lruvec.
> 
> Can you instead add the filtering logic to lruvec_lru_size() directly,
> and pass MAX_NR_ZONES when operating on the entire lruvec? That would
> make the code quite a bit clearer than having 3 different lruvec size
> querying functions.

OK, fair point. What about this?
---
