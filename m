Received: by py-out-1112.google.com with SMTP id f31so265153pyh
        for <linux-mm@kvack.org>; Wed, 08 Aug 2007 00:37:31 -0700 (PDT)
Message-ID: <4a5909270708080037n32be2a73k5c28d33bb02f770b@mail.gmail.com>
Date: Wed, 8 Aug 2007 03:37:31 -0400
From: "Daniel Phillips" <daniel.raymond.phillips@gmail.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070806102922.907530000@chello.nl>
	 <200708061559.41680.phillips@phunq.net>
	 <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
	 <200708061649.56487.phillips@phunq.net>
	 <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On 8/7/07, Christoph Lameter <clameter@sgi.com> wrote:
> > > AFAICT: This patchset is not throttling processes but failing
> > > allocations.
> >
> > Failing allocations?  Where do you see that?  As far as I can see,
> > Peter's patch set allows allocations to fail exactly where the user has
> > always specified they may fail, and in no new places.  If there is a
> > flaw in that logic, please let us know.
>
> See the code added to slub: Allocations are satisfied from the reserve
> patch or they are failing.

First off, what I know about this patch set is, it works.  Without it,
ddsnap deadlocks on network IO, and with it, no deadlock.  We are
niggling over how it works, not whether it works, or whether it is
needed.

Next a confession: I have not yet applied this particular patch and
read the resulting file.  However, the algorithm it is supposed to
implement with respect to slab is:

  1. If the allocation can be satisified in the usual way, do that.
  2. Otherwise, if the GFP flags do not include __GFP_MEMALLOC or
PF_MEMALLOC is not set, fail the allocation
  3. Otherwise, if the memcache's reserve quota is not reached,
satisfy the request, allocating a new page from the MEMALLOC reserve,
but the memcache's reserve counter and succeed
  4. Die.  We are the walking dead.  Do whatever we feel like, for
example fail allocation.  This is a kernel bug, if we are lucky enough
of the kernel will remain running to get some diagnostics.

If it does not implement that algorithm, please shout.

> > > The patchset does not reconfigure the memory reserves as
> > > expected.
> >
> > What do you mean by that?  Expected by who?
>
> What would be expected it some recalculation of min_freekbytes?

I still do not know exactly what you are talking about.  The patch set
provides a means of adjusting the global memalloc reserve when a
memalloc pool user starts or stops.  We could leave that part entirely
out of the patch set and just rely on the reserve being "big enough"
as we have done since the dawn of time.  That would leave less to
niggle about and the reserve adjustment mechanism could  be submitted
later.  Would that be better?

> > > And I suspect that we
> > > have the same issues as in earlier releases with various corner cases
> > > not being covered.
> >
> > Do you have an example?
>
> Try NUMA constraints and zone limitations.

Are you worried about a correctness issue that would prevent the
machine from operating, or are you just worried about allocating
reserve pages to the local node for performance reasons?

> > > Code is added that is supposedly not used.
> >
> > What makes you think that?
>
> Because the argument is that performance does not matter since the code
> patchs are not used.

Used, yes.   Maybe heavily, maybe not.  The point is, with current
kernels you would never get to these new code paths because your
machine would have slowed to a crawl or deadlocked.  So not having the
perfect NUMA implementation of the new memory reserves is perhaps a
new performance issue for NUMA, but it is no show stopper, and
according to design, existing code paths are not degraded by any
measurable extent.  Deadlock in current kernels is a showstopper, that
is what this patch set fixes.

Since there is no regression for NUMA here (there is not supposed to
be anyway) I do not think that adding more complexity to the patch set
to optimize NUMA in this corner case that you could never even get to
before is warranted.  That is properly a follow-on NUMA-specific
patch, analogous to a per-arch optimization.

> > > If it  ever is on a large config then we are in very deep trouble by
> > > the new code paths themselves that serialize things in order to give
> > > some allocations precendence over the other allocations that are made
> > > to fail ....
> >
> > You mean by allocating the reserve memory on the wrong node in NUMA?
>
> No I mean all 1024 processors of our system running into this fail/succeed
> thingy that was added.

If an allocation now fails that would have succeeded in the past, the
patch set is buggy.  I can't say for sure one way or another at this
time of night.  If you see something, could you please mention a
file/line number?

> > That is on a code path that avoids destroying your machine performance
> > or killing the machine entirely as with current kernels, for which a
>
> As far as I know from our systems: The current kernels do not kill the
> machine if the reserves are configured the right way.

Current kernels deadlock on a regular basis doing fancy block IO.  I
am not sure what you mean.

> > few cachelines pulled to another node is a small price to pay.  And you
> > are free to use your special expertise in NUMA to make those fallback
> > paths even more efficient, but first you need to understand what they
> > are doing and why.
>
> There is your problem. The justification is not clear at all and the
> solution likely causes unrelated problems.

Well I hope the justification is clear now.  Not deadlocking is a very
good thing, and we have a before and after test case.  Getting late
here, Peter's email shift starts now ;-)

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
