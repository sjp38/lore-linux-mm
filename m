Date: Wed, 20 Feb 2008 07:15:15 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v6
Message-ID: <20080220131515.GF11364@sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080220113313.GD11364@sgi.com> <20080220120324.GW7128@v2.random> <20080220122424.GE11364@sgi.com> <20080220123235.GX7128@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080220123235.GX7128@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 01:32:36PM +0100, Andrea Arcangeli wrote:
> On Wed, Feb 20, 2008 at 06:24:24AM -0600, Robin Holt wrote:
> > We do not need to do any allocation in the messaging layer, all
> > structures used for messaging are allocated at module load time.
> > The allocation discussions we had early on were about trying to
> > rearrange you notifiers to allow a seperate worker thread to do the
> > invalidate and then the main thread would spin waiting for the worker to
> > complete.  That was canned by the moving your notifier to before the
> > lock was grabbed which led us to the point of needing a _begin and _end.
> 
> I thought you called some net/* function inside the mmu notifier
> methods. Those always require several ram allocations internally.

Nope, that was the discussions with the IB folks.  We only use XPC and
both the messages we send and the XPC internals do not need to allocate.

> > So, fundamentally, how would they be different?  Would we be required to
> > add another notifier list to the mm and have two seperate callout
> > points?  Reduction would end up with the same half-registered
> > half-not-registered situation you point out above.  Then further
> > reduction would lead to the elimination of the callouts you have just
> > proposed and using the _begin/_end callouts and we are back to
> > Christoph's current patch.
> 
> Did you miss Nick's argument that we'd need to change some VM lock to
> mutex and solve lock issues first? Are you implying mutex are more
> efficient for the VM? (you may seek support from preempt-rt folks at
> least) or are you implying the VM would better run slower with mutex
> in order to have a single config option?

That would be if we needed to support file backed mappings and hugetlbfs
mappings.  Currently (and for the last 6 years), XPMEM has not supported
either of those.  I don't view either as being a realistic possibility,
but it is certainly something we would need to address before either
could be supported.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
