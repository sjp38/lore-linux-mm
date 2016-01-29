Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id D57AB6B0255
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 12:58:07 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l66so64990276wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:58:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lg10si23553338wjc.20.2016.01.29.09.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 09:58:06 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH v2 2/5] mm: workingset: #define radix entry eviction mask
Date: Fri, 29 Jan 2016 12:54:04 -0500
Message-Id: <1454090047-1790-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1454090047-1790-1-git-send-email-hannes@cmpxchg.org>
References: <1454090047-1790-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This is a compile-time constant, no need to calculate it on refault.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/workingset.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 61ead9e..3ef92f6 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -152,6 +152,10 @@
  * refault distance will immediately activate the refaulting page.
  */
 
+#define EVICTION_SHIFT	(RADIX_TREE_EXCEPTIONAL_ENTRY + \
+			 ZONES_SHIFT + NODES_SHIFT)
+#define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
+
 static void *pack_shadow(unsigned long eviction, struct zone *zone)
 {
 	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
@@ -168,7 +172,6 @@ static void unpack_shadow(void *shadow,
 	unsigned long entry = (unsigned long)shadow;
 	unsigned long eviction;
 	unsigned long refault;
-	unsigned long mask;
 	int zid, nid;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
@@ -181,8 +184,7 @@ static void unpack_shadow(void *shadow,
 	*zone = NODE_DATA(nid)->node_zones + zid;
 
 	refault = atomic_long_read(&(*zone)->inactive_age);
-	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
-			RADIX_TREE_EXCEPTIONAL_SHIFT);
+
 	/*
 	 * The unsigned subtraction here gives an accurate distance
 	 * across inactive_age overflows in most cases.
@@ -199,7 +201,7 @@ static void unpack_shadow(void *shadow,
 	 * inappropriate activation leading to pressure on the active
 	 * list is not a problem.
 	 */
-	*distance = (refault - eviction) & mask;
+	*distance = (refault - eviction) & EVICTION_MASK;
 }
 
 /**
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
