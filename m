Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AC2186B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 22:36:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2A2aNaw017742
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 10 Mar 2009 11:36:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D27945DE52
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 11:36:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E2E345DE51
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 11:36:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E93351DB8044
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 11:36:22 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 946FA1DB803F
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 11:36:22 +0900 (JST)
Date: Tue, 10 Mar 2009 11:35:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: charge swapcache to proper memcg
Message-Id: <20090310113502.d272fc2a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Mar 2009 10:07:07 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> memcg_test.txt says at 4.1:
> 
> 	This swap-in is one of the most complicated work. In do_swap_page(),
> 	following events occur when pte is unchanged.
> 
> 	(1) the page (SwapCache) is looked up.
> 	(2) lock_page()
> 	(3) try_charge_swapin()
> 	(4) reuse_swap_page() (may call delete_swap_cache())
> 	(5) commit_charge_swapin()
> 	(6) swap_free().
> 
> 	Considering following situation for example.
> 
> 	(A) The page has not been charged before (2) and reuse_swap_page()
> 	    doesn't call delete_from_swap_cache().
> 	(B) The page has not been charged before (2) and reuse_swap_page()
> 	    calls delete_from_swap_cache().
> 	(C) The page has been charged before (2) and reuse_swap_page() doesn't
> 	    call delete_from_swap_cache().
> 	(D) The page has been charged before (2) and reuse_swap_page() calls
> 	    delete_from_swap_cache().
> 
> 	    memory.usage/memsw.usage changes to this page/swp_entry will be
> 	 Case          (A)      (B)       (C)     (D)
>          Event
>        Before (2)     0/ 1     0/ 1      1/ 1    1/ 1
>           ===========================================
>           (3)        +1/+1    +1/+1     +1/+1   +1/+1
>           (4)          -       0/ 0       -     -1/ 0
>           (5)         0/-1     0/ 0     -1/-1    0/ 0
>           (6)          -       0/-1       -      0/-1
>           ===========================================
>        Result         1/ 1     1/ 1      1/ 1    1/ 1
> 
>        In any cases, charges to this page should be 1/ 1.
> 
> In case of (D), mem_cgroup_try_get_from_swapcache() returns NULL
> (because lookup_swap_cgroup() returns NULL), so "+1/+1" at (3) means
> charges to the memcg("foo") to which the "current" belongs.

Hmm...in try_charge_swapin(), if !PageSwapCache(),
it seems no charges and returns NULL...(means commit will not occur.)
Could you clarify ?

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
