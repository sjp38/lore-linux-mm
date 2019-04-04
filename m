Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50F45C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:47:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C342206B7
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:47:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C342206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B06916B000E; Thu,  4 Apr 2019 05:47:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB5CF6B0266; Thu,  4 Apr 2019 05:47:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CE146B0269; Thu,  4 Apr 2019 05:47:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFD36B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:47:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s27so1083081eda.16
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:47:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=kbLzgI/BbNqddxcLvhl156HmxQpyP2Y/KdoRc3dMBxE=;
        b=AGbgIDXGgfnrENoqjziAFFOm0CvZq3AB3pUDAHn//pq852WU2hcbZTXO5Pm7Wcotge
         eIZmBRysiKyzKz5mGc9dnogPz8rjm4h3IVXgfd+Zv3X0GW1UpHeIpy6x/Mef8rVHLZu+
         JJdomlrwP2ASl+Vjkg0HXh+zTNoW1psoVY4YfnGaUPgn87pm3zZ8z4Wp9xN7+6OSNALm
         AMyK8HEHKy7qTfCqHjf/Zu4xoxr00dZvCYS94q+Yvoj+JkqlnwU1y2966kkZ0ul9JJ7E
         phF27JHURudnryBdGTflylWsJXQgkKFR/q4aBhUeQsrUtI20QoNvPWFPfTs7w7fMV8Gp
         RgfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWXfzgCIdAt8cOLMKuQZvTKqC4dV01h9f1aZTaFtjSB8Vn2Xf/3
	uxbZEw/p5S0o3PeyO1NN4IDAChdQqNYAqVlmzIES+L/AuV6CBLwKXseCnxxjdompEk3wmPRgT/D
	s44qte+Broqo2k/vHNEQ0EJ3gnhxkLBVZ6qTUwd2J0cowYHG130Zg3iyyLseNAz/tlg==
X-Received: by 2002:aa7:c250:: with SMTP id y16mr3050661edo.238.1554371233843;
        Thu, 04 Apr 2019 02:47:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxYMDQxsE2Qy2TE/0zi6yvBxpp+gt/JKJ5COUcm1Y3lRqoJpnekElGwxIFbwXz9QfXihR4
X-Received: by 2002:aa7:c250:: with SMTP id y16mr3050591edo.238.1554371232508;
        Thu, 04 Apr 2019 02:47:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554371232; cv=none;
        d=google.com; s=arc-20160816;
        b=tsqA0oUM82WJ0Z06dIx4PX4FTHOyGaoDFI6CmQftPU9tbQ8dln4cY+axVHhzwzHzch
         fmnYt5mrNdbx6i8+lXGsHZMw/3vFcNdHZIzfuajnS/bg0PW7D0UutCgiRQR5eRQf9d+x
         3UpNU9tIfZ18CwTngK9ai/4UwZNa1PFs3xkD6CkBAfnxT1fC8ESC0jIRglxQOs4xfhwm
         bV0W2ArqHdCesIQbjhHP1ftlcWzU1P0ogWpz/MPw3Wcgvd2Sk/eiq5UDwHo8QetsSeXC
         Inl8SCNFLqZKXC3htLD6DjywvVx+v1df0ACYdIMXrUyTJtSwFFOPh51udhqPn2O20f0C
         CZNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=kbLzgI/BbNqddxcLvhl156HmxQpyP2Y/KdoRc3dMBxE=;
        b=WzB3fEJJTGleCoG2Knvs5T/B6BjF0yjLY3zGbkCbb2fCRPWK9oCipUKbY1AZThA8i0
         EitefWRke5Z+Qtw4vVAa5TY2yhQyxq5n3qEzj+UIDbbbPPJAQmNzlrBBvSQipkwK/JRG
         itQdnRP7QVJ3yblHfC5+ZEdY+iWDyBRjGl77n5peb97krvISrixX3wNFDwgF7KqyNmws
         u35IHJelPI1jpXbqtK2YvlTwT3xjGGd1fwbxG2wmNKDW8oLPbPqythqvSJ9udTWyPmFl
         HPY1aoPfvYyN4OD4wyVj6Of+i4M5yEzxmzCSv5WqxKsvPzyYkZC89RFcW+8PIFlyGAa3
         ZV8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f25si2999991ejf.32.2019.04.04.02.47.12
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 02:47:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 67B1C169E;
	Thu,  4 Apr 2019 02:47:11 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 6B6113F557;
	Thu,  4 Apr 2019 02:47:05 -0700 (PDT)
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
	david@redhat.com,
	cai@lca.pw
Subject: [RFC 2/2] arm64/mm: Enable ZONE_DEVICE for all page configs
Date: Thu,  4 Apr 2019 15:16:50 +0530
Message-Id: <1554371210-24736-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1554371210-24736-1-git-send-email-anshuman.khandual@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554371210-24736-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now that vmemmap_populate_basepages() supports struct vmem_altmap based
allocations, ZONE_DEVICE can be functional across all page size configs.
Now vmemmap_populate_baepages() takes in actual struct vmem_altmap for
allocation and remove_pagetable() should accommodate such new PTE level
vmemmap mappings. Just remove the ARCH_HAS_ZONE_DEVICE dependency from
ARM64_4K_PAGES.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig  |  2 +-
 arch/arm64/mm/mmu.c | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index b5d8cf57e220..4a37a33a4fe5 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -31,7 +31,7 @@ config ARM64
 	select ARCH_HAS_SYSCALL_WRAPPER
 	select ARCH_HAS_TEARDOWN_DMA_OPS if IOMMU_SUPPORT
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
-	select ARCH_HAS_ZONE_DEVICE if ARM64_4K_PAGES
+	select ARCH_HAS_ZONE_DEVICE
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_INLINE_READ_LOCK if !PREEMPT
 	select ARCH_INLINE_READ_LOCK_BH if !PREEMPT
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 2859aa89cc4a..509ed7e547a3 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -818,8 +818,8 @@ static void __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd, bool direct)
 #endif
 
 static void __meminit
-remove_pte_table(pte_t *pte_start, unsigned long addr,
-			unsigned long end, bool direct)
+remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
+		bool direct, struct vmem_altmap *altmap)
 {
 	pte_t *pte;
 
@@ -829,7 +829,7 @@ remove_pte_table(pte_t *pte_start, unsigned long addr,
 			continue;
 
 		if (!direct)
-			free_pagetable(pte_page(*pte), 0);
+			free_huge_pagetable(pte_page(*pte), 0, altmap);
 		spin_lock(&init_mm.page_table_lock);
 		pte_clear(&init_mm, addr, pte);
 		spin_unlock(&init_mm.page_table_lock);
@@ -860,7 +860,7 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 			continue;
 		}
 		pte_base = pte_offset_kernel(pmd, 0UL);
-		remove_pte_table(pte_base, addr, next, direct);
+		remove_pte_table(pte_base, addr, next, direct, altmap);
 		free_pte_table(pte_base, pmd, direct);
 	}
 }
@@ -921,7 +921,7 @@ remove_pagetable(unsigned long start, unsigned long end,
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		struct vmem_altmap *altmap)
 {
-	return vmemmap_populate_basepages(start, end, node, NULL);
+	return vmemmap_populate_basepages(start, end, node, altmap);
 }
 #else	/* !ARM64_SWAPPER_USES_SECTION_MAPS */
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
-- 
2.20.1

