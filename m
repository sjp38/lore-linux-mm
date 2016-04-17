Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7445E6B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 15:14:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a140so53318627wma.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 12:14:45 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id q7si2600549lfd.191.2016.04.17.12.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 12:14:44 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id g184so195294991lfb.3
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 12:14:44 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: move memblock_{add,reserve}_region into memblock_{add,reserve}
Date: Mon, 18 Apr 2016 01:14:36 +0600
Message-Id: <1460920476-14320-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Gibson <david@gibson.dropbear.id.au>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0xAX <kuleshovmail@gmail.com>

From: 0xAX <kuleshovmail@gmail.com>

The memblock_add_region() and memblock_reserve_region do not nothing specific
before the call of the memblock_add_range(), only print debug output.

We can do the same in the memblock_add() and memblock_reserve() since both
memblock_add_region() and memblock_reserve_region are not used by anybody
outside of memblock.c and the memblock_{add,reserve}() have the same set of
flags and nids.

Since the memblock_add_region() and memblock_reserve_region() anyway will be
inlined, there will not be functional changes, but will improve code readability
a little.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index b570ddd..3b93daa 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -606,22 +606,14 @@ int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
 	return memblock_add_range(&memblock.memory, base, size, nid, 0);
 }
 
-static int __init_memblock memblock_add_region(phys_addr_t base,
-						phys_addr_t size,
-						int nid,
-						unsigned long flags)
+int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
 	memblock_dbg("memblock_add: [%#016llx-%#016llx] flags %#02lx %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size - 1,
-		     flags, (void *)_RET_IP_);
-
-	return memblock_add_range(&memblock.memory, base, size, nid, flags);
-}
+		     0UL, (void *)_RET_IP_);
 
-int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
-{
-	return memblock_add_region(base, size, MAX_NUMNODES, 0);
+	return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
 }
 
 /**
@@ -732,22 +724,14 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 	return memblock_remove_range(&memblock.reserved, base, size);
 }
 
-static int __init_memblock memblock_reserve_region(phys_addr_t base,
-						   phys_addr_t size,
-						   int nid,
-						   unsigned long flags)
+int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
 	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] flags %#02lx %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size - 1,
-		     flags, (void *)_RET_IP_);
-
-	return memblock_add_range(&memblock.reserved, base, size, nid, flags);
-}
+		     0UL, (void *)_RET_IP_);
 
-int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
-{
-	return memblock_reserve_region(base, size, MAX_NUMNODES, 0);
+	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, 0);
 }
 
 /**
-- 
2.8.0.rc3.212.g1f992f2.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
