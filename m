Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 588B06B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 00:59:16 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so411514pab.4
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 21:59:16 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id fh5si5568901pbb.70.2014.09.11.21.59.14
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 21:59:15 -0700 (PDT)
Date: Fri, 12 Sep 2014 13:59:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 01/10] zsmalloc: fix init_zspage free obj linking
Message-ID: <20140912045913.GA2160@bbox>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
 <1410468841-320-2-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1410468841-320-2-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 11, 2014 at 04:53:52PM -0400, Dan Streetman wrote:
> When zsmalloc creates a new zspage, it initializes each object it contains
> with a link to the next object, so that the zspage has a singly-linked list
> of its free objects.  However, the logic that sets up the links is wrong,
> and in the case of objects that are precisely aligned with the page boundries
> (e.g. a zspage with objects that are 1/2 PAGE_SIZE) the first object on the
> next page is skipped, due to incrementing the offset twice.  The logic can be
> simplified, as it doesn't need to calculate how many objects can fit on the
> current page; simply checking the offset for each object is enough.

If objects are precisely aligned with the page boundary, pages_per_zspage
should be 1 so there is no next page.

> 
> Change zsmalloc init_zspage() logic to iterate through each object on
> each of its pages, checking the offset to verify the object is on the
> current page before linking it into the zspage.
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Minchan Kim <minchan@kernel.org>
> ---
>  mm/zsmalloc.c | 14 +++++---------
>  1 file changed, 5 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index c4a9157..03aa72f 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -628,7 +628,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
>  	while (page) {
>  		struct page *next_page;
>  		struct link_free *link;
> -		unsigned int i, objs_on_page;
> +		unsigned int i = 1;
>  
>  		/*
>  		 * page->index stores offset of first object starting
> @@ -641,14 +641,10 @@ static void init_zspage(struct page *first_page, struct size_class *class)
>  
>  		link = (struct link_free *)kmap_atomic(page) +
>  						off / sizeof(*link);
> -		objs_on_page = (PAGE_SIZE - off) / class->size;
>  
> -		for (i = 1; i <= objs_on_page; i++) {
> -			off += class->size;
> -			if (off < PAGE_SIZE) {
> -				link->next = obj_location_to_handle(page, i);
> -				link += class->size / sizeof(*link);
> -			}
> +		while ((off += class->size) < PAGE_SIZE) {
> +			link->next = obj_location_to_handle(page, i++);
> +			link += class->size / sizeof(*link);
>  		}
>  
>  		/*
> @@ -660,7 +656,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
>  		link->next = obj_location_to_handle(next_page, 0);
>  		kunmap_atomic(link);
>  		page = next_page;
> -		off = (off + class->size) % PAGE_SIZE;
> +		off %= PAGE_SIZE;
>  	}
>  }
>  
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
