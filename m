Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 56E0F6B004D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:24:41 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id A83B71258056
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:29:38 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wCP37340360
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:12 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wGnD026753
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:17 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 13/25] powerpc: Update tlbie/tlbiel as per ISA doc
Date: Thu,  4 Apr 2013 11:27:51 +0530
Message-Id: <1365055083-31956-14-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This make sure we handle multiple page size segment correctly.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hash_native_64.c |   30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index b461b2d..ac84fa6 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -61,7 +61,10 @@ static inline void __tlbie(unsigned long vpn, int psize, int apsize, int ssize)
 
 	switch (psize) {
 	case MMU_PAGE_4K:
+		/* clear out bits after (52) [0....52.....63] */
+		va &= ~((1ul << (64 - 52)) - 1);
 		va |= ssize << 8;
+		va |= mmu_psize_defs[apsize].sllp << 6;
 		asm volatile(ASM_FTR_IFCLR("tlbie %0,0", PPC_TLBIE(%1,%0), %2)
 			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
 			     : "memory");
@@ -69,9 +72,19 @@ static inline void __tlbie(unsigned long vpn, int psize, int apsize, int ssize)
 	default:
 		/* We need 14 to 14 + i bits of va */
 		penc = mmu_psize_defs[psize].penc[apsize];
-		va &= ~((1ul << mmu_psize_defs[psize].shift) - 1);
+		va &= ~((1ul << mmu_psize_defs[apsize].shift) - 1);
 		va |= penc << 12;
 		va |= ssize << 8;
+		/* Add AVAL part */
+		if (psize != apsize) {
+			/*
+			 * MPSS, 64K base page size and 16MB parge page size
+			 * We don't need all the bits, but this seems to work.
+			 * vpn cover upto 65 bits of va. (0...65) and we need
+			 * 58..64 bits of va.
+			 */
+			va |= (vpn & 0xfe);
+		}
 		va |= 1; /* L */
 		asm volatile(ASM_FTR_IFCLR("tlbie %0,1", PPC_TLBIE(%1,%0), %2)
 			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
@@ -96,16 +109,29 @@ static inline void __tlbiel(unsigned long vpn, int psize, int apsize, int ssize)
 
 	switch (psize) {
 	case MMU_PAGE_4K:
+		/* clear out bits after(52) [0....52.....63] */
+		va &= ~((1ul << (64 - 52)) - 1);
 		va |= ssize << 8;
+		va |= mmu_psize_defs[apsize].sllp << 6;
 		asm volatile(".long 0x7c000224 | (%0 << 11) | (0 << 21)"
 			     : : "r"(va) : "memory");
 		break;
 	default:
 		/* We need 14 to 14 + i bits of va */
 		penc = mmu_psize_defs[psize].penc[apsize];
-		va &= ~((1ul << mmu_psize_defs[psize].shift) - 1);
+		va &= ~((1ul << mmu_psize_defs[apsize].shift) - 1);
 		va |= penc << 12;
 		va |= ssize << 8;
+		/* Add AVAL part */
+		if (psize != apsize) {
+			/*
+			 * MPSS, 64K base page size and 16MB parge page size
+			 * We don't need all the bits, but this seems to work.
+			 * vpn cover upto 65 bits of va. (0...65) and we need
+			 * 58..64 bits of va.
+			 */
+			va |= (vpn & 0xfe);
+		}
 		va |= 1; /* L */
 		asm volatile(".long 0x7c000224 | (%0 << 11) | (1 << 21)"
 			     : : "r"(va) : "memory");
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
