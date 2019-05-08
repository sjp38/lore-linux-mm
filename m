Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3782C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81039205ED
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81039205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C77286B026C; Wed,  8 May 2019 10:44:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C6216B026E; Wed,  8 May 2019 10:44:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 658426B026B; Wed,  8 May 2019 10:44:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF0646B026F
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:41 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a97so11667249pla.9
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I+6wOyh018CdSW3M6/P7TyGLXnkc+VcasOUnlcz5gSo=;
        b=a6vH16BJMwIf5OaVh0LUgpaw5frYa5SAaz8fjEDDP2KBBKPQqyQZLPtzK3kmBchHeT
         YxLQ3nfS9hmrDeE9MyDccipH9rpFKFpPvboxqOyefOmYee9GlqsJ1aqUPxpXr0mh5/Cl
         2iYrJ4bVxYGuz2YZ2Jtt3LLt5y6gnKPuF5u1iYXuTci9O1F5tmQkXT6uKWeazl108dgo
         sWImEWRQwlyl1DcE2DtI6nkTeNFVimiYTAuSTNP0vDLCVLwaweVBVyWBg3JA1ifNL3Y5
         cATAwayVbj4c8YeM3642XK6ZCiQIWcvD4LdqBp8EzuoDLNDO/bqb5gdadhRi5uAfeS8w
         4KlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUf7LCVlw2W7DWUEcrXWZL2ph+38pMVeLYwpGwmPjP7fc6qzyM5
	6ENfhJ9M1FP8see2aDW45iswnCBak8b7AFUf5+Pi+nNTd+Lg4+j0P/z58MhCYbpBBGvDtj1T9+U
	ERX9OvVuXiyenqaF2OEWOPOjgFGDtXSy1dIwoccBQ3sirABNVNBaEMxw6E8ywq/00jw==
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr46619546pgd.6.1557326681622;
        Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0prfdz+TSoDBD7/3r3oSu4niaBRHyXYWaLwv/HgLJORY6TlucUtGzf6zZRdfOYtslO3VG
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr46619397pgd.6.1557326680206;
        Wed, 08 May 2019 07:44:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326680; cv=none;
        d=google.com; s=arc-20160816;
        b=SehCZ8jo6Q7roCGPKrvt4RdcmcCwPM6yUwFJwWmCnRa015YpuXiAc0FTZJifzZf2+Y
         GhDaWRUco2PjBgmlGP+xDI9UgRGvlSDtsaWysdZfzPNSt+E3od1DGxB4De/9XTZSJlIL
         LvED1nQFN+aMpFKJ/SqOEq44amEQck4vKHDcrC4z1X77aDn3QD7RBWkv9NhB/R5G1NtV
         xZ+GubXkO7YSRNBZe6PcwOv+eTfSvk76E92f3vPSQCER4c4ZaoDE7sA1dfC6oKXiILrY
         tRmIC0SyHiCwHv//W+Ip9qq9UsWJgUG+YFt8k1LQqDpMQ7iPYqcyFhIpM7PG9gblvPI5
         yahQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=I+6wOyh018CdSW3M6/P7TyGLXnkc+VcasOUnlcz5gSo=;
        b=RsypiUjcaitDvZhpd+zgj4pyEwxWCNnULnIOq7SSOn0IZWk064H2OZizZS3WVn5Ua+
         UX0lWdFPXZHKNXIw7cf7WhhC4er/skZzio1Veanqhn7zf7RGptiLW8uo0d3H5OZU/KUg
         4Q6n1lrYXF3EVCAgW+eIr8WjtwAYYUEy3v180LNZAR80/YO9nvCOhdWOYPahDceDwxmR
         XrKrxT593F+TbdxhybMAlgcx1hgVWstYcc7dywwml+SpcJSpcMaBs6HSx6M5P7QNMSPy
         DqBzXnETPcRDI6dRETyYzBa5fz9H7KOIN/EVCpRz1k0rsUi/EdrAURi3Ij2jC+MOgQlM
         0nKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e61si23294206plb.123.2019.05.08.07.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:39 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga002.jf.intel.com with ESMTP; 08 May 2019 07:44:35 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 07B934FD; Wed,  8 May 2019 17:44:28 +0300 (EEST)
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
Subject: [PATCH, RFC 08/62] x86/mm: Introduce variables to store number, shift and mask of KeyIDs
Date: Wed,  8 May 2019 17:43:28 +0300
Message-Id: <20190508144422.13171-9-kirill.shutemov@linux.intel.com>
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

mktme_nr_keyids holds the number of KeyIDs available for MKTME,
excluding KeyID zero which used by TME. MKTME KeyIDs start from 1.

mktme_keyid_shift holds the shift of KeyID within physical address.

mktme_keyid_mask holds the mask to extract KeyID from physical address.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 16 ++++++++++++++++
 arch/x86/kernel/cpu/intel.c  | 16 ++++++++++++----
 arch/x86/mm/Makefile         |  2 ++
 arch/x86/mm/mktme.c          | 11 +++++++++++
 4 files changed, 41 insertions(+), 4 deletions(-)
 create mode 100644 arch/x86/include/asm/mktme.h
 create mode 100644 arch/x86/mm/mktme.c

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
new file mode 100644
index 000000000000..df31876ec48c
--- /dev/null
+++ b/arch/x86/include/asm/mktme.h
@@ -0,0 +1,16 @@
+#ifndef	_ASM_X86_MKTME_H
+#define	_ASM_X86_MKTME_H
+
+#include <linux/types.h>
+
+#ifdef CONFIG_X86_INTEL_MKTME
+extern phys_addr_t mktme_keyid_mask;
+extern int mktme_nr_keyids;
+extern int mktme_keyid_shift;
+#else
+#define mktme_keyid_mask	((phys_addr_t)0)
+#define mktme_nr_keyids		0
+#define mktme_keyid_shift	0
+#endif
+
+#endif
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 5dfecc9c2253..e271264e238a 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -591,6 +591,9 @@ static void detect_tme(struct cpuinfo_x86 *c)
 
 #ifdef CONFIG_X86_INTEL_MKTME
 	if (mktme_status == MKTME_ENABLED && nr_keyids) {
+		mktme_nr_keyids = nr_keyids;
+		mktme_keyid_shift = c->x86_phys_bits - keyid_bits;
+
 		/*
 		 * Mask out bits claimed from KeyID from physical address mask.
 		 *
@@ -598,17 +601,22 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		 * and number of bits claimed for KeyID is 6, bits 51:46 of
 		 * physical address is unusable.
 		 */
-		phys_addr_t keyid_mask;
-
-		keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, c->x86_phys_bits - keyid_bits);
-		physical_mask &= ~keyid_mask;
+		mktme_keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, mktme_keyid_shift);
+		physical_mask &= ~mktme_keyid_mask;
 	} else {
 		/*
 		 * Reset __PHYSICAL_MASK.
 		 * Maybe needed if there's inconsistent configuation
 		 * between CPUs.
+		 *
+		 * FIXME: broken for hotplug.
+		 * We must not allow onlining secondary CPUs with non-matching
+		 * configuration.
 		 */
 		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
+		mktme_keyid_mask = 0;
+		mktme_keyid_shift = 0;
+		mktme_nr_keyids = 0;
 	}
 #endif
 
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd6e52f..4ebee899c363 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
+
+obj-$(CONFIG_X86_INTEL_MKTME)	+= mktme.o
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
new file mode 100644
index 000000000000..91a415612519
--- /dev/null
+++ b/arch/x86/mm/mktme.c
@@ -0,0 +1,11 @@
+#include <asm/mktme.h>
+
+/* Mask to extract KeyID from physical address. */
+phys_addr_t mktme_keyid_mask;
+/*
+ * Number of KeyIDs available for MKTME.
+ * Excludes KeyID-0 which used by TME. MKTME KeyIDs start from 1.
+ */
+int mktme_nr_keyids;
+/* Shift of KeyID within physical address. */
+int mktme_keyid_shift;
-- 
2.20.1

