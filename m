Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4460FC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AA29213F2
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uFiSP+ha"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AA29213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B3A48E000E; Tue, 25 Jun 2019 10:38:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2DE88E000B; Tue, 25 Jun 2019 10:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B870B8E000F; Tue, 25 Jun 2019 10:38:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0088E000E
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:38:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x3so11786306pgp.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BYP6NRhV0e06f8oIenPFc4bRzhQelZlIe9CTAxSMrks=;
        b=YyVNLxRCxXyUve+JfJUDmSLwm4MGo52DazFaju1CMuWwRhAk4WxA+095lJ9k4ZWcir
         GHXqldvDa2oaMp7dz9SdkES36lpqLJ9L9Etj1A0ddSSR4S7RpnxKVlYLky434d6IGC8f
         zTGVriH9DL6hsTE6FIyFQMv8TvxLvNlezL5Riicz36DEfwziMGEKOB0MY7l6UyD39lWz
         dU2IAX+8rjWHCY0KjJ0dtgq9b1kR7gbX6+gxcRVCDH7qtCgA14tl3XS/4WtMy202G5nL
         9ZC5eI0ScrhQI1T+JO/VnJOE9sl3vdtTX0t7ASniuRhbvVpF9aVcrDPDYgDXjlL5h2Ox
         /+kg==
X-Gm-Message-State: APjAAAUUgPrckfX9VIlJM5sYk7i0/8UUc7X2y34Rn3i2bImRNL87ociV
	wlPFdhNSH4emSku3lubO+km/i2Ho8M3DBzN8aSct1yDuIiPfejFiWpll6E89qIyarFZstf7Yn3A
	i0k0mmHH+3uA3zYlzfdjnfQY8IxpVTyHyrVjIuXuksUpk9TrKPTQybhLQuwiINrI=
X-Received: by 2002:a65:5c8c:: with SMTP id a12mr8033738pgt.255.1561473494918;
        Tue, 25 Jun 2019 07:38:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2VWKIzSxdVJbRd/VrY2Y6yJTXFfbT/vRFv9rZGegPGmIzdQ4DQ/JiiQLDshYcGoBUIo67
X-Received: by 2002:a65:5c8c:: with SMTP id a12mr8033691pgt.255.1561473494198;
        Tue, 25 Jun 2019 07:38:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473494; cv=none;
        d=google.com; s=arc-20160816;
        b=EGGq8pqZNOkCi9z3Smb3hmcPjs8tQSyMtMroetKXrCXGgK71lMZvfnKQ8gC1dHz/H/
         7WsLdU9ks0gfrWbMSLSXxaIeuL4SWHYNuupD1NlKKnBmh5GiqL5dlLItBpNWFx1G+D/Y
         FlTnwoDDFpxgVcasvC2H/s+tAkxTeUw2xtnhtURdwTrWuDWRTu8k3H5ioMhJqj5j5SIb
         eJrQA/EzJjUljYeYQ7x8aIwz2Yz9mDWp6pqkThDLWToB3ZMj8Nyy+5bE/f9hE0r1xGng
         3XIShCJoXPnK0ffQw6dcFz5p+EGbchGmnVqK4KDEvpyfJu1C7AOL/nb4dNw0gXEdJ4qn
         Z8cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BYP6NRhV0e06f8oIenPFc4bRzhQelZlIe9CTAxSMrks=;
        b=y6iC65xEHb7v+fo+5zW8CNNUqOysBtBezsc8KQDgRMAslWeWRHQRojDxR/AUaYkGhO
         Gu32gotJnSHq6NYA7UMw4AOqKsYbgDJ2zZIwQ4zYB6Sr0DD8yLrn2IJNN0I1lzPpIkxB
         PElxkixmxSdNTYTxDVN5eFOVEPJhRZImFK/I1KTWJoidZ3UX5RNpEletSf/P8I3wQ2Lr
         UtOfZRjxKRHFvPrAhAhZOnnUjROzXMBxnhoxlm1YXNyRzE/hVNfnCrAccBRasMfdIznG
         OiaGFABJInCDLmQfetfXRZGG45bIkfhUcn9417y+G+m6KFy3mzgpeZZWT81ZDoK3dEnU
         x/TA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uFiSP+ha;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w10si15301533pfq.115.2019.06.25.07.38.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:38:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uFiSP+ha;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=BYP6NRhV0e06f8oIenPFc4bRzhQelZlIe9CTAxSMrks=; b=uFiSP+haMlQEluFE+XcjFUp0bx
	Xv3+J5Oj3rSXey8kF+/LAwYTXrEwIJB+jJl+6r03zjdzwjVRq+VPnCinGI1fmoEMogJSdLZckr9AW
	XAp23xNpzF2yS1/kPcFDnnRqaX+7wXBwe/7T4cRzngX6ulUf8SAAgu5OVQ2jcWGEuxLz1SDp37tGa
	kOGooG8awv44vL8CYgScJv4OW0UHallUueZhZqIE8tpFKyw8XyatY4V8eI8toPbxmMkYCrMZhNBtv
	3mDNcF2l8cOo+TOQPz1NHnnGn6/ghuBcsA9XRX5JSZ+n8GsK1rDzd7uLbuD+TO1Y3ycQD7r5lehfI
	DSTaEKdA==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfma8-000858-8p; Tue, 25 Jun 2019 14:38:00 +0000
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/16] mm: validate get_user_pages_fast flags
Date: Tue, 25 Jun 2019 16:37:12 +0200
Message-Id: <20190625143715.1689-14-hch@lst.de>
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

We can only deal with FOLL_WRITE and/or FOLL_LONGTERM in
get_user_pages_fast, so reject all other flags.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index 0e83dba98dfd..37a2083b1ed8 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2317,6 +2317,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
 
+	if (WARN_ON_ONCE(gup_flags & ~(FOLL_WRITE | FOLL_LONGTERM)))
+		return -EINVAL;
+
 	start = untagged_addr(start) & PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
-- 
2.20.1

