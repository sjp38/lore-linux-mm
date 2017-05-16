Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F38836B02F2
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:17:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u21so124277847pgn.5
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:46 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id s10si12119046pfj.224.2017.05.15.18.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:17:46 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id u26so17848223pfd.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:46 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 03/11] mm/kasan: handle unaligned end address in zero_pte_populate
Date: Tue, 16 May 2017 10:16:41 +0900
Message-Id: <1494897409-14408-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

It doesn't handle unaligned end address so last pte could not
be initialized. Fix it.

Note that this shadow memory can be used by others so map
the actual page in this case.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/kasan_init.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 554e4c0..48559d9 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -61,6 +61,14 @@ static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
 		addr += PAGE_SIZE;
 		pte = pte_offset_kernel(pmd, addr);
 	}
+
+	if (addr == end)
+		return;
+
+	/* Population for unaligned end address */
+	zero_pte = pfn_pte(PFN_DOWN(
+		__pa(early_alloc(PAGE_SIZE, NUMA_NO_NODE))), PAGE_KERNEL);
+	set_pte_at(&init_mm, addr, pte, zero_pte);
 }
 
 static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
