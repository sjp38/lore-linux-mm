Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8F38E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 15:29:24 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so2820151pfk.12
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:29:24 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m198si4239688pga.98.2019.01.15.12.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 12:29:22 -0800 (PST)
Date: Tue, 15 Jan 2019 12:29:19 -0800
From: Ira Weiny <ira.weiny@intel.com>
Subject: Re: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Message-ID: <20190115202918.GC4343@iweiny-mobl2.amr.corp.intel.com>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-4-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115181300.27547-4-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jgg@mellanox.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, dennis.dalessandro@intel.com, mike.marciniszyn@intel.com, Davidlohr Bueso <dbueso@suse.de>

On Tue, Jan 15, 2019 at 10:12:57AM -0800, Davidlohr Bueso wrote:
> The driver uses mmap_sem for both pinned_vm accounting and
> get_user_pages(). By using gup_fast() and letting the mm handle
> the lock if needed, we can no longer rely on the semaphore and
> simplify the whole thing as the pinning is decoupled from the lock.
> 
> This also fixes a bug that __qib_get_user_pages was not taking into
> account the current value of pinned_vm.
> 
> Cc: dennis.dalessandro@intel.com
> Cc: mike.marciniszyn@intel.com
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  drivers/infiniband/hw/qib/qib_user_pages.c | 67 ++++++++++--------------------
>  1 file changed, 22 insertions(+), 45 deletions(-)
> 
> diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
> index 981795b23b73..4b7a5be782e6 100644
> --- a/drivers/infiniband/hw/qib/qib_user_pages.c
> +++ b/drivers/infiniband/hw/qib/qib_user_pages.c
> @@ -49,43 +49,6 @@ static void __qib_release_user_pages(struct page **p, size_t num_pages,
>  	}
>  }
>  
> -/*
> - * Call with current->mm->mmap_sem held.
> - */
> -static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
> -				struct page **p)
> -{
> -	unsigned long lock_limit;
> -	size_t got;
> -	int ret;
> -
> -	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> -
> -	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
> -		ret = -ENOMEM;
> -		goto bail;
> -	}
> -
> -	for (got = 0; got < num_pages; got += ret) {
> -		ret = get_user_pages(start_page + got * PAGE_SIZE,
> -				     num_pages - got,
> -				     FOLL_WRITE | FOLL_FORCE,
> -				     p + got, NULL);
> -		if (ret < 0)
> -			goto bail_release;
> -	}
> -
> -	atomic_long_add(num_pages, &current->mm->pinned_vm);
> -
> -	ret = 0;
> -	goto bail;
> -
> -bail_release:
> -	__qib_release_user_pages(p, got, 0);
> -bail:
> -	return ret;
> -}
> -
>  /**
>   * qib_map_page - a safety wrapper around pci_map_page()
>   *
> @@ -137,26 +100,40 @@ int qib_map_page(struct pci_dev *hwdev, struct page *page, dma_addr_t *daddr)
>  int qib_get_user_pages(unsigned long start_page, size_t num_pages,
>  		       struct page **p)
>  {
> +	unsigned long locked, lock_limit;
> +	size_t got;
>  	int ret;
>  
> -	down_write(&current->mm->mmap_sem);
> +	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> +	locked = atomic_long_add_return(num_pages, &current->mm->pinned_vm);
>  
> -	ret = __qib_get_user_pages(start_page, num_pages, p);
> +	if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
> +		ret = -ENOMEM;
> +		goto bail;
> +	}
>  
> -	up_write(&current->mm->mmap_sem);
> +	for (got = 0; got < num_pages; got += ret) {
> +		ret = get_user_pages_fast(start_page + got * PAGE_SIZE,
> +				     num_pages - got,
> +				     FOLL_WRITE | FOLL_FORCE,
> +				     p + got);
> +		if (ret < 0)
> +			goto bail_release;
> +	}
>  
> +	return 0;
> +bail_release:
> +	__qib_release_user_pages(p, got, 0);
> +bail:
> +	atomic_long_sub(num_pages, &current->mm->pinned_vm);
>  	return ret;
>  }
>  
>  void qib_release_user_pages(struct page **p, size_t num_pages)
>  {
> -	if (current->mm) /* during close after signal, mm can be NULL */
> -		down_write(&current->mm->mmap_sem);
> -
>  	__qib_release_user_pages(p, num_pages, 1);
>  
> -	if (current->mm) {
> +	if (current->mm) { /* during close after signal, mm can be NULL */
>  		atomic_long_sub(num_pages, &current->mm->pinned_vm);
> -		up_write(&current->mm->mmap_sem);
>  	}
>  }
> -- 
> 2.16.4
> 
