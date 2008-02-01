Date: Fri, 1 Feb 2008 13:09:55 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080201120955.GX7185@v2.random>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random> <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com> <20080131234101.GS7185@v2.random> <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 05:44:24PM -0800, Christoph Lameter wrote:
> The trouble is that the invalidates are much more expensive if you have to 
> send theses to remote partitions (XPmem). And its really great if you can 
> simple tear down everything. Certainly this is a significant improvement 
> over the earlier approach but you still have the invalidate_page calls in 
> ptep_clear_flush. So they fire needlessly?

Dunno, they certainly fire more frequently than yours, even _pages
fires more frequently than range_start,end but don't forget why!
That's because I've a different spinlock for every 512
ptes/4k-grub-tlbs that are being invalidated... So it pays off in
scalability. I'm unsure if gru could play tricks with your patch, to
still allow faults to still happen in parallel if they're on virtual
addresses not in the same 2M naturally aligned chunk.

> Serializing access in the device driver makes sense and comes with 
> additional possiblity of not having to increment page counts all the time. 
> So you trade one cacheline dirtying for many that are necessary if you 
> always increment the page count.

Note that my #v5 doesn't require to increase the page count all the
time, so GRU will work fine with #v5.

See this comment in my patch:

    /*
     * invalidate_page[s] is called in atomic context
     * after any pte has been updated and before
     * dropping the PT lock required to update any Linux pte.
     * Once the PT lock will be released the pte will have its
     * final value to export through the secondary MMU.
     * Before this is invoked any secondary MMU is still ok
     * to read/write to the page previously pointed by the
     * Linux pte because the old page hasn't been freed yet.
     * If required set_page_dirty has to be called internally
     * to this method.
     */


invalidate_page[s] is always called before the page is freed. This
will require modifications to the tlb flushing code logic to take
advantage of _pages in certain places. For now it's just safe.

> How does KVM insure the consistency of the shadow page tables? Atomic ops?

A per-VM mmu_lock spinlock is taken to serialize the access, plus
atomic ops for the cpu.

> The GRU has no page table on its own. It populates TLB entries on demand 
> using the linux page table. There is no way it can figure out when to 
> drop page counts again. The invalidate calls are turned directly into tlb 
> flushes.

Yes, this is why it can't serialize follow_page with only the PT lock
with your patch. KVM may do it once you add start,end to range_end
only thanks to the additional pin on the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
