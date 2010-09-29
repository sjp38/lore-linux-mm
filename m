Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 081086B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 08:02:25 -0400 (EDT)
Received: by pwj6 with SMTP id 6so204729pwj.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 05:02:24 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 1/3] slub: Fix signedness warnings
Date: Wed, 29 Sep 2010 21:02:13 +0900
Message-Id: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The bit-ops routines require its arg to be a pointer to unsigned long.
This leads sparse to complain about different signedness as follows:

 mm/slub.c:2425:49: warning: incorrect type in argument 2 (different signedness)
 mm/slub.c:2425:49:    expected unsigned long volatile *addr
 mm/slub.c:2425:49:    got long *map

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/slub.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 13fffe1..e137688 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2414,9 +2414,8 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 #ifdef CONFIG_SLUB_DEBUG
 	void *addr = page_address(page);
 	void *p;
-	long *map = kzalloc(BITS_TO_LONGS(page->objects) * sizeof(long),
-			    GFP_ATOMIC);
-
+	unsigned long *map = kzalloc(BITS_TO_LONGS(page->objects) *
+				     sizeof(long), GFP_ATOMIC);
 	if (!map)
 		return;
 	slab_err(s, page, "%s", text);
@@ -3635,7 +3634,7 @@ static int add_location(struct loc_track *t, struct kmem_cache *s,
 
 static void process_slab(struct loc_track *t, struct kmem_cache *s,
 		struct page *page, enum track_item alloc,
-		long *map)
+		unsigned long *map)
 {
 	void *addr = page_address(page);
 	void *p;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
