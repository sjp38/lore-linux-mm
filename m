Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9B9AB6B002F
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 18:14:07 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC 2/3] PM / Hibernate : do not count debug pages as savable
Date: Tue, 18 Oct 2011 00:16:26 +0200
References: <1318861486-3942-1-git-send-email-sgruszka@redhat.com> <1318861486-3942-2-git-send-email-sgruszka@redhat.com>
In-Reply-To: <1318861486-3942-2-git-send-email-sgruszka@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Message-Id: <201110180016.26757.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>

On Monday, October 17, 2011, Stanislaw Gruszka wrote:
> When debugging memory corruption with CONFIG_DEBUG_PAGEALLOC and
> corrupt_dbg > 0, we have lot of free pages that are not marked so.
> Snapshot code account them as savable, what cause hibernate memory
> preallocation failure.
> 
> It is pretty hard to make hibernate allocation succeed with
> corrupt_dbg=1. This change at least make it possible when system has
> relatively big amount of RAM.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

> ---
>  include/linux/mm.h      |    7 ++++++-
>  kernel/power/snapshot.c |    6 ++++++
>  mm/page_alloc.c         |    6 ------
>  3 files changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 17e3658..651785b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1630,13 +1630,18 @@ extern void copy_user_huge_page(struct page *dst, struct page *src,
>  #ifdef CONFIG_DEBUG_PAGEALLOC
>  extern unsigned int _corrupt_dbg;
>  
> -
>  static inline unsigned int corrupt_dbg(void)
>  {
>  	return _corrupt_dbg;
>  }
> +
> +static inline bool page_is_corrupt_dbg(struct page *page)
> +{
> +	return test_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
> +}
>  #else
>  static inline unsigned int corrupt_dbg(void) { return 0; }
> +static inline bool page_is_corrupt_dbg(struct page *page) { return false; }
>  #endif /* CONFIG_DEBUG_PAGEALLOC */
>  
>  #endif /* __KERNEL__ */
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index 06efa54..45cf1b1 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -858,6 +858,9 @@ static struct page *saveable_highmem_page(struct zone *zone, unsigned long pfn)
>  	    PageReserved(page))
>  		return NULL;
>  
> +	if (page_is_corrupt_dbg(page))
> +		return NULL;
> +
>  	return page;
>  }
>  
> @@ -920,6 +923,9 @@ static struct page *saveable_page(struct zone *zone, unsigned long pfn)
>  	    && (!kernel_page_present(page) || pfn_is_nosave(pfn)))
>  		return NULL;
>  
> +	if (page_is_corrupt_dbg(page))
> +		return NULL;
> +
>  	return page;
>  }
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8d18ae4..8a7770a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -425,15 +425,9 @@ static inline void clear_page_corrupt_dbg(struct page *page)
>  	__clear_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
>  }
>  
> -static inline bool page_is_corrupt_dbg(struct page *page)
> -{
> -	return test_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
> -}
> -
>  #else
>  static inline void set_page_corrupt_dbg(struct page *page) { }
>  static inline void clear_page_corrupt_dbg(struct page *page) { }
> -static inline bool page_is_corrupt_dbg(struct page *page) { return false; }
>  #endif
>  
>  static inline void set_page_order(struct page *page, int order)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
