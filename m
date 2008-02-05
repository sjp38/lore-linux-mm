Date: Tue, 5 Feb 2008 23:26:58 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080205222657.GG7441@v2.random>
References: <20080201120955.GX7185@v2.random> <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com> <20080203021704.GC7185@v2.random> <Pine.LNX.4.64.0802041106370.9656@schroedinger.engr.sgi.com> <20080205052525.GD7441@v2.random> <Pine.LNX.4.64.0802042206200.6739@schroedinger.engr.sgi.com> <20080205180802.GE7441@v2.random> <Pine.LNX.4.64.0802051013440.11705@schroedinger.engr.sgi.com> <20080205205519.GF7441@v2.random> <Pine.LNX.4.64.0802051400200.14665@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802051400200.14665@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2008 at 02:06:23PM -0800, Christoph Lameter wrote:
> On Tue, 5 Feb 2008, Andrea Arcangeli wrote:
> 
> > On Tue, Feb 05, 2008 at 10:17:41AM -0800, Christoph Lameter wrote:
> > > The other approach will not have any remote ptes at that point. Why would 
> > > there be a coherency issue?
> > 
> > It never happens that two threads writes to two different physical
> > pages by working on the same process virtual address. This is an issue
> > only for KVM which is probably ok with it but certainly you can't
> > consider the dependency on the page-pin less fragile or less complex
> > than my PT lock approach.
> 
> You can avoid the page-pin and the pt lock completely by zapping the 
> mappings at _start and then holding off new references until _end.

Avoid the PT lock? The PT lock has to be taken anyway by the linux
VM.

"holding off new references until _end" = per-range mutex less scalar
and more expensive than the PT lock that has to be taken anyway.

> As I said the implementation is up to the caller. Not sure what 
> XPmem is using there but then XPmem is not using follow_page. The GRU 
> would be using a lightway way of locking not rbtrees.

"lightway way of locking" = mm-wide-mutex (not necessary at all if we
take advantage of the per-pte-scalar PT lock that has to be taken
anyway like in my patch)

> Maybe that is true for KVM but certainly not true for the GRU. The GRU is 
> designed to manage several petabytes of memory that may be mapped by a 
> series of Linux instances. If a process only maps a small chunk of 4 
> Gigabytes then we already have to deal with 1 mio callbacks.

KVM is also going to map a lot of stuff, but mapping involves mmap,
munmap/mremap/mprotect not. The size of mmap is irrelevant in both
approaches. optimizing do_exit by making the tlb-miss runtime slower
doesn't sound great to me and that's your patch does if you force GRU
to use it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
