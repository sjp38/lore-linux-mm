Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97938C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 584A021783
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 584A021783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67E9F6B0275; Wed,  8 May 2019 10:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51C0C6B0272; Wed,  8 May 2019 10:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 398A86B0274; Wed,  8 May 2019 10:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA9466B0271
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d22so119108pgg.2
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yWHOhsSwc3WWUoJslsLAWQcHXdi9Dc2j78/2TZTMTFI=;
        b=K/vaTZg2FbSBqSIsGDl4P4+xbnGVBDbFyJSm7PYbLntuqKZ/oEkq0GEKZ4mBKlqq/P
         mawQFAk/O9yaE6VZeuMPQf284S5WbPcVhOfRnXbg9cHeuZkxh0rOKXS2QVQtIBFGfcw9
         QT8RLdHwyuft/OMVR6zSwAOfo/RjJYeMM7NP0Y6H3VyJJ6hlFl+mIdu3qhx38SyxcWBf
         XJ2nRLt9r0P9I9GznygWonc1C1inLGsfTz/wOqoWyrZJ8qgu5hrSZclK7bB1qWR0yDV5
         8xxW1iLP6Zxq6TxiinCcubTaDX18q95hZalt6jD/BcNR++c7nEmRLPEhjg4je6Zcs8De
         zqpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXnfyXxWs5i6IbCs829FORsDLdn8PGWAQ6t6o8jpT7XbbbuhI0g
	6WnbSYDqtdtH3epkdHxG0sKaWcGNdHSFoYPO/VUbAzO56k06TDVsyow93l6wj86fX6oL6q9k/QA
	lSBEveIRcya2k9A7vjtVzxwOJdlRXZ9Hx1JF12KWxKbkFIfiK+J8NyvpzOk5z7uw3KQ==
X-Received: by 2002:a63:4a5a:: with SMTP id j26mr9001682pgl.361.1557326684610;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+Wk2tXComJ8de/b5g4SCwf4zJfUE2dkXyBTsHRWUTOWxx7+J4I1K29v8LgIeIl2g2u+NZ
X-Received: by 2002:a63:4a5a:: with SMTP id j26mr9001568pgl.361.1557326683390;
        Wed, 08 May 2019 07:44:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326683; cv=none;
        d=google.com; s=arc-20160816;
        b=YrkbF9DPwep9Hy8SLzGhQjjiq5cWemPz5IxM10tXyK88i/oWMjMDHR1i6+vr+7HgRH
         R/PLmgM2l8m3DGBpszEYJtdQMC1LTGtF21ymjoHrD/XpwNNBLGFiVL1K46LmrEtE1a0k
         EzQxyPUgulm+09Wdj9nIIAFwVHVyjWOsw+e0f34I/Pjeb81nXMcO6iXYBrqWDGxjZ+cz
         bojSzC7pXlO9UGZAb52CjCVeYRe6IWJwI3EZAeXY+MKW08C2PEJpwjMmZjXw8B2BZZ4i
         F3064YQ3vIu9pbIQEeKTS7F0mQ4tV66UsbWPcCoF+coqvAc46YEzDFWTwd87fGsRes7r
         Tdbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yWHOhsSwc3WWUoJslsLAWQcHXdi9Dc2j78/2TZTMTFI=;
        b=F0GMQzFGd5ZDhwOs2T9aAEy5ylssjO3W2uIL8dUlw91dwrdx8Zjzt5HeLMRn6uoWvV
         a5E6bqsyl6uHRtGD2ChbZm33I3eyZvDcM2KXsSz02LvMpZDaTXdV0pEj5TlItsNw7CIw
         Q8cicPHEjVruK7kT4QvbEElGEyBEwipAig/akWEuJl6P+B8+0ZOLnIsDD2HkNhmHRyln
         g4sbKS5WPC6JieCsUwu5m73Y9OHhX4LntiCno8RUGCojxK2mndsjrALnCQjb1F0uqhcX
         ZJ3eBW8yCxTdNgjjGb09y0wa+/W2nr8VA8tCYd88V2rkkCHmRIK3/Pvj33mm5pS8Sgwh
         wHGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:43 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga001.fm.intel.com with ESMTP; 08 May 2019 07:44:39 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 74047949; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 16/62] x86/mm: Allow to disable MKTME after enumeration
Date: Wed,  8 May 2019 17:43:36 +0300
Message-Id: <20190508144422.13171-17-kirill.shutemov@linux.intel.com>
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

The new helper mktme_disable() allows to disable MKTME even if it's
enumerated successfully. MKTME initialization may fail and this
functionality allows system to boot regardless of the failure.

MKTME needs per-KeyID direct mapping. It requires a lot more virtual
address space which may be a problem in 4-level paging mode. If the
system has more physical memory than we can handle with MKTME the
feature allows to fail MKTME, but boot the system successfully.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  5 +++++
 arch/x86/kernel/cpu/intel.c  |  5 +----
 arch/x86/mm/mktme.c          | 10 ++++++++++
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 6e604126f0bc..454d6d7c791d 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -18,6 +18,8 @@ static inline bool mktme_enabled(void)
 	return static_branch_unlikely(&mktme_enabled_key);
 }
 
+void mktme_disable(void);
+
 extern struct page_ext_operations page_mktme_ops;
 
 #define page_keyid page_keyid
@@ -68,6 +70,9 @@ static inline bool mktme_enabled(void)
 {
 	return false;
 }
+
+static inline void mktme_disable(void) {}
+
 #endif
 
 #endif
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 4c9fadb57a13..f402a74c00a1 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -618,10 +618,7 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		 * We must not allow onlining secondary CPUs with non-matching
 		 * configuration.
 		 */
-		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
-		mktme_keyid_mask = 0;
-		mktme_keyid_shift = 0;
-		mktme_nr_keyids = 0;
+		mktme_disable();
 	}
 #endif
 
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 43489c098e60..9221c894e8e9 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -15,6 +15,16 @@ int mktme_keyid_shift;
 DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
 EXPORT_SYMBOL_GPL(mktme_enabled_key);
 
+void mktme_disable(void)
+{
+	physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
+	mktme_keyid_mask = 0;
+	mktme_keyid_shift = 0;
+	mktme_nr_keyids = 0;
+	if (mktme_enabled())
+		static_branch_disable(&mktme_enabled_key);
+}
+
 static bool need_page_mktme(void)
 {
 	/* Make sure keyid doesn't collide with extended page flags */
-- 
2.20.1

