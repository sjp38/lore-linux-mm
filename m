Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 06D1C6B006A
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:31:24 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4FDDC82C53D
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:32:34 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9TZ0WUR41q5s for <linux-mm@kvack.org>;
	Wed, 21 Jan 2009 19:32:34 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 51C933040C3
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:17:28 -0500 (EST)
Date: Wed, 21 Jan 2009 19:13:44 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090119061856.GB22584@wotan.suse.de>
Message-ID: <alpine.DEB.1.10.0901211903540.18367@qirst.com>
References: <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com> <20090114150900.GC25401@wotan.suse.de> <20090114152207.GD25401@wotan.suse.de> <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com> <20090114155923.GC1616@wotan.suse.de>
 <Pine.LNX.4.64.0901141219140.26507@quilx.com> <20090115061931.GC17810@wotan.suse.de> <Pine.LNX.4.64.0901151434150.28387@quilx.com> <20090116034356.GM17810@wotan.suse.de> <Pine.LNX.4.64.0901161509160.27283@quilx.com> <20090119061856.GB22584@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jan 2009, Nick Piggin wrote:

> > > You only go to the allocator when the percpu queue goes empty though, so
> > > if memory policy changes (eg context switch or something), then subsequent
> > > allocations will be of the wrong policy.
> >
> > The per cpu queue size in SLUB is limited by the queues only containing
> > objects from the same page. If you have large queues like SLAB/SLQB(?)
> > then this could be an issue.
>
> And it could be a problem in SLUB too. Chances are that several allocations
> will be wrong after every policy switch. I could describe situations in which
> SLUB will allocate with the _wrong_ policy literally 100% of the time.

No it cannot because in SLUB objects must come from the same page.
Multiple objects in a queue will only ever require a single page and not
multiple like in SLAB.

> > That means large amounts of memory are going to be caught in these queues.
> > If its per cpu and one cpu does allocation and the other frees then the
> > first cpu will consume more and more memory from the page allocator
> > whereas the second will build up huge per cpu lists.
>
> Wrong. I said I would allow an option to turn off *periodic trimming*.
> Or just modify the existing tunables or look at making the trimming
> more fine grained etc etc. I won't know until I see a workload where it
> hurts, and I will try to solve it then.

You are not responding to the issue. If you have queues that contain
objects from multiple pages then every object pointer in these queues can
pin a page although this actually is a free object.

> > It seems that on SMP systems SLQB will actually increase the number of
> > queues since it needs 2 queues per cpu instead of the 1 of SLAB.
>
> I don't know what you mean when you say queues, but SLQB has more
> than 2 queues per CPU. Great. I like them ;)

This gets better and better.

> > SLAB also
> > has resizable queues.
>
> Not significantly because that would require large memory allocations for
> large queues. And there is no code there to do runtime resizing.

Groan. Please have a look at do_tune_cpucache() in slab.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
