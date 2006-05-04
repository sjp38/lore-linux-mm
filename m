Date: Thu, 4 May 2006 05:28:56 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: RE: RFC: RCU protected page table walking
In-Reply-To: <4t16i2$tp1jo@orsmga001.jf.intel.com>
Message-ID: <Pine.LNX.4.64.0605040501510.29813@blonde.wat.veritas.com>
References: <4t16i2$tp1jo@orsmga001.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Lameter' <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr, linux-i64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 May 2006, Chen, Kenneth W wrote:
> > On Wed, 3 May 2006, Hugh Dickins wrote:
> > > Those architectures (including i386 and x86_64) which #define their
> > > __pte_free_tlb etc. to tlb_remove_page are safe as is.  But Zoltan's
> > > ia64 #defines it to pte_free, which looks like it may free_page before
> > > the TLB flush.  But it is surprising if it has actually been unsafe
> 
> A while back ia64 reinstated per-cpu pgtable quicklist,
> which bypasses tlb_gather/tlb_finish_mmu for page table pages.

Right you are, it was using tlb_remove_page until 2.6.12.  Forgive me,
but that makes me a little more suspicious of whether it is now safe.

> It should be safe AFAICT because TLB for user address and
> vhpt are already flushed by the time pte_free_tlb() is called.

I'm ia64-challenged, so VHPT is no more than a name to me; but I can
easily believe that on ia64, once the pte has been cleared and the
user address flushed from the TLB, then the page tables can be freed
without waiting on further flushing.

However, are you sure that the TLB for user address has already been
flushed at that point?  There is not necessarily any tlb_finish_mmu
call in between the last tlb_remove_page of unmap_vmas and the first
pte_free_tlb of free_pgtables.

Hugh

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
