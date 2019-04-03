Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1746DC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D464C2084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D464C2084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F8AC6B0272; Wed,  3 Apr 2019 10:17:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D15F6B0274; Wed,  3 Apr 2019 10:17:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E6046B0275; Wed,  3 Apr 2019 10:17:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 128226B0272
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y17so7627799edd.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=U1aR140X7RnjOrD7ClczvI1VvyAi5tuJM37h24SqYlk=;
        b=VTNPESJwhi29S6jj7MQupQ0VEvGInRpTqj5FqFWLobsZugBu2ijgv3vWvmXMkwKB5p
         k0gAZYHJcbqdVONMa8c9Sg7kffY4YS0MBcoLhVSYc2Ezw+wQku3Igsji1UpcdaCCOLVO
         qkU2ioccdY1r6XTqN6IlmgKy1U6I2Bxg0OgcoD0EdKBx3K5G1Y+IRql1RmWPc63fEtBN
         Hbirl+Oy6vzok4l0bR/TGbYUpjR5pRnhCg6QQPsn8nNWBjn3tZWHxzpsP+APBCAs7TPN
         7duw0i2qUmpj62U3yPHP1fUdGSTc1R4cJFis9NW9Y1WVZ7MUFaJ7IX3x/GKyLyGL+qHu
         s+mQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW0sfNA1S/7g3HMhpzluqyOFBP9qlMS4lwInH3vCbpoIUWbARqy
	Pqelt2MtTeltNXS2C+5Oa/iZlNZsydClh174U4EvN9u2aTBSKYSuesOGUklpUilev5kBcsI/bNJ
	c5MTwdMvjvsjEOFjoN8Rava9ycU81Hk4w3cTwh6IrBmQVvL8evOzor+OIZgi/u/HGkA==
X-Received: by 2002:a17:906:2781:: with SMTP id j1mr44049938ejc.238.1554301078581;
        Wed, 03 Apr 2019 07:17:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMA3wPPzhF0l2+ShmdWv3kbFpFtfnT0Stvkiy2ko0romvWCKhe9Bbg5zmaKhNM5YBJcS/B
X-Received: by 2002:a17:906:2781:: with SMTP id j1mr44049863ejc.238.1554301077101;
        Wed, 03 Apr 2019 07:17:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301072; cv=none;
        d=google.com; s=arc-20160816;
        b=tfYPR7010SV5F05rTGfPxFy3kAk3LxvloRVMBHRV/Vuaz69E0N/mzT++IqVKQJi4si
         05kXAz7IP6+lrroByxHGuAr0ALr44TSuHNdIZvWA3jev0pnhdRGG1BupoqHtygI3e4ai
         3c0jhha6xSh10+xXPrHAsqfiKHoHAdIb/vmIATtCE3YWCA5PQLATne8d6EO8ae+fqUlq
         oqx1nHPPXC4fph6qAtlD5pq4E+Khx1LWd6au8E/yURVDeqXX0nlFz0NlYX8IkRdelm16
         mp/+9gd5RsigO24yxE3aYLMAtU0SB2Akj9QWlnUn/Kz0rfGzejiZU4IZL55+MQJ3jjbG
         4QVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=U1aR140X7RnjOrD7ClczvI1VvyAi5tuJM37h24SqYlk=;
        b=q5I3U7VT3dcAsl9tlQOKlV02VGNkx91YbD5g28WbYU83NzW/g1f+nHIMCYBlZUfI9S
         OJJRSCpt9BtUupr+G9aLZYO0CraiEYzOk49hA4bTFRPH5+SdJAbZvj7cdfpaCmakVa1f
         SmnRN/VQ9JFfYFuSP4xw/itlUoQr42sNs09KXxsff6rAXYkWQS30NPOwyDNlbTOfH79R
         LfUiV1D6zVpKHTzmAJua9hxgodpzo/fnYz3b2NLKXHuCBtmMxEvVs6HZxPNIYyCJNCr5
         O5HvH0g2sD3RrLPxINfkhX8PsI2GtQwoee/gz54LuCF063EJtjY9xAcFdhRJyGsNlYw/
         vyOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e38si4389812edd.259.2019.04.03.07.17.52
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8B354168F;
	Wed,  3 Apr 2019 07:17:51 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2C3A33F68F;
	Wed,  3 Apr 2019 07:17:48 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v8 10/20] mm: Add generic p?d_large() macros
Date: Wed,  3 Apr 2019 15:16:17 +0100
Message-Id: <20190403141627.11664-11-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
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

