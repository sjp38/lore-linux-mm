Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA79Dc5u001438
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Nov 2008 18:13:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F1B145DD7D
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 18:13:38 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 79E5045DD7B
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 18:13:38 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 61355E08005
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 18:13:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CAEEE08002
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 18:13:38 +0900 (JST)
Date: Fri, 7 Nov 2008 18:13:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/6] memcg: handle swap cache
Message-Id: <20081107181303.7dd232fd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081107175303.1d5c8a29.nishimura@mxp.nes.nec.co.jp>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
	<20081105172009.d9541e27.kamezawa.hiroyu@jp.fujitsu.com>
	<20081107175303.1d5c8a29.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Nov 2008 17:53:03 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 5 Nov 2008 17:20:09 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > SwapCache support for memory resource controller (memcg)
> > 
> > Before mem+swap controller, memcg itself should handle SwapCache in proper way.
> > 
> > In current memcg, SwapCache is just leaked and the user can create tons of
> > SwapCache. This is a leak of account and should be handled.
> > 
> > SwapCache accounting is done as following.
> > 
> >   charge (anon)
> > 	- charged when it's mapped.
> > 	  (because of readahead, charge at add_to_swap_cache() is not sane)
> >   uncharge (anon)
> > 	- uncharged when it's dropped from swapcache and fully unmapped.
> > 	  means it's not uncharged at unmap.
> > 	  Note: delete from swap cache at swap-in is done after rmap information
> > 	        is established.
> >   charge (shmem)
> > 	- charged at swap-in. this prevents charge at add_to_page_cache().
> > 
> >   uncharge (shmem)
> > 	- uncharged when it's dropped from swapcache and not on shmem's
> > 	  radix-tree.
> > 
> >   at migration, check against 'old page' is modified to handle shmem.
> > 
> > Comparing to the old version discussed (and caused troubles), we have
> > advantages of
> >   - PCG_USED bit.
> >   - simple migrating handling.
> > 
> > So, situation is much easier than several months ago, maybe.
> > 
> > Changelog (v1) -> (v2)
> >   - use lock_page() when we handle unlocked SwapCache.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> I tested this version under swap in/out activity with page migration/rmdir,
> and it worked w/o errors for more than 24 hours.
> 
> 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 	Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
Thank you!

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
