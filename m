Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0AC68E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 17:36:48 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id f69so18845135pff.5
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 14:36:48 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n125si37082895pga.179.2018.12.26.14.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 14:36:47 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.19 30/97] x86/mm: Fix guard hole handling
Date: Wed, 26 Dec 2018 17:34:50 -0500
Message-Id: <20181226223557.149329-30-sashal@kernel.org>
In-Reply-To: <20181226223557.149329-1-sashal@kernel.org>
References: <20181226223557.149329-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, bhe@redhat.com, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Sasha Levin <sashal@kernel.org>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

[ Upstream commit 16877a5570e0c5f4270d5b17f9bab427bcae9514 ]

There is a guard hole at the beginning of the kernel address space, also
used by hypervisors. It occupies 16 PGD entries.

This reserved range is not defined explicitely, it is calculated relative
to other entities: direct mapping and user space ranges.

The calculation got broken by recent changes of the kernel memory layout:
LDT remap range is now mapped before direct mapping and makes the
calculation invalid.

The breakage leads to crash on Xen dom0 boot[1].

Define the reserved range explicitely. It's part of kernel ABI (hypervisors
expect it to be stable) and must not depend on changes in the rest of
kernel memory layout.

[1] https://lists.xenproject.org/archives/html/xen-devel/2018-11/msg03313.html

Fixes: d52888aa2753 ("x86/mm: Move LDT remap out of KASLR region on 5-level paging")
Reported-by: Hans van Kranenburg <hans.van.kranenburg@mendix.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Hans van Kranenburg <hans.van.kranenburg@mendix.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
Cc: bp@alien8.de
Cc: hpa@zytor.com
Cc: dave.hansen@linux.intel.com
Cc: luto@kernel.org
Cc: peterz@infradead.org
Cc: boris.ostrovsky@oracle.com
Cc: bhe@redhat.com
Cc: linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org
Link: https://lkml.kernel.org/r/20181130202328.65359-2-kirill.shutemov@linux.intel.com
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/x86/include/asm/pgtable_64_types.h |  5 +++++
 arch/x86/mm/dump_pagetables.c           |  8 ++++----
 arch/x86/xen/mmu_pv.c                   | 11 ++++++-----
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 84bd9bdc1987..88bca456da99 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -111,6 +111,11 @@ extern unsigned int ptrs_per_p4d;
  */
 #define MAXMEM			(1UL << MAX_PHYSMEM_BITS)
 
+#define GUARD_HOLE_PGD_ENTRY	-256UL
+#define GUARD_HOLE_SIZE		(16UL << PGDIR_SHIFT)
+#define GUARD_HOLE_BASE_ADDR	(GUARD_HOLE_PGD_ENTRY << PGDIR_SHIFT)
+#define GUARD_HOLE_END_ADDR	(GUARD_HOLE_BASE_ADDR + GUARD_HOLE_SIZE)
+
 #define LDT_PGD_ENTRY		-240UL
 #define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 #define LDT_END_ADDR		(LDT_BASE_ADDR + PGDIR_SIZE)
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index a12afff146d1..073755c89126 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -493,11 +493,11 @@ static inline bool is_hypervisor_range(int idx)
 {
 #ifdef CONFIG_X86_64
 	/*
-	 * ffff800000000000 - ffff87ffffffffff is reserved for
-	 * the hypervisor.
+	 * A hole in the beginning of kernel address space reserved
+	 * for a hypervisor.
 	 */
-	return	(idx >= pgd_index(__PAGE_OFFSET) - 16) &&
-		(idx <  pgd_index(__PAGE_OFFSET));
+	return	(idx >= pgd_index(GUARD_HOLE_BASE_ADDR)) &&
+		(idx <  pgd_index(GUARD_HOLE_END_ADDR));
 #else
 	return false;
 #endif
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index 2c84c6ad8b50..c8f011e07a15 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -640,19 +640,20 @@ static int __xen_pgd_walk(struct mm_struct *mm, pgd_t *pgd,
 			  unsigned long limit)
 {
 	int i, nr, flush = 0;
-	unsigned hole_low, hole_high;
+	unsigned hole_low = 0, hole_high = 0;
 
 	/* The limit is the last byte to be touched */
 	limit--;
 	BUG_ON(limit >= FIXADDR_TOP);
 
+#ifdef CONFIG_X86_64
 	/*
 	 * 64-bit has a great big hole in the middle of the address
-	 * space, which contains the Xen mappings.  On 32-bit these
-	 * will end up making a zero-sized hole and so is a no-op.
+	 * space, which contains the Xen mappings.
 	 */
-	hole_low = pgd_index(USER_LIMIT);
-	hole_high = pgd_index(PAGE_OFFSET);
+	hole_low = pgd_index(GUARD_HOLE_BASE_ADDR);
+	hole_high = pgd_index(GUARD_HOLE_END_ADDR);
+#endif
 
 	nr = pgd_index(limit) + 1;
 	for (i = 0; i < nr; i++) {
-- 
2.19.1
