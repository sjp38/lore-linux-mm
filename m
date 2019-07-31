Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4D58C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EEE6206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EEE6206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06EF58E000B; Wed, 31 Jul 2019 11:46:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F14788E0003; Wed, 31 Jul 2019 11:46:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E03278E000B; Wed, 31 Jul 2019 11:46:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 95BDC8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so42647235edc.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BddmaCO7bOzK4AWOjB15c/2T2Rs12mf6BHbqywMmVkc=;
        b=mTVmOjNgIHQDQUmwGWHvLq1yHBKZDKBHikg4sMWGBs+MvHVdhsSSc2Og211KI5d1Y+
         eilaqaJ/h9ZhkKjZMiaJGW7AI4TKkRkWAjcObWlWcSafDlB3BYYQ49me+eyVPhWk48Z6
         63IqoW/qlCKZQ9G+mpJEBPoO2lqYhZLSiPs/sAiNyCO3HqGC40lJZpoFdNaEq3SZIiQZ
         FzC6LPQQvAlRTJt7staek+JO99GYJlIsMJDVCTzy/TgvHPAJrFllh+ug/v1f5Ziiyus1
         o3vEFnJH+3FCj4xQVv5D1+HR9aVBzUkdZm0tEtS4rChyj3yupz5US2+h/O82N+cPjBck
         3Vjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWpAnqgdgVtBFHq5UP8B2ZuYlxIPfqgKud1vDA2zUvrHsEWrxNp
	2msfjhOTFORvHxJjv1rvpUNIyhtpgy+RpldAItgo9244JjV1EVy6KLDjyjoSIhSMnpXj69vHD1K
	57/1g6rrHWCEZ3z/BBfYxQgHZeybsmTVqhZ9MUTLmt9ny2qkyk5hLOJUxE8rGZ5M6ag==
X-Received: by 2002:a17:906:84f:: with SMTP id f15mr29399653ejd.22.1564587976189;
        Wed, 31 Jul 2019 08:46:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIwdjM9Q49WMGwh04WMrnqgrmim418kJHrBhn/1d2+j7mTAIuXchUNQ07ggkt8RE17kAWL
X-Received: by 2002:a17:906:84f:: with SMTP id f15mr29399595ejd.22.1564587975330;
        Wed, 31 Jul 2019 08:46:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587975; cv=none;
        d=google.com; s=arc-20160816;
        b=T5EVVHNRGN13s3D/NPdsZEEsuJ2gP1l7yEfshU4e2/f4hodasYiMMtPgk2PUHS94Nw
         RwouaClH0UmPdVhrsEn25QKwoYj/ZkVaRCKv7nFeFa+OD933hxF23ZhmBNyXS8nq9A/V
         uD4L1wir1hVgadv0EwxtSITfj4zAWj+Dl8SiH0pe3bsNyj1MUOI4h9uGUP2BklR8+SoK
         mryy0HI+UBqXUOdD8mrlx0dSAc5azHcE+fmJwO84ct+TRLJaS0zlFtwAoNmhKywa7M3K
         kDfKx5bypRubjk5P331Sv7vMOhyejh1z2/LRFoxggzO/d/v8EhxcrPGjT6iaKTEX0k90
         uXeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BddmaCO7bOzK4AWOjB15c/2T2Rs12mf6BHbqywMmVkc=;
        b=Y/jDCTi6CyHKfNoCheVxRMrNuHOrHnYdYiIIxnEAiKvksdBzvJJOlmFvEeyeGMZkmX
         v6eXtkxfJ0VdCA7R+hkBcRBPqVMEYw85jhFD4N8jnyNHXdXpsneFofCo/OnRrohVwzJR
         45jQvrAw7inth3dIfuLY3WcR1AKtwaxgZxYYQnaLBIsIHqR1+zdUcyVvG6oS3LxKrC2f
         +p1G96Z/Rjdw6WV3WiHoIWsvHs4GewEsepo623PzxJcq9/YzEZZo9grjfZnADi4aMkuW
         9zSlaNxVj7TPJJd5OlTWm7HdcLAsvDb6L7bvHLxscmhrccNSnF3kdFfw6F2iWHP5k5G8
         0pfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id no6si19264300ejb.173.2019.07.31.08.46.15
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7E38C1570;
	Wed, 31 Jul 2019 08:46:14 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CE3F73F694;
	Wed, 31 Jul 2019 08:46:11 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH v10 01/22] mm: Add generic p?d_leaf() macros
Date: Wed, 31 Jul 2019 16:45:42 +0100
Message-Id: <20190731154603.41797-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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

For architectures that don't provide all p?d_leaf() macros, provide
generic do nothing default that are suitable where there cannot be leaf
pages at that level. Futher patches will add implementations for
individual architectures.

The name p?d_leaf() is chosen to minimize the confusion with existing
uses of "large" pages and "huge" pages which do not necessary mean that
the entry is a leaf (for example it may be a set of contiguous entries
that only take 1 TLB slot). For the purpose of walking the page tables
we don't need to know how it will be represented in the TLB, but we do
need to know for sure if it is a leaf of the tree.

Signed-off-by: Steven Price <steven.price@arm.com>
Acked-by: Mark Rutland <mark.rutland@arm.com>
---
 include/asm-generic/pgtable.h | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 75d9d68a6de7..d3d868ad21b2 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1188,4 +1188,24 @@ static inline bool arch_has_pfn_modify_check(void)
 #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
 #endif
 
+/*
+ * p?d_leaf() - true if this entry is a final mapping to a physical address.
+ * This differs from p?d_huge() by the fact that they are always available (if
+ * the architecture supports large pages at the appropriate level) even
+ * if CONFIG_HUGETLB_PAGE is not defined.
+ * Only meaningful when called on a valid entry.
+ */
+#ifndef pgd_leaf
+#define pgd_leaf(x)	0
+#endif
+#ifndef p4d_leaf
+#define p4d_leaf(x)	0
+#endif
+#ifndef pud_leaf
+#define pud_leaf(x)	0
+#endif
+#ifndef pmd_leaf
+#define pmd_leaf(x)	0
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
-- 
2.20.1

