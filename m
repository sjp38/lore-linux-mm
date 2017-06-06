Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FFB76B02B4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 13:35:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d4so6098673qte.11
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 10:35:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b205si20408627qkg.149.2017.06.06.10.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 10:35:18 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove
Date: Tue,  6 Jun 2017 13:35:12 -0400
Message-Id: <20170606173512.7378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>

With commit af2cf278ef4f we no longer free pud so that we
do not have synchronize all pgd on hotremove/vfree. But the
new 5 level page table code re-added that code f2a6a705 and
thus we now trigger a BUG_ON() l128 in sync_global_pgds()

This patch remove free_pud() like in af2cf278ef4f

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
---
 arch/x86/mm/init_64.c | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a8a9972..8cf7e99 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -772,24 +772,6 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
 	spin_unlock(&init_mm.page_table_lock);
 }
 
-static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
-{
-	pud_t *pud;
-	int i;
-
-	for (i = 0; i < PTRS_PER_PUD; i++) {
-		pud = pud_start + i;
-		if (!pud_none(*pud))
-			return;
-	}
-
-	/* free a pud talbe */
-	free_pagetable(p4d_page(*p4d), 0);
-	spin_lock(&init_mm.page_table_lock);
-	p4d_clear(p4d);
-	spin_unlock(&init_mm.page_table_lock);
-}
-
 static void __meminit
 remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 		 bool direct)
@@ -991,7 +973,6 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 
 		pud_base = pud_offset(p4d, 0);
 		remove_pud_table(pud_base, addr, next, direct);
-		free_pud_table(pud_base, p4d);
 	}
 
 	if (direct)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
