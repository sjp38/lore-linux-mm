Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3B3EC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4378214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4378214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 441CC8E0015; Wed, 31 Jul 2019 11:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41A8B8E0003; Wed, 31 Jul 2019 11:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32D338E0015; Wed, 31 Jul 2019 11:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCE0A8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n3so42648625edr.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gEVtoQCi6h+GyKxSDd1Xkj6e1d5Rk0HO8h+TUtam2wg=;
        b=TRP0eYwFBOc5jHFpfZp9IhxlpUxM7ocNmgpnnUVyPlRGlr2gMsSJXhPboiJL3uZl+5
         MV1+drrgWAaxH8lK0bjVrqERdgQNWw/aWeXJYrOpBMIusqAHVwYWe3I7u7gGAT9UNG7a
         MnqdKoKjYNttnQozpwd2ZT/FOa1ElfXvnFxV2ZJvh0qVB/aIl37oFIlQ7OumhAINNwTT
         7R+QmZ5xcuv79ms52hPI1jwPD6fE8UAK1nup+10ozBn67OkbwjFk8A1SAiMY+cXxjrXJ
         jKPQynyg/PMJH0Yln7kzYn2+ZVvberlqaUHCpR5vIJt4He8NgDQXePabYOBE7IMeSKU2
         fQGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUNZXjOsl5FDCBSCKrIlVgRAm+87MDBr5h0UXJXtgTLEUBdUwkz
	3lUKCZDX1eOmWKWuDosJXg3z86eT9iqAJSZ+4BX8PrQV3togsyghAt4edZ/Ykhd/9cBOX0cwW84
	GDYTr9CWcAyzdf0BfXG8rQHVF1wf10nU/NPLFj3TJgJ4Txtpn2z/IkAMeFyhnStyz1w==
X-Received: by 2002:a17:906:6c97:: with SMTP id s23mr96202779ejr.136.1564587994462;
        Wed, 31 Jul 2019 08:46:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+0c4NfmIp3BLTt66fXe+FCNhLvk0fhtkyuaSnVX2FurKtGwSGuPnNChJ1k7zGzX9B2OBl
X-Received: by 2002:a17:906:6c97:: with SMTP id s23mr96202726ejr.136.1564587993730;
        Wed, 31 Jul 2019 08:46:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587993; cv=none;
        d=google.com; s=arc-20160816;
        b=fwhPMF5uzi/og2SISdqmb9MsdXNwKSvdj/T5u/XNNfqqsyba+yyfWuMr4ibamzylWa
         foZSRYw8p3xn1+RTPbUv3+9nxqNUXXIrOyoxinoKALoqJgj1IyYFwzexY9/aWk9RR/2B
         //Vq2vgxObK0LZiiHNXnSjW1h1jWhcmOC+IBf45rZTeypUv89JT1Wa1pkaJCylILHv1K
         V/jy91w+fO7IUTLA5wvWUKUXhoEB1k6OZFSOinUAMEFR4wZ74ANRhSVw3vlPy1zAzGk5
         ennF6YL0bpE5R90sV/1ADI3gK8bJvoEESNx4oqxsfXOVxMmDcq7nH1VlsRydPMGhMHBM
         4pqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=gEVtoQCi6h+GyKxSDd1Xkj6e1d5Rk0HO8h+TUtam2wg=;
        b=XAC+3MarjZHmT5wJRqUGDs13Oq3Vuuj1un1zAYOnm+f3/rEOBEycApnruPXNhQeSB8
         GY6r6hxMN/TfmdB0pYwwwYKG7nvFizw30Dw8XO866+d2TFDJ3gSPZ4s9TBolqGBoLaoP
         l5Cx1h/jwRGyEKXzOmTj0yVjCdxMLSZjw8/fys4kLimb93ggrWVlcDvUrfVa/CUfOzBE
         0yM/Yp7zP4rQEXOXX3p7pHLhPMEqyyQguf5jgRFDtW4R9vu2MGTBRaEBnIs1jZBqhsi8
         dy8qxKD/9b3lKNaPduvqqm/f9R7d46CLHl4jgnB64xqqLh8fkB7FH5NWmAA4fCYxB1Q1
         1BDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y13si19074706eje.259.2019.07.31.08.46.33
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DEEA41596;
	Wed, 31 Jul 2019 08:46:32 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 034703F694;
	Wed, 31 Jul 2019 08:46:29 -0700 (PDT)
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
Subject: [PATCH v10 07/22] riscv: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:48 +0100
Message-Id: <20190731154603.41797-8-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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

