Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8740F829AA
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:30:56 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2943634eei.0
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:30:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si13720651eeh.183.2014.05.06.08.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 08:30:55 -0700 (PDT)
Message-ID: <5369002D.7030600@suse.cz>
Date: Tue, 06 May 2014 17:30:53 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 15/17] mm: Do not use unnecessary atomic operations when
 adding pages to the LRU
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-16-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 10:44 AM, Mel Gorman wrote:
> When adding pages to the LRU we clear the active bit unconditionally. As the
> page could be reachable from other paths we cannot use unlocked operations
> without risk of corruption such as a parallel mark_page_accessed. This
> patch test if is necessary to clear the atomic flag before using an atomic

                                           active

> operation. In the unlikely even this races with mark_page_accesssed the
> consequences are simply that the page may be promoted to the active list
> that might have been left on the inactive list before the patch. This is
> a marginal consequence.

Well if this is racy, then even before the patch, mark_page_accessed 
might have come right after ClearPageActive(page) anyway? Or is the 
changelog saying that this change only extended the race window that 
already existed? If yes it could be more explicit, as now it might sound 
as if the race was introduced.

> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>   include/linux/swap.h | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index da8a250..395dcab 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -329,13 +329,15 @@ extern void add_page_to_unevictable_list(struct page *page);
>    */
>   static inline void lru_cache_add_anon(struct page *page)
>   {
> -	ClearPageActive(page);
> +	if (PageActive(page))
> +		ClearPageActive(page);
>   	__lru_cache_add(page);
>   }
>
>   static inline void lru_cache_add_file(struct page *page)
>   {
> -	ClearPageActive(page);
> +	if (PageActive(page))
> +		ClearPageActive(page);
>   	__lru_cache_add(page);
>   }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
