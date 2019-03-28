Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2544C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77C2A206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77C2A206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19BBB6B0006; Thu, 28 Mar 2019 11:22:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12A056B0007; Thu, 28 Mar 2019 11:22:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE19A6B0008; Thu, 28 Mar 2019 11:21:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E75A6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:21:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c40so6982780eda.10
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:21:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=JFvUL1hUqkGMeYkkch7zOx0K2yjUnvKD2//jVIkWvxs9Fr86RuYxQcmsJN30B1eheY
         Wo/AVvivSvtbmzgL2Mvw9L1Uyvn/hSDDMdRCETAxP1egCyt6RbwxsHMOSkuZOPbwgGra
         neN6ODxYku6eYSQMO+8O6kSGEuvZYWy6OxNEBmx91QEjwJrc4409tGZM1rx7c2sxnEMw
         GcLBtJhZ7dKp3BkeDlU1clMOI5HY85lmvxvF5zQ1A1DiVhaFqZdw4HCThwAI7ihTE9Nj
         hi6RKMmqy7g3mtrddO/fpzcWqbhkx4h9LwvuCnzE3N5JooafFRX9fW8cOEpov5QkRFx4
         OWsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUBCs/deRGkQa9rqlNKo+cOqOuxzEsCkZ2NM5dzW1xTbza0Cwhk
	S2U9x8zS3JX9EpJXEhWbTBFDagWSUONKNhTRe/p9Kw00yi7dG1ijMEOmaucDc+qmzsqZBk4TtCd
	ozHmslcT6HEl4X44WHeJYujX/NnA4LBT9jkylT3BiFWr7GGiPRJu/wq/vFDvymuH/lw==
X-Received: by 2002:a50:add2:: with SMTP id b18mr29055445edd.43.1553786519184;
        Thu, 28 Mar 2019 08:21:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwisuE8PBzIt693Ng5JOgi5Fu4+eKvpVqLI5v6MEdrRusF79MXKMWzL2H07D9nio9JwXkbk
X-Received: by 2002:a50:add2:: with SMTP id b18mr29055400edd.43.1553786518311;
        Thu, 28 Mar 2019 08:21:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786518; cv=none;
        d=google.com; s=arc-20160816;
        b=NjLBHEhBovFSjXI8JjgIRtlDAwgHH0E07NFsuAdNU/zTyYNQ8LW++toyhWgl98xgMA
         7V1BPENoJylGyr4UOf1GQWRMLzrxg93nplEhPB5fSxYs4C5VKrbNd2O6LbIptgNI6sDT
         ++SkAKZVs0iHNm7/00hd707a6kfM5ufgikaVSk+vuCqk9S2xPLMBoOW/hLTnDI4xiqCF
         18K9cmhghWKy4GfeUHprcmQq9TUO8k1MrY34PcUsSv1sQqeL2gG4+dto7aibz3eY8xWr
         RtBhByhmw9MaXVdLyQ3EyUb7mOBf2cCOASo3Klw+vRImOxsCL5ankvQa77+pdlKYH5Gl
         67ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=pFIJ8Oy6ltzAlfUzdzJ+PbQqo5o6qdD9rOtgBeLxqCFm/wQ8RFJs+u+J2Yez+mhK3c
         dKX4xQoOjDSsyjXL9LMOBGPcj37Ox/hDqV6Db6fhuagw/2oQeCktVxb8DovK008qcVv1
         72HXkC6CiXmclwyyxK96Zm8fytTBlK7AD9rjB/4KXuEyG9Plq1oUqyg6tV+Jz9O6Q5XC
         /L8yhKGXd8OBNP37oJ0rqqckVYULQ6TNA2zi+qdNgLtSu1ywPrJyLcg2pSex4A7hCJEi
         Q5OIVqviW4CiYiYu7/OAPs04OSXW0Ho9jtA/MIokySgE9UENPJDUddfGFfGfQ56ezeyQ
         iFGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c2si3798766edm.332.2019.03.28.08.21.58
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:21:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 59CE615BF;
	Thu, 28 Mar 2019 08:21:57 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BED6C3F557;
	Thu, 28 Mar 2019 08:21:53 -0700 (PDT)
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
	Vineet Gupta <vgupta@synopsys.com>,
	linux-snps-arc@lists.infradead.org
Subject: [PATCH v7 01/20] arc: mm: Add p?d_large() definitions
Date: Thu, 28 Mar 2019 15:20:45 +0000
Message-Id: <20190328152104.23106-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
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

For arc, we only have two levels, so only pmd_large() is needed.

CC: Vineet Gupta <vgupta@synopsys.com>
CC: linux-snps-arc@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
Acked-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgtable.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index cf4be70d5892..0edd27bc7018 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -277,6 +277,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 #define pmd_none(x)			(!pmd_val(x))
 #define	pmd_bad(x)			((pmd_val(x) & ~PAGE_MASK))
 #define pmd_present(x)			(pmd_val(x))
+#define pmd_large(x)			(pmd_val(pmd) & _PAGE_HW_SZ)
 #define pmd_clear(xp)			do { pmd_val(*(xp)) = 0; } while (0)
 
 #define pte_page(pte)		pfn_to_page(pte_pfn(pte))
-- 
2.20.1

