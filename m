Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48BF16B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 20:28:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so75374051pfb.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 17:28:43 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id r26si2264453pfa.108.2016.06.15.17.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 17:28:42 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 01/13] x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()
Date: Wed, 15 Jun 2016 17:28:23 -0700
Message-Id: <f15dcba341945848b48ae74dbcf20228f2c940b0.1466036668.git.luto@kernel.org>
In-Reply-To: <cover.1466036668.git.luto@kernel.org>
References: <cover.1466036668.git.luto@kernel.org>
In-Reply-To: <cover.1466036668.git.luto@kernel.org>
References: <cover.1466036668.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, x86@kernel.org, Borislav Petkov <bp@alien8.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>, linux-mm@kvack.org

From: Ingo Molnar <mingo@kernel.org>

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
Message-Id: <1442903021-3893-4-git-send-email-mingo@kernel.org>
---
 arch/x86/mm/init_64.c | 27 ---------------------------
 1 file changed, 27 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bce2e5d9edd4..c7465453d64e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -702,27 +702,6 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
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
@@ -913,7 +892,6 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 	unsigned long addr;
 	pgd_t *pgd;
 	pud_t *pud;
-	bool pgd_changed = false;
 
 	for (addr = start; addr < end; addr = next) {
 		next = pgd_addr_end(addr, end);
@@ -924,13 +902,8 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
