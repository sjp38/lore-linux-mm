Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0576B0082
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:56:40 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D1F523EE0BB
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:56:37 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B38EE45DE52
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:56:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BA3345DE4E
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:56:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EE641DB8043
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:56:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B2FD1DB8037
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:56:37 +0900 (JST)
Date: Fri, 22 Jul 2011 08:49:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] memcg: get rid of percpu_charge_mutex lock
Message-Id: <20110722084927.96b0aa86.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110721124223.GE27855@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
	<2bfb2b7687c1a6b39da2a04689190725075cc4f8.1311241300.git.mhocko@suse.cz>
	<20110721193051.cd3266e5.kamezawa.hiroyu@jp.fujitsu.com>
	<20110721114704.GC27855@tiehlicka.suse.cz>
	<20110721124223.GE27855@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 21 Jul 2011 14:42:23 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 21-07-11 13:47:04, Michal Hocko wrote:
> > On Thu 21-07-11 19:30:51, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 21 Jul 2011 09:58:24 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> [...]
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -2166,7 +2165,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> > > >  
> > > >  	for_each_online_cpu(cpu) {
> > > >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > > > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > > +		if (root_mem == stock->cached &&
> > > > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > >  			flush_work(&stock->work);
> > > 
> > > Doesn't this new check handle hierarchy ?
> > > css_is_ancestor() will be required if you do this check.
> > 
> > Yes you are right. Will fix it. I will add a helper for the check.
> 
> Here is the patch with the helper. The above will then read 
> 	if (mem_cgroup_same_or_subtree(root_mem, stock->cached))
> 
> ---
> From b963a9f4dac61044daac49700f84b7819d7c2f53 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 21 Jul 2011 13:54:13 +0200
> Subject: [PATCH] memcg: add mem_cgroup_same_or_subtree helper
> 
> We are checking whether a given two groups are same or at least in the
> same subtree of a hierarchy at several places. Let's make a helper for
> it to make code easier to read.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
