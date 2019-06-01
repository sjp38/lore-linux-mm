Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B741BC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:50:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CE2327170
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:50:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="R8eTXd7Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CE2327170
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BCBE6B0007; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66CCC6B000E; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4653E6B000A; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0436E6B0008
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so7829420pla.18
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YXjy0WBjpu+AWKxD8h6RRyLkoP4ahwrltsDsU1htN2I=;
        b=nlQXu2Eg1MiJEx7TiXmyab7Wm94YGiDy3o9x5XxQyEiWa2N9VTgtUrh2WE27JgrDC/
         Wl1P68h03CYtTw4MDBmNMuAPQ8GHV4OvrO4GLyKJU7XxhaNHrlde2Abqyzwy2eY80PJG
         lTe4z1UulXhOkV+IKFewbaG+/wctXdrSBtFotRpqS4sAkE9LtRE5z7LlJT1TC6tgJbcd
         B+haC25xvIU+Gobq2UMhzMjzQoB2epRuQgwcU8mpB3HzgTjoue0q2vFIWFqXB5V/uLKc
         Ur0+8XrHlexjTdvF7BH4uoG4+MMG0VBjPKcLljcpqT/Rde6AvfmWD0zgqNOv6yX/yjW/
         gRGg==
X-Gm-Message-State: APjAAAWq2uAiq+ahY8ehB6nHMJl4hmPTG3mIQTYSIR4MIvUlxnWg8Trf
	dcmexjmOh3gkPS2yoOMwingxqdX9t1rSb3V7H6v9Kxevigtv2dPjLe5aI/bMVP6dGUDvx5/LHL8
	HZCmsdidgDFot2wE94N03MLWhqN421lAlhxrC/OmCHW9ftz6JUIpqEWWh5HCySrg=
X-Received: by 2002:a17:902:a98b:: with SMTP id bh11mr14199371plb.8.1559375450677;
        Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSAVsqrVDcVLn1N6Om6cufNUsta8bmIYuPz5QAsmGtLg6HDBjhwzuJ8HGStLnAempN+A+Q
X-Received: by 2002:a17:902:a98b:: with SMTP id bh11mr14199320plb.8.1559375449541;
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375449; cv=none;
        d=google.com; s=arc-20160816;
        b=CRyM/lsBNrsn2OspLH2PXomw4ehG+IOUnBuSGxrjK6yE7U/ITvGZ0zhKWkj7OqcS1+
         Wc/Cl0Hsu8XoWuRInRIsrvf35fv7fbp1EcZa6Y34P84Mld4BlU9Jzh0iHmjKiH7W/SuI
         3cnNlb7bltg1O7XnL1iIObuBz+Zr7+zH8++dQtDgVa+g9R/yQ0MXukK9mwUl5cb97+uK
         +hOksCNb79/moa0PsXvf+jvfmTmQUS9NDlmwz3CgrVspf7atrEIuwFTO5YcP4EFEnXCC
         JAJsdcBNCz7oVayBkM+CHmJ1UhN8yQdwsj+P92ch9xUQudlNbwBC5EdpZgkafOeraDR8
         +f7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YXjy0WBjpu+AWKxD8h6RRyLkoP4ahwrltsDsU1htN2I=;
        b=OIP8MmpLadN2PcpKoUXZaLcMCDwY+fUnB02U5DZKKrJPW7MyKiARDfesF4Zqw34AOv
         I25/CZfFSank5u2LR1iR8dwqCrdEBnvs2uokkhamG66RqaHYZlxx/oKieHZ4Ga2Vlpcv
         OO2IwWsnYTbElSnuSSuIEJUrVO//hLCG/STk9R1FKeik2jMLG+vXLnfxknfuExatkwmE
         M8mpNe07tsKoOx15U1uoScM5iJdOiq3RB8m0+RWCj8aly7FY05iiFUygG9MGtjthTWpO
         QDIMYV/MmjrxV+dWlDC2qQE/LFbo/twNYrvDI12k3uqkAlJtyg6SalHhRODvtZLAsBW6
         B66A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=R8eTXd7Q;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a4si7933409plm.209.2019.06.01.00.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=R8eTXd7Q;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YXjy0WBjpu+AWKxD8h6RRyLkoP4ahwrltsDsU1htN2I=; b=R8eTXd7Qhgr7vURBFw97YaTWlD
	T3lyN0YEcMJ79ClQ+mCtBMUFLuOiyWyH3g+cHJXsaGhU1ZQW0CpNC7mNNo8HyUgX3FhszTplgD7+X
	btlqXe68EAzd2OLJNYX0KYYHinh1c1G4uuGiFlpg+5KG/tYnjC/ECmZyFV2W5cbClw1LxVMs9OjOx
	xz9hhBoldK6Z0Q6nLK7VIYIQIYX28J0b8BdVQdYwzuUP/jm8NauIjZX8wekrKPrycgoI7/Cp1nW8D
	uv/lWnRuft7vqH/a/ly/wzkcdfMFR+xhY72TZ1pDxHDHpG7pasgAcW1XaGC4eUgJiUS8qppfZsHVh
	aA9pmEJg==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWymX-0007mJ-HL; Sat, 01 Jun 2019 07:50:26 +0000
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
Subject: [PATCH 06/16] sh: add the missing pud_page definition
Date: Sat,  1 Jun 2019 09:49:49 +0200
Message-Id: <20190601074959.14036-7-hch@lst.de>
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

sh only had pud_page_vaddr, but not pud_page.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sh/include/asm/pgtable-3level.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
index 7d8587eb65ff..8ff6fb6b4d19 100644
--- a/arch/sh/include/asm/pgtable-3level.h
+++ b/arch/sh/include/asm/pgtable-3level.h
@@ -37,6 +37,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 {
 	return pud_val(pud);
 }
+#define pud_page(pud)		virt_to_page((void *)pud_page_vaddr(pud))
 
 #define pmd_index(address)	(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
-- 
2.20.1

