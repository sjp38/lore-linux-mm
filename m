Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2866B005A
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 05:54:22 -0400 (EDT)
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
	 <200910190133.33183.elendil@planet.nl>
	 <1255912562.6824.9.camel@penberg-laptop>
	 <200910190444.55867.elendil@planet.nl>
	 <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu>
Date: Mon, 19 Oct 2009 12:54:11 +0300
Message-Id: <1255946051.5941.2.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tobi Oetiker <tobi@oetiker.ch>
Cc: Frans Pop <elendil@planet.nl>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, 2009-10-19 at 11:49 +0200, Tobi Oetiker wrote:
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

Yup, it almost certainly is. Does this patch help?

http://lkml.org/lkml/2009/10/16/89

Frans, did you ever get around retesting with just the above patch
applied?

			Pekka

> Oct 19 07:10:02 johan kernel: [23565.684110] swapper: page allocation failure. order:5, mode:0x4020 [kern.warning]
> Oct 19 07:10:02 johan kernel: [23565.684118] Pid: 0, comm: swapper Not tainted 2.6.31-02063104-generic #02063104 [kern.warning]
> Oct 19 07:10:02 johan kernel: [23565.684121] Call Trace: [kern.warning]
> Oct 19 07:10:02 johan kernel: [23565.684124]  <IRQ>  [<ffffffff810da5a2>] __alloc_pages_slowpath+0x3b2/0x4c0 [kern.warning]
> 
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
