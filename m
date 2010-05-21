Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 046E26B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 14:58:00 -0400 (EDT)
Date: Fri, 21 May 2010 11:57:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at
 first
Message-Id: <20100521115718.552d50dd.akpm@linux-foundation.org>
In-Reply-To: <20100521093629.1E44.A69D9226@jp.fujitsu.com>
References: <20100519174327.9591.A69D9226@jp.fujitsu.com>
	<20100520010032.GC4089@localhost>
	<20100521093629.1E44.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010 09:36:50 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> > 
> > The preceding comment "they need to go on the active_anon lru below"
> > also needs update.
> > 
> 
> Thanks. incremental patch is here.
> 
> 
> ---
>  include/linux/swap.h |   10 ----------
>  mm/filemap.c         |    2 +-
>  2 files changed, 1 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 18420a9..4bfd932 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -224,21 +224,11 @@ static inline void lru_cache_add_anon(struct page *page)
>  	__lru_cache_add(page, LRU_INACTIVE_ANON);
>  }
>  
> -static inline void lru_cache_add_active_anon(struct page *page)
> -{
> -	__lru_cache_add(page, LRU_ACTIVE_ANON);
> -}
> -
>  static inline void lru_cache_add_file(struct page *page)
>  {
>  	__lru_cache_add(page, LRU_INACTIVE_FILE);
>  }
>  
> -static inline void lru_cache_add_active_file(struct page *page)
> -{
> -	__lru_cache_add(page, LRU_ACTIVE_FILE);
> -}

Did you intend to remove these two functions?

They do appear to be unused now, but they still make sense and might be
used in the future, perhaps.  It's OK to remove them, but I'm wondering
if it was deliberately included in this patch?


>  /* LRU Isolation modes. */
>  #define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
>  #define ISOLATE_ACTIVE 1	/* Isolate active pages. */
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 023ef61..a57931a 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -441,7 +441,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
>  	/*
>  	 * Splice_read and readahead add shmem/tmpfs pages into the page cache
>  	 * before shmem_readpage has a chance to mark them as SwapBacked: they
> -	 * need to go on the active_anon lru below, and mem_cgroup_cache_charge
> +	 * need to go on the anon lru below, and mem_cgroup_cache_charge
>  	 * (called in add_to_page_cache) needs to know where they're going too.
>  	 */
>  	if (mapping_cap_swap_backed(mapping))
> -- 
> 1.6.5.2
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
