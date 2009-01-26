Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 906AA6B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:37:44 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7DA0182C25F
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:39:23 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4ahLYEZ7+JvQ for <linux-mm@kvack.org>;
	Mon, 26 Jan 2009 12:39:23 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B95F482C260
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:39:18 -0500 (EST)
Date: Mon, 26 Jan 2009 12:34:21 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090123161017.GC14517@wotan.suse.de>
Message-ID: <alpine.DEB.1.10.0901261230540.1908@qirst.com>
References: <20090114150900.GC25401@wotan.suse.de> <Pine.LNX.4.64.0901141158090.26507@quilx.com> <20090115060330.GB17810@wotan.suse.de> <Pine.LNX.4.64.0901151320250.26467@quilx.com> <20090116031940.GL17810@wotan.suse.de> <Pine.LNX.4.64.0901161500080.27283@quilx.com>
 <20090119054730.GA22584@wotan.suse.de> <alpine.DEB.1.10.0901211914140.18367@qirst.com> <20090123041756.GH20098@wotan.suse.de> <alpine.DEB.1.10.0901231042380.32253@qirst.com> <20090123161017.GC14517@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jan 2009, Nick Piggin wrote:

> > SLUB can directly free an object to any slab page. "Queuing" on free via
> > the per cpu slab is only possible if the object came from that per cpu
> > slab. This is typically only the case for objects that were recently
> > allocated.
>
> Ah yes ok that's right. But then you don't get LIFO allocation
> behaviour for those cases.

But you get more TLB local allocations.

> > > hot objects when you switch to different "fast" pages. I don't consider
> > > this to be "queueing done right".
> >
> > Yes you can loose track of caching hot objects. That is one of the
> > concerns with the SLUB approach. On the other hand: Caching architectures
> > get more and more complex these days (especially in a NUMA system). The
>
> Because it is more important to get good cache behaviour.

Its going to be quite difficult to realize algorithm that guestimate what
information the processor keeps in its caches. The situation is quite
complex in NUMA systems.

> So I think it is wrong to say it requires more metadata handling. SLUB
> will have to switch pages more often or free objects to pages other than
> the "fast" page (what do you call it?), so quite often I think you'll
> find SLUB has just as much if not more metadata handling.

Its the per cpu slab. SLUB does not switch pages often but frees objects
not from the per cpu slab directly with minimal overhead compared to a per
cpu slab free. The overhead is much less than the SLAB slowpath which has
to be taken for alien caches etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
