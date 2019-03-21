Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A803C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FA52218E2
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FA52218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F04566B000C; Thu, 21 Mar 2019 10:20:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE93C6B000D; Thu, 21 Mar 2019 10:20:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8A8A6B000E; Thu, 21 Mar 2019 10:20:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6166B000C
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n12so2297513edo.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=qxeETPs2KPdoDY3HyBQKhZJeky/OHceUrG8NFiTKcOOW+mscZuU602L5TQjzKQlgak
         vAilgOfB6F8HMN9alfJwCGAq8xZI8e7+XogS32lcjoWn5E9GFuSkcauOj2yWNY8bVHbg
         /e4yLUZTEQ+JO0Vl13nM8KqcB2f2bLGu1SUe4xGQaVdYSDM0NSQcHN0qfpVpeixNd3QY
         gQtJTvAd957yfUOv4d4W2cYu2tcEpNg5KDlq3QR1Fx6qtceGQJequ4TP+KW0PrjLBSHq
         yZZbToUWm53UfsH/x47rUrAvIdJlQd+fgvWOme8g6RE/ot4fiGxuNrEIGMxhYS+KRHt9
         nDgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUi0Akrw5b4F3R2cSQmw/fnYtu4PybfqcCSGY0lsMhFSI6ByAHR
	SCdOPEUSRIyeIKZvcVgNxbAc3aTAKfOBbsKlU2ZVImQO52WR/N5yHjmZBTJHoz1aDdU1CpwUHT8
	neEkEXMpFwhLnFxeWM3d+88jBr9YQG03m3dQOCLahtEBJwVFdClMR5AXDxfYNx2nNpw==
X-Received: by 2002:a17:906:a85a:: with SMTP id dx26mr2386153ejb.206.1553178015036;
        Thu, 21 Mar 2019 07:20:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLEZ6E+Y+Y7EtyrNmqHgfCM32p/zDw0AkW/qPT4TFUFayFVB6E/+zC8EraQz+hRjnQ9+Y1
X-Received: by 2002:a17:906:a85a:: with SMTP id dx26mr2386114ejb.206.1553178014213;
        Thu, 21 Mar 2019 07:20:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178014; cv=none;
        d=google.com; s=arc-20160816;
        b=wYWxIR58DRhZFeXuMDKoz8asxLu8nkrK5JgCi6JkUNoq0dMc/NtMsCaatVU7YAn1Kh
         iIgw+SZymqvycT+KVM70LMxFiumE/iRndtJWxv2OPhogyvVoXtrbcyJTOFv3SJJSur4R
         X+K/Wa82soprOqYE5aemzS5yPZVdmZQ3tHKzVzP128p3+5veB4RNzp4KnkLh9tHIroxR
         rbTv+GctIcUadofAagkfT+2sD0NitAzAXfAk/h5efmNeTQXmcyvSWLsW8LWQHTmSg2Ur
         12iuK7Nebn5YRxcdBy8Ixz7rDQ9SaHQJepI0Q5dAgNhed+fLmwT9NtA9tLKAPFrm8koZ
         0WkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=bx+stsjy+hMkxPQByDhupgg/j/E/xp4Zn6D0MqP5lqQ5rg1rQTlI6QPAk1/8el00uh
         oWa8q1/2oe1/Bc9rx/OdM0w7JCqJUYSqbIhEAicqDeOYcBwmyLaZF6ICw3M0GX2Xk57K
         e7ZdKF103htvwT9Wgj9aREAmQeY5UWBlU3BPoC8o7oZ7jWyuFJ9Tyy/nwooTDE29mSvs
         UNiQTyc8u5CEbZSEBy8iZGpxW/M38AbHLwQIhE/KsRJUhkOXw925romILzg+RrHgPycN
         bNwMS1SAz3z9KwrvyD9n7iORNyXg969lLa2C0sDi8xNtwhvy+h3thtpItUnzgVIyB+7z
         KA0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n23si1527317ejk.268.2019.03.21.07.20.13
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 44B84165C;
	Thu, 21 Mar 2019 07:20:13 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 079C73F575;
	Thu, 21 Mar 2019 07:20:09 -0700 (PDT)
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
Subject: [PATCH v5 02/19] arm64: mm: Add p?d_large() definitions
Date: Thu, 21 Mar 2019 14:19:36 +0000
Message-Id: <20190321141953.31960-3-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
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

