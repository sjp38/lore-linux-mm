Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 492226B000D
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:05:51 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Feb 2013 18:04:00 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 42A183578051
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:47 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1Q7rAlC9896280
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 18:53:11 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1Q85krs007987
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:46 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 11/24] powerpc: Update tlbie/tlbiel as per ISA doc
Date: Tue, 26 Feb 2013 13:35:01 +0530
Message-Id: <1361865914-13911-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This make sure we handle multiple page size segment correctly.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hash_native_64.c |   52 +++++++++++++++++++++++++++++---------
 1 file changed, 40 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index e2d816d..e800b26 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -39,7 +39,7 @@
 
 DEFINE_RAW_SPINLOCK(native_tlbie_lock);
 
-static inline void __tlbie(unsigned long vpn, int psize, int apsize, int ssize)
+static inline void __tlbie(unsigned long vpn, int bpsize, int apsize, int ssize)
 {
 	unsigned long va;
 	unsigned int penc;
@@ -59,19 +59,33 @@ static inline void __tlbie(unsigned long vpn, int psize, int apsize, int ssize)
 	 */
 	va &= ~(0xffffULL << 48);
 
-	switch (psize) {
+	switch (bpsize) {
 	case MMU_PAGE_4K:
+		/* clear out bits after (52) [0....52.....63] */
+		va &= ~((1ul << (64 - 52)) - 1);
 		va |= ssize << 8;
+		va |= mmu_psize_defs[apsize].sllp << 6;
 		asm volatile(ASM_FTR_IFCLR("tlbie %0,0", PPC_TLBIE(%1,%0), %2)
 			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
 			     : "memory");
 		break;
 	default:
 		/* We need 14 to 14 + i bits of va */
-		penc = mmu_psize_defs[psize].penc[apsize];
-		va &= ~((1ul << mmu_psize_defs[psize].shift) - 1);
+		penc = mmu_psize_defs[bpsize].penc[apsize];
+		/* clear out bits after (44) [0....44.....63] */
+		va &= ~((1ul << (64 - 44)) - 1);
 		va |= penc << 12;
 		va |= ssize << 8;
+		/* Add AVAL part */
+		if (bpsize != apsize) {
+			/*
+			 * MPSS, 64K base page size and 16MB parge page size
+			 * We don't need all the bits, but this seems to work.
+			 * vpn cover upto 65 bits of va. (0...65) and we need
+			 * 56..62 bits of va.
+			 */
+			va |= ((vpn >> 2) & 0xfe);
+		}
 		va |= 1; /* L */
 		asm volatile(ASM_FTR_IFCLR("tlbie %0,1", PPC_TLBIE(%1,%0), %2)
 			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
@@ -80,7 +94,7 @@ static inline void __tlbie(unsigned long vpn, int psize, int apsize, int ssize)
 	}
 }
 
-static inline void __tlbiel(unsigned long vpn, int psize, int apsize, int ssize)
+static inline void __tlbiel(unsigned long vpn, int bpsize, int apsize, int ssize)
 {
 	unsigned long va;
 	unsigned int penc;
@@ -94,18 +108,32 @@ static inline void __tlbiel(unsigned long vpn, int psize, int apsize, int ssize)
 	 */
 	va &= ~(0xffffULL << 48);
 
-	switch (psize) {
+	switch (bpsize) {
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
-		penc = mmu_psize_defs[psize].penc[apsize];
-		va &= ~((1ul << mmu_psize_defs[psize].shift) - 1);
+		penc = mmu_psize_defs[bpsize].penc[apsize];
+		/* clear out bits after(44) [0....44.....63] */
+		va &= ~((1ul << (64 - 44)) - 1);
 		va |= penc << 12;
 		va |= ssize << 8;
+		/* Add AVAL part */
+		if (bpsize != apsize) {
+			/*
+			 * MPSS, 64K base page size and 16MB parge page size
+			 * We don't need all the bits, but this seems to work.
+			 * vpn cover upto 65 bits of va. (0...65) and we need
+			 * 56..62 bits of va.
+			 */
+			va |= ((vpn >> 2) & 0xfe);
+		}
 		va |= 1; /* L */
 		asm volatile(".long 0x7c000224 | (%0 << 11) | (1 << 21)"
 			     : : "r"(va) : "memory");
@@ -114,22 +142,22 @@ static inline void __tlbiel(unsigned long vpn, int psize, int apsize, int ssize)
 
 }
 
-static inline void tlbie(unsigned long vpn, int psize, int apsize,
+static inline void tlbie(unsigned long vpn, int bpsize, int apsize,
 			 int ssize, int local)
 {
 	unsigned int use_local = local && mmu_has_feature(MMU_FTR_TLBIEL);
 	int lock_tlbie = !mmu_has_feature(MMU_FTR_LOCKLESS_TLBIE);
 
 	if (use_local)
-		use_local = mmu_psize_defs[psize].tlbiel;
+		use_local = mmu_psize_defs[bpsize].tlbiel;
 	if (lock_tlbie && !use_local)
 		raw_spin_lock(&native_tlbie_lock);
 	asm volatile("ptesync": : :"memory");
 	if (use_local) {
-		__tlbiel(vpn, psize, apsize, ssize);
+		__tlbiel(vpn, bpsize, apsize, ssize);
 		asm volatile("ptesync": : :"memory");
 	} else {
-		__tlbie(vpn, psize, apsize, ssize);
+		__tlbie(vpn, bpsize, apsize, ssize);
 		asm volatile("eieio; tlbsync; ptesync": : :"memory");
 	}
 	if (lock_tlbie && !use_local)
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
