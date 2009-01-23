Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 979F46B0047
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:53:11 -0500 (EST)
Date: Fri, 23 Jan 2009 16:53:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123155307.GB14517@wotan.suse.de>
References: <20090114155923.GC1616@wotan.suse.de> <Pine.LNX.4.64.0901141219140.26507@quilx.com> <20090115061931.GC17810@wotan.suse.de> <Pine.LNX.4.64.0901151434150.28387@quilx.com> <20090116034356.GM17810@wotan.suse.de> <Pine.LNX.4.64.0901161509160.27283@quilx.com> <20090119061856.GB22584@wotan.suse.de> <alpine.DEB.1.10.0901211903540.18367@qirst.com> <20090123040913.GG20098@wotan.suse.de> <alpine.DEB.1.10.0901231033210.32253@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0901231033210.32253@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2009 at 10:41:15AM -0500, Christoph Lameter wrote:
> On Fri, 23 Jan 2009, Nick Piggin wrote:
> 
> > > No it cannot because in SLUB objects must come from the same page.
> > > Multiple objects in a queue will only ever require a single page and not
> > > multiple like in SLAB.
> >
> > I don't know how that solves the problem. Task with memory policy A
> > allocates an object, which allocates the "fast" page with policy A
> > and allocates an object. Then context switch to task with memory
> > policy B which allocates another object, which is taken from the page
> > allocated with policy A. Right?
> 
> Correct. But this is only an issue if you think about policies applying to
> individual object allocations (like realized in SLAB). If policies only
> apply to pages (which is sufficient for balancing IMHO) then this is okay.

According to memory policies, a task's memory policy is supposed to
apply to its slab allocations too.

 
> > > (OK this doesn't give the wrong policy 100% of the time; I thought
> > there could have been a context switch race during page allocation
> > that would result in 100% incorrect, but anyway it could still be
> > significantly incorrect couldn't it?)
> 
> Memory policies are applied in a fuzzy way anyways. A context switch can
> result in page allocation action that changes the expected interleave
> pattern. Page populations in an address space depend on the task policy.
> So the exact policy applied to a page depends on the task. This isnt an
> exact thing.

There are other memory policies than just interleave though.

 
> >  "the first cpu will consume more and more memory from the page allocator
> >   whereas the second will build up huge per cpu lists"
> >
> > And this is wrong. There is another possible issue where every single
> > object on the freelist might come from a different (and otherwise free)
> > page, and thus eg 100 8 byte objects might consume 400K.
> >
> > That's not an invalid concern, but I think it will be quite rare, and
> > the periodic queue trimming should naturally help this because it will
> > cycle out those objects and if new allocations are needed, they will
> > come from new pages which can be packed more densely.
> 
> Well but you said that you would defer the trimming (due to latency
> concerns). The longer you defer the larger the lists will get.

But that is wrong. The lists obviously have high water marks that
get trimmed down. Periodic trimming as I keep saying basically is
alrady so infrequent that it is irrelevant (millions of objects
per cpu can be allocated anyway between existing trimming interval)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
