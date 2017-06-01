Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 143F96B02C3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:22:23 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o65so50512633oif.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:22:23 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50099.outbound.protection.outlook.com. [40.107.5.99])
        by mx.google.com with ESMTPS id o13si4331210oto.26.2017.06.01.09.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 09:22:22 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 2/4] x86/kasan: don't allocate extra shadow memory
Date: Thu, 1 Jun 2017 19:23:36 +0300
Message-ID: <20170601162338.23540-2-aryabinin@virtuozzo.com>
In-Reply-To: <20170601162338.23540-1-aryabinin@virtuozzo.com>
References: <20170601162338.23540-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org

We used to read several bytes of the shadow memory in advance.
Therefore additional shadow memory mapped to prevent crash if
speculative load would happen near the end of the mapped shadow memory.

Now we don't have such speculative loads, so we no longer need to map
additional shadow memory.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
---
 arch/x86/mm/kasan_init_64.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 0c7d8129bed6..39231a9c981a 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -23,12 +23,7 @@ static int __init map_range(struct range *range)
 	start = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->start));
 	end = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->end));
 
-	/*
-	 * end + 1 here is intentional. We check several shadow bytes in advance
-	 * to slightly speed up fastpath. In some rare cases we could cross
-	 * boundary of mapped shadow, so we just map some more here.
-	 */
-	return vmemmap_populate(start, end + 1, NUMA_NO_NODE);
+	return vmemmap_populate(start, end, NUMA_NO_NODE);
 }
 
 static void __init clear_pgds(unsigned long start,
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
