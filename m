Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 5A1A46B0078
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 19:49:06 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 20 Nov 2012 19:49:05 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 87DF86E803A
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 19:48:56 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAL0muJG313404
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 19:48:56 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAL0muaL031986
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 22:48:56 -0200
Message-ID: <50AC24F5.9090303@linux.vnet.ibm.com>
Date: Tue, 20 Nov 2012 16:48:53 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [3.7-rc6] capture_free_page() frees page without accounting for
 them??
References: <50ABE741.2020604@linux.vnet.ibm.com>
In-Reply-To: <50ABE741.2020604@linux.vnet.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------060201040006090003020504"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------060201040006090003020504
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

I'm really evil, so I changed the loop in compact_capture_page() to
basically steal the highest-order page it can.  This shouldn't _break_
anything, but it does ensure that we'll be splitting pages that we find
more often and recreating this *MUCH* faster:

-               for (order = cc->order; order < MAX_ORDER; order++) {
+               for (order = MAX_ORDER - 1; order >= cc->order;order--)

I also augmented the area in capture_free_page() that I expect to be
leaking:

        if (alloc_order != order) {
                static int leaked_pages = 0;
                leaked_pages += 1<<order;
                leaked_pages -= 1<<alloc_order;
                printk("%s() alloc_order(%d) != order(%d) leaked %d\n",
                                __func__, alloc_order, order,
				leaked_pages);
                expand(zone, page, alloc_order, order,
                        &zone->free_area[order], migratetype);
        }

I add up all the fields in buddyinfo to figure out how much _should_ be
in the allocator and then compare it to MemFree to get a guess at how
much is leaked.  That number correlates _really_ well with the
"leaked_pages" variable above.  That pretty much seals it for me.

I'll run a stress test overnight to see if it pops up again.  The patch
I'm running is attached.  I'll send a properly changelogged one tomorrow
if it works.


--------------060201040006090003020504
Content-Type: text/x-patch;
 name="leak-fix-20121120-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="leak-fix-20121120-1.patch"



---

 linux-2.6.git-dave/mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/page_alloc.c~leak-fix-20121120-1 mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~leak-fix-20121120-1	2012-11-20 19:44:09.588966346 -0500
+++ linux-2.6.git-dave/mm/page_alloc.c	2012-11-20 19:44:21.993057915 -0500
@@ -1405,7 +1405,7 @@ int capture_free_page(struct page *page,
 
 	mt = get_pageblock_migratetype(page);
 	if (unlikely(mt != MIGRATE_ISOLATE))
-		__mod_zone_freepage_state(zone, -(1UL << order), mt);
+		__mod_zone_freepage_state(zone, -(1UL << alloc_order), mt);
 
 	if (alloc_order != order)
 		expand(zone, page, alloc_order, order,
_

--------------060201040006090003020504--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
