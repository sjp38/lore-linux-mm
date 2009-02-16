Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C1BDB6B00A2
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:05:22 -0500 (EST)
Message-Id: <20090216144726.156785892@cmpxchg.org>
Date: Mon, 16 Feb 2009 15:29:34 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 8/8] atm: use kzfree()
References: <20090216142926.440561506@cmpxchg.org>
Content-Disposition: inline; filename=atm-use-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chas Williams <chas@cmf.nrl.navy.mil>
List-ID: <linux-mm.kvack.org>

Use kzfree() instead of memset() + kfree().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
---
 net/atm/mpoa_caches.c |   14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -167,11 +167,8 @@ static int cache_hit(in_cache_entry *ent
 
 static void in_cache_put(in_cache_entry *entry)
 {
-	if (atomic_dec_and_test(&entry->use)) {
-		memset(entry, 0, sizeof(in_cache_entry));
-		kfree(entry);
-	}
-
+	if (atomic_dec_and_test(&entry->use))
+		kzfree(entry);
 	return;
 }
 
@@ -403,11 +400,8 @@ static eg_cache_entry *eg_cache_get_by_s
 
 static void eg_cache_put(eg_cache_entry *entry)
 {
-	if (atomic_dec_and_test(&entry->use)) {
-		memset(entry, 0, sizeof(eg_cache_entry));
-		kfree(entry);
-	}
-
+	if (atomic_dec_and_test(&entry->use))
+		kzfree(entry);
 	return;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
