Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 042D0C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:47:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5E65206B7
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:47:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5E65206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69A3D6B000A; Thu,  4 Apr 2019 05:47:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64B0B6B000D; Thu,  4 Apr 2019 05:47:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 513D26B000E; Thu,  4 Apr 2019 05:47:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0425A6B000A
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:47:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y17so1076423edd.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:47:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=d9Wi/j50yZk1fgZzBzQqyorQrUldDyzr44Jwm0vgtEI=;
        b=o/CyC0DTk3j0A7mW5h0MIyHR82lNa483hzodgCxqSzakt/fh/RhERbdAk2Gq7E/jCR
         ACLV8ENHtqz/bR2zFKT4B6WfRpHWtS5b8ocX/qP8tW/5a7yZeVFN+nU0qDU8ZigThQ/N
         PElHNgloRlH8vcnSCo+pmzmJwD2zEOS084ASbB/kPVWowfemu3PLtOOEhwkcRExKS63G
         Khm6293iDryVsWEeu59rcRY25hGr8Rb3DgV8s5jLipz/7eJNlQyVNOqjCwMZh3El9Ho9
         OIBaHSubQflormzIq3Mau17OPoGsP2/aoL0UTVpnyZxFvYTshxZzSgny/EHPkfw3KGAL
         hx9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWfUozeztavZgbzlec7MtyCQjDS9VU82stwhaszMMyiSuzn6Xjc
	CeGgsxisvoh0Uw8rITuDR87hoL5MHeFyZYan6CH9dP/vDuwxmj9UdM9tcxiTh4VZyCpUw75aU89
	EeNrNiDwSUQ61a29NKf4kDHBJ2ehD7oJZM9zPjPn+rmlgTotvmIl2NZGOBy8BLpttLQ==
X-Received: by 2002:a50:aa37:: with SMTP id o52mr3108232edc.208.1554371227533;
        Thu, 04 Apr 2019 02:47:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiPE6lZmS3E2mcMUkP6Vjs94IVF2KuVTwPa5sFdzyti8xzq31twIdnxLD83agzMHqCIDFO
X-Received: by 2002:a50:aa37:: with SMTP id o52mr3108156edc.208.1554371226066;
        Thu, 04 Apr 2019 02:47:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554371226; cv=none;
        d=google.com; s=arc-20160816;
        b=nE70xQVvwfxq0YhBvWAtWEHWLd40XWsykpg7pFOK2CVVGrqCU8VlAizRSBZnL/Gq3/
         y+/3F7Z1eDgKU7OycjuRw50gRYYpS1T5kmO4Z/Pi1cpbj21qvJIlagjg0EOmXX9gbXOE
         84rQ+MD1ZG0IKwF2vLgdjfLxGkvnTPlUBMCYf81ppqXgiV6avr4UI5qMLwlLSbgyk9NA
         6rYDtprsLP8ta8ZN9dPQ02vOHA4dP/+nY0AIWAhMFpMHHpGNhC6CqPBvq4q34lYit65/
         gM8WglBs0/TWzF7zNCsRkmnnP0TAM+23BLdqEq0AcnEfnhpqN4+Ogc8qGgcp2shdR5dE
         0sKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=d9Wi/j50yZk1fgZzBzQqyorQrUldDyzr44Jwm0vgtEI=;
        b=gB1TbSSwvp0ECABehpoXBmG5C9ll307rt9mBba43yr0FNKD5y+Kr6RANMa8b7G6auW
         Ev4CweDjafBBcFpLML3i4V4cLlGUeNDLj6H2bfZ7XlgYhEkU/PlfmgtJewjSgr9CMGM1
         iGWEg5P6JLYEicERKRuWNu7RZdEuNDtada+TIJ2lvwwRcSFILTNcxZsYc2z15YpeGpYo
         eQIN11VqiaAdbTuOyshb9OD/yM8PRMw4HcM1J9POGNgg7qoAIUGTbhnwQwH3teDXNKLO
         YICcq9+oqn6mZbKXIHFImZy303c0JLl0W08+7h6C/fYtj4LAbEWuCVZUrYlGmQS+8ml0
         9gsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j2si6767280ejs.162.2019.04.04.02.47.05
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 02:47:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D4C04169E;
	Thu,  4 Apr 2019 02:47:04 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 98E153F557;
	Thu,  4 Apr 2019 02:46:58 -0700 (PDT)
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
Subject: [RFC 1/2] mm/vmemmap: Enable vmem_altmap based base page mapping for vmemmap
Date: Thu,  4 Apr 2019 15:16:49 +0530
Message-Id: <1554371210-24736-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

vmemmap_populate_basepages() is used for vmemmap mapping across platforms.
On arm64 it is used for ARM64_16K_PAGES and ARM64_64K_PAGES configs. When
applicable enable it's allocation from device memory range through struct
vmem_altpamp. Individual archs should enable this when appropriate. Hence
keep it disabled to continue with the existing semantics.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/mm/mmu.c      |  2 +-
 arch/ia64/mm/discontig.c |  2 +-
 arch/x86/mm/init_64.c    |  4 ++--
 include/linux/mm.h       |  5 +++--
 mm/sparse-vmemmap.c      | 14 ++++++++++----
 5 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 4b25b7544763..2859aa89cc4a 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -921,7 +921,7 @@ remove_pagetable(unsigned long start, unsigned long end,
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		struct vmem_altmap *altmap)
 {
-	return vmemmap_populate_basepages(start, end, node);
+	return vmemmap_populate_basepages(start, end, node, NULL);
 }
 #else	/* !ARM64_SWAPPER_USES_SECTION_MAPS */
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 05490dd073e6..faefd7ec991f 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -660,7 +660,7 @@ void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		struct vmem_altmap *altmap)
 {
-	return vmemmap_populate_basepages(start, end, node);
+	return vmemmap_populate_basepages(start, end, node, NULL);
 }
 
 void vmemmap_free(unsigned long start, unsigned long end,
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bccff68e3267..e7e05d1b8bcf 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1450,7 +1450,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
 			continue;
 		}
-		if (vmemmap_populate_basepages(addr, next, node))
+		if (vmemmap_populate_basepages(addr, next, node, NULL))
 			return -ENOMEM;
 	}
 	return 0;
@@ -1468,7 +1468,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 				__func__);
 		err = -ENOMEM;
 	} else
-		err = vmemmap_populate_basepages(start, end, node);
+		err = vmemmap_populate_basepages(start, end, node, NULL);
 	if (!err)
 		sync_global_pgds(start, end - 1);
 	return err;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..a62e9ff24af3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2672,14 +2672,15 @@ pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
 p4d_t *vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node);
 pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
-pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
+pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node,
+					struct vmem_altmap *altmap);
 void *vmemmap_alloc_block(unsigned long size, int node);
 struct vmem_altmap;
 void *vmemmap_alloc_block_buf(unsigned long size, int node);
 void *altmap_alloc_block_buf(unsigned long size, struct vmem_altmap *altmap);
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
-			       int node);
+			       int node, struct vmem_altmap *altmap);
 int vmemmap_populate(unsigned long start, unsigned long end, int node,
 		struct vmem_altmap *altmap);
 void vmemmap_populate_print_last(void);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 7fec05796796..81a0960b5cd4 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -140,12 +140,18 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 			start, end - 1);
 }
 
-pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
+pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node,
+				struct vmem_altmap *altmap)
 {
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte)) {
 		pte_t entry;
-		void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
+		void *p;
+
+		if (altmap)
+			p = altmap_alloc_block_buf(PAGE_SIZE, altmap);
+		else
+			p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
@@ -214,7 +220,7 @@ pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node)
 }
 
 int __meminit vmemmap_populate_basepages(unsigned long start,
-					 unsigned long end, int node)
+			unsigned long end, int node, struct vmem_altmap *altmap)
 {
 	unsigned long addr = start;
 	pgd_t *pgd;
@@ -236,7 +242,7 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 		pmd = vmemmap_pmd_populate(pud, addr, node);
 		if (!pmd)
 			return -ENOMEM;
-		pte = vmemmap_pte_populate(pmd, addr, node);
+		pte = vmemmap_pte_populate(pmd, addr, node, altmap);
 		if (!pte)
 			return -ENOMEM;
 		vmemmap_verify(pte, node, addr, addr + PAGE_SIZE);
-- 
2.20.1

