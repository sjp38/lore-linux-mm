Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1D40C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:50:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0AB52715B
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:50:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mkWRLr9J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0AB52715B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A87706B0010; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 752056B000D; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50A746B0008; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1440B6B000C
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e20so6193485pgm.16
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:50:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=64aY9b4xFVCSoNTQbXTmr4fGKAtsk5F7+1Ma/JRJei4=;
        b=D+nj2jfriwDkSVsMF9A/kTFYztNyxXYZx3ppUqesiFJMREk5wxK2/ll/Ziczl8ZuST
         puxsjsq6g9jDAsNg88Ha/YzeAXHajRPEpxen41eKJBzPeEYdTp5a+jgFWqxpJ/zIXc2l
         Ym+Z3ss4LwL8UZ8LtFEbnikUFaKgg7jnfmogrKsVxBCIKanDr3dw6028i52P+3M2B99p
         DgoDl0WUWpKmHYKv/uKexSE33mfxo+BG4bE6mgXUWd9iYTxwbhi9sxe87jcEt2oZZ51Q
         UCI6yxxRVWSM4WfsXDxG7r33nRseUnKsTgquArruaGLNdva7Y8s+mSZz9oqh4flsNlNW
         hJQQ==
X-Gm-Message-State: APjAAAU088v0zoevwyXV2RdBH1m5x0BIfGyfVZD288FoBumGq/bmjWTW
	8uibyi0q+CmmZRmBEaTvgc1B7n0nL9b2+x15nVF1cC9t0o7/CxpwSFotpidQ2Ju0xkpSzRCNb6O
	sqPusnBWEnML524+rDFHZIUYQPleTIbD26XIezcxMgFA5o3p9JlL3xQjQhvtTxxQ=
X-Received: by 2002:a17:90a:9f8b:: with SMTP id o11mr7522893pjp.102.1559375450735;
        Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDiBPuZHcdfLynJG8IlitA/yJLZZwdw3mXtuLNt7py++COOG03GdgAo6g4/YxJzsTcxzv0
X-Received: by 2002:a17:90a:9f8b:: with SMTP id o11mr7522829pjp.102.1559375449539;
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375449; cv=none;
        d=google.com; s=arc-20160816;
        b=L6V4Z1esuv2119QvopUBu9dK+TAv4Qr4cFk52WEbkkQ9kegKc3geCy8mQyyszmXoYV
         vufMM3tfYpdIR2JWJM48CCveg5YGk2IsJlRXi31P6ag6ydu+9sgfOuTENkTApyLv2ozD
         NSc15S3wkIvSbFKD/35bjkyBuxcXF15eXSKIqsB477YtaC+mnd9brgdQD+jjvGWTqg9H
         Qh18chCkWkO6RXHmhy1GIZ6LgPcyoj0cElhYehRkv2pD9T7PIRqNLWFnVyQHoyei+PWM
         p12vM8dXA1yIlLRVnNqHlxwTjqyMFwLhB2PIOEg41tUm0hMe03pKQSL0M1AzuXHsPwMv
         XmiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=64aY9b4xFVCSoNTQbXTmr4fGKAtsk5F7+1Ma/JRJei4=;
        b=BD7nZLZcgGBZA/SS5XwNyJ/4v5ptQI1sBtDfhLAVSQge4F5NahNVIhWTgFPSV8PgK5
         zuWV/GOL4TX/uC6IxN9EmzoMxRjAMICxdYnruAkjQDSADths52z8DCELeuk/b8K4Tb0b
         4KelnLEA8NXAhkaHzihWSLv/kLRmo6dkzw88ScX7NZZYZ7c1bjnudzTV+mpOjaIWGxGD
         4cROL2oIW1o/N/9Bvsiih4plkFAbnseQ2hZoliTldUGAWtAxuXiLPZdTMQ3EzcmFiNt/
         RBUUETUf587CxwXR/9iiT9TaRKc3AvSFhyFnhlG6fVxfiPcKS+UszfYspG2tPhZIrCEp
         XdIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mkWRLr9J;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u42si9310327pjb.31.2019.06.01.00.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mkWRLr9J;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=64aY9b4xFVCSoNTQbXTmr4fGKAtsk5F7+1Ma/JRJei4=; b=mkWRLr9J9mHC0wx40p7g15JOI9
	MqOjScSPa9jeEaRm9X2mjxzwMKdjCd086mEGnPApg7IMDXb1c7CpovPAF6hXz2nMidmHuycA4jU0t
	uYlQ3KBMfUCPEMSbW9cc4MZnsg4vxER8u/iO/pt02EJS8C69A7HyF1u4YCsOwGF3WTfZVnDfmIvrY
	mjdmAE+SemqsVDC+nsAYctAGcsSTP2jyW9Tra0GOmnaRwgZjYuZsl6++JQlzm+y47NF8eU0MPkqi3
	of1k7Chqe2bjQ8kairsqNJ+gtDw7yjrfcUA2WU5ac8yOVr2wiPgLS1f9WRR0fa69WyMUAbZ/uEtoY
	XAOpu9Dg==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWymL-0007l9-SJ; Sat, 01 Jun 2019 07:50:14 +0000
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
Subject: [PATCH 03/16] mm: simplify gup_fast_permitted
Date: Sat,  1 Jun 2019 09:49:46 +0200
Message-Id: <20190601074959.14036-4-hch@lst.de>
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

Pass in the already calculated end value instead of recomputing it, and
leave the end > start check in the callers instead of duplicating them
in the arch code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/s390/include/asm/pgtable.h   |  8 +-------
 arch/x86/include/asm/pgtable_64.h |  8 +-------
 mm/gup.c                          | 17 +++++++----------
 3 files changed, 9 insertions(+), 24 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 9f0195d5fa16..9b274fcaacb6 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1270,14 +1270,8 @@ static inline pte_t *pte_offset(pmd_t *pmd, unsigned long address)
 #define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_unmap(pte) do { } while (0)
 
-static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
+static inline bool gup_fast_permitted(unsigned long start, unsigned long end)
 {
-	unsigned long len, end;
-
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-	if (end < start)
-		return false;
 	return end <= current->mm->context.asce_limit;
 }
 #define gup_fast_permitted gup_fast_permitted
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 0bb566315621..4990d26dfc73 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -259,14 +259,8 @@ extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
 #define gup_fast_permitted gup_fast_permitted
-static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
+static inline bool gup_fast_permitted(unsigned long start, unsigned long end)
 {
-	unsigned long len, end;
-
-	len = (unsigned long)nr_pages << PAGE_SHIFT;
-	end = start + len;
-	if (end < start)
-		return false;
 	if (end >> __VIRTUAL_MASK_SHIFT)
 		return false;
 	return true;
diff --git a/mm/gup.c b/mm/gup.c
index 9775f7675653..e7566f5ff9cf 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2122,13 +2122,9 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
  * Check if it's allowed to use __get_user_pages_fast() for the range, or
  * we need to fall back to the slow version:
  */
-bool gup_fast_permitted(unsigned long start, int nr_pages)
+static bool gup_fast_permitted(unsigned long start, unsigned long end)
 {
-	unsigned long len, end;
-
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-	return end >= start;
+	return true;
 }
 #endif
 
@@ -2149,6 +2145,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
+	if (end < start)
+		return 0;
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return 0;
 
@@ -2164,7 +2162,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	if (gup_fast_permitted(start, nr_pages)) {
+	if (gup_fast_permitted(start, end)) {
 		local_irq_save(flags);
 		gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr);
 		local_irq_restore(flags);
@@ -2223,13 +2221,12 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
-	if (nr_pages <= 0)
+	if (end < start)
 		return 0;
-
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return -EFAULT;
 
-	if (gup_fast_permitted(start, nr_pages)) {
+	if (gup_fast_permitted(start, end)) {
 		local_irq_disable();
 		gup_pgd_range(addr, end, gup_flags, pages, &nr);
 		local_irq_enable();
-- 
2.20.1

