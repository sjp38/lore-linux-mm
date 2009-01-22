Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B060F6B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 04:27:13 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <alpine.DEB.1.10.0901211903540.18367@qirst.com>
References: <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
	 <20090114150900.GC25401@wotan.suse.de>
	 <20090114152207.GD25401@wotan.suse.de>
	 <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>
	 <20090114155923.GC1616@wotan.suse.de>
	 <Pine.LNX.4.64.0901141219140.26507@quilx.com>
	 <20090115061931.GC17810@wotan.suse.de>
	 <Pine.LNX.4.64.0901151434150.28387@quilx.com>
	 <20090116034356.GM17810@wotan.suse.de>
	 <Pine.LNX.4.64.0901161509160.27283@quilx.com>
	 <20090119061856.GB22584@wotan.suse.de>
	 <alpine.DEB.1.10.0901211903540.18367@qirst.com>
Date: Thu, 22 Jan 2009 11:27:10 +0200
Message-Id: <1232616430.14549.11.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Mon, 19 Jan 2009, Nick Piggin wrote:
> > > > You only go to the allocator when the percpu queue goes empty though, so
> > > > if memory policy changes (eg context switch or something), then subsequent
> > > > allocations will be of the wrong policy.
> > >
> > > The per cpu queue size in SLUB is limited by the queues only containing
> > > objects from the same page. If you have large queues like SLAB/SLQB(?)
> > > then this could be an issue.
> >
> > And it could be a problem in SLUB too. Chances are that several allocations
> > will be wrong after every policy switch. I could describe situations in which
> > SLUB will allocate with the _wrong_ policy literally 100% of the time.

On Wed, 2009-01-21 at 19:13 -0500, Christoph Lameter wrote:
> No it cannot because in SLUB objects must come from the same page.
> Multiple objects in a queue will only ever require a single page and not
> multiple like in SLAB.

There's one potential problem with "per-page queues", though. The bigger
the object, the smaller the "queue" (i.e. less objects per page). Also,
partial lists are less likely to help for big objects because they get
emptied so quickly and returned to the page allocator. Perhaps we should
do a small "full list" for caches with large objects?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
