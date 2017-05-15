Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1AE06B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 02:21:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u21so104085084pgn.5
        for <linux-mm@kvack.org>; Sun, 14 May 2017 23:21:06 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id d1si9909578pfa.100.2017.05.14.23.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 May 2017 23:21:05 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id f27so4238369pfe.0
        for <linux-mm@kvack.org>; Sun, 14 May 2017 23:21:05 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH] mm/kasan: use kasan_zero_pud for p4d table
Date: Mon, 15 May 2017 15:20:55 +0900
Message-Id: <1494829255-23946-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is missing optimization in zero_p4d_populate() that can save
some memory when mapping zero shadow. Implement it like as others.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/kasan_init.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index b96a5f7..554e4c0 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -118,6 +118,18 @@ static void __init zero_p4d_populate(pgd_t *pgd, unsigned long addr,
 
 	do {
 		next = p4d_addr_end(addr, end);
+		if (IS_ALIGNED(addr, P4D_SIZE) && end - addr >= P4D_SIZE) {
+			pud_t *pud;
+			pmd_t *pmd;
+
+			p4d_populate(&init_mm, p4d, lm_alias(kasan_zero_pud));
+			pud = pud_offset(p4d, addr);
+			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
+			pmd = pmd_offset(pud, addr);
+			pmd_populate_kernel(&init_mm, pmd,
+						lm_alias(kasan_zero_pte));
+			continue;
+		}
 
 		if (p4d_none(*p4d)) {
 			p4d_populate(&init_mm, p4d,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
