Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2556A900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 02:50:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7A5433EE0BC
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 15:50:32 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F94D45DE54
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 15:50:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 33ED845DE55
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 15:50:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2412D1DB8055
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 15:50:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD4D41DB804B
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 15:50:31 +0900 (JST)
Date: Thu, 18 Aug 2011 15:42:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 2/6]  memcg: stop vmscan when enough done.
Message-Id: <20110818154259.6b4adf09.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110818062722.GB23056@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809190933.d965888b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110810141425.GC15007@tiehlicka.suse.cz>
	<20110811085252.b29081f1.kamezawa.hiroyu@jp.fujitsu.com>
	<20110811145055.GN8023@tiehlicka.suse.cz>
	<20110817095405.ee3dcd74.kamezawa.hiroyu@jp.fujitsu.com>
	<20110817113550.GA7482@tiehlicka.suse.cz>
	<20110818085233.69dbf23b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110818062722.GB23056@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, 18 Aug 2011 08:27:22 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 18-08-11 08:52:33, KAMEZAWA Hiroyuki wrote:
> > On Wed, 17 Aug 2011 13:35:50 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Wed 17-08-11 09:54:05, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 11 Aug 2011 16:50:55 +0200
> > > > > - mem_cgroup_force_empty asks for reclaiming all pages. I guess it should be
> > > > >   OK but will have to think about it some more.
> > > > 
> > > > force_empty/rmdir() is allowed to be stopped by Ctrl-C. I think passing res->usage
> > > > is overkilling.
> > > 
> > > So, how many pages should be reclaimed then?
> > > 
> > 
> > How about (1 << (MAX_ORDER-1))/loop ?
> 
> Hmm, I am not sure I see any benefit. We want to reclaim all those
> pages why shouldn't we do it in one batch? If we use a value based on
> MAX_ORDER then we make a bigger chance that force_empty fails for big
> cgroups (e.g. with a lot of page cache).

Why bigger chance to fail ? retry counter is decreased only when we cannot
make any reclaim. The number passed here is not problem against the faiulre.

I don't like very long vmscan which cannot be stopped by Ctrl-C.


> Anyway, if we want to mimic the previous behavior then we should use
> something like nr_nodes * SWAP_CLUSTER_MAX (the above value would be
> sufficient for up to 32 nodes).
> 

agreed.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
