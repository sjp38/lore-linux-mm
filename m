Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4280C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 09:45:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AFDE20679
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 09:45:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JqeYVSNx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AFDE20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DFD26B0008; Sun, 23 Jun 2019 05:45:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 390BC8E0002; Sun, 23 Jun 2019 05:45:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27FAD8E0001; Sun, 23 Jun 2019 05:45:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E59C56B0008
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 05:45:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a13so7114312pgw.19
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 02:45:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BUni308L4TNZcRdWweuUiutx4ej146UezPXSv2fRAeU=;
        b=dnGEh2Fq0CiYg/mxwRW1SZEoOUXxAPHNeJI/pwm7OORU/nV5MOb+Uucf4AI67zd8iM
         i2BSz0T/pnu5/LwHfoGyoxmACvOJgjQ6O1odyMF66rPq3Y/H5yV3g21p4bzFr/o1zsbF
         y1yH4nqzduEBZCPg4PULRILGgAtfncqpN61AUn6IUmHHVpWsrjnjD7JzmUfh1GUNbPFs
         HMV/o3mz/CirFC532dQu0uqsY7Hwa70Vy4weksHDD8KRwaoKnWBcfyZiTHh5mxy5k6Xm
         x7VqmLSmlSDB5I55FapKtPKfjt8OcT9vT48B7Op04ccfJWFM/VuVfVBjcliLgy2ElneN
         9YmA==
X-Gm-Message-State: APjAAAVs4I92t/zgAcsY/SPhkWHBBsg5HpMMnheDQpTS5F8QaeB36sdw
	Wv+igBq924ql2+xexPaStu62Ik22ROiULDb9HO86pGe9jTfL3bHbkwrEtKFHvo/GIySX4pVH28j
	hO8MIEHNvTvp9okZRYcXbSK92T/vHtWR+NQkk07/0R2BdxVIpTGZ/2w39Ogt0GbXZOA==
X-Received: by 2002:a63:289:: with SMTP id 131mr21270725pgc.211.1561283148446;
        Sun, 23 Jun 2019 02:45:48 -0700 (PDT)
X-Received: by 2002:a63:289:: with SMTP id 131mr21270664pgc.211.1561283147520;
        Sun, 23 Jun 2019 02:45:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561283147; cv=none;
        d=google.com; s=arc-20160816;
        b=Gxa0WETME/UaRPP1SDhR/B1szPhPqXyq2H0KerATPXhxQjiPwypSXc8IyYLyW4EbK7
         Ke2OFuRXfebB8DjtcAd9TjvOVbrRmAGgUAE3bpdWrdnWn9Cpt2izM9YSHJLVaoY3JZwv
         sPQhryXlD4i+uIncHuolpRyQZlRulKRYZGADNe2+3VAQU4kKzcUHjHv5TE/vMBv7sXUy
         0JNIl0MQPiZYegzIrkcjIVwpFH/+Yc66hmQwZPZf1C268WQcoe38USUdhRnt0kRjAJPR
         JbfThCAydCQXrDiSBNuBJoJ7bU5HIkKIUTRwgbiSYMAWgzENFVN87/5iVB8Cw3PSDxrh
         fIYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BUni308L4TNZcRdWweuUiutx4ej146UezPXSv2fRAeU=;
        b=zWqALFj+1cy98W8yPZ1HtUO37XHP2q+RxNS1lXJPANDidI9hCoGY0Vy8XGlG4ERQnt
         MHOntsIBc5Pr464/d2m+5pB2ITNz6qDPuEqV/L3IEb7XJ51bbRXFVYADP2ntkNvVV56Z
         VWl2XAlHmQPbta0oKJxl/+kBVWe8Y6u9wcoK7f5QRcP947qIsvBBYPy4+zkjozlAVRGR
         zBHU7E9MqEz9WnX0HhCrn/eGzBgG8ypXXWNHf4vnP/+cOlLpTauW0t/It/sVQjXpD7X4
         ZJ86vewsBERshbQwv7ZldwvDPdpkgDtAhhJHEegYiOs8RisJE2FT3nBlb0COkENQSwPY
         G++A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JqeYVSNx;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o5sor10736630pjp.20.2019.06.23.02.45.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 02:45:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JqeYVSNx;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=BUni308L4TNZcRdWweuUiutx4ej146UezPXSv2fRAeU=;
        b=JqeYVSNxIoqFzu0xK2z/Z3ztnBfVaDvdJ4jBDcTZwl1ZZSzJpb4XVAqFLNcvsicZQx
         8azD+7/r8TB6Xe4GCrMf2HyZfHSfUYK9qHQtKFQhT72bYJ5DCjJKYW0muFytZdbqa87K
         C4bitxQYLZlwTNsjcupbcQlpamUux3vetpFGshSj8TWe5rPmtnBH77PG9DeEGbtuVAlg
         hcFCbqVaJ5nfQFVZKN55i3/+v0EylIZXr82F3dOYsbZrBaddGQETYoJ3hPGwQwMDgiaF
         hhN2431E96e1zXHj299iMvvgry3NSb6UH8u1MpCg5ujVQm+BqSQj0GWssD6TTCp7Ci3I
         5cVQ==
X-Google-Smtp-Source: APXvYqzXhmFEsFsp6pqN+TP8Jn+x9XMVyMY/SjTnneXCEg7e318qlarpEXN25vv1DI0lY9gT+msajA==
X-Received: by 2002:a17:90a:be0a:: with SMTP id a10mr16827730pjs.112.1561283147081;
        Sun, 23 Jun 2019 02:45:47 -0700 (PDT)
Received: from bobo.ozlabs.ibm.com ([1.129.156.141])
        by smtp.gmail.com with ESMTPSA id d26sm6181062pfn.29.2019.06.23.02.45.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 02:45:46 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH 3/3] mm/vmalloc: fix vmalloc_to_page for huge vmap mappings
Date: Sun, 23 Jun 2019 19:44:46 +1000
Message-Id: <20190623094446.28722-4-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190623094446.28722-1-npiggin@gmail.com>
References: <20190623094446.28722-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

vmalloc_to_page returns NULL for addresses mapped by larger pages[*].
Whether or not a vmap is huge depends on the architecture details,
alignments, boot options, etc., which the caller can not be expected
to know. Therefore HUGE_VMAP is a regression for vmalloc_to_page.

This change teaches vmalloc_to_page about larger pages, and returns
the struct page that corresponds to the offset within the large page.
This makes the API agnostic to mapping implementation details.

[*] As explained by commit 029c54b095995 ("mm/vmalloc.c: huge-vmap:
    fail gracefully on unexpected huge vmap mappings")

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 include/asm-generic/4level-fixup.h |  1 +
 include/asm-generic/5level-fixup.h |  1 +
 mm/vmalloc.c                       | 37 +++++++++++++++++++-----------
 3 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index e3667c9a33a5..3cc65a4dd093 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -20,6 +20,7 @@
 #define pud_none(pud)			0
 #define pud_bad(pud)			0
 #define pud_present(pud)		1
+#define pud_large(pud)			0
 #define pud_ERROR(pud)			do { } while (0)
 #define pud_clear(pud)			pgd_clear(pud)
 #define pud_val(pud)			pgd_val(pud)
diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
index bb6cb347018c..c4377db09a4f 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -22,6 +22,7 @@
 #define p4d_none(p4d)			0
 #define p4d_bad(p4d)			0
 #define p4d_present(p4d)		1
+#define p4d_large(p4d)			0
 #define p4d_ERROR(p4d)			do { } while (0)
 #define p4d_clear(p4d)			pgd_clear(p4d)
 #define p4d_val(p4d)			pgd_val(p4d)
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4c9e150e5ad3..4be98f700862 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -36,6 +36,7 @@
 #include <linux/rbtree_augmented.h>
 
 #include <linux/uaccess.h>
+#include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
@@ -284,26 +285,36 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 
 	if (pgd_none(*pgd))
 		return NULL;
+
 	p4d = p4d_offset(pgd, addr);
 	if (p4d_none(*p4d))
 		return NULL;
-	pud = pud_offset(p4d, addr);
+	if (WARN_ON_ONCE(p4d_bad(*p4d)))
+		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (p4d_large(*p4d))
+		return p4d_page(*p4d) + ((addr & ~P4D_MASK) >> PAGE_SHIFT);
+#endif
 
-	/*
-	 * Don't dereference bad PUD or PMD (below) entries. This will also
-	 * identify huge mappings, which we may encounter on architectures
-	 * that define CONFIG_HAVE_ARCH_HUGE_VMAP=y. Such regions will be
-	 * identified as vmalloc addresses by is_vmalloc_addr(), but are
-	 * not [unambiguously] associated with a struct page, so there is
-	 * no correct value to return for them.
-	 */
-	WARN_ON_ONCE(pud_bad(*pud));
-	if (pud_none(*pud) || pud_bad(*pud))
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return NULL;
+	if (WARN_ON_ONCE(pud_bad(*pud)))
 		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (pud_large(*pud))
+		return pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+#endif
+
 	pmd = pmd_offset(pud, addr);
-	WARN_ON_ONCE(pmd_bad(*pmd));
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
+	if (pmd_none(*pmd))
+		return NULL;
+	if (WARN_ON_ONCE(pmd_bad(*pmd)))
 		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (pmd_large(*pmd))
+		return pmd_page(*pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+#endif
 
 	ptep = pte_offset_map(pmd, addr);
 	pte = *ptep;
-- 
2.20.1

