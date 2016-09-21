Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF86828024B
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 00:35:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l91so76380475qte.3
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 21:35:28 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id q9si21147070qkh.237.2016.09.20.21.35.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 21:35:28 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 5/5] mm/vmalloc.c: avoid endless loop under v[un]mapping
 improper ranges
Message-ID: <57E20DCD.4000703@zoho.com>
Date: Wed, 21 Sep 2016 12:34:21 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

From: zijun_hu <zijun_hu@htc.com>

fix the following bug:
 - endless loop maybe happen when v[un]mapping improper ranges
   whose either boundary is not aligned to page

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/vmalloc.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5eeecc3..16fe957 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -67,7 +67,7 @@ static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
 	do {
 		pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
 		WARN_ON(!pte_none(ptent) && !pte_present(ptent));
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
 }
 
 static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
@@ -108,6 +108,9 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 	unsigned long next;
 
 	BUG_ON(addr >= end);
+	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
+
+	addr = round_down(addr, PAGE_SIZE);
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -139,7 +142,7 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 			return -ENOMEM;
 		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
 		(*nr)++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE, addr < end);
 	return 0;
 }
 
@@ -193,6 +196,8 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 	int nr = 0;
 
 	BUG_ON(addr >= end);
+	BUG_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
+
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
