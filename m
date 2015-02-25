Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 096656B0075
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 19:16:06 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id h15so1715106igd.3
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:16:05 -0800 (PST)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id e10si11220560igl.32.2015.02.24.16.16.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 16:16:05 -0800 (PST)
Received: by iecrp18 with SMTP id rp18so616691iec.9
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:16:05 -0800 (PST)
Date: Tue, 24 Feb 2015 16:16:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hugetlb: close race when setting PageTail for gigantic
 pages
Message-ID: <alpine.DEB.2.10.1502241614480.4646@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <dave@stgolabs.net>, Luiz Capitulino <lcapitulino@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Now that gigantic pages are dynamically allocatable, care must be taken
to ensure that p->first_page is valid before setting PageTail.

If this isn't done, then it is possible to race and have compound_head()
return NULL.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -917,7 +917,6 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 	__SetPageHead(page);
 	__ClearPageReserved(page);
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
-		__SetPageTail(p);
 		/*
 		 * For gigantic hugepages allocated through bootmem at
 		 * boot, it's safer to be consistent with the not-gigantic
@@ -933,6 +932,9 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
 		p->first_page = page;
+		/* Make sure p->first_page is always valid for PageTail() */
+		smp_wmb();
+		__SetPageTail(p);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
