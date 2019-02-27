Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63A1AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ADB320842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ADB320842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF2EE8E000E; Wed, 27 Feb 2019 12:07:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA5518E0001; Wed, 27 Feb 2019 12:07:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A44128E000E; Wed, 27 Feb 2019 12:07:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0B88E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:08 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x13so5022131edq.11
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8WwnUWaYGMHoutYzvtb527XsVGA/6K7onIq0f5cih6c=;
        b=JpccEGmz0GexxoGTD/Dok4Z+IQNlsR9telJua3ygesLENOMwa3ZmScPuOMnoH7j6Bh
         EdZJzQv1V31qLEZPOe7G46y7W2d8HME/uCOTWO3jDdOkUnswb+o1lKk8+gOwrc8xGi5e
         FDNsUUpHhbx9WZT3g89Hj8dqa2UKOiKzH50pYDADFi2UzCPKEj1Odfp7TXeh8D+wLyKA
         arTX9oXaAxkv9b/tBqwb3aNGCmIMRWscO9nD+PBl7K/UZZ9FHr+QCslv21ce/OUU5AFL
         6CMFa9K/wt9hZkLJxTqvpeNyROkGCA90iWNBjc064EFw3lVjGd0GDzI10NLoZECGK8DI
         2qxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuY7QWym/72WjcUpkZjRHNHrNDNdhlqGq7qHB/wabsGgX0OIf9u+
	vpw5PnUjulc0pVP9qwrJVGni17vEKpmjJjnKa7lY0biY3S3rzuT823c4wcV7SspSpqHa+EoovSD
	Y/Ssqy3R1yvpdCA9eyxjnfedOFBIUjzT/ROr+/5FxxbeTVwr3/knLlgAEaMhky5xweQ==
X-Received: by 2002:a50:a4b1:: with SMTP id w46mr3063461edb.215.1551287227822;
        Wed, 27 Feb 2019 09:07:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZPEvt4qI0vg/VAwUlvTXm8vI8DLVI0PrBe+fGzMUkOr7WmRLHbkTVhzvVk+FzSDwfokZlp
X-Received: by 2002:a50:a4b1:: with SMTP id w46mr3063393edb.215.1551287226862;
        Wed, 27 Feb 2019 09:07:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287226; cv=none;
        d=google.com; s=arc-20160816;
        b=as29YvEGLyDiMMc3b9lO7UgqgZEFT5Rbo/g6nHna/HPPwpv9XgbvKTADKo2wGXfqL5
         Z7RjhyOOALMTGqrlMUI4kcWExu9399yv561pQgr8zLW9w0t09/8LpUxc3EaLyjdkASV0
         A3/1LTjsuZzW0BL3WIZtEtKmf+pZWZN3hyvPG56q3xkmLkBUfd1WTT/QpnFlO2J56U9q
         LXwg6UYhPOI8wS4IZkGNl1IAVbS1+VMIW4bt2hLliSfkfOMLE9d5Y8D9QQ7jiyS+m8vo
         sVGgBistZU8V4gaJWXt+uzo5C6dmE8nCzdVuGbVhRIXBo3dspxa5/LMSGOkN6dzgMv/w
         a8KA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=8WwnUWaYGMHoutYzvtb527XsVGA/6K7onIq0f5cih6c=;
        b=sr2xzMRxInSNPmI7+OXvs/8OYCam6CxYrcuVqAt7bD2CFM9jl1u+p7rLsZB8m7KH/g
         RKCH7TL3cTHDdwR+Lw4S2QpHHU3n8YlOOY/FS+d9w66tZwI8ZCQ9jh2e6t2IKPBd0OGt
         fM4kdOBxGh60LTIJnH+tJGTaq/TKooh91DWSKQW9X3e7xK4lbbduzsZJDluMSDyhMCDh
         d0NL7N4lgikej6XiPwcYN9w08ElSD2IDkiNC4zmpAx3D0meb/0aNQGlBN4rV8qVKwpiB
         RIL0IqalQWNe6l0saXQ9c7PvF/iY14IVp+CcYSP7pbd9bgSszC6k3YiqoRYwQb7ZanEC
         baPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s45si260305edm.357.2019.02.27.09.07.06
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:06 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D81C11688;
	Wed, 27 Feb 2019 09:07:05 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 794C43F738;
	Wed, 27 Feb 2019 09:07:02 -0800 (PST)
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
	Michal Simek <monstr@monstr.eu>
Subject: [PATCH v3 10/34] microblaze: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:44 +0000
Message-Id: <20190227170608.27963-11-steven.price@arm.com>
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
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For microblaze, we don't support large pages, so add stubs returning 0.

CC: Michal Simek <monstr@monstr.eu>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/microblaze/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/microblaze/include/asm/pgtable.h b/arch/microblaze/include/asm/pgtable.h
index 142d3f004848..044ea7dbb4cc 100644
--- a/arch/microblaze/include/asm/pgtable.h
+++ b/arch/microblaze/include/asm/pgtable.h
@@ -303,6 +303,7 @@ extern unsigned long empty_zero_page[1024];
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define	pmd_bad(pmd)		((pmd_val(pmd) & _PMD_PRESENT) == 0)
 #define	pmd_present(pmd)	((pmd_val(pmd) & _PMD_PRESENT) != 0)
+#define	pmd_large(pmd)		(0)
 #define	pmd_clear(pmdp)		do { pmd_val(*(pmdp)) = 0; } while (0)
 
 #define pte_page(x)		(mem_map + (unsigned long) \
@@ -323,6 +324,7 @@ extern unsigned long empty_zero_page[1024];
 static inline int pgd_none(pgd_t pgd)		{ return 0; }
 static inline int pgd_bad(pgd_t pgd)		{ return 0; }
 static inline int pgd_present(pgd_t pgd)	{ return 1; }
+static inline int pgd_large(pgd_t pgd)		{ return 0; }
 #define pgd_clear(xp)				do { } while (0)
 #define pgd_page(pgd) \
 	((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
-- 
2.20.1

