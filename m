Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 984036B0080
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 16:59:19 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id tp5so5415954ieb.37
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 13:59:19 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id bg2si4582icb.58.2014.09.15.13.59.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 13:59:19 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id tp5so5181911ieb.23
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 13:59:18 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zsmalloc: simplify init_zspage free obj linking
Date: Mon, 15 Sep 2014 16:58:50 -0400
Message-Id: <1410814730-5740-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <20140914232427.GD2160@bbox>
References: <20140914232427.GD2160@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

Change zsmalloc init_zspage() logic to iterate through each object on
each of its pages, checking the offset to verify the object is on the
current page before linking it into the zspage.

The current zsmalloc init_zspage free object linking code has logic
that relies on there only being one page per zspage when PAGE_SIZE
is a multiple of class->size.  It calculates the number of objects
for the current page, and iterates through all of them plus one,
to account for the assumed partial object at the end of the page.
While this currently works, the logic can be simplified to just
link the object at each successive offset until the offset is larger
than PAGE_SIZE, which does not rely on PAGE_SIZE being a multiple of
class->size.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c4a9157..03aa72f 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -628,7 +628,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 	while (page) {
 		struct page *next_page;
 		struct link_free *link;
-		unsigned int i, objs_on_page;
+		unsigned int i = 1;
 
 		/*
 		 * page->index stores offset of first object starting
@@ -641,14 +641,10 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 
 		link = (struct link_free *)kmap_atomic(page) +
 						off / sizeof(*link);
-		objs_on_page = (PAGE_SIZE - off) / class->size;
 
-		for (i = 1; i <= objs_on_page; i++) {
-			off += class->size;
-			if (off < PAGE_SIZE) {
-				link->next = obj_location_to_handle(page, i);
-				link += class->size / sizeof(*link);
-			}
+		while ((off += class->size) < PAGE_SIZE) {
+			link->next = obj_location_to_handle(page, i++);
+			link += class->size / sizeof(*link);
 		}
 
 		/*
@@ -660,7 +656,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		link->next = obj_location_to_handle(next_page, 0);
 		kunmap_atomic(link);
 		page = next_page;
-		off = (off + class->size) % PAGE_SIZE;
+		off %= PAGE_SIZE;
 	}
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
