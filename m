Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDB76B006C
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 11:36:18 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so493921pac.14
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:36:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v11si1093790pas.205.2014.10.01.08.36.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 08:36:17 -0700 (PDT)
Date: Wed, 1 Oct 2014 17:36:11 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: RFC: get_user_pages_locked|unlocked to leverage VM_FAULT_RETRY
Message-ID: <20141001153611.GC2843@worktop.programming.kicks-ass.net>
References: <20140926172535.GC4590@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140926172535.GC4590@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Fri, Sep 26, 2014 at 07:25:35PM +0200, Andrea Arcangeli wrote:
> diff --git a/drivers/dma/iovlock.c b/drivers/dma/iovlock.c
> index bb48a57..12ea7c3 100644
> --- a/drivers/dma/iovlock.c
> +++ b/drivers/dma/iovlock.c
> @@ -95,17 +95,11 @@ struct dma_pinned_list *dma_pin_iovec_pages(struct iovec *iov, size_t len)
>  		pages += page_list->nr_pages;
>  
>  		/* pin pages down */
> -		down_read(&current->mm->mmap_sem);
> -		ret = get_user_pages(
> -			current,
> -			current->mm,
> +		ret = get_user_pages_fast(
>  			(unsigned long) iov[i].iov_base,
>  			page_list->nr_pages,
>  			1,	/* write */
> -			0,	/* force */
> -			page_list->pages,
> -			NULL);
> -		up_read(&current->mm->mmap_sem);
> +			page_list->pages);
>  
>  		if (ret != page_list->nr_pages)
>  			goto unpin;

> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -198,8 +198,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
>  #else
>  	*pageshift = PAGE_SHIFT;
>  #endif
> -	if (get_user_pages
> -	    (current, current->mm, vaddr, 1, write, 0, &page, NULL) <= 0)
> +	if (get_user_pages_fast(vaddr, 1, write, &page) <= 0)
>  		return -EFAULT;
>  	*paddr = page_to_phys(page);
>  	put_page(page);

> diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
> index aff9689..c89dcfa 100644
> --- a/drivers/scsi/st.c
> +++ b/drivers/scsi/st.c
> @@ -4536,18 +4536,12 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
>  		return -ENOMEM;
>  
>          /* Try to fault in all of the necessary pages */
> -	down_read(&current->mm->mmap_sem);
>          /* rw==READ means read from drive, write into memory area */
> -	res = get_user_pages(
> -		current,
> -		current->mm,
> +	res = get_user_pages_fast(
>  		uaddr,
>  		nr_pages,
>  		rw == READ,
> -		0, /* don't force */
> -		pages,
> -		NULL);
> -	up_read(&current->mm->mmap_sem);
> +		pages);
>  
>  	/* Errors and no page mapped should return here */
>  	if (res < nr_pages)


For all these and the other _fast() users, is there an actual limit to
the nr_pages passed in? Because we used to have the 64 pages limit from
DIO, but without that we get rather long IRQ-off latencies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
