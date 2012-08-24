Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id ACB846B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 17:51:53 -0400 (EDT)
Date: Fri, 24 Aug 2012 14:51:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/mmu_notifier: init notifier if necessary
Message-Id: <20120824145151.b92557cc.akpm@linux-foundation.org>
In-Reply-To: <1345819076-12545-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1345819076-12545-1-git-send-email-liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Gavin Shan <shangw@linux.vnet.ibm.com>

On Fri, 24 Aug 2012 22:37:55 +0800
Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> From: Gavin Shan <shangw@linux.vnet.ibm.com>
> 
> While registering MMU notifier, new instance of MMU notifier_mm will
> be allocated and later free'd if currrent mm_struct's MMU notifier_mm
> has been initialized. That cause some overhead. The patch tries to
> eleminate that.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/mmu_notifier.c |   22 +++++++++++-----------
>  1 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 862b608..fb4067f 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -192,22 +192,23 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  
>  	BUG_ON(atomic_read(&mm->mm_users) <= 0);
>  
> -	ret = -ENOMEM;
> -	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
> -	if (unlikely(!mmu_notifier_mm))
> -		goto out;
> -
>  	if (take_mmap_sem)
>  		down_write(&mm->mmap_sem);
>  	ret = mm_take_all_locks(mm);
>  	if (unlikely(ret))
> -		goto out_cleanup;
> +		goto out;
>  
>  	if (!mm_has_notifiers(mm)) {
> +		mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm),
> +					GFP_ATOMIC);

Why was the code switched to the far weaker GFP_ATOMIC?  We can still
perform sleeping allocations inside mmap_sem.

> +		if (unlikely(!mmu_notifier_mm)) {
> +			ret = -ENOMEM;
> +			goto out_of_mem;
> +		}
>  		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
>  		spin_lock_init(&mmu_notifier_mm->lock);
> +
>  		mm->mmu_notifier_mm = mmu_notifier_mm;
> -		mmu_notifier_mm = NULL;
>  	}
>  	atomic_inc(&mm->mm_count);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
