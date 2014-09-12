From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 03/10] zsmalloc: always update lru ordering of each zspage
Date: Thu, 11 Sep 2014 22:20:32 -0500
Message-ID: <20140912032032.GC17818@cerebellum.variantweb.net>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
 <1410468841-320-4-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410468841-320-4-git-send-email-ddstreet@ieee.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Thu, Sep 11, 2014 at 04:53:54PM -0400, Dan Streetman wrote:
> Update ordering of a changed zspage in its fullness group LRU list,
> even if it has not moved to a different fullness group.
> 
> This is needed by zsmalloc shrinking, which partially relies on each
> class fullness group list to be kept in LRU order, so the oldest can
> be reclaimed first.  Currently, LRU ordering is only updated when
> a zspage changes fullness groups.

Just something I saw.

fix_fullness_group() is called from zs_free(), which means that removing
an object from a zspage moves it to the front of the LRU.  Not sure if
that is what we want.  If anything that makes it a _better_ candidate
for reclaim as the zspage is now contains fewer objects that we'll have
to decompress and writeback.

Seth

> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Minchan Kim <minchan@kernel.org>
> ---
>  mm/zsmalloc.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index fedb70f..51db622 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -467,16 +467,14 @@ static enum fullness_group fix_fullness_group(struct zs_pool *pool,
>  	BUG_ON(!is_first_page(page));
>  
>  	get_zspage_mapping(page, &class_idx, &currfg);
> -	newfg = get_fullness_group(page);
> -	if (newfg == currfg)
> -		goto out;
> -
>  	class = &pool->size_class[class_idx];
> +	newfg = get_fullness_group(page);
> +	/* Need to do this even if currfg == newfg, to update lru */
>  	remove_zspage(page, class, currfg);
>  	insert_zspage(page, class, newfg);
> -	set_zspage_mapping(page, class_idx, newfg);
> +	if (currfg != newfg)
> +		set_zspage_mapping(page, class_idx, newfg);
>  
> -out:
>  	return newfg;
>  }
>  
> -- 
> 1.8.3.1
> 
