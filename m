Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E78C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E2DD2145D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Elx6a7oB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E2DD2145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 920B76B026C; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8043C6B000D; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6578C6B0269; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 152486B000D
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id y187so9262207pgd.1
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:41:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NpWcgZzp3PVAHx6KOALQeB51c2SoNPG0lnYZA6y2f1k=;
        b=CJYi3PJvAuBTpfAx9ZRTePS6O87j42Tt0T/qjqfsAq7HRMeKNIG8k3OPmNBUYKJwSe
         kFa8jeGMazkJ54RqF6dpdblQK7TKIYiCn8USQ35K8rzCWwMgl8EiyK86Eo6WGWQKB7GH
         wRjWaatH6o45BLV4NViiFKY6AbL3sHPZ8Cec4FgzjlmVpd+RpYmTJPJff+h3Ah9Kzy98
         JcAKm8IpsrSrZM3wRld/+ufbs0FsloIN8tvZuvXAWNMy6d1oPwkGK7VYJlf/IojtDJnq
         Sufkm5sulUg/brtK8zfpz3zahpRlyXKN0oy8AObehVdEeRwcTMs+hY8NUsM2W5qgtBV2
         +01A==
X-Gm-Message-State: APjAAAUL4WKbUGHhkaD45/aSSXJ7QigLhyJL5i7W4/6sJj07slZYk5B/
	O96bH/PV5/eTKX0u78jw7X1Qgxvd1y3hFwtSaNb+cWNrlw1VeOY7U9y+2t9crcBD+A8cRjLx5Tq
	mgK2t8uVN6CXd7JKCO0GPZhjMcy2EYxPK7aGj/gkjDukY4csTwA2b2RKmrQfly80=
X-Received: by 2002:a63:de4b:: with SMTP id y11mr18605352pgi.301.1560264106605;
        Tue, 11 Jun 2019 07:41:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw13bdqDX15EBXBNm/KdermuyR792R9WFHY5jxVZPjOarvnubVY+SnNmxvALxJ67bxHXjjs
X-Received: by 2002:a63:de4b:: with SMTP id y11mr18605306pgi.301.1560264105746;
        Tue, 11 Jun 2019 07:41:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264105; cv=none;
        d=google.com; s=arc-20160816;
        b=ToLs7Lr/PCuTOnqqJRCw1dMauWHOfae0hE52MOphVycpY/K4Aiz+/9G5kz0DZyT+ID
         +n6zHNU/81hSNmTE1S7v7dAcMwJw1t15GGDzIITjOx0aG/7eHTL86YHRTn+HzREyA6v3
         4j6ff4op/Oloj1VMPY1wbPs/K6/2N8seY7peXvmEmboWh/UpNgmEj/3sU9wQUcGDioOb
         wTecTlUDUg7tzGnMz2oMG8LBPXVBAG/s6tOngVaN1FfaLKveS65pxVzXbbaKq4wKk7zB
         E3mK0kVYww+BW1piu8uPsO2AcZlF4h9zvMAwCriI6jfzkdjrDWGgB3fPvlVV/TQ0v6Js
         QQPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NpWcgZzp3PVAHx6KOALQeB51c2SoNPG0lnYZA6y2f1k=;
        b=CYxRPhRhcwQgR+jOHoTKGt4InchWfSklsBlh0fv/naJSaa27xnt7Mu+IPuc1CigTYm
         5wHmGbCC0F8jDc8hhSig0L7kSpP11VD+tjs3I3paWnkvL01QS+meWtpI/9fUHqkobWR+
         otaJPFy8iyIw3lkITRmTHe5BvJe9IhKjkVwDsWuwNJcwQDMZf+/O2BrRGDbjFTzDUQEz
         FDMV9ljsx2KbuLBg/LmldihIpyAZ0U+kiFOvJOe8AJKVCZnhHtUiPA3LEYec4UcfaqKU
         Kx9LYucJiNB2WwRP4F362c5yy354st8Vj/lv5WAevcpLVy3s4hFnlk4Izew6+54t92kw
         42AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Elx6a7oB;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p19si12208760plq.47.2019.06.11.07.41.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:41:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Elx6a7oB;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=NpWcgZzp3PVAHx6KOALQeB51c2SoNPG0lnYZA6y2f1k=; b=Elx6a7oB+cG63hmgYxilqyyn8c
	41Dy5+a7mSEbpr74nkmh4p8U4+Csa9fSuC+Gn2NIci0h+zE1AJ2oCVBGO13LLiFb0b5dtSmQVG46v
	9u67LZN22/J37Gq6Pw0EdVcHmtYQmz4D+jPa3xzMxshR3N3w3jFih5D2yKc/uCU1s1tzAUO98HmhR
	Eb4uYc9Q63+/RNoh85FinfAQMq2GbkMiPqDoguuctm3ABd08mxoDvUh7pRodjX/6Qrk1P4MO1lvCS
	cb+WEkPCrmQqVuObuLcxvqmcclY+k9OvtBq6GcKL8ErofhZRUpsV0D0m18ViO9NmB/7DHIAQrxxoM
	YaFeTNdQ==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahxi-0005Q5-7q; Tue, 11 Jun 2019 14:41:22 +0000
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
Subject: [PATCH 05/16] sh: add the missing pud_page definition
Date: Tue, 11 Jun 2019 16:40:51 +0200
Message-Id: <20190611144102.8848-6-hch@lst.de>
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

sh only had pud_page_vaddr, but not pud_page.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sh/include/asm/pgtable-3level.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
index 7d8587eb65ff..3c7ff20f3f94 100644
--- a/arch/sh/include/asm/pgtable-3level.h
+++ b/arch/sh/include/asm/pgtable-3level.h
@@ -37,6 +37,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 {
 	return pud_val(pud);
 }
+#define pud_page(pud)		pfn_to_page(pud_pfn(pud))
 
 #define pmd_index(address)	(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
-- 
2.20.1

