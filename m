Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 79CE66B005A
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 23:02:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8T3GJqu031721
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 29 Sep 2009 12:16:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5940045DE54
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 12:16:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 383D145DE52
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 12:16:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E511BE18009
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 12:16:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 91126E1800B
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 12:16:18 +0900 (JST)
Date: Tue, 29 Sep 2009 12:14:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 8/10] memcg: clean up charge/uncharge anon
Message-Id: <20090929121408.7f955f41.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090929120348.0bcb17d1.nishimura@mxp.nes.nec.co.jp>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090925172850.265abe78.kamezawa.hiroyu@jp.fujitsu.com>
	<20090929092413.9526de0b.nishimura@mxp.nes.nec.co.jp>
	<20090929102653.612cc2a4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090929111828.6f9148d6.nishimura@mxp.nes.nec.co.jp>
	<20090929120348.0bcb17d1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Sep 2009 12:03:48 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Just to make sure.
> 
> > > Maybe there is something I don't understand..
> > > IIUC, when page_remove_rmap() is called by do_wp_page(),
> > > there must be pte(s) which points to the page and a pte is guarded by
> > > page table lock. So, I think page_mapcount() > 0 before calling page_remove_rmap()
> > > because there must be a valid pte, at least.
> > > 
> > > Can this scenario happen ?
> > I think so. I intended to mention this case :)
> > I'm sorry for my vague explanation.
> > 
> > > ==
> > >     Thread A.                                      Thread B.
> > > 
> > >     do_wp_page()                                 do_swap_page()
> > >        PageAnon(oldpage)                         
> > >          lock_page()                             lock_page()=> wait.
> > >          reuse = false.
> > >          unlock_page()                           get lock.      
> > >        do copy-on-write
> > >        pte_same() == true
> > >          page_remove_rmap(oldpage) (mapcount goes to -1)
> > >                                                  page_set_anon_rmap() (new anon rmap again)
> > > ==
> > > Then, oldpage's mapcount goes down to 0 and up to 1 immediately.
> > > 
> I meant "process" not "thread".
Okay ;)

> I think this cannot happen in the case of threads, because these page_remove_rmap()
> and page_set_anon_rmap() are called under pte lock(they share the pte).
> 
Anyway, I'll fix this patch.
But Balbir ask me to post batched_charge/uncharge first, this clean up series
will be postponed.

I think..

  1. post softlimit fixes.
  2. batched uncharge/charge
  3. post some fixes from this set.

I personally want to reorder all functions but it makes diff (between versions)
too big. So, I think I should avoid big reorganization.
I'll go moderate way.
Hmm..but I'll do move percpu/perzone functions below definitions of structs.

Thanks,
-Kame

> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
