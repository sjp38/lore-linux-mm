Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B577C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF431216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF431216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 474F16B02A2; Wed,  8 May 2019 10:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 434416B02A5; Wed,  8 May 2019 10:44:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 088536B02A6; Wed,  8 May 2019 10:44:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B94266B02A5
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:53 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so11662505plq.1
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WDFDEcXg+f/4xOnB0EiSvj+2Wa4G0QK/3j1Q+39oVvk=;
        b=rBQWNifsWvcTks83Xfu9FzFnOpDvBlhK6iJVOnf8EX2NK6yPjKChMT9WK/psAxsEVz
         mYwYkJ+xfaGxPH4wRYI7TT0XIRe4gM9Sgm9qsyIs0TubSQqCBuPcgI+LYMuEfnccpEuB
         ullQUqL25Hn1UwLq45imkFJCmNTJBKf63P1UckxVOiuRIr7oFj1hd28loK2pJJHWgkN6
         ile+1eQpbYJys+zxcjANPb8NlWjaizVN6knjdn66YTo0tWaORqXFw5G3essCqWrnv5w6
         Y80ykoUH2srFsITSADJABVjmRIx3REpt1yC68Z5d1CkHlhFJsByCm2KvMIYOhgMSGZRc
         LWIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV3ai4HHZFUdF57gZ7dyuR5xzZPjdocSlymVBkVm+1KB3GhGnr6
	J90op62tPZS+Bl8k3cqbmpAcMweJH/m0M5ItRymyoMp4XaVrdPtrJkYnDxF3rzPFfKNEUTWI0UD
	ETBslodq9QSubHlT+hVTmN8JI/Ch6Xtvx/FYFS6hQR8F5+H9xt8SKlRoVRgNLjJWd7w==
X-Received: by 2002:aa7:928b:: with SMTP id j11mr49326101pfa.200.1557326693424;
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/wMPFJGajzafW4hJmUNBiTYhjwiVjX5uroXXVc7zRWc/3VOFofsEfbByZYvnkSwkxgwJ6
X-Received: by 2002:aa7:928b:: with SMTP id j11mr49325958pfa.200.1557326692173;
        Wed, 08 May 2019 07:44:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326692; cv=none;
        d=google.com; s=arc-20160816;
        b=BOSPNteRkDFMi121k48cr6R6DhJ6X5ROx4IX6InSpqAWhzfyEwQzw7Gahv3gIX3uTh
         ifeUE/QsBmCcn3gzF4M2X8qxeWdkFyniTut3s1nPQu8p1XB1N+RALpL3BWV3JVlnuLT5
         vzprdnKgb9Cb2oG0+CGep1WznhGpOgWYLVHxf0LnWxPzNejW8Ov+PIJzHtJ9WA+4e09R
         4A59T77sluaeJJ9b/YJK43/3pAspZDVoN5hN9FcXC69bWMg0Aek89KAxBzSvcGxtWuyf
         FGPHMI9c9JamMHZ5wTclJPUeD7vZGCTlKe589QnSDC5++cqKq25G1ZeZKKmxj2IiZPFw
         0AJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WDFDEcXg+f/4xOnB0EiSvj+2Wa4G0QK/3j1Q+39oVvk=;
        b=z8c6BdrSWiFZdIqkYKcPONxVfiU9gy1gUlb7QMlDMjubqNyNgoV0xEvUdy95v0LcbW
         fJX8bXOAcRkrUBmrbLljpIrUiczqBmNLAc8j8vBVgbS2DxieABppA8LpFiT8U3+Qg5Sc
         iDWsJqNTZSos/RxL+sNBmm7Z20bhs3M3eQZlTqevg3R7bHQ/H9N67n36IWQ5eGGeqjxB
         XLTr9/FqpwrRnDqJtXemEzgD9qDUpUaCb282I+33sjYmZAu+T/Zb9RaG3pg2taMn8VgL
         gwf176VLMNGRpVADCLlyMNQdObVJX9UNazPH6sa7cInxBmLYNDWAqN3GsjKWvfaPHA/x
         CZkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id i4si16013585pfa.218.2019.05.08.07.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:51 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga005.jf.intel.com with ESMTP; 08 May 2019 07:44:46 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 51F061123; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 52/62] x86/mm: introduce common code for mem encryption
Date: Wed,  8 May 2019 17:44:12 +0300
Message-Id: <20190508144422.13171-53-kirill.shutemov@linux.intel.com>
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

Both Intel MKTME and AMD SME have needs to support DMA address
translation with encryption related bits. Common functions are
introduced in this patch to keep DMA generic code abstracted.

Signed-off-by: Jacob Pan <jacob.jun.pan@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig                 |  4 ++++
 arch/x86/mm/Makefile             |  1 +
 arch/x86/mm/mem_encrypt_common.c | 28 ++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+)
 create mode 100644 arch/x86/mm/mem_encrypt_common.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 62cfb381fee3..ce9642e2c31b 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1505,11 +1505,15 @@ config X86_CPA_STATISTICS
 config ARCH_HAS_MEM_ENCRYPT
 	def_bool y
 
+config X86_MEM_ENCRYPT_COMMON
+	def_bool n
+
 config AMD_MEM_ENCRYPT
 	bool "AMD Secure Memory Encryption (SME) support"
 	depends on X86_64 && CPU_SUP_AMD
 	select DYNAMIC_PHYSICAL_MASK
 	select ARCH_USE_MEMREMAP_PROT
+	select X86_MEM_ENCRYPT_COMMON
 	---help---
 	  Say yes to enable support for the encryption of system memory.
 	  This requires an AMD processor that supports Secure Memory
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4ebee899c363..89dddbc01b1b 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -55,3 +55,4 @@ obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
 
 obj-$(CONFIG_X86_INTEL_MKTME)	+= mktme.o
+obj-$(CONFIG_X86_MEM_ENCRYPT_COMMON)	+= mem_encrypt_common.o
diff --git a/arch/x86/mm/mem_encrypt_common.c b/arch/x86/mm/mem_encrypt_common.c
new file mode 100644
index 000000000000..2adee65eec46
--- /dev/null
+++ b/arch/x86/mm/mem_encrypt_common.c
@@ -0,0 +1,28 @@
+#include <linux/mm.h>
+#include <linux/mem_encrypt.h>
+#include <asm/mktme.h>
+
+/*
+ * Encryption bits need to be set and cleared for both Intel MKTME and
+ * AMD SME when converting between DMA address and physical address.
+ */
+dma_addr_t __mem_encrypt_dma_set(dma_addr_t daddr, phys_addr_t paddr)
+{
+	unsigned long keyid;
+
+	if (sme_active())
+		return __sme_set(daddr);
+	keyid = page_keyid(pfn_to_page(__phys_to_pfn(paddr)));
+
+	return (daddr & ~mktme_keyid_mask) | (keyid << mktme_keyid_shift);
+}
+EXPORT_SYMBOL_GPL(__mem_encrypt_dma_set);
+
+phys_addr_t __mem_encrypt_dma_clear(phys_addr_t paddr)
+{
+	if (sme_active())
+		return __sme_clr(paddr);
+
+	return paddr & ~mktme_keyid_mask;
+}
+EXPORT_SYMBOL_GPL(__mem_encrypt_dma_clear);
-- 
2.20.1

