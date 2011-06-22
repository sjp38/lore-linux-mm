Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE9A90016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:43:44 -0400 (EDT)
Message-ID: <4E01C752.10405@redhat.com>
Date: Wed, 22 Jun 2011 13:43:30 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com>
In-Reply-To: <201106212132.39311.nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 06/21/2011 04:32 PM, Nai Xia wrote:
> Introduced kvm_mmu_notifier_test_and_clear_dirty(), kvm_mmu_notifier_dirty_update()
> and their mmu_notifier interfaces to support KSM dirty bit tracking, which brings
> significant performance gain in volatile pages scanning in KSM.
> Currently, kvm_mmu_notifier_dirty_update() returns 0 if and only if intel EPT is
> enabled to indicate that the dirty bits of underlying sptes are not updated by
> hardware.
>


Can you quantify the performance gains?

> +int kvm_test_and_clear_dirty_rmapp(struct kvm *kvm, unsigned long *rmapp,
> +				   unsigned long data)
> +{
> +	u64 *spte;
> +	int dirty = 0;
> +
> +	if (!shadow_dirty_mask) {
> +		WARN(1, "KVM: do NOT try to test dirty bit in EPT\n");
> +		goto out;
> +	}
> +
> +	spte = rmap_next(kvm, rmapp, NULL);
> +	while (spte) {
> +		int _dirty;
> +		u64 _spte = *spte;
> +		BUG_ON(!(_spte&  PT_PRESENT_MASK));
> +		_dirty = _spte&  PT_DIRTY_MASK;
> +		if (_dirty) {
> +			dirty = 1;
> +			clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);
> +		}

Racy.  Also, needs a tlb flush eventually.

> +		spte = rmap_next(kvm, rmapp, spte);
> +	}
> +out:
> +	return dirty;
> +}
> +
>   #define RMAP_RECYCLE_THRESHOLD 1000
>
>
>   struct mmu_notifier_ops {
> +	int (*dirty_update)(struct mmu_notifier *mn,
> +			     struct mm_struct *mm);
> +

I prefer to have test_and_clear_dirty() always return 1 in this case (if 
the spte is writeable), and drop this callback.
> +int __mmu_notifier_dirty_update(struct mm_struct *mm)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n;
> +	int dirty_update = 0;
> +
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(mn, n,&mm->mmu_notifier_mm->list, hlist) {
> +		if (mn->ops->dirty_update)
> +			dirty_update |= mn->ops->dirty_update(mn, mm);
> +	}
> +	rcu_read_unlock();
> +

Should it not be &= instead?

> +	return dirty_update;
> +}
> +
>   /*
>    * This function can't run concurrently against mmu_notifier_register
>    * because mm->mm_users>  0 during mmu_notifier_register and exit_mmap

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
