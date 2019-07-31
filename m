Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC962C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65B692064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="bo4uajak"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65B692064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 659958E001C; Wed, 31 Jul 2019 11:08:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E1EE8E001D; Wed, 31 Jul 2019 11:08:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C2A58E001C; Wed, 31 Jul 2019 11:08:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4A888E001D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so42578295edr.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AKmba4vf/ZPJ1ANSLVq0BszaZ5EHEw0+rluolW4cNw8=;
        b=sOzDydW1ORpSRRSrwnhzmr30IbxkCNloiBGUd6QW1o2YwIEJzFmk22919jb7kF1XuD
         RrPq0MbxHOjgLKJ1OKdx3RVwFiFCE0YESskhXaBPCMYYFZbpc9m988qXxUBs1N0o9D5e
         FLaOWALDsDU0wLEzDE/K9gkb4RJ7ohTnGUQFiH+dZIjJZx3Qq6rp6JBZqluri/07o4eF
         B70q9NE8K1GRCL++1Twb1vsIdZwQe07Ony0iA46Ez/xvWk5A64vCqcNN8eZhIYTZl61R
         xlkPubvJxnI2bYGdgvGQSP66VpRmazQ0gT+yq6WT4mL21OzxStfd1z/8ZHMXLFTwnY7t
         CFoA==
X-Gm-Message-State: APjAAAWL9hePXL3Hj181EznK7stLmUYGDN95PoeI6RwDTCgdpqPHPHsm
	vjxkVs+RRYM4oM33WwNUgBrIv74LOBN1kSNzS7qBP36R95h5Qi+x9t40TPFznzSSORSuaDJUuyy
	lgUsUqGA6pDNCAq4O9dtCY9xmhN+g82qUx3XQUwOsJsQYez6Kp2GICgAP+GETRsU=
X-Received: by 2002:aa7:da03:: with SMTP id r3mr106995590eds.130.1564585714297;
        Wed, 31 Jul 2019 08:08:34 -0700 (PDT)
X-Received: by 2002:aa7:da03:: with SMTP id r3mr106995419eds.130.1564585712875;
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585712; cv=none;
        d=google.com; s=arc-20160816;
        b=kFbcTbVPy70Trs4fHJyO741om45CUXRtjuh7NIqW6WfuYWjCrxc598jgVY0E+4w9wH
         Jq/VCyA/aZng9r1cRX5Mt8l9RIS/wMSOV5sFCQ8SjAmggtfeFZJK0NlHxfbrf4LJBzvR
         hkBQpQY1739VMalv89iekMRuAfVyer3rwYs+fr8HoI1FgiOsrVld52jHkPzwjn4oV9Q+
         NUfn1cihKCjfPSGgNuw49fMAwTe/sGx0+OluYMTd7PbaQJ0Qv03Zd5Eb70FEFVpq6/rb
         FGlh2PHBrtauEG+8AD3mFsdmK80JHUG84npAcee46AnyXljwJGc6ArwC/pUXGMhoZZzO
         4LgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AKmba4vf/ZPJ1ANSLVq0BszaZ5EHEw0+rluolW4cNw8=;
        b=0A4Cq6hV4RABubi2EyTEZT+AHBUyjKPAzTLgbVUfpFIJIC6Zeto86dBJfujriI1nrd
         TKNjnatAqPdLepzMWg9KGgwcthQ22oAfsftgVbJcGK8IvTAZguEteh+HYMwXxkXI5KCH
         8EARaYkksRUsaQEI1+DsUnPQlg2ASVC7Yb3Mp1p95C3UvT7f9y1V9mH628xdM/2x118H
         4ubBJrZqNR4194qv8exXmZq/9VhAqN2q7Bm7SRYuH5MBHgVoUtsYNzJY0OCV7Tkj9btb
         7TponzpuZupi8nA4OyO4UBZCsB3XTVRaZIQUx9SSodIjInHO1gLQ4CT5ahIQ+J3NgehO
         x6/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=bo4uajak;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor22150291eju.28.2019.07.31.08.08.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=bo4uajak;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AKmba4vf/ZPJ1ANSLVq0BszaZ5EHEw0+rluolW4cNw8=;
        b=bo4uajak/nrY2caCviEQ5+13QOOruKSVot/3mpFhnPUptXe8wQiI2pcggx1UFzkc+6
         p2enaIZE1WQ0nur+4ojLwMmfA3mnX2TiIzq/vOH4fPX7tFzT7bwdjkaqQeNcebCtaRK2
         YncpJbM19Mg+hJ0PgQoeGEunjUw6+YNXDPaFZKrtGi1suwJGSQ25iciPmh/QlVLzh68/
         dFKIA5VbuTbQiB1EFWVSIRHLZOqQe4aOiF5cdzltkeIKMO93kV8/XGQs8282Dvs4jNAK
         r4taKwQzR2Fb1WQzuTvnWB10NdFL0EW3LOi1Sx3I7icX3Xv1+3uBneHoWO18TZnuPiw4
         Xl9Q==
X-Google-Smtp-Source: APXvYqwScU6xXfOXVBF3/9vB3jUnf5274LJ9+ShKG2lqwNOlRRUFmLwjUMddJUmbcRJe29HUOaEEYg==
X-Received: by 2002:a17:906:b6c6:: with SMTP id ec6mr96502459ejb.183.1564585711755;
        Wed, 31 Jul 2019 08:08:31 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id w24sm17512065edb.90.2019.07.31.08.08.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 5E4AA1048A3; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 51/59] x86/mm: Disable MKTME on incompatible platform configurations
Date: Wed, 31 Jul 2019 18:08:05 +0300
Message-Id: <20190731150813.26289-52-kirill.shutemov@linux.intel.com>
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
 arch/x86/kernel/cpu/intel.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 9852580340b9..3583bea0a5b9 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -19,6 +19,7 @@
 #include <asm/microcode_intel.h>
 #include <asm/hwcap2.h>
 #include <asm/elf.h>
+#include <asm/cpu_device_id.h>
 
 #ifdef CONFIG_X86_64
 #include <linux/topology.h>
@@ -560,6 +561,16 @@ static void detect_vmx_virtcap(struct cpuinfo_x86 *c)
 
 #define TME_ACTIVATE_CRYPTO_KNOWN_ALGS	TME_ACTIVATE_CRYPTO_AES_XTS_128
 
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
@@ -593,6 +604,17 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		return;
 	}
 
+	/* Icelake Server quirk: do not enable MKTME if aliases are forbidden */
+	if (x86_match_cpu(mktme_status_msr_ids)) {
+		u64 status;
+		rdmsrl(MSR_ICX_MKTME_STATUS, status);
+
+		if (MKTME_ALIASES_FORBIDDEN(status)) {
+			pr_err_once("x86/tme: Directory Mode is enabled in BIOS\n");
+			mktme_status = MKTME_DISABLED;
+		}
+	}
+
 	if (mktme_status != MKTME_UNINITIALIZED)
 		goto detect_keyid_bits;
 
-- 
2.21.0

