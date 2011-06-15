Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D98536B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 20:19:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 72D8B3EE0C0
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:19:43 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5725D45DE53
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:19:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40E2345DF49
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:19:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 353701DB8051
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:19:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F168C1DB804F
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:19:42 +0900 (JST)
Date: Wed, 15 Jun 2011 09:12:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 5/5] memcg: fix percpu cached charge draining
 frequency
Message-Id: <20110615091245.e3267a6b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110614073651.GA21197@tiehlicka.suse.cz>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
	<20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110614073651.GA21197@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

On Tue, 14 Jun 2011 09:36:51 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 13-06-11 12:16:48, KAMEZAWA Hiroyuki wrote:
> > From 18b12e53f1cdf6d7feed1f9226c189c34866338c Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Mon, 13 Jun 2011 11:25:43 +0900
> > Subject: [PATCH 5/5] memcg: fix percpu cached charge draining frequency
> > 
> >  For performance, memory cgroup caches some "charge" from res_counter
> >  into per cpu cache. This works well but because it's cache,
> >  it needs to be flushed in some cases. Typical cases are
> >          1. when someone hit limit.
> >          2. when rmdir() is called and need to charges to be 0.
> > 
> > But "1" has problem.
> > 
> > Recently, with large SMP machines, we see many kworker runs because
> > of flushing memcg's cache. Bad things in implementation are
> > that even if a cpu contains a cache for memcg not related to
> > a memcg which hits limit, drain code is called.
> > 
> > This patch does
> > 	D) don't call at softlimit reclaim.
> 
> I think this needs some justification. The decision is not that
> obvious IMO. I would say that this is a good decision because cached
> charges will not help to free any memory (at least not directly) during
> background reclaim. What about something like:
> "
> We are not draining per cpu cached charges during soft limit reclaim 
> because background reclaim doesn't care about charges. It tries to free
> some memory and charges will not give any.
> Cached charges might influence only selection of the biggest soft limit
> offender but as the call is done only after the selection has been
> already done it makes no change.
> "
> 
> Anyway, wouldn't it be better to have this change separate from the
> async draining logic change?

Hmm. I think calling "draining" at softlimit is just a bug.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
