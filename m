Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 71A916B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 06:57:45 -0400 (EDT)
Date: Tue, 20 Oct 2009 11:57:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091020105746.GD11778@csn.ul.ie>
References: <1255912562.6824.9.camel@penberg-laptop> <200910190444.55867.elendil@planet.nl> <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu> <20091019133146.GB9036@csn.ul.ie> <alpine.DEB.2.00.0910191538450.8526@sebohet.brgvxre.pu> <20091019140957.GE9036@csn.ul.ie> <alpine.DEB.2.00.0910191613580.8526@sebohet.brgvxre.pu> <20091019145954.GH9036@csn.ul.ie> <alpine.DEB.2.00.0910192211230.27123@sebohet.brgvxre.pu> <alpine.DEB.2.00.0910192215450.27123@sebohet.brgvxre.pu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910192215450.27123@sebohet.brgvxre.pu>
Sender: owner-linux-mm@kvack.org
To: Tobias Oetiker <tobi@oetiker.ch>
Cc: Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 10:17:06PM +0200, Tobias Oetiker wrote:
> Hi Mel,
> 
> Today Tobias Oetiker wrote:
> 
> > Hi Mel,
> >
> > Today Mel Gorman wrote:
> >
> > > >
> > > > if you can send me a consolidated patch which does apply to
> > > > 2.6.31.4 I will be glad to try ...
> > > >
> > >
> > > Sure
> > >
> > > ==== CUT HERE ====
> > >
> > > From 6c0215af3b7c39ef7b8083ea38ca3ad93cd3f51f Mon Sep 17 00:00:00 2001
> > > From: Mel Gorman <mel@csn.ul.ie>
> > > Date: Mon, 19 Oct 2009 15:40:43 +0100
> > > Subject: [PATCH] Kick off kswapd after direct reclaim and revert congestion changes
> > >
> > > The following patch is http://lkml.org/lkml/2009/10/16/89 on top of
> > > 2.6.31.4 as well as patches 373c0a7e and 8aa7e847 reverted.
> >
> > it seems to help ... the server has been running for 3 hours now
> > without incident, but then again it is not as active as during the
> > day, ... will report tomorrow.
> 
> while I was writing, the system found that the patch does not realy
> help:
> 
> Oct 19 22:09:52 johan kernel: [11157.121506] smtpd: page allocation failure. order:5, mode:0x4020 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121514] Pid: 19324, comm: smtpd Tainted: G      D    2.6.31.4-oep #1 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121518] Call Trace: [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121521]  <IRQ>  [<ffffffff810cb599>] __alloc_pages_nodemask+0x549/0x650 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121563]  [<ffffffffa02bde3b>] ? __nf_ct_refresh_acct+0xab/0x110 [nf_conntrack] [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121572]  [<ffffffffa02a8337>] ? ipt_do_table+0x2f7/0x610 [ip_tables] [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121580]  [<ffffffff810fac18>] kmalloc_large_node+0x68/0xc0 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121585]  [<ffffffff810fe90a>] __kmalloc_node_track_caller+0x11a/0x180 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121592]  [<ffffffff813ebd42>] ? skb_copy+0x32/0xa0 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121596]  [<ffffffff813e9606>] __alloc_skb+0x76/0x180 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121600]  [<ffffffff813ebd42>] skb_copy+0x32/0xa0 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121615]  [<ffffffffa07dd33c>] vboxNetFltLinuxPacketHandler+0x5c/0xd0 [vboxnetflt] [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121620]  [<ffffffff813f2512>] dev_hard_start_xmit+0x142/0x320 [kern.warning]

Are the number of failures at least reduced or are they occuring at the
same rate? Also, what was the last kernel that worked for you with this
configuration?

Thanks

> Oct 19 22:09:52 johan kernel: [11157.121632]  [<ffffffff8140a2c1>] __qdisc_run+0x1a1/0x230 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121637]  [<ffffffff813f41e0>] dev_queue_xmit+0x2b0/0x3a0 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121642]  [<ffffffff8142349b>] ip_finish_output+0x11b/0x2f0 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121646]  [<ffffffff814236f9>] ip_output+0x89/0xd0 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121650]  [<ffffffff81422710>] ip_local_out+0x20/0x30 [kern.warning]
> Oct 19 22:09:52 johan kernel: [11157.121654]  [<ffffffff81422ffb>] ip_queue_xmit+0x22b/0x3f0 [kern.warning]
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
