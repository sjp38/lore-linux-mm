Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9B0086B016A
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 11:00:52 -0400 (EDT)
Received: by yxe10 with SMTP id 10so3826172yxe.12
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:00:51 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 22 Sep 2009 00:00:51 +0900
Message-ID: <2f11576a0909210800l639560e4jad6cfc2e7f74538f@mail.gmail.com>
Subject: a patch drop request in -mm
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel,

Today, my test found following patch makes false-positive warning.
because, truncate can free the pages
although the pages are mlock()ed.

So, I think following patch should be dropped.
.. or, do you think truncate should clear PG_mlock before free the page?

Can I ask your patch intention?


=============================================================
commit 7a06930af46eb39351cbcdc1ab98701259f9a72c
Author: Mel Gorman <mel@csn.ul.ie>
Date:   Tue Aug 25 00:43:07 2009 +0200

    When a page is freed with the PG_mlocked set, it is considered an
    unexpected but recoverable situation.  A counter records how often this
    event happens but it is easy to miss that this event has occured at
    all.  This patch warns once when PG_mlocked is set to prompt debuggers
    to check the counter to see how often it is happening.

    Signed-off-by: Mel Gorman <mel@csn.ul.ie>
    Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
    Acked-by: Johannes Weiner <hannes@cmpxchg.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 28c2f3e..251fd73 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -494,6 +494,11 @@ static inline void __free_one_page(struct page *page,
  */
 static inline void free_page_mlock(struct page *page)
 {
+       WARN_ONCE(1, KERN_WARNING
+               "Page flag mlocked set for process %s at pfn:%05lx\n"
+               "page:%p flags:%#lx\n",
+               current->comm, page_to_pfn(page),
+               page, page->flags|__PG_MLOCKED);
        __dec_zone_page_state(page, NR_MLOCK);
        __count_vm_event(UNEVICTABLE_MLOCKFREED);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
