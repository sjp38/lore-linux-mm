Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EEC596B01AF
	for <linux-mm@kvack.org>; Sun,  4 Jul 2010 06:18:01 -0400 (EDT)
Date: Sun, 4 Jul 2010 12:16:40 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] slob:Use _safe funtion to iterate partially free list.
Message-ID: <20100704101640.GA1634@cmpxchg.org>
References: <1278235353-9638-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278235353-9638-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sun, Jul 04, 2010 at 05:22:33PM +0800, Bob Liu wrote:
> Since a list entry may be removed, so use list_for_each_entry_safe
> instead of list_for_each_entry.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/slob.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slob.c b/mm/slob.c
> index 3f19a34..e2af18b 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -320,7 +320,7 @@ static void *slob_page_alloc(struct slob_page *sp, size_t size, int align)
>   */
>  static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
>  {
> -	struct slob_page *sp;
> +	struct slob_page *sp, *tmp;
>  	struct list_head *prev;
>  	struct list_head *slob_list;
>  	slob_t *b = NULL;
> @@ -335,7 +335,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
>  
>  	spin_lock_irqsave(&slob_lock, flags);
>  	/* Iterate through each partially free page, try to find room */
> -	list_for_each_entry(sp, slob_list, list) {
> +	list_for_each_entry_safe(sp, tmp, slob_list, list) {    
>  #ifdef CONFIG_NUMA

sp's list head is only modified if an allocation was successful, but
then the iteration stops as well.  So I see no reason for your patch.
Did I overlook something?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
