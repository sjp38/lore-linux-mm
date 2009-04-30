Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 119256B0047
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 14:12:39 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3UI2BW6005059
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 14:02:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3UICnid121296
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 14:12:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3UIAwIT029693
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 14:10:59 -0400
Date: Thu, 30 Apr 2009 23:42:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: fix stale swap cache leak v5
Message-ID: <20090430181246.GM4430@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com> <20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com> <20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com> <20090430094252.GG4430@balbir.in.ibm.com> <20090430184738.752858ea.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090430184738.752858ea.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-30 18:47:38]:

> On Thu, 30 Apr 2009 15:12:52 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-30 18:04:26]:
> > 
> > > On Thu, 30 Apr 2009 16:35:39 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Thu, 30 Apr 2009 16:16:27 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > 
> > > > > This is v5 but all codes are rewritten.
> > > > > 
> > > > > After this patch, when memcg is used,
> > > > >  1. page's swapcount is checked after I/O (without locks). If the page is
> > > > >     stale swap cache, freeing routine will be scheduled.
> > > > >  2. vmscan.c calls try_to_free_swap() when __remove_mapping() fails.
> > > > > 
> > > > > Works well for me. no extra resources and no races.
> > > > > 
> > > > > Because my office will be closed until May/7, I'll not be able to make a
> > > > > response. Posting this for showing what I think of now.
> > > > > 
> > > > I found a hole immediately after posted this...sorry. plz ignore this patch/
> > > > see you again in the next month.
> > > > 
> > > I'm now wondering to disable "swapin readahed" completely when memcg is used...
> > > Then, half of the problems will go away immediately.
> > > And it's not so bad to try to free swapcache if swap writeback ends. Then, another
> > > half will go away...
> > >
> > 
> > Could you clarify? Will memcg not account for swapin readahead pages?
> >  
> swapin-readahead pages are _not_ accounted now. (And I think _never_)
> But has race and leak swp_entry account until global LRU runs.
> 
> "Don't do swapin-readahead, at all" will remove following race completely.
> ==
>          CPU0                  CPU1
>  free_swap_and_cache()
>                         read_swapcache_async()
> ==
> swp_entry to be freed will not be read-in.
> 
> I think there will no performance regression in _usual_ case even if no readahead.
> But has no number yet.
>

Kamezawa, Daisuke,

Can't we just correct the accounting and leave the page on the global
LRU?

Daisuke in the race conditions mentioned is (2) significant? Since the
accounting is already fixed during mem_cgroup_uncharge_page()?

 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
