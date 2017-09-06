From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm/slub: wake up kswapd for initial high order
 allocation
Date: Wed, 6 Sep 2017 10:59:09 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709061056270.13344@nuc-kabylake>
References: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
List-Id: linux-mm.kvack.org

On Wed, 6 Sep 2017, js1304@gmail.com wrote:

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

Can we come up with another inline function in gfp.h for this as well?

Well and needing these functions to manipulate flags actually indicates
that we may need a cleanup of the GFP flags at some point. There is a buch
of flags that disable things and some that enable things.
