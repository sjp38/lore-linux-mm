Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 242D96B0072
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 15:25:57 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 20 Nov 2012 13:25:56 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B26221FF001B
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:25:49 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAKKPexx242406
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:25:40 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAKKPdtT009268
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:25:39 -0700
Message-ID: <50ABE741.2020604@linux.vnet.ibm.com>
Date: Tue, 20 Nov 2012 12:25:37 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [3.7-rc6] capture_free_page() frees page without accounting for them??
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

I'm chasing an apparent memory leak introduced post-3.6.  The
interesting thing is that it appears that the pages are in the
allocator, but not being accounted for:

	http://www.spinics.net/lists/linux-mm/msg46187.html
	https://bugzilla.kernel.org/show_bug.cgi?id=50181

I started auditing anything that might be messing with NR_FREE_PAGES,
and came across commit 1fb3f8ca.  It does something curious with
capture_free_page() (previously known as split_free_page()).

int capture_free_page(struct page *page, int alloc_order,
...
        __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));

-       /* Split into individual pages */
-       set_page_refcounted(page);
-       split_page(page, order);
+       if (alloc_order != order)
+               expand(zone, page, alloc_order, order,
+                       &zone->free_area[order], migratetype);

Note that expand() puts the pages _back_ in the allocator, but it does
not bump NR_FREE_PAGES.  We "return" alloc_order' worth of pages, but we
accounted for removing 'order'.

I _think_ the correct fix is to just:

-     __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+     __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << alloc_order));

I'm trying to confirm the theory my making this happen a bit more often,
but I'd appreciate a second pair of eyes on the code in case I'm reading
it wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
