Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0E98E5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 03:58:46 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3H7xeVe010308
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Apr 2009 16:59:40 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28CCB45DE4E
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 16:59:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B7A4B45DE52
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 16:59:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BB1A1DB804B
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 16:59:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CA8E1DB8043
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 16:59:39 +0900 (JST)
Date: Fri, 17 Apr 2009 16:58:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090417165806.4ca40a08.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090417165036.bdca7163.nishimura@mxp.nes.nec.co.jp>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090319180631.44b0130f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319190118.db8a1dd7.nishimura@mxp.nes.nec.co.jp>
	<20090319191321.6be9b5e8.nishimura@mxp.nes.nec.co.jp>
	<100477cfc6c3c775abc7aecd4ce8c46e.squirrel@webmail-b.css.fujitsu.com>
	<432ace3655a26d2d492a56303369a88a.squirrel@webmail-b.css.fujitsu.com>
	<20090320164520.f969907a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323104555.cb7cd059.nishimura@mxp.nes.nec.co.jp>
	<20090323114118.8b45105f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323140419.40235ce3.nishimura@mxp.nes.nec.co.jp>
	<20090323142242.f6659457.kamezawa.hiroyu@jp.fujitsu.com>
	<20090324173218.4de33b90.nishimura@mxp.nes.nec.co.jp>
	<20090325085713.6f0b7b74.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417153455.c6fe2ba6.nishimura@mxp.nes.nec.co.jp>
	<20090417155411.76901324.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417165036.bdca7163.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Apr 2009 16:50:36 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 17 Apr 2009 15:54:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 17 Apr 2009 15:34:55 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > I made a patch for reclaiming SwapCache from orphan LRU based on your patch,
> > > and have been testing it these days.
> > > 
> > Good trial! 
> > Honestly, I've written a patch to fix this problem in these days but seems to
> > be over-kill ;)
> > 
> > 
> > > Major changes from your version:
> > > - count the number of orphan pages per zone and make the threshold per zone(4MB).
> > > - As for type 2 of orphan SwapCache, they are usually set dirty by add_to_swap.
> > >   But try_to_drop_swapcache(__remove_mapping) can't free dirty pages,
> > >   so add a check and try_to_free_swap to the end of shrink_page_list.
> > > 
> > > It seems work fine, no "pseud leak" of SwapCache can be seen.
> > > 
> > > What do you think ?
> > > If it's all right, I'll merge this with the orphan list framework patch
> > > and send it to Andrew with other fixes of memcg that I have.
> > > 
> > I'm sorry but my answer is "please wait". The reason is..
> > 
> > 1. When global LRU works, the pages will be reclaimed.
> > 2. Global LRU will work finally.
> > 3. While testing, "stale" swap cache cannot be big amount.
> > 
> Hmm, I can't understand 2.
> 
> If (memsize on system) >> (swapsize on system), global LRU doesn't run
> and all the swap space can be used up by these SwapCache.
> This means setting mem.limit can use up all the swap space on the system.
> I've tested with 50MB size of swap and it can be used up in less than 24h.
> I think it's not small.
> 

plz add hook to shrink_zone() to fix this as you did. 
orphan list is overkilling at this stage.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
