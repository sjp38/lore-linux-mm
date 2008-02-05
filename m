Date: Tue, 5 Feb 2008 19:08:02 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080205180802.GE7441@v2.random>
References: <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com> <20080131234101.GS7185@v2.random> <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com> <20080201120955.GX7185@v2.random> <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com> <20080203021704.GC7185@v2.random> <Pine.LNX.4.64.0802041106370.9656@schroedinger.engr.sgi.com> <20080205052525.GD7441@v2.random> <Pine.LNX.4.64.0802042206200.6739@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802042206200.6739@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2008 at 10:11:24PM -0800, Christoph Lameter wrote:
> Zero problems only if you find having a single callout for every page 
> acceptable. So the invalidate_range in your patch is only working 

invalidate_pages is only a further optimization that was
strightforward in some places where the page isn't freed but only the
pte modified.

> sometimes. And even if it works then it has to be used on 2M range. Seems 
> to be a bit fragile and needlessly complex.

The patch as a whole isn't fragile nor complex. Pretending to use
invalidate_pages anywhere would be complex (and in turn more fragile
than my current patch, complexity brings fragility).

Overall you can only argue against performance issues (my patch is
simpler for GRU/KVM, and it sure isn't fragile, quite the opposite,
given I never allow a coherency-loss between two threads that will
read/write to two different physical pages for the same virtual
adddress in remap_file_pages).

In performance terms with your patch before GRU can run follow_page it
has to take a mm-wide global mutex where each thread in all cpus will
have to take it. That will trash on >4-way when the tlb misses start
to occour. There's nothing like that in my patch. Your approach will
micro-optimize certain large pte-mangling calls, or do_exit, but those
aren't interesting paths nor for GRU nor for KVM. You're optimizing for
the slow path, and making the fast path slower.

> "conversion of some page in pages"? A proposal to defer the freeing of the 
> pages until after the pte_unlock?

There can be many tricks to optimize page in pages, but again munmap
and do_exit aren't the interesting path to optimzie, nor for GRU nor
for KVM so it doesn't matter right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
