Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D9ABC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 08:08:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06600218D3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 08:08:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06600218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F9A76B0003; Thu, 21 Mar 2019 04:08:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A7776B0006; Thu, 21 Mar 2019 04:08:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 898636B0007; Thu, 21 Mar 2019 04:08:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35E9C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 04:08:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 41so1911521edr.19
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 01:08:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=pTp6og0ZBTVQtFn0hVX+rHPdqVdRwBAc/w4sCgsUJ10=;
        b=bi11uazZq5mWNnL6qYxFYjSVJfuavDkdh+ORxw9+VBRDcxvjDnrID0cR6tCuoLmShe
         tf8EEs//5h8GOmKck1Lo+GDd8TqWgJ/MQMxcdEfIuBumwkx1cL3VpRiMsNrAUfbTVWZp
         6fIyHxvTMTe6mwTAa40u87cYwhRNcTk6wyZwHSTZMljE9OREJYz7SM7rfXLALrDIjZ1N
         lbDDLtHgfqOaNUH8p2ZqGWGbFXlYL4SdHffNr02dIdrHhIPtFcnQmIyRLLYqgAnSsOZV
         o/FBp35eWJ2IiivZrO2G0CTSZc4/UFmVlBw5NC2Q9w8ucUasrOrr8SH0k+t09wQywxX4
         x1OA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXX/uFoiFlAGnbXmSwAjia9QkYAf4vMizh99mmxskkJFRklNkiR
	EVk62QSD+6AltJrZGCQL1FUcgKLKHHYCrO56+NZLAFamZDYrZ4V8FAz2c+TwaabJlgiO3tybZmF
	d2uamobYj/QKjeIpTEyTcKz09+ePWe/maLtZBIMH3nej7DPGZa7L9VsGexsWPMDVFOA==
X-Received: by 2002:a17:906:a2c6:: with SMTP id by6mr1562586ejb.134.1553155710679;
        Thu, 21 Mar 2019 01:08:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOut9IoBWp5ITWLVAR5K79Sh9ykuw0o0qiNFkwqgcl2XW42Iv8Zi33WrtufSkYf1xi1/gO
X-Received: by 2002:a17:906:a2c6:: with SMTP id by6mr1562538ejb.134.1553155709374;
        Thu, 21 Mar 2019 01:08:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553155709; cv=none;
        d=google.com; s=arc-20160816;
        b=dBNXgTgJBTy+k1YIQBYt4SWWMVuJ6x5mEg49efqp9jBkVgrru+tbluXj4drl2oKtQ3
         2a1SYfQu2HLNvsfAIEvW4we0SCPjKw8iNdTtChL6tZkiKPGM6rA9gOzCM+2RDObRf0YV
         h/zvk+bJXi+YWEi6BN9lxR+wTGsMDfLXxq6LOzxFI8cUdNm7f6y+gTEnLyCtW6uG3luz
         jLGgWuZRhOuhkl5W5vl89zkOkaYDx36TB2g5sTogWc4Lqvsmo/i7xwohqV9U/LJLaZMd
         gv1zRmLXFrmZPScr1dRroIqCs5Gpdu/QA558lxHLDIOYAr2LiAk4HJ0Cz++/MxhSm+Qn
         K97w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=pTp6og0ZBTVQtFn0hVX+rHPdqVdRwBAc/w4sCgsUJ10=;
        b=eQFYH5K/Uf6RuMr+67jtDIcLPNwRnXaCkSIWMULkMTUu8nUwnjTMxb7RQVVEM1XF/e
         2HOG9K55yDm0/Fx5VdQMuJSZpbA7DLQutZ6+by/9R0xjlC3a5PH8msBAmBJcVoGjrE6R
         u3cmUEpfTm9fvmirgm9h8+IuPbiT+tzNSHuexaqzWE6maZ+vJNrGRYVphouIBTpOC4jA
         fmQzBEtxa5aPSpyngm0viwJx6IYomrXtSfMpp3+764S4ar1KRyXqj5AggZ48wmTzIV8V
         YzCTG3zGL723jWc4VlbU69y5F0UONJrfsusH1/ZLqMWutrkK2KOQF/WfeywD+JfTUF+m
         ++QA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n23si1235461ejk.268.2019.03.21.01.08.29
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 01:08:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 304B280D;
	Thu, 21 Mar 2019 01:08:28 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.102])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 2ACEB3F59C;
	Thu, 21 Mar 2019 01:08:24 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: logang@deltatee.com,
	osalvador@suse.de,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	akpm@linux-foundation.org,
	richard.weiyang@gmail.com,
	rientjes@google.com,
	zi.yan@cs.rutgers.edu
Subject: [RFC] mm/hotplug: Make get_nid_for_pfn() work with HAVE_ARCH_PFN_VALID
Date: Thu, 21 Mar 2019 13:38:20 +0530
Message-Id: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
entries between memory block and node. It first checks pfn validity with
pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
(arm64 has this enabled) pfn_valid_within() calls pfn_valid().

pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
which scans all mapped memblock regions with memblock_is_map_memory(). This
creates a problem in memory hot remove path which has already removed given
memory range from memory block with memblock_[remove|free] before arriving
at unregister_mem_sect_under_nodes().

During runtime memory hot remove get_nid_for_pfn() needs to validate that
given pfn has a struct page mapping so that it can fetch required nid. This
can be achieved just by looking into it's section mapping information. This
adds a new helper pfn_section_valid() for this purpose. Its same as generic
pfn_valid().

This maintains existing behaviour for deferred struct page init case.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
This is a preparatory patch for memory hot-remove enablement on arm64. I
will appreciate some early feedback on this approach.

 drivers/base/node.c    | 15 ++++++++++++---
 include/linux/mmzone.h |  9 +++++++--
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..9e944b71e352 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -394,11 +394,20 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
 static int __ref get_nid_for_pfn(unsigned long pfn)
 {
-	if (!pfn_valid_within(pfn))
-		return -1;
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-	if (system_state < SYSTEM_RUNNING)
+	if (system_state < SYSTEM_RUNNING) {
+		if (!pfn_valid_within(pfn))
+			return -1;
 		return early_pfn_to_nid(pfn);
+	}
+#endif
+
+#if defined(CONFIG_HAVE_ARCH_PFN_VALID) && defined(CONFIG_HOLES_IN_ZONE)
+	if (!pfn_section_valid(pfn))
+		return -1;
+#else
+	if (!pfn_valid_within(pfn))
+		return -1;
 #endif
 	return pfn_to_nid(pfn);
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 842f9189537b..9cf4c1111b95 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1242,13 +1242,18 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 
 extern int __highest_present_section_nr;
 
-#ifndef CONFIG_HAVE_ARCH_PFN_VALID
-static inline int pfn_valid(unsigned long pfn)
+static inline int pfn_section_valid(unsigned long pfn)
 {
 	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
 		return 0;
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
+
+#ifndef CONFIG_HAVE_ARCH_PFN_VALID
+static inline int pfn_valid(unsigned long pfn)
+{
+	return pfn_section_valid(pfn);
+}
 #endif
 
 static inline int pfn_present(unsigned long pfn)
-- 
2.20.1

