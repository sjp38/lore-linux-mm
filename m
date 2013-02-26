Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1914E6B000E
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:05:55 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Feb 2013 18:04:04 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 18F372BB0051
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:52 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1Q85n757143852
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:49 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1Q85phf008279
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:51 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 14/24] powerpc: Fix hpte_decode to use the correct decoding for page sizes
Date: Tue, 26 Feb 2013 13:35:04 +0530
Message-Id: <1361865914-13911-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

As per ISA doc, we encode base and actual page size in the LP bits of
PTE. The number of bit used to encode the page sizes depend on actual
page size.  ISA doc lists this as

   PTE LP     actual page size
rrrr rrrz 	a?JPY8KB
rrrr rrzz	a?JPY16KB
rrrr rzzz 	a?JPY32KB
rrrr zzzz 	a?JPY64KB
rrrz zzzz 	a?JPY128KB
rrzz zzzz 	a?JPY256KB
rzzz zzzz	a?JPY512KB
zzzz zzzz 	a?JPY1MB

ISA doc also says
"The values of the a??za?? bits used to specify each size, along with all possible
values of a??ra?? bits in the LP field, must result in LP values distinct from
other LP values for other sizes."

based on the above update hpte_decode to use the correct decoding for LP bits.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hash_native_64.c |   27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index e800b26..2c6940f 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -428,19 +428,15 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
 			int *psize, int *apsize, int *ssize, unsigned long *vpn)
 {
 	unsigned long avpn, pteg, vpi;
-	unsigned long hpte_r = hpte->r;
 	unsigned long hpte_v = hpte->v;
 	unsigned long vsid, seg_off;
-	int i, size, a_size = MMU_PAGE_4K, shift, penc;
+	int size, a_size = MMU_PAGE_4K, shift, mask;
+	/* Look at the 8 bit LP value */
+	unsigned int lp = (hpte->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
 
 	if (!(hpte_v & HPTE_V_LARGE))
 		size = MMU_PAGE_4K;
 	else {
-		for (i = 0; i < LP_BITS; i++) {
-			if ((hpte_r & LP_MASK(i+1)) == LP_MASK(i+1))
-				break;
-		}
-		penc = LP_MASK(i+1) >> LP_SHIFT;
 		for (size = 0; size < MMU_PAGE_COUNT; size++) {
 
 			/* 4K pages are not represented by LP */
@@ -450,12 +446,23 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
 			/* valid entries have a shift value */
 			if (!mmu_psize_defs[size].shift)
 				continue;
-			for (a_size = 0; a_size < MMU_PAGE_COUNT; a_size++)
-				if (penc == mmu_psize_defs[size].penc[a_size])
+
+			for (a_size = 0; a_size < MMU_PAGE_COUNT; a_size++) {
+				/* valid entries have a shift value */
+				if (!mmu_psize_defs[a_size].shift)
+					continue;
+
+				shift = mmu_psize_defs[a_size].shift - 11;
+				if (shift > 9)
+					shift = 9;
+				mask = (1 << shift) - 1;
+				if ((lp & mask) ==
+				    mmu_psize_defs[size].penc[a_size]) {
 					goto out;
+				}
+			}
 		}
 	}
-
 out:
 	/* This works for all page sizes, and for 256M and 1T segments */
 	*ssize = hpte_v >> HPTE_V_SSIZE_SHIFT;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
