Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3323C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACFE62192B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACFE62192B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A3456B0010; Thu, 21 Mar 2019 10:20:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 253DD6B0266; Thu, 21 Mar 2019 10:20:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 141EA6B0269; Thu, 21 Mar 2019 10:20:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE1626B0010
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s27so2274550eda.16
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1lP5uxd4lkeHOs2R/letx90Hs4gQDKi/XVW6tvSp3kc=;
        b=BKt7wiSEw+NgGnYz8JOIufRMgko3c22NZOTJty1cVuusxrtTlvYKpjqjRkQ6Ol2PIA
         d3rMD0IiJTODVRkd/r8Qg8p6PWKxLmsXiSVlwejxHXLZCa/Ue31X25/rk33rY+GjxnXX
         Ytatc3bNPg6WMqYqLRX8rDnM7p/kyymoHpLX+hDI465TIH3dqZHRGHLqA3Fe51q05NL5
         uU+b2ujv/xCGZPKRCHVDGnVCaccs3E9XWi94CbkFzZfMw4FxLk7g3YPqriIdjW/YUo6a
         K40B6r0Upqq2gXeEzdPJAN+hBbXS9WuwGrIoGEXQ/LxBNTMGlpFxls2KJqZVlNg+Kaii
         LbgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVCtVL+gf65WRDlMqgoFbjf+HMhTasFKM0IL5nGJf1F5w8TOS/U
	ls1qIPOs5hp3CmeYFqIgXiiyG0w7TwE6cce1J+rRA3Yr+qVkVWDcMZOAbF0EpsoMg78Cygw03Pi
	mR+LM7cdMExIqCH8OpOozQV2wnfG5SpmqOzi7c/VnX+1pGqbFnDYtP0o4RhBazgXkZg==
X-Received: by 2002:a17:906:2983:: with SMTP id x3mr1673449eje.130.1553178027304;
        Thu, 21 Mar 2019 07:20:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9K+XE6GDrTOhKYie9Ky4hlliU49d8q1Stw6vFZzQwyOe9GMUBe9K8nM7d6eAJHS/f4+hH
X-Received: by 2002:a17:906:2983:: with SMTP id x3mr1673411eje.130.1553178026520;
        Thu, 21 Mar 2019 07:20:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178026; cv=none;
        d=google.com; s=arc-20160816;
        b=GNO3gudEZY6DNAHZUhZp7B9fzdkVNIuybIaDdZRVmSjVhiWJnvQYe3hZGTJfS+6EcY
         54rbB9en2FhXdpQBcRLMNhdDtRaU2VDs+h62/+mX17FkyDH2yYjN8KVyVho/Yta8bhdC
         N7c29Oxb8YRRdTAg4tdCm/cA9BgDFtbhYtR9dWs5HUGQLRb97Mcv0KEqarhVSF3xWh+2
         ViS69k1vgu69O2aBRae8XhLc5sHJfLFdJSW3KYTMUh8DEmG4RkEPrfVpbnI4bfPzohkV
         hSpDyCiiyD1FbQHDDWasK1tTGgLuygG4zi678zBZNuSDt8XC/UyazAkrRBQV5qTNkd3Y
         tE5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1lP5uxd4lkeHOs2R/letx90Hs4gQDKi/XVW6tvSp3kc=;
        b=aEcz2Lrlqu2TdPJElvPFY5voiJJ4NtrZ83zEdHNXKX6dm8DIRKKhAd6ELzx9b16dm7
         HPy4NdADZW937ArWpq+327kY2WbQ2519pvM5xkBL9t/pr781//jjUNY9CbO/0bXfao8x
         EFIN1ADHKuudYKx6lqvdLPjhVS6k0n3V9diBwxI1BL7clgDI6jJsUqdIDr1buqlsk3OJ
         JyGK1eHGDwiB8LDBBTRivlWNuFcvaQOi+UUsjMw41BgwtbFenGF74hNWIAl4dogSwMQj
         gFttu83JmuRjw6kr4iAHweZXkm7R1cW86zj57PYXHdeORtfKg7+2JIngZlRglnxZdMDR
         fWIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e3si2150143edd.270.2019.03.21.07.20.26
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 853FD168F;
	Thu, 21 Mar 2019 07:20:25 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D266F3F575;
	Thu, 21 Mar 2019 07:20:21 -0700 (PDT)
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
Subject: [PATCH v5 05/19] riscv: mm: Add p?d_large() definitions
Date: Thu, 21 Mar 2019 14:19:39 +0000
Message-Id: <20190321141953.31960-6-steven.price@arm.com>
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
index 1141364d990e..9570883c79e7 100644
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

