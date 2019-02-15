Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4921C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 815B4222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="M67Fe/Tz";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="bqJPD/Ck"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 815B4222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F6458E0015; Fri, 15 Feb 2019 17:09:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02E108E0014; Fri, 15 Feb 2019 17:09:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E371A8E0015; Fri, 15 Feb 2019 17:09:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B82F08E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:29 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 207so9420689qkl.2
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=Ga8VenLEXsfHIBrTuI99vweGDQOP7ZPGj8CyjpF25ow=;
        b=fqVuFGz9TMpfNOjGrzdjA0E7HevReRzVsr2AqQ2auCanrZybbeNQQSx7x0nF9ZtkFX
         au+QcY0WCVH6ifN8ueeYDu9kebVGCc51lUE1zOKTcvTb5OWSrknvxsP8/VtCIOsNEX0e
         0MBOkqZJhYBK+9yeJd3HxiD3jyH7ezo+6xnJ98RYkzlLxhFcceTIVpC1/q/ZntOObtGh
         yxIOKTYwbB3Pc6BpAtvsNihkaD7o28/rGub05wZLLRbBmZYEI0NG0pdGt+rAC0FOzKAb
         ZoVYeUrpU/nSxlIvD50Qsse7uNxH5RYsci/jpsbCwthKTucaflFbiNPXEHjuUFkpFyVr
         NKag==
X-Gm-Message-State: AHQUAuYlp4cJUTRR3CmfNgA0SAbi++3Nb5gxSx4aIhlj/zlF1/UcDkeN
	xyEPPatgTpu927Q7aHKVe9IELp6AhMrr0MlpCAhaXoDV2id4x1WlnozhwbQSwBGCwwLFspmq5/i
	h+JdsQww5jngjRInOeHz7vX9BjkEfPncnHhD3vqIPBtyYV2XNEFr6jcT6DUbClij6PA==
X-Received: by 2002:a37:b146:: with SMTP id a67mr8569241qkf.240.1550268569515;
        Fri, 15 Feb 2019 14:09:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ942Wy/5mEdF4QQsJf7J2E2w1Thu/gMnFQIpR0P3967KhBEZxesBXgHq8lWN7bJWZYg1b+
X-Received: by 2002:a37:b146:: with SMTP id a67mr8569211qkf.240.1550268568883;
        Fri, 15 Feb 2019 14:09:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268568; cv=none;
        d=google.com; s=arc-20160816;
        b=tg4PVvuzE9qBNZ0PGZ0m6RnPixCevJfBTTZ+Xg8N7VQeO318voSqspPc9ajx4t9EcM
         0+I5epFRdirG2kGZYnyQpcSKRV2P+QYR0T1Yh/FCTclWHL3hR+lYMOuwizwv1fF87Feh
         IfBuxEYH15RtQg2b2cFEPFVjjDYfnuSHAvbRKeDNG2gkb2Uxf5fp492e5GKl97Ud0tVH
         ZPPIhSpy3Aym9owtoGTc5xT7j1aWDniDDVp5nFuUUqS3U04K6iWUmZ0rxSVFJv4+rHAG
         GADhe7FI06MTursYXkn+qkBToPaN2zJErMi85KKUEc726/i4ZQxymYHOtGraLMT8K3Sr
         TncA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=Ga8VenLEXsfHIBrTuI99vweGDQOP7ZPGj8CyjpF25ow=;
        b=yWHEGbs2sNLrDU/jiw87+9C32n90qSPESLD8/R1Lgg8xzwYYg0/eEVnwIhl4wcGumV
         KBdCKap1o6Qimbw3HZiDGn1BIVFdU41qGY9bh8sLsnELZTgFx949k/FG/qMa4Y6d8fzZ
         v9+8iYmTVQ3e34ApetBmdF0vhGwHGJnsiBu7POTJbl5cqZal622TsX32oXwr7e31/Mpx
         GXTmYFlEAiG9E6U9Jy43sbTHwYNNIocCQ3lVbmJ8eRfvOTSE+psrr0dTEEA+7KnEqpCS
         g/pDd/+8xMm2LAA5ijTq48d9/KHizNmU8d2DMS22G/oEhQ+rxBaMBzr72eEQ6ms0a687
         QTHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b="M67Fe/Tz";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="bqJPD/Ck";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id y14si1058003qvc.191.2019.02.15.14.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:28 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b="M67Fe/Tz";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="bqJPD/Ck";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 1DF59180C;
	Fri, 15 Feb 2019 17:09:27 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:27 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=Ga8VenLEXsfHI
	BrTuI99vweGDQOP7ZPGj8CyjpF25ow=; b=M67Fe/TzdU9IqJ5P/Z3Mhb7yl2l9f
	b6hpBpxfXUuSGtDzySjnkvu1aFuaDoS8vx+0XHnCJ3T2MZy5d+ABEdCSzlWQR9i0
	VxfAKXjwyv8JxUfctwau2jllu9BxfD9AuQ7Y3oIA6FG4ITwZ5f+Kq5l5FmbjUH8w
	wlPWe1ST3ukCkSwJ2lev/yq14axD8W9de1qwWUGuuQQXpmn5k2P8vOsw6LQxnuog
	4rsFXBED+TRXLao/2soBUrRpnLhaf6OGfWGiBpA0tStfw/g78kyxH5zShHqogcTJ
	6lLDGIM+vFr2xAHocWGO07nRW6V4n+VDWSdrWTN140/zhxnNcMKmSXfCw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=Ga8VenLEXsfHIBrTuI99vweGDQOP7ZPGj8CyjpF25ow=; b=bqJPD/Ck
	MaLt5xra5OYDZGo7mSEF5nkxyAwIvzjZf56YkILlgES3rS71DMpjQxkBEOIOOpOe
	7w8dH/uUBIoUkJDLmtVo9MEgAAzs4nqjW75dw/0ofu0Ej3YxT+eSnpA5T/E7B9tQ
	KS4gzhJt1rb2k/48VNrhjVwD6VEf44BDxBGukgcbk1lcEHIoP48v3Ly0XYIEV7tG
	6Vn/Cd88r374iuweWEaTg6Hq+R+lN/1BYx2BV9n0WaPNLy0y7yIdkt+DVtGWumt7
	j6H2rJvlzrCTC9HX/ePyJlwxPELxlgQ7BmQGcMDWcg+JmCE+1pQbV6/UVtQ9i+1G
	L0QCklN2ObGF3Q==
X-ME-Sender: <xms:ljhnXFs43Oeq4p_9qlCuPTyeqA17A_Bwdkh3-K0QQTGfsDUbIrPuAQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedufe
X-ME-Proxy: <xmx:ljhnXFBFX8m6M0Fe-Wt0jy69nfVOW0yT5Z2nbwVqWjURGHwRXEAs1A>
    <xmx:ljhnXGPsskLUvI89-efI8US0ALrZn7TKsjgV-ePjb6DV5ixFpuxy5A>
    <xmx:ljhnXMZ79x4HCcRtL7io_sCbqpvOpP4k8x1OfFXdtX6XBnCxfWAUoA>
    <xmx:ljhnXNy9CDM1bc3K_rxMZNrj_wAAnZ3hX4aB9fHuE2NslgKp19g5XQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 2C2A1E4511;
	Fri, 15 Feb 2019 17:09:25 -0500 (EST)
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
Subject: [RFC PATCH 18/31] mm: page_vma_walk: teach it about PMD-mapped PUD THP.
Date: Fri, 15 Feb 2019 14:08:43 -0800
Message-Id: <20190215220856.29749-19-zi.yan@sent.com>
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

We now have PMD-mapped PUD THP and PTE-mapped PUD THP, page_vma_walk
should handle them properly.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/page_vma_mapped.c | 116 ++++++++++++++++++++++++++++++-------------
 1 file changed, 82 insertions(+), 34 deletions(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index a473553aa9a5..fde47dae0b9c 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -52,6 +52,22 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
 	return true;
 }
 
+static bool map_pmd(struct page_vma_mapped_walk *pvmw)
+{
+	pmd_t pmde;
+
+	pvmw->pmd = pmd_offset(pvmw->pud, pvmw->address);
+	pmde = READ_ONCE(*pvmw->pmd);
+	if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
+		pvmw->ptl = pmd_lock(pvmw->vma->vm_mm, pvmw->pmd);
+		return true;
+	} else if (!pmd_present(pmde))
+		return false;
+
+	pvmw->ptl = pmd_lock(pvmw->vma->vm_mm, pvmw->pmd);
+	return true;
+}
+
 static inline bool pfn_in_hpage(struct page *hpage, unsigned long pfn)
 {
 	unsigned long hpage_pfn = page_to_pfn(hpage);
@@ -111,6 +127,38 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
 	return pfn_in_hpage(pvmw->page, pfn);
 }
 
+/* 0: not mapped, 1: pmd_page, 2: pmd  */
+static int check_pmd(struct page_vma_mapped_walk *pvmw)
+{
+	unsigned long pfn;
+
+	if (likely(pmd_trans_huge(*pvmw->pmd))) {
+		if (pvmw->flags & PVMW_MIGRATION)
+			return 0;
+		pfn = pmd_pfn(*pvmw->pmd);
+		if (!pfn_in_hpage(pvmw->page, pfn))
+			return 0;
+		return 1;
+	} else if (!pmd_present(*pvmw->pmd)) {
+		if (thp_migration_supported()) {
+			if (!(pvmw->flags & PVMW_MIGRATION))
+				return 0;
+			if (is_migration_entry(pmd_to_swp_entry(*pvmw->pmd))) {
+				swp_entry_t entry = pmd_to_swp_entry(*pvmw->pmd);
+
+				pfn = migration_entry_to_pfn(entry);
+				if (!pfn_in_hpage(pvmw->page, pfn))
+					return 0;
+				return 1;
+			}
+		}
+		return 0;
+	}
+	/* THP pmd was split under us: handle on pte level */
+	spin_unlock(pvmw->ptl);
+	pvmw->ptl = NULL;
+	return 2;
+}
 /**
  * page_vma_mapped_walk - check if @pvmw->page is mapped in @pvmw->vma at
  * @pvmw->address
@@ -142,14 +190,14 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	pgd_t *pgd;
 	p4d_t *p4d;
 	pud_t pude;
-	pmd_t pmde;
+	int pmd_res;
 
 	if (!pvmw->pte && !pvmw->pmd && pvmw->pud)
 		return not_found(pvmw);
 
 	/* The only possible pmd mapping has been handled on last iteration */
 	if (pvmw->pmd && !pvmw->pte)
-		return not_found(pvmw);
+		goto next_pmd;
 
 	if (pvmw->pte)
 		goto next_pte;
@@ -198,43 +246,43 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	} else if (!pud_present(pude))
 		return false;
 
-	pvmw->pmd = pmd_offset(pvmw->pud, pvmw->address);
-	/*
-	 * Make sure the pmd value isn't cached in a register by the
-	 * compiler and used as a stale value after we've observed a
-	 * subsequent update.
-	 */
-	pmde = READ_ONCE(*pvmw->pmd);
-	if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
-		pvmw->ptl = pmd_lock(mm, pvmw->pmd);
-		if (likely(pmd_trans_huge(*pvmw->pmd))) {
-			if (pvmw->flags & PVMW_MIGRATION)
-				return not_found(pvmw);
-			if (pmd_page(*pvmw->pmd) != page)
-				return not_found(pvmw);
+	if (!map_pmd(pvmw))
+		goto next_pmd;
+	/* pmd locked after map_pmd  */
+	while (1) {
+		pmd_res = check_pmd(pvmw);
+		if (pmd_res == 1) /* pmd_page */
 			return true;
-		} else if (!pmd_present(*pvmw->pmd)) {
-			if (thp_migration_supported()) {
-				if (!(pvmw->flags & PVMW_MIGRATION))
-					return not_found(pvmw);
-				if (is_migration_entry(pmd_to_swp_entry(*pvmw->pmd))) {
-					swp_entry_t entry = pmd_to_swp_entry(*pvmw->pmd);
-
-					if (migration_entry_to_page(entry) != page)
-						return not_found(pvmw);
-					return true;
+		else if (pmd_res == 2) /* pmd entry  */
+			goto pte_level;
+next_pmd:
+		/* Only PMD-mapped PUD THP has next pmd  */
+		if (!(PageTransHuge(pvmw->page) && compound_order(pvmw->page) == HPAGE_PUD_ORDER))
+			return not_found(pvmw);
+		do {
+			pvmw->address += HPAGE_PMD_SIZE;
+			if (pvmw->address >= pvmw->vma->vm_end ||
+			    pvmw->address >=
+					__vma_address(pvmw->page, pvmw->vma) +
+					hpage_nr_pages(pvmw->page) * PAGE_SIZE)
+				return not_found(pvmw);
+			/* Did we cross page table boundary? */
+			if (pvmw->address % PUD_SIZE == 0) {
+				if (pvmw->ptl) {
+					spin_unlock(pvmw->ptl);
+					pvmw->ptl = NULL;
 				}
+				goto restart;
+			} else {
+				pvmw->pmd++;
 			}
-			return not_found(pvmw);
-		} else {
-			/* THP pmd was split under us: handle on pte level */
-			spin_unlock(pvmw->ptl);
-			pvmw->ptl = NULL;
-		}
-	} else if (!pmd_present(pmde)) {
-		return false;
+		} while (pmd_none(*pvmw->pmd));
+
+		if (!pvmw->ptl)
+			pvmw->ptl = pmd_lock(mm, pvmw->pmd);
 	}
 
+pte_level:
 	if (!map_pte(pvmw))
 		goto next_pte;
 	while (1) {
-- 
2.20.1

