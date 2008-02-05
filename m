Date: Tue, 5 Feb 2008 10:17:41 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
In-Reply-To: <20080205180802.GE7441@v2.random>
Message-ID: <Pine.LNX.4.64.0802051013440.11705@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com>
 <20080131234101.GS7185@v2.random> <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com>
 <20080201120955.GX7185@v2.random> <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com>
 <20080203021704.GC7185@v2.random> <Pine.LNX.4.64.0802041106370.9656@schroedinger.engr.sgi.com>
 <20080205052525.GD7441@v2.random> <Pine.LNX.4.64.0802042206200.6739@schroedinger.engr.sgi.com>
 <20080205180802.GE7441@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Andrea Arcangeli wrote:

> given I never allow a coherency-loss between two threads that will
> read/write to two different physical pages for the same virtual
> adddress in remap_file_pages).

The other approach will not have any remote ptes at that point. Why would 
there be a coherency issue?
 
> In performance terms with your patch before GRU can run follow_page it
> has to take a mm-wide global mutex where each thread in all cpus will
> have to take it. That will trash on >4-way when the tlb misses start

No. It only has to lock the affected range. Remote page faults can occur 
while another part of the address space is being invalidated. The 
complexity of locking is up to the user of the mmu notifier. A simple 
implementation is satisfactory for the GRU right now. Should it become a 
problem then the lock granularity can be refined without changing the API.

> > "conversion of some page in pages"? A proposal to defer the freeing of the 
> > pages until after the pte_unlock?
> 
> There can be many tricks to optimize page in pages, but again munmap
> and do_exit aren't the interesting path to optimzie, nor for GRU nor
> for KVM so it doesn't matter right now.

Still not sure what we are talking about here.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
