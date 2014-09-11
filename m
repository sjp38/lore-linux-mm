Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id A06BF6B0037
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:54:47 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so1037146igd.14
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:47 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id pz4si2457602icb.95.2014.09.11.13.54.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 13:54:46 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id a13so144477igq.2
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:46 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 01/10] zsmalloc: fix init_zspage free obj linking
Date: Thu, 11 Sep 2014 16:53:52 -0400
Message-Id: <1410468841-320-2-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

When zsmalloc creates a new zspage, it initializes each object it contains
with a link to the next object, so that the zspage has a singly-linked list
of its free objects.  However, the logic that sets up the links is wrong,
and in the case of objects that are precisely aligned with the page boundries
(e.g. a zspage with objects that are 1/2 PAGE_SIZE) the first object on the
next page is skipped, due to incrementing the offset twice.  The logic can be
simplified, as it doesn't need to calculate how many objects can fit on the
current page; simply checking the offset for each object is enough.

Change zsmalloc init_zspage() logic to iterate through each object on
each of its pages, checking the offset to verify the object is on the
current page before linking it into the zspage.

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
