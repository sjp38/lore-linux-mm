Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14D9DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1EDD20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1EDD20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E92C8E000D; Wed, 27 Feb 2019 12:07:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A5E38E0001; Wed, 27 Feb 2019 12:07:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 563088E000D; Wed, 27 Feb 2019 12:07:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA6598E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:04 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k32so7092093edc.23
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o8V0Tzxsi6NTsG8lOFeqs8u+PtO84JGBEV7Wz4LTce4=;
        b=LxGzt2zZ/NGfQ0CGvIIh7dPz2diSo8zlMCxLHz537PEfdh2kfl3hCrrRGk2un2WNvB
         epq6dtW+w0WQrlHTCafrQbALSQ3p7rtitVPvoQzANEccr9XqeggENFNP4c2+QWArS69t
         ECsYPbcwRUxTQmalBarhM67xzj0oNf/VG3El7evS/zlRbnZLD1zP7YrGWXTdL8qvmVu+
         DQ8E+aIyCytLeTzbaRK/vEbP+ZqEYpocXgUiJhopU1ZON5oX3Kaes3LMGWlVklpXjbbI
         QQ2rGNPYgm9Fh6nstJd4Jn7FnDC3/G064C39t1oYp6PUS8ic+KMr3WGds4ZQBWw+3wZX
         XYZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYkdISXCuFZT0eg/lC3p9ock6b1NGXmWthEYVFaktAp1U+TVBLW
	cmoeqlaqY+RcLGLxKojK1xOsSNrm3elq5pc+cEkhq+WXOfNBmFliVICwxv6DJ6/WRg4l3z+IOvd
	1L6cuCS7xpdATWPuDqFRH7RzQ58sZcsVjavJvSb5T9JnMzyxEr1rO5TYplcSnKuRO+w==
X-Received: by 2002:a50:a4b1:: with SMTP id w46mr3063234edb.215.1551287224442;
        Wed, 27 Feb 2019 09:07:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IblG78CeEKuIk9bs/gZX9MIwi9w7z9cGy0jDbJDbyQvFJW5FCVPCzK/xf24pe/aodQIYn1M
X-Received: by 2002:a50:a4b1:: with SMTP id w46mr3063173edb.215.1551287223340;
        Wed, 27 Feb 2019 09:07:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287223; cv=none;
        d=google.com; s=arc-20160816;
        b=Dd7r54n4k2h8U2yaKrvroPcViTnPdyb3egnyAHc4mJDNHtiJuWnhVAcsrMZ2DKzSHD
         c9Eo1X45ZfHnpbjhB2ZwUCePP8os+mpxsG7h7ljhXgRBhL/c/6F2Oov+psbkWPWLZccK
         uXJEbkC1OpJlFyN+naJW44ZFgkhWlMSU3b4lsVk/RB1gDtSVetKaidN5hEZrXlukn9XK
         3a9SJZHJWSXnoH84XF2eaCM1U50cgv485QODGKv0eo4gZr3S5XhohHpTOPg0vbYL0ard
         vnpJTrRgNOsyYPmXxMtttBDNIGETFArYynfuo5PLXkgWc8GU9ki9ma01IsnFObOeLumQ
         kDuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=o8V0Tzxsi6NTsG8lOFeqs8u+PtO84JGBEV7Wz4LTce4=;
        b=VcJIGdn5j6P1rUefbJWrDsbJAmHP0SUUKErBSEKcvIjyeyAImlbObrJuNm+HELGzT7
         Ol8QB8mQxuo7peIWL8/amWRu2YIT+X1KkmKoFmBdX9bNhYD6/+XCNmVLy3HqG+WJvWev
         TFRN1HCRna7DZd2aIcyLVZRKj9s+3Gs4OOznAzkg7fKIFugkNRy1E/BZDmHnyt9QBF1N
         qzsJ/Ru76iwy0ygzjgWmJWEHrBpk/qzPU7/ErusNxyRrDhDGYtfyp9yBiddEaBpVFAxf
         BcVtUsTCNWLrVW2oNzmFAJDsUua7Xx2lXj9R7CNs4MzjBDB/PHNex/kvT+5urIO9wzqP
         2kpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z34si6723938ede.93.2019.02.27.09.07.02
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:03 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 39D221684;
	Wed, 27 Feb 2019 09:07:02 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ABECA3F738;
	Wed, 27 Feb 2019 09:06:58 -0800 (PST)
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
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-m68k@lists.linux-m68k.org
Subject: [PATCH v3 09/34] m68k: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:43 +0000
Message-Id: <20190227170608.27963-10-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
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

For m68k, we don't support large pages, so add stubs returning 0

CC: Geert Uytterhoeven <geert@linux-m68k.org>
CC: linux-m68k@lists.linux-m68k.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/m68k/include/asm/mcf_pgtable.h      | 2 ++
 arch/m68k/include/asm/motorola_pgtable.h | 2 ++
 arch/m68k/include/asm/pgtable_no.h       | 1 +
 arch/m68k/include/asm/sun3_pgtable.h     | 2 ++
 4 files changed, 7 insertions(+)

diff --git a/arch/m68k/include/asm/mcf_pgtable.h b/arch/m68k/include/asm/mcf_pgtable.h
index 5d5502cb2b2d..63827d28a017 100644
--- a/arch/m68k/include/asm/mcf_pgtable.h
+++ b/arch/m68k/include/asm/mcf_pgtable.h
@@ -196,11 +196,13 @@ static inline int pmd_none2(pmd_t *pmd) { return !pmd_val(*pmd); }
 static inline int pmd_bad2(pmd_t *pmd) { return 0; }
 #define pmd_bad(pmd) pmd_bad2(&(pmd))
 #define pmd_present(pmd) (!pmd_none2(&(pmd)))
+#define pmd_large(pmd) (0)
 static inline void pmd_clear(pmd_t *pmdp) { pmd_val(*pmdp) = 0; }
 
 static inline int pgd_none(pgd_t pgd) { return 0; }
 static inline int pgd_bad(pgd_t pgd) { return 0; }
 static inline int pgd_present(pgd_t pgd) { return 1; }
+static inline int pgd_large(pgd_t pgd) { return 0; }
 static inline void pgd_clear(pgd_t *pgdp) {}
 
 #define pte_ERROR(e) \
diff --git a/arch/m68k/include/asm/motorola_pgtable.h b/arch/m68k/include/asm/motorola_pgtable.h
index 7f66a7bad7a5..a649eb8a91de 100644
--- a/arch/m68k/include/asm/motorola_pgtable.h
+++ b/arch/m68k/include/asm/motorola_pgtable.h
@@ -138,6 +138,7 @@ static inline void pgd_set(pgd_t *pgdp, pmd_t *pmdp)
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define pmd_bad(pmd)		((pmd_val(pmd) & _DESCTYPE_MASK) != _PAGE_TABLE)
 #define pmd_present(pmd)	(pmd_val(pmd) & _PAGE_TABLE)
+#define pmd_large(pmd)		(0)
 #define pmd_clear(pmdp) ({			\
 	unsigned long *__ptr = pmdp->pmd;	\
 	short __i = 16;				\
@@ -150,6 +151,7 @@ static inline void pgd_set(pgd_t *pgdp, pmd_t *pmdp)
 #define pgd_none(pgd)		(!pgd_val(pgd))
 #define pgd_bad(pgd)		((pgd_val(pgd) & _DESCTYPE_MASK) != _PAGE_TABLE)
 #define pgd_present(pgd)	(pgd_val(pgd) & _PAGE_TABLE)
+#define pgd_large(pgd)		(0)
 #define pgd_clear(pgdp)		({ pgd_val(*pgdp) = 0; })
 #define pgd_page(pgd)		(mem_map + ((unsigned long)(__va(pgd_val(pgd)) - PAGE_OFFSET) >> PAGE_SHIFT))
 
diff --git a/arch/m68k/include/asm/pgtable_no.h b/arch/m68k/include/asm/pgtable_no.h
index fc3a96c77bd8..eeef17b2eae8 100644
--- a/arch/m68k/include/asm/pgtable_no.h
+++ b/arch/m68k/include/asm/pgtable_no.h
@@ -17,6 +17,7 @@
  * Trivial page table functions.
  */
 #define pgd_present(pgd)	(1)
+#define pgd_large(pgd)		(0)
 #define pgd_none(pgd)		(0)
 #define pgd_bad(pgd)		(0)
 #define pgd_clear(pgdp)
diff --git a/arch/m68k/include/asm/sun3_pgtable.h b/arch/m68k/include/asm/sun3_pgtable.h
index c987d50866b4..eea72e3515db 100644
--- a/arch/m68k/include/asm/sun3_pgtable.h
+++ b/arch/m68k/include/asm/sun3_pgtable.h
@@ -143,6 +143,7 @@ static inline int pmd_bad2 (pmd_t *pmd) { return 0; }
 static inline int pmd_present2 (pmd_t *pmd) { return pmd_val (*pmd) & SUN3_PMD_VALID; }
 /* #define pmd_present(pmd) pmd_present2(&(pmd)) */
 #define pmd_present(pmd) (!pmd_none2(&(pmd)))
+#define pmd_large(pmd) (0)
 static inline void pmd_clear (pmd_t *pmdp) { pmd_val (*pmdp) = 0; }
 
 static inline int pgd_none (pgd_t pgd) { return 0; }
@@ -150,6 +151,7 @@ static inline int pgd_bad (pgd_t pgd) { return 0; }
 static inline int pgd_present (pgd_t pgd) { return 1; }
 static inline void pgd_clear (pgd_t *pgdp) {}
 
+static inline int pgd_large(pgd_t pgd) { return 0; }
 
 #define pte_ERROR(e) \
 	pr_err("%s:%d: bad pte %08lx.\n", __FILE__, __LINE__, pte_val(e))
-- 
2.20.1

