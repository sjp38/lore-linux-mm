Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA0C6B0038
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 13:19:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 127so448964555pfg.5
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:19:19 -0800 (PST)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id e186si69748735pgc.45.2017.01.03.10.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 10:19:18 -0800 (PST)
Received: by mail-pg0-x22f.google.com with SMTP id i5so152456416pgh.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:19:18 -0800 (PST)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH] Fix SLAB freelist randomization duplicate entries
Date: Tue,  3 Jan 2017 10:19:08 -0800
Message-Id: <20170103181908.143178-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jsperbeck@google.com, Thomas Garnier <thgarnie@google.com>

This patch fixes a bug in the freelist randomization code. When a high
random number is used, the freelist will contain duplicate entries. It
will result in different allocations sharing the same chunk.

Fixes: c7ce4f60ac19 ("mm: SLAB freelist randomization")
Signed-off-by: John Sperbeck <jsperbeck@google.com>
Reviewed-by: Thomas Garnier <thgarnie@google.com>
---
 mm/slab.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 29bc6c0dedd0..4f2ec6bb46eb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2457,7 +2457,6 @@ union freelist_init_state {
 		unsigned int pos;
 		unsigned int *list;
 		unsigned int count;
-		unsigned int rand;
 	};
 	struct rnd_state rnd_state;
 };
@@ -2483,8 +2482,7 @@ static bool freelist_state_initialize(union freelist_init_state *state,
 	} else {
 		state->list = cachep->random_seq;
 		state->count = count;
-		state->pos = 0;
-		state->rand = rand;
+		state->pos = rand % count;
 		ret = true;
 	}
 	return ret;
@@ -2493,7 +2491,9 @@ static bool freelist_state_initialize(union freelist_init_state *state,
 /* Get the next entry on the list and randomize it using a random shift */
 static freelist_idx_t next_random_slot(union freelist_init_state *state)
 {
-	return (state->list[state->pos++] + state->rand) % state->count;
+	if (state->pos >= state->count)
+		state->pos = 0;
+	return state->list[state->pos++];
 }
 
 /* Swap two freelist entries */
-- 
2.11.0.390.gc69c2f50cf-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
