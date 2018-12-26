Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A535C43444
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCC18218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCC18218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86AE98E0013; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75A258E000C; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF4958E0002; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2F08E0002
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so15290285pgd.0
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=5Mnwktm5eJFyeiOEO0Th0lml9blQA9FGr4VHQc/KtHc=;
        b=cL64DXlUU9r1XKmD8BSVu8OtL6AS6NTx5cVaXyH+i/+UnAbK8LknDqJl6S6zPmcg44
         l9Zhr0RWQJDx4d8lRhRuFCgP3o4bacd+NT37K/eNnLb+9DzgLK5rfcAhmm7G0B0GMhHs
         09IJ6Qxcxx71e6BJHxLDde4Us0csibB/hNbW20gzLrF4x2LbNoa3J3mGpWjmoJLKlm1z
         XXg73C9J7m149KXh4s0Vha4UUN0ktubUoGI0LUFCnK+C6FhNDNpMj0aK6KxIOXi1HvIx
         clqzI6b0Y+8eWBZv9Sc7pzowGVgTeebUYB1pCpXT2Ct1MEnMnD5+A6uT+SHdq7dVNHd7
         87Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukch0HJ05VX8mFf7P4nF2E/cvesm0eEuSfSfS5vWnzoX7boEbL80
	xkCjxwRfVwPL+nErR87PbUNULQVvpbpMGjJl/z3BXOoxJ4T3nb9v38fyeDZRhLeo6wmySkQMEfx
	+W4YJtuBNF5R6AVgidM2oie0iGWJYxTaljHq0Eygs15Lbtk8Hon4cGbUiyKN+bvyb3w==
X-Received: by 2002:a17:902:22f:: with SMTP id 44mr19745075plc.137.1545831427020;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7L8un+cIsXDE6sJgneWRuY1vE1xzoIlwcTy0m8TduUUWGaQjfmHYIpjYJwMhbMjHxYssvF
X-Received: by 2002:a17:902:22f:: with SMTP id 44mr19745040plc.137.1545831426397;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=lm/XA6XnE4Yutt7o4oofahx8AZB3ISncmkVyI0x3RjRTR2vo98Yh7SHehJnIikcPWZ
         MpBUXu4qDb0xVYAT9WsVSErzCL0POIAxtn0vifZG4UsNXdCqVB+mcSYs+K0dmbnrqb/z
         FdvSWa1d0udtnXuV6FM0RknHd4lvsQaZsERisLVo3FF21h2iMA5oPBI3JEJZfiMdlgaD
         eXDmpcW8EUPVTUl1nqhTKYgObUT0RGNMzDxNFC5ZOaGd8bT2c4wiKk1GmcVLRzP2FRSN
         8PiK+VlsPiB34LVn/RI1wBgdYflZC9w+pacTJi5kdv05glIl4M/WW8mgsvXBmLGcPi9l
         KRvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=5Mnwktm5eJFyeiOEO0Th0lml9blQA9FGr4VHQc/KtHc=;
        b=0Xhjy9xNRwGgxROXSrlm7YHawzStRoi1uvnw9k2u53I4Y6x6Y3OviSgkRrRwjtQZvW
         uoZLYOGz+wgaIEfZ1BYn9TCqzkgPvYKwRSFdOikM2Jv1aGrW1Rh6qc9R5SH0TrSveFzT
         VX8chTJRotiRgz5fts1ejXSSQBJDX7k4RnUG9v58hOBGCPPyfffSsyP3tq6derYw3GXx
         4aJ/OX+PfSziyz5/9eF1eiTU7jFFDa1wdxzN/GaqPo1sHXSgIUgYMsSRP1i4wbMd6rHx
         oX8aneFj24cS6XEXeQBo9/tMsSBorgDuLwb1hQFQ/yJ92dmEE19BoOqZU03Thbmm7KrM
         0kaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="121185464"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005Oo-FY; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.770245668@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:58 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 12/21] x86/pgtable: allocate page table pages from DRAM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0018-pgtable-force-pgtable-allocation-from-DRAM-node-0.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131458.rhx6tcxqOQHqlB53teyuE4x-gfz3dGs4hj12VOpnHj8@z>

On rand read/writes on large data, we find near half memory accesses
caused by TLB misses, hence hit the page table pages. So better keep
page table pages in faster DRAM nodes.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/include/asm/pgalloc.h |   10 +++++++---
 arch/x86/mm/pgtable.c          |   22 ++++++++++++++++++----
 2 files changed, 25 insertions(+), 7 deletions(-)

--- linux.orig/arch/x86/mm/pgtable.c	2018-12-26 19:41:57.494900885 +0800
+++ linux/arch/x86/mm/pgtable.c	2018-12-26 19:42:35.531621035 +0800
@@ -22,17 +22,30 @@ EXPORT_SYMBOL(physical_mask);
 #endif
 
 gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;
+nodemask_t all_node_mask = NODE_MASK_ALL;
+
+unsigned long __get_free_pgtable_pages(gfp_t gfp_mask,
+						     unsigned int order)
+{
+	struct page *page;
+
+	page = __alloc_pages_nodemask(gfp_mask, order, numa_node_id(), &all_node_mask);
+	if (!page)
+		return 0;
+	return (unsigned long) page_address(page);
+}
+EXPORT_SYMBOL(__get_free_pgtable_pages);
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)__get_free_page(PGALLOC_GFP & ~__GFP_ACCOUNT);
+	return (pte_t *)__get_free_pgtable_pages(PGALLOC_GFP & ~__GFP_ACCOUNT, 0);
 }
 
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
 
-	pte = alloc_pages(__userpte_alloc_gfp, 0);
+	pte = __alloc_pages_nodemask(__userpte_alloc_gfp, 0, numa_node_id(), &all_node_mask);
 	if (!pte)
 		return NULL;
 	if (!pgtable_page_ctor(pte)) {
@@ -241,7 +254,7 @@ static int preallocate_pmds(struct mm_st
 		gfp &= ~__GFP_ACCOUNT;
 
 	for (i = 0; i < count; i++) {
-		pmd_t *pmd = (pmd_t *)__get_free_page(gfp);
+		pmd_t *pmd = (pmd_t *)__get_free_pgtable_pages(gfp, 0);
 		if (!pmd)
 			failed = true;
 		if (pmd && !pgtable_pmd_page_ctor(virt_to_page(pmd))) {
@@ -422,7 +435,8 @@ static inline void _pgd_free(pgd_t *pgd)
 
 static inline pgd_t *_pgd_alloc(void)
 {
-	return (pgd_t *)__get_free_pages(PGALLOC_GFP, PGD_ALLOCATION_ORDER);
+	return (pgd_t *)__get_free_pgtable_pages(PGALLOC_GFP,
+						 PGD_ALLOCATION_ORDER);
 }
 
 static inline void _pgd_free(pgd_t *pgd)
--- linux.orig/arch/x86/include/asm/pgalloc.h	2018-12-26 19:40:12.992251270 +0800
+++ linux/arch/x86/include/asm/pgalloc.h	2018-12-26 19:42:35.531621035 +0800
@@ -96,10 +96,11 @@ static inline pmd_t *pmd_alloc_one(struc
 {
 	struct page *page;
 	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_ZERO;
+	nodemask_t all_node_mask = NODE_MASK_ALL;
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
-	page = alloc_pages(gfp, 0);
+	page = __alloc_pages_nodemask(gfp, 0, numa_node_id(), &all_node_mask);
 	if (!page)
 		return NULL;
 	if (!pgtable_pmd_page_ctor(page)) {
@@ -141,13 +142,16 @@ static inline void p4d_populate(struct m
 	set_p4d(p4d, __p4d(_PAGE_TABLE | __pa(pud)));
 }
 
+extern unsigned long __get_free_pgtable_pages(gfp_t gfp_mask,
+					      unsigned int order);
+
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	gfp_t gfp = GFP_KERNEL_ACCOUNT;
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
-	return (pud_t *)get_zeroed_page(gfp);
+	return (pud_t *)__get_free_pgtable_pages(gfp | __GFP_ZERO, 0);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -179,7 +183,7 @@ static inline p4d_t *p4d_alloc_one(struc
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
-	return (p4d_t *)get_zeroed_page(gfp);
+	return (p4d_t *)__get_free_pgtable_pages(gfp | __GFP_ZERO, 0);
 }
 
 static inline void p4d_free(struct mm_struct *mm, p4d_t *p4d)


