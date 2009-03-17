Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0E32D6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 03:31:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H7VDIS001456
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 16:31:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 141E445DD78
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 16:31:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E184C45DD77
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 16:31:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C23DBE08004
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 16:31:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FA211DB8013
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 16:31:12 +0900 (JST)
Date: Tue, 17 Mar 2009 16:29:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memcg: handle swapcache leak
Message-Id: <20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090317143903.a789cf57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 15:11:13 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:


> > Hmm, but IHMO, this is not "leak". "leak" means the object will not be freed forever.
> > This is a "delay".
> > 
> > And I tend to allow this. (stale SwapCache will be on LRU until global LRU found it,
> > but it's not called leak.)
> > 
> You're right, but memcg's reclaim doesn't scan global LRU,
> so these swapcaches cannot be free'ed by memcg's reclaim.
> 
right.

> This means that a system with memcg's memory pressure but without
> global memory pressure can use up swap space as swapcaches, doesn't it ?
> That's what I'm worrying about.
> 
This kind of behavior (don't add to LRU if !PageCgroupUsed()) is for swapin-readahead.
We need this hebavior.

We never see the swap is exhausted by this issue .....but yes, not 0%.

Without memcg, when the page is added to swap, global LRU runs, anyway.
With memcg, when the page is added to swap, global LRU will not runs.

Give me time, I'll find a fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
