Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 017F26B0253
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 08:01:44 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so86341823pfg.4
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 05:01:43 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 1si40259664pgy.294.2016.12.11.05.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 05:01:43 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id e9so7829620pgc.1
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 05:01:43 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/2] mm/memblock.c: trivial code refine in memblock_is_region_memory()
Date: Sun, 11 Dec 2016 12:59:49 +0000
Message-Id: <1481461190-11780-2-git-send-email-richard.weiyang@gmail.com>
In-Reply-To: <1481461190-11780-1-git-send-email-richard.weiyang@gmail.com>
References: <1481461190-11780-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

The base address is already guaranteed to be in the region by
memblock_search().

This patch removes the check on base, also a little refine in a macro.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/memblock.h |    5 ++---
 mm/memblock.c            |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 3106ac1..e611819 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -408,9 +408,8 @@ static inline unsigned long memblock_region_reserved_end_pfn(const struct memblo
 	     region++)
 
 #define for_each_memblock_type(memblock_type, rgn)			\
-	idx = 0;							\
-	rgn = &memblock_type->regions[idx];				\
-	for (idx = 0; idx < memblock_type->cnt;				\
+	for (idx = 0, rgn = &memblock_type->regions[idx];		\
+	     idx < memblock_type->cnt;					\
 	     idx++,rgn = &memblock_type->regions[idx])
 
 #ifdef CONFIG_MEMTEST
diff --git a/mm/memblock.c b/mm/memblock.c
index ac12489..9d402d05 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1557,7 +1557,7 @@ int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size
 
 	if (idx == -1)
 		return 0;
-	return memblock.memory.regions[idx].base <= base &&
+	return /* memblock.memory.regions[idx].base <= base && */
 		(memblock.memory.regions[idx].base +
 		 memblock.memory.regions[idx].size) >= end;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
