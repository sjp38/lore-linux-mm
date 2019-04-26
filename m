Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2419DC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5BE42084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5BE42084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C34106B026F; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D3B66B0266; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D4DC6B026A; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9D4F6B0266
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y2so1659966pfn.13
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=KTT3A6U4NQUMX3UyJFnXteqziiXHIb6+tR0GZna3rFw=;
        b=XEX0vJMTCC986W7GqL7WVQ5utVDAn7fsP6SAh3TnY7JffavQHCLsiZl4rX30UycqKy
         tcNpS+5VNrABRnvg8Y2ZWoeIVkw3cEv4OR/fIh6wKU8cf7Tm/PXNPN7gMKde18LWFixG
         bY1p3OyE6QhKnXmlziEY9aOvFbyOhLqfyROvzW0oale/Txal5Jtp1rr8hohMFgnwbk94
         HQq/0mNJSEc6ZZpgXV0i7fa0vZwfpQHU+rGlRAaGuaTgEAUTNTHW3jnso5o5CMQO1LT2
         Ch6XRkpl1GhXYzp99MreeizSG2fAVuZSGfsyMLs1xmRoWLZypLY6/OZg9W/AOO0eOqYv
         YoXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUqXb2ot+XW6m9hLrYbifFQlvx2QYnINfvuqfReNHYB4n+Ha6Xw
	jiHG06y3Q8pgAnSBAkuncz7wVztLzwW3WV47IzIfJiujBny2aGzffRLcfrzw49va0/lquWdqjBI
	0Au+DedGl6y3oUoqNt7t86rLVbn0S1wqbrJQyK1H1ybkO3/gOS7PnPMqTDHPt/o1NRQ==
X-Received: by 2002:a62:474a:: with SMTP id u71mr44164050pfa.87.1556263909418;
        Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRYLjLGCR7EDAjtQi5NLvJXU/YK/939ExPOMraZEJx73r+tmAKQyXAwbYytNJRKSGrKTCx
X-Received: by 2002:a62:474a:: with SMTP id u71mr44163940pfa.87.1556263907940;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263907; cv=none;
        d=google.com; s=arc-20160816;
        b=YjSpPH0zyeJfdD/BU+DCYTGFirPSadfamceFqJ5bf8HThsSxV4yrjnm7G7nzwcPQUQ
         dwTQ0ieETVj4xpyaKTTd1ZZcVc2cuvPe7tYHumjN5+dGvZlZgKlbimjr1sc+2rgMzJ+c
         Xp5/NzVkiaK4TTs5Jqn2QLrzXFQxbsu6KPrLkHeVJDrEwXac813T65EFm9rxS3MkL7EZ
         P8N9PMHaT1AFj1Nu3X0AKkkeamQSGAsZnwlgcUvtsTvKfo3BmKf7fq/ERUG2TY5b112j
         wo0Yn2GP6NuTNs6rokrSD8oTl67N8wfK8MBGfc32ldnEjbwhKZ2KNQnwVXsnVtL8CZTY
         pzOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=KTT3A6U4NQUMX3UyJFnXteqziiXHIb6+tR0GZna3rFw=;
        b=jsFprV6g5HwGE+pB153Lm0FyehL0l7puGnSqLApDe8W8jdzF/rtk4zqzLdXTKVnvoi
         C5fa2jn8QEyTcoHOeJBLExXMX5TGAKutICTOi1WN+rO9E2fQiDnU7ufw9h4MYsSZxHom
         PwSlG97H5obe3sfVFuH4rjTVKA9uLiJpxMhWz3FHypJ6YFbKbiHKF2gjAqU7BBbdYbop
         Ic7IcprsTBd3tqypXI0zXtHuE16nq3gZbyn5Pxxvy9gbpAJm54RLAZHBFHOJvvfqht/O
         w6JEqn1MOi+1ZyYAkuhbiSzq3xEOAvhOqdKVWDzBrjv2NkcohtsBpcp09Tl90ggdtdkq
         h48A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id D96B44129C;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>
Subject: [PATCH v5 14/23] x86/mm/cpa: Add set_direct_map_ functions
Date: Thu, 25 Apr 2019 17:11:34 -0700
Message-ID: <20190426001143.4983-15-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

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
 include/linux/set_memory.h        | 11 +++++++++++
 5 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 3ab446bd12ef..5e43fcbad4ca 100644
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
index 2ec5e850b807..45d788354376 100644
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
index 4c570612e24e..3574550192c6 100644
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
index 2a986d282a97..b5071497b8cb 100644
--- a/include/linux/set_memory.h
+++ b/include/linux/set_memory.h
@@ -17,6 +17,17 @@ static inline int set_memory_x(unsigned long addr,  int numpages) { return 0; }
 static inline int set_memory_nx(unsigned long addr, int numpages) { return 0; }
 #endif
 
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
+
 #ifndef set_mce_nospec
 static inline int set_mce_nospec(unsigned long pfn)
 {
-- 
2.17.1

