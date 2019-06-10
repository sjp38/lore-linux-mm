Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E7BEC468C1
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35D65206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QcKUZrLg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35D65206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C28BD6B000A; Mon, 10 Jun 2019 00:41:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB1CA6B000C; Mon, 10 Jun 2019 00:41:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A09E56B000D; Mon, 10 Jun 2019 00:41:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9CC6B000A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:41:09 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so6104994pgo.14
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 21:41:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j0iK9oPhBRVSERhwHAEayZPRDfAp+ATJEAPI7I5uyj4=;
        b=Jx8h/wbYJjC9DlgH+8hT3ossUlsKfZkHAsc4QYAIl+uDa//ozks2Pc5joqGAPNs8qI
         wEH25s7JlL92cHWyq2YNalloAdfxHJ0WgiORDPoT0I3DnVLd6jDO7TTSXf7mgGVlenXF
         HQ3FoxSv8qNa4gGBrrMsC0pQGAG/3zcmWgBYPe8HVOASzgTnDxsPADb0I2axut0ZKZlI
         HZevEYw9KZ3gJwdZfaDRK+Zc6HKx0FI2pFd5/3qKAbYDDrRAEdWdaqAXy3tgeYC+uQTm
         GNBmC2khwMud6CG4HGVuOm7j9afThNpQu5WZwwlTlwHo37uhFFgjrok9QCRnc650e42o
         tnEg==
X-Gm-Message-State: APjAAAVIu9M7wHpPwDeOEOm6nK+g2lN7usrtMGOKorPwUKYTcBLiHwCC
	yBnr5EkXxLJLpv0qZVjmQLQVK+mSDOibg/zmYfURlYF5UHDten92q60ic2twsIBmp3VxNW/pItn
	ztIT7HAhruNAStnaOlTf6apD6wXOIl8dn2FYwDDIfxj7W+l5tziHuOUlldMzkjgZudA==
X-Received: by 2002:aa7:8193:: with SMTP id g19mr66092890pfi.162.1560141669044;
        Sun, 09 Jun 2019 21:41:09 -0700 (PDT)
X-Received: by 2002:aa7:8193:: with SMTP id g19mr66092839pfi.162.1560141667997;
        Sun, 09 Jun 2019 21:41:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560141667; cv=none;
        d=google.com; s=arc-20160816;
        b=yf/TsxTkIk5NKIBXXz2hjX+2Or/n+1UcGRkwbPeyBz6TRUBci1R0RR2CcHhd6+1cYI
         SuACo1PSL0J3P7p8GQntw+yUW9MXqrmzSkeMnK5R1Vano1/z6F6m0CpsrWoOgyCZ5xm2
         sIbbTaiavBqlOfjlm/flIueYoLAPHu2v3XfIUF2KpVqSwgKwpC72OkjdB9Gb5IGEV/yG
         BaOk+a220jVekSnZhzshvEIEifKm8lfN6D6A6kVWOYXsyMClVjCux7C96w5zHXeoGcPQ
         oIq6yYakdrJoB9XoNmHzaGFxSkpNWKz3GYV9hMkS+yl9gLzQe64JlwUqJVQjUowZAC0C
         OXfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=j0iK9oPhBRVSERhwHAEayZPRDfAp+ATJEAPI7I5uyj4=;
        b=oJjXEm53q3Unk+8cjOZnJl8sf2nwW6CZZeZNgyBYSioZfug8DW3Mfyqts8XW9CED/J
         piMN4cyABg3bRzYwzV1ySisZ/hMoHxlffRasymjRbjoZyvq2h7uoiV/oltQr5+PbxFpJ
         tEpElmQ7lhw3cNf9FZ8DOb980ys0qbtfxDETImgix/3opRuq8vpJelaDPOw3RsFlctj3
         ntzU8e06/eB4u3DWuJgMfMCA8LxYCZBM4AUpV35CfrE4y9KqxsQz0e4k/XzsQd+PPkMY
         VM6ZuiIYZ5IxQ5wEnqvszpRMegY8wRM/lltxcmmLKmyyR7kTgFrkmGmkLLIi83WT0TAJ
         OW2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QcKUZrLg;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor10523250pjq.8.2019.06.09.21.41.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 21:41:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QcKUZrLg;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=j0iK9oPhBRVSERhwHAEayZPRDfAp+ATJEAPI7I5uyj4=;
        b=QcKUZrLgQKctcgR3ilhCBa5vjFh1fCNel4R0mH2jk1Tp1iY8hD5fmbOXmGKoUrtwrX
         aooSLGAYY4vJTaJiilgcSwtsbtlReimSqPJehqwexfgMa1TSDy87tibLD1OVDBuraUgF
         1eug6DwfebsLN8WATm5Uo/buzMbsbe7cmFeeGAou4YR8gUntPh269QbxM4FU0ceR+tkZ
         yYV/k5ae9a57jsDNkdnoZv/7BNEnWzMf2bpp4UgMJtp4lhaMos2gOosWi+v2Q2ucsNo8
         u4SyyZAk+CXBmcTfhN9KeuKxn8I04ooCPtfQSfJVzUy10NVs7IEypZ1DcHHiWqHw2nfp
         FjMA==
X-Google-Smtp-Source: APXvYqw+VLnzFiNoQ//mElPmrK/yDIA214P00B8jjBcBGJdQSiCpHxlwG6iJk4iNAZq+HcvbqmTphQ==
X-Received: by 2002:a17:90a:9f8e:: with SMTP id o14mr18793157pjp.82.1560141667565;
        Sun, 09 Jun 2019 21:41:07 -0700 (PDT)
Received: from bobo.local0.net (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id l1sm9166802pgj.67.2019.06.09.21.41.04
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 09 Jun 2019 21:41:07 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH 3/4] powerpc/64s/radix: support huge vmap vmalloc
Date: Mon, 10 Jun 2019 14:38:37 +1000
Message-Id: <20190610043838.27916-3-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610043838.27916-1-npiggin@gmail.com>
References: <20190610043838.27916-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Applying huge vmap to vmalloc requires vmalloc_to_page to walk huge
pages. Define pud_large and pmd_large to support this.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 24 ++++++++++++--------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 5faceeefd9f9..8e02077b11fb 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -923,6 +923,11 @@ static inline int pud_present(pud_t pud)
 	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+static inline int pud_large(pud_t pud)
+{
+	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PTE));
+}
+
 extern struct page *pud_page(pud_t pud);
 extern struct page *pmd_page(pmd_t pmd);
 static inline pte_t pud_pte(pud_t pud)
@@ -966,6 +971,11 @@ static inline int pgd_present(pgd_t pgd)
 	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+static inline int pgd_large(pgd_t pgd)
+{
+	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PTE));
+}
+
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte_raw(pgd_raw(pgd));
@@ -1091,6 +1101,11 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
 #define pmd_mk_savedwrite(pmd)	pte_pmd(pte_mk_savedwrite(pmd_pte(pmd)))
 #define pmd_clear_savedwrite(pmd)	pte_pmd(pte_clear_savedwrite(pmd_pte(pmd)))
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
+}
+
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
 #define pmd_mksoft_dirty(pmd)  pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
@@ -1159,15 +1174,6 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
 	return hash__pmd_hugepage_update(mm, addr, pmdp, clr, set);
 }
 
-/*
- * returns true for pmd migration entries, THP, devmap, hugetlb
- * But compile time dependent on THP config
- */
-static inline int pmd_large(pmd_t pmd)
-{
-	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
-}
-
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
 	return __pmd(pmd_val(pmd) & ~_PAGE_PRESENT);
-- 
2.20.1

