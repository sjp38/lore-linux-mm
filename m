Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 12A456B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 06:54:23 -0400 (EDT)
Date: Fri, 2 Nov 2012 11:54:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix hotplugged memory zone oops
Message-ID: <20121102105420.GB24073@dhcp22.suse.cz>
References: <505187D4.7070404@cn.fujitsu.com>
 <20120913205935.GK1560@cmpxchg.org>
 <alpine.LSU.2.00.1209131816070.1908@eggly.anvils>
 <507CF789.6050307@cn.fujitsu.com>
 <alpine.LSU.2.00.1210181129180.2137@eggly.anvils>
 <20121018220306.GA1739@cmpxchg.org>
 <alpine.LNX.2.00.1211011822190.20048@eggly.anvils>
 <20121102102159.GA24073@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121102102159.GA24073@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wen Congyang <wency@cn.fujitsu.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Jiang Liu <liuj97@gmail.com>, bsingharora@gmail.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, paul.gortmaker@windriver.com, Tang Chen <tangchen@cn.fujitsu.com>

On Fri 02-11-12 11:21:59, Michal Hocko wrote:
> On Thu 01-11-12 18:28:02, Hugh Dickins wrote:
[...]

And I forgot to mention that the following hunk will clash with
"memcg: Simplify mem_cgroup_force_empty_list error handling" which is in
linux-next already (via Tejun's tree). 
Would it be easier to split the patch into the real fix and the hunk
bellow? That one doesn't have to go into stable anyway and we would save
some merging conflicts. The updated fix on top of -mm tree is bellow for
your convinience.

> >  /**
> > @@ -3688,17 +3712,17 @@ unsigned long mem_cgroup_soft_limit_recl
> >  static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> >  				int node, int zid, enum lru_list lru)
> >  {
> > -	struct mem_cgroup_per_zone *mz;
> > +	struct lruvec *lruvec;
> >  	unsigned long flags, loop;
> >  	struct list_head *list;
> >  	struct page *busy;
> >  	struct zone *zone;
> >  
> >  	zone = &NODE_DATA(node)->node_zones[zid];
> > -	mz = mem_cgroup_zoneinfo(memcg, node, zid);
> > -	list = &mz->lruvec.lists[lru];
> > +	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> > +	list = &lruvec->lists[lru];
> >  
> > -	loop = mz->lru_size[lru];
> > +	loop = mem_cgroup_get_lru_size(lruvec, lru);
> >  	/* give some margin against EBUSY etc...*/
> >  	loop += 256;
> >  	busy = NULL;

---
