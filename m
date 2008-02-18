Date: Mon, 18 Feb 2008 13:17:15 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] KVM swapping with MMU Notifiers V7
Message-ID: <20080218121715.GR11732@v2.random>
References: <20080215064859.384203497@sgi.com> <20080216104827.GI11732@v2.random> <20080216030817.965ff1f7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080216030817.965ff1f7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2008 at 03:08:17AM -0800, Andrew Morton wrote:
> On Sat, 16 Feb 2008 11:48:27 +0100 Andrea Arcangeli <andrea@qumranet.com> wrote:
> 
> > +void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
> > +					   struct mm_struct *mm,
> > +					   unsigned long start, unsigned long end,
> > +					   int lock)
> > +{
> > +	for (; start < end; start += PAGE_SIZE)
> > +		kvm_mmu_notifier_invalidate_page(mn, mm, start);
> > +}
> > +
> > +static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
> > +	.invalidate_page	= kvm_mmu_notifier_invalidate_page,
> > +	.age_page		= kvm_mmu_notifier_age_page,
> > +	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
> > +};
> 
> So this doesn't implement ->invalidate_range_start().

Correct. range_start is needed by subsystems that don't pin the pages
(so they've to drop the secondary mmu mappings on the physical page
before the page is released by the linux VM).

> By what means does it prevent new mappings from being established in the
> range after core mm has tried to call ->invalidate_rande_start()?
> mmap_sem, I assume?

No, populate range only takes the mmap_sem in read mode and the kvm page
fault also is of course taking it only in read mode.

What makes it safe, is that invalidate_range_end is called _after_ the
linux pte is clear. The kvm page fault, if it triggers, it will call
into get_user_pages again to re-establish the linux pte _before_
establishing the spte.

It's the same reason why it's safe to flush the tlb after clearing the
linux pte. sptes are like a secondary tlb.

> > +			/* set userspace_addr atomically for kvm_hva_to_rmapp */
> > +			spin_lock(&kvm->mmu_lock);
> > +			memslot->userspace_addr = userspace_addr;
> > +			spin_unlock(&kvm->mmu_lock);
> 
> are you sure?  kvm_unmap_hva() and kvm_age_hva() read ->userspace_addr a
> single time and it doesn't immediately look like there's a need to take the
> lock here?

gcc will always write it with a movq but this is to be
C-specs-compliant and because this is by far not a performance
critical path I thought it was simpler than some other atomic move in
a single insn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
