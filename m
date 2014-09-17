Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id ACCE26B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 06:26:41 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id x12so1151775wgg.25
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 03:26:41 -0700 (PDT)
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
        by mx.google.com with ESMTPS id s9si6077341wix.53.2014.09.17.03.26.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 03:26:40 -0700 (PDT)
Received: by mail-we0-f181.google.com with SMTP id w62so1179732wes.40
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 03:26:39 -0700 (PDT)
Date: Wed, 17 Sep 2014 13:26:36 +0300
From: Gleb Natapov <gleb@kernel.org>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140917102635.GA30733@minantech.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410811885-17267-1-git-send-email-andreslc@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 15, 2014 at 01:11:25PM -0700, Andres Lagar-Cavilla wrote:
> When KVM handles a tdp fault it uses FOLL_NOWAIT. If the guest memory has been
> swapped out or is behind a filemap, this will trigger async readahead and
> return immediately. The rationale is that KVM will kick back the guest with an
> "async page fault" and allow for some other guest process to take over.
> 
> If async PFs are enabled the fault is retried asap from a workqueue, or
> immediately if no async PFs. The retry will not relinquish the mmap semaphore
> and will block on the IO. This is a bad thing, as other mmap semaphore users
> now stall. The fault could take a long time, depending on swap or filemap
> latency.
> 
> This patch ensures both the regular and async PF path re-enter the fault
> allowing for the mmap semaphore to be relinquished in the case of IO wait.
> 
> Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
> ---
>  include/linux/kvm_host.h |  9 +++++++++
>  include/linux/mm.h       |  1 +
>  mm/gup.c                 |  4 ++++
>  virt/kvm/async_pf.c      |  4 +---
>  virt/kvm/kvm_main.c      | 45 ++++++++++++++++++++++++++++++++++++++++++---
>  5 files changed, 57 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 3addcbc..704908d 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -198,6 +198,15 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, unsigned long hva,
>  int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu);
>  #endif
>  
> +/*
> + * Retry a fault after a gup with FOLL_NOWAIT. This properly relinquishes mmap
> + * semaphore if the filemap/swap has to wait on page lock (and retries the gup
> + * to completion after that).
> + */
> +int kvm_get_user_page_retry(struct task_struct *tsk, struct mm_struct *mm,
> +			    unsigned long addr, bool write_fault,
> +			    struct page **pagep);
> +
>  enum {
>  	OUTSIDE_GUEST_MODE,
>  	IN_GUEST_MODE,
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ebc5f90..13e585f7 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2011,6 +2011,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
>  #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
>  #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
>  #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
> +#define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
>  
>  typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>  			void *data);
> diff --git a/mm/gup.c b/mm/gup.c
> index 91d044b..332d1c3 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -281,6 +281,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>  	if (*flags & FOLL_NOWAIT)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
> +	if (*flags & FOLL_TRIED) {
> +		WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
> +		fault_flags |= FAULT_FLAG_TRIED;
> +	}
>  
>  	ret = handle_mm_fault(mm, vma, address, fault_flags);
>  	if (ret & VM_FAULT_ERROR) {
> diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
> index d6a3d09..17b78b1 100644
> --- a/virt/kvm/async_pf.c
> +++ b/virt/kvm/async_pf.c
> @@ -80,9 +80,7 @@ static void async_pf_execute(struct work_struct *work)
>  
>  	might_sleep();
>  
> -	down_read(&mm->mmap_sem);
> -	get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
> -	up_read(&mm->mmap_sem);
> +	kvm_get_user_page_retry(NULL, mm, addr, 1, NULL);
>  	kvm_async_page_present_sync(vcpu, apf);
>  
>  	spin_lock(&vcpu->async_pf.lock);
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 7ef6b48..43a9ab9 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -1115,6 +1115,39 @@ static int get_user_page_nowait(struct task_struct *tsk, struct mm_struct *mm,
>  	return __get_user_pages(tsk, mm, start, 1, flags, page, NULL, NULL);
>  }
>  
> +int kvm_get_user_page_retry(struct task_struct *tsk, struct mm_struct *mm,
> +				unsigned long addr, bool write_fault,
> +				struct page **pagep)
> +{
> +	int npages;
> +	int locked = 1;
> +	int flags = FOLL_TOUCH | FOLL_HWPOISON |
> +		    (pagep ? FOLL_GET : 0) |
> +		    (write_fault ? FOLL_WRITE : 0);
> +
> +	/*
> +	 * Retrying fault, we get here *not* having allowed the filemap to wait
> +	 * on the page lock. We should now allow waiting on the IO with the
> +	 * mmap semaphore released.
> +	 */
> +	down_read(&mm->mmap_sem);
> +	npages = __get_user_pages(tsk, mm, addr, 1, flags, pagep, NULL,
> +				  &locked);
> +	if (!locked) {
> +		BUG_ON(npages != -EBUSY);
> +		/*
> +		 * The previous call has now waited on the IO. Now we can
> +		 * retry and complete. Pass TRIED to ensure we do not re
> +		 * schedule async IO (see e.g. filemap_fault).
> +		 */
> +		down_read(&mm->mmap_sem);
> +		npages = __get_user_pages(tsk, mm, addr, 1, flags | FOLL_TRIED,
> +					  pagep, NULL, NULL);
For async_pf_execute() you do not need to even retry. Next guest's page fault
will retry it for you.

> +	}
> +	up_read(&mm->mmap_sem);
> +	return npages;
> +}
> +
>  static inline int check_user_page_hwpoison(unsigned long addr)
>  {
>  	int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
> @@ -1177,9 +1210,15 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
>  		npages = get_user_page_nowait(current, current->mm,
>  					      addr, write_fault, page);
>  		up_read(&current->mm->mmap_sem);
> -	} else
> -		npages = get_user_pages_fast(addr, 1, write_fault,
> -					     page);
> +	} else {
> +		/*
> +		 * By now we have tried gup_fast, and possible async_pf, and we
> +		 * are certainly not atomic. Time to retry the gup, allowing
> +		 * mmap semaphore to be relinquished in the case of IO.
> +		 */
> +		npages = kvm_get_user_page_retry(current, current->mm, addr,
> +						 write_fault, page);
> +	}
>  	if (npages != 1)
>  		return npages;
>  
> -- 
> 2.1.0.rc2.206.gedb03e5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
