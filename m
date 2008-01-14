Date: Mon, 14 Jan 2008 12:02:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v2
In-Reply-To: <20080113162418.GE8736@v2.random>
Message-ID: <Pine.LNX.4.64.0801141154240.8300@schroedinger.engr.sgi.com>
References: <20080113162418.GE8736@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jan 2008, Andrea Arcangeli wrote:

> About the locking perhaps I'm underestimating it, but by following the
> TLB flushing analogy, by simply clearing the shadow ptes (with kvm
> mmu_lock spinlock to avoid racing with other vcpu spte accesses of
> course) and flushing the shadow-pte after clearing the main linux pte,
> it should be enough to serialize against shadow-pte page faults that
> would call into get_user_pages. Flushing the host TLB before or after
> the shadow-ptes shouldn't matter.

Hmmm... In most of the callsites we hold a writelock on mmap_sem right?

> Comments welcome... especially from SGI/IBM/Quadrics and all other
> potential users of this functionality.

> There are also certain details I'm uncertain about, like passing 'mm'
> to the lowlevel methods, my KVM usage of the invalidate_page()
> notifier for example only uses 'mm' for a BUG_ON for example:

Passing mm is fine as long as mmap_sem is held.

> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -86,6 +86,7 @@ do {									\
>  	pte_t __pte;							\
>  	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
>  	flush_tlb_page(__vma, __address);				\
> +	mmu_notifier(invalidate_page, (__vma)->vm_mm, __address);	\
>  	__pte;								\
>  })
>  #endif

Hmmm... this is ptep_clear_flush? What about the other uses of 
flush_tlb_page in asm-generic/pgtable.h and related uses in arch code?
(would help if your patches would mention the function name in the diff 
headers)

> +#define mmu_notifier(function, mm, args...)				\
> +	do {								\
> +		struct mmu_notifier *__mn;				\
> +		struct hlist_node *__n;					\
> +									\
> +		hlist_for_each_entry(__mn, __n, &(mm)->mmu_notifier, hlist) \
> +			if (__mn->ops->function)			\
> +				__mn->ops->function(__mn, mm, args);	\
> +	} while (0)

Does this have to be inline? ptep_clear_flush will become quite big

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
