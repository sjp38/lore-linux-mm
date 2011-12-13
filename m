Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A0B556B028D
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 17:05:09 -0500 (EST)
Date: Tue, 13 Dec 2011 14:05:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4] mm: page_alloc: remove order assumption from
 __free_pages_bootmem()
Message-Id: <20111213140507.d0727989.akpm@linux-foundation.org>
In-Reply-To: <1323784711-1937-2-git-send-email-hannes@cmpxchg.org>
References: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
	<1323784711-1937-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

On Tue, 13 Dec 2011 14:58:28 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Even though bootmem passes an order with the page to be freed,
> __free_pages_bootmem() assumes that 1 << order is always BITS_PER_LONG
> if non-zero.  While this happens to be true, it's not really robust.
> Remove that assumption and use 1 << order instead.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/page_alloc.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2b8ba3a..4d5e91c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -703,13 +703,14 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
>  		set_page_refcounted(page);
>  		__free_page(page);
>  	} else {
> -		int loop;
> +		unsigned int nr_pages = 1 << order;
> +		unsigned int loop;
>  
>  		prefetchw(page);
> -		for (loop = 0; loop < BITS_PER_LONG; loop++) {
> +		for (loop = 0; loop < nr_pages; loop++) {
>  			struct page *p = &page[loop];
>  
> -			if (loop + 1 < BITS_PER_LONG)
> +			if (loop + 1 < nr_pages)
>  				prefetchw(p + 1);
>  			__ClearPageReserved(p);
>  			set_page_count(p, 0);

Tejun has recently secretly snuck the below (rather old) patch into
linux-next's page_alloc.c.  I think I got everything fixed up right -
please check.

commit 53348f27168534561c0c814843bbf181314374f4
Author:     Tejun Heo <tj@kernel.org>
AuthorDate: Tue Jul 12 09:58:06 2011 +0200
Commit:     H. Peter Anvin <hpa@linux.intel.com>
CommitDate: Wed Jul 13 16:35:56 2011 -0700

    bootmem: Fix __free_pages_bootmem() to use @order properly
    
    a226f6c899 (FRV: Clean up bootmem allocator's page freeing algorithm)
    separated out __free_pages_bootmem() from free_all_bootmem_core().
    __free_pages_bootmem() takes @order argument but it assumes @order is
    either 0 or ilog2(BITS_PER_LONG).  Note that all the current users
    match that assumption and this doesn't cause actual problems.
    
    Fix it by using 1 << order instead of BITS_PER_LONG.
    
    Signed-off-by: Tejun Heo <tj@kernel.org>
    Link: http://lkml.kernel.org/r/1310457490-3356-3-git-send-email-tj@kernel.org
    Cc: David Howells <dhowells@redhat.com>
    Signed-off-by: H. Peter Anvin <hpa@linux.intel.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9119faa..b6da6ed 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -705,10 +705,10 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 		int loop;
 
 		prefetchw(page);
-		for (loop = 0; loop < BITS_PER_LONG; loop++) {
+		for (loop = 0; loop < (1 << order); loop++) {
 			struct page *p = &page[loop];
 
-			if (loop + 1 < BITS_PER_LONG)
+			if (loop + 1 < (1 << order))
 				prefetchw(p + 1);
 			__ClearPageReserved(p);
 			set_page_count(p, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
