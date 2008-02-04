Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m143tOPk002091
	for <linux-mm@kvack.org>; Mon, 4 Feb 2008 14:55:24 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m143tgpR3576046
	for <linux-mm@kvack.org>; Mon, 4 Feb 2008 14:55:43 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m143tgmq029227
	for <linux-mm@kvack.org>; Mon, 4 Feb 2008 14:55:42 +1100
Date: Mon, 4 Feb 2008 09:25:43 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: 2.6.24-mm1 Build Faliure on pgtable_32.c
Message-ID: <20080204035543.GA8186@linux.vnet.ibm.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
References: <20080203171634.58ab668b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080203171634.58ab668b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,

The 2.6.24-mm1 kernel build fails with 

arch/x86/mm/pgtable_32.c: In function `pgd_mop_up_pmds':
arch/x86/mm/pgtable_32.c:302: warning: passing arg 1 of `pmd_free' from incompatible pointer type
arch/x86/mm/pgtable_32.c:302: error: too few arguments to function `pmd_free'

I have tested the patch for the build failure only.

Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
--
--- linux-2.6.24/arch/x86/mm/pgtable_32.c	2008-02-04 07:36:36.000000000 +0000
+++ linux-2.6.24/arch/x86/mm/~pgtable_32.c	2008-02-04 07:38:02.000000000 +0000
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
+static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgdp)
 {
 }
 #endif	/* CONFIG_X86_PAE */
@@ -368,7 +368,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
-	pgd_mop_up_pmds(pgd);
+	pgd_mop_up_pmds(mm,pgd);
 	quicklist_free(0, pgd_dtor, pgd);
 }
 
-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
