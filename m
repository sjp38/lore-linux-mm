Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4BE88E000F
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:55:01 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t1-v6so1517092plz.17
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:55:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n28-v6si4679006pfg.127.2018.09.26.04.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 04:55:00 -0700 (PDT)
Message-ID: <20180926114801.468888082@infradead.org>
Date: Wed, 26 Sep 2018 13:36:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 18/18] asm-generic/tlb: Remove tlb_table_flush()
References: <20180926113623.863696043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com

There are no external users of this API (nor should there be); remove it.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/tlb.h |    1 -
 mm/mmu_gather.c           |   34 +++++++++++++++++-----------------
 2 files changed, 17 insertions(+), 18 deletions(-)

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -174,7 +174,6 @@ struct mmu_table_batch {
 #define MAX_TABLE_BATCH		\
 	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
 
-extern void tlb_table_flush(struct mmu_gather *tlb);
 extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
 
 #endif
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -91,22 +91,6 @@ bool __tlb_remove_page_size(struct mmu_g
 
 #endif /* HAVE_MMU_GATHER_NO_GATHER */
 
-static void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb_table_flush(tlb);
-#endif
-#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
-	tlb_batch_pages_flush(tlb);
-#endif
-}
-
-void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
-
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 
 /*
@@ -159,7 +143,7 @@ static void tlb_remove_table_rcu(struct
 	free_page((unsigned long)batch);
 }
 
-void tlb_table_flush(struct mmu_gather *tlb)
+static void tlb_table_flush(struct mmu_gather *tlb)
 {
 	struct mmu_table_batch **batch = &tlb->batch;
 
@@ -191,6 +175,22 @@ void tlb_remove_table(struct mmu_gather
 
 #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 
+static void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb_table_flush(tlb);
+#endif
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb_batch_pages_flush(tlb);
+#endif
+}
+
+void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	tlb_flush_mmu_tlbonly(tlb);
+	tlb_flush_mmu_free(tlb);
+}
+
 /**
  * tlb_gather_mmu - initialize an mmu_gather structure for page-table tear-down
  * @tlb: the mmu_gather structure to initialize
