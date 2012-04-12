Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 27C866B0092
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 13:00:42 -0400 (EDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH] Revert "proc: clear_refs: do not clear reserved pages"
Date: Thu, 12 Apr 2012 18:00:34 +0100
Message-Id: <1334250034-29866-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nico@linaro.org>

This reverts commit 85e72aa5384b1a614563ad63257ded0e91d1a620, which was
a quick fix suitable for -stable until ARM had been moved over to the
gate_vma mechanism:

https://lkml.org/lkml/2012/1/14/55

With commit f9d4861f ("ARM: 7294/1: vectors: use gate_vma for vectors user
mapping"), ARM does now use the gate_vma, so the PageReserved check can
be removed from the proc code.

Cc: Nicolas Pitre <nico@linaro.org>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 fs/proc/task_mmu.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2b9a760..2d60492 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -597,9 +597,6 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 		if (!page)
 			continue;
 
-		if (PageReserved(page))
-			continue;
-
 		/* Clear accessed and referenced bits. */
 		ptep_test_and_clear_young(vma, addr, pte);
 		ClearPageReferenced(page);
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
