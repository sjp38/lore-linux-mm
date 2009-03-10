Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8916B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 23:36:47 -0400 (EDT)
Date: Tue, 10 Mar 2009 12:18:56 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH] memcg: charge swapcache to proper memcg
Message-Id: <20090310121856.93cd2786.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090310113502.d272fc2a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
	<20090310113502.d272fc2a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Mar 2009 11:35:02 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 10 Mar 2009 10:07:07 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > memcg_test.txt says at 4.1:
> > 
> > 	This swap-in is one of the most complicated work. In do_swap_page(),
> > 	following events occur when pte is unchanged.
> > 
> > 	(1) the page (SwapCache) is looked up.
> > 	(2) lock_page()
> > 	(3) try_charge_swapin()
> > 	(4) reuse_swap_page() (may call delete_swap_cache())
> > 	(5) commit_charge_swapin()
> > 	(6) swap_free().
> > 
> > 	Considering following situation for example.
> > 
> > 	(A) The page has not been charged before (2) and reuse_swap_page()
> > 	    doesn't call delete_from_swap_cache().
> > 	(B) The page has not been charged before (2) and reuse_swap_page()
> > 	    calls delete_from_swap_cache().
> > 	(C) The page has been charged before (2) and reuse_swap_page() doesn't
> > 	    call delete_from_swap_cache().
> > 	(D) The page has been charged before (2) and reuse_swap_page() calls
> > 	    delete_from_swap_cache().
> > 
> > 	    memory.usage/memsw.usage changes to this page/swp_entry will be
> > 	 Case          (A)      (B)       (C)     (D)
> >          Event
> >        Before (2)     0/ 1     0/ 1      1/ 1    1/ 1
> >           ===========================================
> >           (3)        +1/+1    +1/+1     +1/+1   +1/+1
> >           (4)          -       0/ 0       -     -1/ 0
> >           (5)         0/-1     0/ 0     -1/-1    0/ 0
> >           (6)          -       0/-1       -      0/-1
> >           ===========================================
> >        Result         1/ 1     1/ 1      1/ 1    1/ 1
> > 
> >        In any cases, charges to this page should be 1/ 1.
> > 
> > In case of (D), mem_cgroup_try_get_from_swapcache() returns NULL
> > (because lookup_swap_cgroup() returns NULL), so "+1/+1" at (3) means
> > charges to the memcg("foo") to which the "current" belongs.
> 
> Hmm...in try_charge_swapin(), if !PageSwapCache(),
> it seems no charges and returns NULL...(means commit will not occur.)
> Could you clarify ?
> 
I'm saying about PageSwapCache() case.
IIUC, swapcache which has been unmapped but has not been removed from
swapcache yet on swap-out path (so not uncharged yet) can go through
this (D) path.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
