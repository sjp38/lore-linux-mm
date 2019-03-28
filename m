Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2228C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 601B2206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 601B2206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 590FE6B0269; Thu, 28 Mar 2019 11:22:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F2A96B026A; Thu, 28 Mar 2019 11:22:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36C936B026B; Thu, 28 Mar 2019 11:22:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE9BA6B0269
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c40so6983761eda.10
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=U1aR140X7RnjOrD7ClczvI1VvyAi5tuJM37h24SqYlk=;
        b=clF95RQ8Va+wSoUxhi9vG900QtIZmhAzVt6GMSh4n6vhV1T7TtYz3K8rS8tndI/DIA
         VZz35Skqd90i+BRy4SZ1v2DWg+tGsNOoTnLHZ0qlJyddW9zcnKN9g82gCD2M5G9i/U2B
         +zZbuoEB1sKbbM7ZWkYeU51/WS4tMf+5jTmgjUZZ/UtHj/1wigegyUybCyZSRVa1wBJr
         a+a1E3z1FtYHv20enySM4a9pr7OIpUQNPAeH2ALdbifTnAbGmpnrkzpRV/tFtdaEsE5w
         nZwYtfX4OQ9JwPbvubpvqDiCN39OuCVzf6aLThCAZn6wQpsXViF5B9twr5etG9P7h6I9
         haxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVWPLx6oSpF/Ek01Kf764OqQI0pzAau/FoQogP2lviaRYTp8Jw/
	ItVUUsC0TchOq7amyn5YKob3QFJNDm3k+RPJa+m+c6vgJbQA0bkFxrj+Ar2jvhAAAMJyudmyMSJ
	eWXvuL1xTDzYn1DddExyrxWjKnnYYSC7lppwY3GoR35G4uTO1rlRU2P5xUeMZX3XxFA==
X-Received: by 2002:a50:ba52:: with SMTP id 18mr28686206eds.243.1553786554451;
        Thu, 28 Mar 2019 08:22:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy673eScNceBou3zW9EhrAiJZYpVT9EuQ3GMp3F4vpb5K1x5ILi0H/sZct+qDldJ4AA0MT7
X-Received: by 2002:a50:ba52:: with SMTP id 18mr28686150eds.243.1553786553432;
        Thu, 28 Mar 2019 08:22:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786553; cv=none;
        d=google.com; s=arc-20160816;
        b=hQ0fQlV3sZHlcLomjJoP5V93sVqAYB99FWIV77i/aEPDZhJ7nROa+LsluYg2xWJaJW
         Q7NWmjX/5MlowM+wAAJIi7NpCUGX1c7SF8WAqSgmL+Sun2fFV1vkjUWQkpYtpjBKX0V8
         fkPsUB6t5vX6mxXfhPqm7UPUKvkB6jmeJ5fcEYypcrtoIByu9o2Tw0/I9LHJ8C1Q92TX
         kUbioPrMH79+mSiGv5wSrD3V6kunMz0wvd2C+lEQhDNwQ86jfNvAZWRYjB0v1VdtU1/8
         wCkbXFLEkAUwY0gEJk7Jf6A3AwCK1fN4wmlFX4cL+PfOtsBdAJ635XBoIIpyhcMhSmqU
         JT6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=U1aR140X7RnjOrD7ClczvI1VvyAi5tuJM37h24SqYlk=;
        b=JcbZ+BV1gSkNedf0nk7ZoK3lZnGGSOwXLHdgjOx2wfpg0MFAGPiwLAKcfXTa21Srdl
         pIJyJuf9XQHVuFvcYX4eXOsT2ZG1ILOFZFqx2SWgo1zhX3bN2KBJ2cNJMSJOlbsFRA5o
         lJ3xZ8TYAhTlngkpEPTExmQD4mXUzZRZLFZFwZLHi9/S11y5C/PU+4M+/l+fZTXVCZRC
         FRu3yeo0Jq4+sumJs58O/W36dMFgMdV6DXv1dysL52K5ybwx2FAFdLZhkPALYzwheFwB
         ORstXLVgi2gZCV6gNTwGzOV3ml0hF0HNmO6K4DfextY33B7btUOGXXggqew7/9BFrKIK
         OaFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l1si1410158edn.23.2019.03.28.08.22.33
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 958871684;
	Thu, 28 Mar 2019 08:22:32 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4EB6A3F557;
	Thu, 28 Mar 2019 08:22:29 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v7 10/20] mm: Add generic p?d_large() macros
Date: Thu, 28 Mar 2019 15:20:54 +0000
Message-Id: <20190328152104.23106-11-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Exposing the pud/pgd levels of the page tables to walk_page_range() means
we may come across the exotic large mappings that come with large areas
of contiguous memory (such as the kernel's linear map).

For architectures that don't provide p?d_large() macros, provide generic
does nothing defaults.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/asm-generic/pgtable.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index fa782fba51ee..9c5d0f73db67 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1186,4 +1186,23 @@ static inline bool arch_has_pfn_modify_check(void)
 #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
 #endif
 
+/*
+ * p?d_large() - true if this entry is a final mapping to a physical address.
+ * This differs from p?d_huge() by the fact that they are always available (if
+ * the architecture supports large pages at the appropriate level) even
+ * if CONFIG_HUGETLB_PAGE is not defined.
+ */
+#ifndef pgd_large
+#define pgd_large(x)	0
+#endif
+#ifndef p4d_large
+#define p4d_large(x)	0
+#endif
+#ifndef pud_large
+#define pud_large(x)	0
+#endif
+#ifndef pmd_large
+#define pmd_large(x)	0
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
-- 
2.20.1

