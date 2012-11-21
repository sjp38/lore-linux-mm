Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 5819E6B00AD
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:33:09 -0500 (EST)
Date: Wed, 21 Nov 2012 14:33:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [3.7-rc6] capture_free_page() frees page without accounting for
 them??
Message-ID: <20121121143303.GD8218@suse.de>
References: <50ABE741.2020604@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50ABE741.2020604@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 20, 2012 at 12:25:37PM -0800, Dave Hansen wrote:
> Hi Mel,
> 
> I'm chasing an apparent memory leak introduced post-3.6. 

An accounting leak could also contribute to the kswapd bugs we've been
seeing recently.

Andrew, this is quite important and might be worth wedging in before 3.7
comes out because it'll cause serious problems if Dave is right.

> The
> interesting thing is that it appears that the pages are in the
> allocator, but not being accounted for:
> 
> 	http://www.spinics.net/lists/linux-mm/msg46187.html
> 	https://bugzilla.kernel.org/show_bug.cgi?id=50181
> 

Differences in the buddy allocator and reported free figures almost
always point to either per-cpu drift or NR_FREE_PAGES accounting bugs.
Usually the drift is not too bad and the drift is always within a
margin related to the number of CPUs. NR_FREE_PAGES accounting bugs get
progressively worse until the machine starts OOM killing or locks up.

> I started auditing anything that might be messing with NR_FREE_PAGES,
> and came across commit 1fb3f8ca. 

It could certainly affect NR_FREE_PAGES due to its manipulating of buddy
pages. It will not result in happy and the system would potentially need
to be running a long time before it's spotted.

> It does something curious with
> capture_free_page() (previously known as split_free_page()).
> 
> int capture_free_page(struct page *page, int alloc_order,
> ...
>         __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> 
> -       /* Split into individual pages */
> -       set_page_refcounted(page);
> -       split_page(page, order);
> +       if (alloc_order != order)
> +               expand(zone, page, alloc_order, order,
> +                       &zone->free_area[order], migratetype);
> 
> Note that expand() puts the pages _back_ in the allocator, but it does
> not bump NR_FREE_PAGES.  We "return" alloc_order' worth of pages, but we
> accounted for removing 'order'.
> 
> I _think_ the correct fix is to just:
> 
> -     __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> +     __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << alloc_order));
> 

This looks correct to me but it will collide with other patches. You'll
need something like the below. If it works for you, stick a changelog on
it, feel free to put my Acked on it and get it to Andrew for ASAP
because I really think this needs to be in before 3.7 comes out or we'll
be swamped with a maze of kswapd-goes-mental bugs, all similar with
different root causes.

Thanks a million Dave!


diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fd6a073..ad99f0f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1406,7 +1406,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 
 	mt = get_pageblock_migratetype(page);
 	if (unlikely(mt != MIGRATE_ISOLATE))
-		__mod_zone_freepage_state(zone, -(1UL << order), mt);
+		__mod_zone_freepage_state(zone, -(1UL << alloc_order), mt);
 
 	if (alloc_order != order)
 		expand(zone, page, alloc_order, order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
