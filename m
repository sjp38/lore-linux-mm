From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 01/10] zsmalloc: fix init_zspage free obj linking
Date: Thu, 11 Sep 2014 22:16:44 -0500
Message-ID: <20140912031644.GB17818@cerebellum.variantweb.net>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
 <1410468841-320-2-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410468841-320-2-git-send-email-ddstreet@ieee.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Thu, Sep 11, 2014 at 04:53:52PM -0400, Dan Streetman wrote:
> When zsmalloc creates a new zspage, it initializes each object it contains
> with a link to the next object, so that the zspage has a singly-linked list
> of its free objects.  However, the logic that sets up the links is wrong,
> and in the case of objects that are precisely aligned with the page boundries
> (e.g. a zspage with objects that are 1/2 PAGE_SIZE) the first object on the
> next page is skipped, due to incrementing the offset twice.  The logic can be
> simplified, as it doesn't need to calculate how many objects can fit on the
> current page; simply checking the offset for each object is enough.
> 
> Change zsmalloc init_zspage() logic to iterate through each object on
> each of its pages, checking the offset to verify the object is on the
> current page before linking it into the zspage.
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Minchan Kim <minchan@kernel.org>

This one stands on its own as a bugfix.

Reviewed-by: Seth Jennings <sjennings@variantweb.net>

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
