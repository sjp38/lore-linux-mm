Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9F86B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:44:14 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id u68so78155337ywg.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 18:44:14 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f185si4137632ywd.95.2017.01.13.18.44.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 18:44:12 -0800 (PST)
Subject: Re: [PATCH 2/6] mm: support __GFP_REPEAT in kvmalloc_node for >=64kB
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-3-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <b4b9bb2c-86e2-a5ca-b072-593613924929@I-love.SAKURA.ne.jp>
Date: Sat, 14 Jan 2017 11:42:09 +0900
MIME-Version: 1.0
In-Reply-To: <20170112153717.28943-3-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 2017/01/13 0:37, Michal Hocko wrote:
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 5dc34653274a..105cd04c7414 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -797,12 +797,9 @@ static int vhost_net_open(struct inode *inode, struct file *f)
>  	struct vhost_virtqueue **vqs;
>  	int i;
>  
> -	n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> -	if (!n) {
> -		n = vmalloc(sizeof *n);
> -		if (!n)
> -			return -ENOMEM;
> -	}
> +	n = kvmalloc(sizeof *n, GFP_KERNEL | __GFP_REPEAT);

An opportunity to standardize as sizeof(*n) like other allocations.

> diff --git a/mm/util.c b/mm/util.c
> index 7e0c240b5760..9306244b9f41 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -333,7 +333,8 @@ EXPORT_SYMBOL(vm_mmap);
>   * Uses kmalloc to get the memory but if the allocation fails then falls back
>   * to the vmalloc allocator. Use kvfree for freeing the memory.
>   *
> - * Reclaim modifiers - __GFP_NORETRY, __GFP_REPEAT and __GFP_NOFAIL are not supported
> + * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_REPEAT
> + * is supported only for large (>64kB) allocations

Isn't this ">32kB" (i.e. __GFP_REPEAT is supported for 64kB allocation) ?

>   */
>  void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  {
> @@ -350,8 +351,18 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	 * Make sure that larger requests are not too disruptive - no OOM
>  	 * killer and no allocation failure warnings as we have a fallback
>  	 */
> -	if (size > PAGE_SIZE)
> -		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
> +	if (size > PAGE_SIZE) {
> +		kmalloc_flags |= __GFP_NOWARN;
> +
> +		/*
> +		 * We have to override __GFP_REPEAT by __GFP_NORETRY for !costly
> +		 * requests because there is no other way to tell the allocator
> +		 * that we want to fail rather than retry endlessly.
> +		 */
> +		if (!(kmalloc_flags & __GFP_REPEAT) ||
> +				(size <= PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> +			kmalloc_flags |= __GFP_NORETRY;
> +	}
>  
>  	ret = kmalloc_node(size, kmalloc_flags, node);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
