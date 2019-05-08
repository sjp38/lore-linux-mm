Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 656C4C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FA5A216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FA5A216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0D5A6B02A8; Wed,  8 May 2019 10:44:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF6526B02A2; Wed,  8 May 2019 10:44:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBCB76B02A7; Wed,  8 May 2019 10:44:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89C5A6B02A0
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:53 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c7so6537816pfp.14
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BgUXVgL6FkazvI2b18Syn+j1NwXwqEISW+VcLEk+rCs=;
        b=Twu3UflJlEBd8twumZQUvJe2qD+9geNMS/Ux2K2zKmJS85NPGaXEfyoOgWJ8qV9iEB
         FenD4VW5z3hNJeo9aXbB8H3t3WY7eFbwfndxl27uLueRcPdnG3itx6Z40+FM2Tyq2M4R
         qgn8+U3bObmYmEgWfW6fPMbdJsIvqQpxBnLKnztwlqtrJe/nLhyriA38tiwCG8MkrYLN
         XcFVTsCto2nYjglGnlNs9s2q5tqMNarKJkNyqF4s3lAt21Y4blDkdlFNZ6e2/WR/kL+W
         NCnFOjj1mickG0okTary1DgVl7zhXVWQ4vr4TrXvzs3ubm0Z93hd1TwjnicqjqWfCBeB
         3Rww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU71/jc1OctkimambMZ3IYCIucbBQNr8huYpJ+HQ7Ew/rJapxVL
	vFw2d9QZH7fzyVKi/6CFZmE+v6q6fm1BoB+usm2gqkTjXLZM7vb7fV7WsW56CgqYYQpQZq2DRBN
	C/yrpofw8l+wsmCgO7dbFrI07G1n4cyiE0/n85uuTSvLE8qxh79muwSB5JPtHbceucA==
X-Received: by 2002:a62:5b81:: with SMTP id p123mr26533217pfb.158.1557326693196;
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlFVsWyYZXfr5seLf21ay7CZTHeVxg66yL1fe789A6go9Fb8R9GD65JJcN4Rw0NBvyihWf
X-Received: by 2002:a62:5b81:: with SMTP id p123mr26533057pfb.158.1557326691800;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326691; cv=none;
        d=google.com; s=arc-20160816;
        b=zK6Icywny79LnCRO6pPgb5oH8dOGjaIYr2KUeKzd0brvkQ+qxLAy86zTzRSAZxH3bP
         mupn7chlDXiIBNVQ04TSR1VVx6C45ZZQ0NIqM8o0eGot3H+edcghXkUz9gmEzV5BBXIt
         5meRFUIEdedff+Zs3DfwFvZbWaz0el9OxhnfGyVbxLAfSpX2P+0As1whYfKYPLRPZjkR
         dcF80uPbB+djRh3IyGjHxnXDYbcggt8nuez3X5wCJiWFL/BaBi8SCd8gbehMhfDk8Qjg
         0gy56SJ1RHwxTMAXQlGv5oqF9dANqsnvKvNR3zuzFt3NagTf3P+NRJ1rt1Vmik6t2gHR
         D/vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BgUXVgL6FkazvI2b18Syn+j1NwXwqEISW+VcLEk+rCs=;
        b=HH7NWf6bX09TdYdMzAKxj63KbzX81aeBhVLdEKxhVRhM2Le4QPJGOyzB6Xft8hIQii
         Hh7olXT1WZiBm4Wye4VNWvGvHJdMwPsoHjREzvFl5349s18vDnpCQcI70oJRjZ56Ic2m
         tHu2ky96Irex7yIlvRe52skfOBa2+Vix9Vb9rBetTog7Za9QI1E1NdudioSRnQvsdyXq
         dE3PXZ9oIHZCWFHQhi+OP9tv69LoFqO5fXGPBqx5KiLf72oIH9DDbGFyJjcPNpOeQvug
         kppE1Mi5rn8zDr51/S6mRFjRfZ6lol0s2jT8ASHg2DBeXWWrSavacNe26TVcd0d1rDGw
         skgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:51 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga007.jf.intel.com with ESMTP; 08 May 2019 07:44:46 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 5D8901124; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 53/62] x86/mm: Use common code for DMA memory encryption
Date: Wed,  8 May 2019 17:44:13 +0300
Message-Id: <20190508144422.13171-54-kirill.shutemov@linux.intel.com>
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
index 616f8e637bc3..a2b69cbb0e41 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -55,8 +55,19 @@ bool sev_active(void);
 
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
@@ -97,4 +108,22 @@ extern char __start_bss_decrypted[], __end_bss_decrypted[], __start_bss_decrypte
 
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
index 2adee65eec46..dcc5c710a235 100644
--- a/arch/x86/mm/mem_encrypt_common.c
+++ b/arch/x86/mm/mem_encrypt_common.c
@@ -1,5 +1,5 @@
 #include <linux/mm.h>
-#include <linux/mem_encrypt.h>
+#include <asm/mem_encrypt.h>
 #include <asm/mktme.h>
 
 /*
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index b7338702592a..a949adeb6558 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -40,12 +40,12 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
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
index b310a9c18113..ce8ff0ead16c 100644
--- a/include/linux/mem_encrypt.h
+++ b/include/linux/mem_encrypt.h
@@ -26,6 +26,16 @@
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
@@ -38,19 +48,6 @@ static inline u64 sme_get_me_mask(void)
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
2.20.1

