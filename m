Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08506828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 00:46:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 143so372484240pfx.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 21:46:59 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id dk11si3464054pac.244.2016.07.03.21.46.56
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 21:46:57 -0700 (PDT)
Date: Mon, 4 Jul 2016 13:50:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] kasan: make depot_fetch_stack more robust
Message-ID: <20160704045012.GB14840@js1304-P5Q-DELUXE>
References: <1467394698-142163-1-git-send-email-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467394698-142163-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: akpm@linux-foundation.org, ryabinin.a.a@gmail.com, glider@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com

On Fri, Jul 01, 2016 at 07:38:18PM +0200, Dmitry Vyukov wrote:
> I've hit a GPF in depot_fetch_stack when it was given
> bogus stack handle. I think it was caused by a distant
> out-of-bounds that hit a different object, as the result
> we treated uninit garbage as stack handle. Maybe there is
> something to fix in KASAN logic, but I think it makes
> sense to make depot_fetch_stack more robust as well.
> 
> Verify that the provided stack handle looks correct.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> ---
> For your convenience uploaded to codereview:
> https://codereview.appspot.com/295680043
> 
> ---
>  include/linux/stackdepot.h |  2 +-
>  lib/stackdepot.c           | 21 +++++++++++++++++----
>  mm/kasan/report.c          | 10 ++++------
>  mm/page_owner.c            | 12 ++++++------
>  4 files changed, 28 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/stackdepot.h b/include/linux/stackdepot.h
> index 7978b3e..b2dbe02 100644
> --- a/include/linux/stackdepot.h
> +++ b/include/linux/stackdepot.h
> @@ -27,6 +27,6 @@ struct stack_trace;
>  
>  depot_stack_handle_t depot_save_stack(struct stack_trace *trace, gfp_t flags);
>  
> -void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace);
> +bool depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace);
>  
>  #endif
> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
> index 53ad6c0..0982331 100644
> --- a/lib/stackdepot.c
> +++ b/lib/stackdepot.c
> @@ -181,16 +181,29 @@ static inline struct stack_record *find_stack(struct stack_record *bucket,
>  	return NULL;
>  }
>  
> -void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
> +bool depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
>  {
>  	union handle_parts parts = { .handle = handle };
> -	void *slab = stack_slabs[parts.slabindex];
> -	size_t offset = parts.offset << STACK_ALLOC_ALIGN;
> -	struct stack_record *stack = slab + offset;
> +	void *slab;
> +	struct stack_record *stack;
>  
> +	if (handle == 0)
> +		return false;
> +	if (parts.valid != 1 || parts.slabindex >= ARRAY_SIZE(stack_slabs))
> +		goto bad;
> +	slab = stack_slabs[parts.slabindex];
> +	if (slab == NULL)
> +		goto bad;
> +	stack = slab + (parts.offset << STACK_ALLOC_ALIGN);
> +	if (stack->handle.handle != handle)
> +		goto bad;
>  	trace->nr_entries = trace->max_entries = stack->size;
>  	trace->entries = stack->entries;
>  	trace->skip = 0;
> +	return true;
> +bad:
> +	pr_err("stackdepot: fetching bogus stack %x\n", handle);
> +	return false;
>  }
>  
>  /**
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 861b977..46e4b82 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -118,15 +118,13 @@ static inline bool init_task_stack_addr(const void *addr)
>  
>  static void print_track(struct kasan_track *track)
>  {
> -	pr_err("PID = %u\n", track->pid);
> -	if (track->stack) {
> -		struct stack_trace trace;
> +	struct stack_trace trace;
>  
> -		depot_fetch_stack(track->stack, &trace);
> +	pr_err("PID = %u\n", track->pid);
> +	if (depot_fetch_stack(track->stack, &trace))
>  		print_stack_trace(&trace, 0);
> -	} else {
> +	else
>  		pr_err("(stack is not available)\n");
> -	}
>  }
>  
>  static void kasan_object_err(struct kmem_cache *cache, struct page *page,
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 8fa5083..1862f05 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -252,10 +252,11 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  	if (ret >= count)
>  		goto err;
>  
> -	depot_fetch_stack(handle, &trace);
> -	ret += snprint_stack_trace(kbuf + ret, count - ret, &trace, 0);
> -	if (ret >= count)
> -		goto err;
> +	if (depot_fetch_stack(handle, &trace)) {
> +		ret += snprint_stack_trace(kbuf + ret, count - ret, &trace, 0);
> +		if (ret >= count)
> +			goto err;
> +	}

Please do 'goto err' if depot_fetch_stack() return false here.

Others looks fine to me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
