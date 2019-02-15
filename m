Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFD07C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAB00222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="h/T0x0Sg";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="BYpXmwnx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAB00222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A91F8E0013; Fri, 15 Feb 2019 17:09:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75D148E0009; Fri, 15 Feb 2019 17:09:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5ADE58E0013; Fri, 15 Feb 2019 17:09:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 333818E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:28 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id n197so9429516qke.0
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=GfBeHwr04ORtgFLQqsnmzDHGaDVuFMi5ctYcK2NwUOA=;
        b=lysxUH+PyniTe0T3k/HOn508Ny6g1ZGTQblZJgSvQugnStTObmRYOQWgWddc/RevE8
         UQTu/+r0Va504J4fGYlHd3/Zg4Xm9pI/scuqiSvmPEACImpp6fgN1vqVxX0tm7uLtUL5
         HZOkWPuvIF2BKbTqxU2ziufd903ShT5m+LNbH3F+qk6quCPX1fKouhKAvp/DSRj76HIB
         7MD9UqNbrRcNHFftfjEWi+7jncKecLaU71HwhgEioCOw2hWU3Dfn+ubhdxRfDN8erhNO
         BKcabRGLpdAjDJMhv2US1Nf2m6MxzAv+mxeQMVLNGrNM7R4EAHscq22NiEzYsICaYBQb
         sbRw==
X-Gm-Message-State: AHQUAuYKtYfcPQNF4akrhyyQisQZDoYzfENCkrtoCiu8WhnKOWgVMyH4
	zUZUTBkzXjp+RJZ2yxsV++NqfEWhVQhDwKuYp5W2STluNSu9T02kHjbnxRULynzGOpK2klte5/a
	rOYqM/Fl9LH4PeTle+XImsNMq/YwVXtNaocSI3UVoQVrYHIDi12tZCoudTeyaEY7pQw==
X-Received: by 2002:ac8:2709:: with SMTP id g9mr9163368qtg.287.1550268568014;
        Fri, 15 Feb 2019 14:09:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY9+GfQf01Ffej8k8fJbL6FGIrHjURtLYCJSvzB6pzyv5nrRAY95ZSXZZXU2a7BnwBkHwPs
X-Received: by 2002:ac8:2709:: with SMTP id g9mr9163344qtg.287.1550268567571;
        Fri, 15 Feb 2019 14:09:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268567; cv=none;
        d=google.com; s=arc-20160816;
        b=ZjH7M6LrM+HjAqJMkHmidTSt+GZ693HJHdLpbR76xWAcNVAlGfUiVuxIeUUoHgzcSA
         B3sgtRKsqK8btAuDWzMS5/RQ5PUZ6fVpWOTzzN4M8AvqNCLzzca8/YQS0SxPsM7I2y6p
         NXgC65XdCJBQywK/Ogg9KjNoWFJNHz1rloCLAsgLLruAAZEe0flH9jvGKiAPadv7g+z+
         fjJZVmg+nMy6QWFQuaRlU775SFErn05Az3ABqzuoa+YwNDmXVG4Sp/h5OMZd6yNjOrVw
         m4AmAm2twjoXVB1pH9ido4wQZyoNUUtgz9+8x5+ohA767AcSM21OxbF0QEck5eRkuDYe
         bZjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=GfBeHwr04ORtgFLQqsnmzDHGaDVuFMi5ctYcK2NwUOA=;
        b=xJgKzdMNR2sest3EW1XdW+VPoZ1R04jOaHQpSJefKPBiT9TBFFpjvkcP6Hd5SGsOQq
         yT5ZwiHUDnT0uRsDqRTFbqhq6A9vxf0wiZ4BUh9skLn7trXm9SNGWPQ5BJZp3KUcUUpV
         KzvTn/VLHC1MOef4i1VMLf7aAk/x0QynsBAta0nwsFffL0bK0wBiJF24mjYcOfpxPizU
         F+9NQUE0SXaII7B6wMRh++332nrfaragdnArGzH/NG8teyspTj1F4C84qch66L1afTpG
         Trj7mw0GgN7i9t3+CD91g6yN3qTyKDTQMyt3ULonP+N7J/+rs1bMJ25dJAGHc4iUGXE0
         mKFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b="h/T0x0Sg";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=BYpXmwnx;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id z2si4492409qtf.343.2019.02.15.14.09.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:27 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b="h/T0x0Sg";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=BYpXmwnx;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id BB191DC6;
	Fri, 15 Feb 2019 17:09:25 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:26 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=GfBeHwr04ORtg
	FLQqsnmzDHGaDVuFMi5ctYcK2NwUOA=; b=h/T0x0Sgnwu6ItOzFmOHDJZDiM14/
	vbHNXuL+4gSJ6PigtN6YNxm1GpjaxWOXwpXf1iShiLEP9fCEJZmBhEUJkblzLZ67
	PS1cAIjKw/DeJvmwIdbleMg7sfP82qDR9GoKTXr81fp3v2y+GSRmfz/lRX3zcMnj
	UMyR7/op89Haa3COGEiziTKkKAUUF5rMYfmDgy9hI0gu0Mw9AMhKkpGOKwF8ajyI
	+5ZaqbQ7tjXtDYh3bcvXz2SHehNb6wE9iKtxWGzbwt1oUIvQsRINodf1341VO97N
	VWI3cOLI+qBrAaQwStIf+NaohnTKKY1isq1H2jjq49pmXMeHMF59FZHQw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=GfBeHwr04ORtgFLQqsnmzDHGaDVuFMi5ctYcK2NwUOA=; b=BYpXmwnx
	TrlidDSTsUGjyMtY5kDWNJ8bCQjZf5W6cEb/tUXA+huVciXtF1tadt/EUcckif9k
	qK7jrBRhmLDkOwogxn5OSu/4hji7B/gRUvPPzB1cJzZvfb7v47akaaZkIAZcg8/H
	spVRBd9VjFtSH0XGKqlVZzDB1AjnriIV8f+7RHw3+PBtoCEnEyNuW2RT6140Urx1
	kXPXTpP0yBwm0nB29l9Qm2H925HoddwlN/vLPWQCfsJhUx+0eUn6xsFTvO0dkBAF
	EA9UxypMExSavFefXMhyopv04NDNa6q3pyGtC7Oe1U4UGA/qg6J6c5DjqmZvYzdZ
	jeSCkvQZHh3MCw==
X-ME-Sender: <xms:lThnXPjYSIBnZ0WFJP1-Y39sfPiRqtebBPDYCVjVVqRN6Vf24kQI_g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedufe
X-ME-Proxy: <xmx:lThnXAQJOnIMUEYE_7vyspnlqB3-bybAWENPahIIKTebxqsrm7M6Zw>
    <xmx:lThnXCMTddYXSp6eN9WA9WgBdX8i9o-BKacWDwXsCtlDzIf_74-prw>
    <xmx:lThnXKnPMENzxbnUcaaO8VRYgKjJr43gx_-MDlYWSbNtTg_ktxitaw>
    <xmx:lThnXGM5c-J7WSliPisk0x0hCLjvKJHBWk9rrBU1dGRL8O_ccOktJQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id CAB2AE4597;
	Fri, 15 Feb 2019 17:09:23 -0500 (EST)
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
Subject: [RFC PATCH 17/31] mm: thp: split properly PMD-mapped PUD THP to PTE-mapped PUD THP.
Date: Fri, 15 Feb 2019 14:08:42 -0800
Message-Id: <20190215220856.29749-18-zi.yan@sent.com>
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

Page count increase needs to goto the head of the PUD page.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/huge_memory.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5f83f4c5eac7..bbdbc9ae06bf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3198,7 +3198,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long haddr, bool freeze)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct page *page;
+	struct page *page, *head;
 	pgtable_t pgtable;
 	pmd_t old_pmd, _pmd;
 	bool young, write, soft_dirty, pmd_migration = false;
@@ -3285,7 +3285,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		soft_dirty = pmd_soft_dirty(old_pmd);
 	}
 	VM_BUG_ON_PAGE(!page_count(page), page);
-	page_ref_add(page, HPAGE_PMD_NR - 1);
+	head = compound_head(page);
+	page_ref_add(head, HPAGE_PMD_NR - 1);
 
 	/*
 	 * Withdraw the table only after we mark the pmd entry invalid.
-- 
2.20.1

