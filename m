From: Dave Hansen <haveblue@us.ibm.com>
Subject: [patch] remove weird pmd cast
Date: Thu, 07 Oct 2004 09:38:40 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <E1CFbHz-0001b8-00@kernel.beaverton.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267454AbUJGRGQ@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@osdl.org, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-Id: linux-mm.kvack.org


I don't know what this is trying to do.  It might be some kind of
artifact from when get_pgd_slow() was removed. 

The expanded expression with __pa() ends up looking something like this:

	(unsigned long)(u64)(u32)pmd-PAGE_OFFSET

and that is just nutty because pmd is a pointer now, anyway.

Attached patch removes the casts.  

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/mm/pgtable.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/i386/mm/pgtable.c~A3-remove-weird-pmd-casts-i386 arch/i386/mm/pgtable.c
--- memhotplug/arch/i386/mm/pgtable.c~A3-remove-weird-pmd-casts-i386	2004-10-07 09:34:26.000000000 -0700
+++ memhotplug-dave/arch/i386/mm/pgtable.c	2004-10-07 09:34:26.000000000 -0700
@@ -233,7 +233,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 		pmd_t *pmd = kmem_cache_alloc(pmd_cache, GFP_KERNEL);
 		if (!pmd)
 			goto out_oom;
-		set_pgd(&pgd[i], __pgd(1 + __pa((u64)((u32)pmd))));
+		set_pgd(&pgd[i], __pgd(1 + __pa(pmd)));
 	}
 	return pgd;
 
_
