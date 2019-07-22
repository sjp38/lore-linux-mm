Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47A03C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F1C021985
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F1C021985
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9958E8E0005; Mon, 22 Jul 2019 11:42:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9465F8E0001; Mon, 22 Jul 2019 11:42:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E87A8E0005; Mon, 22 Jul 2019 11:42:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB788E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so26566797ede.0
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dw5qvPvLE7W70oX+QwfsL5BaF0k/anytr4XJVfIwlRs=;
        b=Dx5bpA5a/L5ouyj4BBuGevGG3qjVvHkjS7WiNqEQok08T4ToS/ST7UNwW5LZ8OBaEg
         Vu8iMQ8sCwhvfwoTF4pXWZHcH/su7kdQN23Fi0XlKpsY72qX1q8UXbK9txBF1SKOElv9
         En37fijxB5gQGhj1dd59AgCAMNL4A82cyLZ4THEh2PSEPB96Zl2vJkXRSrujoGi+FYAe
         GGk2bmxPqFIZ3LiXypy4KkPZl3ADiJdkG4SURCTRsKugXCnTQE+yP9lZMbL33dLnvLdb
         wKVm9OMRzbsTaGT6sRlcwuHY2HdSAFsVTyDdow+MKz2TPFjH3gCvIBq3VHI38IJZafnl
         I25w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW8j2g6Du84Y+NJT4kgrAJrB1DxJ8vgMlyU18ao5F2RQl6yZCG6
	Di5XUoNnMiLnhPiw4s3FMtLNDUwZ66qkeQI/pfb/uhhj6zwvUS+jryuli7g78qIaFgujU8XvaEZ
	B0Cojz66OZuBKwm90dQ+RdaGYM9A09ug4BGF+YMlBE0NVG7zHmYXRiLNqvQ3s5YbdtA==
X-Received: by 2002:a50:b122:: with SMTP id k31mr61765815edd.204.1563810153773;
        Mon, 22 Jul 2019 08:42:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDEJNdX4RKJS8kfarPekfxYkF1MvI3AUcqsoE/8JcjtpY4nYBKMqnkw6LxUYWgiqGoDH2l
X-Received: by 2002:a50:b122:: with SMTP id k31mr61765758edd.204.1563810153046;
        Mon, 22 Jul 2019 08:42:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810153; cv=none;
        d=google.com; s=arc-20160816;
        b=zH5wd8x+zwJaLUc3R6NorAtz0bU70eN5P9Iv78b2Qkd6R5Y1DopFnts3roLxyBOrWO
         4+0iKk1q0mnQdlfYQDR6PLfbH8GsklR4Q0psbtCmGYzfj4C39VpYvV5eoOO6n08wqdmD
         yoNwJPFkItsWFayFpF6/APCtCtuOWxKdmRTgADNs1/NnTwxsirq5gmGWPrq0L0vlQYZE
         1kqcoOz76X924eC3oGJgI+QdzEEmkFIeVZ5anPSNEqsWy5ZCiSYrhY2jjS4V3XxJ4FJp
         GeUM96UDgfW/BMVDhZ91nDI3516y6egqA/UPXQqKhZU6cwWNPJLulvJ8HSAinyyGTy3c
         eITQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dw5qvPvLE7W70oX+QwfsL5BaF0k/anytr4XJVfIwlRs=;
        b=aWgyt6Bohk/WQJnZGdv/dwPQxaGFDuOU5uvSRc+TnbiUUXPLKeLmj7m+sE+etJPTel
         GHs47uzHZhl/EJbUCtdTPFncFfUrXr87kw4tE03vJofJvHU06nrMJhEnTB2a6wuEJmOE
         KYT9syqp8yAuEGPOpu8JMuheY0Oo+DXLWbe0fOZdMgADxG1RtIYYSQeRjJ9cOwBBb8L1
         nZQSmfh3DRaYU5fu+w4jQVURE+VpP29xuB8Dn2URwQs0RM4thXKQVvIs41ngBVld5OSy
         hy8FK5hPyNjA9TPYd8I0nn9pi9Ug0eug6vLFKzUgQdIfp1oUyXjiONQBosQARPHGZwon
         kU7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 9si4929231ejv.195.2019.07.22.08.42.32
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3C5BD15A2;
	Mon, 22 Jul 2019 08:42:32 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A3AD73F694;
	Mon, 22 Jul 2019 08:42:29 -0700 (PDT)
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
Subject: [PATCH v9 03/21] arm64: mm: Add p?d_leaf() definitions
Date: Mon, 22 Jul 2019 16:41:52 +0100
Message-Id: <20190722154210.42799-4-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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
large page that this level, and any code using these page walking macros
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

