Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D254FC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81136222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="i82NFi9c";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="a41IDbu3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81136222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CDC08E001A; Fri, 15 Feb 2019 17:09:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97C938E0014; Fri, 15 Feb 2019 17:09:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81C528E001A; Fri, 15 Feb 2019 17:09:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 512DA8E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:36 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p5so10415672qtp.3
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=EYbvEGR5T55O/whT3ormGMsc4OjejtdS/ncHWvxXxkQ=;
        b=MUHQDaEVIPp3/aw4XN9JN+BnKiZl6OceBlytjQdqRv3683E5A+3ytiB+fIlVEwaOtZ
         Mzzb8dA8JWLj2WeRLGSPGPMP2lG6FnvgaTHC8GdNRaGVisz3tJH8ln8e0T/5eJgmschT
         JeeycWMkLoMRuGW3H8EsihBGHnx8v85DLR0iZXvKQJ6DDlyzINlqGD/GiNcz527su6HB
         o72kyXjfeuiuDMKXsujO1cTDRLULj0imbjjHO+aVSSDbcR8LMIsNIKteYWIzPW9qyL/K
         YVzYzfbPcMXXV2kA3A1dWU4g67JJOFKpHM4pOyZiyefhGKewn7q1IOLkrT3bpOYO8Cjl
         L+/A==
X-Gm-Message-State: AHQUAuYrdqfqjdRUIIXcz4s8Erqa+fZgD/tx/CjBvN+jZibgqsN6AEA+
	SPPTvxbGdbBTl78PcrgNovfjb1G2NRAGABHrqoAnWxSm0OU9MOTt6wJUAB+C7DPjsnXEzkGvQrP
	Eo1dVi+L7/MO3/tCvDUHNPCD6Dsth8t1qPo2+593tOy1PeQCkbf345C262Uw4rNpqtw==
X-Received: by 2002:a0c:a326:: with SMTP id u35mr9156737qvu.190.1550268576103;
        Fri, 15 Feb 2019 14:09:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbIiJcWOAzt7wT3DgS/fNJGl7//ERbB2c/fXPhrWMm9DVPKw8/T6YaucM8dlwjTxpzdDWhY
X-Received: by 2002:a0c:a326:: with SMTP id u35mr9156696qvu.190.1550268575534;
        Fri, 15 Feb 2019 14:09:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268575; cv=none;
        d=google.com; s=arc-20160816;
        b=fSYJHRlnXMMNEaEKx8p7bjFa66uyywRnwECp/OutFwoBLZEJl3mFmtJPT5AZIRa8Hm
         uWWnwOEusthJhLtVQnoLYU3L4ld5FMzLwtDAdPqxQOBXaFlnpV7MsjLg+kIMn7oSbLBl
         wE7CEa1zovinXl6rUyx+oFqBG8plJ57pLc19tEt3eXlgYaE3L9/9Q9ixRq5MAgovI27d
         5OeA3UFY2yFHRzZndvQiCvbTcduQo55noKlryG5g4TRPT3XvyYZyucQ/uqcbEFAn3VqA
         cnZN8YD/2mqGHVg8EhOayYkEs5nuYUVBpK7pHsNfyEkxhTPhl42rxmXAepRToUprg1Qa
         PXDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=EYbvEGR5T55O/whT3ormGMsc4OjejtdS/ncHWvxXxkQ=;
        b=y7hY6tCmPbCn8z5E+xmLK0q5Tg+/yD3e0B/btj9EF0rCIjMgBnSolfD5SntCQEcQS1
         PEsjZPWbW81+3iSJgj4FfFMxFnMSURyTQ6c/ZwlyWuEW+1SRnNHqakiULpbYLbbfMlzc
         qGVbvXT3GilEhdlHY0Z4qCxBarjHSRm7Rwso0x6Rt21XBYTss0gX7ESrQHofKSJg+ZEk
         M+TBi1Dyo2sKN/Qn5xMBR8Xfv4d1mj14D9F+5tyIfIAQuqMqm1FuqWc2Pv9MUjuH6rJs
         5TwPlpVqPmcYzbgpH83u6dQRGmOOaMvNURIQWneH5xdC0sXZiszhUi4vEJuHLRl2FBP4
         IjeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=i82NFi9c;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=a41IDbu3;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id j6si578330qtb.108.2019.02.15.14.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:35 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=i82NFi9c;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=a41IDbu3;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id B6AA9310A;
	Fri, 15 Feb 2019 17:09:33 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:34 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=EYbvEGR5T55O/
	whT3ormGMsc4OjejtdS/ncHWvxXxkQ=; b=i82NFi9clRWllhWB+1WAQDVTJSxf2
	jkZ+OZAH1x/MG1hPo+I91aXGzCqHNZqN/VbppOW4xJYXO4kNZfKmmcVg6gK/K8YM
	fsd2Eew3vCg8A5AxWQpjCGI2G22ajdn05x7sotOilp56JcFmTWtM+rDWjnCxsOPI
	mAtnifkzdIbVhOTNOBOTM3e5rOLAJ7g4zykkGNg9Jc/UYSG2BhMq+n106msRfV9i
	ZIOVP1PIZVEnuj/NwEZFV6XpzaSW5WDH0RdHpc9iAvwRaGnPCWbLkcLWsFtSNqsx
	eToUv6aDMEdcKSq6T89UMR1bm4VTPcZRPoce57vAp475TeBacI19f1Jgw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=EYbvEGR5T55O/whT3ormGMsc4OjejtdS/ncHWvxXxkQ=; b=a41IDbu3
	5RvxGLl/hTeM1wR3EQ9zuSaqUa3N/oLwo1XIObh6/XEIjeq8g8IFvjLlyqals5Sa
	ckfgVcYysYgWcyp/M++lW2PcvAXKaTHPKVEXYvTEfcmnPU+87hMTXTzkacOFTebi
	/gmTBScgG9ZTVAaKE29y1CX+rg4dwjekj0vLs9uuO9kfeDV7ASd2gy0n4azIeLKc
	A1jGIaQFVmk1iXi20m5uRATMbjTLmL1KM0qVAaaMS0Oj3X0Q3K6r2hzrPJv9p7aJ
	KfP5r7sSURNfkcQrpyxop7Y8d5r2tjMu/jLM9DS64ZFD23CsgRYFGOkZQYY6WVfp
	hjV+pVn0qBJ72g==
X-ME-Sender: <xms:nThnXH9mjHl8YGa-yOYXgO5plywmTDc7i6epfRjTNv7g2vNE_1KtZQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedvvd
X-ME-Proxy: <xmx:nThnXDEVJkV_hM72tcbdo7pebFQDt3G71YnQf5AieEy3_bMYDDoAzg>
    <xmx:nThnXHl4RnGCNoatF2ox2lA-MQsC-CYCjghd6Dd0XFsRWvtj2CisxA>
    <xmx:nThnXErGKbXI2wgyjb0Tbyxn4yOi3cX8Xo9klJhvCqKimZB29XSoFQ>
    <xmx:nThnXFpbYtB2yNpp-J_95fonAyrP1QR-t7LcPkvxhkP_oycOH45zBg>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id E5B2AE4511;
	Fri, 15 Feb 2019 17:09:31 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 23/31] mm: support 1GB THP pagemap support.
Date: Fri, 15 Feb 2019 14:08:48 -0800
Message-Id: <20190215220856.29749-24-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Print page flags properly.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 fs/proc/task_mmu.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0ec9edab2f3..ccf8ce760283 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1373,6 +1373,45 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 	return err;
 }
 
+static int pagemap_pud_range(pud_t *pudp, unsigned long addr, unsigned long end,
+			     struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->vma;
+	struct pagemapread *pm = walk->private;
+	int err = 0;
+	u64 flags = 0, frame = 0;
+	pud_t pud = *pudp;
+	struct page *page = NULL;
+
+	if (vma->vm_flags & VM_SOFTDIRTY)
+		flags |= PM_SOFT_DIRTY;
+
+	if (pud_present(pud)) {
+		page = pud_page(pud);
+
+		flags |= PM_PRESENT;
+		if (pud_soft_dirty(pud))
+			flags |= PM_SOFT_DIRTY;
+		if (pm->show_pfn)
+			frame = pud_pfn(pud) +
+				((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	}
+
+	if (page && page_mapcount(page) == 1)
+		flags |= PM_MMAP_EXCLUSIVE;
+
+	for (; addr != end; addr += PAGE_SIZE) {
+		pagemap_entry_t pme = make_pme(frame, flags);
+
+		err = add_to_pagemap(addr, &pme, pm);
+		if (err)
+			break;
+		if (pm->show_pfn && (flags & PM_PRESENT))
+			frame++;
+	}
+	return err;
+}
+
 #ifdef CONFIG_HUGETLB_PAGE
 /* This function walks within one hugetlb entry in the single call */
 static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
@@ -1479,6 +1518,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!pm.buffer)
 		goto out_mm;
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	pagemap_walk.pud_entry = pagemap_pud_range;
+#endif
 	pagemap_walk.pmd_entry = pagemap_pmd_range;
 	pagemap_walk.pte_hole = pagemap_pte_hole;
 #ifdef CONFIG_HUGETLB_PAGE
-- 
2.20.1

