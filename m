Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69E96C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33A3120863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33A3120863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B881C6B026E; Tue, 26 Mar 2019 12:26:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B619C6B0270; Tue, 26 Mar 2019 12:26:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4F646B0271; Tue, 26 Mar 2019 12:26:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54B4B6B026E
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:26:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s27so5474380eda.16
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:26:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1lP5uxd4lkeHOs2R/letx90Hs4gQDKi/XVW6tvSp3kc=;
        b=l6yZdL6mH3E0onokKBX0c637vKJW5june0IKM0UeX/p2g69Sl2OTVVFIVKu0BI1LpD
         llwn7OYP8kpDtub/hKAI9qe9vz6I2Vcs9gBngd3/Ehzd3CQR6bVkkWnO55CrfB8BdHBW
         gKlPFFrRCGHz2C6hSB9hzSIf/bpoYw26rE1TehTfMvoxQNElTtuLqnb/5ud+QQtJhKAw
         f7JohG+RLDB+dHTbY6zLme0Fm1M6qOOF1oYKgl2cDULlHG9Oj9ZB8AZbOIJN7YXXjyt4
         Fgb5oRuqtFPejUXOD6hefonVuK5b5V3Mdwynk/N6attLSGnzhmJw3/0L2A8ze1lSe/6O
         4zZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVH1lu6KaFQ3ulZ5ESnAzTEcjUdS8HkfNRKH680tXR1IfuXd3HY
	uk227deTzzngyNMZVQpucjWm96BRTjn4yxgs4voopMILZ8U6xtzFC4zXr0RQErKA5tcv6vB7EeE
	jFWo6n0bugi7ePdyj6GFsek0j6fjc9UfLr2czSAFmkTI3rC/NfMdbF3z8FfN6gTrn+Q==
X-Received: by 2002:a17:906:3d21:: with SMTP id l1mr17865294ejf.83.1553617616760;
        Tue, 26 Mar 2019 09:26:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUG6gsaoMGJYh7/wTsZ3wEwU4YdsxaP5FxAybJKupBAQuFVmqIdsVm/TiwfcmgRdMxlhbf
X-Received: by 2002:a17:906:3d21:: with SMTP id l1mr17865251ejf.83.1553617615970;
        Tue, 26 Mar 2019 09:26:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617615; cv=none;
        d=google.com; s=arc-20160816;
        b=0tLcJvl1AxPMGIpm4QKOI30jJ4X7aP/mebpgYYmAhIQXEs/Xuz+QMTPgpE5Ef5Gw01
         JKrKfJUUp71jtRMiWqHNQA9iAHr6iWnfVxcO7Xj4hhQZNJKsogemRSU/LVWqx+sNHUBc
         mafXSKwAX6M0QMT1KP63O/C4Iqvrmk73/iBujwH3Lw8Q/2LfbB3tU7L2XK9dhoiwqgKW
         7fPcL4GKs2FC5yr6U1gWpnA9QeOrKIgm+FRdEjLquEc6Hqi4Sf8Jwid1uhe3YLndysnh
         xayRzdSKrtaqy7aMUl37eVqsCK3fHpVzaZHPcyKnL52P8ZfkQaba2vQx82tuH1T34Ocd
         +04g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1lP5uxd4lkeHOs2R/letx90Hs4gQDKi/XVW6tvSp3kc=;
        b=aM1Dh+JwoEDPR2HlqD6Bob8qoZSRHDlwvsSXckGm2Lz1uyzf94xe6soMLbgktkOI7y
         /yIItTPCxKRLyWmT/WQzC4q0UtT9omByW3SAS064fRYIFv5WDZIAjRCCGnFYzciQtqYn
         QpESSnQ/yFk++4aw9En3j3u572oCNuGg34aUV06Vp6E1GXweqFL8OWfYO5H8LComgaSQ
         3SB5cRphr2BlAUf7ZndsKut0R57T/BCNRy/BzoKdY8EC0R5IGK3Ps0mWHUu7MYgfadVT
         D60s3ENfoBweHnBu6OFUd4AdPTUFitztLDYVrOln5jcxchee6dbFzZcEwPHOT+hVkIMU
         WGLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b23si1207419ede.163.2019.03.26.09.26.55
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:26:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F32D7169E;
	Tue, 26 Mar 2019 09:26:54 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4CA2B3F614;
	Tue, 26 Mar 2019 09:26:51 -0700 (PDT)
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
Subject: [PATCH v6 05/19] riscv: mm: Add p?d_large() definitions
Date: Tue, 26 Mar 2019 16:26:10 +0000
Message-Id: <20190326162624.20736-6-steven.price@arm.com>
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

