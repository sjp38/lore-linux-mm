Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FA74C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56E4720830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56E4720830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 091886B0266; Wed,  3 Apr 2019 10:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01B7A6B026B; Wed,  3 Apr 2019 10:17:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFE5D6B026C; Wed,  3 Apr 2019 10:17:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94FB36B0266
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 41so7661513edq.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1lP5uxd4lkeHOs2R/letx90Hs4gQDKi/XVW6tvSp3kc=;
        b=FvcyzKLEZQJBI986iOwqesMegd1cgDsqEbtzL2ojxh+vHgALz5fy34dYwYX3YxfmiB
         X4b91m2m46WhzniWktsKc3ao8Xpjjgr8SuQc0H9xRUXJ2/0EecaOaQPL5xUIkqM8DXok
         8wN9PkIT4kaKOr1dUhsv/jn7D9/PgazV0Ozg/pd8SqWVY9NBndZBo3YJUde8/bVadoQl
         aB/DUa/5NOmCDnq/ok/3mfOpWziBXF2X8KyBi4Kq/if0LMfW73LguOXiLvWlBHjjpYi0
         Q/pQw4N+PR9wtxTFoJKXEv8K4aLaopNBFET3ow34n7vns6i4r1dYw/koXq7iVgprtHX2
         dNnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVgUgKSefulDnMElWMRdWiIaxGdXwBlLA8g7nsMj8vmFaYlLjSY
	UZD8ikp4Ktcu07h9s5Fd+ffNmJOAXnutESh1zX/Xb2wAKQI/DKISRK1arukd13gGnm2X82QBe00
	cs1bw/AkUh9SN5w90/vv8TiHlGYrsAj+8sFJD0AFZXSom/wKPnIiqeC9RSaZ62d+N9g==
X-Received: by 2002:a50:a6db:: with SMTP id f27mr50837308edc.117.1554301058106;
        Wed, 03 Apr 2019 07:17:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXvKDU8mHg61+kfBbcR1e+isvHzv6G0hbLCNeOJ8QT6GCWunvpjFTNBXpmEtRlaWc9HsBH
X-Received: by 2002:a50:a6db:: with SMTP id f27mr50837263edc.117.1554301057250;
        Wed, 03 Apr 2019 07:17:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301057; cv=none;
        d=google.com; s=arc-20160816;
        b=oAybVYDrrpv+gzcWMkEsgAHjPoYcNCTsy2QAZPmXBEYKVjOsPvsfpH5xwRQwMxxQ/8
         YHMYEzcEENd9rAs0Poe861qUSVfEJVOylOihr+iRL6nhE0TPEXrtFj+lq0AWJ2j4uVzr
         E5KeW6+W8v9E4xvLUz2wrHlfAflc0rP+b6cycDl6yxEGMBOJcsnBcSqk+EEkXg2OedIJ
         nqOYfJtZjT/uXDOa62ozIFXqLy/Knxi2l6QHhk8htfFcUvdA3iUOjG8KPPSrZvvREFbU
         t5GeZzhxvE+tIa7asijcctau0M0SwgdHNH2yDgyZQl8wNRuktUqK1NmENnFb/MLyogbW
         2D2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1lP5uxd4lkeHOs2R/letx90Hs4gQDKi/XVW6tvSp3kc=;
        b=VYPgWACA+KWFqBSd86UF0hIwwdScicBp09lanxoDy3lzN1l1fwHotbPZIuPOwau+Ie
         3TruNYrQBlWQsN2N4P/wQMI7BsvisEjWzfe84S5+n1mqIrZA1xB8kquh2WGcR2hnYV05
         xnlinT/I4QDb92Zq+Y4+2DFsrK4yeznHqZFrndeFA9L23Cs3MW1C8tGwfHxKOwEsCNSW
         eUAUUmxR2po2mOzT63xIBTMfvghSTlM7+R3lEZZ9+Z7vf2Rx+xVnKg8XDzsUuRczkRQc
         o9Hu6eXDptL4dcsUDhkvRMq7bntPz/wo7C6jXLShCuWp0p/9/c9mTxwvEyBD1gbtXSPq
         /S9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m29si3453588edm.213.2019.04.03.07.17.36
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 358D41596;
	Wed,  3 Apr 2019 07:17:36 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5A3383F68F;
	Wed,  3 Apr 2019 07:17:32 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	linux-riscv@lists.infradead.org
Subject: [PATCH v8 06/20] riscv: mm: Add p?d_large() definitions
Date: Wed,  3 Apr 2019 15:16:13 +0100
Message-Id: <20190403141627.11664-7-steven.price@arm.com>
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

