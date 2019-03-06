Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D08AC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:50:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 058AB20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:50:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 058AB20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB3358E0006; Wed,  6 Mar 2019 10:50:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3BFF8E0002; Wed,  6 Mar 2019 10:50:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92AF48E0006; Wed,  6 Mar 2019 10:50:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE1C8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:50:56 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f2so6456184edm.18
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:50:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=qF5Rl+9HdODZowxwei5NAUla67PNplkDMtrQOyH+7dbBDsEo6FzHkAmX3dri510s9Q
         tkkIOhMp9vE6tOY0pk3+0jOa+FM1pKFD7pWlrR4hqS6ZIrpq/eD95dt9muoJbqbSO0pG
         WxkYYwedAKWE5BxFuIh4XA+/YpeQXkAiTxTuPvgTMYb75jNL0tbH9lEnNpD/9br09Rl7
         oj9eTV5yJZ8W72X/qAE+pqEuAIM+NEM5MtXhIqY3H0gbNKTckmfTrUevuKW/YPuseSOF
         2qcOe/7yTdr0spnZlz6OgOMOHwANMYi3BCVfWpsh2MaBAcVfWMitLk8z676SJeVMKUny
         qJtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV75hvVoKjJKbsnLnfJJW+eugRl/mqFcvWAofolTFaB/WyCiC3i
	i9LQp3f4uyzAtYzhQMteVV4BZZtVfGxUX60M/d6x4qL7ZdRrvWzhtNR88EpR7kQNFFC/HxU7alf
	WBLkchww9+bo8Yxn7acyCVYyWvlj5DcUHiM5osWUS+ovUos0zy3Cc4s87vokmgzHwuw==
X-Received: by 2002:a17:906:1b10:: with SMTP id o16mr4349027ejg.184.1551887455470;
        Wed, 06 Mar 2019 07:50:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqw5PY5iX0vBxzenuxfEpGSQe8p7MrWdyvJB90iIWkK0Bn2UKdm0N99XkVwfqaCyb6jzyNUP
X-Received: by 2002:a17:906:1b10:: with SMTP id o16mr4348955ejg.184.1551887454115;
        Wed, 06 Mar 2019 07:50:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887454; cv=none;
        d=google.com; s=arc-20160816;
        b=FTno8MxPKMP1dVa8ZboXg2f3MkFbG9gcw6YuNr43lnbFSOcT9DDYhTvaH84vKrMqvG
         R1OQPp/q7cNL3eEByyWw3NU5NDSaurharA99hiMlq5khtmjWQK82tTfud0WFIOCanJZb
         F3PpPKsL9s/3QiPt7Jo8ARhAWSD+1WGgs0rWO5eUtUCOCSKoasagFdb4X91my8QmJciZ
         5Q2n7x3f7yJRbpwH3+2CirmRQJOOm7TP+bFl7KnObgvu7eBSAauehHgiI03QPKvx9zB8
         wUoMEDDrWrZTATDkV4DOXnq3BQMN+KguXnPegfDweXg4P0fVfiPs5W72XKP6ufA2G3/X
         PGFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=jYzqQ9IZ/PD6FR75YrWDgnqcFvQXt++t1FFih7UH6trSL0TMPSG5pJlgsRe97tH9NC
         JkbJXTwecf9re2l3+LomsDm8CmSoYMKz+u3ZfSekrB4zpZjdMA2+QKXt12nVfW0KqW1r
         9cJAfEc81GxzVREkg1WVviGTvmgJtuG4hrU2O0s5lkSVzGaJXGbKI0o605wp1HIOD9fS
         4bvm01oa6RKlNMCywOE6gUaeJzLd5yQJw7K0t8JqBQR4wxyX56TTs9rvGk+wjJdeJzbp
         jyineMyF8tN+4GQO6MecIbHM1/vuQZA9zlPwNzqWiWH8ah8ykFOCOgEJzEaX7Ua3ovEB
         XE3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id jr13si751296ejb.235.2019.03.06.07.50.53
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:50:54 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1612C165C;
	Wed,  6 Mar 2019 07:50:53 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CF75B3F703;
	Wed,  6 Mar 2019 07:50:49 -0800 (PST)
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
Subject: [PATCH v4 02/19] arm64: mm: Add p?d_large() definitions
Date: Wed,  6 Mar 2019 15:50:14 +0000
Message-Id: <20190306155031.4291-3-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306155031.4291-1-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
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

