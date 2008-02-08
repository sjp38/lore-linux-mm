Message-ID: <47AC29AC.6050502@bull.net>
Date: Fri, 08 Feb 2008 11:06:36 +0100
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: [PATCH 2.6.24-mm1] fix build error in arch/x86/mm/pgtable_32.c
Content-Type: multipart/mixed;
 boundary="------------090804050203090803060008"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090804050203090803060008
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit

Hi,

2.6.24-mm1 won't build if CONFIG_X86_PAE is defined:


/home/lkernel/src/linux-2.6.24-mm1/arch/x86/mm/pgtable_32.c: In function 
?pgd_mop_up_pmds?:
/home/lkernel/src/linux-2.6.24-mm1/arch/x86/mm/pgtable_32.c:302: 
warning: passing argument 1 of ?pmd_free? from incompatible pointer type
/home/lkernel/src/linux-2.6.24-mm1/arch/x86/mm/pgtable_32.c:302: error: 
too few arguments to function ?pmd_free?
make[2]: *** [arch/x86/mm/pgtable_32.o] Error 1
make[1]: *** [arch/x86/mm] Error 2
make: *** [sub-make] Error 2


You'll find the proposed patch in attachment.

Regards,
Nadia

--------------090804050203090803060008
Content-Type: text/x-patch;
 name="x86_pmd_free.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x86_pmd_free.patch"

Add the mm missing argument to pmd_free() calls.

Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>

---
 arch/x86/mm/pgtable_32.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6.24-mm1/arch/x86/mm/pgtable_32.c
===================================================================
--- linux-2.6.24-mm1.orig/arch/x86/mm/pgtable_32.c	2008-02-07 13:40:42.000000000 +0100
+++ linux-2.6.24-mm1/arch/x86/mm/pgtable_32.c	2008-02-08 11:40:00.000000000 +0100
@@ -286,7 +286,7 @@ static void pgd_dtor(void *pgd)
  * preallocate which never got a corresponding vma will need to be
  * freed manually.
  */
-static void pgd_mop_up_pmds(pgd_t *pgdp)
+static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgdp)
 {
 	int i;
 
@@ -299,7 +299,7 @@ static void pgd_mop_up_pmds(pgd_t *pgdp)
 			pgdp[i] = native_make_pgd(0);
 
 			paravirt_release_pd(pgd_val(pgd) >> PAGE_SHIFT);
-			pmd_free(pmd);
+			pmd_free(mm, pmd);
 		}
 	}
 }
@@ -327,7 +327,7 @@ static int pgd_prepopulate_pmd(struct mm
 		pmd_t *pmd = pmd_alloc_one(mm, addr);
 
 		if (!pmd) {
-			pgd_mop_up_pmds(pgd);
+			pgd_mop_up_pmds(mm, pgd);
 			return 0;
 		}
 
@@ -347,7 +347,7 @@ static int pgd_prepopulate_pmd(struct mm
 	return 1;
 }
 
-static void pgd_mop_up_pmds(pgd_t *pgd)
+static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgd)
 {
 }
 #endif	/* CONFIG_X86_PAE */
@@ -368,7 +368,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
-	pgd_mop_up_pmds(pgd);
+	pgd_mop_up_pmds(mm, pgd);
 	quicklist_free(0, pgd_dtor, pgd);
 }
 

--------------090804050203090803060008--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
