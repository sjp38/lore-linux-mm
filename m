Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id A62FE6B0055
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:55:06 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id a13so123920igq.0
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:55:06 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id n6si2526439icc.3.2014.09.11.13.55.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 13:55:06 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id tp5so11250846ieb.37
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:55:06 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 07/10] zsmalloc: add obj_handle_is_free()
Date: Thu, 11 Sep 2014 16:53:58 -0400
Message-Id: <1410468841-320-8-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

Add function obj_handle_is_free() which scans through the entire
singly-linked list of free objects inside the provided zspage to
determine if the provided object handle is free or not.  This is
required by zspage reclaiming, which needs to evict each object
that is currently in use by the zs_pool owner, but has no other
way to determine if an object is in use.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 3dc7dae..ab72390 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -605,6 +605,33 @@ static unsigned long obj_idx_to_offset(struct page *page,
 	return off + obj_idx * class_size;
 }
 
+static bool obj_handle_is_free(struct page *first_page,
+			struct size_class *class, unsigned long handle)
+{
+	unsigned long obj, idx, offset;
+	struct page *page;
+	struct link_free *link;
+
+	BUG_ON(!is_first_page(first_page));
+
+	obj = (unsigned long)first_page->freelist;
+
+	while (obj) {
+		if (obj == handle)
+			return true;
+
+		obj_handle_to_location(obj, &page, &idx);
+		offset = obj_idx_to_offset(page, idx, class->size);
+
+		link = (struct link_free *)kmap_atomic(page) +
+					offset / sizeof(*link);
+		obj = (unsigned long)link->next;
+		kunmap_atomic(link);
+	}
+
+	return false;
+}
+
 static void obj_free(unsigned long obj, struct page *page, unsigned long offset)
 {
 	struct page *first_page = get_first_page(page);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
