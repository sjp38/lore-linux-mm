Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D4E7C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 510F02064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="kpoM7/cz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 510F02064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87F078E0017; Wed, 31 Jul 2019 11:08:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794D78E0013; Wed, 31 Jul 2019 11:08:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 596BC8E0018; Wed, 31 Jul 2019 11:08:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 053178E0017
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so42564587edx.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=h0//8b8JhmDYiWR+Ncdp81M8YpF3RR/HYJneA6rLbBE=;
        b=LCGMICBjVH53PrRdNlmSPxS1rTy49gwNGrIpW9IqWWlFI7UFq+Ch1ZW0Axfa3Vg/95
         iKNJN5fY3fi93w6bIFTZmtqk/EEE03NX43YWu8x9+dibDaeewHC+Gd+DD9ThQIRwkKyq
         2h/HoHg9taSM3kgD3AwJLTYSzm59Ie62iKnj7oZHtD7QqWsyoUuMB04YHsRU73GH4uTR
         /2AiIqM7XfP11JdIbuypmGGf/57IaWaBL4DuPWgMKCxIxFeB3TfVFN28E5zpsv0cMK17
         pckJuJa1BdmP7+pimtR1o6otJN9VZV2H1qSAoDQG7aJyODLhCluvA/Y4qfeVejtOaQOG
         lrsQ==
X-Gm-Message-State: APjAAAXYruNsGrEeX2wV6pFeeY2VRv/1DhlbSzKfhRbLxtBtDUVFYbFM
	y/OepPZUj3BfHO3YScSWG1LM6SOyiwyEgaKz647h73QRbfQt9PmXOfylG0IvFUiibIQ+m7PfjS5
	+6FwEaUHrAjNne28hhskRBSY14ucUgw9auWS0fpfu4Z6U++u20tIbsEfg/wTlcvk=
X-Received: by 2002:a17:907:20b7:: with SMTP id pw23mr96116102ejb.127.1564585709588;
        Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
X-Received: by 2002:a17:907:20b7:: with SMTP id pw23mr96115982ejb.127.1564585708328;
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585708; cv=none;
        d=google.com; s=arc-20160816;
        b=rY59B3vn8zMK77XlRqEsZDXZN2s2GkJYX9LkvpI4ejj5Y1gTOOQZlvpJ0uX4QgCF/d
         +pDUemn4JRBBSH9lJ5YUIdileuOYJpOanSY+NPbadxV4pyS9XBauS5kQ4XhWKgVaNk5Y
         1Gxa3+2t6iS2ajuTwl5E0calTGvlsI96+d8IUigdMuzWkpCcLbmGPviUcps5G1fFkk42
         OOAsvALB5uwx+mO16APK3p00Bjw89vz3bVpthn01/ncZnDFxrpXzRYk1Nr8hsvDXPcNB
         QVyj/nCZTTfH1ilFKg73Bk32s5UBpVJ0wOna9nqiuip2cDRWWgkcsR/LfNcM/Lyu/se5
         9rAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=h0//8b8JhmDYiWR+Ncdp81M8YpF3RR/HYJneA6rLbBE=;
        b=gmFGk+3X6379W1S6blDLaId+LHTCU1xAdzMqbtOLxDgu4Ndcy9C/VArLeQKhfkl99a
         K+k5HRohtbXXid/ZT4N50Lw9bD5ZqfCqQgV6phv0OWgVbORr+pGF6WHIj7YNSPfgAX4H
         AlQcH7ByyGnG3nTWfzaws/nFP1PUckYx8ZGBDVI/rtDVgUthvSLoCaYQovyly4a9hSA7
         7POBpXNchtSYE1CApT1/iN1CNIUw6B6oem5BrIPPYEAZlv73c/uOs8gTQ2fKAPEG8vCo
         MKzsRA8yw0TCUCcJRkFrXTeg9bei3tQrGrVbYGufz+nIjDHYqfSuXBMwDJgJi5NVG6ie
         2b0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="kpoM7/cz";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id jt17sor21767905ejb.23.2019.07.31.08.08.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="kpoM7/cz";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=h0//8b8JhmDYiWR+Ncdp81M8YpF3RR/HYJneA6rLbBE=;
        b=kpoM7/czG2vuCwsXq98nirdJYBOwr8KtzxM9+afNHenqhKIfVEFjDG3vbbM89v9hU6
         YMAzAAX30FdCqCWqUZzuyEQfYHEZ5SGXYXGaTc/RfM7vFtD/yULcwWNLageDoX/8krFH
         n4QKoyHVqCbs14roQ7VJaujfaJiV2Mk09sz0OeErJzlvISCfVQW2kNTXy8w9Gxm3/IwU
         dcejxnmJWBrLcdeNajBBaL1AUmO1liY5yMiINB1/ytr9VKZzK36rf3vWWCycIhQ15tIE
         DSLnTwriWXZKdOs1A4sQUyGiM4P5PvUWt23VhEqgSeYDF0Ha/yNAfcCo2u0r6R6Yiip8
         wAXQ==
X-Google-Smtp-Source: APXvYqxzkJr6sogcwi+BoQU+16q789SLZB/aHhQhjukCfnhAW3wOEpwRSp2oNCYJ50Xj+teIukdhFg==
X-Received: by 2002:a17:906:c315:: with SMTP id s21mr93121050ejz.238.1564585708018;
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id q56sm17019541eda.28.2019.07.31.08.08.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 5DF9E102772; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 16/59] x86/mm: Rename CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING
Date: Wed, 31 Jul 2019 18:07:30 +0300
Message-Id: <20190731150813.26289-17-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Rename the option to CONFIG_MEMORY_PHYSICAL_PADDING. It will be used
not only for KASLR.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig    | 2 +-
 arch/x86/mm/kaslr.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 222855cc0158..2eb2867db5fa 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2214,7 +2214,7 @@ config RANDOMIZE_MEMORY
 
 	   If unsure, say Y.
 
-config RANDOMIZE_MEMORY_PHYSICAL_PADDING
+config MEMORY_PHYSICAL_PADDING
 	hex "Physical memory mapping padding" if EXPERT
 	depends on RANDOMIZE_MEMORY
 	default "0xa" if MEMORY_HOTPLUG
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index dc6182eecefa..580b82c2621b 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -104,7 +104,7 @@ void __init kernel_randomize_memory(void)
 	 */
 	BUG_ON(kaslr_regions[0].base != &page_offset_base);
 	memory_tb = DIV_ROUND_UP(max_pfn << PAGE_SHIFT, 1UL << TB_SHIFT) +
-		CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING;
+		CONFIG_MEMORY_PHYSICAL_PADDING;
 
 	/* Adapt phyiscal memory region size based on available memory */
 	if (memory_tb < kaslr_regions[0].size_tb)
-- 
2.21.0

