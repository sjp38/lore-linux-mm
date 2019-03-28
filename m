Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC809C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A30E4206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A30E4206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 544CD6B000D; Thu, 28 Mar 2019 11:22:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A4DA6B000E; Thu, 28 Mar 2019 11:22:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3468B6B0010; Thu, 28 Mar 2019 11:22:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D963B6B000D
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so8276657edo.5
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1lP5uxd4lkeHOs2R/letx90Hs4gQDKi/XVW6tvSp3kc=;
        b=LYNufbFL4vnFnnXUt0JziWoJHIJ/3WGF5jPJmFoHMnChyajqBwgcdKnGTzOB2CqmHZ
         1NqXSlc6GIH7n55NL2Ben/lofH66RCIlRNFtQMwM8FBshDVOXhHekm1s4tLMKRU/3lsL
         /7mbYYi9FAy621o2nO/oygDfeHauqJsMRaYM2aT3bc/kTRQMpxtxczfEfRGYG/Ft7HqO
         qkXHdlxNZ29/55KN046NcT2K0Zf7eqmTSSHNsH3f75LOHNb+IwpA6AJiyAgrewqlVWZD
         alEfXdCf2PSsWG3DqYoyV9JunVoIzwTGMkzyaYOmEPBvIqmgpIKLKiMh3Gxaw85GXkBs
         0TDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVa0HuVY4isASeCzSTxvQAamU21CoKNFSJhGHUMLa7sNw8JJUrS
	fg/gSce890Wk7ht0PSrNOyaiLcaQ02b8JYyIKstds9xLUh32hla6PCYOQ3cJnYaYEnEcxWlG+SC
	OxY8oRywyuk0oN+DcS9/+6fHP7QNjSkxPslPNWTopdPvQAsl1I0kQl4/b3FAD8d2+4Q==
X-Received: by 2002:a17:906:f2d6:: with SMTP id gz22mr4176873ejb.38.1553786539419;
        Thu, 28 Mar 2019 08:22:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp5gjWqeNUf3jGL2bZsYPyVWRoJzOo7KT4k6MniwAH5GPt2dafs/zyVRi+ug4TRbKFzO6a
X-Received: by 2002:a17:906:f2d6:: with SMTP id gz22mr4176836ejb.38.1553786538553;
        Thu, 28 Mar 2019 08:22:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786538; cv=none;
        d=google.com; s=arc-20160816;
        b=GveNUM/979MclMeOIv76pWmlEMsrFR3IhkxdnjgWH/d/E3AAAU6lbuIcVJfCtIyJ+z
         y9JYbGVpfGW4k4PbRzLDceswO3zoc4zxZ2at1Pbzb4fyLadeL95c7lj1JBoc9VYUlTGN
         ccP6/YI0UF4P4MICXA/Sr44g8zKsf/KR1/BAa1F5b8ti25kF6xBGdf2bizC/ba6NfXku
         0xpOhMyReUfwlMMxaqLqxY4+lhn11JlU30/UNEdHJr9kQjJ3uZ0/dPLd2aJYfNdMYZ/t
         SjFyDFUa0D8XJ5UW8kMTZfsKTIfe90gYChuBA9ddOcEdmDSNAfoS1uF9JRyWdbaLVjNc
         zd2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1lP5uxd4lkeHOs2R/letx90Hs4gQDKi/XVW6tvSp3kc=;
        b=QMrp2Tnmz1L9bWlJ+fuHBz/Ad8YvKDmMnQmiwUi6EoqWTDIpNuOSoFs676UFNedvIf
         76MZW4Pxt9Xt3OSs2LXxy3wr6doIufoFtw3HjjaVLdqARMa7AblNpoAiAUNYdePxy9X4
         lG3q+7Js0QtBithv0vrZW++1StPvAG6ldz1fdog9biLUIj/I9qxLGvoH7qMCuyyK5J5M
         Q6WWn2LU6ludsr+2RmigyizYY8FqlBNSC7XAsiJA/5puDHU+r5p5IaaGUt0cEcjYZdFj
         IEt1LjY1ff+9ZgY+6CZ7YhiTI92BV7yvzuV8N1uAyNuPkfGNHoflNulIRQEVkWTdMoo7
         Tzqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c40si5908876ede.242.2019.03.28.08.22.18
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A1494169E;
	Thu, 28 Mar 2019 08:22:17 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DFF3A3F557;
	Thu, 28 Mar 2019 08:22:13 -0700 (PDT)
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
Subject: [PATCH v7 06/20] riscv: mm: Add p?d_large() definitions
Date: Thu, 28 Mar 2019 15:20:50 +0000
Message-Id: <20190328152104.23106-7-steven.price@arm.com>
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

