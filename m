Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 3AD146B00A9
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 18:32:54 -0500 (EST)
Date: Tue, 27 Nov 2012 21:32:44 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: fix balloon_page_movable() page->flags check
Message-ID: <20121127233243.GB1812@t510.redhat.com>
References: <20121127145708.c7173d0d.akpm@linux-foundation.org>
 <1ccb1c95a52185bcc6009761cb2829197e2737ea.1354058194.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ccb1c95a52185bcc6009761cb2829197e2737ea.1354058194.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>

On Tue, Nov 27, 2012 at 09:31:10PM -0200, Rafael Aquini wrote:
> This patch fixes the following crash by fixing and enhancing the way 
> page->flags are tested to identify a ballooned page.
> 
> ---8<---
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000194
> IP: [<ffffffff8122b354>] isolate_migratepages_range+0x344/0x7b0
> --->8---
> 
> The NULL pointer deref was taking place because balloon_page_movable()
> page->flags tests were incomplete and we ended up 
> inadvertently poking at private pages.
> 
> Reported-by: Sasha Levin <levinsasha928@gmail.com>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---

Here it is Andrew, sorry by the lagged reply

Cheers!
--Rafael


>  include/linux/balloon_compaction.h | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index 68893bc..634a19b 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -107,6 +107,23 @@ static inline void balloon_mapping_free(struct address_space *balloon_mapping)
>  }
>  
>  /*
> + * __balloon_page_flags - helper to perform balloon @page ->flags tests.
> + *
> + * As balloon pages are got from Buddy, and we do not play with page->flags
> + * at driver level (exception made when we get the page lock for compaction),
> + * therefore we can safely identify a ballooned page by checking if the
> + * NR_PAGEFLAGS rightmost bits from the page->flags are all cleared.
> + * This approach also helps on skipping ballooned pages that are locked for
> + * compaction or release, thus mitigating their racy check at
> + * balloon_page_movable()
> + */
> +#define BALLOON_PAGE_FLAGS_MASK       ((1UL << NR_PAGEFLAGS) - 1)
> +static inline bool __balloon_page_flags(struct page *page)
> +{
> +	return page->flags & BALLOON_PAGE_FLAGS_MASK ? false : true;
> +}
> +
> +/*
>   * __is_movable_balloon_page - helper to perform @page mapping->flags tests
>   */
>  static inline bool __is_movable_balloon_page(struct page *page)
> @@ -135,8 +152,8 @@ static inline bool balloon_page_movable(struct page *page)
>  	 * Before dereferencing and testing mapping->flags, lets make sure
>  	 * this is not a page that uses ->mapping in a different way
>  	 */
> -	if (!PageSlab(page) && !PageSwapCache(page) && !PageAnon(page) &&
> -	    !page_mapped(page))
> +	if (__balloon_page_flags(page) && !page_mapped(page) &&
> +	    page_count(page) == 1)
>  		return __is_movable_balloon_page(page);
>  
>  	return false;
> -- 
> 1.7.11.7
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
