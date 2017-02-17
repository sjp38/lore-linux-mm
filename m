Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD1B24405D8
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:14:05 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so61484699pgc.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:14:05 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q18si10402025pge.19.2017.02.17.06.14.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 06:14:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 26/33] x86/kasan: extend to support 5-level paging
Date: Fri, 17 Feb 2017 17:13:21 +0300
Message-Id: <20170217141328.164563-27-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>

This patch bring support for non-folded additional page table level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com
---
 arch/x86/mm/kasan_init_64.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 72ffe4c55c2d..11ec306f7913 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -49,8 +49,18 @@ static void __init kasan_map_early_shadow(pgd_t *pgd)
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
@@ -78,6 +88,7 @@ void __init kasan_early_init(void)
 	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL;
 	pmdval_t pmd_val = __pa_nodebug(kasan_zero_pte) | _KERNPG_TABLE;
 	pudval_t pud_val = __pa_nodebug(kasan_zero_pmd) | _KERNPG_TABLE;
+	p4dval_t p4d_val = __pa_nodebug(kasan_zero_pud) | _KERNPG_TABLE;
 
 	for (i = 0; i < PTRS_PER_PTE; i++)
 		kasan_zero_pte[i] = __pte(pte_val);
@@ -88,6 +99,9 @@ void __init kasan_early_init(void)
 	for (i = 0; i < PTRS_PER_PUD; i++)
 		kasan_zero_pud[i] = __pud(pud_val);
 
+	for (i = 0; CONFIG_PGTABLE_LEVELS >= 5 && i < PTRS_PER_P4D; i++)
+		kasan_zero_p4d[i] = __p4d(p4d_val);
+
 	kasan_map_early_shadow(early_level4_pgt);
 	kasan_map_early_shadow(init_level4_pgt);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
