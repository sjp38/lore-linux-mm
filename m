Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8028C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:37:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F3C620656
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:37:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nD3PJ12M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F3C620656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 370678E0005; Tue, 25 Jun 2019 10:37:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F8628E0002; Tue, 25 Jun 2019 10:37:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C13D8E0005; Tue, 25 Jun 2019 10:37:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCA498E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:37:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x13so7831716pgk.23
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:37:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rMutb/mdXZWT7NThFT68hJrDj+EN7r08hrqkExGM1N0=;
        b=K3IABX7zRBp0iG/YOaMWrDQ9d9VZVJvaI2MghonIRDes988CSXAPnkQ8/QZpOA3PRC
         jII0xk6Kh95zmNkC5Z1em1OB23KfCedcbfQOPSjlHQEvPutNDn+0Li9sFaYK8X1IDSVm
         BZD726XgNNvnW2EgCldNxXX1tmTbkPQElCGlkiIcu6N+H5zFkfM2wAM+MgUcGzSZXXPw
         Bcwsh0GXbcU+HIhxQLNFeF2HAKN4jFBY/aV6X4tYRw1clvVTQtifv+kdefVZRPNk94dA
         VegepxuDBZhJp6xzce3z+mVfRrlciFjvzfJEWXgEGYQc8D3B8QX7NF4H+SIOg8yyiuoi
         R51A==
X-Gm-Message-State: APjAAAW8NM6o0Eo2uoDO4xFfIzyhNNeVTNZ2EAjCmeU4ZUhUnFLNGms3
	GDjSd3EQrlIv+pt2EoPkWQb0e+Y+lc/MO8Fzm6ugBK/+9ejiARBcwhfZltLY2NCIDUaVF8wt2KJ
	CyS28nMdRzKjOV6zhIJPQcj0pZoD2g6z/e70Rr51kjl8W50brsdIUexJgANcQl3c=
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr152332211plb.26.1561473471526;
        Tue, 25 Jun 2019 07:37:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8SyTyAlFHq8q1P/mxFv9eJTjXVopxgspckYsAshsLAZLPAOyAyXPtGJwJhqz2jOO/FB/B
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr152332133plb.26.1561473470607;
        Tue, 25 Jun 2019 07:37:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473470; cv=none;
        d=google.com; s=arc-20160816;
        b=E3fNEyT7vz0v28xvab9ADIatG2+mIdpRgV3Ycsd0RVkprklYizATyYmOL2fPFoq+t3
         lHfun9mziDtn3svEUIBCsjfDFVBf2/6MyX03nC7ibOAkG8WrpOXvG/YuHRjRcuyNKZIw
         s6uLeFKCQq5BUBMKwrUueWVGvAJ4WZFUKz4yp30llja0micLb2R90hBPmUYlfupTu+uj
         Tc3RT+NpBMdHJ/+C27M69BnGeR2yL++qZjPhaKsZmLheN5GqyGdr1f7sdlLF5xoBWbo4
         2mlrQk6vMXSSAycA91jybCO/yhULWPIhQbOWC0HwxxHO+tYXrIqfb+2J74gjr7qSsk2P
         ZRSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rMutb/mdXZWT7NThFT68hJrDj+EN7r08hrqkExGM1N0=;
        b=iD18gcTF8+TMFrtkZTkWVBu4FkxUk+oQaEU9wQs8/1rVrzZvKAksL1ip5Vp+UdUY8d
         bPWPY0XIhhhK71w4AtPk4XrzYMfc7RtwEa90El/hTm+b8Se+zfGe2hGIGwAl2PwSKl6e
         cRxKhGstxXcW09KwOUn/zGuZ2KrHJwWEam8QwrTKkcVvPsQvadgp0ZGuXrXg0PKFcCcp
         tLG81hCI9M81GPRpNYqg6eHHWRs3s/Q+Oub79NH6kTNqnmI86Apsl4hdDMQdVPjy9+0z
         GJA9jkKhQavFdHz4k81Vxl0TldauEY98/TNZ7IAD4dONsN4u+Fh5z1BXdfeE9tYDKOBu
         IkRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nD3PJ12M;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j25si14050497pfr.11.2019.06.25.07.37.50
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:37:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nD3PJ12M;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=rMutb/mdXZWT7NThFT68hJrDj+EN7r08hrqkExGM1N0=; b=nD3PJ12M/+ZRf8iUUjpwR2BcYx
	672S8ju0tCof1gf2fqrCbrsCpu7NFBMKaLTMwLkXOaFiKyFut/g5RXRJ/cOxHnubPbiLSN5aV8tJy
	JavcS+cHBWZD76nRh6lZuQ/mQIPinDpLY5TMCmr49gDGHFbuHmJdb00rTzy1mFwlsZIsSgl9kT5Fj
	kkd5icJsltmuqyAF7k3QI/zT6tGFmaPcaUX17VAB09De8SAUkTKOfv2zQx+qdDT4CeXWd6UHrZjo8
	A++RYiFjkYlhD6cfHebQjHq6sW2lxvpcONIU3/+aXFXEukG9qDfInJQXNXV9C+WwblaXsZ2jisVo+
	/tYjAgzA==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZY-0007y2-7Z; Tue, 25 Jun 2019 14:37:24 +0000
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
Subject: [PATCH 02/16] mm: simplify gup_fast_permitted
Date: Tue, 25 Jun 2019 16:37:01 +0200
Message-Id: <20190625143715.1689-3-hch@lst.de>
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

Pass in the already calculated end value instead of recomputing it, and
leave the end > start check in the callers instead of duplicating them
in the arch code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
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
index 6bb521db67ec..3237f33792e6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2123,13 +2123,9 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
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
 
@@ -2150,6 +2146,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
+	if (end <= start)
+		return 0;
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return 0;
 
@@ -2165,7 +2163,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	if (gup_fast_permitted(start, nr_pages)) {
+	if (gup_fast_permitted(start, end)) {
 		local_irq_save(flags);
 		gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr);
 		local_irq_restore(flags);
@@ -2224,13 +2222,12 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
-	if (nr_pages <= 0)
+	if (end <= start)
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

