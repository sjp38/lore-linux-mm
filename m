Date: Fri, 7 Mar 2008 12:00:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] 3/4 combine RCU with seqlock to allow mmu notifier
 methods to sleep (#v9 was 1/4)
In-Reply-To: <20080307152328.GE24114@v2.random>
Message-ID: <Pine.LNX.4.64.0803071155100.6815@schroedinger.engr.sgi.com>
References: <20080302155457.GK8091@v2.random> <20080303213707.GA8091@v2.random>
 <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com>
 <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
 <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
 <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
 <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Andrea Arcangeli wrote:

> This combines the non-sleep-capable RCU locking of #v9 with a seqlock
> so the mmu notifier fast path will require zero cacheline
> writes/bouncing while still providing mmu_notifier_unregister and
> allowing to schedule inside the mmu notifier methods. If we drop
> mmu_notifier_unregister we can as well drop all seqlock and
> rcu_read_lock()s. But this locking scheme combination is sexy enough
> and 100% scalable (the mmu_notifier_list cacheline will be preloaded
> anyway and that will most certainly include the sequence number value
> in l1 for free even in Christoph's NUMA systems) so IMHO it worth to
> keep mmu_notifier_unregister.

Well its adds lots of processing. Not sure if its really worth it. Seems 
that this scheme cannot work since the existence of the structure passed 
to the callbacks is not guaranteed since the RCU locks are not held. You 
need some kind of a refcount to give the existence guarantee.

> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -20,7 +20,9 @@ void __mmu_notifier_release(struct mm_st
>  void __mmu_notifier_release(struct mm_struct *mm)
>  {
>  	struct mmu_notifier *mn;
> +	unsigned seq;
>  
> +	seq = read_seqbegin(&mm->mmu_notifier_lock);
>  	while (unlikely(!hlist_empty(&mm->mmu_notifier_list))) {
>  		mn = hlist_entry(mm->mmu_notifier_list.first,
>  				 struct mmu_notifier,
> @@ -28,6 +30,7 @@ void __mmu_notifier_release(struct mm_st
>  		hlist_del(&mn->hlist);
>  		if (mn->ops->release)
>  			mn->ops->release(mn, mm);
> +		BUG_ON(read_seqretry(&mm->mmu_notifier_lock, seq));
>  	}
>  }

So this is only for sanity checking? The BUG_ON detects concurrent 
operations that should not happen? Need a comment here.


> @@ -42,11 +45,19 @@ int __mmu_notifier_clear_flush_young(str
>  	struct mmu_notifier *mn;
>  	struct hlist_node *n;
>  	int young = 0;
> +	unsigned seq;
>  
>  	rcu_read_lock();
> +restart:
> +	seq = read_seqbegin(&mm->mmu_notifier_lock);
>  	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
> -		if (mn->ops->clear_flush_young)
> +		if (mn->ops->clear_flush_young) {
> +			rcu_read_unlock();
>  			young |= mn->ops->clear_flush_young(mn, mm, address);
> +			rcu_read_lock();
> +		}
> +		if (read_seqretry(&mm->mmu_notifier_lock, seq))
> +			goto restart;

Great innovative idea of the seqlock for versioning checks.

>  	}
>  	rcu_read_unlock();
>  

Well that gets pretty sophisticated here. If you drop the rcu lock then 
the entity pointed to by mn can go away right? So how can you pass that 
structure to clear_flush_young? What is guaranteeing the existence of the 
structure?


> @@ -58,11 +69,19 @@ void __mmu_notifier_invalidate_page(stru
>  {
>  	struct mmu_notifier *mn;
>  	struct hlist_node *n;
> +	unsigned seq;
>  
>  	rcu_read_lock();
> +restart:
> +	seq = read_seqbegin(&mm->mmu_notifier_lock);
>  	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
> -		if (mn->ops->invalidate_page)
> +		if (mn->ops->invalidate_page) {
> +			rcu_read_unlock();
>  			mn->ops->invalidate_page(mn, mm, address);

Ditto structure can vanish since no existence guarantee exists.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
