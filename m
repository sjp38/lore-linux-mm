Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2662803E9
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 14:04:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d15so3718365qta.11
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:04:15 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w12si419407ywa.193.2017.08.23.11.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 11:04:11 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 1/1] mm: Reversed logic in memblock_discard
Date: Wed, 23 Aug 2017 14:04:01 -0400
Message-Id: <1503511441-95478-2-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1503511441-95478-1-git-send-email-pasha.tatashin@oracle.com>
References: <1503511441-95478-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, terraluna977@gmail.com

In recently introduced memblock_discard() there is a reversed logic bug.
Memory is freed of static array instead of dynamically allocated one.

Fixes: 3010f876500f ("mm: discard memblock data later")

Reported-and-tested-by: Woody Suwalski <terraluna977@gmail.com>
Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index bf14aea6ab70..91205780e6b1 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -299,7 +299,7 @@ void __init memblock_discard(void)
 		__memblock_free_late(addr, size);
 	}
 
-	if (memblock.memory.regions == memblock_memory_init_regions) {
+	if (memblock.memory.regions != memblock_memory_init_regions) {
 		addr = __pa(memblock.memory.regions);
 		size = PAGE_ALIGN(sizeof(struct memblock_region) *
 				  memblock.memory.max);
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
