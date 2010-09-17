Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EE3786B0078
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 20:50:52 -0400 (EDT)
Message-Id: <1284684653.10161.1395434085@webmail.messagingengine.com>
From: "Robert Mueller" <robm@fastmail.fm>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="us-ascii"
References: <1284349152.15254.1394658481@webmail.messagingengine.com>
 <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1009161153210.22849@router.home>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
In-Reply-To: <alpine.DEB.2.00.1009161153210.22849@router.home>
Reply-To: robm@fastmail.fm
Date: Fri, 17 Sep 2010 10:50:53 +1000
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>


> > > Having very little knowledge of what this actually does, I'd just
> > > like to point out that from a users point of view, it's really
> > > annoying for your machine to be crippled by a default kernel
> > > setting that's pretty obscure.
>
> Thats an issue of the NUMA BIOS information. Kernel defaults to zone
> reclaim if the cost of accessing remote memory vs local memory crosses
> a certain threshhold which usually impacts performance.

We use what I thought was a fairly standard server type motherboard and
CPU combination, and I was surprised that things were so badly broken
for a standard usage scenario with a vanilla kernel with a default
configuration.

I'd point out that the cost of a remote memory access is many, many
orders of magnitude less than having to go back to disk! The problem is
that with zone_reclaim_mode = 1 it seems lots of memory was being wasted
that could be used as disk cache.

> > Yes, sadly intel motherboard turn on zone_reclaim_mode by
> > default. and current zone_reclaim_mode doesn't fit file/web
> > server usecase ;-)
>
> Or one could also say that the web servers are not designed to
> properly distribute the load on a complex NUMA based memory
> architecture of todays Intel machines.

I don't think this is any fault of how the software works. It's a *very*
standard "pre-fork child processes, allocate incoming connections to a
child process, open and mmap one or more files to read data from them".
That's not exactly a weird programming model, and it's bad that the
kernel is handling that case very badly with everything default.

> So would enabling memory interleave in the BIOS to get the machine to
> not consider the memory distances but average out the NUMA effects.

We'll see if the BIOS has an option for that and try it out. I'd like to
document for others that encounter this problem ways around it.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
