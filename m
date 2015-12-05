Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 41CC46B0258
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 02:26:29 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so32345526lbb.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 23:26:28 -0800 (PST)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id h185si10488476lfe.134.2015.12.04.23.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 23:26:27 -0800 (PST)
Received: by lbbed20 with SMTP id ed20so17737049lbb.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 23:26:27 -0800 (PST)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: use memblock_insert_region() for the empty array
Date: Sat,  5 Dec 2015 13:23:40 +0600
Message-Id: <1449300220-30108-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

We have the special case for an empty array in the memblock_add_range()
function. In the same time we have almost the same functional in the
memblock_insert_region() function. Let's use the memblock_insert_region()
instead of direct initialization.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index d300f13..e8a897d 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -496,12 +496,16 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
 	struct memblock_region *rgn = &type->regions[idx];

 	BUG_ON(type->cnt >= type->max);
-	memmove(rgn + 1, rgn, (type->cnt - idx) * sizeof(*rgn));
+	/* special case for empty array */
+	if (idx)
+	{
+		memmove(rgn + 1, rgn, (type->cnt - idx) * sizeof(*rgn));
+		type->cnt++;
+	}
 	rgn->base = base;
 	rgn->size = size;
 	rgn->flags = flags;
 	memblock_set_region_node(rgn, nid);
-	type->cnt++;
 	type->total_size += size;
 }

@@ -536,11 +540,7 @@ int __init_memblock memblock_add_range(struct memblock_type *type,
 	/* special case for empty array */
 	if (type->regions[0].size == 0) {
 		WARN_ON(type->cnt != 1 || type->total_size);
-		type->regions[0].base = base;
-		type->regions[0].size = size;
-		type->regions[0].flags = flags;
-		memblock_set_region_node(&type->regions[0], nid);
-		type->total_size = size;
+		memblock_insert_region(type, 0, base, size, nid, flags);
 		return 0;
 	}
 repeat:
--
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
