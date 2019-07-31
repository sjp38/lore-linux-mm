Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB4B4C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 841EB20693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="ZzxPi2vB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 841EB20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 482BE8E0036; Wed, 31 Jul 2019 11:14:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BD388E0035; Wed, 31 Jul 2019 11:14:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D3988E0036; Wed, 31 Jul 2019 11:14:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2AB48E0035
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so42556981ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:14:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xZCrLs3XD8OGAT3ycWjyC35TQ10BuGZLp4dKCEJJsRg=;
        b=biYdG+ioRHWysnMecnRvlACirQP/ziwcljMru71kVQjerakhnA4tnfFMopKJk6Utih
         g8OiDnYBnsXH9FxHOpgpFH02v2PbKTQLqyX5wbxcegBhQsMxM2PP6EevncXCSZzMuDkH
         /+ls6V55O+xrtx90FNwzLrhJjUXfLtGpus7Tg+nJjazU6TGcB1Z1riZ4JDd6KXilzJyh
         gvPkiSMPcojMkCelyxUCrNFPg+nwhakVt4pbstns78ApYpmA/NgbfXowaiXAMrWQn3iL
         TCdjb/qHYaizBtH2fqBqKoRlRoEThLK32CR5nAI+Q5qixZXrY6dRnGILBznDKf9EZnsm
         HxbA==
X-Gm-Message-State: APjAAAUsCVXMVqK1kNNMpX8uC8KJgs22lGp6/mkW/9raAvuK2IXU6g1H
	xYK6KWnJCsI7X0tfZJ4TSDWH+zU4EsBeAvsgMB5kE2vRpeDs30dXGz5BMmP9nckRsJcPDe16zUF
	/fT3XvLL8LA86OEBY+nh0ymxJjz0HNj8anhz0eIaCeYw4eVwRAqt2n3B98JbGvZs=
X-Received: by 2002:a50:9263:: with SMTP id j32mr106969636eda.121.1564586042414;
        Wed, 31 Jul 2019 08:14:02 -0700 (PDT)
X-Received: by 2002:a50:9263:: with SMTP id j32mr106969505eda.121.1564586041083;
        Wed, 31 Jul 2019 08:14:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586041; cv=none;
        d=google.com; s=arc-20160816;
        b=IEH7b6zpm/VzHgWsf4XVcmUiJ6+cfFj2UYM1KsJsCe/RzIe0+8MuMeE0iV6sVCA48W
         WlzOfnFb6uF9EOZAX1z7WKu7/ARJOY3Env0NFwAqtYIY+AOnUMHax+l65uk3eTO+TmEQ
         KKhFSF+J+qN+r0JO+Q4MHev5wRmwEnl1IF6ZSJfipHnviF/JGGW7fBB8ZeX1ZJIjczwz
         KllixwWNV0Y0eRbM5ayaEV0NYkVyEHaMfvPIUfO3Sgow38S1hxuBo9stoiTR80h+4Ity
         iXSrhfwrtLDe0gcC4nHondQ8Jh/WnIPsek55OilzankVU6WLPuhHnrJNm3sM2lYGkkQJ
         +YJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xZCrLs3XD8OGAT3ycWjyC35TQ10BuGZLp4dKCEJJsRg=;
        b=w8TSQhoPkRPC9xpAZvwx+bMH1UlpQAyMw1Jmi70Y5kb16PKD1gYMDkdQ632ppPWczn
         PKcBOitp2P56XeIXzATWSGlmnB582vOMn40GUQhm9lpRPElQFxiJp46a2wL351izlV5a
         edmLK6RcQbP/+YBWmOqJhUMjFdMPToU1xn/GsfTTwnZbl/rSZHPhoWic/S0H2xiWSuOx
         Jq6siC8Z0nQpyxqkQvWyhT7EjgGunP/uBi3o57mWhRxn2aJ6lxP1PzVQAItilXx3S14f
         dejsgWlqvmtpAFF8fzb6vc+3zZSq38EsG2oauOYcZgIZM66/huO5HgBcqJDJ8ZtPj+JK
         b7tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=ZzxPi2vB;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id no5sor18524964ejb.51.2019.07.31.08.14.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:14:01 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=ZzxPi2vB;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xZCrLs3XD8OGAT3ycWjyC35TQ10BuGZLp4dKCEJJsRg=;
        b=ZzxPi2vB6H9up8THEqzUbCNwa2E1YZmLUp1GoionKsfBr1KQUEhgprj6heyI63fXrw
         H+vh1QV4vFyU7pFE4ViKBgvENglga5fVeNfWMRPCrZCi98qsi+r5zk6N62pl/svz4DjD
         WnRM8TC+Pj61sbunfqi5fGW98WW6DAYki4QW6kO4N7z8wCx7WTMte/S7jP4fuei7n7eq
         Hftvw0iaa2a1kXT25K4D3+dXvLj2vwBC0o2P1NCeJjiYQsXP0Nqqds5A7BCA5ZOq7vv9
         366A7NPLtjGoulNRAC6+0JGz6sJc40LnEY1OPEQYpV1Yi42ZVQe4Pz+slBHXGt07SvXV
         N3yg==
X-Google-Smtp-Source: APXvYqzi+h2CEkJox27TxBwILuSunR6853S6mGlis2VdUPScZU2xczXssICyuyck991q2MnJokM4kQ==
X-Received: by 2002:a17:906:1dd5:: with SMTP id v21mr65219317ejh.112.1564586040695;
        Wed, 31 Jul 2019 08:14:00 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id h10sm16374181edn.86.2019.07.31.08.13.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 4FE39104831; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 49/59] x86/mm: introduce common code for mem encryption
Date: Wed, 31 Jul 2019 18:08:03 +0300
Message-Id: <20190731150813.26289-50-kirill.shutemov@linux.intel.com>
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

Both Intel MKTME and AMD SME have needs to support DMA address
translation with encryption related bits. Common functions are
introduced in this patch to keep DMA generic code abstracted.

Signed-off-by: Jacob Pan <jacob.jun.pan@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig                 |  8 +++--
 arch/x86/mm/Makefile             |  1 +
 arch/x86/mm/mem_encrypt.c        | 30 ------------------
 arch/x86/mm/mem_encrypt_common.c | 52 ++++++++++++++++++++++++++++++++
 4 files changed, 59 insertions(+), 32 deletions(-)
 create mode 100644 arch/x86/mm/mem_encrypt_common.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2eb2867db5fa..f2cc88fe8ada 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1521,12 +1521,16 @@ config X86_CPA_STATISTICS
 config ARCH_HAS_MEM_ENCRYPT
 	def_bool y
 
+config X86_MEM_ENCRYPT_COMMON
+	select ARCH_HAS_FORCE_DMA_UNENCRYPTED
+	select DYNAMIC_PHYSICAL_MASK
+	def_bool n
+
 config AMD_MEM_ENCRYPT
 	bool "AMD Secure Memory Encryption (SME) support"
 	depends on X86_64 && CPU_SUP_AMD
-	select DYNAMIC_PHYSICAL_MASK
 	select ARCH_USE_MEMREMAP_PROT
-	select ARCH_HAS_FORCE_DMA_UNENCRYPTED
+	select X86_MEM_ENCRYPT_COMMON
 	---help---
 	  Say yes to enable support for the encryption of system memory.
 	  This requires an AMD processor that supports Secure Memory
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 600d18691876..608e57cda784 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -55,3 +55,4 @@ obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
 
 obj-$(CONFIG_X86_INTEL_MKTME)	+= mktme.o
+obj-$(CONFIG_X86_MEM_ENCRYPT_COMMON)	+= mem_encrypt_common.o
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index fece30ca8b0c..e94e0a62ba92 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -15,10 +15,6 @@
 #include <linux/dma-direct.h>
 #include <linux/swiotlb.h>
 #include <linux/mem_encrypt.h>
-#include <linux/device.h>
-#include <linux/kernel.h>
-#include <linux/bitops.h>
-#include <linux/dma-mapping.h>
 
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
@@ -352,32 +348,6 @@ bool sev_active(void)
 }
 EXPORT_SYMBOL(sev_active);
 
-/* Override for DMA direct allocation check - ARCH_HAS_FORCE_DMA_UNENCRYPTED */
-bool force_dma_unencrypted(struct device *dev)
-{
-	/*
-	 * For SEV, all DMA must be to unencrypted addresses.
-	 */
-	if (sev_active())
-		return true;
-
-	/*
-	 * For SME, all DMA must be to unencrypted addresses if the
-	 * device does not support DMA to addresses that include the
-	 * encryption mask.
-	 */
-	if (sme_active()) {
-		u64 dma_enc_mask = DMA_BIT_MASK(__ffs64(sme_me_mask));
-		u64 dma_dev_mask = min_not_zero(dev->coherent_dma_mask,
-						dev->bus_dma_mask);
-
-		if (dma_dev_mask <= dma_enc_mask)
-			return true;
-	}
-
-	return false;
-}
-
 /* Architecture __weak replacement functions */
 void __init mem_encrypt_free_decrypted_mem(void)
 {
diff --git a/arch/x86/mm/mem_encrypt_common.c b/arch/x86/mm/mem_encrypt_common.c
new file mode 100644
index 000000000000..c11d70151735
--- /dev/null
+++ b/arch/x86/mm/mem_encrypt_common.c
@@ -0,0 +1,52 @@
+#include <linux/mm.h>
+#include <linux/mem_encrypt.h>
+#include <linux/dma-mapping.h>
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
+	return (daddr & ~mktme_keyid_mask()) | (keyid << mktme_keyid_shift());
+}
+
+phys_addr_t __mem_encrypt_dma_clear(phys_addr_t paddr)
+{
+	if (sme_active())
+		return __sme_clr(paddr);
+
+	return paddr & ~mktme_keyid_mask();
+}
+
+/* Override for DMA direct allocation check - ARCH_HAS_FORCE_DMA_UNENCRYPTED */
+bool force_dma_unencrypted(struct device *dev)
+{
+	u64 dma_enc_mask, dma_dev_mask;
+
+	/*
+	 * For SEV, all DMA must be to unencrypted addresses.
+	 */
+	if (sev_active())
+		return true;
+
+	/*
+	 * For SME and MKTME, all DMA must be to unencrypted addresses if the
+	 * device does not support DMA to addresses that include the encryption
+	 * mask.
+	 */
+	if (!sme_active() && !mktme_enabled())
+		return false;
+
+	dma_enc_mask = sme_me_mask | mktme_keyid_mask();
+	dma_dev_mask = min_not_zero(dev->coherent_dma_mask, dev->bus_dma_mask);
+
+	return (dma_dev_mask & dma_enc_mask) != dma_enc_mask;
+}
-- 
2.21.0

