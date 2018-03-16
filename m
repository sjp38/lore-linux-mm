Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 835CC6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 22:56:50 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m6-v6so4247615pln.8
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 19:56:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14sor1412985pgc.328.2018.03.15.19.56.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 19:56:49 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH] Revert "mm/memblock.c: hardcode the end_pfn being -1"
Date: Thu, 15 Mar 2018 19:56:06 -0700
Message-Id: <1521168966-5245-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

This reverts commit 379b03b7fa05f7db521b7732a52692448a3c34fe.

Commit 864b75f9d6b0 ("mm/page_alloc: fix memmap_init_zone pageblock
alignment") introduced boot hang issues in arm/arm64 machines, so
Ard Biesheuvel reverted in commit 3e04040df6d4. But there is a
preparation patch for commit 864b75f9d6b0. So just revert it for
the sake of caution.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 mm/memblock.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index b6ba6b7..5a9ca2a 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1107,7 +1107,7 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 	struct memblock_type *type = &memblock.memory;
 	unsigned int right = type->cnt;
 	unsigned int mid, left = 0;
-	phys_addr_t addr = PFN_PHYS(++pfn);
+	phys_addr_t addr = PFN_PHYS(pfn + 1);
 
 	do {
 		mid = (right + left) / 2;
@@ -1118,15 +1118,15 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 				  type->regions[mid].size))
 			left = mid + 1;
 		else {
-			/* addr is within the region, so pfn is valid */
-			return pfn;
+			/* addr is within the region, so pfn + 1 is valid */
+			return min(pfn + 1, max_pfn);
 		}
 	} while (left < right);
 
 	if (right == type->cnt)
-		return -1UL;
+		return max_pfn;
 	else
-		return PHYS_PFN(type->regions[right].base);
+		return min(PHYS_PFN(type->regions[right].base), max_pfn);
 }
 
 /**
-- 
2.7.4
