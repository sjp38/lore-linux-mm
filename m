Date: Thu, 28 Feb 2008 11:48:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v7
In-Reply-To: <20080227192610.GF28483@v2.random>
Message-ID: <Pine.LNX.4.64.0802281139250.30865@schroedinger.engr.sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random>
 <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random>
 <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de>
 <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008, Andrea Arcangeli wrote:

> What Christoph need to do when he's back from vacations to support
> sleepable mmu notifiers is to add a CONFIG_XPMEM config option that
> will switch the i_mmap_lock from a semaphore to a mutex (any other
> change to this patch will be minor compared to that) so XPMEM hardware
> will have kernels compiled that way. I don't see other sane ways to
> remove the "atomic" parameter from the API (apparently required by
> Andrew for merging something not restricted to the xpmem current usage
> with only anonymous memory) and I don't want to have such a
> locking-change intrusive dependency for all other non-blocking users
> that are fine without having to alter how the VM works (for example
> KVM and GRU). Very minor changes will be required to this patch to
> make it work after the VM locking will be altered (for example the
> CONFIG_XPMEM should also switch the mmu_register/unregister locking
> from RCU to mutex as well). XPMEM then will only compile if
> CONFIG_XPMEM=y and in turn the invalidate_range_* will support
> scheduling inside.

This is not going to work even if the mutex would work as easily as you 
think since the patch here still does an rcu_lock/unlock around a callback.

> I don't think pretending to merge all in one block (I mean including
> xpmem support that requires blocking methods) is good idea anymore as
> long as we agree the "atomic" parameter shouldn't be merged. But we
> can quite easily agree on the below to be optimal for GRU/KVM and
> trivially extendible once a CONFIG_XPMEM will be added. So this first
> part can go in now I think.

Changing the locking for the callouts for users of the mmu notivier that 
f.e. require a response via the network (RDMA, XPMEM etc) is not trivial 
at all. RCU lock cannot be used. So we are looking at totally disjunct 
methods for those users who have to sleep.

> +struct mmu_notifier_ops {
> +	/*
> +	 * Called when nobody can register any more notifier in the mm
> +	 * and after the "mn" notifier has been disarmed already.
> +	 */
> +	void (*release)(struct mmu_notifier *mn,
> +			struct mm_struct *mm);

Who disarms the notifier? Why is the method not called to disarm the 
notifier on exit?

> +obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> --- a/mm/filemap_xip.c
> +++ b/mm/filemap_xip.c
> @@ -194,7 +194,7 @@ __xip_unmap (struct address_space * mapp
>  		if (pte) {
>  			/* Nuke the page table entry. */
>  			flush_cache_page(vma, address, pte_pfn(*pte));
> -			pteval = ptep_clear_flush(vma, address, pte);
> +			pteval = ptep_clear_flush_notify(vma, address, pte);
>  			page_remove_rmap(page, vma);
>  			dec_mm_counter(mm, file_rss);
>  			BUG_ON(pte_dirty(pteval));

Well a bit better but now we have to modify both the macro and the code 
in teh VM. It would be easier to put the notify call in here.

> @@ -2048,6 +2050,7 @@ void exit_mmap(struct mm_struct *mm)
>  	vm_unacct_memory(nr_accounted);
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
>  	tlb_finish_mmu(tlb, 0, end);
> +	mmu_notifier_release(mm);

The release should be called much earlier to allow the driver to release 
all resources in one go. This way each vma must be processed individually. 
For our gobs of memory this method may create a scaling problem on exit().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
