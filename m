Date: Tue, 5 Feb 2008 14:06:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
In-Reply-To: <20080205205519.GF7441@v2.random>
Message-ID: <Pine.LNX.4.64.0802051400200.14665@schroedinger.engr.sgi.com>
References: <20080131234101.GS7185@v2.random>
 <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com>
 <20080201120955.GX7185@v2.random> <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com>
 <20080203021704.GC7185@v2.random> <Pine.LNX.4.64.0802041106370.9656@schroedinger.engr.sgi.com>
 <20080205052525.GD7441@v2.random> <Pine.LNX.4.64.0802042206200.6739@schroedinger.engr.sgi.com>
 <20080205180802.GE7441@v2.random> <Pine.LNX.4.64.0802051013440.11705@schroedinger.engr.sgi.com>
 <20080205205519.GF7441@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Andrea Arcangeli wrote:

> On Tue, Feb 05, 2008 at 10:17:41AM -0800, Christoph Lameter wrote:
> > The other approach will not have any remote ptes at that point. Why would 
> > there be a coherency issue?
> 
> It never happens that two threads writes to two different physical
> pages by working on the same process virtual address. This is an issue
> only for KVM which is probably ok with it but certainly you can't
> consider the dependency on the page-pin less fragile or less complex
> than my PT lock approach.

You can avoid the page-pin and the pt lock completely by zapping the 
mappings at _start and then holding off new references until _end.

> > No. It only has to lock the affected range. Remote page faults can occur 
> > while another part of the address space is being invalidated. The 
> > complexity of locking is up to the user of the mmu notifier. A simple 
> > implementation is satisfactory for the GRU right now. Should it become a 
> > problem then the lock granularity can be refined without changing the API.
> 
> That will make the follow_page fast path even slower if it has to
> lookup a rbtree or a list of locked ranges. Still not comparable to
> the PT lock that 1) it's zero cost and 2) it'll provide an even more
> granular scalability.

As I said the implementation is up to the caller. Not sure what 
XPmem is using there but then XPmem is not using follow_page. The GRU 
would be using a lightway way of locking not rbtrees.

> > Still not sure what we are talking about here.
> 
> The apps using GRU/KVM never trigger large
> munmap/mremap/do_exit. You're optimizing for the irrelevant workload,
> by requiring unnecessary new locking in the GRU fast path.

Maybe that is true for KVM but certainly not true for the GRU. The GRU is 
designed to manage several petabytes of memory that may be mapped by a 
series of Linux instances. If a process only maps a small chunk of 4 
Gigabytes then we already have to deal with 1 mio callbacks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
