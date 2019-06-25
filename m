Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1A36C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 707F920656
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:37:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="J5if1v3z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 707F920656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60BA68E0003; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58F8A8E0002; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E7DE6B0007; Tue, 25 Jun 2019 10:37:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6D8D8E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:37:47 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so9297528pla.18
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:37:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+0/viyEOzdJ4g+CLfsqZmoPceslPqx1tCvvAPI4dyzQ=;
        b=Sgvm7dT6zTo+7KiBykHjDYFZh2t0KSzxpfgMLNp30mE+oPx4SbR/WyOo81+n+KrOqn
         D8jiRJ+mS+tf7728ukwfwNE6yq9TXCtOXG9PmlDFF/mC9BKl/FuWvf62FefJdIZEuzob
         qL7M6k41znqdEQy3z7/A6oR+wpP3fCIRew0fYKz9yhcVRTE8z2pFH3uJDeBh9sVkqsv+
         7OiemXO6XNX/wddHMKAuk5HKuX1PKQwh284WiNM0+YTZ097xWsTRaonbis7dSlp/FexJ
         /S81afzDIU34yvYQXj8Fh9ymUtwp9OJvCypWWOb6hp7bWFGx+eSaoqR7NeNdjozI/26x
         oGYQ==
X-Gm-Message-State: APjAAAXLJV3gOy9SuI2/m8DC3D1y4sQSGY1gLRUAXCy8GoDMmVbwngJA
	CsJWyUvV6aE/Iwxxp44R26ziG6NRaEnTOWNUzy2K24z0vBxvT0gnnfRfoN/XgbIlCCo3KIDqsG8
	vC75kTs2mQ9GBW5DLGabffDHIKCTLaHdSDzbz88Y0yTVHFieO8FP3INXlRPmOGm0=
X-Received: by 2002:a65:5c88:: with SMTP id a8mr9738684pgt.388.1561473467448;
        Tue, 25 Jun 2019 07:37:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3epuuMYCLA2sSnDYsM0h+l6D0ops3w1xrx2b9HthgWz3PsO3gjEPCmuaIVVuXzmOMbmbG
X-Received: by 2002:a65:5c88:: with SMTP id a8mr9738612pgt.388.1561473466563;
        Tue, 25 Jun 2019 07:37:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473466; cv=none;
        d=google.com; s=arc-20160816;
        b=MGk9Ii9YS4BJ3VciBWY1CdfByE2AI1OSnBXkFc7GhvKZ9Si0lc2fHp0aw/47eKF6ez
         0mPgjkgpAN8ArDxLGfIMAIiO6cA/HLCR65nkiJpJLGbLYia48u01b5vOMMCyfn8mbzQ+
         6spAl4/7OEiWUjPchg6N1l7Kx1A4EM4xK/RPdMRDSntebRo00DJzhp/ECFkLsJy7Xt7A
         6bB0Ohf4uPEVU2bYkCvUK85YYARYMp8ySQhVvNLVEKK0wZPafV8HueCARcYR8UfMNRF7
         TcFzcOklTLyfNQAQHmPBZAPVzs0rJPWtiuGLUMhWsynKh0G1gk0ZdhO68zk4WnynBs6y
         /lcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+0/viyEOzdJ4g+CLfsqZmoPceslPqx1tCvvAPI4dyzQ=;
        b=QU5v9Ursf0oZ+xx0iO4JcPC51z74cZ7gMVMrGXVUnzEPQ0zFlfVEDooKgogSi4vn5T
         Fe3Deorz8RGXFrquNwCk94xhOJYGoq9cwFK7XSelNhxACsAkRIlaXFCiHVmw8nsHgWl1
         Z06by9sNBmmaO6nQPe2cwe/s83feC3vAYJaVJ8pEf06TwJxZfIZ6STr3zL9t5L5SqjiJ
         0bAHodB54NLvyDJcBsXZQSdGUSuXgPTw+4HXt/+CN/NqhDu/urVAqx/3qKhEu282dK3b
         MgWhBuYDKUXQ2GIkhCxODVt9BwRzcrulxg2u2m5/Wj7W+afLl2S8rhGYurPke1248U5S
         y/jA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=J5if1v3z;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t130si9086449pgc.237.2019.06.25.07.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:37:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=J5if1v3z;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=+0/viyEOzdJ4g+CLfsqZmoPceslPqx1tCvvAPI4dyzQ=; b=J5if1v3zcVM4I6x+2c5HtP4Bna
	8Tefof1zgp+1eNhi7Lj/fWmEE2wW3rI8O4UbbH9ZXb6HT9QkCIwWaDfQ8VIjokPGOMCr4mTU7VKC3
	BDJ9kTuu2kMvLojAus5QH/0IZbOaX5UCvmyn6bQTIZDkRfCnABq3kui54EXCrUdecIPX1UjtuoJvk
	Jb00yuChRKvnfiSIvznda80OjYZGtraH1c+tG4xnPe3aJsyDJn7b+bxmvddcgwCNaZFotzFXb39bC
	IB9Dsngi53dguMdFaTUTcWZoQBNLbeV9ShycGEu2VkmE3PeGt9vtNUcVnJ2h/JtVajilfZH+flpW0
	eKQT/WWg==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZU-0007xc-Qw; Tue, 25 Jun 2019 14:37:21 +0000
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
Subject: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast addresses
Date: Tue, 25 Jun 2019 16:37:00 +0200
Message-Id: <20190625143715.1689-2-hch@lst.de>
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

This will allow sparc64, or any future architecture with memory tagging
to override its tags for get_user_pages and get_user_pages_fast.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/gup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..6bb521db67ec 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2146,7 +2146,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	unsigned long flags;
 	int nr = 0;
 
-	start &= PAGE_MASK;
+	start = untagged_addr(start) & PAGE_MASK;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
@@ -2219,7 +2219,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
 
-	start &= PAGE_MASK;
+	start = untagged_addr(start) & PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
-- 
2.20.1

