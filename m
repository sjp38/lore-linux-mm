Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id B6C016B0256
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:11 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so8098229wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:11 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id m4si1766754wif.74.2015.09.21.23.24.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:10 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so144250964wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:10 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 03/11] x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()
Date: Tue, 22 Sep 2015 08:23:33 +0200
Message-Id: <1442903021-3893-4-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

So when memory hotplug removes a piece of physical memory from pagetable
mappings, it also frees the underlying PGD entry.

This complicates PGD management, so don't do this. We can keep the
PGD mapped and the PUD table all clear - it's only a single 4K page
per 512 GB of memory hotplugged.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Waiman Long <Waiman.Long@hp.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/init_64.c | 27 ---------------------------
 1 file changed, 27 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 7129e7647a76..60b0cc3f2819 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -780,27 +780,6 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
 	spin_unlock(&init_mm.page_table_lock);
 }
 
-/* Return true if pgd is changed, otherwise return false. */
-static bool __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd)
-{
-	pud_t *pud;
-	int i;
-
-	for (i = 0; i < PTRS_PER_PUD; i++) {
-		pud = pud_start + i;
-		if (pud_val(*pud))
-			return false;
-	}
-
-	/* free a pud table */
-	free_pagetable(pgd_page(*pgd), 0);
-	spin_lock(&init_mm.page_table_lock);
-	pgd_clear(pgd);
-	spin_unlock(&init_mm.page_table_lock);
-
-	return true;
-}
-
 static void __meminit
 remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 		 bool direct)
@@ -992,7 +971,6 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 	unsigned long addr;
 	pgd_t *pgd;
 	pud_t *pud;
-	bool pgd_changed = false;
 
 	for (addr = start; addr < end; addr = next) {
 		next = pgd_addr_end(addr, end);
@@ -1003,13 +981,8 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 
 		pud = (pud_t *)pgd_page_vaddr(*pgd);
 		remove_pud_table(pud, addr, next, direct);
-		if (free_pud_table(pud, pgd))
-			pgd_changed = true;
 	}
 
-	if (pgd_changed)
-		sync_global_pgds(start, end - 1, 1);
-
 	flush_tlb_all();
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
