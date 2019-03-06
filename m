Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B918C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0736A206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0736A206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9534F8E0008; Wed,  6 Mar 2019 10:51:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 904538E0002; Wed,  6 Mar 2019 10:51:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 759328E0008; Wed,  6 Mar 2019 10:51:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDA28E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:08 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y26so6584827edb.4
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HeBpJ/5/E/W6YLustewMuJne+7VmLrz2+1cQ19OBNYE=;
        b=VX9hU4A+L6Vl+FXMLILiQjO9v6UwuTpOerKVPPJx1EXiN0E3p6i3P63EwDV0/ds/Rw
         dlV2yTZ/TM9xl0hSiiUccFMk5jrFYSpuPqXnpiKLfY2d/UKNEi1RnnEbFge4Rd0yL4o5
         HzTrMNTEAduBR8NKlhqaH4VNUIZQkssGfun85YooH+A6ghll4IzGeckMW1SZ6U4kAqsX
         KbMpSVPSQNFrJdTrEfsMnYZ+GrGtAgrnyqygAici+m95fnXJCIKNn6alN6Zf9/OHFtTs
         9gNUVXws09OyEiNvhcjKq9WDdFN79UaNrOscy+9NBruY4oVOnCzPPgksqzr14hTrWiry
         OsEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW8sSXLKwPQj70R1RK7xID6Eoqw7lzS/jrSuUnLw9KJZ2UW1nrY
	Adp4hosOcdAgtbdIhtqch0xOWiU9fKYZNoT3uyd2IQqib9nNhPTZML+CBNyyVDpXrfCtaHX6iUc
	QBQGZudMzmdKo6KsxqiJ+SzweOjXJ/M6FpcsYH8WvuW5bpZsZfaiQq5l+IN8EbgyQig==
X-Received: by 2002:a50:ad45:: with SMTP id z5mr24093513edc.61.1551887467368;
        Wed, 06 Mar 2019 07:51:07 -0800 (PST)
X-Google-Smtp-Source: APXvYqwpU9x0p3uNcKzogjkzmfoQY7kxandjDFwLL4o0n2clcis/N47EXoxDwX+Wcroeh/NJed4H
X-Received: by 2002:a50:ad45:: with SMTP id z5mr24093440edc.61.1551887466311;
        Wed, 06 Mar 2019 07:51:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887466; cv=none;
        d=google.com; s=arc-20160816;
        b=JcBp5QQZ3GZsJeGwgLiqz55HJ6i3whybBXtMkFLuN+1Co0gCPyWKtH3UYXf2tFduzb
         yh6UGrIFl3ELBghij4QMQfIAe4e5+e0yVURSU9Xb5qSZR8fFZha6qhtCGy5voEHcsHT9
         rLcFe/U+DvGQNZ/o2XMuUXWGPqsKwS2/avDijjuBYcxrEa4psGc0UBgK+MdCkNTrzzzi
         EW+vcc94qzquW8NAAfNBRfFtUs+k+PK/cxZOiqZvdGHR2FndBEycj40ooYteFsnRe/Y+
         SczUfJRUQJRyf1vkDXtyLOrbob4hairpJkvpl9SqUHkSxw/2vV8k3h3+8vmN6JwsOYXk
         77OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=HeBpJ/5/E/W6YLustewMuJne+7VmLrz2+1cQ19OBNYE=;
        b=0ukJlzUs0MvOrIUcykW2f+v689NY1RMUEhTjlIoD5RxtJr+gEPj0eucZOjuB+x3JI1
         0sdPSdLEfsxK+tKo6U77RYWqDpiRKDzf2JL89B538fYqSomJ3O68tpRyI/U/BOJM91NW
         kKamtkB9mEcX7XuDNI8ewdJ5A9vfgCDg4s1LH2+JMW5T2htpO//uiK1ELkGh3F/YKY2B
         8CohJc/KTbYSRWTIWASI8gT+k/TusYZX42uYYxyTpNnEg0mVRwVgfdEFWkOBT9TLkyFI
         wqj0ZDLYUx0v715KgX6xUMlWIauzpRaruVxUCU/htGyS/xOwUAsoqkUnwMi2prltDcy0
         kaZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i22si752281edv.214.2019.03.06.07.51.06
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:06 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 54ABF165C;
	Wed,  6 Mar 2019 07:51:05 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A34033F703;
	Wed,  6 Mar 2019 07:51:01 -0800 (PST)
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
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	linux-riscv@lists.infradead.org
Subject: [PATCH v4 05/19] riscv: mm: Add p?d_large() definitions
Date: Wed,  6 Mar 2019 15:50:17 +0000
Message-Id: <20190306155031.4291-6-steven.price@arm.com>
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
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For riscv a page is large when it has a read, write or execute bit
set on it.

CC: Palmer Dabbelt <palmer@sifive.com>
CC: Albert Ou <aou@eecs.berkeley.edu>
CC: linux-riscv@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/riscv/include/asm/pgtable-64.h | 7 +++++++
 arch/riscv/include/asm/pgtable.h    | 7 +++++++
 2 files changed, 14 insertions(+)

diff --git a/arch/riscv/include/asm/pgtable-64.h b/arch/riscv/include/asm/pgtable-64.h
index 7aa0ea9bd8bb..73747d9d7c66 100644
--- a/arch/riscv/include/asm/pgtable-64.h
+++ b/arch/riscv/include/asm/pgtable-64.h
@@ -51,6 +51,13 @@ static inline int pud_bad(pud_t pud)
 	return !pud_present(pud);
 }
 
+#define pud_large	pud_large
+static inline int pud_large(pud_t pud)
+{
+	return pud_present(pud)
+		&& (pud_val(pud) & (_PAGE_READ | _PAGE_WRITE | _PAGE_EXEC));
+}
+
 static inline void set_pud(pud_t *pudp, pud_t pud)
 {
 	*pudp = pud;
diff --git a/arch/riscv/include/asm/pgtable.h b/arch/riscv/include/asm/pgtable.h
index 16301966d65b..c66e2a69215f 100644
--- a/arch/riscv/include/asm/pgtable.h
+++ b/arch/riscv/include/asm/pgtable.h
@@ -111,6 +111,13 @@ static inline int pmd_bad(pmd_t pmd)
 	return !pmd_present(pmd);
 }
 
+#define pmd_large	pmd_large
+static inline int pmd_large(pmd_t pmd)
+{
+	return pmd_present(pmd)
+		&& (pmd_val(pmd) & (_PAGE_READ | _PAGE_WRITE | _PAGE_EXEC));
+}
+
 static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
 	*pmdp = pmd;
-- 
2.20.1

