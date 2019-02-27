Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2880C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7859420842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7859420842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A9228E0009; Wed, 27 Feb 2019 12:06:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 030118E0001; Wed, 27 Feb 2019 12:06:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E615C8E0009; Wed, 27 Feb 2019 12:06:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE828E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:06:49 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id k32so7091827edc.23
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:06:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F2Zj9D+6mzZU1aa6902mR5rKdYqk0kidu/xuD/i/Puw=;
        b=lRA9Vj2lxNUJCiL38FBpJgx8n7DXPtktG38/pSTzNYd9vGpI/R2zEw2alys4saE3Bm
         7IrqECi14F9/bWhkr0LdwqwcytpOmFtacaP86uupMlY0Nmqiau3DCC0FXNJqayY29YzB
         VADD0vOqvyonR6fAR/2A1F0TDnzYwZfq629VDen0lvgFdtr26YAbHad0BgJbJ9vYw1/0
         zaROV36m6lEK0pwT4iW2pKprgwYs6+t/BgwH9TYsgS3jtcOd6nlxv+bYlNJsO4U7nDNY
         T8x/L8LUmfX0prqUF7LGxQyXffsRw32hP63tEfYl+VgMTjUnVWKKKQqkmT0OYTUtX6Mj
         UkXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZyRJwAko4Ha0c0ooKZ+BP3YF1hjE1PlsxELnDDmDF6MOeERzow
	iwdalhcMuGJWCPGi2b5kUVnJa+xPOkhyl0nVkpEMs+/5DchLkk+DN0J8PyW76+86omjlur7lebG
	SGPcmnLDjliCY8fKK26fHHkN3pMzJ3peEzpX3auM4297Nim3epIZBtU8ejZqnXd9ayA==
X-Received: by 2002:a17:906:4ccc:: with SMTP id q12mr2284404ejt.201.1551287209063;
        Wed, 27 Feb 2019 09:06:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYgw2khElJAi6wZOvR0h1r9WmZo1NLBUMjvMPOROXboT2ZafhGHdZJYjB+KT3r3jWrJQD/O
X-Received: by 2002:a17:906:4ccc:: with SMTP id q12mr2284346ejt.201.1551287208113;
        Wed, 27 Feb 2019 09:06:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287208; cv=none;
        d=google.com; s=arc-20160816;
        b=rpfLfSzopST8YP4gHNd3bjhxPLXdz/h/eONJajeE4rpragp6UVe/RC1eSbrNixeH3J
         HEJIuwCoIePZZRjUK/PuKbmUFteEaShrYX86OFtqwuuguZgApMOAUe3gJWrz2XDux8l0
         qfjslI+CrcspqPV7JpDfNehxiLB6YVgwnLbKv1k8t15YnybFKxk44vU8KhBIDVWo/YhT
         fhFvKOYFJHRHmTUIzITYUlXU8Y6HwbbIwPh0589XWfoQzek93lKQxGi6Hr0Cj55GRePT
         Qqgl2ho6OtyxV1h6Tzyt35Kbu35Zwtuqbtdmwk79w4/M2FD9423J1CZNEXOZiRxoJnsW
         NvTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=F2Zj9D+6mzZU1aa6902mR5rKdYqk0kidu/xuD/i/Puw=;
        b=CbgCULLHXJa1G6mQbR3Mn0fdcIGSWdONNez1Rte/7cIKBIXToM89t66DolDDtOINDa
         gvs41SFyW7euZtMm1Y1u/uNUxqsCR9oX50JR7etZT3Zb7ZDTshoSlC6+d3uLujpzETF5
         x5b6D3NcCT5KYbe6F1itb1gQTW2td6KjeRcEbiixv1JcCD3JBgGsEyqsIMi18ZxmQDy3
         roiJSrMu9MqjNMMkdsYivbLm/7EiDzq0z/TLL7EQGnLDkyejKtnugCTtKwHFsJJjYvo7
         RHOoYbtnCTYsxilcpAc99cnQSZZ+3z7NI3CHgrWh0WodLf/r0RInWwEPGBlDK6xTpmMi
         yUzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m5si1981548eje.78.2019.02.27.09.06.47
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:48 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 11CBA1684;
	Wed, 27 Feb 2019 09:06:47 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5EEB53F738;
	Wed, 27 Feb 2019 09:06:43 -0800 (PST)
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
	Mark Salter <msalter@redhat.com>,
	Aurelien Jacquiot <jacquiot.aurelien@gmail.com>,
	linux-c6x-dev@linux-c6x.org
Subject: [PATCH v3 05/34] c6x: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:39 +0000
Message-Id: <20190227170608.27963-6-steven.price@arm.com>
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

For c6x there's no MMU so there's never a large page, so just add stubs.

CC: Mark Salter <msalter@redhat.com>
CC: Aurelien Jacquiot <jacquiot.aurelien@gmail.com>
CC: linux-c6x-dev@linux-c6x.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/c6x/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/c6x/include/asm/pgtable.h b/arch/c6x/include/asm/pgtable.h
index ec4db6df5e0d..d532b7df9001 100644
--- a/arch/c6x/include/asm/pgtable.h
+++ b/arch/c6x/include/asm/pgtable.h
@@ -26,6 +26,7 @@
 #define pgd_present(pgd)	(1)
 #define pgd_none(pgd)		(0)
 #define pgd_bad(pgd)		(0)
+#define pgd_large(pgd)		(0)
 #define pgd_clear(pgdp)
 #define kern_addr_valid(addr) (1)
 
@@ -34,6 +35,7 @@
 #define pmd_present(x)		(pmd_val(x))
 #define pmd_clear(xp)		do { set_pmd(xp, __pmd(0)); } while (0)
 #define pmd_bad(x)		(pmd_val(x) & ~PAGE_MASK)
+#define pmd_large(pgd)		(0)
 
 #define PAGE_NONE		__pgprot(0)    /* these mean nothing to NO_MM */
 #define PAGE_SHARED		__pgprot(0)    /* these mean nothing to NO_MM */
-- 
2.20.1

