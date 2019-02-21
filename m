Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C10FAC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78D9220818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78D9220818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE2098E00D1; Thu, 21 Feb 2019 18:51:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C91888E00CD; Thu, 21 Feb 2019 18:51:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA80D8E00D1; Thu, 21 Feb 2019 18:51:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75FFA8E00CD
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:07 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 71so288861plf.19
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=vnm0CR07Tfw1GDwsiV5/vDSm+bo6LLBKcYWCZj/kFdA=;
        b=LYgo6yrPWj8QKgdLzpY3WuV17bZmEjoMajvlWGB7URp2ylu+mI+Z82HNkBnEVyathR
         s3VPxzWNz+Y8Hn5MS19HJLPDSN6gRR4hJyb5bxJXiaQrQ6/zXrGdd6tTDGMc+Be7LcbK
         sM/SVbxMHNGcY+qx473EJmJOd2C4WdU1ZNe0pKp804fmfz/3il0CyvlPKi75OFW/lH8z
         OB1MzxyHfkFrL8PLUInSczxfzJAbFhBFvPhP/MwNP5pSV+04dhvGNt3kDNzTSqHD6koB
         kO8yzoWlI4BWvQT4x75HQEyzbHzOSf9so1aPcE7f9Xh/zqVbv7f87h627qWUUefPXn+/
         NQzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuavLhU0rNKACrghMgppwog1tsSml7z0cy3oeVaERbDDvYjjVDjs
	zii6iW4GNkNpkfLuW3z7BB6h1W6NuYBqrW30kkxtUfP4h+I0OyG2oRiQ0W2yzNpyPBdXkxbziT/
	mQuW05Fg6w4fwkef4ZNlbxfjzRSURnfnQbB7IdCQUKHkMep4+RcPwuFWNRFRq3Qpttw==
X-Received: by 2002:a63:1061:: with SMTP id 33mr1080586pgq.226.1550793067145;
        Thu, 21 Feb 2019 15:51:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibl/1xtYG/hbpzNFXT5P+tY412bDqklpIoR4/gD6rEhtq+sCc01WkFh+dBYQU+j0SY5EqWX
X-Received: by 2002:a63:1061:: with SMTP id 33mr1080543pgq.226.1550793066351;
        Thu, 21 Feb 2019 15:51:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793066; cv=none;
        d=google.com; s=arc-20160816;
        b=ReMGZ0v+tP5coROaTk8Uvp4tVvRSfrA8c3EYz4YGnVsPdWH2y+8c6sD+3s1PhxNlPD
         lEm60rey2r4RQuHFyTNJYILWsPnk8BV0xyTV+IUCH72XnEY6vg9u3+YSxbjzBOCO2WHT
         rQxPHV7sSby73jj7nId+B86QbLYP9Q45PMiG1E2Em6+2GddC5VqLfe+FZVLlUd0lgIuQ
         rJGCRRbs6R5uFekwugBEj/gFtlFtxANEf3vF4qoToHzVsgHXwp0Bh5IFvDBHCcTEqigY
         5VNl0MUdm2aN6GNscskeC/fOY/Gh/YB0VpxZ/1hlSVbAJoktdXJ8xpq+r7ce4WWOL0y+
         8CrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=vnm0CR07Tfw1GDwsiV5/vDSm+bo6LLBKcYWCZj/kFdA=;
        b=AYnz1cuz0nSWPv0id/4ShPz5bBYtUv/YzwoF89hKRzaNwMnAETJ0by5howa/imY5+k
         u8ULBwxRjnoeGcbMYXfsl1HVCKNQOOHfHeTxwXyHg9I9XdJTjrNtEGJmmrQ6Js2U7XfM
         BzgNVsP28nADcv7SQSbesARLrbhG1jTBQ0QAy9QysyueeYIUV02s05gJA9F0jNiUndIU
         H5x2uQJKeG9PBciN2B9LtTHAHN2mUFIp40jJ/CoQBhNNyLr/tf0yWl93o4QVnUDOOp0l
         0WL4e0WuDMzWGl9NZrGBFIH/U9MyfQO2nYgjyc5oCir/D18qza3Fu8yZCrVGXtRB5ZyH
         3voA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:06 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394927"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:05 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 13/20] x86/mm/cpa: Add set_direct_map_ functions
Date: Thu, 21 Feb 2019 15:44:44 -0800
Message-Id: <20190221234451.17632-14-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add two new functions set_direct_map_default_noflush() and
set_direct_map_invalid_noflush() for setting the direct map alias for the
page to its default valid permissions and to an invalid state that cannot
be cached in a TLB, respectively. These functions do not flush the TLB.

Note, __kernel_map_pages() does something similar but flushes the TLB and
doesn't reset the permission bits to default on all architectures.

Also add an ARCH config ARCH_HAS_SET_DIRECT_MAP for specifying whether
these have an actual implementation or a default empty one.

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/Kconfig                      |  4 ++++
 arch/x86/Kconfig                  |  1 +
 arch/x86/include/asm/set_memory.h |  3 +++
 arch/x86/mm/pageattr.c            | 14 +++++++++++---
 include/linux/set_memory.h        | 10 ++++++++++
 5 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 4cfb6de48f79..79a9ec371964 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -249,6 +249,10 @@ config ARCH_HAS_FORTIFY_SOURCE
 config ARCH_HAS_SET_MEMORY
 	bool
 
+# Select if arch has all set_direct_map_invalid/default() functions
+config ARCH_HAS_SET_DIRECT_MAP
+	bool
+
 # Select if arch init_task must go in the __init_task_data section
 config ARCH_TASK_STRUCT_ON_STACK
        bool
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 26387c7bf305..291c6566cf88 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -66,6 +66,7 @@ config X86
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if X86_64
 	select ARCH_HAS_UACCESS_MCSAFE		if X86_64 && X86_MCE
 	select ARCH_HAS_SET_MEMORY
+	select ARCH_HAS_SET_DIRECT_MAP
 	select ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_SYNC_CORE_BEFORE_USERMODE
diff --git a/arch/x86/include/asm/set_memory.h b/arch/x86/include/asm/set_memory.h
index 07a25753e85c..ae7b909dc242 100644
--- a/arch/x86/include/asm/set_memory.h
+++ b/arch/x86/include/asm/set_memory.h
@@ -85,6 +85,9 @@ int set_pages_nx(struct page *page, int numpages);
 int set_pages_ro(struct page *page, int numpages);
 int set_pages_rw(struct page *page, int numpages);
 
+int set_direct_map_invalid_noflush(struct page *page);
+int set_direct_map_default_noflush(struct page *page);
+
 extern int kernel_set_to_readonly;
 void set_kernel_text_rw(void);
 void set_kernel_text_ro(void);
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 4f8972311a77..fff9c91ad177 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -2209,8 +2209,6 @@ int set_pages_rw(struct page *page, int numpages)
 	return set_memory_rw(addr, numpages);
 }
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-
 static int __set_pages_p(struct page *page, int numpages)
 {
 	unsigned long tempaddr = (unsigned long) page_address(page);
@@ -2249,6 +2247,17 @@ static int __set_pages_np(struct page *page, int numpages)
 	return __change_page_attr_set_clr(&cpa, 0);
 }
 
+int set_direct_map_invalid_noflush(struct page *page)
+{
+	return __set_pages_np(page, 1);
+}
+
+int set_direct_map_default_noflush(struct page *page)
+{
+	return __set_pages_p(page, 1);
+}
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
 void __kernel_map_pages(struct page *page, int numpages, int enable)
 {
 	if (PageHighMem(page))
@@ -2282,7 +2291,6 @@ void __kernel_map_pages(struct page *page, int numpages, int enable)
 }
 
 #ifdef CONFIG_HIBERNATION
-
 bool kernel_page_present(struct page *page)
 {
 	unsigned int level;
diff --git a/include/linux/set_memory.h b/include/linux/set_memory.h
index 2a986d282a97..82477e934b1a 100644
--- a/include/linux/set_memory.h
+++ b/include/linux/set_memory.h
@@ -10,6 +10,16 @@
 
 #ifdef CONFIG_ARCH_HAS_SET_MEMORY
 #include <asm/set_memory.h>
+#ifndef CONFIG_ARCH_HAS_SET_DIRECT_MAP
+static inline int set_direct_map_invalid_noflush(struct page *page)
+{
+	return 0;
+}
+static inline int set_direct_map_default_noflush(struct page *page)
+{
+	return 0;
+}
+#endif
 #else
 static inline int set_memory_ro(unsigned long addr, int numpages) { return 0; }
 static inline int set_memory_rw(unsigned long addr, int numpages) { return 0; }
-- 
2.17.1

