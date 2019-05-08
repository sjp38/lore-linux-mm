Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A967AC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F027216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F027216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7188D6B02A7; Wed,  8 May 2019 10:44:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CA6C6B02AA; Wed,  8 May 2019 10:44:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E34D6B02AC; Wed,  8 May 2019 10:44:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F37516B02AE
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x5so11673793pll.2
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YaEUfUd5VoDz+D3t/tMnMmtVbfr/7wfrUagdOS99llw=;
        b=ToNCawtoYgp8Zm4OvHDJC5jj0RKOi9oy5KUJhzx/KNyZnml5j6y2lFq3cHytigpnbB
         5sl+7j5epazBoSomQ3RsrKRO5rr3UvxT5TzqJf7AydE9SEqOsdlleYl/GziNeLZABgrU
         M12X23lkWOBDvd/5P9JoAwNZKaOK3H2uLC0icMkQxD/Pa2Ykyxmg14E77yzJUK5NnsYw
         6vCZqwy9jH5bDT6W4xgBQDLtnPSv66rAB5tIw8pVCrNpArrwv39y7FxpAgy+zIxdGToh
         8mnR6ETflb70cjJcgoj4sJkDRTz/XQEvbfbuBtO3wWBTNJjiKE+PdNrjwbKS1jo4oyxf
         iYOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVzzDAd4kWtjj65zKqM4F0axihe5rcQVgN3lhOU09NCyQwZWrcc
	+mE6fDKUpxe2VawjvXDupXBO0m0dTbR1XZdgyURZRdyA5WP3Mh8xMCoZzVXWVfIWKs3XF2KtmYG
	9QAmWEJ0gjvmJJxzXorG31gqp7AJOluVrFktUZkHr6tS3ex2lobBvXpqPnLrrE9WKZQ==
X-Received: by 2002:a17:902:7797:: with SMTP id o23mr15676458pll.147.1557326695656;
        Wed, 08 May 2019 07:44:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz42zjHxqR6sPA8w9dDWq6219x4ZJ3VitxwoHgyPh+hUDtcjpsfy8OMUukz23Hw02C4t/Je
X-Received: by 2002:a17:902:7797:: with SMTP id o23mr15676246pll.147.1557326693604;
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326693; cv=none;
        d=google.com; s=arc-20160816;
        b=id2hoIGodRL6MQxj3dT/ew2F5daWd/hraJGA111TnveYzspx73+fuGoWy/rq2hj2tw
         ogezj6P6SxqQ5l25nlAN4phIMvOVeIfICSoMGGVHwN38n4YD6TpUHipXzN3y0Jdh3JEo
         W++mqveuv8CBGkhno8JGoIvs5isbkyk/1loBk4LcLead8OX7Ntt3MR+TiyyjAQx4Cjgr
         hyr+yZi8CuQ9DpLmTcP0I/myDdlGEozROiskvSxIpvvvKVKNFfsr7rl8/gLL1NgLyu1k
         Q9w3cRobo9kQQsOliQxj5uqHUSVAf0hqV+oUTuB+S932QMs5SZ69gDmgHLlfNRHJzA94
         S8Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=YaEUfUd5VoDz+D3t/tMnMmtVbfr/7wfrUagdOS99llw=;
        b=pfMKJI1bkPvmbkG2jRrtOSdL6uNhgyM0XJRjAk/5kIHIFF8QPT5d/g3E6EpTBR3gT7
         OKZ3l8EY3N3a0YQSV+1femotZ+HMbTPo+WHlJaR0ynf/aPOEHLBWN60WFDsufr2uw4rd
         2XlNYmc6qKt5Bzhwjt2rhf8+bka0uQmrRjwUmZ1xlk4g8F/lURuxsMIdeOYQ4sd3HObD
         1WRPElXw9Y9c/1S61b2GptmqGacgNAavhBMdxP0utP+1avTxACxg1EIvQVdxamCAlfhc
         F3+vd2BNBvr7tx7kjukwbsQAOVQDknDCDoZGXwsice6Jpoz2gD+i6oShyhVhv1B/eAuS
         6MYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t16si6593003plm.65.2019.05.08.07.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:53 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:49 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id A1F3611C1; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 59/62] x86/mktme: Document the MKTME kernel configuration requirements
Date: Wed,  8 May 2019 17:44:19 +0300
Message-Id: <20190508144422.13171-60-kirill.shutemov@linux.intel.com>
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

From: Alison Schofield <alison.schofield@intel.com>

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/mktme/index.rst               |  1 +
 Documentation/x86/mktme/mktme_configuration.rst | 17 +++++++++++++++++
 2 files changed, 18 insertions(+)
 create mode 100644 Documentation/x86/mktme/mktme_configuration.rst

diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
index a3a29577b013..0f021cc4a2db 100644
--- a/Documentation/x86/mktme/index.rst
+++ b/Documentation/x86/mktme/index.rst
@@ -7,3 +7,4 @@ Multi-Key Total Memory Encryption (MKTME)
 
    mktme_overview
    mktme_mitigations
+   mktme_configuration
diff --git a/Documentation/x86/mktme/mktme_configuration.rst b/Documentation/x86/mktme/mktme_configuration.rst
new file mode 100644
index 000000000000..91d2f80c736e
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_configuration.rst
@@ -0,0 +1,17 @@
+MKTME Configuration
+===================
+
+CONFIG_X86_INTEL_MKTME
+        MKTME is enabled by selecting CONFIG_X86_INTEL_MKTME on Intel
+        platforms supporting the MKTME feature.
+
+mktme_storekeys
+        mktme_storekeys is a kernel cmdline parameter.
+
+        This parameter allows the kernel to store the user specified
+        MKTME key payload. Storing this payload means that the MKTME
+        Key Service can always allow the addition of new physical
+        packages. If the mktme_storekeys parameter is not present,
+        users key data will not be stored, and new physical packages
+        may only be added to the system if no user type MKTME keys
+        are programmed.
-- 
2.20.1

