Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 239086B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 10:10:20 -0500 (EST)
Received: by wmec201 with SMTP id c201so26108832wme.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:10:19 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id gg6si21701862wjb.56.2015.11.26.07.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 07:10:19 -0800 (PST)
Received: by wmvv187 with SMTP id v187so35535774wmv.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:10:18 -0800 (PST)
Date: Thu, 26 Nov 2015 16:10:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] jbd2: get rid of superfluous __GFP_REPEAT
Message-ID: <20151126151017.GJ7953@dhcp22.suse.cz>
References: <1446740160-29094-4-git-send-email-mhocko@kernel.org>
 <1446826623-23959-1-git-send-email-mhocko@kernel.org>
 <563D526F.6030504@I-love.SAKURA.ne.jp>
 <20151108050802.GB3880@thunk.org>
 <20151109081650.GA8916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151109081650.GA8916@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, john.johansen@canonical.com

Hi Ted,
are there any objections for the patch or should I just repost it?

On Mon 09-11-15 09:16:50, Michal Hocko wrote:
> On Sun 08-11-15 00:08:02, Theodore Ts'o wrote:
> > On Sat, Nov 07, 2015 at 10:22:55AM +0900, Tetsuo Handa wrote:
> > > All jbd2_alloc() callers seem to pass GFP_NOFS. Therefore, use of
> > > vmalloc() which implicitly passes GFP_KERNEL | __GFP_HIGHMEM can cause
> > > deadlock, can't it? This vmalloc(size) call needs to be replaced with
> > > __vmalloc(size, flags).
> > 
> > jbd2_alloc is only passed in the bh->b_size, which can't be >
> > PAGE_SIZE, so the code path that calls vmalloc() should never get
> > called.  When we conveted jbd2_alloc() to suppor sub-page size
> > allocations in commit d2eecb039368, there was an assumption that it
> > could be called with a size greater than PAGE_SIZE, but that's
> > certaily not true today.
> 
> Thanks for the clarification. Then the patch can be simplified even
> more then.
> ---
> From fbf02c347dae8ee86e396bc769a88e85773db83e Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 21 Oct 2015 17:14:49 +0200
> Subject: [PATCH] jbd2: get rid of superfluous __GFP_REPEAT
> 
> jbd2_alloc is explicit about its allocation preferences wrt. the
> allocation size. Sub page allocations go to the slab allocator
> and larger are using either the page allocator or vmalloc. This
> is all good but the logic is unnecessarily complex.
> 1) as per Ted, the vmalloc fallback is a left-over:
> : jbd2_alloc is only passed in the bh->b_size, which can't be >
> : PAGE_SIZE, so the code path that calls vmalloc() should never get
> : called.  When we conveted jbd2_alloc() to suppor sub-page size
> : allocations in commit d2eecb039368, there was an assumption that it
> : could be called with a size greater than PAGE_SIZE, but that's
> : certaily not true today.
> Moreover vmalloc allocation might even lead to a deadlock because
> the callers expect GFP_NOFS context while vmalloc is GFP_KERNEL.
> 2) Requests smaller than order-3 are go to the page allocator with
> __GFP_REPEAT. The flag doesn't do anything useful for those because they
> are smaller than PAGE_ALLOC_COSTLY_ORDER.
> 
> Let's simplify the code flow and use the slab allocator for sub-page
> requests and the page allocator for others. Even though order > 0 is
> not currently used as per above leave that option open.
> 
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/jbd2/journal.c | 32 +++++++-------------------------
>  1 file changed, 7 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
> index 81e622681c82..0145e7978ab4 100644
> --- a/fs/jbd2/journal.c
> +++ b/fs/jbd2/journal.c
> @@ -2299,18 +2299,10 @@ void *jbd2_alloc(size_t size, gfp_t flags)
>  
>  	BUG_ON(size & (size-1)); /* Must be a power of 2 */
>  
> -	flags |= __GFP_REPEAT;
> -	if (size == PAGE_SIZE)
> -		ptr = (void *)__get_free_pages(flags, 0);
> -	else if (size > PAGE_SIZE) {
> -		int order = get_order(size);
> -
> -		if (order < 3)
> -			ptr = (void *)__get_free_pages(flags, order);
> -		else
> -			ptr = vmalloc(size);
> -	} else
> +	if (size < PAGE_SIZE)
>  		ptr = kmem_cache_alloc(get_slab(size), flags);
> +	else
> +		ptr = (void *)__get_free_pages(flags, get_order(size));
>  
>  	/* Check alignment; SLUB has gotten this wrong in the past,
>  	 * and this can lead to user data corruption! */
> @@ -2321,20 +2313,10 @@ void *jbd2_alloc(size_t size, gfp_t flags)
>  
>  void jbd2_free(void *ptr, size_t size)
>  {
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
> +	else
> +		free_pages((unsigned long)ptr, get_order(size));
>  };
>  
>  /*
> -- 
> 2.6.2
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
