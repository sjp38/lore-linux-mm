Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id E4BA76B0044
	for <linux-mm@kvack.org>; Sat,  3 Nov 2012 03:00:09 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so2018197eaa.14
        for <linux-mm@kvack.org>; Sat, 03 Nov 2012 00:00:08 -0700 (PDT)
Date: Sat, 3 Nov 2012 08:00:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix hotplugged memory zone oops
Message-ID: <20121103070006.GA12038@dhcp22.suse.cz>
References: <505187D4.7070404@cn.fujitsu.com>
 <20120913205935.GK1560@cmpxchg.org>
 <alpine.LSU.2.00.1209131816070.1908@eggly.anvils>
 <507CF789.6050307@cn.fujitsu.com>
 <alpine.LSU.2.00.1210181129180.2137@eggly.anvils>
 <20121018220306.GA1739@cmpxchg.org>
 <alpine.LNX.2.00.1211011822190.20048@eggly.anvils>
 <20121102102159.GA24073@dhcp22.suse.cz>
 <20121102105420.GB24073@dhcp22.suse.cz>
 <alpine.LNX.2.00.1211021631260.11106@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211021631260.11106@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wen Congyang <wency@cn.fujitsu.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Jiang Liu <liuj97@gmail.com>, bsingharora@gmail.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, paul.gortmaker@windriver.com, Tang Chen <tangchen@cn.fujitsu.com>

On Fri 02-11-12 16:37:37, Hugh Dickins wrote:
> On Fri, 2 Nov 2012, Michal Hocko wrote:
> > On Fri 02-11-12 11:21:59, Michal Hocko wrote:
> > > On Thu 01-11-12 18:28:02, Hugh Dickins wrote:
> > [...]
> > 
> > And I forgot to mention that the following hunk will clash with
> > "memcg: Simplify mem_cgroup_force_empty_list error handling" which is in
> > linux-next already (via Tejun's tree). 
> 
> Oh, via Tejun's tree.  Right, when I checked mmotm there was no problem.

Yeah, whole that thing goes through Tejun's tree because there are many
follow up clean ups depending on that change.

> > Would it be easier to split the patch into the real fix and the hunk
> > bellow? That one doesn't have to go into stable anyway and we would save
> > some merging conflicts. The updated fix on top of -mm tree is bellow for
> > your convinience.
> 
> I'd prefer to leave it as one patch, so even the "future proof" part
> of the fix goes into 3.7 and stable.  But your point is that you have
> already seen the future, and it forks in a slightly different direction!
> 
> Well, I don't want to be obstructive, but it doesn't look difficult
> to resolve.  

True.

> Perhaps if I hold off on splitting them, and see if akpm barks at me
> or not :)
> 
> Hugh
> 
> > > >  /**
> > > > @@ -3688,17 +3712,17 @@ unsigned long mem_cgroup_soft_limit_recl
> > > >  static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> > > >  				int node, int zid, enum lru_list lru)
> > > >  {
> > > > -	struct mem_cgroup_per_zone *mz;
> > > > +	struct lruvec *lruvec;
> > > >  	unsigned long flags, loop;
> > > >  	struct list_head *list;
> > > >  	struct page *busy;
> > > >  	struct zone *zone;
> > > >  
> > > >  	zone = &NODE_DATA(node)->node_zones[zid];
> > > > -	mz = mem_cgroup_zoneinfo(memcg, node, zid);
> > > > -	list = &mz->lruvec.lists[lru];
> > > > +	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> > > > +	list = &lruvec->lists[lru];
> > > >  
> > > > -	loop = mz->lru_size[lru];
> > > > +	loop = mem_cgroup_get_lru_size(lruvec, lru);
> > > >  	/* give some margin against EBUSY etc...*/
> > > >  	loop += 256;
> > > >  	busy = NULL;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
