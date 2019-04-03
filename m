Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3FEDC10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FD17206C0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FD17206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E57D56B028A; Wed,  3 Apr 2019 00:30:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E05EA6B028C; Wed,  3 Apr 2019 00:30:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD3806B028D; Wed,  3 Apr 2019 00:30:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9BC6B028A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:30:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h27so6735518eda.8
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:30:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=KerfpmvxM83iM3jUFKjZ5pNEafPHXBEirlMZMbxybmU=;
        b=sVC+CJxCU41tM8b81e1Nko4SKPlUZm7UXSGE4pSMVnSQIWq7wSLdAEi0c24FI5GBcB
         POdu+FzMHNbMoeONHhiBzCLkDfFH9r2pCkE2ePApcrAAyZpcAwCGTFLeyYtUZ4DKPq+j
         PTC6/hFDdmrFitFt0ZrtAHq36pWvUfLQvgWDdteHq892DQQjCQE5ZaSnzH1JxuBioLs+
         7y/807OEG/VDKjg337bSprTIW/qU9feDQBuJ0wPfcmg1HI1FNVWuEvdc1ybhV+WXxdOU
         HsA5LHk5gobtTL2W7azvSWsqdaNTnWEjjwdXabDHAtqWGFNgNHe7OZwnep42RfvMI/XG
         HV7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVdGI0fXxpzHDm0pmbLwP/NSsZim3Rm6Y6nQlAF1caZkkQmdiJi
	dn44qprJAZL+z8FV1/QF0pcpKhrYZrqVwin30DD2Qg4Dp4oWQfKVpZDoHeyQ5/EfNkcChLNNrFw
	Pfzc9jYJwtq0bEkOaW+h/sk2PUqKmg+Z3hosZtMEAjzoRr4Tk3TxLUVCTYIiEXk5gNA==
X-Received: by 2002:a50:a705:: with SMTP id h5mr39742294edc.226.1554265833026;
        Tue, 02 Apr 2019 21:30:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx42/iMCculpK3p5aN50aIRe3QIts0lxdTcJyI5AGykw5n/JXxRdd8+mEwO3PCtA+HBX7wd
X-Received: by 2002:a50:a705:: with SMTP id h5mr39742226edc.226.1554265831610;
        Tue, 02 Apr 2019 21:30:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265831; cv=none;
        d=google.com; s=arc-20160816;
        b=axe+NUlzJ+yBvAnzGeoyi+EvYkH5DCue+QgmeVCdu8fBmJpLsDLCZJYv2O2sRMdngO
         axsq4qCAKBfmChSH7J3Vqk/6aFVNTwiKGcuoczrDvs8h85kV9OwrHMcdCXSWoK4LWk6W
         gTW+bkAuhzbtU22RBErqvuk/F8kVbIsHRu+QaRLOPe9U7h96rhJk13ydq28dytpZMr9z
         b+NqJUz1+XCEuVh53RERBgxRGgvmFqd1nTwvOgOyzCFzWMW2oIuGNRDpV+ekwDOA/54s
         WYulEpElilz+OXIP6Xe2ozW0KBYlxFnYq3r0fJysqCfbbIfJH83ZPuaN1s57h09Kwcyd
         /8BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=KerfpmvxM83iM3jUFKjZ5pNEafPHXBEirlMZMbxybmU=;
        b=q1+4Fszj46RFGG8WZw7yBs8LVxzNycpQvgFT5tv92A2BvfLMtOlqZsROWeqdrsKG9q
         eESTvenXVFwDrdpM6eE4AhB4vuIcBa4Kx0Om0nCjux9fMChPhLGY9BD2Qorhfe8fj/a9
         3Z9veVWHlmBGu5pZ0/1EEFXrfPJc1MaMuBLgpvm1lsNQjSqCXsv2KKF1eS/SEItT7Ask
         7Dn8/4tTeQ+UWjAZSA0gMxftW2Vrik0kri4CrDdF7ktR+cX6JWnOi6SV+FK6JMHtKrt+
         /R/GHH+Estyl6AlgJxB2RazoHGdfH1FvTWMrhzXj2OPG9CzbBnIUsluLS6kAgXc+ZZQ1
         p14g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d3si4018170ejc.309.2019.04.02.21.30.31
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 21:30:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 85EA8168F;
	Tue,  2 Apr 2019 21:30:30 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.97])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 2D9863F721;
	Tue,  2 Apr 2019 21:30:24 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com
Cc: mhocko@suse.com,
	mgorman@techsingularity.net,
	james.morse@arm.com,
	mark.rutland@arm.com,
	robin.murphy@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	osalvador@suse.de,
	logang@deltatee.com,
	pasha.tatashin@oracle.com,
	david@redhat.com,
	cai@lca.pw
Subject: [PATCH 3/6] arm64/mm: Enable struct page allocation from device memory
Date: Wed,  3 Apr 2019 10:00:03 +0530
Message-Id: <1554265806-11501-4-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ZONE_DEVICE based device memory like persistent memory would typically be
more than available system RAM and can have size in TBs. Allocating struct
pages from system RAM for these vast range of device memory will reduce
amount of system RAM available for other purposes. There is a mechanism
with struct vmem_altmap which reserves range of device memory to be used
for it's own struct pages.

On arm64 platforms this enables vmemmap_populate() & vmemmap_free() which
creates & destroys struct page mapping to accommodate a given instance of
struct vmem_altmap.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/mm/mmu.c | 41 +++++++++++++++++++++++++++--------------
 1 file changed, 27 insertions(+), 14 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index ae0777b..4b25b75 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -735,6 +735,15 @@ static void __meminit free_pagetable(struct page *page, int order)
 		free_pages((unsigned long)page_address(page), order);
 }
 
+static void __meminit free_huge_pagetable(struct page *page, int order,
+						struct vmem_altmap *altmap)
+{
+	if (altmap)
+		vmem_altmap_free(altmap, (1UL << order));
+	else
+		free_pagetable(page, order);
+}
+
 #if (CONFIG_PGTABLE_LEVELS > 2)
 static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd, bool direct)
 {
@@ -828,8 +837,8 @@ remove_pte_table(pte_t *pte_start, unsigned long addr,
 }
 
 static void __meminit
-remove_pmd_table(pmd_t *pmd_start, unsigned long addr,
-			unsigned long end, bool direct)
+remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
+			bool direct, struct vmem_altmap *altmap)
 {
 	unsigned long next;
 	pte_t *pte_base;
@@ -843,8 +852,8 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr,
 
 		if (pmd_large(*pmd)) {
 			if (!direct)
-				free_pagetable(pmd_page(*pmd),
-						get_order(PMD_SIZE));
+				free_huge_pagetable(pmd_page(*pmd),
+						get_order(PMD_SIZE), altmap);
 			spin_lock(&init_mm.page_table_lock);
 			pmd_clear(pmd);
 			spin_unlock(&init_mm.page_table_lock);
@@ -857,8 +866,8 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr,
 }
 
 static void __meminit
-remove_pud_table(pud_t *pud_start, unsigned long addr,
-			unsigned long end, bool direct)
+remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
+			bool direct, struct vmem_altmap *altmap)
 {
 	unsigned long next;
 	pmd_t *pmd_base;
@@ -872,21 +881,22 @@ remove_pud_table(pud_t *pud_start, unsigned long addr,
 
 		if (pud_large(*pud)) {
 			if (!direct)
-				free_pagetable(pud_page(*pud),
-						get_order(PUD_SIZE));
+				free_huge_pagetable(pud_page(*pud),
+						get_order(PUD_SIZE), altmap);
 			spin_lock(&init_mm.page_table_lock);
 			pud_clear(pud);
 			spin_unlock(&init_mm.page_table_lock);
 			continue;
 		}
 		pmd_base = pmd_offset(pud, 0UL);
-		remove_pmd_table(pmd_base, addr, next, direct);
+		remove_pmd_table(pmd_base, addr, next, direct, altmap);
 		free_pmd_table(pmd_base, pud, direct);
 	}
 }
 
 static void __meminit
-remove_pagetable(unsigned long start, unsigned long end, bool direct)
+remove_pagetable(unsigned long start, unsigned long end,
+			bool direct, struct vmem_altmap *altmap)
 {
 	unsigned long addr, next;
 	pud_t *pud_base;
@@ -899,7 +909,7 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 			continue;
 
 		pud_base = pud_offset(pgd, 0UL);
-		remove_pud_table(pud_base, addr, next, direct);
+		remove_pud_table(pud_base, addr, next, direct, altmap);
 		free_pud_table(pud_base, pgd, direct);
 	}
 	flush_tlb_kernel_range(start, end);
@@ -938,7 +948,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		if (pmd_none(READ_ONCE(*pmdp))) {
 			void *p = NULL;
 
-			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
+			if (altmap)
+				p = altmap_alloc_block_buf(PMD_SIZE, altmap);
+			else
+				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
 			if (!p)
 				return -ENOMEM;
 
@@ -954,7 +967,7 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
 		struct vmem_altmap *altmap)
 {
 #ifdef CONFIG_MEMORY_HOTPLUG
-	remove_pagetable(start, end, false);
+	remove_pagetable(start, end, false, altmap);
 #endif
 }
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
@@ -1244,7 +1257,7 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
 static void __remove_pgd_mapping(pgd_t *pgdir, unsigned long start, u64 size)
 {
 	WARN_ON(pgdir != init_mm.pgd);
-	remove_pagetable(start, start + size, true);
+	remove_pagetable(start, start + size, true, NULL);
 }
 
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-- 
2.7.4

