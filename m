Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9B6386B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 02:55:36 -0500 (EST)
Message-ID: <509A137C.3020903@mellanox.com>
Date: Wed, 7 Nov 2012 09:53:32 +0200
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: fix build warning for uninitialized value
References: <alpine.DEB.2.00.1210312234180.31758@chino.kir.corp.google.com> <alpine.DEB.2.00.1211051334490.5296@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211051334490.5296@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/11/2012 23:36, David Rientjes wrote:
> do_wp_page() sets mmun_called if mmun_start and mmun_end were initialized 
> and, if so, may call mmu_notifier_invalidate_range_end() with these 
> values.  This doesn't prevent gcc from emitting a build warning though:
> 
> mm/memory.c: In function a??do_wp_pagea??:
> mm/memory.c:2530: warning: a??mmun_starta?? may be used uninitialized in this function
> mm/memory.c:2531: warning: a??mmun_enda?? may be used uninitialized in this function

I haven't seen these warning. Perhaps I used a different compiler
version, or the right flags.

> 
> It's much easier to initialize the variables to impossible values and do a 
> simple comparison to determine if they were initialized to remove the bool 
> entirely.

This solution looks great to me.

> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memory.c |   10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2527,9 +2527,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int ret = 0;
>  	int page_mkwrite = 0;
>  	struct page *dirty_page = NULL;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> -	bool mmun_called = false;	/* For mmu_notifiers */
> +	unsigned long mmun_start = 0;	/* For mmu_notifiers */
> +	unsigned long mmun_end = 0;	/* For mmu_notifiers */
>  
>  	old_page = vm_normal_page(vma, address, orig_pte);
>  	if (!old_page) {
> @@ -2708,8 +2707,7 @@ gotten:
>  		goto oom_free_new;
>  
>  	mmun_start  = address & PAGE_MASK;
> -	mmun_end    = (address & PAGE_MASK) + PAGE_SIZE;
> -	mmun_called = true;
> +	mmun_end    = mmun_start + PAGE_SIZE;
>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>  
>  	/*
> @@ -2778,7 +2776,7 @@ gotten:
>  		page_cache_release(new_page);
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
> -	if (mmun_called)
> +	if (mmun_end > mmun_start)
>  		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  	if (old_page) {
>  		/*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
