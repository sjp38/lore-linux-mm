Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D1EFB6B0082
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 23:22:00 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1H4LvYs026280
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Feb 2009 13:21:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B15E845DD7B
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 13:21:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F3D045DD78
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 13:21:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F25F1DB8037
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 13:21:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 079241DB803C
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 13:21:54 +0900 (JST)
Date: Tue, 17 Feb 2009 13:20:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches (v2)
Message-Id: <20090217132039.3504cd3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090217130352.4ba7f91c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090216110844.29795.17804.sendpatchset@localhost.localdomain>
	<20090217090523.975bbec2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090217030526.GA20958@balbir.in.ibm.com>
	<20090217130352.4ba7f91c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Feb 2009 13:03:52 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > > 2. I don't like to change usual direct-memory-reclaim path. It will be obstacles
> > >    for VM-maintaners to improve memory reclaim. memcg's LRU is designed for
> > >    shrinking memory usage and not for avoiding memory shortage. IOW, it's slow routine
> > >    for reclaiming memory for memory shortage.
> > 
> > I don't think I agree here. Direct reclaim is the first indication of
> > shortage and if order 0 pages are short, memcg's above their soft
> > limit can be targetted first.
> > 
> My "slow" means "the overhead seems to be big". The latency will increase.
> 
> About 0-order
> In patch 4/4
> +	did_some_progress = mem_cgroup_soft_limit_reclaim(gfp_mask);
> +	/*
> should be
>         if (!order)
>             did_some_progress = mem....
above is wrong.

if (!order && (gfp_mask & GFP_MOVABLE)) ....Hmm, but this is not correct.
I have no good idea to avoid unnecessary works.

BTW,  why don't you call soft_limit_reclaim from kswapd's path ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
