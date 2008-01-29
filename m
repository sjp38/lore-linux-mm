Date: Tue, 29 Jan 2008 10:31:58 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 6/6] mmu_notifier: Add invalidate_all()
Message-ID: <20080129163158.GX3058@sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202924.810792591@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080128202924.810792591@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

What is the status of getting invalidate_all adjusted to indicate a need
to also call _release?

Thanks,
Robin

On Mon, Jan 28, 2008 at 12:28:46PM -0800, Christoph Lameter wrote:
> when a task exits we can remove all external pts at once. At that point the
> extern mmu may also unregister itself from the mmu notifier chain to avoid
> future calls.
> 
> Note the complications because of RCU. Other processors may not see that the
> notifier was unlinked until a quiescent period has passed!
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/mmu_notifier.h |    4 ++++
>  mm/mmap.c                    |    1 +
>  2 files changed, 5 insertions(+)
> 
> Index: linux-2.6/include/linux/mmu_notifier.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mmu_notifier.h	2008-01-28 11:43:03.000000000 -0800
> +++ linux-2.6/include/linux/mmu_notifier.h	2008-01-28 12:21:33.000000000 -0800
> @@ -62,6 +62,10 @@ struct mmu_notifier_ops {
>  				struct mm_struct *mm,
>  				unsigned long address);
>  
> +	/* Dummy needed because the mmu_notifier() macro requires it */
> +	void (*invalidate_all)(struct mmu_notifier *mn, struct mm_struct *mm,
> +				int dummy);
> +
>  	/*
>  	 * lock indicates that the function is called under spinlock.
>  	 */
> Index: linux-2.6/mm/mmap.c
> ===================================================================
> --- linux-2.6.orig/mm/mmap.c	2008-01-28 11:47:53.000000000 -0800
> +++ linux-2.6/mm/mmap.c	2008-01-28 11:57:45.000000000 -0800
> @@ -2034,6 +2034,7 @@ void exit_mmap(struct mm_struct *mm)
>  	unsigned long end;
>  
>  	/* mm's last user has gone, and its about to be pulled down */
> +	mmu_notifier(invalidate_all, mm, 0);
>  	arch_exit_mmap(mm);
>  
>  	lru_add_drain();
> 
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
