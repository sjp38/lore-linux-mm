Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 95BFE600805
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 12:27:30 -0400 (EDT)
Message-ID: <4C447CE9.20904@redhat.com>
Date: Mon, 19 Jul 2010 11:27:21 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 RESEND] fix return value for mb_cache_shrink_fn when
 nr_to_scan > 0
References: <4C430830.9020903@gmail.com>
In-Reply-To: <4C430830.9020903@gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wang Sheng-Hui <crosslonelyover@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On 07/18/2010 08:57 AM, Wang Sheng-Hui wrote:
> Sorry to resend this patch. For the 2nd patch should
> be applied after this patch, I just send them together.
> 
> Following is the explanation of the patch:
> The comment for struct shrinker in include/linux/mm.h says
> "shrink...It should return the number of objects which remain in the
> cache."
> Please notice the word "remain".
> 
> In fs/mbcache.h, mb_cache_shrink_fn is used as the shrink function:
>        static struct shrinker mb_cache_shrinker = {
>                .shrink = mb_cache_shrink_fn,
>                .seeks = DEFAULT_SEEKS,
>        };
> In mb_cache_shrink_fn, the return value for nr_to_scan > 0 is the
> number of mb_cache_entry before shrink operation. It may because the
> memory usage for mbcache is low, so the effect is not so obvious.
> 
> Per Eric Sandeen, we should do the counting only once.
> Per Christoph Hellwig, we should use list_for_each_entry instead of
> list_for_each here.
> 
> Following patch is against 2.6.35-rc4. Please check it.
> 
> 
> Signed-off-by: Wang Sheng-Hui <crosslonelyover@gmail.com>

Reviewed-by: Eric Sandeen <sandeen@redhat.com>

Thanks,
-Eric

> ---
>  fs/mbcache.c |   22 +++++++++++-----------
>  1 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/mbcache.c b/fs/mbcache.c
> index ec88ff3..5697d9e 100644
> --- a/fs/mbcache.c
> +++ b/fs/mbcache.c
> @@ -201,21 +201,13 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
>  {
>  	LIST_HEAD(free_list);
>  	struct list_head *l, *ltmp;
> +	struct mb_cache *cache;
>  	int count = 0;
> 
> -	spin_lock(&mb_cache_spinlock);
> -	list_for_each(l, &mb_cache_list) {
> -		struct mb_cache *cache =
> -			list_entry(l, struct mb_cache, c_cache_list);
> -		mb_debug("cache %s (%d)", cache->c_name,
> -			  atomic_read(&cache->c_entry_count));
> -		count += atomic_read(&cache->c_entry_count);
> -	}
>  	mb_debug("trying to free %d entries", nr_to_scan);
> -	if (nr_to_scan == 0) {
> -		spin_unlock(&mb_cache_spinlock);
> +	if (nr_to_scan == 0)
>  		goto out;
> -	}
> +
>  	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
>  		struct mb_cache_entry *ce =
>  			list_entry(mb_cache_lru_list.next,
> @@ -229,6 +221,14 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
>  						   e_lru_list), gfp_mask);
>  	}
>  out:
> +	spin_lock(&mb_cache_spinlock);
> +	list_for_each_entry(cache, &mb_cache_list, c_cache_list) {
> +		mb_debug("cache %s (%d)", cache->c_name,
> +			  atomic_read(&cache->c_entry_count));
> +		count += atomic_read(&cache->c_entry_count);
> +	}
> +	spin_unlock(&mb_cache_spinlock);
> +
>  	return (count / 100) * sysctl_vfs_cache_pressure;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
