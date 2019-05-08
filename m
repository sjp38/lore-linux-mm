Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 191DEC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8540217F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8540217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9418B6B0272; Wed,  8 May 2019 10:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67C8B6B0271; Wed,  8 May 2019 10:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42F5C6B0273; Wed,  8 May 2019 10:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 046436B0272
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n4so12805179pgm.19
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oy9k/lofk32Hk6frBD0fIszp4fG0mb5SPdi5BaNsex0=;
        b=bq+tJnqHFCcDCxkygtkTyfFZlYORMrDWu2pW4ZHZQd4O/6Yol6KqKraGtG0m96e4z7
         lOiruj8yKySzrd6ZVD+ItpUlT0dD8OKbIpXOiUoczAT5GUdBQNVJ3oyNrusq3V3yT5R3
         +CG7VAbHhwiSpV2gKZJNKiuiyIsfGYH+RiV8mllcD4FWD+f3p9BD7btJfJTRAntHuWu3
         Nt3DHgA42LnYJ6x9pCWWyF7zleHnebAsbTI2eeJQzMj7R5e2FtOpVRLjXXoHadoxqWeP
         xWtcw/SNsPv1e3HCN7eW/gC90jj6LW6kFSFHof16hYGt1lA8wOmW/852q33+/fDdhTzN
         eLXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU5We+X8SwkPN0YglPJTfdCjYoJWCwjt5dALNXqC3rqnzMFFNKw
	BrZ6QRPoZm75Tc+kmZo7eA3Ynt1qX2KqfDBVL6b1kl7y/J2SX5W6czZLMRied1x+Ij4Ulzn3Sz5
	Ing8M6eqpnZHF4+N2CsnYE525B5uckbPMp1N7nFlbcPXFyEG4MupIhXn+xFcvKznUMg==
X-Received: by 2002:a65:63c8:: with SMTP id n8mr12379005pgv.96.1557326684679;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5jLFhqm0AsnCbDCfFh4/aAkwl+KWrQ5yqvWdC/+g2LCC+w/bmxSFqqhUrfOEAtv2hWzXU
X-Received: by 2002:a65:63c8:: with SMTP id n8mr12378922pgv.96.1557326683838;
        Wed, 08 May 2019 07:44:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326683; cv=none;
        d=google.com; s=arc-20160816;
        b=njr+sm+PUUyr542jK2q5NRY0zox9jm/LTKoXQFKd//AUZ83dOdDWKbmBEBptlVQLaA
         T2NF90iXKjDotEC1bzqeQrVYTJvyWFUm4HPKZJ7LizS1PRMqnN/iXeVc/AKadNTQzMdv
         NwwOvD81md/ggAHj/+9uH/w2MfdJDBm63x6MQ93nUeZq1I6qbMj19fenA3+lpQkkG7Ln
         64PbbZjtJqeYsKWZdrPV6IwQAagfVNfuHgusgYattAxP8+Kd8p+VAs9ag1/l9zD0WLu2
         J7yEMtbqZSwaSHIliJQV/KUgFPU36diFB6pTwGNPaq21sp8I5ra7gfgAfevscYPhsNEv
         kJIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=oy9k/lofk32Hk6frBD0fIszp4fG0mb5SPdi5BaNsex0=;
        b=jJtqpLiYjJcjArVE7AFxkAhEmfEsKfuVrzmZDXMzMtEhm3YuYIMUFlc0z4eMbkwQYk
         MHxJgsFN60UqvmnqreuLjYdqJMsZRjHEOTFoQbDz5WAfSFvKC6zxE1k5fHZWQrgMzNsb
         z1eFtWRcJ+lh3KgSsM1K+dPcRj4TkroPW3H/I0OGeqyUH6usFyzQyWVs1GKyAF2uxJ0z
         lOCwitqwAn85ekOlC7Bo1lk8dvwIM7wHZl/ZZeOZFHX85JhlKBqNy+ZAnsZ+8J6Ptl8K
         ks6X2tHO6zvgBam+uW/f6vLdd31DWpWtUn+keYSaR7nCW8iQ0Yk46VOCWBwqIYY2HwtT
         OqIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 90si19482350plb.86.2019.05.08.07.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:43 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga006.fm.intel.com with ESMTP; 08 May 2019 07:44:39 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 6629B926; Wed,  8 May 2019 17:44:29 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
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
Subject: [PATCH, RFC 15/62] x86/mm: Rename CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING
Date: Wed,  8 May 2019 17:43:35 +0300
Message-Id: <20190508144422.13171-16-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
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
index 62fc3fda1a05..62cfb381fee3 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2201,7 +2201,7 @@ config RANDOMIZE_MEMORY
 
 	   If unsure, say Y.
 
-config RANDOMIZE_MEMORY_PHYSICAL_PADDING
+config MEMORY_PHYSICAL_PADDING
 	hex "Physical memory mapping padding" if EXPERT
 	depends on RANDOMIZE_MEMORY
 	default "0xa" if MEMORY_HOTPLUG
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index d669c5e797e0..2228cc7d6b42 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -103,7 +103,7 @@ void __init kernel_randomize_memory(void)
 	 */
 	BUG_ON(kaslr_regions[0].base != &page_offset_base);
 	memory_tb = DIV_ROUND_UP(max_pfn << PAGE_SHIFT, 1UL << TB_SHIFT) +
-		CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING;
+		CONFIG_MEMORY_PHYSICAL_PADDING;
 
 	/* Adapt phyiscal memory region size based on available memory */
 	if (memory_tb < kaslr_regions[0].size_tb)
-- 
2.20.1

