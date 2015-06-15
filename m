Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 362B66B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 04:19:51 -0400 (EDT)
Received: by wiga1 with SMTP id a1so69009018wig.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 01:19:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u15si20747174wjw.211.2015.06.15.01.19.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 01:19:49 -0700 (PDT)
Date: Mon, 15 Jun 2015 09:19:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/25] mm, vmscan: Move LRU lists to node
Message-ID: <20150615081943.GK26425@suse.de>
References: <00e901d0a415$f06fed80$d14fc880$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <00e901d0a415$f06fed80$d14fc880$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Thu, Jun 11, 2015 at 03:12:12PM +0800, Hillf Danton wrote:
> > @@ -774,6 +764,21 @@ typedef struct pglist_data {
> >  	ZONE_PADDING(_pad1_)
> >  	spinlock_t		lru_lock;
> > 
> > +	/* Fields commonly accessed by the page reclaim scanner */
> > +	struct lruvec		lruvec;
> > +
> > +	/* Evictions & activations on the inactive file list */
> > +	atomic_long_t		inactive_age;
> > +
> > +	/*
> > +	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
> > +	 * this zone's LRU.  Maintained by the pageout code.
> > +	 */
> 
> The comment has to be updated.
> 

Yes it does. Fixed.

> > +	unsigned int inactive_ratio;
> > +
> > +	unsigned long		flags;
> > +
> > +	ZONE_PADDING(_pad2_)
> >  	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
> >  	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
> >  } pg_data_t;
> > @@ -1185,7 +1185,7 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
> >  	struct lruvec *lruvec;
> > 
> >  	if (mem_cgroup_disabled()) {
> > -		lruvec = &zone->lruvec;
> > +		lruvec = zone_lruvec(zone);
> >  		goto out;
> >  	}
> > 
> > @@ -1197,8 +1197,8 @@ out:
> >  	 * we have to be prepared to initialize lruvec->zone here;
> >  	 * and if offlined then reonlined, we need to reinitialize it.
> >  	 */
> > -	if (unlikely(lruvec->zone != zone))
> > -		lruvec->zone = zone;
> > +	if (unlikely(lruvec->pgdat != zone->zone_pgdat))
> > +		lruvec->pgdat = zone->zone_pgdat;
> 
> See below please.
> 
> >  	return lruvec;
> >  }
> > 
> > @@ -1211,14 +1211,14 @@ out:
> >   * and putback protocol: the LRU lock must be held, and the page must
> >   * either be PageLRU() or the caller must have isolated/allocated it.
> >   */
> > -struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
> > +struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgdat)
> >  {
> >  	struct mem_cgroup_per_zone *mz;
> >  	struct mem_cgroup *memcg;
> >  	struct lruvec *lruvec;
> > 
> >  	if (mem_cgroup_disabled()) {
> > -		lruvec = &zone->lruvec;
> > +		lruvec = &pgdat->lruvec;
> >  		goto out;
> >  	}
> > 
> > @@ -1238,8 +1238,8 @@ out:
> >  	 * we have to be prepared to initialize lruvec->zone here;
> >  	 * and if offlined then reonlined, we need to reinitialize it.
> >  	 */
> > -	if (unlikely(lruvec->zone != zone))
> > -		lruvec->zone = zone;
> > +	if (unlikely(lruvec->pgdat != pgdat))
> > +		lruvec->pgdat = pgdat;
> 
> Given &pgdat->lruvec, we no longer need(or are able) to set lruvec->pgdat.
> 

I do not understand your comment. This is setting a mapping between lruvec
and pgdat, not the other way around. It's a straight-forward conversion
of zone to pgdat.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
