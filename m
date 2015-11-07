Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 568A782F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 20:23:10 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so138654310pab.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 17:23:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fc2si3878773pbd.137.2015.11.06.17.23.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Nov 2015 17:23:09 -0800 (PST)
Subject: Re: [PATCH] jbd2: get rid of superfluous __GFP_REPEAT
References: <1446740160-29094-4-git-send-email-mhocko@kernel.org>
 <1446826623-23959-1-git-send-email-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <563D526F.6030504@I-love.SAKURA.ne.jp>
Date: Sat, 7 Nov 2015 10:22:55 +0900
MIME-Version: 1.0
In-Reply-To: <1446826623-23959-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, john.johansen@canonical.com

On 2015/11/07 1:17, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> jbd2_alloc is explicit about its allocation preferences wrt. the
> allocation size. Sub page allocations go to the slab allocator
> and larger are using either the page allocator or vmalloc. This
> is all good but the logic is unnecessarily complex. Requests larger
> than order-3 are doing the vmalloc directly while smaller go to the
> page allocator with __GFP_REPEAT. The flag doesn't do anything useful
> for those because they are smaller than PAGE_ALLOC_COSTLY_ORDER.
>
> Let's simplify the code flow and use kmalloc for sub-page requests
> and the page allocator for others with fallback to vmalloc if the
> allocation fails.
>
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   fs/jbd2/journal.c | 35 ++++++++++++-----------------------
>   1 file changed, 12 insertions(+), 23 deletions(-)
>
> diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
> index 81e622681c82..2945c96f171f 100644
> --- a/fs/jbd2/journal.c
> +++ b/fs/jbd2/journal.c
> @@ -2299,18 +2299,15 @@ void *jbd2_alloc(size_t size, gfp_t flags)
>
>   	BUG_ON(size & (size-1)); /* Must be a power of 2 */
>
> -	flags |= __GFP_REPEAT;
> -	if (size == PAGE_SIZE)
> -		ptr = (void *)__get_free_pages(flags, 0);
> -	else if (size > PAGE_SIZE) {
> +	if (size < PAGE_SIZE)
> +		ptr = kmem_cache_alloc(get_slab(size), flags);
> +	else {
>   		int order = get_order(size);
>
> -		if (order < 3)
> -			ptr = (void *)__get_free_pages(flags, order);
> -		else
> +		ptr = (void *)__get_free_pages(flags, order);

I thought that we can add __GFP_NOWARN for this __get_free_pages() call.
But I noticed more important problem. See below.

> +		if (!ptr)
>   			ptr = vmalloc(size);
> -	} else
> -		ptr = kmem_cache_alloc(get_slab(size), flags);
> +	}
>
>   	/* Check alignment; SLUB has gotten this wrong in the past,
>   	 * and this can lead to user data corruption! */
> @@ -2321,20 +2318,12 @@ void *jbd2_alloc(size_t size, gfp_t flags)
>
>   void jbd2_free(void *ptr, size_t size)
>   {
> -	if (size == PAGE_SIZE) {
> -		free_pages((unsigned long)ptr, 0);
> -		return;
> -	}
> -	if (size > PAGE_SIZE) {
> -		int order = get_order(size);
> -
> -		if (order < 3)
> -			free_pages((unsigned long)ptr, order);
> -		else
> -			vfree(ptr);
> -		return;
> -	}
> -	kmem_cache_free(get_slab(size), ptr);
> +	if (size < PAGE_SIZE)
> +		kmem_cache_free(get_slab(size), ptr);
> +	else if (is_vmalloc_addr(ptr))
> +		vfree(ptr);
> +	else
> +		free_pages((unsigned long)ptr, get_order(size));
>   };
>
>   /*
>

All jbd2_alloc() callers seem to pass GFP_NOFS. Therefore, use of
vmalloc() which implicitly passes GFP_KERNEL | __GFP_HIGHMEM can cause
deadlock, can't it? This vmalloc(size) call needs to be replaced with
__vmalloc(size, flags).

We need to check all vmalloc() callers in case they are calling vmalloc()
under GFP_KERNEL-unsafe context. For example, I think that __aa_kvmalloc()
needs to use __vmalloc() too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
