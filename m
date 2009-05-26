Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DED0D6B004D
	for <linux-mm@kvack.org>; Tue, 26 May 2009 14:14:41 -0400 (EDT)
Date: Tue, 26 May 2009 20:14:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH 5/5] (experimental) chase and free cache only swap
Message-ID: <20090526181359.GB2843@cmpxchg.org>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com> <20090526121834.dd9a4193.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090526121834.dd9a4193.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 26, 2009 at 12:18:34PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Just a trial/example patch.
> I'd like to consider more. Better implementation idea is welcome.
> 
> When the system does swap-in/swap-out repeatedly, there are 
> cache-only swaps in general.
> Typically,
>  - swapped out in past but on memory now while vm_swap_full() returns true
> pages are cache-only swaps. (swap_map has no references.)
> 
> This cache-only swaps can be an obstacles for smooth page reclaiming.
> Current implemantation is very naive, just scan & free.

I think we can just remove that vm_swap_full() check in do_swap_page()
and try to remove the page from swap cache unconditionally.

If it's still mapped someplace else, we let it cached.  If not, there
is not much use for keeping it around and we free it.

When I removed it and did benchmarks, I couldn't spot any difference
in the timings, though.  Did you measure the benefits of your patch
somehow?

According to the git history tree, vm_swap_full() was initially only
used to aggressively drop cache entries even when they are mapped.

Rik put it into vmscan to reclaim swap cache _at all_ for activated
pages.  But I think unconditionally dropping the cache entry makes
sense if the page gets shuffled around on the LRU list.  Better to
re-allocate a swap slot close to the new LRU buddies on the next scan.

And having this all covered, the need for the scanning your patch does
should be gone, unless I missed something.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
