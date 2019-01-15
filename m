Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DBC88E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 15:29:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id bj3so2332126plb.17
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:29:39 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 123si4386033pfx.109.2019.01.15.12.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 12:29:38 -0800 (PST)
Date: Tue, 15 Jan 2019 12:29:36 -0800
From: Ira Weiny <ira.weiny@intel.com>
Subject: Re: [PATCH 4/6] drivers/IB,hfi1: do not se mmap_sem
Message-ID: <20190115202935.GD4343@iweiny-mobl2.amr.corp.intel.com>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-5-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115181300.27547-5-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jgg@mellanox.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, mike.marciniszyn@intel.com, dennis.dalessandro@intel.com, Davidlohr Bueso <dbueso@suse.de>

On Tue, Jan 15, 2019 at 10:12:58AM -0800, Davidlohr Bueso wrote:
> This driver already uses gup_fast() and thus we can just drop
> the mmap_sem protection around the pinned_vm counter. Note that
> the window between when hfi1_can_pin_pages() is called and the
> actual counter is incremented remains the same as mmap_sem was
> _only_ used for when ->pinned_vm was touched.
> 
> Cc: mike.marciniszyn@intel.com
> Cc: dennis.dalessandro@intel.com
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  drivers/infiniband/hw/hfi1/user_pages.c | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
> index df86a596d746..f0c6f219f575 100644
> --- a/drivers/infiniband/hw/hfi1/user_pages.c
> +++ b/drivers/infiniband/hw/hfi1/user_pages.c
> @@ -91,9 +91,7 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
>  	/* Convert to number of pages */
>  	size = DIV_ROUND_UP(size, PAGE_SIZE);
>  
> -	down_read(&mm->mmap_sem);
>  	pinned = atomic_long_read(&mm->pinned_vm);
> -	up_read(&mm->mmap_sem);
>  
>  	/* First, check the absolute limit against all pinned pages. */
>  	if (pinned + npages >= ulimit && !can_lock)
> @@ -111,9 +109,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
>  	if (ret < 0)
>  		return ret;
>  
> -	down_write(&mm->mmap_sem);
>  	atomic_long_add(ret, &mm->pinned_vm);
> -	up_write(&mm->mmap_sem);
>  
>  	return ret;
>  }
> @@ -130,8 +126,6 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
>  	}
>  
>  	if (mm) { /* during close after signal, mm can be NULL */
> -		down_write(&mm->mmap_sem);
>  		atomic_long_sub(npages, &mm->pinned_vm);
> -		up_write(&mm->mmap_sem);
>  	}
>  }
> -- 
> 2.16.4
> 
