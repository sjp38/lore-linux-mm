Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB2D1C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83BFF2186A
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83BFF2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3671F8E0008; Wed, 27 Feb 2019 12:06:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 316BE8E0001; Wed, 27 Feb 2019 12:06:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 144128E0008; Wed, 27 Feb 2019 12:06:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACCF08E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:06:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y26so2499044edb.4
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:06:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=fz3/GNRkaNKpOFa5Tmpe51RcAF9EAV39lb2nWPYRbGnzNDbDMtyjYX8Vx29pHQSbVf
         1ghJ8LRo2uSbKsbLXRqkTWRJFd9hXdT88tVr+ZzqkVnZIEp5nClmcGX7kyFKeKT5FJwd
         0LMDg9eerQd6sLHvPRmyZoBpblHtCIP/RyXMvaPM/Xy7c9kj+2y2NSjwQCUV4CvhQLBG
         xfpCCLhd4rAoYysv1QPHMPWpjbLaA5Pmo80W0UpeIMrrjONG9zE0t6lArWMlbrGxhVFy
         M8VbjI8XVOAs0BKzSyNLfkP330US5QciITZ6wOuAbGiFODJSeqJePzv+u9Cflm9h1wqy
         UkjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuapKNJY//MLQd9jHRhvteWXJDeoHrP++uTRIAw9vlkUwUkkhddA
	FS/aLsA3ZeP6KSa/6rrRWEGcRR+xyzWkZosb2OTZx6lRZKf70Ne4znjtiDwuvJbFRBtiUZcLTWt
	aiUkVHrFJOqJUdcwBC/2rC5mUZHiRc8EjxeZPvWepkRF8CmIbG2apbLqWT23QHkF6TQ==
X-Received: by 2002:a50:b16e:: with SMTP id l43mr3012872edd.99.1551287205215;
        Wed, 27 Feb 2019 09:06:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaHIdR5UqBcZZjizTuNL6/H1VWonyJzQmPy/fovgexu1xL50PjY3a3wg2PPNptFTJnIR949
X-Received: by 2002:a50:b16e:: with SMTP id l43mr3012804edd.99.1551287204136;
        Wed, 27 Feb 2019 09:06:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287204; cv=none;
        d=google.com; s=arc-20160816;
        b=kEJSYqqNy84JmfYhTd/rrktbi5D9EZ2p6GqAQrCeC0PMs3RBwYeY4jj7UBc714J394
         lRrKANH/nam/gGYI5pi5f+81jC9fjVk5+pA8J2W36Rgo65ui/7RcTgHgINyuzmBtqts7
         HtHJUR11UyZoNu6kHH/2RNwpCa3wUnsdWPtBSyD+QnDo0m97VehtrMANFd/EMHG6FivM
         YMppHu69HQnHn4GthYRgDFJopcmb/SzaNe8YVJa/VbRWL0xQI/WNRgANJHGTdFO5hcJe
         GU0XSNTMIj31jS6kX7vgNpsVLCEqJEZJF1kMhowXOYtxlszR2zoFDDtCL5cCnzvCP/y+
         PCKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=rXJok0Sh7VIFmLugHChG2XnExyDpEFp3AWXJ9An5XDlkhq2cIFgrQdgYXvUckpKno7
         F4+HN9NGPCAy+eISxzEAuKQhILgDfHO73jCTqYINRRyeDwnE2xMuBemDY/2h0tmiVV45
         uUpW2uiNccOYRTOEoi8dQ0YT6/G1WVileE3A04cLb2BsFUyEfUapX5mfV2PKDGozp0YD
         nIVqqxRgHfGkoUSUH+Ds5H+D6g7+y/893T45kK3T2R8pL49YWqO9zc02d8QdfPGkiTrX
         Uzt2xCMCdtw4k+fx0JIeg3HoXRyOiQ39wqzhcPstrF6jK8JyiWSRRX51ArRy4aWRSLdG
         hTAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o40si3285221edc.108.2019.02.27.09.06.43
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:44 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1ED3A1688;
	Wed, 27 Feb 2019 09:06:43 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D7FD83F738;
	Wed, 27 Feb 2019 09:06:39 -0800 (PST)
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
Subject: [PATCH v3 04/34] arm64: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:38 +0000
Message-Id: <20190227170608.27963-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
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

