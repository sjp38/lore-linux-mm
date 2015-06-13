Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4496B006C
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:34 -0400 (EDT)
Received: by wigg3 with SMTP id g3so34739791wig.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:33 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id y7si11628612wjr.77.2015.06.13.02.49.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:32 -0700 (PDT)
Received: by wigg3 with SMTP id g3so34739377wig.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:31 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 01/12] x86/mm/pat: Don't free PGD entries on memory unmap
Date: Sat, 13 Jun 2015 11:49:04 +0200
Message-Id: <1434188955-31397-2-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

So when we unmap kernel memory range then we also check whether a PUD
is completely clear, and free it and clear the PGD entry.

This complicates PGD management, so don't do this. We can keep the
PGD mapped and the PUD table all clear - it's only a single 4K page
per 512 GB of memory mapped.

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
 arch/x86/mm/pageattr.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 70d221fe2eb4..997fc97e9072 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -717,18 +717,6 @@ static bool try_to_free_pmd_page(pmd_t *pmd)
 	return true;
 }
 
-static bool try_to_free_pud_page(pud_t *pud)
-{
-	int i;
-
-	for (i = 0; i < PTRS_PER_PUD; i++)
-		if (!pud_none(pud[i]))
-			return false;
-
-	free_page((unsigned long)pud);
-	return true;
-}
-
 static bool unmap_pte_range(pmd_t *pmd, unsigned long start, unsigned long end)
 {
 	pte_t *pte = pte_offset_kernel(pmd, start);
@@ -847,9 +835,6 @@ static void unmap_pgd_range(pgd_t *root, unsigned long addr, unsigned long end)
 	pgd_t *pgd_entry = root + pgd_index(addr);
 
 	unmap_pud_range(pgd_entry, addr, end);
-
-	if (try_to_free_pud_page((pud_t *)pgd_page_vaddr(*pgd_entry)))
-		pgd_clear(pgd_entry);
 }
 
 static int alloc_pte_page(pmd_t *pmd)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
