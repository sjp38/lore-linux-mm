Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A80C66B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 08:38:38 -0500 (EST)
Received: by fxm22 with SMTP id 22so4104650fxm.6
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 05:38:35 -0800 (PST)
Subject: Re: [patch 1/3] vmscan: factor out page reference checks
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1266868150-25984-2-git-send-email-hannes@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org>
	 <1266868150-25984-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Feb 2010 22:38:23 +0900
Message-ID: <1266932303.2723.13.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Hannes. 

On Mon, 2010-02-22 at 20:49 +0100, Johannes Weiner wrote:
> Moving the big conditional into its own predicate function makes the
> code a bit easier to read and allows for better commenting on the
> checks one-by-one.
> 
> This is just cleaning up, no semantics should have been changed.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c |   53 ++++++++++++++++++++++++++++++++++++++++-------------
>  1 files changed, 40 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c26986c..c2db55b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -579,6 +579,37 @@ redo:
>  	put_page(page);		/* drop ref from isolate */
>  }
>  
> +enum page_references {
> +	PAGEREF_RECLAIM,
> +	PAGEREF_RECLAIM_CLEAN,
> +	PAGEREF_ACTIVATE,
> +};
> +
> +static enum page_references page_check_references(struct page *page,
> +						  struct scan_control *sc)
> +{
> +	unsigned long vm_flags;
> +	int referenced;
> +
> +	referenced = page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
> +	if (!referenced)
> +		return PAGEREF_RECLAIM;
> +
> +	/* Lumpy reclaim - ignore references */
> +	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> +		return PAGEREF_RECLAIM;
> +
> +	/* Mlock lost isolation race - let try_to_unmap() handle it */

How doest try_to_unamp handle it?

/* Page which PG_mlocked lost isolation race - let try_to_unmap() move
the page to unevitable list */

The point is to move the page into unevictable list in case of race. 
Let's write down comment more clearly. 
As it was, it was clear, I think. :)

> +	if (vm_flags & VM_LOCKED)
> +		return PAGEREF_RECLAIM;
> +
> +	if (page_mapping_inuse(page))
> +		return PAGEREF_ACTIVATE;
> +
> +	/* Reclaim if clean, defer dirty pages to writeback */
> +	return PAGEREF_RECLAIM_CLEAN;
> +}
> +
>  /*
>   * shrink_page_list() returns the number of reclaimed pages
>   */
> @@ -590,16 +621,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  	struct pagevec freed_pvec;
>  	int pgactivate = 0;
>  	unsigned long nr_reclaimed = 0;
> -	unsigned long vm_flags;
>  
>  	cond_resched();
>  
>  	pagevec_init(&freed_pvec, 1);
>  	while (!list_empty(page_list)) {
> +		enum page_references references;
>  		struct address_space *mapping;
>  		struct page *page;
>  		int may_enter_fs;
> -		int referenced;
>  
>  		cond_resched();
>  
> @@ -641,17 +671,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  		}
>  
> -		referenced = page_referenced(page, 1,
> -						sc->mem_cgroup, &vm_flags);
> -		/*
> -		 * In active use or really unfreeable?  Activate it.
> -		 * If page which have PG_mlocked lost isoltation race,
> -		 * try_to_unmap moves it to unevictable list
> -		 */
> -		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
> -					referenced && page_mapping_inuse(page)
> -					&& !(vm_flags & VM_LOCKED))
> +		references = page_check_references(page, sc);
> +		switch (references) {
> +		case PAGEREF_ACTIVATE:
>  			goto activate_locked;
> +		case PAGEREF_RECLAIM:
> +		case PAGEREF_RECLAIM_CLEAN:
> +			; /* try to reclaim the page below */
> +		}
>  
>  		/*
>  		 * Anonymous process memory has backing store?
> @@ -685,7 +712,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		}
>  
>  		if (PageDirty(page)) {
> -			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
> +			if (references == PAGEREF_RECLAIM_CLEAN)

How equal PAGEREF_RECLAIM_CLEAN and sc->order <= PAGE_ALLOC_COSTLY_ORDER
&& referenced by semantic? 
Dirtyness test is already done above line by PageDirty. 
So I think PAGEREF_RECLAIM_CLEAN isn't proper in there. 
What's your intention I don't catch? 


>  				goto keep_locked;
>  			if (!may_enter_fs)
>  				goto keep_locked;


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
