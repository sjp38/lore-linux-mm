Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id ABF546B000A
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 16:24:55 -0500 (EST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 22 Jan 2013 14:24:55 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 375331FF001C
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 14:24:37 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0MLOidk150706
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 14:24:46 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0MLOXWs028149
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 14:24:33 -0700
Subject: [PATCH 2/5] pagetable level size/shift/mask helpers
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Tue, 22 Jan 2013 13:24:31 -0800
References: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
In-Reply-To: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
Message-Id: <20130122212431.405D3A8C@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>


I plan to use lookup_address() to walk the kernel pagetables
in a later patch.  It returns a "pte" and the level in the
pagetables where the "pte" was found.  The level is just an
enum and needs to be converted to a useful value in order to
do address calculations with it.  These helpers will be used
in at least two places.

This also gives the anonymous enum a real name so that no one
gets confused about what they should be passing in to these
helpers.

"PTE_SHIFT" was chosen for naming consistency with the other
pagetable levels (PGD/PUD/PMD_SHIFT).

Cc: H. Peter Anvin <hpa@zytor.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/x86/include/asm/pgtable.h       |   14 ++++++++++++++
 linux-2.6.git-dave/arch/x86/include/asm/pgtable_types.h |    2 +-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/pgtable.h~pagetable-level-size-helpers arch/x86/include/asm/pgtable.h
--- linux-2.6.git/arch/x86/include/asm/pgtable.h~pagetable-level-size-helpers	2013-01-22 13:17:15.464309478 -0800
+++ linux-2.6.git-dave/arch/x86/include/asm/pgtable.h	2013-01-22 13:17:15.472309544 -0800
@@ -390,6 +390,7 @@ pte_t *populate_extra_pte(unsigned long
 
 #ifndef __ASSEMBLY__
 #include <linux/mm_types.h>
+#include <linux/log2.h>
 
 static inline int pte_none(pte_t pte)
 {
@@ -781,6 +782,19 @@ static inline void clone_pgd_range(pgd_t
        memcpy(dst, src, count * sizeof(pgd_t));
 }
 
+#define PTE_SHIFT ilog2(PTRS_PER_PTE)
+static inline int page_level_shift(enum pg_level level)
+{
+	return (PAGE_SHIFT - PTE_SHIFT) + level * PTE_SHIFT;
+}
+static inline unsigned long page_level_size(enum pg_level level)
+{
+	return 1UL << page_level_shift(level);
+}
+static inline unsigned long page_level_mask(enum pg_level level)
+{
+	return ~(page_level_size(level) - 1);
+}
 
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
diff -puN arch/x86/include/asm/pgtable_types.h~pagetable-level-size-helpers arch/x86/include/asm/pgtable_types.h
--- linux-2.6.git/arch/x86/include/asm/pgtable_types.h~pagetable-level-size-helpers	2013-01-22 13:17:15.468309511 -0800
+++ linux-2.6.git-dave/arch/x86/include/asm/pgtable_types.h	2013-01-22 13:17:15.472309544 -0800
@@ -331,7 +331,7 @@ extern void native_pagetable_init(void);
 struct seq_file;
 extern void arch_report_meminfo(struct seq_file *m);
 
-enum {
+enum pg_level {
 	PG_LEVEL_NONE,
 	PG_LEVEL_4K,
 	PG_LEVEL_2M,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
