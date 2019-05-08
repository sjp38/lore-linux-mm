Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C04AC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BE5A218CD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BE5A218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76BA06B0266; Wed,  8 May 2019 10:44:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62E276B026B; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A98E6B0266; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBA676B000E
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e128so12720303pfc.22
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9YHtkwxGIV+d1GTMPRWNkobcvSAfYRY2fTtas/iQlJE=;
        b=qHf/wfgvhmoEF7zRixKI9le92Y2JusR8R5eYBfdWp03j3PJ9Llmq0nkWkU2YbOSqyi
         gMDSRNM1bCJ2Q6YnTRKQ8IHSalTDOtMCweAOF60+/FiOovjb3RC7fvUoWTJ3uQ+kvuLr
         aHGlzR+tO0uIgvxKUthOuVbQ9SxfX2si9/tSOoepBJGBg5o0SREfi3NJvciCdIrBWrfa
         oxvzpjFDL9uODuS9gcucZWQHBKXt9dGcr6CuhNoJ4an7AwxWIJEYkcJt6R1I+214Uuke
         87Z1YnmIPNVGIjnUi/IChhrdgYWDoR8p6/deJzRELaoVYBHppyfIRwj2YrvfYKElnGi2
         bPpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXdJ8nPz5JolCkfGniF56DV3I4CF7MLYsmORKbOZ6hAuRe6lr9R
	it3kvmKlzT4y6XbtQohE9LhtZIeAD8ksv7jhKFwRnljn3gJiLlA/DcTFUDIiSPNjyk1rDnmSLmi
	XFPRfIeNk1b0lm4tcXPcKjF3qaVuntsxDHDR/pG6RbivrkBwckafs/5dvzROOmcCHcw==
X-Received: by 2002:aa7:8046:: with SMTP id y6mr49991981pfm.251.1557326680575;
        Wed, 08 May 2019 07:44:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxit4LEwvUDJytGlb0jv2oVlSt2+r+DxGNZ2vK/dbtaEh1ndBOWzguWcWYKSucYUtgSlBI
X-Received: by 2002:aa7:8046:: with SMTP id y6mr49991865pfm.251.1557326679456;
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326679; cv=none;
        d=google.com; s=arc-20160816;
        b=yOAP5hx6XB1T/QnDgU3A4heRaCdcko6GHtur6RcrdLTSF6wz2RYweunkA4hvt9lX/C
         WRJmBOD+vsuNkK1DARyQdSMrcjtES5PO6E5d4GSDR/Hq2zW97S3d/q/bxE/HMNt34O5Z
         GavEJKLBKu7Ek1FmeYK+OdY9sqjfXk0epBzVGR/VpvXXVPIlA+MPvS7/zGVKk+oGfY3R
         yPeij/m3XF8vq4iJV1TykKxZFqvK+ITk13Z3407tSz/eYF0FhwaSuCHY7IXTIpOZQ8oN
         wFn2iVdp1gJsLA9Bx1kMofggA/h7jYaiwBuoKdyUXMvG3F/OsSuntK/6TgWkZ0WAcFrT
         aTjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=9YHtkwxGIV+d1GTMPRWNkobcvSAfYRY2fTtas/iQlJE=;
        b=VH0ptbqW4ZS12p8twivP0pLagaEwYmAimfLmbxLZHPL8g/M2FWRQL6HZlK8e/WkyGU
         91rBtlUv1ANBw/sz89l/kheNtP3+5JKxKM6OIv2bbnDrULCHC2OrJORv5rOU6oLaq/BK
         WBWg21OEjJaTzNhCC4fF/9fgz7KxfMDR80dcbRE/aVusqgNFLcDeo862bnl4OnIC84VX
         n+ik5mNYmjI5IhedOtOhEiv+vDzEDMZsJqR6cdJ/d9TVLg464d74FlVWkMTWAM2ngamY
         xaylvfcSkDnK4+PN51WbJ6vfbBMlF0PlcXkgexUOayPOrkRsr3aXrjy/0rCi/0lgicFB
         Hp/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:38 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga001.fm.intel.com with ESMTP; 08 May 2019 07:44:34 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id E99E54F8; Wed,  8 May 2019 17:44:28 +0300 (EEST)
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
Subject: [PATCH, RFC 07/62] x86/mm: Mask out KeyID bits from page table entry pfn
Date: Wed,  8 May 2019 17:43:27 +0300
Message-Id: <20190508144422.13171-8-kirill.shutemov@linux.intel.com>
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

MKTME claims several upper bits of the physical address in a page table
entry to encode KeyID. It effectively shrinks number of bits for
physical address. We should exclude KeyID bits from physical addresses.

For instance, if CPU enumerates 52 physical address bits and number of
bits claimed for KeyID is 6, bits 51:46 must not be threated as part
physical address.

This patch adjusts __PHYSICAL_MASK during MKTME enumeration.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/cpu/intel.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 3142fd7a9b32..5dfecc9c2253 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -589,6 +589,29 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		mktme_status = MKTME_ENABLED;
 	}
 
+#ifdef CONFIG_X86_INTEL_MKTME
+	if (mktme_status == MKTME_ENABLED && nr_keyids) {
+		/*
+		 * Mask out bits claimed from KeyID from physical address mask.
+		 *
+		 * For instance, if a CPU enumerates 52 physical address bits
+		 * and number of bits claimed for KeyID is 6, bits 51:46 of
+		 * physical address is unusable.
+		 */
+		phys_addr_t keyid_mask;
+
+		keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, c->x86_phys_bits - keyid_bits);
+		physical_mask &= ~keyid_mask;
+	} else {
+		/*
+		 * Reset __PHYSICAL_MASK.
+		 * Maybe needed if there's inconsistent configuation
+		 * between CPUs.
+		 */
+		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
+	}
+#endif
+
 	/*
 	 * KeyID bits effectively lower the number of physical address
 	 * bits.  Update cpuinfo_x86::x86_phys_bits accordingly.
-- 
2.20.1

