Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F6E0C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 510C2216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 510C2216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F7466B02A5; Wed,  8 May 2019 10:44:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D9326B02A9; Wed,  8 May 2019 10:44:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F8456B02AA; Wed,  8 May 2019 10:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9DEC6B02A5
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:54 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m35so12801984pgl.6
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o5KW25YTExVeHUad5j7wl2zSQfDlvno755Y/jyretlU=;
        b=YjMpnczf1sj3r9WwDsppEcRWlJ34EWjHWhih/McREgald07K5phgzr7jyhK0Uxbd81
         29YMZuLZQWc404I8bWN487eL4UzDczfQF1GvhK/gEvW25XYhZklOLsyetDyKfY8R32tp
         omP0It0oMbLILV3LHhtsuEUJNmtQWwMGbr2o6b1aIo/IAnx5nMsLU88oKdCUA7E6soBV
         C99wCznrRadQx+26e81MOsSVTHfaC3XfoYiK9kiOHhvxWaxowzehTxySE2RGv3cwOj0L
         yXL5RD+qCSYoe+CAQrwPNrH2OqlOtBDEPNoavCkvEGG0xn2xZ9DXVMCEcpt4JYHEnfZc
         385Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU5VyTg6641an1GsbRF3pY0pwefgLJqeCJu3H7+A5RlY50JhgtR
	gAHQBzXWwPv9dssBWGnIGmzrVBjfBOwddMRgmPfzqzxlPESRJf3skhDpyqGckSm2+fgMpUUy1US
	H3xijnHRWuUWsayd8u7yi4sf8JSgqYvaZFWBTErfyNw83s1ObAIRCM0H9mUJ1AicExQ==
X-Received: by 2002:aa7:8383:: with SMTP id u3mr48407387pfm.245.1557326694620;
        Wed, 08 May 2019 07:44:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpUIi65AOZpDSCDOqLyynHRdEE8GyBRXsxcm3SFw1O8WMgQRSxBE/pQA/Ln7IPzJFNWnUj
X-Received: by 2002:aa7:8383:: with SMTP id u3mr48407267pfm.245.1557326693434;
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326693; cv=none;
        d=google.com; s=arc-20160816;
        b=owe/5F09UUIrtXPYh4H14KVqL4Q3j621/RNH4oXFoTMKVRcu6RWsKj9KQ7IVXHEfnS
         HuMabXI05U0p6Qb4bDW/4ugTyAs7b1PjW/kUalbzGAIBRx/4mNdDAjS0XTU2zhXK8q7c
         2mcM3Yxct8OiEHUDyyHFn0IGzuYT2J/Koqapb9B9XKdO8myBVGIXWhgU1CpKfp9XO/LL
         K0wYh1uYz/ZxZ7Wasi4bh119GKnqcs3jYib3Vh0RyK+pJowkqXJ/NpNNIDwL3Pns2Bby
         ia6cNz/9ul9ZqE5oqTXi3/DF6wEQZ0+K7OkftziCfHVWIrBRIf4bnk8nORshi4dGgDBv
         J/Hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=o5KW25YTExVeHUad5j7wl2zSQfDlvno755Y/jyretlU=;
        b=E850BiV0bxzgEE8B9eTL/4FOE4+N0VH98cBAFvDUC0xzLvHplJTZ0mkX+UbmEnSvnv
         mwP2bgkOGOjcRMZHZTnqx9H9viaFzt+tOsP3JJJOpns69hhrIsgug+G6tmqGiMxk2dnW
         Buzlw1yfl1QBWL3773isKf7d3Rlq1mYeTftDz6nlp6t7dzJMTxWMKipn3zKTvtgbdHxQ
         o9PwB+sxlmrJv952/UVgbWH2rIv2PhwnEaVYOBMYNGF370m9bq9865vqn1HrPMu8R1+F
         QaZqHMX0xWTyiIw0HBSchX0tDWBJoM4xDV8j5wpqRqxHCVeR/ZuW3pP7FS8L/Vuh0/UP
         WzDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g13si12322802pgs.161.2019.05.08.07.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:53 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga004.fm.intel.com with ESMTP; 08 May 2019 07:44:48 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 7CDA2117C; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 56/62] x86: Introduce CONFIG_X86_INTEL_MKTME
Date: Wed,  8 May 2019 17:44:16 +0300
Message-Id: <20190508144422.13171-57-kirill.shutemov@linux.intel.com>
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

Add new config option to enabled/disable Multi-Key Total Memory
Encryption support.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index ce9642e2c31b..4d2cfee50102 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1533,6 +1533,27 @@ config AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
 	  If set to N, then the encryption of system memory can be
 	  activated with the mem_encrypt=on command line option.
 
+config X86_INTEL_MKTME
+	bool "Intel Multi-Key Total Memory Encryption"
+	select DYNAMIC_PHYSICAL_MASK
+	select PAGE_EXTENSION
+	select X86_MEM_ENCRYPT_COMMON
+	depends on X86_64 && CPU_SUP_INTEL && !KASAN
+	depends on KEYS
+	depends on !MEMORY_HOTPLUG_DEFAULT_ONLINE
+	depends on ACPI_HMAT
+	---help---
+	  Say yes to enable support for Multi-Key Total Memory Encryption.
+	  This requires an Intel processor that has support of the feature.
+
+	  Multikey Total Memory Encryption (MKTME) is a technology that allows
+	  transparent memory encryption in upcoming Intel platforms.
+
+	  MKTME is built on top of TME. TME allows encryption of the entirety
+	  of system memory using a single key. MKTME allows having multiple
+	  encryption domains, each having own key -- different memory pages can
+	  be encrypted with different keys.
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
@@ -2207,7 +2228,7 @@ config RANDOMIZE_MEMORY
 
 config MEMORY_PHYSICAL_PADDING
 	hex "Physical memory mapping padding" if EXPERT
-	depends on RANDOMIZE_MEMORY
+	depends on RANDOMIZE_MEMORY || X86_INTEL_MKTME
 	default "0xa" if MEMORY_HOTPLUG
 	default "0x0"
 	range 0x1 0x40 if MEMORY_HOTPLUG
-- 
2.20.1

