Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 57ED36B006C
	for <linux-mm@kvack.org>; Sun, 13 Nov 2011 20:46:17 -0500 (EST)
Received: by ywp17 with SMTP id 17so2933819ywp.14
        for <linux-mm@kvack.org>; Sun, 13 Nov 2011 17:46:15 -0800 (PST)
Date: Sun, 13 Nov 2011 17:46:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/4] mm: remove unused pagevec_free
In-Reply-To: <20111111124001.7371.17791.stgit@zurg>
Message-ID: <alpine.LSU.2.00.1111131745350.1239@sister.anvils>
References: <20110729075837.12274.58405.stgit@localhost6> <20111111124001.7371.17791.stgit@zurg>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>

On Fri, 11 Nov 2011, Konstantin Khlebnikov wrote:

> It not exported and now nobody use it.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  include/linux/pagevec.h |    7 -------
>  mm/page_alloc.c         |   10 ----------
>  2 files changed, 0 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
> index bab82f4..ed17024 100644
> --- a/include/linux/pagevec.h
> +++ b/include/linux/pagevec.h
> @@ -21,7 +21,6 @@ struct pagevec {
>  };
>  
>  void __pagevec_release(struct pagevec *pvec);
> -void __pagevec_free(struct pagevec *pvec);
>  void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
>  void pagevec_strip(struct pagevec *pvec);
>  unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
> @@ -67,12 +66,6 @@ static inline void pagevec_release(struct pagevec *pvec)
>  		__pagevec_release(pvec);
>  }
>  
> -static inline void pagevec_free(struct pagevec *pvec)
> -{
> -	if (pagevec_count(pvec))
> -		__pagevec_free(pvec);
> -}
> -
>  static inline void __pagevec_lru_add_anon(struct pagevec *pvec)
>  {
>  	____pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5093114..0562d85 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2341,16 +2341,6 @@ unsigned long get_zeroed_page(gfp_t gfp_mask)
>  }
>  EXPORT_SYMBOL(get_zeroed_page);
>  
> -void __pagevec_free(struct pagevec *pvec)
> -{
> -	int i = pagevec_count(pvec);
> -
> -	while (--i >= 0) {
> -		trace_mm_pagevec_free(pvec->pages[i], pvec->cold);
> -		free_hot_cold_page(pvec->pages[i], pvec->cold);
> -	}
> -}
> -
>  void __free_pages(struct page *page, unsigned int order)
>  {
>  	if (put_page_testzero(page)) {
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
