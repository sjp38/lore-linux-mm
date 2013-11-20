Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 27F9C6B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 14:48:13 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id k4so2101732qaq.18
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 11:48:12 -0800 (PST)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id l8si363148qag.120.2013.11.20.11.48.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 11:48:12 -0800 (PST)
Received: by mail-qa0-f52.google.com with SMTP id k4so2104405qaq.4
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 11:48:11 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] mm/zswap: remove unneeded zswap_rb_erase calls
Date: Wed, 20 Nov 2013 14:47:04 -0500
Message-Id: <1384976824-32624-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Since zswap_rb_erase was added to the final (when refcount == 0)
zswap_put_entry, there is no need to call zswap_rb_erase before
calling zswap_put_entry.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index e154f1e..f4fbbd5 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -711,8 +711,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
 		if (ret == -EEXIST) {
 			zswap_duplicate_entry++;
-			/* remove from rbtree */
-			zswap_rb_erase(&tree->rbroot, dupentry);
 			zswap_entry_put(tree, dupentry);
 		}
 	} while (ret == -EEXIST);
@@ -787,9 +785,6 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 		return;
 	}
 
-	/* remove from rbtree */
-	zswap_rb_erase(&tree->rbroot, entry);
-
 	/* drop the initial reference from entry creation */
 	zswap_entry_put(tree, entry);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
