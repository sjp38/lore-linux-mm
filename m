Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA5836B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:24:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s16-v6so815679pfm.1
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:24:48 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0096.outbound.protection.outlook.com. [104.47.1.96])
        by mx.google.com with ESMTPS id m63-v6si20034171pld.429.2018.05.24.04.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:24:45 -0700 (PDT)
Subject: Re: [PATCH] userfaultfd: prevent non-cooperative events vs
 mcopy_atomic races
References: <1527061324-19949-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <0e1ce040-1beb-fd96-683c-1b18eb635fd6@virtuozzo.com>
Date: Thu, 24 May 2018 14:24:37 +0300
MIME-Version: 1.0
In-Reply-To: <1527061324-19949-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrei Vagin <avagin@virtuozzo.com>

On 05/23/2018 10:42 AM, Mike Rapoport wrote:
> If a process monitored with userfaultfd changes it's memory mappings or
> forks() at the same time as uffd monitor fills the process memory with
> UFFDIO_COPY, the actual creation of page table entries and copying of the
> data in mcopy_atomic may happen either before of after the memory mapping
> modifications and there is no way for the uffd monitor to maintain
> consistent view of the process memory layout.
> 
> For instance, let's consider fork() running in parallel with
> userfaultfd_copy():
> 
> process        		         |	uffd monitor
> ---------------------------------+------------------------------
> fork()        		         | userfaultfd_copy()
> ...        		         | ...
>     dup_mmap()        	         |     down_read(mmap_sem)
>     down_write(mmap_sem)         |     /* create PTEs, copy data */
>         dup_uffd()               |     up_read(mmap_sem)
>         copy_page_range()        |
>         up_write(mmap_sem)       |
>         dup_uffd_complete()      |
>             /* notify monitor */ |
> 
> If the userfaultfd_copy() takes the mmap_sem first, the new page(s) will be
> present by the time copy_page_range() is called and they will appear in the
> child's memory mappings. However, if the fork() is the first to take the
> mmap_sem, the new pages won't be mapped in the child's address space.

But in this case child should get an entry, that emits a message to uffd when step upon!
And uffd will just userfaultfd_copy() it again. No?

-- Pavel

> Since userfaultfd monitor has no way to determine what was the order, let's
> disallow userfaultfd_copy in parallel with the non-cooperative events. In
> such case we return -EAGAIN and the uffd monitor can understand that
> userfaultfd_copy() clashed with a non-cooperative event and take an
> appropriate action.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Pavel Emelyanov <xemul@virtuozzo.com>
> Cc: Andrei Vagin <avagin@virtuozzo.com>
> ---
>  fs/userfaultfd.c              | 22 ++++++++++++++++++++--
>  include/linux/userfaultfd_k.h |  6 ++++--
>  mm/userfaultfd.c              | 22 +++++++++++++++++-----
>  3 files changed, 41 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index cec550c8468f..123bf7d516fc 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -62,6 +62,8 @@ struct userfaultfd_ctx {
>  	enum userfaultfd_state state;
>  	/* released */
>  	bool released;
> +	/* memory mappings are changing because of non-cooperative event */
> +	bool mmap_changing;
>  	/* mm with one ore more vmas attached to this userfaultfd_ctx */
>  	struct mm_struct *mm;
>  };
> @@ -641,6 +643,7 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
>  	 * already released.
>  	 */
>  out:
> +	WRITE_ONCE(ctx->mmap_changing, false);
>  	userfaultfd_ctx_put(ctx);
>  }
>  
> @@ -686,10 +689,12 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
>  		ctx->state = UFFD_STATE_RUNNING;
>  		ctx->features = octx->features;
>  		ctx->released = false;
> +		ctx->mmap_changing = false;
>  		ctx->mm = vma->vm_mm;
>  		mmgrab(ctx->mm);
>  
>  		userfaultfd_ctx_get(octx);
> +		WRITE_ONCE(octx->mmap_changing, true);
>  		fctx->orig = octx;
>  		fctx->new = ctx;
>  		list_add_tail(&fctx->list, fcs);
> @@ -732,6 +737,7 @@ void mremap_userfaultfd_prep(struct vm_area_struct *vma,
>  	if (ctx && (ctx->features & UFFD_FEATURE_EVENT_REMAP)) {
>  		vm_ctx->ctx = ctx;
>  		userfaultfd_ctx_get(ctx);
> +		WRITE_ONCE(ctx->mmap_changing, true);
>  	}
>  }
>  
> @@ -772,6 +778,7 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
>  		return true;
>  
>  	userfaultfd_ctx_get(ctx);
> +	WRITE_ONCE(ctx->mmap_changing, true);
>  	up_read(&mm->mmap_sem);
>  
>  	msg_init(&ewq.msg);
> @@ -815,6 +822,7 @@ int userfaultfd_unmap_prep(struct vm_area_struct *vma,
>  			return -ENOMEM;
>  
>  		userfaultfd_ctx_get(ctx);
> +		WRITE_ONCE(ctx->mmap_changing, true);
>  		unmap_ctx->ctx = ctx;
>  		unmap_ctx->start = start;
>  		unmap_ctx->end = end;
> @@ -1653,6 +1661,10 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
>  
>  	user_uffdio_copy = (struct uffdio_copy __user *) arg;
>  
> +	ret = -EAGAIN;
> +	if (READ_ONCE(ctx->mmap_changing))
> +		goto out;
> +
>  	ret = -EFAULT;
>  	if (copy_from_user(&uffdio_copy, user_uffdio_copy,
>  			   /* don't copy "copy" last field */
> @@ -1674,7 +1686,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
>  		goto out;
>  	if (mmget_not_zero(ctx->mm)) {
>  		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
> -				   uffdio_copy.len);
> +				   uffdio_copy.len, &ctx->mmap_changing);
>  		mmput(ctx->mm);
>  	} else {
>  		return -ESRCH;
> @@ -1705,6 +1717,10 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
>  
>  	user_uffdio_zeropage = (struct uffdio_zeropage __user *) arg;
>  
> +	ret = -EAGAIN;
> +	if (READ_ONCE(ctx->mmap_changing))
> +		goto out;
> +
>  	ret = -EFAULT;
>  	if (copy_from_user(&uffdio_zeropage, user_uffdio_zeropage,
>  			   /* don't copy "zeropage" last field */
> @@ -1721,7 +1737,8 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
>  
>  	if (mmget_not_zero(ctx->mm)) {
>  		ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
> -				     uffdio_zeropage.range.len);
> +				     uffdio_zeropage.range.len,
> +				     &ctx->mmap_changing);
>  		mmput(ctx->mm);
>  	} else {
>  		return -ESRCH;
> @@ -1900,6 +1917,7 @@ SYSCALL_DEFINE1(userfaultfd, int, flags)
>  	ctx->features = 0;
>  	ctx->state = UFFD_STATE_WAIT_API;
>  	ctx->released = false;
> +	ctx->mmap_changing = false;
>  	ctx->mm = current->mm;
>  	/* prevent the mm struct to be freed */
>  	mmgrab(ctx->mm);
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index f2f3b68ba910..e091f0a11b11 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -31,10 +31,12 @@
>  extern int handle_userfault(struct vm_fault *vmf, unsigned long reason);
>  
>  extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
> -			    unsigned long src_start, unsigned long len);
> +			    unsigned long src_start, unsigned long len,
> +			    bool *mmap_changing);
>  extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
>  			      unsigned long dst_start,
> -			      unsigned long len);
> +			      unsigned long len,
> +			      bool *mmap_changing);
>  
>  /* mm helpers */
>  static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index 39791b81ede7..5029f241908f 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -404,7 +404,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  					      unsigned long dst_start,
>  					      unsigned long src_start,
>  					      unsigned long len,
> -					      bool zeropage)
> +					      bool zeropage,
> +					      bool *mmap_changing)
>  {
>  	struct vm_area_struct *dst_vma;
>  	ssize_t err;
> @@ -431,6 +432,15 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  	down_read(&dst_mm->mmap_sem);
>  
>  	/*
> +	 * If memory mappings are changing because of non-cooperative
> +	 * operation (e.g. mremap) running in parallel, bail out and
> +	 * request the user to retry later
> +	 */
> +	err = -EAGAIN;
> +	if (mmap_changing && READ_ONCE(*mmap_changing))
> +		goto out_unlock;
> +
> +	/*
>  	 * Make sure the vma is not shared, that the dst range is
>  	 * both valid and fully within a single existing vma.
>  	 */
> @@ -563,13 +573,15 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  }
>  
>  ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
> -		     unsigned long src_start, unsigned long len)
> +		     unsigned long src_start, unsigned long len,
> +		     bool *mmap_changing)
>  {
> -	return __mcopy_atomic(dst_mm, dst_start, src_start, len, false);
> +	return __mcopy_atomic(dst_mm, dst_start, src_start, len, false,
> +			      mmap_changing);
>  }
>  
>  ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
> -		       unsigned long len)
> +		       unsigned long len, bool *mmap_changing)
>  {
> -	return __mcopy_atomic(dst_mm, start, 0, len, true);
> +	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing);
>  }
> 
