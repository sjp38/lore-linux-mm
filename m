Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 32ACF6B006E
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:37:53 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:03:19 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id E3A7F3940058
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:46 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJbfu143646978
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:41 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJbjfk003258
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:37:46 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 13/18] powerpc: Use encode avpn where we need only avpn values
Date: Mon, 29 Apr 2013 01:07:34 +0530
Message-Id: <1367177859-7893-14-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

In all these cases we are doing something similar to

HPTE_V_COMPARE(hpte_v, want_v) which ignores the HPTE_V_LARGE bit

With MPSS support we would need actual page size to set HPTE_V_LARGE
bit and that won't be available in most of these cases. Since we are ignoring
HPTE_V_LARGE bit, use the  avpn value instead. There should not be any change
in behaviour after this patch.

Acked-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hash_native_64.c        |  8 ++++----
 arch/powerpc/platforms/cell/beat_htab.c | 10 +++++-----
 arch/powerpc/platforms/ps3/htab.c       |  2 +-
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index ffc1e00..9d8983a 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -252,7 +252,7 @@ static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
 	unsigned long hpte_v, want_v;
 	int ret = 0;
 
-	want_v = hpte_encode_v(vpn, psize, ssize);
+	want_v = hpte_encode_avpn(vpn, psize, ssize);
 
 	DBG_LOW("    update(vpn=%016lx, avpnv=%016lx, group=%lx, newpp=%lx)",
 		vpn, want_v & HPTE_V_AVPN, slot, newpp);
@@ -288,7 +288,7 @@ static long native_hpte_find(unsigned long vpn, int psize, int ssize)
 	unsigned long want_v, hpte_v;
 
 	hash = hpt_hash(vpn, mmu_psize_defs[psize].shift, ssize);
-	want_v = hpte_encode_v(vpn, psize, ssize);
+	want_v = hpte_encode_avpn(vpn, psize, ssize);
 
 	/* Bolted mappings are only ever in the primary group */
 	slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
@@ -348,7 +348,7 @@ static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
 
 	DBG_LOW("    invalidate(vpn=%016lx, hash: %lx)\n", vpn, slot);
 
-	want_v = hpte_encode_v(vpn, psize, ssize);
+	want_v = hpte_encode_avpn(vpn, psize, ssize);
 	native_lock_hpte(hptep);
 	hpte_v = hptep->v;
 
@@ -520,7 +520,7 @@ static void native_flush_hash_range(unsigned long number, int local)
 			slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
 			slot += hidx & _PTEIDX_GROUP_IX;
 			hptep = htab_address + slot;
-			want_v = hpte_encode_v(vpn, psize, ssize);
+			want_v = hpte_encode_avpn(vpn, psize, ssize);
 			native_lock_hpte(hptep);
 			hpte_v = hptep->v;
 			if (!HPTE_V_COMPARE(hpte_v, want_v) ||
diff --git a/arch/powerpc/platforms/cell/beat_htab.c b/arch/powerpc/platforms/cell/beat_htab.c
index 0f6f839..472f9a7 100644
--- a/arch/powerpc/platforms/cell/beat_htab.c
+++ b/arch/powerpc/platforms/cell/beat_htab.c
@@ -191,7 +191,7 @@ static long beat_lpar_hpte_updatepp(unsigned long slot,
 	u64 dummy0, dummy1;
 	unsigned long want_v;
 
-	want_v = hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M);
+	want_v = hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
 
 	DBG_LOW("    update: "
 		"avpnv=%016lx, slot=%016lx, psize: %d, newpp %016lx ... ",
@@ -228,7 +228,7 @@ static long beat_lpar_hpte_find(unsigned long vpn, int psize)
 	unsigned long want_v, hpte_v;
 
 	hash = hpt_hash(vpn, mmu_psize_defs[psize].shift, MMU_SEGSIZE_256M);
-	want_v = hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M);
+	want_v = hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
 
 	for (j = 0; j < 2; j++) {
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
@@ -283,7 +283,7 @@ static void beat_lpar_hpte_invalidate(unsigned long slot, unsigned long vpn,
 
 	DBG_LOW("    inval : slot=%lx, va=%016lx, psize: %d, local: %d\n",
 		slot, va, psize, local);
-	want_v = hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M);
+	want_v = hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
 
 	raw_spin_lock_irqsave(&beat_htab_lock, flags);
 	dummy1 = beat_lpar_hpte_getword0(slot);
@@ -372,7 +372,7 @@ static long beat_lpar_hpte_updatepp_v3(unsigned long slot,
 	unsigned long want_v;
 	unsigned long pss;
 
-	want_v = hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M);
+	want_v = hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
 	pss = (psize == MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc;
 
 	DBG_LOW("    update: "
@@ -402,7 +402,7 @@ static void beat_lpar_hpte_invalidate_v3(unsigned long slot, unsigned long vpn,
 
 	DBG_LOW("    inval : slot=%lx, vpn=%016lx, psize: %d, local: %d\n",
 		slot, vpn, psize, local);
-	want_v = hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M);
+	want_v = hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
 	pss = (psize == MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc;
 
 	lpar_rc = beat_invalidate_htab_entry3(0, slot, want_v, pss);
diff --git a/arch/powerpc/platforms/ps3/htab.c b/arch/powerpc/platforms/ps3/htab.c
index 6cc5820..cd8f2fb 100644
--- a/arch/powerpc/platforms/ps3/htab.c
+++ b/arch/powerpc/platforms/ps3/htab.c
@@ -117,7 +117,7 @@ static long ps3_hpte_updatepp(unsigned long slot, unsigned long newpp,
 	unsigned long flags;
 	long ret;
 
-	want_v = hpte_encode_v(vpn, psize, ssize);
+	want_v = hpte_encode_avpn(vpn, psize, ssize);
 
 	spin_lock_irqsave(&ps3_htab_lock, flags);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
