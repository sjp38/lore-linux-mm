Date: Thu, 28 Feb 2008 15:05:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v7
In-Reply-To: <20080227192610.GF28483@v2.random>
Message-ID: <Pine.LNX.4.64.0802281456200.1152@schroedinger.engr.sgi.com>
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

> +struct mmu_notifier_head {
> +	struct hlist_head head;
> +	spinlock_t lock;
> +};

Still think that the lock here is not of too much use and can be easily 
replaced by mmap_sem.

> +#define mmu_notifier(function, mm, args...)				\
> +	do {								\
> +		struct mmu_notifier *__mn;				\
> +		struct hlist_node *__n;					\
> +									\
> +		if (unlikely(!hlist_empty(&(mm)->mmu_notifier.head))) { \
> +			rcu_read_lock();				\
> +			hlist_for_each_entry_rcu(__mn, __n,		\
> +						 &(mm)->mmu_notifier.head, \
> +						 hlist)			\
> +				if (__mn->ops->function)		\
> +					__mn->ops->function(__mn,	\
> +							    mm,		\
> +							    args);	\
> +			rcu_read_unlock();				\
> +		}							\
> +	} while (0)

Andrew recomended local variables for parameters used multile times. This 
means the mm parameter here.

> +/*
> + * Notifiers that use the parameters that they were passed so that the
> + * compiler does not complain about unused variables but does proper
> + * parameter checks even if !CONFIG_MMU_NOTIFIER.
> + * Macros generate no code.
> + */
> +#define mmu_notifier(function, mm, args...)			       \
> +	do {							       \
> +		if (0) {					       \
> +			struct mmu_notifier *__mn;		       \
> +								       \
> +			__mn = (struct mmu_notifier *)(0x00ff);	       \
> +			__mn->ops->function(__mn, mm, args);	       \
> +		};						       \
> +	} while (0)

Note also Andrew's comments on the use of 0x00ff...

> +/*
> + * No synchronization. This function can only be called when only a single
> + * process remains that performs teardown.
> + */
> +void mmu_notifier_release(struct mm_struct *mm)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n, *tmp;
> +
> +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> +		hlist_for_each_entry_safe(mn, n, tmp,
> +					  &mm->mmu_notifier.head, hlist) {
> +			hlist_del(&mn->hlist);
> +			if (mn->ops->release)
> +				mn->ops->release(mn, mm);
> +		}
> +	}
> +}

One could avoid a hlist_for_each_entry_safe here by simply always deleting 
the first object. 

Also re the _notify variants: The binding to pte_clear_flush_young etc 
will become a problem for notifiers that want to sleep because 
pte_clear_flush is usually called with the pte lock held. See f.e. 
try_to_unmap_one, page_mkclean_one etc.

It would be better if the notifier calls could be moved outside of the 
pte lock.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
