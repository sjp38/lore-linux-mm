Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C241DC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93DB721985
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93DB721985
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 418258E0008; Mon, 22 Jul 2019 11:42:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CC558E0001; Mon, 22 Jul 2019 11:42:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B58F8E0008; Mon, 22 Jul 2019 11:42:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4E408E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k22so26567037ede.0
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gEVtoQCi6h+GyKxSDd1Xkj6e1d5Rk0HO8h+TUtam2wg=;
        b=mYe0RZGvYLJlLj9/mGM+xJ41qRXrhYhu+V94PBbKs+KjHj8CNX79DwtDGLPlD1CQYO
         Sv5nl3OAMKgxw6LbLmtV3QVZLgX/0oguujtqcALLF8yu/KRlEtASXz9W+TUmQ6S08UoK
         GlPBMyv/G/eFRUIr0RnGf/XRgE7Iyrhx0QxFW18nMHbpY9I13RBrbtPsaivmyR2pTBDl
         RNpFOPKAMfwO+4O52qeSLG9GalHzJUpavkhjNs+scd2yW9V6VHeH9aiGyeN0cEJhZAIe
         7KHTnwNswTepmXJ4KnpnYEtpMBRZHkcG6airdVYmJWukECZ/uMFyX7hyIfy71DNY3yLK
         Dy6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXZfXbWuc+3+wptLW97/+qfroQf3U4/7SKmms381Dm1VRivc+5G
	ZtQ08x88syAlMvHtHu811T8eLKXbojOtpnuWxpcsO8Pd4p0E8rd8+Dl1ivlxhF+MGJyibIc44l6
	xjdl2ICgHnRVToEHWy5ejNyibRxhCvuBeI5sS0vf64By2vTLbR/H3ifleTn93G+a33w==
X-Received: by 2002:aa7:c49a:: with SMTP id m26mr62758589edq.0.1563810163449;
        Mon, 22 Jul 2019 08:42:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrrSZKMqw4zjjsWlG2qzbY0tqWJvJvF9T3Kx9EngqYKqpUQ/yuHhPd1ttMuhiEgQWCI7sg
X-Received: by 2002:aa7:c49a:: with SMTP id m26mr62758539edq.0.1563810162676;
        Mon, 22 Jul 2019 08:42:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810162; cv=none;
        d=google.com; s=arc-20160816;
        b=VEo0841oDhXzNASnPtfHPNOuqHja0tGEEnihfOfgJxztL18J+MsX65rTXtz0+BuF2m
         Wr61LZCc8YltK+F8twjG4MbO9TsfjVUx4CiVG7wSQ6m2ABBNmZchAo2I6pH6jGdkdWC/
         NNcAOdVZLxtbsQHrIT5Ab88tKepS7VublEee2CIw6yd/Rm4GXHxHbGyYrTF4aOqtSx4f
         HMaAcTKfk6vFu5Itjom5coAPPmDu7cnWZFRexRDIxo/iEcuwBWGCMwXJhwknO222a1Et
         CfZb1TIJJ1wcMMAVc5x5EI0Sif+xjV/wfcS5++GSAeTtH1O5mIyRMweaEIXgqe2di2eT
         yBnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=gEVtoQCi6h+GyKxSDd1Xkj6e1d5Rk0HO8h+TUtam2wg=;
        b=VV1Tzwae63stROsEk+XYR+8UwCGApGPldznJQpA6VJu2QhOMlT/kxmvCs7ZyH6hHFF
         5CByRkmyFRUlNSSO3s0aLY8aVA9Kv8LCMpaH3MBk01XzuBQSExf4aVgMBAetL3nG7MFK
         q9++CNbLP675muQV9Ytfv/b0m1R34Yp5NngZiBZOKu9ZDp95LGC8fax5gzaKtfDUoAb8
         E/C9yORTCp2DDa3J5Z+OhGtNQUaKVQRguBPCeF3nXZOMK7RdPsU1nqhGRh0oCdam84Bp
         ernHb1smETLb0JRqDMJWjCOI8ZmgWET1ORFni0IDVvYURSe4hBehWAiLNCzkBtutDtWF
         2sVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id oe22si4839341ejb.79.2019.07.22.08.42.42
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E3ACF28;
	Mon, 22 Jul 2019 08:42:41 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 094753F694;
	Mon, 22 Jul 2019 08:42:38 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	linux-riscv@lists.infradead.org
Subject: [PATCH v9 06/21] riscv: mm: Add p?d_leaf() definitions
Date: Mon, 22 Jul 2019 16:41:55 +0100
Message-Id: <20190722154210.42799-7-steven.price@arm.com>
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
'leaf' entry in the page tables. This information is provided by the
p?d_leaf() functions/macros.

For riscv a page is a leaf page when it has a read, write or execute bit
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
index 74630989006d..e88a8e8acbdf 100644
--- a/arch/riscv/include/asm/pgtable-64.h
+++ b/arch/riscv/include/asm/pgtable-64.h
@@ -43,6 +43,13 @@ static inline int pud_bad(pud_t pud)
 	return !pud_present(pud);
 }
 
+#define pud_leaf	pud_leaf
+static inline int pud_leaf(pud_t pud)
+{
+	return pud_present(pud)
+		&& (pud_val(pud) & (_PAGE_READ | _PAGE_WRITE | _PAGE_EXEC));
+}
+
 static inline void set_pud(pud_t *pudp, pud_t pud)
 {
 	*pudp = pud;
diff --git a/arch/riscv/include/asm/pgtable.h b/arch/riscv/include/asm/pgtable.h
index a364aba23d55..f6523155111a 100644
--- a/arch/riscv/include/asm/pgtable.h
+++ b/arch/riscv/include/asm/pgtable.h
@@ -105,6 +105,13 @@ static inline int pmd_bad(pmd_t pmd)
 	return !pmd_present(pmd);
 }
 
+#define pmd_leaf	pmd_leaf
+static inline int pmd_leaf(pmd_t pmd)
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

