Date: Mon, 01 Dec 2003 11:40:46 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] Clear dirty bits etc on compound frees
Message-ID: <33500000.1070307646@flay>
In-Reply-To: <22420000.1069877625@[10.10.2.4]>
References: <22420000.1069877625@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm mailing list <linux-mm@kvack.org>, Guillaume Morin <guillaume@morinfr.org>
List-ID: <linux-mm.kvack.org>

> Guillaume noticed this on s390 whilst writing a driver that used
> compound pages. Seems correct to me, I've tested it on i386 as
> well. The patch just makes us call free_pages_check for each element
> of a compound page.
> 
> diff -purN -X /home/mbligh/.diff.exclude virgin/mm/page_alloc.c clear_dirty/mm/page_alloc.c
> --- virgin/mm/page_alloc.c	2003-10-14 15:50:36.000000000 -0700
> +++ clear_dirty/mm/page_alloc.c	2003-11-26 10:36:04.000000000 -0800
> @@ -267,8 +267,11 @@ free_pages_bulk(struct zone *zone, int c
>  void __free_pages_ok(struct page *page, unsigned int order)
>  {
>  	LIST_HEAD(list);
> +	int i;
>  
>  	mod_page_state(pgfree, 1 << order);
> +	for (i = 0 ; i < (1 << order) ; ++i)
> +		free_pages_check(__FUNCTION__, page + i);
>  	free_pages_check(__FUNCTION__, page);
>  	list_add(&page->list, &list);
>  	kernel_map_pages(page, 1<<order, 0);

Gah. Guillaume pointed out that in editing his patch, I left the old 
free pages check in as well. <beats head repeatedly against wall>. Sorry.

I think you can reproduce this without the driver he's playing with
by mmap'ing /dev/mem, and writing into any clustered page group (that
a driver might have created or whatever).

diff -purN -X /home/mbligh/.diff.exclude virgin/mm/page_alloc.c clear_dirty/mm/page_alloc.c
--- virgin/mm/page_alloc.c	2003-10-14 15:50:36.000000000 -0700
+++ clear_dirty/mm/page_alloc.c	2003-12-01 11:34:09.000000000 -0800
@@ -267,9 +267,11 @@ free_pages_bulk(struct zone *zone, int c
 void __free_pages_ok(struct page *page, unsigned int order)
 {
 	LIST_HEAD(list);
+	int i;
 
 	mod_page_state(pgfree, 1 << order);
-	free_pages_check(__FUNCTION__, page);
+	for (i = 0 ; i < (1 << order) ; ++i)
+		free_pages_check(__FUNCTION__, page + i);
 	list_add(&page->list, &list);
 	kernel_map_pages(page, 1<<order, 0);
 	free_pages_bulk(page_zone(page), 1, &list, order);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
