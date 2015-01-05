Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4E28E6B0073
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 20:37:50 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so27132168pdj.20
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 17:37:50 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id tu9si80913636pbc.157.2015.01.04.17.37.44
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 17:37:46 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 5/6] mm/slab: cleanup ____cache_alloc()
Date: Mon,  5 Jan 2015 10:37:30 +0900
Message-Id: <1420421851-3281-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

This cleanup makes code more readable and help future changes.
In the following patch, many code will be added to this function.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 1246ac6..449fc6b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2939,21 +2939,23 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 	local_irq_save(save_flags);
 
 	ac = cpu_cache_get(cachep);
-	if (likely(ac->avail)) {
-		ac->touched = 1;
-		objp = ac_get_obj(cachep, ac, flags, false);
+	if (unlikely(!ac->avail))
+		goto slowpath;
 
-		/*
-		 * Allow for the possibility all avail objects are not allowed
-		 * by the current flags
-		 */
-		if (objp) {
-			STATS_INC_ALLOCHIT(cachep);
-			goto out;
-		}
-		force_refill = true;
+	ac->touched = 1;
+	objp = ac_get_obj(cachep, ac, flags, false);
+
+	/*
+	 * Allow for the possibility all avail objects are not allowed
+	 * by the current flags
+	 */
+	if (likely(objp)) {
+		STATS_INC_ALLOCHIT(cachep);
+		goto out;
 	}
+	force_refill = true;
 
+slowpath:
 	STATS_INC_ALLOCMISS(cachep);
 	objp = cache_alloc_refill(cachep, flags, force_refill);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
