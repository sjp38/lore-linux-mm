Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AEE76B0268
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:30:16 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 96so5874887wrk.12
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:30:16 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id l26si2032534edf.443.2018.03.16.12.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:30:15 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 30/35] x86/ldt: Define LDT_END_ADDR
Date: Fri, 16 Mar 2018 20:29:48 +0100
Message-Id: <1521228593-3820-31-git-send-email-joro@8bytes.org>
In-Reply-To: <1521228593-3820-1-git-send-email-joro@8bytes.org>
References: <1521228593-3820-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

It marks the end of the address-space range reserved for the
LDT. The LDT-code will use it when unmapping the LDT for
user-space.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable_32_types.h | 2 ++
 arch/x86/include/asm/pgtable_64_types.h | 2 ++
 arch/x86/kernel/ldt.c                   | 2 +-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/pgtable_32_types.h b/arch/x86/include/asm/pgtable_32_types.h
index eb2e97a..02bd445 100644
--- a/arch/x86/include/asm/pgtable_32_types.h
+++ b/arch/x86/include/asm/pgtable_32_types.h
@@ -51,6 +51,8 @@ extern bool __vmalloc_start_set; /* set once high_memory is set */
 #define LDT_BASE_ADDR		\
 	((CPU_ENTRY_AREA_BASE - PAGE_SIZE) & PMD_MASK)
 
+#define LDT_END_ADDR		(LDT_BASE_ADDR + PMD_SIZE)
+
 #define PKMAP_BASE		\
 	((LDT_BASE_ADDR - PAGE_SIZE) & PMD_MASK)
 
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index e57003a..15188baa 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -90,12 +90,14 @@ typedef struct { pteval_t pte; } pte_t;
 # define __VMEMMAP_BASE		_AC(0xffd4000000000000, UL)
 # define LDT_PGD_ENTRY		_AC(-112, UL)
 # define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
+#define  LDT_END_ADDR		(LDT_BASE_ADDR + PGDIR_SIZE)
 #else
 # define VMALLOC_SIZE_TB	_AC(32, UL)
 # define __VMALLOC_BASE		_AC(0xffffc90000000000, UL)
 # define __VMEMMAP_BASE		_AC(0xffffea0000000000, UL)
 # define LDT_PGD_ENTRY		_AC(-3, UL)
 # define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
+#define  LDT_END_ADDR		(LDT_BASE_ADDR + PGDIR_SIZE)
 #endif
 
 #ifdef CONFIG_RANDOMIZE_MEMORY
diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index 26d713e..f3c2fbf 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -202,7 +202,7 @@ static void free_ldt_pgtables(struct mm_struct *mm)
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 	struct mmu_gather tlb;
 	unsigned long start = LDT_BASE_ADDR;
-	unsigned long end = start + (1UL << PGDIR_SHIFT);
+	unsigned long end = LDT_END_ADDR;
 
 	if (!static_cpu_has(X86_FEATURE_PTI))
 		return;
-- 
2.7.4
