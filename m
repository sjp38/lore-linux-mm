Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 96DA98D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:52:27 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CB64E3EE0BC
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:52:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B335D45DE58
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:52:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D87645DE3E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:52:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 90DE7E38001
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:52:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C605E08001
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:52:23 +0900 (JST)
Date: Tue, 29 Mar 2011 11:45:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-Id: <20110329114555.cb5d5c51.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikgop4m9ngX6Dd1K6Jk7jsMMU0xig@mail.gmail.com>
References: <20110328093957.089007035@suse.cz>
	<AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
	<20110329091254.20c7cfcb.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin4J5kiysPdQD2aTC52U4-dy04C1g@mail.gmail.com>
	<20110329094756.49af153d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikgop4m9ngX6Dd1K6Jk7jsMMU0xig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Suleiman Souhlal <suleiman@google.com>

On Mon, 28 Mar 2011 19:46:41 -0700
Ying Han <yinghan@google.com> wrote:

> On Mon, Mar 28, 2011 at 5:47 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >
> >> By saying that, memcg simplified the memory accounting per-cgroup but
> >> the memory isolation is broken. This is one of examples where pages
> >> are shared between global LRU and per-memcg LRU. It is easy to get
> >> cgroup-A's page evicted by adding memory pressure to cgroup-B.
> >>
> > If you overcommit....Right ?
> 
> yes, we want to support the configuration of over-committing the
> machine w/ limit_in_bytes.
> 

Then, soft_limit is a feature for fixing the problem. If you have problem
with soft_limit, let's fix it.


> >
> >
> >> The approach we are thinking to make the page->lru exclusive solve the
> >> problem. and also we should be able to break the zone->lru_lock
> >> sharing.
> >>
> > Is zone->lru_lock is a problem even with the help of pagevecs ?
> 
> > If LRU management guys acks you to isolate LRUs and to make kswapd etc..
> > more complex, okay, we'll go that way.
> 
> I would assume the change only apply to memcg users , otherwise
> everything is leaving in the global LRU list.
> 
> This will _change_ the whole memcg design and concepts Maybe memcg
> should have some kind of balloon driver to
> > work happy with isolated lru.
> 
> We have soft_limit hierarchical reclaim for system memory pressure,
> and also we will add per-memcg background reclaim. Both of them do
> targeting reclaim on per-memcg LRUs, and where is the balloon driver
> needed?
> 

If soft_limit is _not_ enough. And I think you background reclaim should
be work with soft_limit and be triggered by global memory pressure. 

As wrote in other mail, it's not called via direct reclaim.
Maybe its the 1st point to be shooted rather than trying big change.




Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
