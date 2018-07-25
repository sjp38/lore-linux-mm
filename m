Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5B4B6B0291
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 11:53:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w18-v6so5675412plp.3
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:53:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5-v6sor4879475plr.67.2018.07.25.08.53.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 08:53:03 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 3/4] mm: zap_pte_range optimise fullmm handling for dirty shared pages
Date: Thu, 26 Jul 2018 01:52:45 +1000
Message-Id: <20180725155246.1085-4-npiggin@gmail.com>
In-Reply-To: <20180725155246.1085-1-npiggin@gmail.com>
References: <20180725155246.1085-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-arch@vger.kernel.org

Shared dirty pages do not need to be flushed under page table lock
for the fullmm case, because there will be no subsequent access
through the TLBs.
---
 mm/memory.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 1161ed3f1d0b..490689909186 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1322,8 +1322,18 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 
 			if (!PageAnon(page)) {
 				if (pte_dirty(ptent)) {
-					force_flush = 1;
-					locked_flush = 1;
+					/*
+					 * Page must be flushed from TLBs
+					 * before releasing PTL to synchronize
+					 * with page_mkclean and avoid another
+					 * thread writing to the page through
+					 * the old TLB after it was marked
+					 * clean.
+					 */
+					if (!tlb->fullmm) {
+						force_flush = 1;
+						locked_flush = 1;
+					}
 					set_page_dirty(page);
 				}
 				if (pte_young(ptent) &&
-- 
2.17.0
