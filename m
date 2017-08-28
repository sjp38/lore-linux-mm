Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0B406B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 06:04:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a47so94846wra.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 03:04:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b83si20181wmc.139.2017.08.28.03.04.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 03:04:43 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm/slub: wake up kswapd for initial high order
 allocation
References: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f1423efc-3c60-c03e-0d81-f2e8fcccbcd6@suse.cz>
Date: Mon, 28 Aug 2017 12:04:41 +0200
MIME-Version: 1.0
In-Reply-To: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 08/28/2017 03:11 AM, js1304@gmail.com wrote:
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
> 
> Note that this patch does some clean up, too.
> __GFP_NOFAIL is cleared twice so remove one.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hm, so this seems to revert Mel's 444eb2a449ef ("mm: thp: set THP defrag
by default to madvise and add a stall-free defrag option") wrt the slub
allocate_slab() part. AFAICS the intention in Mel's patch was that he
removed a special case in __alloc_page_slowpath() where including
__GFP_THISNODE and lacking ~__GFP_DIRECT_RECLAIM effectively means also
lacking __GFP_KSWAPD_RECLAIM. The commit log claims that slab/slub might
change behavior so he moved the removal of __GFP_KSWAPD_RECLAIM to them.

But AFAICS, only slab uses __GFP_THISNODE, while slub doesn't. So your
patch would indeed revert an unintentional change of Mel's commit. Is it
right or do I miss something?

> ---
>  mm/slub.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 0dc7397..e1e442c 100644
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
