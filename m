Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F38616B0092
	for <linux-mm@kvack.org>; Wed, 27 May 2009 00:37:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R4c3EU007840
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 May 2009 13:38:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5527345DD74
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:38:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 341D045DD72
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:38:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 20C881DB8012
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:38:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B84E21DB8015
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:38:02 +0900 (JST)
Date: Wed, 27 May 2009 13:36:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/5] add SWAP_HAS_CACHE flag to swap_map
Message-Id: <20090527133629.142aa42f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090527130246.95dadb2c.nishimura@mxp.nes.nec.co.jp>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121547.ce866fe4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090527130246.95dadb2c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 May 2009 13:02:46 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -1067,21 +1113,21 @@ static int try_to_unuse(unsigned int typ
> >  		}
> >  
> >  		/*
> > -		 * How could swap count reach 0x7fff when the maximum
> > -		 * pid is 0x7fff, and there's no way to repeat a swap
> > -		 * page within an mm (except in shmem, where it's the
> > -		 * shared object which takes the reference count)?
> > -		 * We believe SWAP_MAP_MAX cannot occur in Linux 2.4.
> > -		 *
> > +		 * How could swap count reach 0x7ffe ?
> > +		 * There's no way to repeat a swap page within an mm
> > +		 * (except in shmem, where it's the shared object which takes
> > +		 * the reference count)?
> > +		 * We believe SWAP_MAP_MAX cannot occur.(if occur, unsigned
> > +		 * short is too small....)
> >  		 * If that's wrong, then we should worry more about
> >  		 * exit_mmap() and do_munmap() cases described above:
> >  		 * we might be resetting SWAP_MAP_MAX too early here.
> >  		 * We know "Undead"s can happen, they're okay, so don't
> >  		 * report them; but do report if we reset SWAP_MAP_MAX.
> >  		 */
> > -		if (*swap_map == SWAP_MAP_MAX) {
> > +		if (swap_count(*swap_map) == SWAP_MAP_MAX) {
> >  			spin_lock(&swap_lock);
> > -			*swap_map = 1;
> > +			*swap_map = make_swap_count(0, 1);
> Can we assume the entry has SWAP_HAS_CACHE here ?
> Shouldn't we check PageSwapCache beforehand ?
> 

IIUC, in this try_to_unuse code, the page is added to swap cache and locked
before reaches here. But....ah,ok, unuse_mm() may release lock_page() before
reach here. Then...

if (PageSwapCache(page) && swap_count(*swap_map) == SWAP_MAP_MAX)

is right ? (maybe original code, set to "1" is also buggy.)

Thanks,
-Kame


> >  			spin_unlock(&swap_lock);
> >  			reset_overflow = 1;
> >  		}
> 
> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
