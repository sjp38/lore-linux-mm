Date: Tue, 22 Apr 2008 09:20:26 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080422072026.GM12709@duo.random>
References: <patchbomb.1207669443@duo.random> <20080409131709.GR11364@sgi.com> <20080409144401.GT10133@duo.random> <20080409185500.GT11364@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080409185500.GT11364@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is a followup of the locking of the mmu-notifier methods against
the secondary-mmu page fault, each driver can implement differently
but this is to show an example of what I planned for KVM, others may
follow closely if they find this useful. I post this as pseudocode to
hide 99% of kvm internal complexities and to focus only on the
locking. The KVM locking scheme should be something on these lines:

    invalidate_range_start {
	spin_lock(&kvm->mmu_lock);

	kvm->invalidate_range_count++;
	rmap-invalidate of sptes in range

	spin_unlock(&kvm->mmu_lock)
    }

    invalidate_range_end {
	spin_lock(&kvm->mmu_lock);

	kvm->invalidate_range_count--;

	spin_unlock(&kvm->mmu_lock)
    }

   invalidate_page {
	spin_lock(&kvm->mmu_lock);

	write_seqlock()
	rmap-invalidate of sptes of page
	write_sequnlock()

	spin_unlock(&kvm->mmu_lock)
   }

   kvm_page_fault {
      seq = read_seqlock()
      get_user_pages() (aka gfn_to_pfn() in kvm terms)

      spin_lock(&kvm->mmu_lock)
      if (seq_trylock(seq) || kvm->invalidate_range_count)
      	 goto out; /* reply page fault */
      map sptes and build rmap
 out:
      spin_unlock(&kvm->mmu_lock)
   }

This will allow to remove the page pinning from KVM. I'd appreciate if
you Robin and Christoph can have a second look and pinpoint any
potential issue in my plan.

invalidate_page as you can notice, allows to decrease the fixed cost
overhead from all VM code that works with a single page and where
freeing the page _after_ calling invalidate_page is zero runtime/tlb
cost. We need invalidate_range_begin/end because when we work on
multiple pages, we can reduce cpu utilization and avoid many tlb
flushes by holding off the kvm page fault when we work on the range.

invalidate_page also allows to decrease the window where the kvm page
fault could possibly need to be replied (the ptep_clear_flush <->
invalidate_page window is shorter than a
invalidate_range_begin(PAGE_SIZE) <->
invalidate_range_end(PAGE_SIZE)).

So even if only as a microoptimization it worth it to decrease the
impact on the common VM code. The cost of having both a seqlock and a
range_count is irrlevant in kvm terms as they'll be in the same
cacheline and checked at the same time by the page fault and it won't
require any additional blocking (or writing) lock.

Note that the kvm page fault can't happen unless the cpu switches to
guest mode, and it can't switch to guest mode if we're in the
begin/end critical section, so in theory I could loop inside the page
fault too without risking deadlocking, but replying it by restarting
guest mode sounds nicer in sigkill/scheduling terms.

Soon I'll release a new mmu notifier patchset with patch 1 being the
mmu-notifier-core self-included and ready to go in -mm and mainline in
time for 2.6.26. Then I'll be glad to help merging any further patch
in the patchset to allow methods to sleep so XPMEM can run on mainline
2.6.27 the same way GRU/KVM/Quadrics will run fine on 2.6.26, in a
fully backwards compatible way with 2.6.26 (and of course it doesn't
really need to be backwards compatible because this is a kernel
internal API only, ask Greg etc... ;). But that will likely require a
new config option to avoid hurting AIM performance in fork because the
anon_vma critical sections are so short in the fast path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
