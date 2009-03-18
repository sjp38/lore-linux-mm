Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EA9146B004F
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 20:09:31 -0400 (EDT)
Date: Wed, 18 Mar 2009 09:08:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC] memcg: handle swapcache leak
Message-Id: <20090318090818.bdb5ca0e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090317143903.a789cf57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
	<20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 16:29:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 17 Mar 2009 15:11:13 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> 
> > > Hmm, but IHMO, this is not "leak". "leak" means the object will not be freed forever.
> > > This is a "delay".
> > > 
> > > And I tend to allow this. (stale SwapCache will be on LRU until global LRU found it,
> > > but it's not called leak.)
> > > 
> > You're right, but memcg's reclaim doesn't scan global LRU,
> > so these swapcaches cannot be free'ed by memcg's reclaim.
> > 
> right.
> 
> > This means that a system with memcg's memory pressure but without
> > global memory pressure can use up swap space as swapcaches, doesn't it ?
> > That's what I'm worrying about.
> > 
> This kind of behavior (don't add to LRU if !PageCgroupUsed()) is for swapin-readahead.
> We need this hebavior.
> 
> We never see the swap is exhausted by this issue .....but yes, not 0%.
> 
Just FYI.
I run 5 programs last night, which uses 8MB each, with mem.limit=32M
and 30MB swap on system.
All swap space are used up by swapcache and some programs are oom'ed.


Thanks,
Daisuke Nishimura.

> Without memcg, when the page is added to swap, global LRU runs, anyway.
> With memcg, when the page is added to swap, global LRU will not runs.
> 
> Give me time, I'll find a fix.
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
