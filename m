Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEE56B0255
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:08 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so176868926wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:07 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id gi4si7579wjc.108.2015.09.21.23.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:07 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so176166388wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:06 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 01/11] x86/mm/pat: Don't free PGD entries on memory unmap
Date: Tue, 22 Sep 2015 08:23:31 +0200
Message-Id: <1442903021-3893-2-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

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
index 2c44c0792301..b784ed7c9a7e 100644
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
