Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE736B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:44:15 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g14so308491238ioj.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:44:15 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00137.outbound.protection.outlook.com. [40.107.0.137])
        by mx.google.com with ESMTPS id j93si475230otj.261.2016.08.01.07.44.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 07:44:13 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 3/6] mm/kasan, slub: don't disable interrupts when object leaves quarantine
Date: Mon, 1 Aug 2016 17:45:12 +0300
Message-ID: <1470062715-14077-3-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

SLUB doesn't require disabled interrupts to call ___cache_free().

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/quarantine.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 65793f1..4852625 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -147,10 +147,14 @@ static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 	unsigned long flags;
 
-	local_irq_save(flags);
+	if (IS_ENABLED(CONFIG_SLAB))
+		local_irq_save(flags);
+
 	alloc_info->state = KASAN_STATE_FREE;
 	___cache_free(cache, object, _THIS_IP_);
-	local_irq_restore(flags);
+
+	if (IS_ENABLED(CONFIG_SLAB))
+		local_irq_restore(flags);
 }
 
 static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cache)
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
