Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3C1DC76192
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:02:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C580D206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:02:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C580D206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D49126B0008; Mon, 15 Jul 2019 07:02:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C02186B026D; Mon, 15 Jul 2019 07:02:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA0126B026E; Mon, 15 Jul 2019 07:02:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 700086B0008
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 07:02:25 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i6so8703411wre.1
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:02:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hGDApp89EWhquOjtHhsxHXkKfOY16kq5K6euPrNcpVQ=;
        b=CTJUHAojp6G+rr3cId37wyVyPP575IbBz3e608I0c+uYhobOSNVyOoou90ZfjMd+hk
         n22m3txdlwgjXF+Z/HyyYM2ZFHgWtZvEW/4xUpz/ksDRou0Xt8x7Ql7WXaPw3Q0FIIU1
         0vX+V5M/Wk7z8DcAH7NIYQgQcxcnaIHlll9zS3ZXH6st4rzkpeOEabIleZ4TBa1mCpdL
         lR0blfc7c+Q+gz/O//FH1AK3DJrxXymAQSafSMXS2jLyqxCLZJ8U2EBNy28LiP+LBMY3
         Tgco331/HUXCPqBa14b3EWvButl12ueujrgoK2TKrQ06g0nWrnd9OHS8l3AaDadWL8Vd
         ascw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAWNzVo5bYlATHhCDXwkJ1szityONoP4CvKH1gXCL9/FrBL7dq0m
	VZfyxD4GfOXGrV0F1c7POFw2AYYeaGBzr0pDsxJ974hJAXPPEaTXy0PnSiji/xvhw4WLAoxhv1J
	t5ehjiOLkWTB1e3QyUGzu/B6pwHlsvTBBF0kyXMOU1UrMInaFw9BxY0Qz2lR2nOoIww==
X-Received: by 2002:a1c:7c08:: with SMTP id x8mr24241841wmc.19.1563188544896;
        Mon, 15 Jul 2019 04:02:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1gTxpi5pPcg6D6yfWGeM8C+oHMIoD1XGI9JirPVd7SkkxuoD457+jxBJDt695IrpjrKWK
X-Received: by 2002:a1c:7c08:: with SMTP id x8mr24241735wmc.19.1563188544005;
        Mon, 15 Jul 2019 04:02:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563188544; cv=none;
        d=google.com; s=arc-20160816;
        b=dfg1zSRm27UwlDkBEQrkvEAsgWhmhwYxx4hK2/tHFX8D1RdiwRV43D5xbQ3Dp/SODv
         q43S1AWy1lEeUNskEXM1k9gt68j+9DLhqB9ZiBSMVFEk1iAu76TO4B4YlBUZcImnjqgT
         oYwSt0uPlNJEIusdNNBuP0EvBx+HS3ysV5YrGgvIAWSSMj6BkOMzIMEH+c1+SqlDe3PN
         UNzNXMAJDVdH7hlpvo464L2bvkqGvdKYv77Y1+S4UAcWgPJ93A2LZLnq5k/BOETynLzg
         NFooh6ZI3jdoCOuRS8JWUvby4yMonta0Kdlad1taA4ZI/1PrLbJoEG6SzK/dEWm5eruM
         pObw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hGDApp89EWhquOjtHhsxHXkKfOY16kq5K6euPrNcpVQ=;
        b=xRtL8f7OCPPBeYIXyo71cWtGhDMAEsNlzNFS6fdxeKKuKCGoKyVMzBUc17BaVaNTC1
         4cJ6V7N/nXxgWQlrh67mTrjp7drt0jId2AGcL1nCfrfpfC0t7OeYWlhj2HV0d0WW1RO1
         +ml6UAAZpTXLBwzfKvkcEiSF7a5i89Vv7u/dlSCfNAkedPy2MuNrta+xDbHykdITb5IY
         i4atqDO1P14x3ruDwTCxP3VGtRweXFxwuqKR3zug0SxYhNgd8EsNwHQOK8ihbbofQZ98
         zpgjvPYzm08Nb/iHH8X72uRcOWYjYqlN6uizOp8Q+GuZrujLZzyS1CWPs2etdsm5Tyqt
         G6bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 49si6964571wra.232.2019.07.15.04.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 15 Jul 2019 04:02:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) client-ip=81.169.241.247;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id 6E377366; Mon, 15 Jul 2019 13:02:22 +0200 (CEST)
From: Joerg Roedel <joro@8bytes.org>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Joerg Roedel <jroedel@suse.de>
Subject: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
Date: Mon, 15 Jul 2019 13:02:11 +0200
Message-Id: <20190715110212.18617-3-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190715110212.18617-1-joro@8bytes.org>
References: <20190715110212.18617-1-joro@8bytes.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joerg Roedel <jroedel@suse.de>

With huge-page ioremap areas the unmappings also need to be
synced between all page-tables. Otherwise it can cause data
corruption when a region is unmapped and later re-used.

Make the vmalloc_sync_one() function ready to sync
unmappings.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/fault.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 4a4049f6d458..d71e167662c3 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -194,11 +194,12 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
 
 	pmd = pmd_offset(pud, address);
 	pmd_k = pmd_offset(pud_k, address);
-	if (!pmd_present(*pmd_k))
-		return NULL;
 
-	if (!pmd_present(*pmd))
+	if (pmd_present(*pmd) ^ pmd_present(*pmd_k))
 		set_pmd(pmd, *pmd_k);
+
+	if (!pmd_present(*pmd_k))
+		return NULL;
 	else
 		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
 
-- 
2.17.1

