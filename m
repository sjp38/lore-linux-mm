Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 397B26B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:51:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 87B673EE0BB
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:40 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C78A45DE53
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 528D945DE4E
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 43E8C1DB8043
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:40 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D39E1DB8037
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:40 +0900 (JST)
Date: Fri, 22 Jul 2011 08:44:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] memcg: do not try to drain per-cpu caches without
 pages
Message-Id: <20110722084413.9dd4b880.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110721113606.GA27855@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
	<113c4affc2f0938b7b22d43c88d2b0a623de9a6b.1311241300.git.mhocko@suse.cz>
	<20110721191250.1c945740.kamezawa.hiroyu@jp.fujitsu.com>
	<20110721113606.GA27855@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 21 Jul 2011 13:36:06 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 21-07-11 19:12:50, KAMEZAWA Hiroyuki wrote:
> > On Thu, 21 Jul 2011 09:38:00 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > drain_all_stock_async tries to optimize a work to be done on the work
> > > queue by excluding any work for the current CPU because it assumes that
> > > the context we are called from already tried to charge from that cache
> > > and it's failed so it must be empty already.
> > > While the assumption is correct we can do it by checking the current
> > > number of pages in the cache. This will also reduce a work on other CPUs
> > > with an empty stock.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > 
> > At the first look, when a charge against TransParentHugepage() goes
> > into the reclaim routine, stock->nr_pages != 0 and this will
> > call additional kworker.
> 
> True. We will drain a charge which could be used by other allocations
> in the meantime so we have a good chance to reclaim less. But how big
> problem is that?
> I mean I can add a new parameter that would force checking the current
> cpu but it doesn't look nice. I cannot add that condition
> unconditionally because the code will be shared with the sync path in
> the next patch and that one needs to drain _all_ cpus.
> 
> What would you suggest?
By 2 methods

 - just check nr_pages. 
 - drain "local stock" without calling schedule_work(). It's fast.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
