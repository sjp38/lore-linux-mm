Date: Fri, 1 Feb 2008 11:23:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
In-Reply-To: <20080201120955.GX7185@v2.random>
Message-ID: <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random>
 <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com>
 <20080131234101.GS7185@v2.random> <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com>
 <20080201120955.GX7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2008, Andrea Arcangeli wrote:

> Note that my #v5 doesn't require to increase the page count all the
> time, so GRU will work fine with #v5.

But that comes with the cost of firing invalidate_page for every page 
being evicted. In order to make your single invalidate_range work without 
it you need to hold a refcount on the page.

> invalidate_page[s] is always called before the page is freed. This
> will require modifications to the tlb flushing code logic to take
> advantage of _pages in certain places. For now it's just safe.

Yes so your invalidate_range is still some sort of dysfunctional 
optimization? Gazillions of invalidate_page's will have to be executed 
when tearing down large memory areas.

> > How does KVM insure the consistency of the shadow page tables? Atomic ops?
> 
> A per-VM mmu_lock spinlock is taken to serialize the access, plus
> atomic ops for the cpu.

And that would not be enough to hold of new references? With small tweaks 
this should work with a common scheme. We could also redefine the role 
of _start and _end slightly to just require that the refs are removed when 
_end completes. That would allow the KVM page count ref to work as is now 
and would avoid the individual invalidate_page() callouts.
 
> > The GRU has no page table on its own. It populates TLB entries on demand 
> > using the linux page table. There is no way it can figure out when to 
> > drop page counts again. The invalidate calls are turned directly into tlb 
> > flushes.
> 
> Yes, this is why it can't serialize follow_page with only the PT lock
> with your patch. KVM may do it once you add start,end to range_end
> only thanks to the additional pin on the page.

Right but that pin requires taking a refcount which we cannot do.

Frankly this looks as if this is a solution that would work only for KVM.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
