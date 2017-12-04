Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FAA56B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:35:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q186so11773748pga.23
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:35:22 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l28si10509016pfg.215.2017.12.04.08.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 08:35:21 -0800 (PST)
Date: Mon, 4 Dec 2017 19:34:45 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] x86/mm: Rewrite sme_populate_pgd() in a more sensible way
Message-ID: <20171204163445.qt5dqcrrkilnhowz@black.fi.intel.com>
References: <20171204112323.47019-1-kirill.shutemov@linux.intel.com>
 <d177df77-cdc7-1507-08f8-fcdb3b443709@amd.com>
 <20171204145755.6xu2w6a6og56rq5v@node.shutemov.name>
 <d9701b1c-1abf-5fc1-80b0-47ab4e517681@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9701b1c-1abf-5fc1-80b0-47ab4e517681@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 04, 2017 at 04:00:26PM +0000, Tom Lendacky wrote:
> On 12/4/2017 8:57 AM, Kirill A. Shutemov wrote:
> > On Mon, Dec 04, 2017 at 08:19:11AM -0600, Tom Lendacky wrote:
> > > On 12/4/2017 5:23 AM, Kirill A. Shutemov wrote:
> > > > sme_populate_pgd() open-codes a lot of things that are not needed to be
> > > > open-coded.
> > > > 
> > > > Let's rewrite it in a more stream-lined way.
> > > > 
> > > > This would also buy us boot-time switching between support between
> > > > paging modes, when rest of the pieces will be upstream.
> > > 
> > > Hi Kirill,
> > > 
> > > Unfortunately, some of these can't be changed.  The use of p4d_offset(),
> > > pud_offset(), etc., use non-identity mapped virtual addresses which cause
> > > failures at this point of the boot process.
> > 
> > Wat? Virtual address is virtual address. p?d_offset() doesn't care about
> > what mapping you're using.
> 
> Yes it does.  For example, pmd_offset() issues a pud_page_addr() call,
> which does a __va() returning a non-identity mapped address (0xffff88...).
> Only identity mapped virtual addresses have been setup at this point, so
> the use of that virtual address panics the kernel.

Stupid me. You are right.

What about something like this:

diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index d9a9e9fc75dd..65e0d68f863f 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -12,6 +12,23 @@
 
 #define DISABLE_BRANCH_PROFILING
 
+/*
+ * Since we're dealing with identity mappings, physical and virtual
+ * addresses are the same, so override these defines which are ultimately
+ * used by the headers in misc.h.
+ */
+#define __pa(x)  ((unsigned long)(x))
+#define __va(x)  ((void *)((unsigned long)(x)))
+
+/*
+ * Special hack: we have to be careful, because no indirections are
+ * allowed here, and paravirt_ops is a kind of one. As it will only run in
+ * baremetal anyway, we just keep it from happening. (This list needs to
+ * be extended when new paravirt and debugging variants are added.)
+ */
+#undef CONFIG_PARAVIRT
+#undef CONFIG_PARAVIRT_SPINLOCKS
+
 #include <linux/linkage.h>
 #include <linux/init.h>
 #include <linux/mm.h>
@@ -489,73 +506,42 @@ static void __init sme_clear_pgd(pgd_t *pgd_base, unsigned long start,
 static void __init *sme_populate_pgd(pgd_t *pgd_base, void *pgtable_area,
 				     unsigned long vaddr, pmdval_t pmd_val)
 {
-	pgd_t *pgd_p;
-	p4d_t *p4d_p;
-	pud_t *pud_p;
-	pmd_t *pmd_p;
-
-	pgd_p = pgd_base + pgd_index(vaddr);
-	if (native_pgd_val(*pgd_p)) {
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
-			p4d_p = (p4d_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
-		else
-			pud_p = (pud_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pgd_t pgd;
-
-		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-			p4d_p = pgtable_area;
-			memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
-			pgtable_area += sizeof(*p4d_p) * PTRS_PER_P4D;
-
-			pgd = native_make_pgd((pgdval_t)p4d_p + PGD_FLAGS);
-		} else {
-			pud_p = pgtable_area;
-			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-			pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
-
-			pgd = native_make_pgd((pgdval_t)pud_p + PGD_FLAGS);
-		}
-		native_set_pgd(pgd_p, pgd);
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_base + pgd_index(vaddr);
+	if (pgd_none(*pgd)) {
+		p4d = pgtable_area;
+		memset(p4d, 0, sizeof(*p4d) * PTRS_PER_P4D);
+		pgtable_area += sizeof(*p4d) * PTRS_PER_P4D;
+		set_pgd(pgd, __pgd(PGD_FLAGS | __pa(p4d)));
 	}
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-		p4d_p += p4d_index(vaddr);
-		if (native_p4d_val(*p4d_p)) {
-			pud_p = (pud_t *)(native_p4d_val(*p4d_p) & ~PTE_FLAGS_MASK);
-		} else {
-			p4d_t p4d;
-
-			pud_p = pgtable_area;
-			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-			pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
-
-			p4d = native_make_p4d((pudval_t)pud_p + P4D_FLAGS);
-			native_set_p4d(p4d_p, p4d);
-		}
+	p4d = p4d_offset(pgd, vaddr);
+	if (p4d_none(*p4d)) {
+		pud = pgtable_area;
+		memset(pud, 0, sizeof(*pud) * PTRS_PER_PUD);
+		pgtable_area += sizeof(*pud) * PTRS_PER_PUD;
+		set_p4d(p4d, __p4d(P4D_FLAGS | __pa(pud)));
 	}
 
-	pud_p += pud_index(vaddr);
-	if (native_pud_val(*pud_p)) {
-		if (native_pud_val(*pud_p) & _PAGE_PSE)
-			goto out;
-
-		pmd_p = (pmd_t *)(native_pud_val(*pud_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pud_t pud;
-
-		pmd_p = pgtable_area;
-		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
-		pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
-
-		pud = native_make_pud((pmdval_t)pmd_p + PUD_FLAGS);
-		native_set_pud(pud_p, pud);
+	pud = pud_offset(p4d, vaddr);
+	if (pud_none(*pud)) {
+		pmd = pgtable_area;
+		memset(pmd, 0, sizeof(*pmd) * PTRS_PER_PMD);
+		pgtable_area += sizeof(*pmd) * PTRS_PER_PMD;
+		set_pud(pud, __pud(PUD_FLAGS | __pa(pmd)));
 	}
+	if (pud_large(*pud))
+		goto out;
 
-	pmd_p += pmd_index(vaddr);
-	if (!native_pmd_val(*pmd_p) || !(native_pmd_val(*pmd_p) & _PAGE_PSE))
-		native_set_pmd(pmd_p, native_make_pmd(pmd_val));
+	pmd = pmd_offset(pud, vaddr);
+	if (pmd_large(*pmd))
+		goto out;
 
+	set_pmd(pmd, __pmd(pmd_val));
 out:
 	return pgtable_area;
 }
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
