Date: Sun, 21 May 2006 03:59:06 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2/2] mm: handle unaligned zones
Message-Id: <20060521035906.3a9997b0.akpm@osdl.org>
In-Reply-To: <4470417F.2000605@yahoo.com.au>
References: <4470232B.7040802@yahoo.com.au>
	<44702358.1090801@yahoo.com.au>
	<20060521021905.0f73e01a.akpm@osdl.org>
	<4470417F.2000605@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: apw@shadowen.org, mel@csn.ul.ie, stable@kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> >>+ * This function checks whether a buddy is free and is the buddy of page.
>  >>+ * We can coalesce a page and its buddy if
>  >>+ * (a) the buddy is not "outside" the zone &&
>  >>  * (b) the buddy is in the buddy system &&
>  >>  * (c) a page and its buddy have the same order.
>  >>  *
>  >>@@ -292,15 +320,13 @@ __find_combined_index(unsigned long page
>  >>  *
>  >>  * For recording page's order, we use page_private(page).
>  >>  */
>  >>-static inline int page_is_buddy(struct page *page, int order)
>  >>+static inline int page_is_buddy(struct page *page, struct page *buddy, int order)
>  >> {
>  >>-#ifdef CONFIG_HOLES_IN_ZONE
>  >>-	if (!pfn_valid(page_to_pfn(page)))
>  >>+	if (buddy_outside_zone(page, buddy))
>  >> 		return 0;
>  > 
>  > 
>  > This is a heck of a lot of code to be throwing into the page-freeing
>  > hotpath.  Surely there's a way of moving all this work to
>  > initialisation/hotadd time?
> 
>  Can't think of any good way to do it. We could add yet another page
>  flag, which would relegate unaligned portions of zones to only order-0
>  pages (and never try to merge them up the buddy allocator).
> 
>  Of course that's another page flag.
> 
>  It is possible we can avoid the zone seqlock checks simply by always
>  testing whether the pfn is valid (this way the test would be more
>  unified with the holes in zone case).
> 
>  The tests would still be pretty heavyweight though.

How about just throwing the pages away?  It sounds like a pretty rare
problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
