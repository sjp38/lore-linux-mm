Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 87E376B000A
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:05:47 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Feb 2013 17:58:21 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A5EFB2BB0050
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:39 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1Q7r3g610092870
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 18:53:03 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1Q85cod007826
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:38 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 07/24] powerpc: Add size argument to pgtable_cache_add
Date: Tue, 26 Feb 2013 13:34:57 +0530
Message-Id: <1361865914-13911-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will use this later with THP changes to request for pmd table of double the size.
THP code does PTE page allocation along with large page request and deposit them
for later use. This is to ensure that we won't have any failures when we split
huge pages to regular pages.

On powerpc we want to use the deposited PTE page for storing hash pte slot and
secondary bit information for the HPTEs. Hence we save them in the second half
of the pmd table.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64.h |    7 ++++++-
 arch/powerpc/mm/init_64.c                |   16 ++++++++--------
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 0182c20..658ba7c 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -338,8 +338,13 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 #define pgoff_to_pte(off)	((pte_t) {((off) << PTE_RPN_SHIFT)|_PAGE_FILE})
 #define PTE_FILE_MAX_BITS	(BITS_PER_LONG - PTE_RPN_SHIFT)
 
-void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
+extern void __pgtable_cache_add(unsigned index, unsigned long table_size,
+				void (*ctor)(void *));
 void pgtable_cache_init(void);
+static inline void pgtable_cache_add(unsigned shift, void (*ctor)(void *))
+{
+	return __pgtable_cache_add(shift, sizeof(void *) << shift, ctor);
+}
 
 /*
  * find_linux_pte returns the address of a linux pte for a given
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 95a4529..b378438 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -100,10 +100,10 @@ struct kmem_cache *pgtable_cache[MAX_PGTABLE_INDEX_SIZE];
  * everything else.  Caches created by this function are used for all
  * the higher level pagetables, and for hugepage pagetables.
  */
-void pgtable_cache_add(unsigned shift, void (*ctor)(void *))
+void __pgtable_cache_add(unsigned int index, unsigned long table_size,
+			 void (*ctor)(void *))
 {
 	char *name;
-	unsigned long table_size = sizeof(void *) << shift;
 	unsigned long align = table_size;
 
 	/* When batching pgtable pointers for RCU freeing, we store
@@ -111,7 +111,7 @@ void pgtable_cache_add(unsigned shift, void (*ctor)(void *))
 	 * big enough to fit it.
 	 *
 	 * Likewise, hugeapge pagetable pointers contain a (different)
-	 * shift value in the low bits.  All tables must be aligned so
+	 * huge page size in the low bits.  All tables must be aligned so
 	 * as to leave enough 0 bits in the address to contain it. */
 	unsigned long minalign = max(MAX_PGTABLE_INDEX_SIZE + 1,
 				     HUGEPD_SHIFT_MASK + 1);
@@ -121,17 +121,17 @@ void pgtable_cache_add(unsigned shift, void (*ctor)(void *))
 	 * moment, gcc doesn't seem to recognize is_power_of_2 as a
 	 * constant expression, so so much for that. */
 	BUG_ON(!is_power_of_2(minalign));
-	BUG_ON((shift < 1) || (shift > MAX_PGTABLE_INDEX_SIZE));
+	BUG_ON((index < 1) || (index > MAX_PGTABLE_INDEX_SIZE));
 
-	if (PGT_CACHE(shift))
+	if (PGT_CACHE(index))
 		return; /* Already have a cache of this size */
 
 	align = max_t(unsigned long, align, minalign);
-	name = kasprintf(GFP_KERNEL, "pgtable-2^%d", shift);
+	name = kasprintf(GFP_KERNEL, "pgtable-2^%d", index);
 	new = kmem_cache_create(name, table_size, align, 0, ctor);
-	PGT_CACHE(shift) = new;
+	PGT_CACHE(index) = new;
 
-	pr_debug("Allocated pgtable cache for order %d\n", shift);
+	pr_debug("Allocated pgtable cache for order %d\n", index);
 }
 
 
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
