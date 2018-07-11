Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E39EB6B0293
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:30:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a22-v6so9880762eds.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:30:22 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id a90-v6si364106ede.124.2018.07.11.04.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 04:30:21 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 35/39] x86/ldt: Split out sanity check in map_ldt_struct()
Date: Wed, 11 Jul 2018 13:29:42 +0200
Message-Id: <1531308586-29340-36-git-send-email-joro@8bytes.org>
In-Reply-To: <1531308586-29340-1-git-send-email-joro@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

This splits out the mapping sanity check and the actual
mapping of the LDT to user-space from the map_ldt_struct()
function in a way so that it is re-usable for PAE paging.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/kernel/ldt.c | 82 ++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 58 insertions(+), 24 deletions(-)

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index e921b3d..69af9a0 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -100,6 +100,49 @@ static struct ldt_struct *alloc_ldt_struct(unsigned int num_entries)
 	return new_ldt;
 }
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+
+static void do_sanity_check(struct mm_struct *mm,
+			    bool had_kernel_mapping,
+			    bool had_user_mapping)
+{
+	if (mm->context.ldt) {
+		/*
+		 * We already had an LDT.  The top-level entry should already
+		 * have been allocated and synchronized with the usermode
+		 * tables.
+		 */
+		WARN_ON(!had_kernel_mapping);
+		if (static_cpu_has(X86_FEATURE_PTI))
+			WARN_ON(!had_user_mapping);
+	} else {
+		/*
+		 * This is the first time we're mapping an LDT for this process.
+		 * Sync the pgd to the usermode tables.
+		 */
+		WARN_ON(had_kernel_mapping);
+		if (static_cpu_has(X86_FEATURE_PTI))
+			WARN_ON(had_user_mapping);
+	}
+}
+
+static void map_ldt_struct_to_user(struct mm_struct *mm)
+{
+	pgd_t *pgd = pgd_offset(mm, LDT_BASE_ADDR);
+
+	if (static_cpu_has(X86_FEATURE_PTI) && !mm->context.ldt)
+		set_pgd(kernel_to_user_pgdp(pgd), *pgd);
+}
+
+static void sanity_check_ldt_mapping(struct mm_struct *mm)
+{
+	pgd_t *pgd = pgd_offset(mm, LDT_BASE_ADDR);
+	bool had_kernel = (pgd->pgd != 0);
+	bool had_user   = (kernel_to_user_pgdp(pgd)->pgd != 0);
+
+	do_sanity_check(mm, had_kernel, had_user);
+}
+
 /*
  * If PTI is enabled, this maps the LDT into the kernelmode and
  * usermode tables for the given mm.
@@ -115,9 +158,8 @@ static struct ldt_struct *alloc_ldt_struct(unsigned int num_entries)
 static int
 map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 {
-#ifdef CONFIG_PAGE_TABLE_ISOLATION
-	bool is_vmalloc, had_top_level_entry;
 	unsigned long va;
+	bool is_vmalloc;
 	spinlock_t *ptl;
 	pgd_t *pgd;
 	int i;
@@ -131,13 +173,15 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	 */
 	WARN_ON(ldt->slot != -1);
 
+	/* Check if the current mappings are sane */
+	sanity_check_ldt_mapping(mm);
+
 	/*
 	 * Did we already have the top level entry allocated?  We can't
 	 * use pgd_none() for this because it doens't do anything on
 	 * 4-level page table kernels.
 	 */
 	pgd = pgd_offset(mm, LDT_BASE_ADDR);
-	had_top_level_entry = (pgd->pgd != 0);
 
 	is_vmalloc = is_vmalloc_addr(ldt->entries);
 
@@ -172,35 +216,25 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 		pte_unmap_unlock(ptep, ptl);
 	}
 
-	if (mm->context.ldt) {
-		/*
-		 * We already had an LDT.  The top-level entry should already
-		 * have been allocated and synchronized with the usermode
-		 * tables.
-		 */
-		WARN_ON(!had_top_level_entry);
-		if (static_cpu_has(X86_FEATURE_PTI))
-			WARN_ON(!kernel_to_user_pgdp(pgd)->pgd);
-	} else {
-		/*
-		 * This is the first time we're mapping an LDT for this process.
-		 * Sync the pgd to the usermode tables.
-		 */
-		WARN_ON(had_top_level_entry);
-		if (static_cpu_has(X86_FEATURE_PTI)) {
-			WARN_ON(kernel_to_user_pgdp(pgd)->pgd);
-			set_pgd(kernel_to_user_pgdp(pgd), *pgd);
-		}
-	}
+	/* Propagate LDT mapping to the user page-table */
+	map_ldt_struct_to_user(mm);
 
 	va = (unsigned long)ldt_slot_va(slot);
 	flush_tlb_mm_range(mm, va, va + LDT_SLOT_STRIDE, 0);
 
 	ldt->slot = slot;
-#endif
 	return 0;
 }
 
+#else /* !CONFIG_PAGE_TABLE_ISOLATION */
+
+static int
+map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
+{
+	return 0;
+}
+#endif /* CONFIG_PAGE_TABLE_ISOLATION */
+
 static void free_ldt_pgtables(struct mm_struct *mm)
 {
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
-- 
2.7.4
