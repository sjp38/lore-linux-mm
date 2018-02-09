Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFE2D6B002E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:26:07 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g187so3601518wmg.2
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:26:07 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id b2si1647930ede.522.2018.02.09.01.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:26:06 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 26/31] x86/pgtable/pae: Use separate kernel PMDs for user page-table
Date: Fri,  9 Feb 2018 10:25:35 +0100
Message-Id: <1518168340-9392-27-git-send-email-joro@8bytes.org>
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

We need separate kernel PMDs in the user page-table when PTI
is enabled to map the per-process LDT for user-space.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pgtable.c | 100 ++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 81 insertions(+), 19 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index a81d42e..d95bc7b 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -177,6 +177,14 @@ static void pgd_dtor(pgd_t *pgd)
  */
 #define PREALLOCATED_PMDS	UNSHARED_PTRS_PER_PGD
 
+/*
+ * We allocate separate PMDs for the kernel part of the user page-table
+ * when PTI is enabled. We need them to map the per-process LDT into the
+ * user-space page-table.
+ */
+#define PREALLOCATED_USER_PMDS	 (static_cpu_has(X86_FEATURE_PTI) ? \
+					KERNEL_PGD_PTRS : 0)
+
 void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd)
 {
 	paravirt_alloc_pmd(mm, __pa(pmd) >> PAGE_SHIFT);
@@ -197,14 +205,14 @@ void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd)
 
 /* No need to prepopulate any pagetable entries in non-PAE modes. */
 #define PREALLOCATED_PMDS	0
-
+#define PREALLOCATED_USER_PMDS	 0
 #endif	/* CONFIG_X86_PAE */
 
-static void free_pmds(struct mm_struct *mm, pmd_t *pmds[])
+static void free_pmds(struct mm_struct *mm, pmd_t *pmds[], int count)
 {
 	int i;
 
-	for(i = 0; i < PREALLOCATED_PMDS; i++)
+	for(i = 0; i < count; i++)
 		if (pmds[i]) {
 			pgtable_pmd_page_dtor(virt_to_page(pmds[i]));
 			free_page((unsigned long)pmds[i]);
@@ -212,7 +220,7 @@ static void free_pmds(struct mm_struct *mm, pmd_t *pmds[])
 		}
 }
 
-static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[])
+static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[], int count)
 {
 	int i;
 	bool failed = false;
@@ -221,7 +229,7 @@ static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[])
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
 
-	for(i = 0; i < PREALLOCATED_PMDS; i++) {
+	for(i = 0; i < count; i++) {
 		pmd_t *pmd = (pmd_t *)__get_free_page(gfp);
 		if (!pmd)
 			failed = true;
@@ -236,7 +244,7 @@ static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[])
 	}
 
 	if (failed) {
-		free_pmds(mm, pmds);
+		free_pmds(mm, pmds, count);
 		return -ENOMEM;
 	}
 
@@ -249,23 +257,38 @@ static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[])
  * preallocate which never got a corresponding vma will need to be
  * freed manually.
  */
+static void mop_up_one_pmd(struct mm_struct *mm, pgd_t *pgdp)
+{
+	pgd_t pgd = *pgdp;
+
+	if (pgd_val(pgd) != 0) {
+		pmd_t *pmd = (pmd_t *)pgd_page_vaddr(pgd);
+
+		*pgdp = native_make_pgd(0);
+
+		paravirt_release_pmd(pgd_val(pgd) >> PAGE_SHIFT);
+		pmd_free(mm, pmd);
+		mm_dec_nr_pmds(mm);
+	}
+}
+
 static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgdp)
 {
 	int i;
 
-	for(i = 0; i < PREALLOCATED_PMDS; i++) {
-		pgd_t pgd = pgdp[i];
+	for(i = 0; i < PREALLOCATED_PMDS; i++)
+		mop_up_one_pmd(mm, &pgdp[i]);
 
-		if (pgd_val(pgd) != 0) {
-			pmd_t *pmd = (pmd_t *)pgd_page_vaddr(pgd);
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
 
-			pgdp[i] = native_make_pgd(0);
+	if (!static_cpu_has(X86_FEATURE_PTI))
+		return;
 
-			paravirt_release_pmd(pgd_val(pgd) >> PAGE_SHIFT);
-			pmd_free(mm, pmd);
-			mm_dec_nr_pmds(mm);
-		}
-	}
+	pgdp = kernel_to_user_pgdp(pgdp);
+
+	for (i = 0; i < PREALLOCATED_USER_PMDS; i++)
+		mop_up_one_pmd(mm, &pgdp[i + KERNEL_PGD_BOUNDARY]);
+#endif
 }
 
 static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
@@ -291,6 +314,38 @@ static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
 	}
 }
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+static void pgd_prepopulate_user_pmd(struct mm_struct *mm,
+				     pgd_t *k_pgd, pmd_t *pmds[])
+{
+	pgd_t *s_pgd = kernel_to_user_pgdp(swapper_pg_dir);
+	pgd_t *u_pgd = kernel_to_user_pgdp(k_pgd);
+	p4d_t *u_p4d;
+	pud_t *u_pud;
+	int i;
+
+	u_p4d = p4d_offset(u_pgd, 0);
+	u_pud = pud_offset(u_p4d, 0);
+
+	s_pgd += KERNEL_PGD_BOUNDARY;
+	u_pud += KERNEL_PGD_BOUNDARY;
+
+	for (i = 0; i < PREALLOCATED_USER_PMDS; i++, u_pud++, s_pgd++) {
+		pmd_t *pmd = pmds[i];
+
+		memcpy(pmd, (pmd_t *)pgd_page_vaddr(*s_pgd),
+		       sizeof(pmd_t) * PTRS_PER_PMD);
+
+		pud_populate(mm, u_pud, pmd);
+	}
+
+}
+#else
+static void pgd_prepopulate_user_pmd(struct mm_struct *mm,
+				     pgd_t *k_pgd, pmd_t *pmds[])
+{
+}
+#endif
 /*
  * Xen paravirt assumes pgd table should be in one page. 64 bit kernel also
  * assumes that pgd should be in one page.
@@ -371,6 +426,7 @@ static inline void _pgd_free(pgd_t *pgd)
 pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	pgd_t *pgd;
+	pmd_t *u_pmds[PREALLOCATED_USER_PMDS];
 	pmd_t *pmds[PREALLOCATED_PMDS];
 
 	pgd = _pgd_alloc();
@@ -380,12 +436,15 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 
 	mm->pgd = pgd;
 
-	if (preallocate_pmds(mm, pmds) != 0)
+	if (preallocate_pmds(mm, pmds, PREALLOCATED_PMDS) != 0)
 		goto out_free_pgd;
 
-	if (paravirt_pgd_alloc(mm) != 0)
+	if (preallocate_pmds(mm, u_pmds, PREALLOCATED_USER_PMDS) != 0)
 		goto out_free_pmds;
 
+	if (paravirt_pgd_alloc(mm) != 0)
+		goto out_free_user_pmds;
+
 	/*
 	 * Make sure that pre-populating the pmds is atomic with
 	 * respect to anything walking the pgd_list, so that they
@@ -395,13 +454,16 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 
 	pgd_ctor(mm, pgd);
 	pgd_prepopulate_pmd(mm, pgd, pmds);
+	pgd_prepopulate_user_pmd(mm, pgd, u_pmds);
 
 	spin_unlock(&pgd_lock);
 
 	return pgd;
 
+out_free_user_pmds:
+	free_pmds(mm, u_pmds, PREALLOCATED_USER_PMDS);
 out_free_pmds:
-	free_pmds(mm, pmds);
+	free_pmds(mm, pmds, PREALLOCATED_PMDS);
 out_free_pgd:
 	_pgd_free(pgd);
 out:
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
