Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B795F8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:36:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C22DE3EE0AE
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:36:06 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A70FE45DE52
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:36:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D02545DE50
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:36:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7883E1DB8045
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:36:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 425B91DB802F
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:36:06 +0900 (JST)
Date: Tue, 29 Mar 2011 11:29:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-Id: <20110329112940.fcccd175.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110329094756.49af153d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110328093957.089007035@suse.cz>
	<AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
	<20110329091254.20c7cfcb.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin4J5kiysPdQD2aTC52U4-dy04C1g@mail.gmail.com>
	<20110329094756.49af153d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Suleiman Souhlal <suleiman@google.com>

On Tue, 29 Mar 2011 09:47:56 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 28 Mar 2011 17:37:02 -0700
> Ying Han <yinghan@google.com> wrote:

> > The approach we are thinking to make the page->lru exclusive solve the
> > problem. and also we should be able to break the zone->lru_lock
> > sharing.
> > 
> Is zone->lru_lock is a problem even with the help of pagevecs ?
> 
> If LRU management guys acks you to isolate LRUs and to make kswapd etc..
> more complex, okay, we'll go that way. This will _change_ the whole
> memcg design and concepts Maybe memcg should have some kind of balloon driver to
> work happy with isolated lru.
> 
> But my current standing position is "never bad effects global reclaim".
> So, I'm not very happy with the solution.
> 
> If we go that way, I guess we'll think we should have pseudo nodes/zones, which
> was proposed in early days of resource controls.(not cgroup).
> 

BTW, against isolation, I have one thought.

Now, soft_limit_reclaim is not called in direct-reclaim path just because we thought
kswapd works enough well. If necessary, I think we can put soft-reclaim call in
generic do_try_to_free_pages(order=0). 

So, isolation problem can be reduced to some extent, isn't it ?
Algorithm of softlimit _should_ be updated. I guess it's not heavily tested feature.

About ROOT cgroup, I think some daemon application should put _all_ process to
some controled cgroup. So, I don't want to think about limiting on ROOT cgroup
without any justification.

I'd like you to devide 'the talk on performance' and 'the talk on feature'.

"This makes makes performance better! ...and add an feature" sounds bad to me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
