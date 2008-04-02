From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1 of 8] Core of mmu notifiers
Date: Wed, 2 Apr 2008 15:34:01 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021527370.31603@schroedinger.engr.sgi.com>
References: <a406c0cc686d0ca94a4d.1207171802@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a406c0cc686d0ca94a4d.1207171802@duo.random>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, akpm@linux-foundation.org
List-Id: linux-mm.kvack.org

On Wed, 2 Apr 2008, Andrea Arcangeli wrote:

> +	void (*invalidate_page)(struct mmu_notifier *mn,
> +				struct mm_struct *mm,
> +				unsigned long address);
> +
> +	void (*invalidate_range_start)(struct mmu_notifier *mn,
> +				       struct mm_struct *mm,
> +				       unsigned long start, unsigned long end);
> +	void (*invalidate_range_end)(struct mmu_notifier *mn,
> +				     struct mm_struct *mm,
> +				     unsigned long start, unsigned long end);

Still two methods ...

> +void __mmu_notifier_release(struct mm_struct *mm)
> +{
> +	struct mmu_notifier *mn;
> +	unsigned seq;
> +
> +	seq = read_seqbegin(&mm->mmu_notifier_lock);
> +	while (unlikely(!hlist_empty(&mm->mmu_notifier_list))) {
> +		mn = hlist_entry(mm->mmu_notifier_list.first,
> +				 struct mmu_notifier,
> +				 hlist);
> +		hlist_del(&mn->hlist);
> +		if (mn->ops->release)
> +			mn->ops->release(mn, mm);
> +		BUG_ON(read_seqretry(&mm->mmu_notifier_lock, seq));
> +	}
> +}

seqlock just taken for checking if everything is ok?

> +
> +/*
> + * If no young bitflag is supported by the hardware, ->clear_flush_young can
> + * unmap the address and return 1 or 0 depending if the mapping previously
> + * existed or not.
> + */
> +int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
> +					unsigned long address)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n;
> +	int young = 0;
> +	unsigned seq;
> +
> +	seq = read_seqbegin(&mm->mmu_notifier_lock);
> +	do {
> +		hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
> +			if (mn->ops->clear_flush_young)
> +				young |= mn->ops->clear_flush_young(mn, mm,
> +								    address);
> +		}
> +	} while (read_seqretry(&mm->mmu_notifier_lock, seq));
> +

The critical section could be run multiple times for one callback which 
could result in multiple callbacks to clear the young bit. Guess not that 
big of an issue?

> +void __mmu_notifier_invalidate_page(struct mm_struct *mm,
> +					  unsigned long address)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n;
> +	unsigned seq;
> +
> +	seq = read_seqbegin(&mm->mmu_notifier_lock);
> +	do {
> +		hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
> +			if (mn->ops->invalidate_page)
> +				mn->ops->invalidate_page(mn, mm, address);
> +		}
> +	} while (read_seqretry(&mm->mmu_notifier_lock, seq));
> +}

Ok. Retry would try to invalidate the page a second time which is not a 
problem unless you would drop the refcount or make other state changes 
that require correspondence with mapping. I guess this is the reason 
that you stopped adding a refcount?

> +void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> +				  unsigned long start, unsigned long end)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n;
> +	unsigned seq;
> +
> +	seq = read_seqbegin(&mm->mmu_notifier_lock);
> +	do {
> +		hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
> +			if (mn->ops->invalidate_range_start)
> +				mn->ops->invalidate_range_start(mn, mm,
> +								start, end);
> +		}
> +	} while (read_seqretry(&mm->mmu_notifier_lock, seq));
> +}

Multiple invalidate_range_starts on the same range? This means the driver 
needs to be able to deal with the situation and ignore the repeated 
call?

> +void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> +				  unsigned long start, unsigned long end)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n;
> +	unsigned seq;
> +
> +	seq = read_seqbegin(&mm->mmu_notifier_lock);
> +	do {
> +		hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
> +			if (mn->ops->invalidate_range_end)
> +				mn->ops->invalidate_range_end(mn, mm,
> +							      start, end);
> +		}
> +	} while (read_seqretry(&mm->mmu_notifier_lock, seq));
> +}

Retry can lead to multiple invalidate_range callbacks with the same 
parameters? Driver needs to ignore if the range is already clear?

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
