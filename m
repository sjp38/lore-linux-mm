Date: Sun, 3 Feb 2008 03:17:04 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080203021704.GC7185@v2.random>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random> <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com> <20080131234101.GS7185@v2.random> <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com> <20080201120955.GX7185@v2.random> <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2008 at 11:23:57AM -0800, Christoph Lameter wrote:
> Yes so your invalidate_range is still some sort of dysfunctional 
> optimization? Gazillions of invalidate_page's will have to be executed 
> when tearing down large memory areas.

I don't know if gru can flush the external TLB references with a
single instruction like the cpu can do by overwriting %cr3. As far as
vmx/svm are concerned, you got to do some fixed amount of work on the
rmap structures and each spte, for each 4k invalidated regardless of
page/pages/range/ranges. You can only share the cost of the lock and
of the memslot lookup, so you lookup and take the lock once and you
drop 512 sptes instead of just 1. Similar to what we do in the main
linux VM by taking the PT lock for every 512 sptes.

So you worry about gazillions of invalidate_page without taking into
account that even if you call invalidate_range_end(0, -1ULL) KVM will
have to mangle over 4503599627370496 rmap entries anyway. Yes calling
1 invalidate_range_end instead of 4503599627370496 invalidate_page,
will be faster, but not much faster. For KVM it remains an O(N)
operation, where N is the number of pages. I'm not so sure we need to
worry about my invalidate_pages being limited to 512 entries.

Perhaps GRU is different, I'm just describing the KVM situation here.

As far as KVM is concerned it's more sensible to be able to scale when
there are 1024 kvm threads on 1024 cpus and each kvm-vcpu is accessing
a different guest physical page (especially when new chunks of memory
are allocated for the first time) that won't collide the whole time on
naturally aligned 2M chunks of virtual addresses.

> And that would not be enough to hold of new references? With small tweaks 
> this should work with a common scheme. We could also redefine the role 
> of _start and _end slightly to just require that the refs are removed when 
> _end completes. That would allow the KVM page count ref to work as is now 
> and would avoid the individual invalidate_page() callouts.

I can already only use _end and ignore _start, only remaining problem
is this won't be 100% coherent (my patch is 100% coherent thanks to PT
lock implicitly serializing follow_page/get_user_pages of the KVM/GRU
secondary MMU faults). My approach give a better peace of mind with
full scalability and no lock recursion when it's the KVM page fault
that invokes get_user_pages that invokes the linux page fault routines
that will try to execute _start taking the lock to block the page
fault that is already running...

> > > The GRU has no page table on its own. It populates TLB entries on demand 
> > > using the linux page table. There is no way it can figure out when to 
> > > drop page counts again. The invalidate calls are turned directly into tlb 
> > > flushes.
> > 
> > Yes, this is why it can't serialize follow_page with only the PT lock
> > with your patch. KVM may do it once you add start,end to range_end
> > only thanks to the additional pin on the page.
> 
> Right but that pin requires taking a refcount which we cannot do.

GRU can use my patch without the pin. XPMEM obviously can't use my
patch as my invalidate_page[s] are under the PT lock (a feature to fit
GRU/KVM in the simplest way), this is why an incremental patch adding
invalidate_range_start/end would be required to support XPMEM too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
