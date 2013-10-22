Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA9D6B03B8
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 07:41:18 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fa1so9675940pad.9
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 04:41:18 -0700 (PDT)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id z1si11389714pbw.249.2013.10.22.04.41.16
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 04:41:17 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 17:11:12 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6532795854F
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:00:06 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBSUhi44499126
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:32 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSXIh023012
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:33 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 1/9] powerpc: Use HPTE constants when updating hpte bits
Date: Tue, 22 Oct 2013 16:58:12 +0530
Message-Id: <1382441300-1513-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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
index c34ee4e..d4d245c 100644
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
index 356bc75..c8fbef23 100644
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
