Date: Wed, 26 Nov 2003 12:13:45 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: [PATCH] Clear dirty bits etc on compound frees
Message-ID: <22420000.1069877625@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm mailing list <linux-mm@kvack.org>, Guillaume Morin <guillaume@morinfr.org>
List-ID: <linux-mm.kvack.org>

Guillaume noticed this on s390 whilst writing a driver that used
compound pages. Seems correct to me, I've tested it on i386 as
well. The patch just makes us call free_pages_check for each element
of a compound page.

diff -purN -X /home/mbligh/.diff.exclude virgin/mm/page_alloc.c clear_dirty/mm/page_alloc.c
--- virgin/mm/page_alloc.c	2003-10-14 15:50:36.000000000 -0700
+++ clear_dirty/mm/page_alloc.c	2003-11-26 10:36:04.000000000 -0800
@@ -267,8 +267,11 @@ free_pages_bulk(struct zone *zone, int c
 void __free_pages_ok(struct page *page, unsigned int order)
 {
 	LIST_HEAD(list);
+	int i;
 
 	mod_page_state(pgfree, 1 << order);
+	for (i = 0 ; i < (1 << order) ; ++i)
+		free_pages_check(__FUNCTION__, page + i);
 	free_pages_check(__FUNCTION__, page);
 	list_add(&page->list, &list);
 	kernel_map_pages(page, 1<<order, 0);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
