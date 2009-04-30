Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1FD7D6B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 05:48:26 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3U9nA6K007345
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Apr 2009 18:49:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA01B45DD7D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:49:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C902045DD7E
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:49:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A250E1DB803F
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:49:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 45AC31DB8040
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:49:09 +0900 (JST)
Date: Thu, 30 Apr 2009 18:47:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix stale swap cache leak v5
Message-Id: <20090430184738.752858ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090430094252.GG4430@balbir.in.ibm.com>
References: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430094252.GG4430@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 15:12:52 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-30 18:04:26]:
> 
> > On Thu, 30 Apr 2009 16:35:39 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Thu, 30 Apr 2009 16:16:27 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > This is v5 but all codes are rewritten.
> > > > 
> > > > After this patch, when memcg is used,
> > > >  1. page's swapcount is checked after I/O (without locks). If the page is
> > > >     stale swap cache, freeing routine will be scheduled.
> > > >  2. vmscan.c calls try_to_free_swap() when __remove_mapping() fails.
> > > > 
> > > > Works well for me. no extra resources and no races.
> > > > 
> > > > Because my office will be closed until May/7, I'll not be able to make a
> > > > response. Posting this for showing what I think of now.
> > > > 
> > > I found a hole immediately after posted this...sorry. plz ignore this patch/
> > > see you again in the next month.
> > > 
> > I'm now wondering to disable "swapin readahed" completely when memcg is used...
> > Then, half of the problems will go away immediately.
> > And it's not so bad to try to free swapcache if swap writeback ends. Then, another
> > half will go away...
> >
> 
> Could you clarify? Will memcg not account for swapin readahead pages?
>  
swapin-readahead pages are _not_ accounted now. (And I think _never_)
But has race and leak swp_entry account until global LRU runs.

"Don't do swapin-readahead, at all" will remove following race completely.
==
         CPU0                  CPU1
 free_swap_and_cache()
                        read_swapcache_async()
==
swp_entry to be freed will not be read-in.

I think there will no performance regression in _usual_ case even if no readahead.
But has no number yet.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
