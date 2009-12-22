Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F23EE620002
	for <linux-mm@kvack.org>; Tue, 22 Dec 2009 18:35:40 -0500 (EST)
Date: Tue, 22 Dec 2009 15:35:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH 00 of 28] Transparent Hugepage
 support #2]
Message-Id: <20091222153504.5ad9a16d.akpm@linux-foundation.org>
In-Reply-To: <20091219160300.GB29790@random.random>
References: <20091218163058.GT29790@random.random>
	<20091218114236.e883671a.akpm@linux-foundation.org>
	<20091219160300.GB29790@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

On Sat, 19 Dec 2009 17:03:00 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> Subject: clear_huge_page fix
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> sz is in bytes, MAX_ORDER_NR_PAGES is in pages.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -401,7 +401,7 @@ static void clear_huge_page(struct page 
>  {
>  	int i;
>  
> -	if (unlikely(sz > MAX_ORDER_NR_PAGES)) {
> +	if (unlikely(sz/PAGE_SIZE > MAX_ORDER_NR_PAGES)) {
>  		clear_gigantic_page(page, addr, sz);
>  		return;
>  	}

: static void clear_huge_page(struct page *page,
: 			unsigned long addr, unsigned long sz)
: {
: 	int i;
: 
: 	if (unlikely(sz > MAX_ORDER_NR_PAGES)) {
: 		clear_gigantic_page(page, addr, sz);
: 		return;
: 	}
: 
: 	might_sleep();
: 	for (i = 0; i < sz/PAGE_SIZE; i++) {
: 		cond_resched();
: 		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
: 	}
: }

umph.  So we've basically never executed the clear_user_highpage() loop.

Is there any point in retaining it?  Why not just call
clear_gigantic_page() all the time, as we've been doing?  All it does
it to avoid a call to mem_map_next() per clear_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
