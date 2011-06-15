Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7F36B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 21:19:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BCD1C3EE0CD
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:18:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A0C6345DE6B
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:18:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E65A45DE61
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:18:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FBEA1DB8040
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:18:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2936B1DB803C
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:18:58 +0900 (JST)
Date: Wed, 15 Jun 2011 10:12:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 5/5] memcg: fix percpu cached charge draining
 frequency
Message-Id: <20110615101202.fa8e9f76.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110615091245.e3267a6b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
	<20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110614073651.GA21197@tiehlicka.suse.cz>
	<20110615091245.e3267a6b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

On Wed, 15 Jun 2011 09:12:45 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 14 Jun 2011 09:36:51 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Mon 13-06-11 12:16:48, KAMEZAWA Hiroyuki wrote:
> > > From 18b12e53f1cdf6d7feed1f9226c189c34866338c Mon Sep 17 00:00:00 2001
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Date: Mon, 13 Jun 2011 11:25:43 +0900
> > > Subject: [PATCH 5/5] memcg: fix percpu cached charge draining frequency
> > > 
> > >  For performance, memory cgroup caches some "charge" from res_counter
> > >  into per cpu cache. This works well but because it's cache,
> > >  it needs to be flushed in some cases. Typical cases are
> > >          1. when someone hit limit.
> > >          2. when rmdir() is called and need to charges to be 0.
> > > 
> > > But "1" has problem.
> > > 
> > > Recently, with large SMP machines, we see many kworker runs because
> > > of flushing memcg's cache. Bad things in implementation are
> > > that even if a cpu contains a cache for memcg not related to
> > > a memcg which hits limit, drain code is called.
> > > 
> > > This patch does
> > > 	D) don't call at softlimit reclaim.
> > 
> > I think this needs some justification. The decision is not that
> > obvious IMO. I would say that this is a good decision because cached
> > charges will not help to free any memory (at least not directly) during
> > background reclaim. What about something like:
> > "
> > We are not draining per cpu cached charges during soft limit reclaim 
> > because background reclaim doesn't care about charges. It tries to free
> > some memory and charges will not give any.
> > Cached charges might influence only selection of the biggest soft limit
> > offender but as the call is done only after the selection has been
> > already done it makes no change.
> > "
> > 
> > Anyway, wouldn't it be better to have this change separate from the
> > async draining logic change?
> 
> Hmm. I think calling "draining" at softlimit is just a bug.
> 
I'll divide patches.

Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
