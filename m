Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CE70C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0097D20C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0097D20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E8E68E000E; Wed, 31 Jul 2019 11:46:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94D1A8E0003; Wed, 31 Jul 2019 11:46:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E76D8E000E; Wed, 31 Jul 2019 11:46:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32B878E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so42732057edb.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7eguvhFG3vFIX+cjWUMgrCPyT9l1sSVqWaOQbfj+tXE=;
        b=LBYEy1TYZMGgJqE8CyhNCPDFr0849iaWFIbbtoaN6ECW12EWUdZ5JurSTGB7mKyW3f
         WebcBTPp/9zQnyvw6i2xXftCtGkq1XPyuIHoSS1pKlnNGoK8C9j0A0/9aAiXGzFkkB5r
         0cSYxwbq0jBoXjBMDHJ9XYLAwQzRHT5c1QaaAyOKkUXJleqc29u2I26dJGtx27Ck5Uki
         T7OE8xgc36klnFVSEEwgRgcOU0k8BHK0g/aYytUCDOVQxR/r238BRoQm8LJ/tOkBDoqW
         JZCPzQXw6GJxzbk6om5VpT4uJtF9rNLRxpNgCwcdeVkvunQjFchRkjzdMVd4eFMowwXb
         5QXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUSHCVs1tyhA0g5eIHJ3cd93FnKnJV9YcOk1kopP254K/JbjpCS
	Vd2jECwG2gKkXvJ6E+sU7jkBbqRgaSbQU//U7ek0qr+yToJR6ebKeKr8hn1cQuEYY69CJjNZ5ZH
	fgrFm7IYN6dbW3LE37OxPZMNE1LjYDHJheIyra+hc/0nDA/HAnmQRkbZsazqurBY5OA==
X-Received: by 2002:a50:c28a:: with SMTP id o10mr105550736edf.182.1564587984789;
        Wed, 31 Jul 2019 08:46:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywB8EIrN0KfRtbjsBQd91xffvHyts0rEOQ3OukdUvA60AjIG3Uk5DzcXGnSsceV+XeCuII
X-Received: by 2002:a50:c28a:: with SMTP id o10mr105550662edf.182.1564587984017;
        Wed, 31 Jul 2019 08:46:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587984; cv=none;
        d=google.com; s=arc-20160816;
        b=WVRQ1XdWfWRuF5LUGmfUOlffp2QFuSTWHZV3/2bZfpB8wtsiXsKC97OgD6dht8L8Mp
         /javN2HiaNt84XQ5tLoIe2WmVzmw8py3/fi0T8Ocw0vtTR9UnRATaa1YgP9qQKTVELyB
         flch7gTnGxukzw4KHSt7AZVaQlXFS6ZLex4WdAETwRQr1JyFEYo4AvBkgkacV6kjft4G
         3CeLZDTMmjQuK/oXJVfRQjWkHeHMbBZ4p9OPklShMbY8N8aFVR0NiJjHZonfNuMHLuhV
         aI+qfkGqYKvzTIr+euTAwW9vSnmqnntitvpJN3GwhTRgdbVJFuMISeaQhhydhbvLk+7Q
         +JCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7eguvhFG3vFIX+cjWUMgrCPyT9l1sSVqWaOQbfj+tXE=;
        b=PlVDBsUCnKsEJLbjHkUsGlAWJWarBiEHn5LgQl4ageOKOtlCXASfFuBCJlE//b+/Hb
         27Fkdn7h8ohkWiMdW6s87WrHyCXipMDz0WHRelNbT63WrLHrf5QHSnjIcQOen2GRlfoo
         1TbaDVmQ4RhitQPaqcXbWIClI8qa3Tn4pA4nBGz+aF3/9/shKCIYd9BpWV+Ae5lp64la
         S/MXJfS2iFfATboKOWh5TTc0RHSOR67WK/IoGcGs+PC4E05oSQtDbVjMQ/NpB2xh4Jt2
         VX75aUwAsutMZqa9nw50stuKQOeAQA6sJXiJ/ltTTHsjvJRlix4QWrZGHhVH97skzMTr
         WJcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b38si21700149edb.341.2019.07.31.08.46.23
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 342EC344;
	Wed, 31 Jul 2019 08:46:23 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9D62A3F694;
	Wed, 31 Jul 2019 08:46:20 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v10 04/22] arm64: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:45 +0100
Message-Id: <20190731154603.41797-5-steven.price@arm.com>
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

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information will be provided by the
p?d_leaf() functions/macros.

For arm64, we already have p?d_sect() macros which we can reuse for
p?d_leaf().

pud_sect() is defined as a dummy function when CONFIG_PGTABLE_LEVELS < 3
or CONFIG_ARM64_64K_PAGES is defined. However when the kernel is
configured this way then architecturally it isn't allowed to have a
large page at this level, and any code using these page walking macros
is implicitly relying on the page size/number of levels being the same as
the kernel. So it is safe to reuse this for p?d_leaf() as it is an
architectural restriction.

CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Will Deacon <will@kernel.org>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 87a4b2ddc1a1..2c123d59dbff 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -446,6 +446,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 				 PMD_TYPE_SECT)
+#define pmd_leaf(pmd)		pmd_sect(pmd)
 
 #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
 #define pud_sect(pud)		(0)
@@ -528,6 +529,7 @@ static inline void pte_unmap(pte_t *pte) { }
 #define pud_none(pud)		(!pud_val(pud))
 #define pud_bad(pud)		(!(pud_val(pud) & PUD_TABLE_BIT))
 #define pud_present(pud)	pte_present(pud_pte(pud))
+#define pud_leaf(pud)		pud_sect(pud)
 #define pud_valid(pud)		pte_valid(pud_pte(pud))
 
 static inline void set_pud(pud_t *pudp, pud_t pud)
-- 
2.20.1

