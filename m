Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1006B003B
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 04:28:39 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so3317528pdi.24
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 01:28:38 -0800 (PST)
Received: from psmtp.com ([74.125.245.115])
        by mx.google.com with SMTP id bq8si9163637pab.87.2013.11.18.01.28.35
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 01:28:36 -0800 (PST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 18 Nov 2013 19:28:31 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 2CD30357805A
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:29 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAI9SCZT9044358
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:17 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAI9SNW6019661
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:23 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 1/5] powerpc: Use HPTE constants when updating hpte bits
Date: Mon, 18 Nov 2013 14:58:09 +0530
Message-Id: <1384766893-10189-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Even though we have same value for linux PTE bits and hash PTE pits
use the hash pte bits wen updating hash pte

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/platforms/cell/beat_htab.c | 4 ++--
 arch/powerpc/platforms/pseries/lpar.c   | 3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/platforms/cell/beat_htab.c b/arch/powerpc/platforms/cell/beat_htab.c
index c34ee4e60873..d4d245c0d787 100644
--- a/arch/powerpc/platforms/cell/beat_htab.c
+++ b/arch/powerpc/platforms/cell/beat_htab.c
@@ -111,7 +111,7 @@ static long beat_lpar_hpte_insert(unsigned long hpte_group,
 		DBG_LOW(" hpte_v=%016lx, hpte_r=%016lx\n", hpte_v, hpte_r);
 
 	if (rflags & _PAGE_NO_CACHE)
-		hpte_r &= ~_PAGE_COHERENT;
+		hpte_r &= ~HPTE_R_M;
 
 	raw_spin_lock(&beat_htab_lock);
 	lpar_rc = beat_read_mask(hpte_group);
@@ -337,7 +337,7 @@ static long beat_lpar_hpte_insert_v3(unsigned long hpte_group,
 		DBG_LOW(" hpte_v=%016lx, hpte_r=%016lx\n", hpte_v, hpte_r);
 
 	if (rflags & _PAGE_NO_CACHE)
-		hpte_r &= ~_PAGE_COHERENT;
+		hpte_r &= ~HPTE_R_M;
 
 	/* insert into not-volted entry */
 	lpar_rc = beat_insert_htab_entry3(0, hpte_group, hpte_v, hpte_r,
diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
index 356bc75ca74f..c8fbef238d4b 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -153,7 +153,8 @@ static long pSeries_lpar_hpte_insert(unsigned long hpte_group,
 
 	/* Make pHyp happy */
 	if ((rflags & _PAGE_NO_CACHE) && !(rflags & _PAGE_WRITETHRU))
-		hpte_r &= ~_PAGE_COHERENT;
+		hpte_r &= ~HPTE_R_M;
+
 	if (firmware_has_feature(FW_FEATURE_XCMO) && !(hpte_r & HPTE_R_N))
 		flags |= H_COALESCE_CAND;
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
