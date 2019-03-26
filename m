Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2ADCDC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA4E0206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA4E0206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87BFA6B0269; Tue, 26 Mar 2019 12:26:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82AE76B026A; Tue, 26 Mar 2019 12:26:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D9F96B026B; Tue, 26 Mar 2019 12:26:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 135166B0269
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:26:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so5520746edo.5
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:26:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=YKXhOaYekNIohRIbw1JelrHT8LjLM9KqRZaRo24EHEy9nCLc/zQDz5YskT5lWTB8fx
         9yMzGyiGjzrDAnWOW6O28yOyyNbc6gOiYu12FEDnA2Ult4JBunQiRouinl/R6T+kn8hW
         XGnpfeT3F9glXrQr7yh9IO0+yCEnC+mhgh6YSOVk/fAHJCNMkDrEXuFyV9cK5SFUXZsV
         gQGaJHWSpV9AjICEfFAkTtHcPfH8XePtsEcQBuXod7AwUxmKLlyna81FMEfF4EECFjbp
         XwvFttB8avY1JL9pYHmhqH6wSiD1Bk79k0m0lvyTZ6uz9fCOQJUSU/PZehULGST3Bcq5
         JePw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXajcfbBGtD8ZO7SUCKuv+U90obVoJqRtTrk2rjNUk1Tj7PDxru
	lIvxMoKtaiGlRfEZqN3Yn7XMwf253JbOWJAk9BJ4MwOjYSLcM5vKUZ44poW2BoFATAdYVXp2LTR
	jVfWZCJ3o2m3+PG5t9MJyraV6/LRzTDnRM1aQ2vIun9PWcG4ulKI22RPkc+UXzHVP4g==
X-Received: by 2002:aa7:d3d8:: with SMTP id o24mr21607893edr.53.1553617604572;
        Tue, 26 Mar 2019 09:26:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxehmF2ENSAgoB58Bd1douq1IqWuhtVTmRCWzjIGlAa8tRC+FZOfLs5p1umXgr8A5x/IMbZ
X-Received: by 2002:aa7:d3d8:: with SMTP id o24mr21607840edr.53.1553617603703;
        Tue, 26 Mar 2019 09:26:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617603; cv=none;
        d=google.com; s=arc-20160816;
        b=Gj7jGmF2GFmt3VBEdTW1pfTDkOM0YgzgVXU1P5cyWkmJBYlknw/SvFht0KQ95UOmni
         qm96AFeOg1wxWU3EbFuSvnXONrmFMLX5G/lvIJgiMkypsfaXWVxRvw5jryLgsXWVXufL
         14CP50spkIQone0bemBTosetiSbAtSAJaBsBzmloEHlEraTseryn5NyrTVytOXeeR9fY
         ppowzHMvklgVghWPYJIIq/y5cZKVtQZaGr+vK1SDC6TiY17s04NT1NJ8cdCOou4HJHQZ
         L+hTqcBzW9POYRjnE+IDfb+aIDelGZZYC69RmdaxOKqAKD0IY/7+Uir+1dba2Bd3Hh8o
         Cqkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=OQU3GDFjlaFW9RqcTqQMS6mbr9SQh+Ms0WGfPMyJPmUczGK7LSkWelCqqzMK9E9quU
         xQQu88TYAIJ0Zg9iWT8dTV7MLa5/ig70/8DRRATRnehYNlvDtEWwHxzREaMs5hsfDpb6
         uqWk+5fLrgFJh85JhUyTzC7ZWEDSTeORMyNUI7EFELLS6NxxXUizE4lfBBc15/hGokJD
         WFeATnuMYcoWP/8TqIs5dl300VqtwLGG5h1L8vsIvi7i2FeLArx0AigpQjBq+px2y/CG
         gRbFWn1vWKTwL++mziP3gbNUs8U+3SPEShIgKng5tw4GoCdwRHdXknF95JS40KNxGB7U
         aEuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g15si66617eda.20.2019.03.26.09.26.43
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:26:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B06FF168F;
	Tue, 26 Mar 2019 09:26:42 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 74BDD3F614;
	Tue, 26 Mar 2019 09:26:39 -0700 (PDT)
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
Subject: [PATCH v6 02/19] arm64: mm: Add p?d_large() definitions
Date: Tue, 26 Mar 2019 16:26:07 +0000
Message-Id: <20190326162624.20736-3-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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

