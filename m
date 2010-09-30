Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A181B6B007D
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:43 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:42 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 05/12] mm: wrap follow_pte() using __cond_lock()
Date: Thu, 30 Sep 2010 12:50:14 +0900
Message-Id: <1285818621-29890-6-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The follow_pte() conditionally grabs *@ptlp in case of returning 0.
Rename and wrap it using __cond_lock() removes following warnings:

 mm/memory.c:2337:9: warning: context imbalance in 'do_wp_page' - unexpected unlock
 mm/memory.c:3142:19: warning: context imbalance in 'handle_mm_fault' - different lock contexts for basic block

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/memory.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 76fa60e..6892fe8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3344,7 +3344,7 @@ int in_gate_area_no_task(unsigned long addr)
 
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
-static int follow_pte(struct mm_struct *mm, unsigned long address,
+static int __follow_pte(struct mm_struct *mm, unsigned long address,
 		pte_t **ptepp, spinlock_t **ptlp)
 {
 	pgd_t *pgd;
@@ -3381,6 +3381,17 @@ out:
 	return -EINVAL;
 }
 
+static inline int follow_pte(struct mm_struct *mm, unsigned long address,
+			     pte_t **ptepp, spinlock_t **ptlp)
+{
+	int res;
+
+	/* (void) is needed to make gcc happy */
+	(void) __cond_lock(*ptlp,
+			   !(res = __follow_pte(mm, address, ptepp, ptlp)));
+	return res;
+}
+
 /**
  * follow_pfn - look up PFN at a user virtual address
  * @vma: memory mapping
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
