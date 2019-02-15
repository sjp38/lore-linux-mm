Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 685E4C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A498222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="bCST9++F";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="N2TNvU/R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A498222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED60D8E0020; Fri, 15 Feb 2019 17:09:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAE408E0014; Fri, 15 Feb 2019 17:09:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D74DF8E0020; Fri, 15 Feb 2019 17:09:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACF218E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:44 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id b6so9416657qkg.4
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=k7ZExxjAnB4keDLSp3xQU/1nRGQzF8KzUQhggKQXhQA=;
        b=QcBpr3crFhAWcR+l825JLLLFPwWlc+VdDVpZDFSl1oYGFxZV6K0M5t3pWdi/t0zYou
         5refvXT7DjtIGI03QU+A/syJGMmn2VilbYmpUJCxtdhA0I43C+0FPZLUrelMB/q4X1R6
         2pWhslOfdFvZt7JS4DvfqfqXzM6iulkka3oQXaKnNkpZGgscle2Dstuq2wqr9iCgEv5g
         umhULgOKVuQv85K9vJCvqpb3sAlalzo1CoEwdwOY0xku1FmWMAaIfeQMoXJVcTdaMpHu
         3+VzxYsrVLrL758ZfByXVs5NBwsTe7HrUefY6ZKgw9kXc+svMFFC7vMKSLZSf5en5hYg
         tH9A==
X-Gm-Message-State: AHQUAuYI/QHJuFIVqEfpGjAGhroNjkP3yng+AXNBsF+eyflR6omdRccq
	16sTpXf7mstw/Q5sIEBEx0RbgK0H7gKnxA5cPdEhTvNzQxk/OriotUxeJKm9TSng28A9q23xuFF
	o9y729PDmzW6R2tL01ckV3W7rtj7kJ6kZKJg+wqIdt/jdwS0b+nCFvYsUW1/Mby3azA==
X-Received: by 2002:ac8:3f46:: with SMTP id w6mr9645988qtk.175.1550268584487;
        Fri, 15 Feb 2019 14:09:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYj4ZociD6oFExUCXkhXgiGdkHHnFGs1xg9gnDiQ3mU3A+zhLkDbkZDyNqBHhZLfBOVXLf8
X-Received: by 2002:ac8:3f46:: with SMTP id w6mr9645951qtk.175.1550268583913;
        Fri, 15 Feb 2019 14:09:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268583; cv=none;
        d=google.com; s=arc-20160816;
        b=T5c01I8L/nB93wZLqJdeZJ8PdQyxdFmnIqjShhA8fUrij4sQGC+MAsONTsS2JgWaZY
         e+h3t3VQBP2HRBxJJD0JXwj8yNP1tWj5LwnSbj7G9wEXbSMJwtkpjN65gGsUhbUUdtf3
         3iynvvm30CgtLsQFk/tTNkn95mzXhxgSyWOR55KdNIidQptTDlKdeCyDl0QT+nLCGgCo
         j7GDSji7+ftxm6bZ9VQSiVZwv41rOka4DCQSsRwRlHwWtyC07xH7Rvb27qCQAoTURC0r
         xs6vPI65HfTKMkjOGLC1oubBbznPiL2rZkp8sVFwu/Fa4h1MzwSgh9rzBRWFBXyWshM2
         YfUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=k7ZExxjAnB4keDLSp3xQU/1nRGQzF8KzUQhggKQXhQA=;
        b=jrIGr2Y8Sq51QlXEUSTzi95PA2cGlep8Eke4fHm8jY9T0Wnc/tsLb8ESI+QDYcgS8s
         iEPCbl+brYaiMgNJGV4zK5xKwueMeQ40VuxHPZKopO3EL2SumFkwUN0spaNe7+N0mDBL
         ryLPXh3m6RRe4wQYZVpIkkQPPtTjhuPIElKqOH9B4zt1BLsTXroUFj8ZYXuwSE2VSqz9
         bVhaslVFT+4MFm1wlWIUXaIsPmYZ5Oysj3qXK65vvm9P+NXv0Sz/s9IQBd72QcQ5Tk+C
         BPVaAmlLwpo10B3fvOCIRNLapoFW1hJ0d/6xHXhdMFJRGf2t+PjRUR4Wdkj6/zUYzbb+
         gd5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=bCST9++F;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="N2TNvU/R";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id u4si4414746qte.0.2019.02.15.14.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:43 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=bCST9++F;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="N2TNvU/R";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 2050E329D;
	Fri, 15 Feb 2019 17:09:42 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:42 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=k7ZExxjAnB4ke
	DLSp3xQU/1nRGQzF8KzUQhggKQXhQA=; b=bCST9++F8XtSzpwjh7el976UwiLPi
	M7Tj8JRboCd0IwlnCEwtvDlYbyA8Rjpd9AeKVgoCIT5DSbK0F5OT5ThksiP9y5Fv
	gGUOCMAhWAnS5OrY9KmLJvxXKHo1+9vfT0FHiVvUevjxUVRUqZ1jfE5ADNrp63Eq
	/BSrH5lpf3BTEN5ouultEKnaUjtma934YpfHusNBt4taJWspaNRCAdRyHucXSagp
	oW5tMUYZxy4oRavKWNRO2QmLgry+kZrIic4ZFt7PkUj9qmE0XYNs8+wq+XNQLG3O
	8obrb2RuOt5RHrBgdH7qr7GXlFclhjXKS0B7bHOjn0H4N7EONBlfEZwMA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=k7ZExxjAnB4keDLSp3xQU/1nRGQzF8KzUQhggKQXhQA=; b=N2TNvU/R
	jWTIXilhmDIXAMyLfIPdfFFt3yofQ6K/H+6duECZyb3D3Kn7KlO1wWA8/o5J0cUi
	OsigiqED0MnljUauXgN6wn4MUvpUVzfu+LgdOMgVv8w9KKh7Xv0wYYmRQmKAHzYf
	cCO7bZb5Ge+jT7dNlPLCNbPaE8Q39AgTa5QJorojhOadKrKZivu3BJA60YJgqGVT
	HQ05Kdd2LfbbRewAP7EjHdyMiFktvsgQp3edeAdrCfZf1Qkz6ICEWtIbuu6qMwSc
	fWDF8CwPOgTdGU3iA3GIk55JoI/68mEukzNu/fWChg9Z16Gteap7m0l7/pFTOnkF
	LKNxQ/mqa/zLXg==
X-ME-Sender: <xms:pThnXOfCEQkB3dIgkj-bbMV2P1V4xGb6tojk3NBiKXrJb_mY2F8arw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehlecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedt
X-ME-Proxy: <xmx:pThnXFnvX2RCQtgh3ZjWLqa1Tl-Ct979ZmGI1JylyY4D9wVRCq7WHw>
    <xmx:pThnXJDvYISAyw_AffEAYhGrsIfIqU9D2WNAWn2oadnugtXdx5M6AA>
    <xmx:pThnXHMivLaeC6T-i5gH3Gkigvx4j52hR1mKCLFpYK1vV85T7_Skng>
    <xmx:pThnXOx4MgLnCxPGUL3fIhfGZQYUkftz2pQPbdWaEeEcR_zDnYDv4A>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 2ABD2E4597;
	Fri, 15 Feb 2019 17:09:40 -0500 (EST)
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
Subject: [RFC PATCH 29/31] mm: madvise: add madvise options to split PMD and PUD THPs.
Date: Fri, 15 Feb 2019 14:08:54 -0800
Message-Id: <20190215220856.29749-30-zi.yan@sent.com>
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

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/uapi/asm-generic/mman-common.h |  12 +++
 mm/madvise.c                           | 106 +++++++++++++++++++++++++
 2 files changed, 118 insertions(+)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index d1ec94a1970d..33db8b6a2ce0 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -69,6 +69,18 @@
 #define MADV_MEMDEFRAG	20		/* Worth backing with hugepages */
 #define MADV_NOMEMDEFRAG	21		/* Not worth backing with hugepages */
 
+#define MADV_SPLITHUGEPAGE	24		/* Split huge page in range once */
+#define MADV_PROMOTEHUGEPAGE	25		/* Promote range into huge page */
+
+#define MADV_SPLITHUGEMAP	26		/* Split huge page table entry in range once */
+#define MADV_PROMOTEHUGEMAP	27		/* Promote range into huge page table entry */
+
+#define MADV_SPLITHUGEPUDPAGE	28		/* Split huge page in range once */
+#define MADV_PROMOTEHUGEPUDPAGE	29		/* Promote range into huge page */
+
+#define MADV_SPLITHUGEPUDMAP	30		/* Split huge page table entry in range once */
+#define MADV_PROMOTEHUGEPUDMAP	31		/* Promote range into huge page table entry */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 9cef96d633e8..be3818c06e17 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -624,6 +624,95 @@ static long madvise_memdefrag(struct vm_area_struct *vma,
 	*prev = vma;
 	return memdefrag_madvise(vma, &vma->vm_flags, behavior);
 }
+
+static long madvise_split_promote_hugepage(struct vm_area_struct *vma,
+		     struct vm_area_struct **prev,
+		     unsigned long start, unsigned long end, int behavior)
+{
+	struct page *page;
+	unsigned long addr = start, haddr;
+	int ret = 0;
+	*prev = vma;
+
+	while (addr < end && !ret) {
+		switch (behavior) {
+		case MADV_SPLITHUGEMAP:
+			split_huge_pmd_address(vma, addr, false, NULL);
+			addr += HPAGE_PMD_SIZE;
+			break;
+		case MADV_SPLITHUGEPUDMAP:
+			split_huge_pud_address(vma, addr, false, NULL);
+			addr += HPAGE_PUD_SIZE;
+			break;
+		case MADV_SPLITHUGEPAGE:
+			page = follow_page(vma, addr, FOLL_GET);
+			if (page) {
+				lock_page(page);
+				if (split_huge_page(page)) {
+					pr_debug("%s: fail to split page\n", __func__);
+					ret = -EBUSY;
+				}
+				unlock_page(page);
+				put_page(page);
+			} else
+				ret = -ENODEV;
+			addr += HPAGE_PMD_SIZE;
+			break;
+		case MADV_SPLITHUGEPUDPAGE:
+			page = follow_page(vma, addr, FOLL_GET);
+			if (page) {
+				lock_page(page);
+				if (split_huge_pud_page(page)) {
+					pr_debug("%s: fail to split pud page\n", __func__);
+					ret = -EBUSY;
+				}
+				unlock_page(page);
+				put_page(page);
+			} else
+				ret = -ENODEV;
+			addr += HPAGE_PUD_SIZE;
+			break;
+		case MADV_PROMOTEHUGEMAP:
+			haddr = addr & HPAGE_PMD_MASK;
+			if (haddr >= start && (haddr + HPAGE_PMD_SIZE) <= end)
+				promote_huge_pmd_address(vma, haddr);
+			else
+				ret = -ENODEV;
+			addr += HPAGE_PMD_SIZE;
+			break;
+		case MADV_PROMOTEHUGEPUDMAP:
+			haddr = addr & HPAGE_PUD_MASK;
+			if (haddr >= start && (haddr + HPAGE_PUD_SIZE) <= end)
+				promote_huge_pud_address(vma, haddr);
+			else
+				ret = -ENODEV;
+			addr += HPAGE_PUD_SIZE;
+			break;
+		case MADV_PROMOTEHUGEPAGE:
+			haddr = addr & HPAGE_PMD_MASK;
+			if (haddr >= start && (haddr + HPAGE_PMD_SIZE) <= end)
+				promote_huge_page_address(vma, haddr);
+			else
+				ret = -ENODEV;
+			addr += HPAGE_PMD_SIZE;
+			break;
+		case MADV_PROMOTEHUGEPUDPAGE:
+			haddr = addr & HPAGE_PUD_MASK;
+			if (haddr >= start && (haddr + HPAGE_PUD_SIZE) <= end)
+				promote_huge_pud_page_address(vma, haddr);
+			else
+				ret = -ENODEV;
+			addr += HPAGE_PUD_SIZE;
+			break;
+		default:
+			ret = -EINVAL;
+			break;
+		}
+	}
+
+	return ret;
+}
+
 #ifdef CONFIG_MEMORY_FAILURE
 /*
  * Error injection support for memory error handling.
@@ -708,6 +797,15 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	case MADV_MEMDEFRAG:
 	case MADV_NOMEMDEFRAG:
 		return madvise_memdefrag(vma, prev, start, end, behavior);
+	case MADV_SPLITHUGEPAGE:
+	case MADV_PROMOTEHUGEPAGE:
+	case MADV_SPLITHUGEMAP:
+	case MADV_PROMOTEHUGEMAP:
+	case MADV_SPLITHUGEPUDPAGE:
+	case MADV_PROMOTEHUGEPUDPAGE:
+	case MADV_SPLITHUGEPUDMAP:
+	case MADV_PROMOTEHUGEPUDMAP:
+		return madvise_split_promote_hugepage(vma, prev, start, end, behavior);
 	default:
 		return madvise_behavior(vma, prev, start, end, behavior);
 	}
@@ -744,6 +842,14 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_MEMDEFRAG:
 	case MADV_NOMEMDEFRAG:
+	case MADV_SPLITHUGEPAGE:
+	case MADV_PROMOTEHUGEPAGE:
+	case MADV_SPLITHUGEMAP:
+	case MADV_PROMOTEHUGEMAP:
+	case MADV_SPLITHUGEPUDPAGE:
+	case MADV_PROMOTEHUGEPUDPAGE:
+	case MADV_SPLITHUGEPUDMAP:
+	case MADV_PROMOTEHUGEPUDMAP:
 		return true;
 
 	default:
-- 
2.20.1

