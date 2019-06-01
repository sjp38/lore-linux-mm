Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52C6DC28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0404827145
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DJPd/p+J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0404827145
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E05AF6B000A; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D40846B000D; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A82126B000E; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65E816B0010
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r191so6178529pgr.23
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:50:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YP3TD4qj2FhYTbm7C+3n+R++qZq8j8DANjDQ1J/4VAA=;
        b=WsUGzycGMMDIpIjuCzUWgmhWA5HMl115/kimbPQ4BnYqfitY78n0URkxKtaRjd5yXm
         JwezCJMy+enQSn2TfYt33E3f7gaVMSG6nX0Y6luIFFqtghRfUwASNykmK4Q1ygFq59Ez
         Ql2SFUUOQ96rpd3GCrn3v0FaKvfvQCAnOs6XZQ/ByipdOCpyD3hF3IbL7lLiao2JjQ7t
         hTvVZbEjkMS7qGG1aPl6KoOdvNpKUSyq68YJeyZtyhMsVQwCW1FndtuybtQnSynwBluB
         yCzip2AC5NGrjmUMU69Sc52kWbkdTbcPHXPLKEbTdHEW6FRt72Rha52lX199RxJvphy2
         S8ww==
X-Gm-Message-State: APjAAAWVkK/5h6JoFXSXMeL7av6wvQJe1zKK78iVENzudN3geKM7jbmS
	EaAHgC9MMJKbkrDQeSYuNM5kmjP2XMv0TY2DDMedOCsZdKRRZr225/6AmtaPAvoN7ji76yiFTJg
	UtTdIH/mDvqWOtnqZsF0QIPcpJMac/T2M3DU9cCs20jSu8CL4ce1DZGY7JbmGLOI=
X-Received: by 2002:a63:2b8a:: with SMTP id r132mr13502662pgr.196.1559375450871;
        Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLYGNhB/kwqF2gqbUmntaNv8hl/5mdZffBWtMzviXgqMwP9uElKNTYWcaqMVgfydzY1vvP
X-Received: by 2002:a63:2b8a:: with SMTP id r132mr13502617pgr.196.1559375449861;
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375449; cv=none;
        d=google.com; s=arc-20160816;
        b=ijt8ZX5ACsXnbQotOtCA/Jz1P5U9xRBEmFqvE3IY2Bi9hVRrw27IlkmnUmESaqKabP
         fg2giEr+8l2CZ0mAyOQk+Bh8Al7CIREnguOIRQYxddYd+/hmSCQkQGuraM8wIGCkfOOw
         Xp/xS++7+L0OMRJWeLI45gK6fxxjJ0EFzJEVvx4vk6pMVyjWzsMvHZUpJBvIxuq+JAo/
         cOU9SvO9ywWv9rhT3+4W5+GWcPhRvq+SVdT0abUapl4BjkRqf9eS9mg3X1O174yv2ErS
         0Po3HtXpG2PvxIZ9ecuf03A261mET9bVo6dfpnmuzlIdj3Gy2e3Et05iHJM6khTZcWoZ
         u+QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YP3TD4qj2FhYTbm7C+3n+R++qZq8j8DANjDQ1J/4VAA=;
        b=xxpkZzuN2dvpuSgoWICODhmTH7L41sExbhW8PfyqB8MPo/mP25gc0myL5kp0I9POxK
         xneetTqwQHAJYyx1Y9RWb95Mzd3jQe9FmHIOTiGdcyFfkaIclkdrNOKL9J/qX1tYx9bP
         a0emekIQhiIeD803C1mSC52TFfK4+v8dAor9CDPavP0UpBnZIcWZYmrelDHMe5NX0yhB
         6AifFWwBJkyz09KimOXzxBFeb7YQQ4JIM0qHkFI/uocd4xyb7zgy+e3GspBpON3mqwUw
         tNmvx4ODCadpqmc7pSMCyqYTyjWBnGuu64Zafv08FrSrFSZU31pRgiCbfzHKChkMxahX
         4E9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="DJPd/p+J";
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 100si9151550plc.415.2019.06.01.00.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="DJPd/p+J";
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YP3TD4qj2FhYTbm7C+3n+R++qZq8j8DANjDQ1J/4VAA=; b=DJPd/p+J6xAiEW19XP4WDdXPUA
	OE7GEEQLhRzHz7FgCGv6MF29DCF/R1XhfnU+WwQD5gVnWNSRbHDwrvQ7PEcHWpnVP4a5/pKVHnzfO
	m6F4JcTmLFrPGGSj0m+c6lcvKb/jwjVbwNIzZEBSn1oFDtWpdL4ZPbF4wJw3e+U7G5dBFqMlsmp3l
	nY5m1NWcRpcPexl6UIKQEHst88/Cg1dw8PO1SdCgeTGeYUd2+PVyn9OBYfu13uEjHPtBASi0EUF3u
	FZIg18gPsQ2h4rkanz1RdkyZ0zxTxu6dNNaDuRB9k2FPU17xGpuLhRsx+87gajqcO02hzPHhj58TY
	ylFFdTXQ==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWymf-0007n3-Nf; Sat, 01 Jun 2019 07:50:34 +0000
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
Subject: [PATCH 08/16] sparc64: add the missing pgd_page definition
Date: Sat,  1 Jun 2019 09:49:51 +0200
Message-Id: <20190601074959.14036-9-hch@lst.de>
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

sparc64 only had pgd_page_vaddr, but not pgd_page.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/include/asm/pgtable_64.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 22500c3be7a9..dcf970e82262 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -861,6 +861,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
 #define pgd_page_vaddr(pgd)		\
 	((unsigned long) __va(pgd_val(pgd)))
+#define pgd_page(pgd)			virt_to_page(__va(pgd_val(pgd)))
 #define pgd_present(pgd)		(pgd_val(pgd) != 0U)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 
-- 
2.20.1

