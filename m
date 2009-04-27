Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 478E66B00A4
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 04:50:32 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3R8pHws008590
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Apr 2009 17:51:18 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 844FC45DE59
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:51:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C6F445DD72
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:51:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 26D231DB8038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:51:17 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B5B251DB8037
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:51:16 +0900 (JST)
Date: Mon, 27 Apr 2009 17:49:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for memg v3.
Message-Id: <20090427174944.86dbb94c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090427084347.GJ4454@balbir.in.ibm.com>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
	<20090424133306.0d9fb2ce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090424152103.a5ee8d13.nishimura@mxp.nes.nec.co.jp>
	<20090424162840.2ad06d8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427081206.GI4454@balbir.in.ibm.com>
	<20090427172119.d84aaa68.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427084347.GJ4454@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 14:13:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > I like to. But there is no space to record it as stale. And "race" makes
> > that difficult even if we have enough space. If you read the whole thread,
> > you know there are many patterns of race.
> 
> There have been several iterations of this discussion, summarizing it
> would be nice, let me find the thread.
> 
At first, it's obious that there are no free space in swap entry array and
swap_cgroup array. (And this can be trouble even if MEM_RES_CONTROLLER_SWAP_EXT
is not used.)

I tried to record "stale" information to page_cgroup with flag, but there is
following sequence and I can't do it.

==
     CPU0(zap_pte)                 CPU1 (read swap)
                                  swap_duplicate()
     free_swapentry()
                                  add_to_swap_cache().
==
In this case, we can't know swap_entry is stale or not at zap_pte().



> > 
> > > 2. Can't we reclaim stale entries during memcg LRU reclaim? Why write
> > > a GC for it?
> > > 
> > Because they are not on memcg LRU. we can't reclaim it by memcg LRU.
> > (See the first mail from Nishimura of this thread. It explains well.)
> >
> 
> Hmm.. I don't find it, let me do a more exhaustive search on the web.
> If the entry is stale and not on memcg LRU, it is still accounted to
> the memcg?
yes. accoutned to memcg.memsw.usage_in_bytes.


>  
> > One easy case is here.
> > 
> >   - CPU0 call zap_pte()->free_swap_and_cache()
> >   - CPU1 tries to swap-in it.
> >   In this case, free_swap_and_cache() doesn't free swp_entry and swp_entry
> >   is read into the memory. But it will never be added memcg's LRU until
> >   it's mapped.
> 
> That is strange.. not even added to the LRU as a cached page?
> 
added to "global" LRU but not to "memcg's LRU" because "USED" bit is not set.


> >   (What we have to consider here is swapin-readahead. It can swap-in memory
> >    even if it's not accessed. Then, this race window is larger than expected.)
> > 
> > We can't use memcg's LRU then...what we can do is.
> > 
> >  - scanning global LRU all
> >  or
> >  - use some trick to reclaim them in lazy way.
> >
> 
> Thanks for being patient, some of these questions have been discussed
> before I suppose. Let me dig out the thread. 
> 

Sorry for lack of explanation. I'll add more text to v4. patch.

Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
