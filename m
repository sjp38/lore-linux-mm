Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8836B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:35:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 68CC33EE0BC
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 18:35:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F37B45DE50
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 18:35:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3855145DE4D
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 18:35:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A9A91DB8040
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 18:35:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA8581DB8037
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 18:35:44 +0900 (JST)
Message-ID: <4E27F2EC.2010902@jp.fujitsu.com>
Date: Thu, 21 Jul 2011 18:35:40 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: page allocator: Reconsider zones for allocation
 after direct reclaim
References: <1310389274-13995-1-git-send-email-mgorman@suse.de> <1310389274-13995-4-git-send-email-mgorman@suse.de> <4E1CE9FF.3050707@jp.fujitsu.com> <20110713111017.GG7529@suse.de> <4E1E6086.4060902@jp.fujitsu.com> <20110714061049.GK7529@suse.de>
In-Reply-To: <20110714061049.GK7529@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi





>> So, I think we don't need to care zonelist, just kswapd turn off
>> their own node.
> 
> I don't understand what you mean by this.

This was the answer of following your comments.

> Instead, couldn't we turn zlc->fullzones off from kswapd?
> >
> > Which zonelist should it clear (there are two)

I mean, buddy list is belong to zone, not zonelist. therefore, kswapd
don't need to look up zonelist.

So, I'd suggest either following way,
 - use direct reclaim path, but only clear a zlc bit of zones in reclaimed zonelist, not all. or
 - use kswapd and only clear a zlc bit at kswap exiting balance_pgdat

I'm prefer to add a branch to slowpath (ie reclaim path) rather than fast path.


>> And, just curious, If we will have a proper zlc clear point, why
>> do we need to keep HZ timeout?
> 
> Yes because we are not guaranteed to call direct reclaim either. Memory
> could be freed by a process exiting and I'd rather not add cost to
> the free path to find and clear all zonelists referencing the zone the
> page being freed belongs to.

Ok, it's good trade-off. I agree we need to keep HZ timeout.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
