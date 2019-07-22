Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 599FFC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 14:11:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D32DF21911
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 14:11:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D32DF21911
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 320866B0003; Mon, 22 Jul 2019 10:11:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D31C6B0005; Mon, 22 Jul 2019 10:11:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19A6D8E0001; Mon, 22 Jul 2019 10:11:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A88356B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 10:11:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so26378932eds.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:11:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=0mNrE0JroOBd9HwpxRSmYt7yikc7Ld076SnICsYTgkk=;
        b=adCSJEKS+H8BygtgwPj+U0r01S5aBUOIRnUThpNVKVd3cUS1qmg9LXG2Yjsm0HhGM2
         ql5UpZO2Budw9molj7PdTU7Yg/UfgpWqHEEESAY4uKQWyINhV2eX1ZVQpERSlT5BuKXw
         ykKf/+1neGA1Z16qU1VPmQpPjt/sDL2ftrEdBd1B+P3okd48HdV77XfeQjGOTxXAfDxE
         xCYMfHCyFK41CRcYaiH9LfKqRZgNzp0QBesOYHjja5K7ojnZqm2XzgLiIo4lhbrj4Mm+
         UhbArxQ0Gp0e+y3/lmHdK9itAwnE1TAOohIu+Q1b/PTsvEN77U1cBfa6O97o3KHTk40P
         UM5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWrFT6CiCLIq1vkGVthb4PQ66DI9whs9dcdp2DICx6Kb99Kb073
	If2VbDI5EMezmXr/gg+51grZuiyhtMUGpvf8Sj7k1pIsBairEhUmfvW2y788yuj3C/kZWd4oKBy
	7KOdG7kstnl4Hgl96njjDTT/CVJNOqJCZI+vfkbrOlUGeFWUOhk7jEAQirKySwV2x/g==
X-Received: by 2002:a50:b0e3:: with SMTP id j90mr60604754edd.26.1563804702185;
        Mon, 22 Jul 2019 07:11:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXAy536ZWPcQTO/wqdcnAIkVt3TdlosgTaqU/4JsCBQfAvQrCDzAsoHNVlJwbtNtpC5KMN
X-Received: by 2002:a50:b0e3:: with SMTP id j90mr60604616edd.26.1563804700838;
        Mon, 22 Jul 2019 07:11:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563804700; cv=none;
        d=google.com; s=arc-20160816;
        b=DsfrYaCf0drXZUCE/720eVhQrK4TqU8MMdvGdkjez6CXz+b9afZSWJMJPp09/3NoL0
         UWxynvVw9o+Rx4y03heJf3tWfOCMSyMNlrNtv3W82IaFkfGfbQbp78w+LcOYQxUR/Oc0
         CraWq6kj1W7MtbTG8NJkNxyNJ4KPdEDqT9nqU7f1l89oVfbGKT6Ldgb7s4dvS3JqYue5
         aKGzdZ3iq8/I8RcRtbvMPTMRerOPDy5xpebzDhlrfqmo2Jo7oB6WdgJXc/q6prRj5vmo
         whj2hjePRi+hCqtkTzI2lbkaF9hVrS6XVRslXbAPAJXF6/8k5XxAJRZmm6s9K3AI5bbU
         K7Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=0mNrE0JroOBd9HwpxRSmYt7yikc7Ld076SnICsYTgkk=;
        b=zwJopnLHWzsuu7yoJLUPmQrR7BbamQCK3Gvb1/flZtMJexJwfp18u0FJyaJVOw+rS1
         8piLvVJzFy6vZMfL+E9xP/Rs50ua9vhHFaW4geUzWoTV4A50oamFqjZu5R2a0HqTitX2
         HUX8OUIzaDheXPtoBlg0iemh5KqiBmTCp/oIury+MQfHfEM4zkMdHxv9HkXE4yI4h6rd
         0nSFSEgjj8CCypDqtAGWQH/m108kK95mLRZbQ9813SYy2qxIwCkGlYpF449VXQ+KLx8C
         pzzFRsxVoqDjt+/AJuGVVb7WB2R01pOPC4E5TWfaQMiL7r5Z8pPR3XSSBinm75wXApLF
         jgdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 10si5095306eju.51.2019.07.22.07.11.40
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 07:11:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CF1FF344;
	Mon, 22 Jul 2019 07:11:39 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 93B623F694;
	Mon, 22 Jul 2019 07:11:38 -0700 (PDT)
From: Mark Rutland <mark.rutland@arm.com>
To: linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Cc: Mark Rutland <mark.rutland@arm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	Yu Zhao <yuzhao@google.com>,
	linux-mm@kvack.org
Subject: [PATCHv2] mm: treewide: Clarify pgtable_page_{ctor,dtor}() naming
Date: Mon, 22 Jul 2019 15:11:33 +0100
Message-Id: <20190722141133.3116-1-mark.rutland@arm.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The naming of pgtable_page_{ctor,dtor}() seems to have confused a few
people, and until recently arm64 used these erroneously/pointlessly for
other levels of page table.

To make it incredibly clear that these only apply to the PTE level, and
to align with the naming of pgtable_pmd_page_{ctor,dtor}(), let's rename
them to pgtable_pte_page_{ctor,dtor}().

These changes were generated with the following shell script:

----
git grep -lw 'pgtable_page_.tor' | while read FILE; do
    sed -i '{s/pgtable_page_ctor/pgtable_pte_page_ctor/}' $FILE;
    sed -i '{s/pgtable_page_dtor/pgtable_pte_page_dtor/}' $FILE;
done
----

... with the documentation re-flowed to remain under 80 columns, and
whitespace fixed up in macros to keep backslashes aligned.

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
 arch/arc/include/asm/pgalloc.h             |  4 ++--
 arch/arm/include/asm/tlb.h                 |  2 +-
 arch/arm/mm/mmu.c                          |  2 +-
 arch/arm64/include/asm/tlb.h               |  2 +-
 arch/arm64/mm/mmu.c                        |  2 +-
 arch/csky/include/asm/pgalloc.h            |  2 +-
 arch/hexagon/include/asm/pgalloc.h         |  2 +-
 arch/ia64/include/asm/pgalloc.h            |  4 ++--
 arch/m68k/include/asm/mcf_pgalloc.h        |  6 +++---
 arch/m68k/include/asm/motorola_pgalloc.h   |  6 +++---
 arch/m68k/include/asm/sun3_pgalloc.h       |  2 +-
 arch/microblaze/include/asm/pgalloc.h      |  4 ++--
 arch/mips/include/asm/pgalloc.h            |  2 +-
 arch/nios2/include/asm/pgalloc.h           |  2 +-
 arch/openrisc/include/asm/pgalloc.h        |  6 +++---
 arch/powerpc/mm/pgtable-frag.c             |  6 +++---
 arch/riscv/include/asm/pgalloc.h           |  2 +-
 arch/s390/mm/pgalloc.c                     |  6 +++---
 arch/sh/include/asm/pgalloc.h              |  6 +++---
 arch/sparc/mm/init_64.c                    |  4 ++--
 arch/sparc/mm/srmmu.c                      |  4 ++--
 arch/um/include/asm/pgalloc.h              |  2 +-
 arch/unicore32/include/asm/tlb.h           |  2 +-
 arch/x86/mm/pgtable.c                      |  2 +-
 arch/xtensa/include/asm/pgalloc.h          |  4 ++--
 include/asm-generic/pgalloc.h              |  8 ++++----
 include/linux/mm.h                         |  4 ++--
 28 files changed, 54 insertions(+), 54 deletions(-)

Since v1 [1]:
* Rebase to v5.3-rc1
* Use shell rather than coccinelle

[1] https://lore.kernel.org/r/20190610163354.24835-1-mark.rutland@arm.com

diff --git a/Documentation/vm/split_page_table_lock.rst b/Documentation/vm/split_page_table_lock.rst
index 889b00be469f..ff51f4a5494d 100644
--- a/Documentation/vm/split_page_table_lock.rst
+++ b/Documentation/vm/split_page_table_lock.rst
@@ -54,9 +54,9 @@ Hugetlb-specific helpers:
 Support of split page table lock by an architecture
 ===================================================
 
-There's no need in special enabling of PTE split page table lock:
-everything required is done by pgtable_page_ctor() and pgtable_page_dtor(),
-which must be called on PTE table allocation / freeing.
+There's no need in special enabling of PTE split page table lock: everything
+required is done by pgtable_pte_page_ctor() and pgtable_pte_page_dtor(), which
+must be called on PTE table allocation / freeing.
 
 Make sure the architecture doesn't use slab allocator for page table
 allocation: slab uses page->slab_cache for its pages.
@@ -74,7 +74,7 @@ paths: i.e X86_PAE preallocate few PMDs on pgd_alloc().
 
 With everything in place you can set CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK.
 
-NOTE: pgtable_page_ctor() and pgtable_pmd_page_ctor() can fail -- it must
+NOTE: pgtable_pte_page_ctor() and pgtable_pmd_page_ctor() can fail -- it must
 be handled properly.
 
 page->ptl
@@ -94,7 +94,7 @@ trick:
    split lock with enabled DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC, but costs
    one more cache line for indirect access;
 
-The spinlock_t allocated in pgtable_page_ctor() for PTE table and in
+The spinlock_t allocated in pgtable_pte_page_ctor() for PTE table and in
 pgtable_pmd_page_ctor() for PMD table.
 
 Please, never access page->ptl directly -- use appropriate helper.
diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.h
index 9bdb8ed5b0db..c2b754b63846 100644
--- a/arch/arc/include/asm/pgalloc.h
+++ b/arch/arc/include/asm/pgalloc.h
@@ -108,7 +108,7 @@ pte_alloc_one(struct mm_struct *mm)
 		return 0;
 	memzero((void *)pte_pg, PTRS_PER_PTE * sizeof(pte_t));
 	page = virt_to_page(pte_pg);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return 0;
 	}
@@ -123,7 +123,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t ptep)
 {
-	pgtable_page_dtor(virt_to_page(ptep));
+	pgtable_pte_page_dtor(virt_to_page(ptep));
 	free_pages((unsigned long)ptep, __get_order_pte());
 }
 
diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index b75ea15b85c0..669474add486 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -44,7 +44,7 @@ static inline void __tlb_remove_table(void *_table)
 static inline void
 __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned long addr)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 
 #ifndef CONFIG_ARM_LPAE
 	/*
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index d9a0038774a6..426d9085396b 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -731,7 +731,7 @@ static void *__init late_alloc(unsigned long sz)
 {
 	void *ptr = (void *)__get_free_pages(GFP_PGTABLE_KERNEL, get_order(sz));
 
-	if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
+	if (!ptr || !pgtable_pte_page_ctor(virt_to_page(ptr)))
 		BUG();
 	return ptr;
 }
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index a95d1fcb7e21..b76df828e6b7 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -44,7 +44,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 				  unsigned long addr)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	tlb_remove_table(tlb, pte);
 }
 
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 750a69dde39b..63d730c5b7a9 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -383,7 +383,7 @@ static phys_addr_t pgd_pgtable_alloc(int shift)
 	 * folded, and if so pgtable_pmd_page_ctor() becomes nop.
 	 */
 	if (shift == PAGE_SHIFT)
-		BUG_ON(!pgtable_page_ctor(phys_to_page(pa)));
+		BUG_ON(!pgtable_pte_page_ctor(phys_to_page(pa)));
 	else if (shift == PMD_SHIFT)
 		BUG_ON(!pgtable_pmd_page_ctor(phys_to_page(pa)));
 
diff --git a/arch/csky/include/asm/pgalloc.h b/arch/csky/include/asm/pgalloc.h
index 98c5716708d6..6bfd5dcf04e1 100644
--- a/arch/csky/include/asm/pgalloc.h
+++ b/arch/csky/include/asm/pgalloc.h
@@ -71,7 +71,7 @@ static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 
 #define __pte_free_tlb(tlb, pte, address)		\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);			\
 	tlb_remove_page(tlb, pte);			\
 } while (0)
 
diff --git a/arch/hexagon/include/asm/pgalloc.h b/arch/hexagon/include/asm/pgalloc.h
index d6544dc71258..d82a83d0b436 100644
--- a/arch/hexagon/include/asm/pgalloc.h
+++ b/arch/hexagon/include/asm/pgalloc.h
@@ -96,7 +96,7 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 
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
index 1a8ddbd0d23c..856121122b91 100644
--- a/arch/m68k/include/asm/sun3_pgalloc.h
+++ b/arch/m68k/include/asm/sun3_pgalloc.h
@@ -21,7 +21,7 @@ extern const char bad_pmd_string[];
 
 #define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);			\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
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
index aa16b85ddffc..ff9c3cf87363 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -54,7 +54,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 #define __pte_free_tlb(tlb,pte,address)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);			\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
diff --git a/arch/nios2/include/asm/pgalloc.h b/arch/nios2/include/asm/pgalloc.h
index 4bc8cf72067e..7dd264c3c539 100644
--- a/arch/nios2/include/asm/pgalloc.h
+++ b/arch/nios2/include/asm/pgalloc.h
@@ -41,7 +41,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
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
index 56a67d66f72f..c1e2780f7352 100644
--- a/arch/riscv/include/asm/pgalloc.h
+++ b/arch/riscv/include/asm/pgalloc.h
@@ -78,7 +78,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 
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
index d7b282e9c4d5..f70df6f5626d 100644
--- a/arch/um/include/asm/pgalloc.h
+++ b/arch/um/include/asm/pgalloc.h
@@ -29,7 +29,7 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 #define __pte_free_tlb(tlb,pte, address)		\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_pte_page_dtor(pte);			\
 	tlb_remove_page((tlb),(pte));			\
 } while (0)
 
diff --git a/arch/unicore32/include/asm/tlb.h b/arch/unicore32/include/asm/tlb.h
index 10d2356bfddd..4663d8cc80ef 100644
--- a/arch/unicore32/include/asm/tlb.h
+++ b/arch/unicore32/include/asm/tlb.h
@@ -15,7 +15,7 @@
 
 #define __pte_free_tlb(tlb, pte, addr)				\
 	do {							\
-		pgtable_page_dtor(pte);				\
+		pgtable_pte_page_dtor(pte);			\
 		tlb_remove_page((tlb), (pte));			\
 	} while (0)
 
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 44816ff6411f..73757bc0eb87 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -45,7 +45,7 @@ early_param("userpte", setup_userpte);
 
 void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	paravirt_release_pte(page_to_pfn(pte));
 	paravirt_tlb_remove_table(tlb, pte);
 }
diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
index dd744aa450fa..1d38f0e755ba 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -55,7 +55,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
-	if (!pgtable_page_ctor(page)) {
+	if (!pgtable_pte_page_ctor(page)) {
 		__free_page(page);
 		return NULL;
 	}
@@ -69,7 +69,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_pte_page_dtor(pte);
 	__free_page(pte);
 }
 #define pmd_pgtable(pmd) pmd_page(pmd)
diff --git a/include/asm-generic/pgalloc.h b/include/asm-generic/pgalloc.h
index 8476175c07e7..ef7ece04a336 100644
--- a/include/asm-generic/pgalloc.h
+++ b/include/asm-generic/pgalloc.h
@@ -49,7 +49,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
  * @mm: the mm_struct of the current context
  * @gfp: GFP flags to use for the allocation
  *
- * Allocates a page and runs the pgtable_page_ctor().
+ * Allocates a page and runs the pgtable_pte_page_ctor().
  *
  * This function is intended for architectures that need
  * anything beyond simple page allocation or must have custom GFP flags.
@@ -63,7 +63,7 @@ static inline pgtable_t __pte_alloc_one(struct mm_struct *mm, gfp_t gfp)
 	pte = alloc_page(gfp);
 	if (!pte)
 		return NULL;
-	if (!pgtable_page_ctor(pte)) {
+	if (!pgtable_pte_page_ctor(pte)) {
 		__free_page(pte);
 		return NULL;
 	}
@@ -76,7 +76,7 @@ static inline pgtable_t __pte_alloc_one(struct mm_struct *mm, gfp_t gfp)
  * pte_alloc_one - allocate a page for PTE-level user page table
  * @mm: the mm_struct of the current context
  *
- * Allocates a page and runs the pgtable_page_ctor().
+ * Allocates a page and runs the pgtable_pte_page_ctor().
  *
  * Return: `struct page` initialized as page table or %NULL on error
  */
@@ -98,7 +98,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
  */
 static inline void pte_free(struct mm_struct *mm, struct page *pte_page)
 {
-	pgtable_page_dtor(pte_page);
+	pgtable_pte_page_dtor(pte_page);
 	__free_page(pte_page);
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..662230704a05 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1972,7 +1972,7 @@ static inline void pgtable_init(void)
 	pgtable_cache_init();
 }
 
-static inline bool pgtable_page_ctor(struct page *page)
+static inline bool pgtable_pte_page_ctor(struct page *page)
 {
 	if (!ptlock_init(page))
 		return false;
@@ -1981,7 +1981,7 @@ static inline bool pgtable_page_ctor(struct page *page)
 	return true;
 }
 
-static inline void pgtable_page_dtor(struct page *page)
+static inline void pgtable_pte_page_dtor(struct page *page)
 {
 	ptlock_free(page);
 	__ClearPageTable(page);
-- 
2.11.0

