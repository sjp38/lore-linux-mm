Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA6736B04AE
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 20:31:29 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 127-v6so12955139pgb.7
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 17:31:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17-v6sor46688154pls.11.2018.11.06.17.31.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 17:31:28 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/slub: record final state of slub action in deactivate_slab()
Date: Wed,  7 Nov 2018 09:31:19 +0800
Message-Id: <20181107013119.3816-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

In case __cmpxchg_double_slab() fails and (l != m), current code records
transition states of slub action.

This patch update slub action after __cmpxchg_double_slab() succeed to
record the final state.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 44dd1d6cfbc3..cbb1aade7858 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2136,24 +2136,14 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 	if (l != m) {
 
 		if (l == M_PARTIAL)
-
 			remove_partial(n, page);
-
 		else if (l == M_FULL)
-
 			remove_full(s, n, page);
 
-		if (m == M_PARTIAL) {
-
+		if (m == M_PARTIAL)
 			add_partial(n, page, tail);
-			stat(s, tail);
-
-		} else if (m == M_FULL) {
-
-			stat(s, DEACTIVATE_FULL);
+		else if (m == M_FULL)
 			add_full(s, n, page);
-
-		}
 	}
 
 	l = m;
@@ -2166,7 +2156,11 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 	if (lock)
 		spin_unlock(&n->list_lock);
 
-	if (m == M_FREE) {
+	if (m == M_PARTIAL)
+		stat(s, tail);
+	else if (m == M_FULL)
+		stat(s, DEACTIVATE_FULL);
+	else if (m == M_FREE) {
 		stat(s, DEACTIVATE_EMPTY);
 		discard_slab(s, page);
 		stat(s, FREE_SLAB);
-- 
2.15.1
