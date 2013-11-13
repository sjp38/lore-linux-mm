Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 62E696B00A8
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 00:04:42 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id w10so7945653pde.31
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 21:04:42 -0800 (PST)
Received: from psmtp.com ([74.125.245.174])
        by mx.google.com with SMTP id rz8si1330142pab.329.2013.11.12.21.04.39
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 21:04:40 -0800 (PST)
Message-ID: <528308E8.8040203@asianux.com>
Date: Wed, 13 Nov 2013 13:06:48 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] arch: um: kernel: skas: mmu: remove pmd_free() and pud_free()
 for failure processing in init_stub_pte()
References: <alpine.LNX.2.00.1310150330350.9078@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1310150330350.9078@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, uml-devel <user-mode-linux-devel@lists.sourceforge.net>, uml-user <user-mode-linux-user@lists.sourceforge.net>

Unfortunately, p?d_alloc() and p?d_free() are not pair!! If p?d_alloc()
succeed, they may be used, so in the next failure, we have to skip them
to let exit_mmap() or do_munmap() to process it.

According to "Documentation/vm/locking", 'mm->page_table_lock' is for
using vma list, so not need it when its related vmas are detached or
unmapped from using vma list.

The related work flow:

  exit_mmap() ->
    unmap_vmas(); /* so not need mm->page_table_lock */
    free_pgtables();

  do_munmap()->
    detach_vmas_to_be_unmapped(); /* so not need mm->page_table_lock */
    unmap_region() ->
      free_pgtables();

  free_pgtables() ->
    free_pgd_range() ->
      free_pud_range() ->
        free_pmd_range() ->
          free_pte_range() ->
            pmd_clear();
            pte_free_tlb();
          pud_clear();
          pmd_free_tlb();
        pgd_clear(); 
        pud_free_tlb();


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 arch/um/kernel/skas/mmu.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/um/kernel/skas/mmu.c b/arch/um/kernel/skas/mmu.c
index 007d550..3fd1951 100644
--- a/arch/um/kernel/skas/mmu.c
+++ b/arch/um/kernel/skas/mmu.c
@@ -40,9 +40,9 @@ static int init_stub_pte(struct mm_struct *mm, unsigned long proc,
 	return 0;
 
  out_pte:
-	pmd_free(mm, pmd);
+	/* used by mm->pgd->pud, will free in do_munmap() or exit_mmap() */
  out_pmd:
-	pud_free(mm, pud);
+	/* used by mm->pgd, will free in do_munmap() or exit_mmap() */
  out:
 	return -ENOMEM;
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
