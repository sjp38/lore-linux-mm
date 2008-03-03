Date: Mon, 3 Mar 2008 12:06:05 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v8
Message-ID: <20080303180605.GA3552@sgi.com>
References: <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random> <20080303032934.GA3301@wotan.suse.de> <20080303125152.GS8091@v2.random> <20080303131017.GC13138@wotan.suse.de> <20080303151859.GA19374@sgi.com> <20080303165910.GA23998@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080303165910.GA23998@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 03, 2008 at 05:59:10PM +0100, Nick Piggin wrote:
> On Mon, Mar 03, 2008 at 09:18:59AM -0600, Jack Steiner wrote:
> > On Mon, Mar 03, 2008 at 02:10:17PM +0100, Nick Piggin wrote:
> > > On Mon, Mar 03, 2008 at 01:51:53PM +0100, Andrea Arcangeli wrote:
> > > > On Mon, Mar 03, 2008 at 04:29:34AM +0100, Nick Piggin wrote:
> > > > > to something I prefer. Others may not, but I'll post them for debate
> > > > > anyway.
> > > > 
> > > > Sure, thanks!
> > > > 
> > > > > > I didn't drop invalidate_page, because invalidate_range_begin/end
> > > > > > would be slower for usages like KVM/GRU (we don't need a begin/end
> > > > > > there because where invalidate_page is called, the VM holds a
> > > > > > reference on the page). do_wp_page should also use invalidate_page
> > > > > > since it can free the page after dropping the PT lock without losing
> > > > > > any performance (that's not true for the places where invalidate_range
> > > > > > is called).
> > > > > 
> > > > > I'm still not completely happy with this. I had a very quick look
> > > > > at the GRU driver, but I don't see why it can't be implemented
> > > > > more like the regular TLB model, and have TLB insertions depend on
> > > > > the linux pte, and do invalidates _after_ restricting permissions
> > > > > to the pte.
> > > > > 
> > > > > Ie. I'd still like to get rid of invalidate_range_begin, and get
> > > > > rid of invalidate calls from places where permissions are relaxed.
> > > > 
> > > > _begin exists because by the time _end is called, the VM already
> > > > dropped the reference on the page. This way we can do a single
> > > > invalidate no matter how large the range is. I don't see ways to
> > > > remove _begin while still invoking _end a single time for the whole
> > > > range.

The range invalidates have a performance advantage for the GRU. TLB invalidates
on the GRU are relatively slow (usec) and interfere somewhat with the performance
of other active GRU instructions. Invalidating a large chunk of addresses with
a single GRU TLBINVAL operation is must faster than issuing a stream of single
page TLBINVALs.

I expect this performance advantage will also apply to other users of mmuops.

> > > 
> > > Is this just a GRU problem? Can't we just require them to take a ref
> > > on the page (IIRC Jack said GRU could be changed to more like a TLB
> > > model).
> > 
> > Maintaining a long-term reference on a page is a problem. The GRU does not
> > currently maintain tables to track the pages for which dropins have been done.
> > 
> > The GRU has a large internal TLB and is designed to reference up to 8PB of
> > memory. The size of the tables to track this many referenced pages would be
> > a problem (at best).
> 
> Is it any worse a problem than the pagetables of the processes which have
> their virtual memory exported to GRU? AFAIKS, no; it is on the same
> magnitude of difficulty. So you could do it without introducing any
> fundamental problem (memory usage might be increased by some constant
> factor, but I think we can cope with that in order to make the core patch
> really nice and simple).

Functionally, the GRU is very close to what I would consider to be the
"standard TLB" model. Dropins and flushs map closely to processor dropins
and flushes for cpus.  The internal structure of the GRU TLB is identical to
the TLB of existing cpus.  Requiring the GRU driver to track dropins with
long term page references seems to me a deviation from having the basic
mmuops support a "standard TLB" model. AFAIK, no other processor requires
this.

Tracking TLB dropins (and long term page references) could be done but it
adds significant complexity and scaling issues. The size of the tables to
track many TB (to PB) of memory can get large. If the memory is being
referenced by highly threaded applications, then the problem becomes even
more complex. Either tables must be replicated per-thread (and require even
more memory), or the table structure becomes even more complex to deal with
node locality, cacheline bouncing, etc.

Try to avoid a requirement to track dropins with long term page references.


> It is going to be really easy to add more weird and wonderful notifiers
> later that deviate from our standard TLB model. It would be much harder to
> remove them. So I really want to see everyone conform to this model first.

Agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
