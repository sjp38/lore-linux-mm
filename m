Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B803F6B025B
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:21 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so176874933wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:21 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id p10si1789176wiv.26.2015.09.21.23.24.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:20 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so176172239wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:20 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 09/11] x86/mm: Make pgd_alloc()/pgd_free() lockless
Date: Tue, 22 Sep 2015 08:23:39 +0200
Message-Id: <1442903021-3893-10-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

The fork()/exit() code uses pgd_alloc()/pgd_free() to allocate/deallocate
the PGD, with platform specific code setting up kernel pagetables.

The x86 code uses a global pgd_list with an associated lock to update
all PGDs of all tasks in the system synchronously.

The lock is still kept to synchronize updates to all PGDs in the system,
but all users of the list have been migrated to use the task list.

So we can remove the pgd_list addition/removal from this code.

The new PGD is private while constructed, so it needs no extra
locking.

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
 arch/x86/mm/pgtable.c | 27 +++------------------------
 1 file changed, 3 insertions(+), 24 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index c7038b6e51bf..8a42d54f44ba 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -125,22 +125,6 @@ static void pgd_ctor(struct mm_struct *mm, pgd_t *pgd)
 				swapper_pg_dir + KERNEL_PGD_BOUNDARY,
 				KERNEL_PGD_PTRS);
 	}
-
-	/* list required to sync kernel mapping updates */
-	if (!SHARED_KERNEL_PMD) {
-		pgd_set_mm(pgd, mm);
-		pgd_list_add(pgd);
-	}
-}
-
-static void pgd_dtor(pgd_t *pgd)
-{
-	if (SHARED_KERNEL_PMD)
-		return;
-
-	spin_lock(&pgd_lock);
-	pgd_list_del(pgd);
-	spin_unlock(&pgd_lock);
 }
 
 /*
@@ -370,17 +354,13 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 		goto out_free_pmds;
 
 	/*
-	 * Make sure that pre-populating the pmds is atomic with
-	 * respect to anything walking the pgd_list, so that they
-	 * never see a partially populated pgd.
+	 * No locking is needed here, as the PGD is still private,
+	 * so no code walking the task list and looking at mm->pgd
+	 * will be able to see it before it's fully constructed:
 	 */
-	spin_lock(&pgd_lock);
-
 	pgd_ctor(mm, pgd);
 	pgd_prepopulate_pmd(mm, pgd, pmds);
 
-	spin_unlock(&pgd_lock);
-
 	return pgd;
 
 out_free_pmds:
@@ -453,7 +433,6 @@ void arch_pgd_init_late(struct mm_struct *mm)
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	pgd_mop_up_pmds(mm, pgd);
-	pgd_dtor(pgd);
 	paravirt_pgd_free(mm, pgd);
 	_pgd_free(pgd);
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
