Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C80EC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:34:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A720020859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:34:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A720020859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10FB76B026A; Mon, 10 Jun 2019 12:34:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C0A16B026B; Mon, 10 Jun 2019 12:34:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECA5B6B026C; Mon, 10 Jun 2019 12:34:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86A7F6B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:34:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k15so16167665eda.6
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:34:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=bY0/2nRftqCxRB5W9FeGiz6/yyko7/PRKDpLO3Qafs8=;
        b=bcJ2nArMpRfHIfqMQlIbl8HJA839OsTVuo0JhUSVJJqi3ssAgYADOhdv+UBZO1HMJ5
         6/9tjGMgVv9GMv7bVp4r0TVNTszWK7prR8VmlHD2RgfTAeIKQcCTOXlYoOXUIUEoX5gH
         /MkdZYiwC4UkRWIZbXP9i+MRZWu6qxXQRimbDxH365Xg4VG1nn025+psvlg3Lob6GB9M
         yxawjE+55ureDeJX/DSTB22PZ16rWBLi3RKj+DF/a5IZVSlEZpmQqYfZ7wKlRnKDj7p/
         4dfKfRVYQ7sSmr9CU71OlFiMQj25ltDOhh9NZ59UAnQXj1NTYD4NqVv6RMnR8JNub9XA
         PkUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWe+dZe6itWVp3lajsTyEynngWk0xDZkGvOyVwmUNiKnWxTXItF
	aj8SNOv5MgRacy4/sZlIqy0OdL93+cXbLH39DEbES/6zr860HRQn0Am2uLxYGiT/QceSur+7Rbt
	xDypjao/7Js0ZXoLYenBENS/ZsqmLjRYx5zkImGAHERv5uPaJj2h0i+Azy0o864r9bA==
X-Received: by 2002:a50:e611:: with SMTP id y17mr74205941edm.222.1560184447776;
        Mon, 10 Jun 2019 09:34:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu0MxDL4m4qUQsrKuQzbttmuhn975gaGlVoDAmMwwhlqt49swu+VvtD7b6nlLsq41UUvhZ
X-Received: by 2002:a50:e611:: with SMTP id y17mr74205792edm.222.1560184445969;
        Mon, 10 Jun 2019 09:34:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560184445; cv=none;
        d=google.com; s=arc-20160816;
        b=xdVdHllpZl+jMbqBdUwpZ0c4kNCyzJBgnb4+atuo09DgssV2krd8SBD9Xvtj/neVan
         oBTJOtTG8hB4ZzxXCk6ttHGTTTcCxbQiyvMfEMtWB0+ZxXGXBfj4XemEqo2A0F+gOGtu
         RduurcjRDhOc//xyb/xGSn8ubRWRWIFFSH9rM1h2yU+1P53g1U3Mu1OSrsuld+wBqcVt
         UGd/eyhijpQe+yMFGYLtDvGZXFO0kTq1umkuPwSzZ5qWaLEobA8GjrABdX1FfhrqAu2X
         imoAQDp34BQvJhPBh/SIOIurWrHv/m58tv4C1qy4yA7rgXEpMH/PxQ6LV4i/EbY5BC8s
         Nf3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=bY0/2nRftqCxRB5W9FeGiz6/yyko7/PRKDpLO3Qafs8=;
        b=y1H0pgtFzlL+8yEvCvdaSpUyizL3I6+GCQKe4FvlFN7yk/S1dPm/MvapOqRMtMbHSm
         Lw6WWdGx6ZhLgaSpIzNlGCNPOzPrw0O/ixv2Ui125xZfp+8KOWYp3AKiZYe+JI1T8F1u
         CYGVh8Ibsi4AYW/6yGg1sgeBpnR9eLlXJC1swM0K0yiAoye5aASf1qR4UxUY7loL2+v+
         k1FV9JR/7OjK6gVMGvf/2jQv5aQgmfxk338vKQaQNUmPBtFSZqwJTLG5SfXe3IClSPeN
         dH9XidhCX30BDhGB2pHxdCM1dgC6Fok3g2rwxo4AzPNpR17ruUsAyr/FmdQ0uYxuwLiC
         Ocsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id i12si3067982edq.333.2019.06.10.09.34.05
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 09:34:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7125A346;
	Mon, 10 Jun 2019 09:34:04 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 36C063F246;
	Mon, 10 Jun 2019 09:34:03 -0700 (PDT)
From: Mark Rutland <mark.rutland@arm.com>
To: linux-kernel@vger.kernel.org
Cc: Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	Yu Zhao <yuzhao@google.com>,
	linux-mm@kvack.org
Subject: [PATCH] mm: treewide: Clarify pgtable_page_{ctor,dtor}() naming
Date: Mon, 10 Jun 2019 17:33:54 +0100
Message-Id: <20190610163354.24835-1-mark.rutland@arm.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The naming of pgtable_page_{ctor,dtor}() seems to have confused a few
people, and until recently arm64 used these erroneously/pointlessly for
other levels of pagetable.

To make it incredibly clear that these only apply to the PTE level, and
to align with the naming of pgtable_pmd_page_{ctor,dtor}(), let's rename
them to pgtable_pte_page_{ctor,dtor}().

The bulk of this conversion was performed by the below Coccinelle
semantic patch, with manual whitespace fixups applied within macros, and
Documentation updated by hand.

----
virtual patch

@ depends on patch @
@@

- pgtable_page_ctor
+ pgtable_pte_page_ctor

@ depends on patch @
@@

- pgtable_page_dtor
+ pgtable_pte_page_dtor
----

There should be no functional change as a result of this patch.

Signed-off-by: Mark Rutland <mark.rutland@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Yu Zhao <yuzhao@google.com>
Cc: linux-mm@kvack.org
---
 Documentation/vm/split_page_table_lock.rst | 10 +++++-----
 arch/alpha/include/asm/pgalloc.h           |  4 ++--
 arch/arc/include/asm/pgalloc.h             |  4 ++--
 arch/arm/include/asm/pgalloc.h             |  4 ++--
 arch/arm/include/asm/tlb.h                 |  2 +-
 arch/arm/mm/mmu.c                          |  2 +-
 arch/arm64/include/asm/pgalloc.h           |  4 ++--
 arch/arm64/include/asm/tlb.h               |  2 +-
 arch/arm64/mm/mmu.c                        |  2 +-
 arch/csky/include/asm/pgalloc.h            |  6 +++---
 arch/hexagon/include/asm/pgalloc.h         |  6 +++---
 arch/ia64/include/asm/pgalloc.h            |  4 ++--
 arch/m68k/include/asm/mcf_pgalloc.h        |  6 +++---
 arch/m68k/include/asm/motorola_pgalloc.h   |  6 +++---
 arch/m68k/include/asm/sun3_pgalloc.h       |  6 +++---
 arch/microblaze/include/asm/pgalloc.h      |  4 ++--
 arch/mips/include/asm/pgalloc.h            |  6 +++---
 arch/nios2/include/asm/pgalloc.h           |  6 +++---
 arch/openrisc/include/asm/pgalloc.h        |  6 +++---
 arch/parisc/include/asm/pgalloc.h          |  4 ++--
 arch/powerpc/mm/pgtable-frag.c             |  6 +++---
 arch/riscv/include/asm/pgalloc.h           |  6 +++---
 arch/s390/mm/pgalloc.c                     |  6 +++---
 arch/sh/include/asm/pgalloc.h              |  6 +++---
 arch/sparc/mm/init_64.c                    |  4 ++--
 arch/sparc/mm/srmmu.c                      |  4 ++--
 arch/um/include/asm/pgalloc.h              |  4 ++--
 arch/um/kernel/mem.c                       |  2 +-
 arch/unicore32/include/asm/pgalloc.h       |  4 ++--
 arch/unicore32/include/asm/tlb.h           |  2 +-
 arch/x86/include/asm/pgalloc.h             |  2 +-
 arch/x86/mm/pgtable.c                      |  4 ++--
 arch/xtensa/include/asm/pgalloc.h          |  4 ++--
 include/linux/mm.h                         |  4 ++--
 34 files changed, 76 insertions(+), 76 deletions(-)

diff --git a/Documentation/vm/split_page_table_lock.rst b/Documentation/vm/split_page_table_lock.rst
index 889b00be469f..73216676479a 100644
--- a/Documentation/vm/split_page_table_lock.rst
+++ b/Documentation/vm/split_page_table_lock.rst
@@ -54,8 +54,8 @@ Hugetlb-specific helpers:
 Support of split page table lock by an architecture
 ===================================================
 
-There's no need in special enabling of PTE split page table lock:
-everything required is done by pgtable_page_ctor() and pgtable_page_dtor(),
+There's no need in special enabling of PTE split page table lock: everything
+required is done by pgtable_pte_page_ctor() and pgtable_pte_page_dtor(),
 which must be called on PTE table allocation / freeing.
 
 Make sure the architecture doesn't use slab allocator for page table
@@ -74,8 +74,8 @@ paths: i.e X86_PAE preallocate few PMDs on pgd_alloc().
 
 With everything in place you can set CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK.
 
-NOTE: pgtable_page_ctor() and pgtable_pmd_page_ctor() can fail -- it must
-be handled properly.
+NOTE: pgtable_pte_page_ctor() and pgtable_pmd_page_ctor() can fail -- it
+must be handled properly.
 
 page->ptl
 =========
@@ -94,7 +94,7 @@ trick:
    split lock with enabled DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC, but costs
    one more cache line for indirect access;
 
-The spinlock_t allocated in pgtable_page_ctor() for PTE table and in
+The spinlock_t allocated in pgtable_pte_page_ctor() for PTE table and in
 pgtable_pmd_page_ctor() for PMD table.
 
 Please, never access page->ptl directly -- use appropriate helper.
diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgalloc.h
index 02f9f91bb4f0..4d051c29a8f0 100644
--- a/arch/alpha/include/asm/pgalloc.h
+++ b/arch/alpha/include/asm/pgalloc.h
@@ -73,7 +73,7 @@ pte_alloc_one(struct mm_struct *mm)
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
@@ -83,7 +83,7 @@ pte_alloc_one(struct mm_struct *mm)
 static inline void
 pte_free(struct mm_struct *mm, pgtable_t page)
 {
-	pgtable_page_dtor(page);
+	pgtable_pte_page_dtor(page);
 	__free_page(page);
 }
 
diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.h
index 9c9b5a5ebf2e..a42450eebc17 100644
--- a/arch/arc/include/asm/pgalloc.h
+++ b/arch/arc/include/asm/pgalloc.h
@@ -111,7 +111,7 @@ pte_alloc_one(struct mm_struct *mm)
 		return 0;
 	memzero((void *)pte_pg, PTRS_PER_PTE * sizeof(pte_t));
 	page = virt_to_page(pte_pg);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return 0;
 	}
@@ -126,7 +126,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t ptep)
 {
-	pgtable_page_dtor(virt_to_page(ptep));
+	pgtable_pte_page_dtor(virt_to_page(ptep));
 	free_pages((unsigned long)ptep, __get_order_pte());
 }
 
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 17ab72f0cc4e..0d8eaf0f7597 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -106,7 +106,7 @@ pte_alloc_one(struct mm_struct *mm)
 		return NULL;
 	if (!PageHighMem(pte))
 		clean_pte_table(page_address(pte));
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
@@ -124,7 +124,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 
diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index bc6d04a09899..ec09acf8a80f 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -47,7 +47,7 @@ static inline void __tlb_remove_table(void *_table)
 static inline void
 __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned long addr)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 
 #ifndef CONFIG_ARM_LPAE
 	/*
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index f3ce34113f89..37d28e34fc70 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -734,7 +734,7 @@ static void *__init late_alloc(unsigned long sz)
 {
 	void *ptr = (void *)__get_free_pages(PGALLOC_GFP, get_order(sz));
 
-	if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
+	if (!ptr || !pgtable_pte_page_ctor(virt_to_page(ptr)))
 		BUG();
 	return ptr;
 }
diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index dabba4b2c61f..6193adbc8adc 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -114,7 +114,7 @@ pte_alloc_one(struct mm_struct *mm)
 	pte = alloc_pages(PGALLOC_GFP, 0);
 	if (!pte)
 		return NULL;
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
@@ -132,7 +132,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *ptep)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index a287189ca8b4..437225d8565d 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -55,7 +55,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 				  unsigned long addr)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	tlb_remove_table(tlb, pte);
 }
 
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index a1bfc4413982..0aa04036dfaa 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -394,7 +394,7 @@ static phys_addr_t pgd_pgtable_alloc(int shift)
 	 * folded, and if so pgtable_pmd_page_ctor() becomes nop.
 	 */
 	if (shift == PAGE_SHIFT)
-		BUG_ON(!pgtable_page_ctor(phys_to_page(pa)));
+		BUG_ON(!pgtable_pte_page_ctor(phys_to_page(pa)));
 	else if (shift == PMD_SHIFT)
 		BUG_ON(!pgtable_pmd_page_ctor(phys_to_page(pa)));
 
diff --git a/arch/csky/include/asm/pgalloc.h b/arch/csky/include/asm/pgalloc.h
index d213bb47b717..aea9a96072bc 100644
--- a/arch/csky/include/asm/pgalloc.h
+++ b/arch/csky/include/asm/pgalloc.h
@@ -47,7 +47,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
 	if (!pte)
 		return NULL;
 
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
@@ -62,7 +62,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_pages(pte, PTE_ORDER);
 }
 
@@ -95,7 +95,7 @@ static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 
 #define __pte_free_tlb(tlb, pte, address)		\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);			\
 	tlb_remove_page(tlb, pte);			\
 } while (0)
 
diff --git a/arch/hexagon/include/asm/pgalloc.h b/arch/hexagon/include/asm/pgalloc.h
index d36183887b60..b05dcc50fa07 100644
--- a/arch/hexagon/include/asm/pgalloc.h
+++ b/arch/hexagon/include/asm/pgalloc.h
@@ -66,7 +66,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
 	pte = alloc_page(GFP_KERNEL | __GFP_ZERO);
 	if (!pte)
 		return NULL;
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
@@ -82,7 +82,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 
@@ -139,7 +139,7 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 
 #define __pte_free_tlb(tlb, pte, addr)		\
 do {						\
-	pgtable_page_dtor((pte));		\
+	pgtable_pte_page_dtor((pte));		\
 	tlb_remove_page((tlb), (pte));		\
 } while (0)
 
diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index c9e481023c25..70db524b75a6 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -92,7 +92,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 	if (!pg)
 		return NULL;
 	page = virt_to_page(pg);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		quicklist_free(0, NULL, pg);
 		return NULL;
 	}
@@ -106,7 +106,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	quicklist_free_page(0, NULL, pte);
 }
 
diff --git a/arch/m68k/include/asm/mcf_pgalloc.h b/arch/m68k/include/asm/mcf_pgalloc.h
index 4399d712f6db..b34d44d666a4 100644
--- a/arch/m68k/include/asm/mcf_pgalloc.h
+++ b/arch/m68k/include/asm/mcf_pgalloc.h
@@ -41,7 +41,7 @@ extern inline pmd_t *pmd_alloc_kernel(pgd_t *pgd, unsigned long address)
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
 				  unsigned long address)
 {
-	pgtable_page_dtor(page);
+	pgtable_pte_page_dtor(page);
 	__free_page(page);
 }
 
@@ -54,7 +54,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
 
 	if (!page)
 		return NULL;
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
@@ -73,7 +73,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
 
 static inline void pte_free(struct mm_struct *mm, struct page *page)
 {
-	pgtable_page_dtor(page);
+	pgtable_pte_page_dtor(page);
 	__free_page(page);
 }
 
diff --git a/arch/m68k/include/asm/motorola_pgalloc.h b/arch/m68k/include/asm/motorola_pgalloc.h
index d04d9ba9b976..acab315c851f 100644
--- a/arch/m68k/include/asm/motorola_pgalloc.h
+++ b/arch/m68k/include/asm/motorola_pgalloc.h
@@ -36,7 +36,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 	page = alloc_pages(GFP_KERNEL|__GFP_ZERO, 0);
 	if(!page)
 		return NULL;
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
@@ -51,7 +51,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t page)
 {
-	pgtable_page_dtor(page);
+	pgtable_pte_page_dtor(page);
 	cache_page(kmap(page));
 	kunmap(page);
 	__free_page(page);
@@ -60,7 +60,7 @@ static inline void pte_free(struct mm_struct *mm, pgtable_t page)
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
 				  unsigned long address)
 {
-	pgtable_page_dtor(page);
+	pgtable_pte_page_dtor(page);
 	cache_page(kmap(page));
 	kunmap(page);
 	__free_page(page);
diff --git a/arch/m68k/include/asm/sun3_pgalloc.h b/arch/m68k/include/asm/sun3_pgalloc.h
index 1456c5eecbd9..1fab59df526a 100644
--- a/arch/m68k/include/asm/sun3_pgalloc.h
+++ b/arch/m68k/include/asm/sun3_pgalloc.h
@@ -25,13 +25,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t page)
 {
-	pgtable_page_dtor(page);
+	pgtable_pte_page_dtor(page);
         __free_page(page);
 }
 
 #define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);			\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
@@ -54,7 +54,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 		return NULL;
 
 	clear_highpage(page);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
diff --git a/arch/microblaze/include/asm/pgalloc.h b/arch/microblaze/include/asm/pgalloc.h
index f4cc9ffc449e..4676ad76ff03 100644
--- a/arch/microblaze/include/asm/pgalloc.h
+++ b/arch/microblaze/include/asm/pgalloc.h
@@ -124,7 +124,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
 	if (!ptepage)
 		return NULL;
 	clear_highpage(ptepage);
-	if (!pgtable_page_ctor(ptepage)) {
+	if (!pgtable_pte_page_ctor(ptepage)) {
 		__free_page(ptepage);
 		return NULL;
 	}
@@ -150,7 +150,7 @@ static inline void pte_free_slow(struct page *ptepage)
 
 static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
-	pgtable_page_dtor(ptepage);
+	pgtable_pte_page_dtor(ptepage);
 	__free_page(ptepage);
 }
 
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index 27808d9461f4..e15e456d5422 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -63,7 +63,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
 	if (!pte)
 		return NULL;
 	clear_highpage(pte);
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
@@ -77,13 +77,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_pages(pte, PTE_ORDER);
 }
 
 #define __pte_free_tlb(tlb,pte,address)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);			\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
diff --git a/arch/nios2/include/asm/pgalloc.h b/arch/nios2/include/asm/pgalloc.h
index 3a149ead1207..8152a993614d 100644
--- a/arch/nios2/include/asm/pgalloc.h
+++ b/arch/nios2/include/asm/pgalloc.h
@@ -52,7 +52,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 
 	pte = alloc_pages(GFP_KERNEL, PTE_ORDER);
 	if (pte) {
-		if (!pgtable_page_ctor(pte)) {
+		if (!pgtable_pte_page_ctor(pte)) {
 			__free_page(pte);
 			return NULL;
 		}
@@ -68,13 +68,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_pages(pte, PTE_ORDER);
 }
 
 #define __pte_free_tlb(tlb, pte, addr)				\
 	do {							\
-		pgtable_page_dtor(pte);				\
+		pgtable_pte_page_dtor(pte);			\
 		tlb_remove_page((tlb), (pte));			\
 	} while (0)
 
diff --git a/arch/openrisc/include/asm/pgalloc.h b/arch/openrisc/include/asm/pgalloc.h
index 3d4b397c2d06..7a3185d87935 100644
--- a/arch/openrisc/include/asm/pgalloc.h
+++ b/arch/openrisc/include/asm/pgalloc.h
@@ -75,7 +75,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
 	if (!pte)
 		return NULL;
 	clear_page(page_address(pte));
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
@@ -89,13 +89,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 
 #define __pte_free_tlb(tlb, pte, addr)	\
 do {					\
-	pgtable_page_dtor(pte);		\
+	pgtable_pte_page_dtor(pte);	\
 	tlb_remove_page((tlb), (pte));	\
 } while (0)
 
diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index ea75cc966dae..d4d63147db6f 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -128,7 +128,7 @@ pte_alloc_one(struct mm_struct *mm)
 	struct page *page = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	if (!page)
 		return NULL;
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
@@ -149,7 +149,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	pte_free_kernel(mm, page_address(pte));
 }
 
diff --git a/arch/powerpc/mm/pgtable-frag.c b/arch/powerpc/mm/pgtable-frag.c
index a7b05214760c..ee4bd6d38602 100644
--- a/arch/powerpc/mm/pgtable-frag.c
+++ b/arch/powerpc/mm/pgtable-frag.c
@@ -25,7 +25,7 @@ void pte_frag_destroy(void *pte_frag)
 	count = ((unsigned long)pte_frag & ~PAGE_MASK) >> PTE_FRAG_SIZE_SHIFT;
 	/* We allow PTE_FRAG_NR fragments from a PTE page */
 	if (atomic_sub_and_test(PTE_FRAG_NR - count, &page->pt_frag_refcount)) {
-		pgtable_page_dtor(page);
+		pgtable_pte_page_dtor(page);
 		__free_page(page);
 	}
 }
@@ -61,7 +61,7 @@ static pte_t *__alloc_for_ptecache(struct mm_struct *mm, int kernel)
 		page = alloc_page(PGALLOC_GFP | __GFP_ACCOUNT);
 		if (!page)
 			return NULL;
-		if (!pgtable_page_ctor(page)) {
+		if (!pgtable_pte_page_ctor(page)) {
 			__free_page(page);
 			return NULL;
 		}
@@ -113,7 +113,7 @@ void pte_fragment_free(unsigned long *table, int kernel)
 	BUG_ON(atomic_read(&page->pt_frag_refcount) <= 0);
 	if (atomic_dec_and_test(&page->pt_frag_refcount)) {
 		if (!kernel)
-			pgtable_page_dtor(page);
+			pgtable_pte_page_dtor(page);
 		__free_page(page);
 	}
 }
diff --git a/arch/riscv/include/asm/pgalloc.h b/arch/riscv/include/asm/pgalloc.h
index 94043cf83c90..1809bf96fb8e 100644
--- a/arch/riscv/include/asm/pgalloc.h
+++ b/arch/riscv/include/asm/pgalloc.h
@@ -94,7 +94,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
 
 	pte = alloc_page(GFP_KERNEL | __GFP_RETRY_MAYFAIL | __GFP_ZERO);
 	if (likely(pte != NULL))
-		pgtable_page_ctor(pte);
+		pgtable_pte_page_ctor(pte);
 	return pte;
 }
 
@@ -105,13 +105,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 
 #define __pte_free_tlb(tlb, pte, buf)   \
 do {                                    \
-	pgtable_page_dtor(pte);         \
+	pgtable_pte_page_dtor(pte);     \
 	tlb_remove_page((tlb), pte);    \
 } while (0)
 
diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
index 99e06213a22b..962d32497912 100644
--- a/arch/s390/mm/pgalloc.c
+++ b/arch/s390/mm/pgalloc.c
@@ -212,7 +212,7 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
 	page = alloc_page(GFP_KERNEL);
 	if (!page)
 		return NULL;
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
@@ -258,7 +258,7 @@ void page_table_free(struct mm_struct *mm, unsigned long *table)
 		atomic_xor_bits(&page->_refcount, 3U << 24);
 	}
 
-	pgtable_page_dtor(page);
+	pgtable_pte_page_dtor(page);
 	__free_page(page);
 }
 
@@ -310,7 +310,7 @@ void __tlb_remove_table(void *_table)
 	case 3:		/* 4K page table with pgstes */
 		if (mask & 3)
 			atomic_xor_bits(&page->_refcount, 3 << 24);
-		pgtable_page_dtor(page);
+		pgtable_pte_page_dtor(page);
 		__free_page(page);
 		break;
 	}
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index b56f908b1395..473a46fb78fe 100644
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -46,7 +46,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 	if (!pg)
 		return NULL;
 	page = virt_to_page(pg);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		quicklist_free(QUICK_PT, NULL, pg);
 		return NULL;
 	}
@@ -60,13 +60,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
 
 #define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);			\
 	tlb_remove_page((tlb), (pte));			\
 } while (0)
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 4b099dd7a767..e6d91819da92 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2903,7 +2903,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm)
 	struct page *page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 	if (!page)
 		return NULL;
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		free_unref_page(page);
 		return NULL;
 	}
@@ -2919,7 +2919,7 @@ static void __pte_free(pgtable_t pte)
 {
 	struct page *page = virt_to_page(pte);
 
-	pgtable_page_dtor(page);
+	pgtable_pte_page_dtor(page);
 	__free_page(page);
 }
 
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index aaebbc00d262..cc3ad64479ac 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -378,7 +378,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm)
 	if ((pte = (unsigned long)pte_alloc_one_kernel(mm)) == 0)
 		return NULL;
 	page = pfn_to_page(__nocache_pa(pte) >> PAGE_SHIFT);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
@@ -389,7 +389,7 @@ void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
 	unsigned long p;
 
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	p = (unsigned long)page_address(pte);	/* Cached address (for test) */
 	if (p == 0)
 		BUG();
diff --git a/arch/um/include/asm/pgalloc.h b/arch/um/include/asm/pgalloc.h
index 99eb5682792a..71f76d62f7a7 100644
--- a/arch/um/include/asm/pgalloc.h
+++ b/arch/um/include/asm/pgalloc.h
@@ -35,13 +35,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 
 #define __pte_free_tlb(tlb,pte, address)		\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);				\
 	tlb_remove_page((tlb),(pte));			\
 } while (0)
 
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index a9c9a94c096f..66553648d533 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -223,7 +223,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm)
 	pte = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	if (!pte)
 		return NULL;
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
diff --git a/arch/unicore32/include/asm/pgalloc.h b/arch/unicore32/include/asm/pgalloc.h
index 7cceabecf4e3..d02c71efae06 100644
--- a/arch/unicore32/include/asm/pgalloc.h
+++ b/arch/unicore32/include/asm/pgalloc.h
@@ -57,7 +57,7 @@ pte_alloc_one(struct mm_struct *mm)
 		void *page = page_address(pte);
 		clean_dcache_area(page, PTRS_PER_PTE * sizeof(pte_t));
 	}
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 	}
 
@@ -75,7 +75,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 
diff --git a/arch/unicore32/include/asm/tlb.h b/arch/unicore32/include/asm/tlb.h
index 00a8477333f6..4aa6e0d78254 100644
--- a/arch/unicore32/include/asm/tlb.h
+++ b/arch/unicore32/include/asm/tlb.h
@@ -18,7 +18,7 @@
 
 #define __pte_free_tlb(tlb, pte, addr)				\
 	do {							\
-		pgtable_page_dtor(pte);				\
+		pgtable_pte_page_dtor(pte);			\
 		tlb_remove_page((tlb), (pte));			\
 	} while (0)
 
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index a281e61ec60c..490d0c76bb5b 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -61,7 +61,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 1f67b1e15bf6..85ec80b037c8 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -35,7 +35,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm)
 	pte = alloc_pages(__userpte_alloc_gfp, 0);
 	if (!pte)
 		return NULL;
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
@@ -61,7 +61,7 @@ early_param("userpte", setup_userpte);
 
 void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	paravirt_release_pte(page_to_pfn(pte));
 	paravirt_tlb_remove_table(tlb, pte);
 }
diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
index 368284c972e7..d91126f080b4 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -58,7 +58,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
@@ -72,7 +72,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 #define pmd_pgtable(pmd) pmd_page(pmd)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..6529ebdd9c98 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1989,7 +1989,7 @@ static inline void pgtable_init(void)
 	pgtable_cache_init();
 }
 
-static inline bool pgtable_page_ctor(struct page *page)
+static inline bool pgtable_pte_page_ctor(struct page *page)
 {
 	if (!ptlock_init(page))
 		return false;
@@ -1998,7 +1998,7 @@ static inline bool pgtable_page_ctor(struct page *page)
 	return true;
 }
 
-static inline void pgtable_page_dtor(struct page *page)
+static inline void pgtable_pte_page_dtor(struct page *page)
 {
 	ptlock_free(page);
 	__ClearPageTable(page);
-- 
2.11.0

