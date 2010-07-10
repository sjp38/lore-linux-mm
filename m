Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3C8B26B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 06:05:50 -0400 (EDT)
Received: by pvc30 with SMTP id 30so1379043pvc.14
        for <linux-mm@kvack.org>; Sat, 10 Jul 2010 03:05:47 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] slob_free:free objects to their own list
Date: Sat, 10 Jul 2010 18:05:33 +0800
Message-Id: <1278756333-6850-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mpm@selenic.com, hannes@cmpxchg.org, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

slob has alloced smaller objects from their own list in reduce
overall external fragmentation and increase repeatability,
free to their own list also.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/slob.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 3f19a34..d582171 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -396,6 +396,7 @@ static void slob_free(void *block, int size)
 	slob_t *prev, *next, *b = (slob_t *)block;
 	slobidx_t units;
 	unsigned long flags;
+	struct list_head *slob_list;
 
 	if (unlikely(ZERO_OR_NULL_PTR(block)))
 		return;
@@ -424,7 +425,13 @@ static void slob_free(void *block, int size)
 		set_slob(b, units,
 			(void *)((unsigned long)(b +
 					SLOB_UNITS(PAGE_SIZE)) & PAGE_MASK));
-		set_slob_page_free(sp, &free_slob_small);
+		if (size < SLOB_BREAK1)
+			slob_list = &free_slob_small;
+		else if (size < SLOB_BREAK2)
+			slob_list = &free_slob_medium;
+		else
+			slob_list = &free_slob_large;
+		set_slob_page_free(sp, slob_list);
 		goto out;
 	}
 
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
