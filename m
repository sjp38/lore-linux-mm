Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4CD66B0287
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 11:52:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u16-v6so1000674pfm.15
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:52:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m125-v6sor4033155pgm.6.2018.07.25.08.52.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 08:52:58 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 1/4] mm: munmap optimise single threaded page freeing
Date: Thu, 26 Jul 2018 01:52:43 +1000
Message-Id: <20180725155246.1085-2-npiggin@gmail.com>
In-Reply-To: <20180725155246.1085-1-npiggin@gmail.com>
References: <20180725155246.1085-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-arch@vger.kernel.org

In case a single threaded process is zapping its own mappings, there
should be no concurrent memory accesses through the TLBs, and so it
is safe to free pages immediately rather than batch them up.
---
 mm/memory.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 135d18b31e44..773d588b371d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -296,6 +296,15 @@ bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_
 	VM_BUG_ON(!tlb->end);
 	VM_WARN_ON(tlb->page_size != page_size);
 
+	/*
+	 * When this is our mm and there are no other users, there can not be
+	 * a concurrent memory access.
+	 */
+	if (current->mm == tlb->mm && atomic_read(&tlb->mm->mm_users) < 2) {
+		free_page_and_swap_cache(page);
+		return false;
+	}
+
 	batch = tlb->active;
 	/*
 	 * Add the page and check if we are full. If so
-- 
2.17.0
