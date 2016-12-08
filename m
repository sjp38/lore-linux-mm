Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DBB046B027C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:22:35 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so645667322pfg.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:22:35 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d2si29475052pli.315.2016.12.08.08.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:22:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 21/28] x86/mm: extend kasan to support 5-level paging
Date: Thu,  8 Dec 2016 19:21:43 +0300
Message-Id: <20161208162150.148763-23-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch bring support fo non-folded additional page table level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/kasan_init_64.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 2964de48e177..e37504e94e8f 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -50,8 +50,18 @@ static void __init kasan_map_early_shadow(pgd_t *pgd)
 	unsigned long end = KASAN_SHADOW_END;
 
 	for (i = pgd_index(start); start < end; i++) {
-		pgd[i] = __pgd(__pa_nodebug(kasan_zero_pud)
-				| _KERNPG_TABLE);
+		switch (CONFIG_PGTABLE_LEVELS) {
+		case 4:
+			pgd[i] = __pgd(__pa_nodebug(kasan_zero_pud) |
+					_KERNPG_TABLE);
+			break;
+		case 5:
+			pgd[i] = __pgd(__pa_nodebug(kasan_zero_p4d) |
+					_KERNPG_TABLE);
+			break;
+		default:
+			BUILD_BUG();
+		}
 		start += PGDIR_SIZE;
 	}
 }
@@ -79,6 +89,7 @@ void __init kasan_early_init(void)
 	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL;
 	pmdval_t pmd_val = __pa_nodebug(kasan_zero_pte) | _KERNPG_TABLE;
 	pudval_t pud_val = __pa_nodebug(kasan_zero_pmd) | _KERNPG_TABLE;
+	p4dval_t p4d_val = __pa_nodebug(kasan_zero_pud) | _KERNPG_TABLE;
 
 	for (i = 0; i < PTRS_PER_PTE; i++)
 		kasan_zero_pte[i] = __pte(pte_val);
@@ -89,6 +100,9 @@ void __init kasan_early_init(void)
 	for (i = 0; i < PTRS_PER_PUD; i++)
 		kasan_zero_pud[i] = __pud(pud_val);
 
+	for (i = 0; CONFIG_PGTABLE_LEVELS >= 5 && i < PTRS_PER_P4D; i++)
+		kasan_zero_p4d[i] = __p4d(p4d_val);
+
 	kasan_map_early_shadow(early_level4_pgt);
 	kasan_map_early_shadow(init_level4_pgt);
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
