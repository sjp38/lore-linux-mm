Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09680C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:37:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B28F42146E
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:37:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AAx87/4y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B28F42146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94A776B0005; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 717608E0005; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 605276B0005; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5DB8E0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y7so11997735pfy.9
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:37:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QyABUaahMXDucs76DrKe6gk3GH371BfoHXoRIxsRdtE=;
        b=Fu+ULGSS7DTns6hN5F0Yd1g6YXBvs2ApjODfQSvnSabuq5puVHF9HXKNmz27m+4VxR
         IoCGdLbshqXnemW9HCs5bqKSl3x7l5HSlUnOwdW8Zqpy8ORZw0iOJTZQN0+pM7CRPegx
         UM7X3CayLCrinirGANxECxx9U2cT3tXmzcELTWIuCDvhBJ6dohKIRQ5g6dO4a1k0MlGJ
         pEs61rvVz/wAc7q+5nNiG1OPF+5wkeLSETpD2xkqubOiC2aQDnh+42EyV905OmlxRX5X
         n+jrUpRm1+KW8j6z58fzStSDR9nf8bGm6LX4Iu0Z/656BRNFoTZjO5zuKaLLbhQxaRKQ
         daIg==
X-Gm-Message-State: APjAAAVG/uCAxvtDoUq0Oie1U+CsOncreGXZu9+B1uW4Xe71SB+cDw3N
	KKQuEUr38R8k/HfEumMyv+Hmkqn4X8Zr4MbaCLfkK2UWMUl5suyL+HLVJLRM2x0n2daIx5IvUgT
	CvYyl1o/dgsbd3FIlwHwgAhch7J/itvTs7xwRQ9UTDLyumOX2KAqJwKCFFTmc1yE=
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr32147594pji.94.1561473467687;
        Tue, 25 Jun 2019 07:37:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkz6cteDawP+F2u+xJA51Rw885qRho5ZVXphuzx7x/oxDZZVAZx6IbpDc3PZxv7aKpl7d7
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr32147476pji.94.1561473466588;
        Tue, 25 Jun 2019 07:37:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473466; cv=none;
        d=google.com; s=arc-20160816;
        b=zl7gKDorI1xWCgdGzfybNibH/dI7nJ8ODs0ciWTGV0fGKjni4fzuoCVEQSS832Olt2
         gDex6V5cpjBlnZQZelZop/QzEgH2UQFN+wHDCMaLDqCe+nlkKPSlvgI4GS10fDWmyTHe
         0IUO3eIBnSiwLoHZgv+W0gV9+WBCJ6ZaiZMTr6EQvytleCATRDHgGxWzJcWvQ2Bll6Mh
         x1TBiF9K6RRp9DQjUkfglbHvNZBk74CWou6WgMHm6Xn9KH2Y30VJWB9AP8t8/zgVSQG8
         9gCLkyerc8m9iE08n+qiqxKxuVPf9ibJ5ys3QipGqye3QxCJRf6GCTOYSIC3UFebftLR
         izwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QyABUaahMXDucs76DrKe6gk3GH371BfoHXoRIxsRdtE=;
        b=wc8A5SI5OclEQZrsVIFnL2aJijH9dNS8S0gUZr9pzdmtwJwWy1Fi4uoZt/2e8L0wvr
         17a+WysOfrVViVVGFIl9TATd4JfUa8wiAF0kgFaqfw5jr90QRftyF9+JgBUz9WFZZ+UL
         XhW4tu3GMZEgpkpWNXAmliL7+s0U+lEZh+OFsg2M/RNFmAHLG+mB1j+Wxqk0IEosvZFn
         pwbiKkHIfyTSyC9QKWIr+sz6Q+S7IpLH00xjEQWV2aaOmhGRxMBePZWKEOcyOE5ZGHCs
         wNKW+H249JD/JwId8MZwrWmtFngV0+dvlZ7j7uYRKgTnnk4npiAdQ/li5oOZVe3QKQlt
         fdNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="AAx87/4y";
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c139si805482pfb.140.2019.06.25.07.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:37:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="AAx87/4y";
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=QyABUaahMXDucs76DrKe6gk3GH371BfoHXoRIxsRdtE=; b=AAx87/4yE16TLsgzBCexdNloqw
	SQQ6qt7hqNIhycsh55YfUmQTHyMCyPi2/hko55Yyb/MqJ6mZU658VEOWrTR4SEardCSyw2OyaS7Oy
	tBVovYa7OkK9CHSAYiGX8ezfbBDSTCbse7HWwKjnqN+Arqb4YRKFOCTmwpUJlDYVsWiEY8ozxYcds
	6bCAb83LXOmgvX640XkeJiJ/V4bWtzNckqR7avhkK7JDjCrTScU4sdqO0TnUFEd3vBe3Jf+istmyu
	9W5pIRypWNJcfNvcS5ZYMh3KwXg4/RiOBrL8RdpyMIwFY5CGgN6likzAe4jvbBDb7aMG+8TpH4DpH
	CuGb0Wqg==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZb-0007yK-FI; Tue, 25 Jun 2019 14:37:28 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
	linux-kernel@vger.kernel.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH 03/16] mm: lift the x86_32 PAE version of gup_get_pte to common code
Date: Tue, 25 Jun 2019 16:37:02 +0200
Message-Id: <20190625143715.1689-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190625143715.1689-1-hch@lst.de>
References: <20190625143715.1689-1-hch@lst.de>
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
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
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
index 98f6e4f88b04..4a9c63d1c20a 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -650,7 +650,7 @@ static u64 __update_clear_spte_slow(u64 *sptep, u64 spte)
 
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

