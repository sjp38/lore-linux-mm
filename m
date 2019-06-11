Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A70B8C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60BD62089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="X22/uN/3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60BD62089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB37A6B0266; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 916D06B026B; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7187C6B0266; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34E1F6B0010
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x9so9737259pfm.16
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:41:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=g4MxpUkGP+hxy8ku71ZEZt00ts6l03REsi5/bfFDlbU=;
        b=Nbaq3iNUVgN2orXQOzMTP7KRA3bUfpklXkwO0xOuBMewu+wQzfUMKBcRTP1efEUhSA
         eR/pnRBx0SYik6klA6Ym0WI1jpk4mzc6zjsPa4fcYkKD5ZfBWKvlRpNKDMJEkXwQYDi9
         G7edSs//ylOitQaFBMh11ETi6E7ab0HhN13hjAuIbwvdH8GLI/ptSjBb5fd8sOp1+gWM
         1lcGw+lkTLf4DY85PLPS7jZCuHYB36bqF2fkApYuuSb+zXlMtxDS4qf0Ih8AZ7IyWOhi
         wk5k4o9dE85Gw2jW8Gdu5sNIZLcxPWsucQwVKmwC5xDCTUdGLY2xo8Jlg9NQshGax8SF
         CrNQ==
X-Gm-Message-State: APjAAAX9vfJxyLpsiNZ82I7t7wjplhk4XlZJCsw1GaAw62pUI8nHM/pb
	HHHtv/+nS9qUUFH/ed82MA8yoBUIMv7haZ1NCAQsDkLiPo+hRLvEL2NPxdqSiwB2Dk9KlQeqNgt
	mfHibtgK5CwH0SY1bHH1QgS/L+sGJu1IzpdzLN4q/xYjcNW9G54j9Efx30k5lVco=
X-Received: by 2002:a63:f817:: with SMTP id n23mr13116881pgh.35.1560264106506;
        Tue, 11 Jun 2019 07:41:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzABvFnGWL0+wpyfbCeIVT5ssyc62KtOlTTuTx2UVStwVuv4/i+Vvii2AIAmYf7TpJ1V7Oc
X-Received: by 2002:a63:f817:: with SMTP id n23mr13116823pgh.35.1560264105495;
        Tue, 11 Jun 2019 07:41:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264105; cv=none;
        d=google.com; s=arc-20160816;
        b=WbqgcR/mTXdR0xa8+IZ0Jj4tm9nzo4NQUwH32sd+B22iqBDWoXP1icROXhu5jrGbAj
         lknT1tMl3sj1zDTXKd6n8xJRN/t6OThZyBEVdk9rVa/NtypIEm/tfXO6N86w5YJwoDXy
         hCNY71jneiDfJvbRjGutP58dvAFPXDQedokBZzvdRcdEQW7XH6sqM2HZQS4AwPkR64hp
         HP5/J2Pav91TTQlT98ff1kGuZkDEqswXt+n4GxYdnWc8XrIvE+g/ijNlS0YGkKgXrkZR
         Zzm9NjVxDBWhrN5vQRksMZvqTCVUaj2DtAeUv3CO9xNh4zUW8cSmuFtvdIWTrt1n4q0F
         nQWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=g4MxpUkGP+hxy8ku71ZEZt00ts6l03REsi5/bfFDlbU=;
        b=JqeUkgO6zBlgW0hN9XMGavy+pWJ0acXblCXivAr7VLqMdcupmxjhREAHX57QfMZjd4
         qX3XPc5cI74HRh1qEXbmCJo+oBJnuYCnU5hobEd2pVT3X77G40wSHbmQTPAsHtb/BgSQ
         RtITGMl9N0bQvYr2SQAe1TNUd6bsxw2XXmuKfj94wojfC0hsd60lVZlvgTtxdh/6tH5R
         x82Teust7FJsbtnAkUufFxiqYuFV2LGMel19FlpFlNq78q42R5CrqmGk3DAbMFgMla4b
         PuXMM3swt5KR8qYXxGXBg6jX+UuXam/Kxghs7xYLP5ipXzMHO7IJPGBLjaVhJD7bvicz
         E2PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="X22/uN/3";
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x7si13453836plv.130.2019.06.11.07.41.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:41:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="X22/uN/3";
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=g4MxpUkGP+hxy8ku71ZEZt00ts6l03REsi5/bfFDlbU=; b=X22/uN/3aqQ1VzBdZFYnIpfrIJ
	JgQOzg3WSjfNhYKznXgvyyQPBF9PGAwq6jJ+1Hl6cDJMxwNjBGvNc5s3srm+ocnQmrf4M8kkhOO/W
	gUs3R2xrlOGvqs5y2CBuev39K1ER5sRtYrGoq4y0dvrKATsVsJpdUPRmS687iV9RkUotsvw15Mh/S
	4xZTVyXHovu/nPgEBWXHfcBFWVWgBaRnr9MDCEclbB2bKjUsn3GX8AOIK006JtuGdhzZjag1gYo4f
	8nPJijR2K316Q4pSDbA33p2yfBWo6yWTrnofL9AuquV2WMhI6Gu2jUVnjmOBUfBlIATdgpoy+HhA9
	kLOu+C6w==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahxc-0005Pc-Qw; Tue, 11 Jun 2019 14:41:17 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 03/16] mm: lift the x86_32 PAE version of gup_get_pte to common code
Date: Tue, 11 Jun 2019 16:40:49 +0200
Message-Id: <20190611144102.8848-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611144102.8848-1-hch@lst.de>
References: <20190611144102.8848-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The split low/high access is the only non-READ_ONCE version of
gup_get_pte that did show up in the various arch implemenations.
Lift it to common code and drop the ifdef based arch override.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/Kconfig                      |  1 +
 arch/x86/include/asm/pgtable-3level.h | 47 ------------------------
 arch/x86/kvm/mmu.c                    |  2 +-
 mm/Kconfig                            |  3 ++
 mm/gup.c                              | 51 ++++++++++++++++++++++++---
 5 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2bbbd4d1ba31..7cd53cc59f0f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -121,6 +121,7 @@ config X86
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
 	select GENERIC_TIME_VSYSCALL
+	select GUP_GET_PTE_LOW_HIGH		if X86_PAE
 	select HARDLOCKUP_CHECK_TIMESTAMP	if X86_64
 	select HAVE_ACPI_APEI			if ACPI
 	select HAVE_ACPI_APEI_NMI		if ACPI
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index f8b1ad2c3828..e3633795fb22 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -285,53 +285,6 @@ static inline pud_t native_pudp_get_and_clear(pud_t *pudp)
 #define __pte_to_swp_entry(pte)	(__swp_entry(__pteval_swp_type(pte), \
 					     __pteval_swp_offset(pte)))
 
-#define gup_get_pte gup_get_pte
-/*
- * WARNING: only to be used in the get_user_pages_fast() implementation.
- *
- * With get_user_pages_fast(), we walk down the pagetables without taking
- * any locks.  For this we would like to load the pointers atomically,
- * but that is not possible (without expensive cmpxchg8b) on PAE.  What
- * we do have is the guarantee that a PTE will only either go from not
- * present to present, or present to not present or both -- it will not
- * switch to a completely different present page without a TLB flush in
- * between; something that we are blocking by holding interrupts off.
- *
- * Setting ptes from not present to present goes:
- *
- *   ptep->pte_high = h;
- *   smp_wmb();
- *   ptep->pte_low = l;
- *
- * And present to not present goes:
- *
- *   ptep->pte_low = 0;
- *   smp_wmb();
- *   ptep->pte_high = 0;
- *
- * We must ensure here that the load of pte_low sees 'l' iff pte_high
- * sees 'h'. We load pte_high *after* loading pte_low, which ensures we
- * don't see an older value of pte_high.  *Then* we recheck pte_low,
- * which ensures that we haven't picked up a changed pte high. We might
- * have gotten rubbish values from pte_low and pte_high, but we are
- * guaranteed that pte_low will not have the present bit set *unless*
- * it is 'l'. Because get_user_pages_fast() only operates on present ptes
- * we're safe.
- */
-static inline pte_t gup_get_pte(pte_t *ptep)
-{
-	pte_t pte;
-
-	do {
-		pte.pte_low = ptep->pte_low;
-		smp_rmb();
-		pte.pte_high = ptep->pte_high;
-		smp_rmb();
-	} while (unlikely(pte.pte_low != ptep->pte_low));
-
-	return pte;
-}
-
 #include <asm/pgtable-invert.h>
 
 #endif /* _ASM_X86_PGTABLE_3LEVEL_H */
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 1e9ba81accba..3f7cd11168f9 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -653,7 +653,7 @@ static u64 __update_clear_spte_slow(u64 *sptep, u64 spte)
 
 /*
  * The idea using the light way get the spte on x86_32 guest is from
- * gup_get_pte(arch/x86/mm/gup.c).
+ * gup_get_pte (mm/gup.c).
  *
  * An spte tlb flush may be pending, because kvm_set_pte_rmapp
  * coalesces them and we are running out of the MMU lock.  Therefore
diff --git a/mm/Kconfig b/mm/Kconfig
index f0c76ba47695..fe51f104a9e0 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -762,6 +762,9 @@ config GUP_BENCHMARK
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
 
+config GUP_GET_PTE_LOW_HIGH
+	bool
+
 config ARCH_HAS_PTE_SPECIAL
 	bool
 
diff --git a/mm/gup.c b/mm/gup.c
index 3237f33792e6..9b72f2ea3471 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1684,17 +1684,60 @@ struct page *get_dump_page(unsigned long addr)
  * This code is based heavily on the PowerPC implementation by Nick Piggin.
  */
 #ifdef CONFIG_HAVE_GENERIC_GUP
+#ifdef CONFIG_GUP_GET_PTE_LOW_HIGH
+/*
+ * WARNING: only to be used in the get_user_pages_fast() implementation.
+ *
+ * With get_user_pages_fast(), we walk down the pagetables without taking any
+ * locks.  For this we would like to load the pointers atomically, but sometimes
+ * that is not possible (e.g. without expensive cmpxchg8b on x86_32 PAE).  What
+ * we do have is the guarantee that a PTE will only either go from not present
+ * to present, or present to not present or both -- it will not switch to a
+ * completely different present page without a TLB flush in between; something
+ * that we are blocking by holding interrupts off.
+ *
+ * Setting ptes from not present to present goes:
+ *
+ *   ptep->pte_high = h;
+ *   smp_wmb();
+ *   ptep->pte_low = l;
+ *
+ * And present to not present goes:
+ *
+ *   ptep->pte_low = 0;
+ *   smp_wmb();
+ *   ptep->pte_high = 0;
+ *
+ * We must ensure here that the load of pte_low sees 'l' IFF pte_high sees 'h'.
+ * We load pte_high *after* loading pte_low, which ensures we don't see an older
+ * value of pte_high.  *Then* we recheck pte_low, which ensures that we haven't
+ * picked up a changed pte high. We might have gotten rubbish values from
+ * pte_low and pte_high, but we are guaranteed that pte_low will not have the
+ * present bit set *unless* it is 'l'. Because get_user_pages_fast() only
+ * operates on present ptes we're safe.
+ */
+static inline pte_t gup_get_pte(pte_t *ptep)
+{
+	pte_t pte;
 
-#ifndef gup_get_pte
+	do {
+		pte.pte_low = ptep->pte_low;
+		smp_rmb();
+		pte.pte_high = ptep->pte_high;
+		smp_rmb();
+	} while (unlikely(pte.pte_low != ptep->pte_low));
+
+	return pte;
+}
+#else /* CONFIG_GUP_GET_PTE_LOW_HIGH */
 /*
- * We assume that the PTE can be read atomically. If this is not the case for
- * your architecture, please provide the helper.
+ * We require that the PTE can be read atomically.
  */
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 	return READ_ONCE(*ptep);
 }
-#endif
+#endif /* CONFIG_GUP_GET_PTE_LOW_HIGH */
 
 static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
 {
-- 
2.20.1

