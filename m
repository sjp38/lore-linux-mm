Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 7A0BF6B0012
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:47:55 -0500 (EST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 22:15:49 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 939FC3940059
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:49 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LGlj2p25755796
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:45 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LGlm9f010422
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:47:48 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH -V2 06/21] powerpc: Add size argument to pgtable_cache_add
Date: Thu, 21 Feb 2013 22:17:13 +0530
Message-Id: <1361465248-10867-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will use this later with THP changes. With THP we want to create PMD with
twice the size. The second half will be used to depoist pgtable, which will
carry the hpte hash index value

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
