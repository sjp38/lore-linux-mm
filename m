Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C7E5B6B003D
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 23:08:05 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator
Date: Wed, 4 Feb 2009 15:07:32 +1100
References: <20090114155923.GC1616@wotan.suse.de> <200902031253.28078.nickpiggin@yahoo.com.au> <alpine.DEB.1.10.0902031217390.17910@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0902031217390.17910@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902041507.33464.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 04 February 2009 04:33:14 Christoph Lameter wrote:
> On Tue, 3 Feb 2009, Nick Piggin wrote:
> > Quite obviously it should. Behaviour of a slab allocation on behalf of
> > some task constrained within a given node should not depend on the task
> > which has previously run on this CPU and made some allocations. Surely
> > you can see this behaviour is not nice.
>
> If you want cache hot objects then its better to use what a prior task
> has used. This opportunistic use is only done if the task is not asking
> for memory from a specifc node. There is another tradeoff here.
>
> SLABs method there is to ignore all caching advantages even if the task
> did not ask for memory from a specific node. So it gets cache cold objects
> and if the node to allow from is remote then it always must use the slow
> path.

Yeah, but I don't think you actually demonstrated any real advantages
to it, and there are obvious failure modes where constraints aren't
obeyed, so I'm going to leave it as-is in SLQB.

Objects where cache hotness tends to be most important are the shorter
lived ones, and objects where constraints matter are longer lived ones,
so I think this is pretty reasonable.

Also, you've just been spending lots of time arguing that cache hotness
is not so important (because SLUB doesn't do LIFO like SLAB and SLQB).


> > > Which have similar issues since memory policy application is depending
> > > on a task policy and on memory migration that has been applied to an
> > > address range.
> >
> > What similar issues? If a task ask to have slab allocations constrained
> > to node 0, then SLUB hands out objects from other nodes, then that's bad.
>
> Of course. A task can ask to have allocations from node 0 and it will get
> the object from node 0. But if the task does not care to ask for data
> from a specific node then it can be satisfied from the cpu slab which
> contains cache hot objects.

But if it is using constrained allocations, then it is also asking for
allocations from node 0.


> > > > But that is wrong. The lists obviously have high water marks that
> > > > get trimmed down. Periodic trimming as I keep saying basically is
> > > > alrady so infrequent that it is irrelevant (millions of objects
> > > > per cpu can be allocated anyway between existing trimming interval)
> > >
> > > Trimming through water marks and allocating memory from the page
> > > allocator is going to be very frequent if you continually allocate on
> > > one processor and free on another.
> >
> > Um yes, that's the point. But you previously claimed that it would just
> > grow unconstrained. Which is obviously wrong. So I don't understand what
> > your point is.
>
> It will grow unconstrained if you elect to defer queue processing. That
> was what we discussed.

And I just keep pointing out that you are wrong (this must be the 4th time).

We were talking about deferring the periodic queue reaping. SLQB will still
constrain the queue sizes to the high watermarks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
