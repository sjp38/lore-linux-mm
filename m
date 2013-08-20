Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A09DB6B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 23:28:46 -0400 (EDT)
Message-ID: <5212E230.1060504@asianux.com>
Date: Tue, 20 Aug 2013 11:27:44 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/mremap.c: call pud_free() after fail calling pmd_alloc()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>, riel@redhat.com, Ingo Molnar <mingo@kernel.org>, linux@rasmusvillemoes.dk
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

In alloc_new_pmd(), if pud_alloc() was called successfully, but
pmd_alloc() is called by fail, in this case, need call pud_free()
before return.

Also need include "asm/pgalloc.h" which have the declaration of
pud_free(), or can not pass compiling.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/mremap.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 457d34e..f37f8a0 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -24,6 +24,7 @@
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
+#include <asm/pgalloc.h>
 
 #include "internal.h"
 
@@ -61,8 +62,10 @@ static pmd_t *alloc_new_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 		return NULL;
 
 	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
+	if (!pmd) {
+		pud_free(mm, pud);
 		return NULL;
+	}
 
 	VM_BUG_ON(pmd_trans_huge(*pmd));
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
