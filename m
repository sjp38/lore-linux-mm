Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30A9C6B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:14:02 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g6-v6so18199436plo.0
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:14:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i69-v6sor4614927pge.17.2018.10.16.06.14.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 06:14:01 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH v2 1/5] nios2: update_mmu_cache clear the old entry from the TLB
Date: Tue, 16 Oct 2018 23:13:39 +1000
Message-Id: <20181016131343.20556-2-npiggin@gmail.com>
In-Reply-To: <20181016131343.20556-1-npiggin@gmail.com>
References: <20181016131343.20556-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, Ley Foon Tan <ley.foon.tan@intel.com>

Fault paths like do_read_fault will install a Linux pte with the young
bit clear. The CPU will fault again because the TLB has not been
updated, this time a valid pte exists so handle_pte_fault will just
set the young bit with ptep_set_access_flags, which flushes the TLB.

The TLB is flushed so the next attempt will go to the fast TLB handler
which loads the TLB with the new Linux pte. The access then proceeds.

This design is fragile to depend on the young bit being clear after
the initial Linux fault. A proposed core mm change to immediately set
the young bit upon such a fault, results in ptep_set_access_flags not
flushing the TLB because it finds no change to the pte. The spurious
fault fix path only flushes the TLB if the access was a store. If it
was a load, then this results in an infinite loop of page faults.

This change adds a TLB flush in update_mmu_cache, which removes that
TLB entry upon the first fault. This will cause the fast TLB handler
to load the new pte and avoid the Linux page fault entirely.

Reviewed-by: Ley Foon Tan <ley.foon.tan@intel.com>
Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/nios2/mm/cacheflush.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/nios2/mm/cacheflush.c b/arch/nios2/mm/cacheflush.c
index 506f6e1c86d5..d58e7e80dc0d 100644
--- a/arch/nios2/mm/cacheflush.c
+++ b/arch/nios2/mm/cacheflush.c
@@ -204,6 +204,8 @@ void update_mmu_cache(struct vm_area_struct *vma,
 	struct page *page;
 	struct address_space *mapping;
 
+	flush_tlb_page(vma, address);
+
 	if (!pfn_valid(pfn))
 		return;
 
-- 
2.18.0
