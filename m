Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AA8AC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D213216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D213216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C1FD6B02A0; Wed,  8 May 2019 10:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F09626B02A7; Wed,  8 May 2019 10:44:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0AE16B02A6; Wed,  8 May 2019 10:44:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9236F6B02A2
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:53 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x13so12797793pgl.10
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ErLNP2t/2r70xowRLHa6YSi8qQGCcGwICK6NMrzI+98=;
        b=lHShVbSJ0HCxugr6lj2t5xSBuTzjjGbwuMnTyhw0KDWtda2kioLrUizaz5wTw0LHlS
         G1FkXJ0oUygopW6bLIfXpRQGXyyKCtOG7OGEryEv0XUD8Ch6ozSZ/f8dTVU+o0UC83Vu
         /S7JZf2bANNpIcClT62O5nrz4AZG4vxIpVK0Q9k40iY0Vi53HiTxTugM6ZUhDKJDR/vA
         4/Dqhz6bxQm1DJJPDGzJAaLBmckZHhwaj953DhQyaEMaTmO1ZHfhhP1jkcuGMVmYTcz/
         u1qtV0jw111NIv3qjE4AwYwP2jotgQgZ/iaTjXoJFdXnjkNOXafvRmSpx2AvcAs0fiP8
         c0BA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQVohXvwkyNhhAl8Bcmueh9nIDo6GZn6PxvlMaDJ6xiwoQM4S6
	hsZsAqN9HmWjGEhoNShyTYAjKdcpDBJhqNF0sVfOivfRTxqO7sxEzHEQ2yDzM6EK8baTDqQH6QD
	REl9FMG8BwuOj7BQpxNwdJ7mYHGMpOPNJwxbsrbPQW2ljN9heB7xcUW6bRrDYdD87kA==
X-Received: by 2002:a65:610a:: with SMTP id z10mr47537143pgu.54.1557326693229;
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfyDDV7cXYZ/fpZVUOKKD1p0jt35533WG7+5ZbrLIbm7gUEWOYCQcfs/lJjY5M62PAYzfY
X-Received: by 2002:a65:610a:: with SMTP id z10mr47537050pgu.54.1557326692415;
        Wed, 08 May 2019 07:44:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326692; cv=none;
        d=google.com; s=arc-20160816;
        b=K31RUxQR2lu6/TW9kHtZKkDqRgHr9FHLvKyvz7fsaQsvRmXst5qxZjkYTV340Qo9UY
         86W4qr3mGfKTMc6HKNQHOE1sFAG5GpaVnrijHTNncdcOfkFTXg8+iDZWR9bhQFarM2xV
         9OH4zcKI0cmBZ97KbKv5nhrQI0PJD2U+kkAcC55Vzjxt036yUHv36J5jtsmWUSAufPMu
         COgoNVzcrI1wFbznTHSz97BTdFvE54/yF5V7oxDn3FLc1fiCkrzCK8m0ZeCKHggldzaX
         uL6O+tJmo28YLKknLcUEy3uvXhKFOW+xsltMyaTKnJkE9MVEL+5oNIAKGeS0rgWQ/Vb2
         jftQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ErLNP2t/2r70xowRLHa6YSi8qQGCcGwICK6NMrzI+98=;
        b=0mdYpUmqgH+/kY6rLcbLnJ862paGJ53USmppB5tS1P0IAUD3fBIBczbbhbTWDYOLUm
         Oq5RobpzvQ/Am3dozPWJAy4bWkVKELpUj1qhitwqbFi5G9312GE2CcXBsI2oyxk6FHg1
         zAe7w615xrpFkeNK5KVI42AlDJKKljiNZzr5ERdaLSdCOjKssnI1BjvRRBUxbk9OaZ9c
         z6T/huGDan0YZwm+FRgUiDF94g893NAyBQmChvrelIo7fTYV0LpANWVVemW7WC3RAKku
         pbMiQluw9TZxJqi/NNNRv1MTC4Xmu3exbU8YCGV9rR6bIQ2IBSRDqSJbJn93j9RrOU7D
         r2Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id i4si16013585pfa.218.2019.05.08.07.44.52
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
	id 672C3116A; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 54/62] x86/mm: Disable MKTME on incompatible platform configurations
Date: Wed,  8 May 2019 17:44:14 +0300
Message-Id: <20190508144422.13171-55-kirill.shutemov@linux.intel.com>
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

Icelake Server requires additional check to make sure that MKTME usage
is safe on Linux.

Kernel needs a way to access encrypted memory. There can be different
approaches to this: create a temporary mapping to access the page (using
kmap() interface), modify kernel's direct mapping on allocation of
encrypted page.

In order to minimize runtime overhead, the Linux MKTME implementation
uses multiple direct mappings, one per-KeyID. Kernel uses the direct
mapping that is relevant for the page at the moment.

Icelake Server in some configurations doesn't allow a page to be mapped
with multiple KeyIDs at the same time. Even if only one of KeyIDs is
actively used. It conflicts with the Linux MKTME implementation.

OS can check if it's safe to map the same with multiple KeyIDs by
examining bit 8 of MSR 0x6F. If the bit is set we cannot safely use
MKTME on Linux.

The user can disable the Directory Mode in BIOS setup to get the
platform into Linux-compatible mode.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/intel-family.h |  2 ++
 arch/x86/kernel/cpu/intel.c         | 22 ++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/arch/x86/include/asm/intel-family.h b/arch/x86/include/asm/intel-family.h
index 9f15384c504a..6a633af144aa 100644
--- a/arch/x86/include/asm/intel-family.h
+++ b/arch/x86/include/asm/intel-family.h
@@ -53,6 +53,8 @@
 #define INTEL_FAM6_CANNONLAKE_MOBILE	0x66
 
 #define INTEL_FAM6_ICELAKE_MOBILE	0x7E
+#define INTEL_FAM6_ICELAKE_X		0x6A
+#define INTEL_FAM6_ICELAKE_XEON_D	0x6C
 
 /* "Small Core" Processors (Atom) */
 
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index f402a74c00a1..3fc318f699d3 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -19,6 +19,7 @@
 #include <asm/microcode_intel.h>
 #include <asm/hwcap2.h>
 #include <asm/elf.h>
+#include <asm/cpu_device_id.h>
 
 #ifdef CONFIG_X86_64
 #include <linux/topology.h>
@@ -531,6 +532,16 @@ static void detect_vmx_virtcap(struct cpuinfo_x86 *c)
 #define TME_ACTIVATE_CRYPTO_ALGS(x)	((x >> 48) & 0xffff)	/* Bits 63:48 */
 #define TME_ACTIVATE_CRYPTO_AES_XTS_128	1
 
+#define MSR_ICX_MKTME_STATUS		0x6F
+#define MKTME_ALIASES_FORBIDDEN(x)	(x & BIT(8))
+
+/* Need to check MSR_ICX_MKTME_STATUS for these CPUs */
+static const struct x86_cpu_id mktme_status_msr_ids[] = {
+	{ X86_VENDOR_INTEL,	6,	INTEL_FAM6_ICELAKE_X		},
+	{ X86_VENDOR_INTEL,	6,	INTEL_FAM6_ICELAKE_XEON_D	},
+	{}
+};
+
 /* Values for mktme_status (SW only construct) */
 #define MKTME_ENABLED			0
 #define MKTME_DISABLED			1
@@ -564,6 +575,17 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		return;
 	}
 
+	/* Icelake Server quirk: do not enable MKTME if aliases are forbidden */
+	if (x86_match_cpu(mktme_status_msr_ids)) {
+		u64 mktme_status;
+		rdmsrl(MSR_ICX_MKTME_STATUS, mktme_status);
+
+		if (MKTME_ALIASES_FORBIDDEN(mktme_status)) {
+			pr_err_once("x86/tme: Directory Mode is enabled in BIOS\n");
+			mktme_status = MKTME_DISABLED;
+		}
+	}
+
 	if (mktme_status != MKTME_UNINITIALIZED)
 		goto detect_keyid_bits;
 
-- 
2.20.1

