Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 615FF6B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 10:59:55 -0400 (EDT)
Date: Mon, 19 Oct 2009 15:59:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091019145954.GH9036@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910190133.33183.elendil@planet.nl> <1255912562.6824.9.camel@penberg-laptop> <200910190444.55867.elendil@planet.nl> <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu> <20091019133146.GB9036@csn.ul.ie> <alpine.DEB.2.00.0910191538450.8526@sebohet.brgvxre.pu> <20091019140957.GE9036@csn.ul.ie> <alpine.DEB.2.00.0910191613580.8526@sebohet.brgvxre.pu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910191613580.8526@sebohet.brgvxre.pu>
Sender: owner-linux-mm@kvack.org
To: Tobias Oetiker <tobi@oetiker.ch>
Cc: Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 04:16:36PM +0200, Tobias Oetiker wrote:
> Hi Mel,
> 
> Today Mel Gorman wrote:
> 
> > On Mon, Oct 19, 2009 at 03:40:05PM +0200, Tobias Oetiker wrote:
> > > Hi Mel,
> > >
> > > Today Mel Gorman wrote:
> > >
> > > > On Mon, Oct 19, 2009 at 11:49:08AM +0200, Tobi Oetiker wrote:
> > > > > Today Frans Pop wrote:
> > > > >
> > > > > >
> > > > > > I'm starting to think that this commit may not be directly related to high
> > > > > > order allocation failures. The fact that I'm seeing SKB allocation
> > > > > > failures earlier because of this commit could be just a side effect.
> > > > > > It could be that instead the main impact of this commit is on encrypted
> > > > > > file system and/or encrypted swap (kcryptd).
> > > > > >
> > > > > > Besides mm the commit also touches dm-crypt (and nfs/write.c, but as I'm
> > > > > > only reading from NFS that's unlikely).
> > > > >
> > > > > I have updated a fileserver to 2.6.31 today and I see page
> > > > > allocation failures from several parts of the system ... mostly nfs though ... (it is a nfs server).
> > > > > So I guess the problem must be quite generic:
> > > > >
> > > > >
> > > > > Oct 19 07:10:02 johan kernel: [23565.684110] swapper: page allocation failure. order:5, mode:0x4020 [kern.warning]
> > > > > Oct 19 07:10:02 johan kernel: [23565.684118] Pid: 0, comm: swapper Not tainted 2.6.31-02063104-generic #02063104 [kern.warning]
> > > > > Oct 19 07:10:02 johan kernel: [23565.684121] Call Trace: [kern.warning]
> > > > > Oct 19 07:10:02 johan kernel: [23565.684124]  <IRQ>  [<ffffffff810da5a2>] __alloc_pages_slowpath+0x3b2/0x4c0 [kern.warning]
> > > > >
> > > >
> > > > What's the rest of the stack trace? I'm wondering where a large number
> > > > of order-5 GFP_ATOMIC allocations are coming from. It seems different to
> > > > the e100 problem where there is one GFP_ATOMIC allocation while the
> > > > firmware is being loaded.
> > >
> > > Oct 19 07:10:02 johan kernel: [23565.684110] swapper: page allocation failure. order:5, mode:0x4020 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684118] Pid: 0, comm: swapper Not tainted 2.6.31-02063104-generic #02063104 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684121] Call Trace: [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684124]  <IRQ>  [<ffffffff810da5a2>] __alloc_pages_slowpath+0x3b2/0x4c0 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684157]  [<ffffffff810da7e5>] __alloc_pages_nodemask+0x135/0x140 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684164]  [<ffffffff815065b4>] ? _spin_unlock_bh+0x14/0x20 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684170]  [<ffffffff8110b368>] kmalloc_large_node+0x68/0xc0 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684175]  [<ffffffff8110f15a>] __kmalloc_node_track_caller+0x11a/0x180 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684181]  [<ffffffff8140ffd2>] ? skb_copy+0x32/0xa0 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684185]  [<ffffffff8140d8b6>] __alloc_skb+0x76/0x180 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684205]  [<ffffffff8140ffd2>] skb_copy+0x32/0xa0 [kern.warning]
> > > Oct 19 07:10:02 johan kernel: [23565.684221]  [<ffffffffa050f33c>] vboxNetFltLinuxPacketHandler+0x5c/0xd0 [vboxnetflt] [kern.warning]
> >
> > Is the MTU set very high between the host and virtualised machine?
> >
> > Can you test please with the patch at http://lkml.org/lkml/2009/10/16/89
> > applied and with commits 373c0a7e and 8aa7e847 reverted please?
> 
> if you can send me a consolidated patch which does apply to
> 2.6.31.4 I will be glad to try ...
> 

Sure

==== CUT HERE ====
