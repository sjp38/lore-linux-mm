Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87CF0C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F6AB20830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F6AB20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 043106B000C; Wed,  3 Apr 2019 10:17:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F34856B000D; Wed,  3 Apr 2019 10:17:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E23E46B000E; Wed,  3 Apr 2019 10:17:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91E2C6B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k8so7582078edl.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0eNmL9jfrpxDxa34qI8mFbQ8g1QTc4gDo9JxlJwzabQ=;
        b=Bm5KiMJ9HhyKAOjyqJQuVbwM9g8XUvlaZSUz4dirpnsG++ipFi6GLM8dgUw7sfKp2z
         rG0tBVjfJ/rHLFo5Ip3LGBbKjF6TYkPxAotB9FhCAvTwuRLWDOvntAXwwDcokEAQPkqd
         ARia2F8inRHlGpYtbLhc8sV5FfbPN+sTlAMXkE9tyNgaUJ+gM+sD0qROQPmo99zCruTc
         0Uh+Sw2obtofWg5ZKLY/bg8kbZDCVXJn39+29SZF7hBZK2cXz76MYVmdS4PRSzqn0X4w
         Fm1sZwdGXcEVKlrl/TyHQm2mPq6gawSC9bRAAPZlxew9CYEKmasiVxb+i1WCGPJiOoJt
         /FLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVyu+EpU7zGJsgyyDv+aAkawNhJ9SH2qFxolL0LdCQ5/zlj2loK
	YQEk/7vU1F7bip1a+B2UmiwXBCcIGd5l/XRSSUO5hbqrfpiwpEqMQLOLkhjNca4V1RbBTwcPttO
	5l0oCgCFBDhu2tliUVw0Z1BEW1rGCjgUT+9hz5JNOETuGpJ0cPXCmKWEuUVTe/mj+FA==
X-Received: by 2002:a50:91ac:: with SMTP id g41mr48831564eda.188.1554301041105;
        Wed, 03 Apr 2019 07:17:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyZd5FDIyrDYxBfJVaPs8YlOaK0zlgnBcrVgxE/6XaPQ8cD8jY6eo6DbRBVHjRAEd+lO51
X-Received: by 2002:a50:91ac:: with SMTP id g41mr48831511eda.188.1554301040065;
        Wed, 03 Apr 2019 07:17:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301040; cv=none;
        d=google.com; s=arc-20160816;
        b=I0L803pVY+dhp8wu0Or+3tpjHnoJXVaRdm8R/PeEpzMIoEnjJ2CB50tGTqRPVBJCj9
         6Kh1MHpkDHRp+hqo+/QHYGbCeJIxGoqhQNQ77q4sBOJ7aptqOVMXmOtU8iZnSALPUcKI
         OAroUiXle80cE/H8e88lSoacYcLpwRdsSoBIjYDov5GHcBtLQ8a8kVEvWpAWVtU0sXB4
         fnIVw7GeHuMSL4KfoOgg4Lt9KM8/qUPa5hSejhl3XNqcNj1zG0o/WSgsEE0TSN1CK9vk
         MdZcT0a/RlerejHQRpqlp6T9iNp0mmyvHdjYLkak+p6C5TEI7Afqej6rJY/u3853p7J6
         Fw3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0eNmL9jfrpxDxa34qI8mFbQ8g1QTc4gDo9JxlJwzabQ=;
        b=vfYFo9L1HoMGcS1V6zG9ZIfW9Jxgkab1cqQ8yShjRjbK7VmoKVm8R2mCsP9n4SG8GU
         r8yayHWWnS4OXpiSwdzWAJijSgBq/2WDxwtodbXa0ywJelcGzmfeX4QKmRwAf0KBLBCk
         Lk9qN3MX31/ueFfhhYQIFy642OAt2hfSVeGVAhXqGom7oQP5N6wV5sWP2UIG3CoLUd/Z
         nh9FuH+I3ySip89gIt0nCT5q93radTG1s4mEhMvvbOnB9s7mPAyhOZlg61tevCzhydCK
         dOIByNzVLb6GB1oq3cuYPgM5esWPA7oVlko7VZ+2XQSNmpnx8NnnCwcFfC7mCgG2YDPC
         fnlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p4si1349570ejj.274.2019.04.03.07.17.19
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1ABA01682;
	Wed,  3 Apr 2019 07:17:19 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AF9D83F68F;
	Wed,  3 Apr 2019 07:17:15 -0700 (PDT)
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
Subject: [PATCH v8 02/20] arm64: mm: Add p?d_large() definitions
Date: Wed,  3 Apr 2019 15:16:09 +0100
Message-Id: <20190403141627.11664-3-steven.price@arm.com>
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

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information will be provided by the
p?d_large() functions/macros.

For arm64, we already have p?d_sect() macros which we can reuse for
p?d_large().

pud_sect() is defined as a dummy function when CONFIG_PGTABLE_LEVELS < 3
or CONFIG_ARM64_64K_PAGES is defined. However when the kernel is
configured this way then architecturally it isn't allowed to have a
large page that this level, and any code using these page walking macros
is implicitly relying on the page size/number of levels being the same as
the kernel. So it is safe to reuse this for p?d_large() as it is an
architectural restriction.

CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Will Deacon <will.deacon@arm.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index de70c1eabf33..6eef345dbaf4 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 				 PMD_TYPE_SECT)
+#define pmd_large(pmd)		pmd_sect(pmd)
 
 #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
 #define pud_sect(pud)		(0)
@@ -511,6 +512,7 @@ static inline phys_addr_t pmd_page_paddr(pmd_t pmd)
 #define pud_none(pud)		(!pud_val(pud))
 #define pud_bad(pud)		(!(pud_val(pud) & PUD_TABLE_BIT))
 #define pud_present(pud)	pte_present(pud_pte(pud))
+#define pud_large(pud)		pud_sect(pud)
 #define pud_valid(pud)		pte_valid(pud_pte(pud))
 
 static inline void set_pud(pud_t *pudp, pud_t pud)
-- 
2.20.1

