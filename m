Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12B83C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD13E27144
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="W5Fzpc87"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD13E27144
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB7646B000E; Sat,  1 Jun 2019 03:50:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D68D56B026A; Sat,  1 Jun 2019 03:50:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE3CC6B026B; Sat,  1 Jun 2019 03:50:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 671EC6B000E
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:50:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 21so6214952pgl.5
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:50:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NGsW8HzLPAPHTIJruOFYV46CCZebbD2jcoy4DVgB5lc=;
        b=WPOgVbvfdtZeJSBAQ+1C3twMJs+FYcX5kmWb3lWk+l6kc+VNmJzZ7SxUGRRxocBTz6
         AtsH0OeiGNMfXMcHwbMjnRphDcZUVxFzaiO0U9i4shZ3G77+F5jrK4jLe0Z2EiTj0W29
         iCxS7aD1vG07Blv3npS15nmwfVe+TdRJE065Snnpz1j1JFlpmq9TQzDqzjsy7AHe/Zx+
         qgMzA/RkROhm2mjUpVodatwtYutFPWMJDrAbS1g1rysnjkfDtR7qgSKPAFJda9joxU5a
         qKFlsh1GAMKdA6xTqioRQ+87MJyGeV8y91bo4p93om4qeJJlSmvY0B7zBK7gdhFkEa6F
         muKw==
X-Gm-Message-State: APjAAAWVBxwftArgLPoGyPLx5i7J5ykQhCf+TQmy3ELjckD0eJ3rnxie
	jk1GXNoNduZ2DCbG7y4f9bPS23tw91CUAu79C/YtR/xLlc8aYKqj2bU2jaKUwmtFlU69hzWoiQr
	uKpCY7wYCInCDVmTZc6I+JIiEK08bH0lFOIqIcDJnZht6gzlGZw4c2PADQZxfXPY=
X-Received: by 2002:a17:902:e65:: with SMTP id 92mr13725912plw.13.1559375451952;
        Sat, 01 Jun 2019 00:50:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcPjmlVcvSE0mM8uh3OiBaJfJK5IfHy7NfPGi+HiHDABovKsmFtJ4eUeDKX6SN2+Fo7/H1
X-Received: by 2002:a17:902:e65:: with SMTP id 92mr13725864plw.13.1559375450994;
        Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375450; cv=none;
        d=google.com; s=arc-20160816;
        b=fXgqj2eJuM+yD8yvt2AMQGlxayttWDB9M9fvB/eh+/Kf0sdWWkyk9kaHbRdBjwL3Z5
         nLEHr0p8C1Q2VofK3lCxU46JjF2Q4GHKEeEH84okfkFv/gSnKPI3jvPpdkPwxdZ3TYSi
         sBKmTYwlapkR9E3Phi2STOOlaVIZqIXq32+9kidLjXBY9CvXTzW0rxaotVlcyYCgRT++
         605yn0kHt1FGFTACs41JKNdigbh0oMPR8LDIRe9OEZVR2OvVbxYTs883bUYgs/qANOYJ
         CYxta/eQUB4WD67j8ULD7wlCckrfMkUJRbyIJa2Zr0Q3ZRXgGdvKCT0lmZhoCUQx9EGB
         Of+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NGsW8HzLPAPHTIJruOFYV46CCZebbD2jcoy4DVgB5lc=;
        b=mdK0ACMG6eBWQ6thJf5weAH9bzY8DNGQ3u5Sp2xq8gto7As4HvY2I1jhtErTnECHT+
         OnOBb5hLpKFgM+FgWs30vMzff+6koAqlDWl2da2MHChMfxZdqUWzgtvkp500uHhV8+Mz
         WOJzYgr9kuPWNIwkHWaNL/EoEwPIiBxrfR4Qxx03F+gjiwD4CtnbOOJyVU7EDs+nCV8T
         TJuR+LRj2uCvtkdPPYrAtwnBkBVPIf7vaVzNePK7+4vB2I7deh3cvGRydMDEOdDegC21
         NmhZYb4AXqckhBKgEzMGgEKT7r2qWeWjOuI9S5aSkCFIVzxfqypcznMOpBlFaftFjqIZ
         hIXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W5Fzpc87;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c20si9583668pfn.256.2019.06.01.00.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W5Fzpc87;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=NGsW8HzLPAPHTIJruOFYV46CCZebbD2jcoy4DVgB5lc=; b=W5Fzpc87jCQCC5I6JcXqu1in1I
	bTayVjBGlByQf2ZOtE9bIqErZj9AM62H0OpGdn2Lwn/2GipoPoUap/cZI48aqF3c67aiqzWD7xbwy
	rEe/vNn2Y5BW+ULmJtjeZ+Mr2peQo/QDFuFWa1wpYjvtqDabrbi1+Lb/vRP/IS07oRb2z359JnkOl
	Oy9vNMlvt4znhmC6ieL36xbVUTGtLHkLluq9lqqbb8gj0tnpd4cHSTEZjmUUmFznkNsHwT38QqN8p
	+Fn/qI7Ube5PWwxb07Fd0bPoB3Fs0JRhQF3NXFvyAv7RtQdHYjOw1aOnL3P8wYLYee4qTtR8skK0a
	sow2i3GQ==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWymP-0007lT-Rf; Sat, 01 Jun 2019 07:50:18 +0000
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
Subject: [PATCH 04/16] mm: lift the x86_32 PAE version of gup_get_pte to common code
Date: Sat,  1 Jun 2019 09:49:47 +0200
Message-Id: <20190601074959.14036-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601074959.14036-1-hch@lst.de>
References: <20190601074959.14036-1-hch@lst.de>
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
index e7566f5ff9cf..a86d65cd7051 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1683,17 +1683,60 @@ struct page *get_dump_page(unsigned long addr)
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

