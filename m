Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 9681B6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 08:48:08 -0400 (EDT)
Message-ID: <51E7E400.4070705@oracle.com>
Date: Thu, 18 Jul 2013 20:48:00 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: zbud: fix condition check on allocation size
References: <1374071410-9337-1-git-send-email-heesub.shin@samsung.com>
In-Reply-To: <1374071410-9337-1-git-send-email-heesub.shin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dongjun Shin <d.j.shin@samsung.com>, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub@gmail.com>

On 07/17/2013 10:30 PM, Heesub Shin wrote:
> zbud_alloc() incorrectly verifies the size of allocation limit. It
> should deny the allocation request greater than (PAGE_SIZE -
> ZHDR_SIZE_ALIGNED - CHUNK_SIZE), not (PAGE_SIZE - ZHDR_SIZE_ALIGNED)
> which has no remaining spaces for its buddy. There is no point in
> spending the entire zbud page storing only a single page, since we don't
> have any benefits.
> 
> Signed-off-by: Heesub Shin <heesub.shin@samsung.com>

Looks good to me, although I'm thinking to make it more aggressive.
eg. minus two or three times of CHUNK_SIZE.

> ---
>  mm/zbud.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/zbud.c b/mm/zbud.c
> index 9bb4710..ad1e781 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -257,7 +257,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>  
>  	if (size <= 0 || gfp & __GFP_HIGHMEM)
>  		return -EINVAL;
> -	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED)
> +	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
>  		return -ENOSPC;
>  	chunks = size_to_chunks(size);
>  	spin_lock(&pool->lock);
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
