Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76886C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3902B21874
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3902B21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 474046B000E; Wed,  8 May 2019 10:44:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BDD86B0010; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20F476B0269; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC60B6B0010
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d12so12786928pfn.9
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Fyr98K7S1me9TsMulAhHdp7GU89gOrJm0h1JtvOHlB0=;
        b=tAcinjFahaLg7zbkDETG58Rnwyd9CBxrxwSerUiQg1r5dc4dIBjsiBNk1CKZB84qgt
         pLUNNg9BCfz8d0ONkUez7sa2CO8woZUY48I1AYeMIy58zEYu3LcWM8/ePIuWqNnyEot1
         C+kcCoYMyYpgoF0S6L4CFGjuPuj6RItj3R2mChYSqGUglrOzFhwUqtRdkUHIeXjdR0/q
         Iq2nbaE9P1YJldwJisq/6HwFCZQ1qklBrUfToc3jr1aLD/M7qXZcdkP4VmplJZZzu71T
         lJFVlKx85VXHfEomtRB9kR/fJ+9oquGUGat/4SSZt7gjAA9iS+5Wq29r782nseUmDjOz
         5oAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVCBePqpoBAilsrJbCqAYb+ZFWKoTiYCwCnFdeNzphDGs07bsx7
	ES4RtsRIBy+hSZ29Zf33FaR/UCO6N6oRsJl5V34ZREXiqIYN6Llvuu/o+eU9/5ojZ/YGHbSRZPR
	PaxA4zlRTcOFb7OVUr8Of41TisvftrKn9mvj9RzUQP34XB0rkxwKbUh9WY+EYIBZPJg==
X-Received: by 2002:a63:309:: with SMTP id 9mr26237063pgd.49.1557326680548;
        Wed, 08 May 2019 07:44:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJFsdd1KxcLolWsiGzuMY0LrkiQKUGZe818aDMPAdEBxzua4h7B8d9vfuikQsNidenHptb
X-Received: by 2002:a63:309:: with SMTP id 9mr26236972pgd.49.1557326679727;
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326679; cv=none;
        d=google.com; s=arc-20160816;
        b=oVa1Lna4VuLFleJflJyHG9LQQG2m3HZYvi63sH8h1j1l5KClsXfz4f8b4gtDzynQou
         RPeIxW0xsHuEgLLPtAgl/U6qtpSAfxpljKgMuD5C5lNnnhVzqJBDVqisjQZ4FXgnnaNs
         hhNpBBQWQwmz8AAKpYUi91Jx+PCL/PdKVN25ft19ZJOg6QOQGcZbgJMxyvZXqxBFFvsj
         GgL/Z5QTSDcGDjuXwBHuOV967A47Miux9LZcQ9/nusjIxososKkt8xsnRwRPRijPjfTx
         hJuuHNEcY51qGNdOpotSve6PTdkUkPDqMtxFOB6e6q3yQsde76Akk17+5Y9VG8HruzNA
         g8LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Fyr98K7S1me9TsMulAhHdp7GU89gOrJm0h1JtvOHlB0=;
        b=xQt92rSVbUhIW0RUSe+a5dUAFpojuf3F2c+B5mHWLwCvLXv/a38X2zd24j02uBA0nu
         UeGao/FopMdZdbY3unLpwAe6Iq1tVXnG/+90dL2zx1EeDgCy2l4kbANg0lV8CBDV3tRK
         sNqWOLqSZgAmDTBV5tBmJ/xM5YB5VYOgxiZMfH4st3hGyLaBYSeV4diVhQErAdEheRm9
         4rbBhQPfU69JDeKanL4XRWWk9jkYKIRDZ3neKyHAPRjp/Zf5+rf//zNtbegqYqZM0okG
         pBfvX5e9xNM3SKHvZStZ9hMVftrOcw8f0fj7KIK6I3LvTncj5dJJiZNbl7TiHQrENDhn
         O1LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w14si24148884ply.226.2019.05.08.07.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,446,1549958400"; 
   d="scan'208";a="169656525"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:35 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 15EF358A; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 09/62] x86/mm: Preserve KeyID on pte_modify() and pgprot_modify()
Date: Wed,  8 May 2019 17:43:29 +0300
Message-Id: <20190508144422.13171-10-kirill.shutemov@linux.intel.com>
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

An encrypted VMA will have KeyID stored in vma->vm_page_prot. This way
we don't need to do anything special to setup encrypted page table
entries and don't need to reserve space for KeyID in a VMA.

This patch changes _PAGE_CHG_MASK to include KeyID bits. Otherwise they
are going to be stripped from vm_page_prot on the first pgprot_modify().

Define PTE_PFN_MASK_MAX similar to PTE_PFN_MASK but based on
__PHYSICAL_MASK_SHIFT. This way we include whole range of bits
architecturally available for PFN without referencing physical_mask and
mktme_keyid_mask variables.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_types.h | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index d6ff0bbdb394..7d6f68431538 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -117,12 +117,25 @@
 				 _PAGE_ACCESSED | _PAGE_DIRTY)
 
 /*
- * Set of bits not changed in pte_modify.  The pte's
- * protection key is treated like _PAGE_RW, for
- * instance, and is *not* included in this mask since
- * pte_modify() does modify it.
+ * Set of bits not changed in pte_modify.
+ *
+ * The pte's protection key is treated like _PAGE_RW, for instance, and is
+ * *not* included in this mask since pte_modify() does modify it.
+ *
+ * They include the physical address and the memory encryption keyID.
+ * The paddr and the keyID never occupy the same bits at the same time.
+ * But, a given bit might be used for the keyID on one system and used for
+ * the physical address on another. As an optimization, we manage them in
+ * one unit here since their combination always occupies the same hardware
+ * bits. PTE_PFN_MASK_MAX stores combined mask.
+ *
+ * Cast PAGE_MASK to a signed type so that it is sign-extended if
+ * virtual addresses are 32-bits but physical addresses are larger
+ * (ie, 32-bit PAE).
  */
-#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
+#define PTE_PFN_MASK_MAX \
+	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
+#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
 			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
-- 
2.20.1

