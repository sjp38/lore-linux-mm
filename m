Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD92900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 02:28:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6FF7E3EE0AE
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:28:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5719545DE9C
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:28:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3595945DE7E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:28:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 29F0D1DB803E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:28:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E859A1DB8038
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:28:12 +0900 (JST)
Date: Thu, 23 Jun 2011 15:21:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] Fix mem_cgroup_hierarchical_reclaim() to do stable
 hierarchy walk.
Message-Id: <20110623152111.a491e954.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110622183249.GA27191@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125141.5fbd230f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110622151500.GF14343@tiehlicka.suse.cz>
	<20110622183249.GA27191@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, 22 Jun 2011 20:33:31 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 22-06-11 17:15:00, Michal Hocko wrote:
> > On Thu 16-06-11 12:51:41, KAMEZAWA Hiroyuki wrote:
> > [...]
> > > @@ -1667,41 +1668,28 @@ static int mem_cgroup_hierarchical_recla
> > >  	if (!check_soft && root_mem->memsw_is_minimum)
> > >  		noswap = true;
> > >  
> > > -	while (1) {
> > > +again:
> > > +	if (!shrink) {
> > > +		visit = 0;
> > > +		for_each_mem_cgroup_tree(victim, root_mem)
> > > +			visit++;
> > > +	} else {
> > > +		/*
> > > +		 * At shrinking, we check the usage again in caller side.
> > > +		 * so, visit children one by one.
> > > +		 */
> > > +		visit = 1;
> > > +	}
> > > +	/*
> > > +	 * We are not draining per cpu cached charges during soft limit reclaim
> > > +	 * because global reclaim doesn't care about charges. It tries to free
> > > +	 * some memory and  charges will not give any.
> > > +	 */
> > > +	if (!check_soft)
> > > +		drain_all_stock_async(root_mem);
> > > +
> > > +	while (visit--) {
> > 
> > This is racy, isn't it? What prevents some groups to disapear in the
> > meantime? We would reclaim from those that are left more that we want.
> > 
> > Why cannot we simply do something like (totally untested):
> > 
> > Index: linus_tree/mm/memcontrol.c
> > ===================================================================
> > --- linus_tree.orig/mm/memcontrol.c	2011-06-22 17:11:54.000000000 +0200
> > +++ linus_tree/mm/memcontrol.c	2011-06-22 17:13:05.000000000 +0200
> > @@ -1652,7 +1652,7 @@ static int mem_cgroup_hierarchical_recla
> >  						unsigned long reclaim_options,
> >  						unsigned long *total_scanned)
> >  {
> > -	struct mem_cgroup *victim;
> > +	struct mem_cgroup *victim, *first_victim = NULL;
> >  	int ret, total = 0;
> >  	int loop = 0;
> >  	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
> > @@ -1669,6 +1669,11 @@ static int mem_cgroup_hierarchical_recla
> >  
> >  	while (1) {
> >  		victim = mem_cgroup_select_victim(root_mem);
> > +		if (!first_victim)
> > +			first_victim = victim;
> > +		else if (first_victim == victim)
> > +			break;
> 
> this will obviously need css_get and css_put to make sure that the group
> doesn't disappear in the meantime.
> 

I forgot why we didn't this. Hmm, ok, I'll use this style.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
