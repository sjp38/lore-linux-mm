Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8922802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 04:07:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v109so6323514wrc.5
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 01:07:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e203si719232wmd.68.2017.09.06.01.07.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 01:07:09 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm/slub: wake up kswapd for initial high order
 allocation
References: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cdf4e3f3-5237-23b7-5188-74401b6c2ba7@suse.cz>
Date: Wed, 6 Sep 2017 10:07:07 +0200
MIME-Version: 1.0
In-Reply-To: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 09/06/2017 06:37 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> slub uses higher order allocation than it actually needs. In this case,
> we don't want to do direct reclaim to make such a high order page since
> it causes a big latency to the user. Instead, we would like to fallback
> lower order allocation that it actually needs.
> 
> However, we also want to get this higher order page in the next time
> in order to get the best performance and it would be a role of
> the background thread like as kswapd and kcompactd. To wake up them,
> we should not clear __GFP_KSWAPD_RECLAIM.
> 
> Unlike this intention, current code clears __GFP_KSWAPD_RECLAIM so fix it.
> Current unintended code is done by Mel's commit 444eb2a449ef ("mm: thp:
> set THP defrag by default to madvise and add a stall-free defrag option")
> for slub part. It removes a special case in __alloc_page_slowpath()
> where including __GFP_THISNODE and lacking ~__GFP_DIRECT_RECLAIM
> effectively means also lacking __GFP_KSWAPD_RECLAIM. However, slub
> doesn't use __GFP_THISNODE so it is not the case for this purpose. So,
> partially reverting this code in slub doesn't hurt Mel's intention.
> 
> Note that this patch does some clean up, too.
> __GFP_NOFAIL is cleared twice so remove one.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/slub.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 163352c..45f4a4b 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1578,8 +1578,12 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	 * so we fall-back to the minimum order allocation.
>  	 */
>  	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> -	if ((alloc_gfp & __GFP_DIRECT_RECLAIM) && oo_order(oo) > oo_order(s->min))
> -		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~(__GFP_RECLAIM|__GFP_NOFAIL);
> +	if (oo_order(oo) > oo_order(s->min)) {
> +		if (alloc_gfp & __GFP_DIRECT_RECLAIM) {
> +			alloc_gfp |= __GFP_NOMEMALLOC;
> +			alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
> +		}
> +	}
>  
>  	page = alloc_slab_page(s, alloc_gfp, node, oo);
>  	if (unlikely(!page)) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
