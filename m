Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCE76B02F3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:22:23 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c71so51390936oig.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:22:23 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50099.outbound.protection.outlook.com. [40.107.5.99])
        by mx.google.com with ESMTPS id o13si4331210oto.26.2017.06.01.09.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 09:22:22 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 3/4] arm64/kasan: don't allocate extra shadow memory
Date: Thu, 1 Jun 2017 19:23:37 +0300
Message-ID: <20170601162338.23540-3-aryabinin@virtuozzo.com>
In-Reply-To: <20170601162338.23540-1-aryabinin@virtuozzo.com>
References: <20170601162338.23540-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

We used to read several bytes of the shadow memory in advance.
Therefore additional shadow memory mapped to prevent crash if
speculative load would happen near the end of the mapped shadow memory.

Now we don't have such speculative loads, so we no longer need to map
additional shadow memory.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org
---
 arch/arm64/mm/kasan_init.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 687a358a3733..81f03959a4ab 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -191,14 +191,8 @@ void __init kasan_init(void)
 		if (start >= end)
 			break;
 
-		/*
-		 * end + 1 here is intentional. We check several shadow bytes in
-		 * advance to slightly speed up fastpath. In some rare cases
-		 * we could cross boundary of mapped shadow, so we just map
-		 * some more here.
-		 */
 		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
-				(unsigned long)kasan_mem_to_shadow(end) + 1,
+				(unsigned long)kasan_mem_to_shadow(end),
 				pfn_to_nid(virt_to_pfn(start)));
 	}
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
