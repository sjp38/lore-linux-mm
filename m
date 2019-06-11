Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D30EFC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AAD52054F
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rr+6i7rP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AAD52054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CD716B0270; Tue, 11 Jun 2019 10:42:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78C356B0272; Tue, 11 Jun 2019 10:42:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6068E6B0273; Tue, 11 Jun 2019 10:42:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4D76B0270
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:42:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id c4so9234244pgm.21
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:42:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=92m0mWNJuHmY5cYpWlooP/cZgBBhq6eJcxducqZ88IQ=;
        b=sQfXnG1DGi5GuFLqAFXN9D5QUGQvHKY63qkuiIZX7iXRbBoCc+bIoB8iSNVXQ4+83d
         QrWD2Qey1SNBxJgahC/gf9kpCnDzFipq71hOQ4XA/E/8SxrZ3IrWL/EyDL+/d9AWLDsp
         bZI1YfxvgNdvtlSdC1yxSrpySCmyD49sdv9qFmy5qBixbxpXkt/Fp9orEToGXMwHVsLa
         p8mpAT6TsWIkmAF6XmTltCAkjw7vYdyGJiimzw+zK2O5jW6/+gKhUQ6OttLScBhtoFrm
         xkNxMJ0dFnvKTZ3k1EgyoK34HxyR2sljyd76kOZGmpbOA06+eImwjLY9+LUwgYSbepDS
         TBjg==
X-Gm-Message-State: APjAAAV36rvNQ1nNiFyFPc0itAj3QIcrD8B79g/ZuHqB3ZhvM75pS6Bi
	+5aCImH3FoaMubAMTVHNrz6sMu27PMCiD1kUqsoChGTrFbesSatt0BJSK7QTuweLjZBwM+8ij8V
	/kuv3H315pVWx8UJRoYLBu3kEdKhhWxO3z7ZySYot4x++ZpoJc7iYdEKbBDFWqfs=
X-Received: by 2002:a17:902:102c:: with SMTP id b41mr26759923pla.204.1560264124763;
        Tue, 11 Jun 2019 07:42:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxn8fNMBjGdsCd6hLXYQmC9bQNHNITey+hUl0xBGJvVN7L6KTVc3O9ShHjY6BJq2MLnoEaX
X-Received: by 2002:a17:902:102c:: with SMTP id b41mr26759848pla.204.1560264123871;
        Tue, 11 Jun 2019 07:42:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264123; cv=none;
        d=google.com; s=arc-20160816;
        b=OvSFj4P/YB7Lxc3vA/q/BIW13hmdYlxwprTVhx76XQ1nUMdo7noFlWpWAUo69Pd/c2
         LvpsWtHuuYASlAi+DGeFNn/BEyT6pD7piUvuSKznT/KUDJYjSBkgB4YYRN3/+rjsLVCn
         u5HhKBNreZTww/+pOSvZQGW2gzc7segH3YUwwwHIlkuFAOellVMNe/nxyojTgX7U5Tbk
         a+z1uI4TxbgVkvXSAUwisap3jBNTt7kYslOfKv2OK2sUQ7yCNVAK1UFJ4Ys5UuPf5eij
         viJq+4c05FNYUUg15ofIwHH5DYd5UyMshFZwf9/ypE8AtGqR5Nd1gRyGSMvMWsr8ZqxD
         +BVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=92m0mWNJuHmY5cYpWlooP/cZgBBhq6eJcxducqZ88IQ=;
        b=v+wYgyACUZ+NoDY3omQWNxZhAXTlyplTRr5sp594HnJU0Bjw/s3s7fzO6+VVPvYnJ7
         6AsSArWJ/YHgMClTQcSpRUKcYScLzvqnhESKsNeJLxIa9mq3Efh7KHItAj8UdBkU80YQ
         7x2lJbPQQU5U6TU5/DxSj2F/I4+hUh+E6WZsGT7ydbx4tVRQLczgB3JHO86zFT8TAz3u
         3aFWJcJXV4uo/Sn+u9uZNHWAXveldcgCGf34o8N6jwOhgXBt7o1p5Ki0Nh/IGrq0n3/F
         /UZlnbrHzAUR3nM+0hk/+oYluerx++B2AGZcOG31yjn6VNBSKd41cD2C86sPqsabTE95
         +WCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rr+6i7rP;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id gn11si12074830plb.119.2019.06.11.07.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:42:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rr+6i7rP;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=92m0mWNJuHmY5cYpWlooP/cZgBBhq6eJcxducqZ88IQ=; b=rr+6i7rPu5se1K/u84C05O1tdY
	GzqfoR4ThRZnBYykD/g3PZVO7wt8FMplFhvZc9xK09NnOLWoT3OfPdCMgF6j8idQ5hVx9Llo1V/aA
	gkylDbMT/JiY3hZo9qmZ7jM0kZrPGMqnbWcr+ylPSRBycRzfkVl6yoTaZ1ZcJXTyhNuZUVuhmKdkL
	39NSJ31ih14hQPhzjcZ3GtnHRqtmiZsoUO6nKeiz7ttH5Iuyf6If7xjguwIwAwHBQreLYaFo0nkc2
	q9x/QDp+b7OsLJTf33M2uFsaCD+JFkB+KMn94HytN+qVUEV+oOEb6fRveAy1MReAX/mRXtPMLUcHi
	LLWRbdIw==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahy7-0005mk-T7; Tue, 11 Jun 2019 14:41:48 +0000
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
Subject: [PATCH 14/16] mm: switch gup_hugepte to use try_get_compound_head
Date: Tue, 11 Jun 2019 16:41:00 +0200
Message-Id: <20190611144102.8848-15-hch@lst.de>
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

This applies the overflow fixes from 8fde12ca79aff
("mm: prevent get_user_pages() from overflowing page refcount")
to the powerpc hugepd code and brings it back in sync with the
other GUP cases.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 494aa4c3a55e..0733674b539d 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2007,7 +2007,8 @@ static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	if (!page_cache_add_speculative(head, refs)) {
+	head = try_get_compound_head(head, refs);
+	if (!head) {
 		*nr -= refs;
 		return 0;
 	}
-- 
2.20.1

