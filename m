Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D07C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96275208E4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qUVDb0Gb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96275208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 750CF8E000F; Tue, 30 Jul 2019 01:52:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B2D98E0003; Tue, 30 Jul 2019 01:52:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 553FB8E000F; Tue, 30 Jul 2019 01:52:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FAA78E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:49 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n3so29998314pgh.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/5sNjyutpvGxyHVQu1GnV/XZDve/kWrhGHnNmckcmW4=;
        b=tBFDDzxp9kqFBkkz0vbm3ahFOkcPLgpxhg8aBPkEjq6evaSgqN9T2qQzAjIhH7guKs
         IhpIyRIaPJYVM7YhnKVgb8B+6C86CS5FgC7juLEEpAovUe9qLTwHJmf63ZYRHxH/6IVV
         3UnsvAbCkyR60ROEBDG9ukxZF7YXTZmNX9dP1BOajt78876hFeGurAcE0k3oypW+CTgk
         dhA90KaEdJwr5Nxup74aKIbwkw4odotCeeoqg565pb0rYVtr37vOvoDTY8PSwa4ZMnCc
         UeIW37kQdr2k+mzNH+JpQG6HMNpNeh9om36BdAc8mfAwOiHFBvlpPeTRP47kvun67mLQ
         VzvA==
X-Gm-Message-State: APjAAAWMk7jpG+Hu7gVd+FETlEI9zavsjtTDe9nUdwBcR9KQR1A0NVjy
	WobmEqZq0PVY76QBkbsaPX5NtsmwPHVuq1b5YZOg5Mw1qY76JImTRDuZ1RnK5aavpbGVIOugyIf
	wOfCNWrmLp1xxWOFN4mkUqESDSXrfXHQ25ayBtXEyJoGG+YSkHyV/5YVzcluRI34=
X-Received: by 2002:a17:902:6847:: with SMTP id f7mr111288380pln.311.1564465968754;
        Mon, 29 Jul 2019 22:52:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj/Qer0ni1KSvPFR9Y0qglvl4QcCA0YKAzVM1mH4CuaO5Z7hg1en9sEGdY3COyaMOR9gDg
X-Received: by 2002:a17:902:6847:: with SMTP id f7mr111288357pln.311.1564465968109;
        Mon, 29 Jul 2019 22:52:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465968; cv=none;
        d=google.com; s=arc-20160816;
        b=J7JJ3VOJY73qbsB1AyEXK9a7Rhleil0Pqn7G01qQW8KEyul8cpm4zgbpIV3sfNYYHF
         EYSEeSwbejZ1CZ6CDMzfji+M3P3bYAvvKbpkMMPs7/i2TRyfAXfRje+fA2cDMnBG5lSJ
         NDOhMgBrNqoHbWaO+/hKktRdG8ZLzsJ5SW0qt2YxElI77+vdzZW5lamk5WneqImkmJ2n
         3Z3wwQDFFOtN0oyB7ohZO8HNjW9NdkOapwmBeEgjnWT6Ek32jgSV831XgdyfSiIIuuAa
         +ndixvGp/XxXn27gHEWl6YNY/FR7tnxQl6mAFwMcxmaW5Ggm73cr/CIbxec8Z4Ut+7QA
         bzGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/5sNjyutpvGxyHVQu1GnV/XZDve/kWrhGHnNmckcmW4=;
        b=ARUoLotrOAgr+qZVwVtvwOk57A2pgTDAektAP+wBjXR1GthY8+ES1UQktVKGyukNda
         ZZlAbqrjWzM3OsdQsmQm5ZVcWu9FAvb0MuRMVjdIVXV5+SiZBTTwTXp3dhTmEB35hbli
         U7wnlK3CTY9/S+EA3KFpw8mhPFqUUOnHAkyDdQMNxUQxNo/yxtYtM46juzsPTQad7yxz
         4UuLwgNBbv9s6b3dDISPk0HVnAZoMZcub7C+bSuwLsblQA6ES+Z9C3BOu7W65f5H+c5G
         UVmPVVVkeJ4IY0A1u5oP3JwNL0BwiTAva+AmgLQ6gZzUmC1PgwRrhNSohlfxF6St4xoa
         2ueg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qUVDb0Gb;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g21si26916997plo.235.2019.07.29.22.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qUVDb0Gb;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=/5sNjyutpvGxyHVQu1GnV/XZDve/kWrhGHnNmckcmW4=; b=qUVDb0Gb7qkDZ66Y+5kTNUPiZS
	oPKFdf1FdqOh8A+YmmGZN9LNdSXHfAWdAy/P90p3MOCc2Z96eNVGgpwDoqMg90kChee4ehDTqgr0j
	Pkj3WfEI90d1K0L5yj8xDhi4zgmFwII7fKqNTkcOh87hmP8aIWYto5bpxj6Uy1e0sMmXDfuZHNiQe
	ryhsB5F5qd969AsJYWXGSU3b3LjXZyE7SQi6J6IID+hg37hn/a03/WzGB57Vb+NcFVUtwUa5rdmZi
	cmRAd6TOTOi1MrSWzl3EdA3D5NUMB0guYKclteB1z/GzP1uvBIhvL0Mxg647o4EVb80KI84ij7PDP
	xbU47HuQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL40-0001NU-9X; Tue, 30 Jul 2019 05:52:44 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 10/13] mm: only define hmm_vma_walk_pud if needed
Date: Tue, 30 Jul 2019 08:52:00 +0300
Message-Id: <20190730055203.28467-11-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We only need the special pud_entry walker if PUD-sized hugepages and
pte mappings are supported, else the common pagewalk code will take
care of the iteration.  Not implementing this callback reduced the
amount of code compiled for non-x86 platforms, and also fixes compile
failures with other architectures when helpers like pud_pfn are not
implemented.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index e63ab7f11334..4d3bd41b6522 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -455,15 +455,6 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
 				range->flags[HMM_PFN_VALID];
 }
 
-static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud_t pud)
-{
-	if (!pud_present(pud))
-		return 0;
-	return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
-				range->flags[HMM_PFN_WRITE] :
-				range->flags[HMM_PFN_VALID];
-}
-
 static int hmm_vma_handle_pmd(struct mm_walk *walk,
 			      unsigned long addr,
 			      unsigned long end,
@@ -700,10 +691,19 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	return 0;
 }
 
-static int hmm_vma_walk_pud(pud_t *pudp,
-			    unsigned long start,
-			    unsigned long end,
-			    struct mm_walk *walk)
+#if defined(CONFIG_ARCH_HAS_PTE_DEVMAP) && \
+    defined(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD)
+static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud_t pud)
+{
+	if (!pud_present(pud))
+		return 0;
+	return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
+				range->flags[HMM_PFN_WRITE] :
+				range->flags[HMM_PFN_VALID];
+}
+
+static int hmm_vma_walk_pud(pud_t *pudp, unsigned long start, unsigned long end,
+		struct mm_walk *walk)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -765,6 +765,9 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 
 	return 0;
 }
+#else
+#define hmm_vma_walk_pud	NULL
+#endif
 
 static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 				      unsigned long start, unsigned long end,
-- 
2.20.1

