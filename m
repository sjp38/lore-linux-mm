Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 50CBE6B025C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 14:30:41 -0500 (EST)
Received: by lffu14 with SMTP id u14so118753677lff.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 11:30:40 -0800 (PST)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com. [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id eq17si9352273lbc.115.2015.12.04.11.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 11:30:40 -0800 (PST)
Received: by lbbkw15 with SMTP id kw15so26347943lbb.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 11:30:39 -0800 (PST)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: remove rgnbase and rgnsize variables
Date: Sat,  5 Dec 2015 01:28:06 +0600
Message-Id: <1449257286-28089-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

This patch removes rgnbase and rgnsize variables from the
memblock_overlaps_region() function. We use these variables
only for passing to the memblock_addrs_overlap() function and
that's all. Let's remove them.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index d300f13..9a45e21 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -96,13 +96,10 @@ bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
 {
 	unsigned long i;
 
-	for (i = 0; i < type->cnt; i++) {
-		phys_addr_t rgnbase = type->regions[i].base;
-		phys_addr_t rgnsize = type->regions[i].size;
-		if (memblock_addrs_overlap(base, size, rgnbase, rgnsize))
+	for (i = 0; i < type->cnt; i++)
+		if (memblock_addrs_overlap(base, size, type->regions[i].base,
+					   type->regions[i].size))
 			break;
-	}
-
 	return i < type->cnt;
 }
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
