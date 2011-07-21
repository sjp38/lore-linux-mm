Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ECDF56B0082
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 08:42:28 -0400 (EDT)
Date: Thu, 21 Jul 2011 14:42:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] memcg: get rid of percpu_charge_mutex lock
Message-ID: <20110721124223.GE27855@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
 <2bfb2b7687c1a6b39da2a04689190725075cc4f8.1311241300.git.mhocko@suse.cz>
 <20110721193051.cd3266e5.kamezawa.hiroyu@jp.fujitsu.com>
 <20110721114704.GC27855@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110721114704.GC27855@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu 21-07-11 13:47:04, Michal Hocko wrote:
> On Thu 21-07-11 19:30:51, KAMEZAWA Hiroyuki wrote:
> > On Thu, 21 Jul 2011 09:58:24 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -2166,7 +2165,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> > >  
> > >  	for_each_online_cpu(cpu) {
> > >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > +		if (root_mem == stock->cached &&
> > > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > >  			flush_work(&stock->work);
> > 
> > Doesn't this new check handle hierarchy ?
> > css_is_ancestor() will be required if you do this check.
> 
> Yes you are right. Will fix it. I will add a helper for the check.

Here is the patch with the helper. The above will then read 
	if (mem_cgroup_same_or_subtree(root_mem, stock->cached))

---
