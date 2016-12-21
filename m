Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA4A6B03DB
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 18:31:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b1so413633636pgc.5
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 15:31:04 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id r90si3373337pfk.118.2016.12.21.15.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 15:31:03 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id i5so8277337pgh.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 15:31:03 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V3 1/2] mm/memblock.c: trivial code refine in memblock_is_region_memory()
Date: Wed, 21 Dec 2016 23:30:32 +0000
Message-Id: <1482363033-24754-2-git-send-email-richard.weiyang@gmail.com>
In-Reply-To: <1482363033-24754-1-git-send-email-richard.weiyang@gmail.com>
References: <1482363033-24754-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

memblock_is_region_memory() invoke memblock_search() to see whether the
base address is in the memory region. If it fails, idx would be -1. Then,
it returns 0.

If the memblock_search() returns a valid index, it means the base address
is guaranteed to be in the range memblock.memory.regions[idx]. Because of
this, it is not necessary to check the base again.

This patch removes the check on "base".

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memblock.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 7608bc3..4929e06 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1615,8 +1615,7 @@ int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size
 
 	if (idx == -1)
 		return 0;
-	return memblock.memory.regions[idx].base <= base &&
-		(memblock.memory.regions[idx].base +
+	return (memblock.memory.regions[idx].base +
 		 memblock.memory.regions[idx].size) >= end;
 }
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
