Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFA06B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 09:31:47 -0400 (EDT)
Date: Mon, 19 Oct 2009 14:31:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091019133146.GB9036@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910190133.33183.elendil@planet.nl> <1255912562.6824.9.camel@penberg-laptop> <200910190444.55867.elendil@planet.nl> <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu>
Sender: owner-linux-mm@kvack.org
To: Tobi Oetiker <tobi@oetiker.ch>
Cc: Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 11:49:08AM +0200, Tobi Oetiker wrote:
> Today Frans Pop wrote:
> 
> >
> > I'm starting to think that this commit may not be directly related to high
> > order allocation failures. The fact that I'm seeing SKB allocation
> > failures earlier because of this commit could be just a side effect.
> > It could be that instead the main impact of this commit is on encrypted
> > file system and/or encrypted swap (kcryptd).
> >
> > Besides mm the commit also touches dm-crypt (and nfs/write.c, but as I'm
> > only reading from NFS that's unlikely).
> 
> I have updated a fileserver to 2.6.31 today and I see page
> allocation failures from several parts of the system ... mostly nfs though ... (it is a nfs server).
> So I guess the problem must be quite generic:
> 
> 
> Oct 19 07:10:02 johan kernel: [23565.684110] swapper: page allocation failure. order:5, mode:0x4020 [kern.warning]
> Oct 19 07:10:02 johan kernel: [23565.684118] Pid: 0, comm: swapper Not tainted 2.6.31-02063104-generic #02063104 [kern.warning]
> Oct 19 07:10:02 johan kernel: [23565.684121] Call Trace: [kern.warning]
> Oct 19 07:10:02 johan kernel: [23565.684124]  <IRQ>  [<ffffffff810da5a2>] __alloc_pages_slowpath+0x3b2/0x4c0 [kern.warning]
> 

What's the rest of the stack trace? I'm wondering where a large number
of order-5 GFP_ATOMIC allocations are coming from. It seems different to
the e100 problem where there is one GFP_ATOMIC allocation while the
firmware is being loaded.

Thanks

> 
> Oct 19 08:59:16 johan kernel: [30120.685647] __ratelimit: 13 callbacks suppressed [kern.warning]
> Oct 19 08:59:16 johan kernel: [30120.685654] nfsd: page allocation failure. order:5, mode:0x4020 [kern.warning]
> Oct 19 08:59:16 johan kernel: [30120.685660] Pid: 6071, comm: nfsd Not tainted 2.6.31-02063104-generic #02063104 [kern.warning]
> Oct 19 08:59:16 johan kernel: [30120.685663] Call Trace: [kern.warning]
> Oct 19 08:59:16 johan kernel: [30120.685666]  <IRQ>  [<ffffffff810da5a2>] __alloc_pages_slowpath+0x3b2/0x4c0 [kern.warning]
> 
> Oct 19 09:36:31 johan kernel: [32355.708345] __ratelimit: 16 callbacks suppressed [kern.warning]
> Oct 19 09:36:31 johan kernel: [32355.708352] nfsd: page allocation failure. order:5, mode:0x4020 [kern.warning]
> Oct 19 09:36:31 johan kernel: [32355.708358] Pid: 6087, comm: nfsd Not tainted 2.6.31-02063104-generic #02063104 [kern.warning]
> Oct 19 09:36:31 johan kernel: [32355.708361] Call Trace: [kern.warning]
> Oct 19 09:36:31 johan kernel: [32355.708364]  <IRQ>  [<ffffffff810da5a2>] __alloc_pages_slowpath+0x3b2/0x4c0 [kern.warning]
> 
> Oct 19 10:52:01 johan kernel: [36885.358312] __ratelimit: 31 callbacks suppressed [kern.warning]
> Oct 19 10:52:01 johan kernel: [36885.358319] nfsd: page allocation failure. order:5, mode:0x4020 [kern.warning]
> Oct 19 10:52:01 johan kernel: [36885.358325] Pid: 6057, comm: nfsd Not tainted 2.6.31-02063104-generic #02063104 [kern.warning]
> Oct 19 10:52:01 johan kernel: [36885.358327] Call Trace: [kern.warning]
> Oct 19 10:52:01 johan kernel: [36885.358331]  <IRQ>  [<ffffffff810da5a2>] __alloc_pages_slowpath+0x3b2/0x4c0 [kern.warning]
> 
> Oct 19 11:12:01 johan kernel: [38085.163831] events/3: page allocation failure. order:5, mode:0x4020 [kern.warning]
> Oct 19 11:12:01 johan kernel: [38085.163840] Pid: 18, comm: events/3 Not tainted 2.6.31-02063104-generic #02063104 [kern.warning]
> Oct 19 11:12:01 johan kernel: [38085.163843] Call Trace: [kern.warning]
> Oct 19 11:12:01 johan kernel: [38085.163846]  <IRQ>  [<ffffffff810da5a2>] __alloc_pages_slowpath+0x3b2/0x4c0 [kern.warning]
> 
> 
> 
> -- 
> Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
> http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900
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
