Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0579CC282CE
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B43312053B
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VM5E4vpT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B43312053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E9516B000A; Sat, 25 May 2019 09:32:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 799506B000C; Sat, 25 May 2019 09:32:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6619A6B000D; Sat, 25 May 2019 09:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0B46B000A
	for <linux-mm@kvack.org>; Sat, 25 May 2019 09:32:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g38so8176264pgl.22
        for <linux-mm@kvack.org>; Sat, 25 May 2019 06:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZZFtwSDsCxtgfQbz1NVsc2BkUdN+ilOhDT8cfx+4H9s=;
        b=qzXkxiq1XQPOFipJzYOltqf3xnrWZKhng/Rlb0Ox3tdoA5HXkiDHPn41Zp4boorlUz
         W5cYrjbS9tCdIPgXxf4OfYzkAaqlWaLGYwA/Ob1UvdiCW6NxPKelnxDXjQZ2ieIiBIXv
         r1t0ye1eaafPHa5umWPhNI3lay96r3SPDWfj7VpWgRdEFsNS3ehEOA38M5/Uy+Wbs6bP
         exA+J9zqA+GWZhKPeK54Rs+t+WOllS69G8610bS3MPPpjsehQPgzmQ86Wjbrts3oEIMs
         0D/oTrOzmdfjhxiIiU1AbRlrc8k5JL/MNuH8ucUV6NYBewGUGdaUQJxda5KVNlgETSjE
         zaEQ==
X-Gm-Message-State: APjAAAUIeBvokBQZ9s12iq61tyyBforOsIjOsKw2+Kyt8/d+mLUIyNHz
	DRfXG2ctWhbBVg6hm5l2jotLZuSnB6OqPrnsnr89v8Ky1BZALh1bwbhi6aELQbiRgcYFhaSIyq4
	SJw7xN0osWJWbfQHoARwkpYYmobbgfY+IBG+9po5wZHYzrgDSq4UxmpXM0TTlaXU=
X-Received: by 2002:a65:4283:: with SMTP id j3mr62565133pgp.88.1558791147593;
        Sat, 25 May 2019 06:32:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ8hv7iMMuCyXw2OFbx2o57gxrDPIr5mwgTXyWyUq+gvgT3DsBKyhGO3FfItK4k6szctBB
X-Received: by 2002:a65:4283:: with SMTP id j3mr62565061pgp.88.1558791146882;
        Sat, 25 May 2019 06:32:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558791146; cv=none;
        d=google.com; s=arc-20160816;
        b=M3sBCPqKNWEJd2ijGvVNJBRi8l3t4jYETIdIJd4guBXKCrDaSv5BA02yjNi6cgig/4
         SYQemlpJVhjxyw0rAyG1Ho4yRHKpQtUXkMGfUw/4weg6lpkNQoa6jrZH01LAl5RzIcxG
         /PEvbeUww4fTa8piKOrEtvtgeP7W95jzLNtCCG8ffMf/gYSbXTqhLjGO6ml7531GCdoc
         2mZNpCRK0NvhyhEFcNhpzUgQuR+M9Rt1rAG0BcpminPpB/2FBDiwyEfI45vw5S9EsIed
         qknHEladapeYjIbnCzZ3zfbCkWTXDAU7Dsn0TqQZ3Zjtx5n4t8GpxsRNWajNB/vWI2Hb
         lBiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZZFtwSDsCxtgfQbz1NVsc2BkUdN+ilOhDT8cfx+4H9s=;
        b=GCm/W53BLjN11H1rgEsw0zt3//W++oICoP33XHbkKNOSMtScvylvrCbSc7uwZKp8jG
         fbtAhmtJF+EQK+qNEdUwca6LpX86soNNrLg1aR5PT6Pb577K0llZeNLy/0xSA8d08UKV
         GxNxqWLuDKCRieDUJi2zRgaQ8gPCJvgdzs0BF1nhAq3O8S2HoC7fPhgltLEhL5KB8esP
         vD/Txd5OYrVznZnZFczffdmyVln74sYYBSUrCN0iECGkCGGj985gXqcG2doclredRZ5L
         Fx3ZKcC6yT6esPpkry9v+vWYrzutZhrWaYPXi+MACxEbXBaK0S/hRGSPtQvdFn5fKWSw
         deiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VM5E4vpT;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f3si7860766pln.263.2019.05.25.06.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 25 May 2019 06:32:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VM5E4vpT;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ZZFtwSDsCxtgfQbz1NVsc2BkUdN+ilOhDT8cfx+4H9s=; b=VM5E4vpTn++p7BaTgkSkUBiAzt
	NRnjC8ZNu8X/cDDkfV6bbNpJmbW7HcUtMqwOfn2FeqjXREc9RiNmiqlWtH4TpX02YRTnYKwj05C4D
	JKhk5CRR6/2hoitHD7DlPO2IirGizW4A4JV6JCkwCP4c7RmZlIthUVht7mvge28qUd/pIQqpQB5ou
	cvYSNKb/2h2VN46bf2aOHsEhctEOEpiBFR6iAxdjfpJtVeCvuPjiVZ+/CjCba/VaDmPmn7fxuzNXS
	56yR+61NCh4bxS+udPq3SmlYJ2OW1kcwKXqY97Kd3FBbdAJLIkLE6S/tkuVSQcqpOAeI9kfADMKPW
	DZnAnLqQ==;
Received: from 213-225-10-46.nat.highway.a1.net ([213.225.10.46] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUWmZ-0006Yk-2b; Sat, 25 May 2019 13:32:19 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/6] mm: add a gup_fixup_start_addr hook
Date: Sat, 25 May 2019 15:32:01 +0200
Message-Id: <20190525133203.25853-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190525133203.25853-1-hch@lst.de>
References: <20190525133203.25853-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This will allow sparc64 to override its ADI tags for
get_user_pages and get_user_pages_fast.  I have no idea why this
is not required for plain old get_user_pages, but it keeps the
existing sparc64 behavior.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index f173fcbaf1b2..1c21ecfbf38b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2117,6 +2117,10 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
 	} while (pgdp++, addr = next, addr != end);
 }
 
+#ifndef gup_fixup_start_addr
+#define gup_fixup_start_addr(start)	(start)
+#endif
+
 #ifndef gup_fast_permitted
 /*
  * Check if it's allowed to use __get_user_pages_fast() for the range, or
@@ -2145,7 +2149,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	unsigned long flags;
 	int nr = 0;
 
-	start &= PAGE_MASK;
+	start = gup_fixup_start_addr(start) & PAGE_MASK;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
@@ -2218,7 +2222,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
 
-	start &= PAGE_MASK;
+	start = gup_fixup_start_addr(start) & PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
-- 
2.20.1

