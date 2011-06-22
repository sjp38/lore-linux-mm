Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1621900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:24:58 -0400 (EDT)
Received: by iwn8 with SMTP id 8so789574iwn.14
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 04:24:56 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte and mmu notifier to help KSM dirty bit tracking
Date: Wed, 22 Jun 2011 19:24:36 +0800
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com> <4E01C752.10405@redhat.com>
In-Reply-To: <4E01C752.10405@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201106221924.36996.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Undisclosed.Recipients:"@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

Hi Avi,

Thanks for viewing!

On Wednesday 22 June 2011 18:43:30 Avi Kivity wrote:
> On 06/21/2011 04:32 PM, Nai Xia wrote:
> > Introduced kvm_mmu_notifier_test_and_clear_dirty(), kvm_mmu_notifier_dirty_update()
> > and their mmu_notifier interfaces to support KSM dirty bit tracking, which brings
> > significant performance gain in volatile pages scanning in KSM.
> > Currently, kvm_mmu_notifier_dirty_update() returns 0 if and only if intel EPT is
> > enabled to indicate that the dirty bits of underlying sptes are not updated by
> > hardware.
> >
> 
> 
> Can you quantify the performance gains?

Compared with checksum based approach, the speed up for volatile host working 
set is about 8 times on normal pages, 16 times on transhuge page. I have not
collect the figures in guest os yet. I'll be back with these numbers in guest.

> 
> > +int kvm_test_and_clear_dirty_rmapp(struct kvm *kvm, unsigned long *rmapp,
> > +				   unsigned long data)
> > +{
> > +	u64 *spte;
> > +	int dirty = 0;
> > +
> > +	if (!shadow_dirty_mask) {
> > +		WARN(1, "KVM: do NOT try to test dirty bit in EPT\n");
> > +		goto out;
> > +	}
> > +
> > +	spte = rmap_next(kvm, rmapp, NULL);
> > +	while (spte) {
> > +		int _dirty;
> > +		u64 _spte = *spte;
> > +		BUG_ON(!(_spte&  PT_PRESENT_MASK));
> > +		_dirty = _spte&  PT_DIRTY_MASK;
> > +		if (_dirty) {
> > +			dirty = 1;
> > +			clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);
> > +		}
> 
> Racy.  Also, needs a tlb flush eventually.
> 
> > +		spte = rmap_next(kvm, rmapp, spte);
> > +	}
> > +out:
> > +	return dirty;
> > +}
> > +
> >   #define RMAP_RECYCLE_THRESHOLD 1000
> >
> >
> >   struct mmu_notifier_ops {
> > +	int (*dirty_update)(struct mmu_notifier *mn,
> > +			     struct mm_struct *mm);
> > +
> 
> I prefer to have test_and_clear_dirty() always return 1 in this case (if 
> the spte is writeable), and drop this callback.

If test_and_clear_dirty() always return 1, how can ksmd tell if it's a real
dirty page or just casued by EPT and ksmd should just fallback to checksum 
based approach?

> > +int __mmu_notifier_dirty_update(struct mm_struct *mm)
> > +{
> > +	struct mmu_notifier *mn;
> > +	struct hlist_node *n;
> > +	int dirty_update = 0;
> > +
> > +	rcu_read_lock();
> > +	hlist_for_each_entry_rcu(mn, n,&mm->mmu_notifier_mm->list, hlist) {
> > +		if (mn->ops->dirty_update)
> > +			dirty_update |= mn->ops->dirty_update(mn, mm);
> > +	}
> > +	rcu_read_unlock();
> > +
> 
> Should it not be &= instead?

I think the logic is "if _any_ underlying MMU is going to update the bit, then
this bit is not dead, we can query it throught test_and_clear....". ksmd should 
not care about which one dirties the page, as long as it's dirty, it can be skipped.
Did I miss sth?

Thanks,

Nai


> 
> > +	return dirty_update;
> > +}
> > +
> >   /*
> >    * This function can't run concurrently against mmu_notifier_register
> >    * because mm->mm_users>  0 during mmu_notifier_register and exit_mmap
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
