Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AB99D6B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 05:21:20 -0400 (EDT)
Date: Fri, 22 Jul 2011 11:21:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] memcg: get rid of percpu_charge_mutex lock
Message-ID: <20110722092116.GC4004@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
 <2bfb2b7687c1a6b39da2a04689190725075cc4f8.1311241300.git.mhocko@suse.cz>
 <20110721193051.cd3266e5.kamezawa.hiroyu@jp.fujitsu.com>
 <20110721114704.GC27855@tiehlicka.suse.cz>
 <20110721124223.GE27855@tiehlicka.suse.cz>
 <20110722084927.96b0aa86.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110722084927.96b0aa86.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Fri 22-07-11 08:49:27, KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Jul 2011 14:42:23 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 21-07-11 13:47:04, Michal Hocko wrote:
> > > On Thu 21-07-11 19:30:51, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 21 Jul 2011 09:58:24 +0200
> > > > Michal Hocko <mhocko@suse.cz> wrote:
> > [...]
> > > > > --- a/mm/memcontrol.c
> > > > > +++ b/mm/memcontrol.c
> > > > > @@ -2166,7 +2165,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> > > > >  
> > > > >  	for_each_online_cpu(cpu) {
> > > > >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > > > > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > > > +		if (root_mem == stock->cached &&
> > > > > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > > >  			flush_work(&stock->work);
> > > > 
> > > > Doesn't this new check handle hierarchy ?
> > > > css_is_ancestor() will be required if you do this check.
> > > 
> > > Yes you are right. Will fix it. I will add a helper for the check.
> > 
> > Here is the patch with the helper. The above will then read 
> > 	if (mem_cgroup_same_or_subtree(root_mem, stock->cached))
> > 
> > ---
> > From b963a9f4dac61044daac49700f84b7819d7c2f53 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Thu, 21 Jul 2011 13:54:13 +0200
> > Subject: [PATCH] memcg: add mem_cgroup_same_or_subtree helper
> > 
> > We are checking whether a given two groups are same or at least in the
> > same subtree of a hierarchy at several places. Let's make a helper for
> > it to make code easier to read.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
