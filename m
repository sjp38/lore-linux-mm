Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3ED5C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67F3221841
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="PbSjR/3Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67F3221841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F370E8E001F; Wed, 31 Jul 2019 11:08:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFA9D8E001C; Wed, 31 Jul 2019 11:08:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4A4B8E001E; Wed, 31 Jul 2019 11:08:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9FA8E001A
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f3so42564701edx.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bKIWoBO1Ox9foRE7zQy0IoCXQXSDJQsZ/wpbYRrt7O8=;
        b=uEpxxcVcOpZvyhibNVTZComQkiv1jVYpBfA+qO93i6wfOZypr4nEcZDVpHHXTnYADg
         t42WDnH3jjShx92xp67zAMMIt3y0wolXhM9TLiRuiKu9zZJj8lkx8pcX64txFtiFPDTs
         L3TjkarPtHLzwdHUe+vBhXSkSqhwSCSiplGI4b/1oF/bFPIJr+Q4yrOhl3uKnUY8/F7+
         5YHHgnw5G4DblxvAlOsuTJwKxg2gTrgNObje5bXT4ndGdfKGeJoxcZ6Yt++WqEIhEdce
         NQVqcmF3B0tbwd83JrDlMBy5+Zwb8hFiBEsOE+D0jxDtcifeU6zlF7T0zkAyWt9exorv
         NTLw==
X-Gm-Message-State: APjAAAUxkEbRywCj5lF413BCyBoTn6yeIjg3m6titDUDY9sggYde5XjV
	pp8N66jhRCJQnhogIzeVSrw3dmFNnbptxj3l+o5VE1Keh9gWfFv9b1XdGYbF8nDtDIoGTfVuQ/8
	DbgtYw2bJ1feMXwgdR69gnXchCgyGrm6jExQn+jetBdPdxFPSTgTkMiEidHGE0Jg=
X-Received: by 2002:a50:91ae:: with SMTP id g43mr107863226eda.279.1564585714030;
        Wed, 31 Jul 2019 08:08:34 -0700 (PDT)
X-Received: by 2002:a50:91ae:: with SMTP id g43mr107863082eda.279.1564585712715;
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585712; cv=none;
        d=google.com; s=arc-20160816;
        b=SJJiCiYxfS7zlNhYenDFgq7+o6IZeE9J9eXjjFPjlVjQREERpuHQP/DLt3zpmiqiUg
         di02j8ZJ8uTEwTEaQOYTZvZOjfz920n7g+RsD2SGQuYU4p2wVr/51KzJO8yK9L81Qqvb
         1cPW3vmpnjbn/RtntOe6WqfOvIWT0Yu3bGXimYZCMtos6ZoCa1p30WFnzLuC1VC7RiGX
         fKSrZ27Sacb4GD6/Cj1aoo58NYej0Xopu+og/Vd7YYazMMFtw5aBgYomYyJ6vlw0uID3
         Bs4hR78+UgYoxKmw7UC4+QrProwTyFAm7oiddqfoGihrZib1uB4P//xqoIVhXHmJOghe
         7sOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bKIWoBO1Ox9foRE7zQy0IoCXQXSDJQsZ/wpbYRrt7O8=;
        b=pvvCAr4L5j807dDEBpu9k0T2oP5V9Yv6ENCFA6TydO5CP3cbltWzzAAtr3DBRTUwdN
         SRMCNNe4mDYQo321pB0ObZxFGnpd+UMdi0gbG7thtd9c+bUBa8Zsnh05H9WDlLmZFZft
         kxOJiPs2sycxU1i9bdDVbLzoZG/iqFuBiqh+dJPCmSmtU83w8tSiSCSXZkbpVaEn/fAU
         PGRWKdSqrhf/rWB6dFiCfLBjMNxuluUW3IlPSpqjVJSZd1Ei78dfZdl6Qk5XXjA/TuMB
         GlG+ja6ZZaArEhRe2YLGwS0BYEawaE5CQJ35d21oPMeIhl7/KLiMX7nDvgmbNtzk++Wq
         mpNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="PbSjR/3Y";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f25sor52155385eda.21.2019.07.31.08.08.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="PbSjR/3Y";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bKIWoBO1Ox9foRE7zQy0IoCXQXSDJQsZ/wpbYRrt7O8=;
        b=PbSjR/3YSpT3z0VTol0zIBTaptMjGhUYM3HUndjM3neCQkCTkww5qEep158FrhMPDB
         lOja6cV3oSHoyK5HuysL26jeiqkfqfvW5YCcm+LVastLopDh0evznn9Jq/ft27Nk0yls
         rnC1AKEeGTuwcFgRdFljMrIygrLWBDFyhvLXjbwshxlOfCLSeM8F5NTRRHEv0Ie5JSY0
         b1aiesbbVNHw4aazLYgwIMzT8ab5pWkVI/0jSeHw4sNpg9XZaJV+IqQWo3AWpb2CYE/1
         0iRZiF3T3Y4zZUpFAx0MzBe/Qihdixe290PHhrcx6T5Kzu6+jBCiV+w7prbZ/t0zig7E
         KLeA==
X-Google-Smtp-Source: APXvYqxPGPCNvE23xibIXe+57N4H71XsaK3wWKF6xCUN274arFhtKnpkEJtXRg5udE0RuJ4iEKcGYA==
X-Received: by 2002:a05:6402:145a:: with SMTP id d26mr107237799edx.10.1564585712394;
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id g7sm16942446eda.52.2019.07.31.08.08.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 57277104836; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 50/59] x86/mm: Use common code for DMA memory encryption
Date: Wed, 31 Jul 2019 18:08:04 +0300
Message-Id: <20190731150813.26289-51-kirill.shutemov@linux.intel.com>
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

From: Jacob Pan <jacob.jun.pan@linux.intel.com>

Replace sme_ code with x86 memory encryption common code such that
Intel MKTME can be supported underneath generic DMA code.
dma_to_phys() & phys_to_dma() results will be runtime modified by
memory encryption code.

Signed-off-by: Jacob Pan <jacob.jun.pan@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mem_encrypt.h | 29 +++++++++++++++++++++++++++++
 arch/x86/mm/mem_encrypt_common.c   |  2 +-
 include/linux/dma-direct.h         |  4 ++--
 include/linux/mem_encrypt.h        | 23 ++++++++++-------------
 4 files changed, 42 insertions(+), 16 deletions(-)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 0c196c47d621..62a1493f389c 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -52,8 +52,19 @@ bool sev_active(void);
 
 #define __bss_decrypted __attribute__((__section__(".bss..decrypted")))
 
+/*
+ * The __sme_set() and __sme_clr() macros are useful for adding or removing
+ * the encryption mask from a value (e.g. when dealing with pagetable
+ * entries).
+ */
+#define __sme_set(x)		((x) | sme_me_mask)
+#define __sme_clr(x)		((x) & ~sme_me_mask)
+
 #else	/* !CONFIG_AMD_MEM_ENCRYPT */
 
+#define __sme_set(x)		(x)
+#define __sme_clr(x)		(x)
+
 #define sme_me_mask	0ULL
 
 static inline void __init sme_early_encrypt(resource_size_t paddr,
@@ -94,4 +105,22 @@ extern char __start_bss_decrypted[], __end_bss_decrypted[], __start_bss_decrypte
 
 #endif	/* __ASSEMBLY__ */
 
+#ifdef CONFIG_X86_MEM_ENCRYPT_COMMON
+
+extern dma_addr_t __mem_encrypt_dma_set(dma_addr_t daddr, phys_addr_t paddr);
+extern phys_addr_t __mem_encrypt_dma_clear(phys_addr_t paddr);
+
+#else
+static inline dma_addr_t __mem_encrypt_dma_set(dma_addr_t daddr, phys_addr_t paddr)
+{
+	return daddr;
+}
+
+static inline phys_addr_t __mem_encrypt_dma_clear(phys_addr_t paddr)
+{
+	return paddr;
+}
+#endif /* CONFIG_X86_MEM_ENCRYPT_COMMON */
+
+
 #endif	/* __X86_MEM_ENCRYPT_H__ */
diff --git a/arch/x86/mm/mem_encrypt_common.c b/arch/x86/mm/mem_encrypt_common.c
index c11d70151735..588d6ea45624 100644
--- a/arch/x86/mm/mem_encrypt_common.c
+++ b/arch/x86/mm/mem_encrypt_common.c
@@ -1,6 +1,6 @@
 #include <linux/mm.h>
-#include <linux/mem_encrypt.h>
 #include <linux/dma-mapping.h>
+#include <asm/mem_encrypt.h>
 #include <asm/mktme.h>
 
 /*
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index adf993a3bd58..6ce96b06c440 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -49,12 +49,12 @@ static inline bool force_dma_unencrypted(struct device *dev)
  */
 static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
-	return __sme_set(__phys_to_dma(dev, paddr));
+	return __mem_encrypt_dma_set(__phys_to_dma(dev, paddr), paddr);
 }
 
 static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
-	return __sme_clr(__dma_to_phys(dev, daddr));
+	return __mem_encrypt_dma_clear(__dma_to_phys(dev, daddr));
 }
 
 u64 dma_direct_get_required_mask(struct device *dev);
diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
index 470bd53a89df..88724aa7c065 100644
--- a/include/linux/mem_encrypt.h
+++ b/include/linux/mem_encrypt.h
@@ -23,6 +23,16 @@
 static inline bool sme_active(void) { return false; }
 static inline bool sev_active(void) { return false; }
 
+static inline dma_addr_t __mem_encrypt_dma_set(dma_addr_t daddr, phys_addr_t paddr)
+{
+	return daddr;
+}
+
+static inline phys_addr_t __mem_encrypt_dma_clear(phys_addr_t paddr)
+{
+	return paddr;
+}
+
 #endif	/* CONFIG_ARCH_HAS_MEM_ENCRYPT */
 
 static inline bool mem_encrypt_active(void)
@@ -35,19 +45,6 @@ static inline u64 sme_get_me_mask(void)
 	return sme_me_mask;
 }
 
-#ifdef CONFIG_AMD_MEM_ENCRYPT
-/*
- * The __sme_set() and __sme_clr() macros are useful for adding or removing
- * the encryption mask from a value (e.g. when dealing with pagetable
- * entries).
- */
-#define __sme_set(x)		((x) | sme_me_mask)
-#define __sme_clr(x)		((x) & ~sme_me_mask)
-#else
-#define __sme_set(x)		(x)
-#define __sme_clr(x)		(x)
-#endif
-
 #endif	/* __ASSEMBLY__ */
 
 #endif	/* __MEM_ENCRYPT_H__ */
-- 
2.21.0

