Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 6BB5B6B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 05:25:12 -0500 (EST)
Message-ID: <4F2E5853.2060605@mellanox.com>
Date: Sun, 5 Feb 2012 12:22:11 +0200
From: sagig <sagig@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: convert rcu_read_lock() to srcu_read_lock(),
 thus allowing to sleep in callbacks
References: <y> <4f25649b.8253b40a.3800.319d@mx.google.com>
In-Reply-To: <4f25649b.8253b40a.3800.319d@mx.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: gleb@redhat.com, oren@mellanox.com, ogerlitz@mellanox.com, linux-mm@kvack.org

Hey all,

I've published this patch [requested for comments] last week, But got no 
responses.
Since I'm not sure what to do if  init_srcu_struct() call fails (it 
might due to memory pressure), I'm interested in the community's advice 
on how to act.

Thanks,

On 1/29/2012 5:23 PM, sagig@mellanox.com wrote:
> Callbacks: invalidate_page, invalidate_range_start/end, change_pte
> Now that anon_vma lock and i_mmap_mutex are both sleepable mutex, it is possible to schedule inside invalidation cllabacks
> This is essential for a scheduling HW sync in RDMA drivers which apply on demand paging methods
>
> Signed-off-by: sagi grimberg<sagig@mellanox.co.il>
> ---
>   mm/mmu_notifier.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++------
>   1 files changed, 55 insertions(+), 8 deletions(-)
>
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 9a611d3..70dadd5 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -123,10 +123,16 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
>   void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
>   			       pte_t pte)
>   {
> +	int idx = -1;
> +	struct srcu_struct srcu;
>   	struct mmu_notifier *mn;
>   	struct hlist_node *n;
>
> -	rcu_read_lock();
> +	if (init_srcu_struct(&srcu))
> +		rcu_read_lock();
> +	else
> +		idx = srcu_read_lock(&srcu);
> +
>   	hlist_for_each_entry_rcu(mn, n,&mm->mmu_notifier_mm->list, hlist) {
>   		if (mn->ops->change_pte)
>   			mn->ops->change_pte(mn, mm, address, pte);
> @@ -137,49 +143,90 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
>   		else if (mn->ops->invalidate_page)
>   			mn->ops->invalidate_page(mn, mm, address);
>   	}
> -	rcu_read_unlock();
> +
> +	if (idx<  0)
> +		rcu_read_unlock();
> +	else
> +		srcu_read_unlock(&srcu, idx);
> +
> +	cleanup_srcu_struct(&srcu);
>   }
>
>   void __mmu_notifier_invalidate_page(struct mm_struct *mm,
>   					  unsigned long address)
>   {
> +	int idx = -1;
> +	struct srcu_struct srcu;
>   	struct mmu_notifier *mn;
>   	struct hlist_node *n;
>
> -	rcu_read_lock();
> +	if (init_srcu_struct(&srcu))
> +		rcu_read_lock();
> +	else
> +		idx = srcu_read_lock(&srcu);
> +
>   	hlist_for_each_entry_rcu(mn, n,&mm->mmu_notifier_mm->list, hlist) {
>   		if (mn->ops->invalidate_page)
>   			mn->ops->invalidate_page(mn, mm, address);
>   	}
> -	rcu_read_unlock();
> +
> +	if (idx<  0)
> +		rcu_read_unlock();
> +	else
> +		srcu_read_unlock(&srcu, idx);
> +
> +	cleanup_srcu_struct(&srcu);
>   }
>
>   void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>   				  unsigned long start, unsigned long end)
>   {
> +	int idx = -1;
> +	struct srcu_struct srcu;
>   	struct mmu_notifier *mn;
>   	struct hlist_node *n;
>
> -	rcu_read_lock();
> +	if (init_srcu_struct(&srcu))
> +		rcu_read_lock();
> +	else
> +		idx = srcu_read_lock(&srcu);
> +
>   	hlist_for_each_entry_rcu(mn, n,&mm->mmu_notifier_mm->list, hlist) {
>   		if (mn->ops->invalidate_range_start)
>   			mn->ops->invalidate_range_start(mn, mm, start, end);
>   	}
> -	rcu_read_unlock();
> +
> +	if (idx<  0)
> +		rcu_read_unlock();
> +	else
> +		srcu_read_unlock(&srcu, idx);
> +
> +	cleanup_srcu_struct(&srcu);
>   }
>
>   void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>   				  unsigned long start, unsigned long end)
>   {
> +	int idx = -1;
> +	struct srcu_struct srcu;
>   	struct mmu_notifier *mn;
>   	struct hlist_node *n;
>
> -	rcu_read_lock();
> +	if (init_srcu_struct(&srcu))
> +		rcu_read_lock();
> +	else
> +		idx = srcu_read_lock(&srcu);
>   	hlist_for_each_entry_rcu(mn, n,&mm->mmu_notifier_mm->list, hlist) {
>   		if (mn->ops->invalidate_range_end)
>   			mn->ops->invalidate_range_end(mn, mm, start, end);
>   	}
> -	rcu_read_unlock();
> +
> +	if (idx<  0)
> +		rcu_read_unlock();
> +	else
> +		srcu_read_unlock(&srcu, idx);
> +
> +	cleanup_srcu_struct(&srcu);
>   }
>
>   static int do_mmu_notifier_register(struct mmu_notifier *mn,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
