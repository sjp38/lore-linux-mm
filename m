Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82FF6C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48C2C20896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hksldD9H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48C2C20896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCF936B0007; Tue, 11 Jun 2019 10:41:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7EB36B0008; Tue, 11 Jun 2019 10:41:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1FC66B000A; Tue, 11 Jun 2019 10:41:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 892FF6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:41:43 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 5so9736714pff.11
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:41:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pU76vjF549TgrGMDxTP+px3yFTf1TEh0R8Swc6QhucM=;
        b=XhUM5VkqUnN1VTnthmiMaoFTI5oFyf9dpV2iXTuVVmEt7Sx4iioUMrE54/f9vQc1hm
         8CXWn9HYnKPYw9zG6sX6lkIt6fIUz30QCNRU9qVyzJT7MHfXEC804WRJxp3c0plTdmYe
         HO8P6j6dnCaTEUWKCARgaa06RqNihwCRES2jxa4BduNgLidRDeGoyQFKzURxXE1kJ+X9
         yrcsdlkuRVBNdLwfxnOiJHDdgEjyOFHBrRntUr5kzAHtc2r2J1F1Cm6pKx6qyR68tc9U
         dKGNFhPyTf+USgKQiQEqIP7MhyX1V1CdVbMxbZlntSqap0O4SH42agwa7iwurI17+FLd
         me0g==
X-Gm-Message-State: APjAAAUc8gC7Xa3JVPqLGWGo5gIjRTEfRE9JGkSDPsvk6vrp+NmY8f9P
	RR66CCOLF1SQGPyKa32LJhyHBi2kS2sZpd71RE8iy8LV3riec+dPFFOzNkkW6sXT3yj1GfNO4Kz
	RchDZTqBES0KVE4IPxPuHdphiAjCjt8tzyVN4Eq3DvWyWUk/SETJuelYvGG2X37k=
X-Received: by 2002:a17:90a:1c17:: with SMTP id s23mr18749841pjs.108.1560264103220;
        Tue, 11 Jun 2019 07:41:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbI8iYRVP0fBBWnC/Rt5tnvoj++2vzH81qYDM+MKszsgEpcS7M5KgQuPlxV2ditXRqOXZe
X-Received: by 2002:a17:90a:1c17:: with SMTP id s23mr18749788pjs.108.1560264102278;
        Tue, 11 Jun 2019 07:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264102; cv=none;
        d=google.com; s=arc-20160816;
        b=Jyh5j/Sq7HxZpwZ1SDxIbNbCVx7CYSTADN/I3L22LxGzrw7L1GrNNch3DdxHlNa0uf
         ESyCluOwsdgobyq9+mUuwEBWhl1VGo98zAx/k3EI5wW6RiO2ho0AihttH8h8FYQugPV5
         /oKRwdOqnEjmUUN5DuKTvtefvE6RMkU1dZcaCoA5h1nye16tEr+DjzEB3+AqqmyrhAgM
         b+olm214nbFlVRpCwMYs1piUCXQaf0cZPMb+tzs1d+zVWG3ZuEvKS+gOh1l8Xl7J398r
         tr8an2fcsNn4r7W4RG5ZtUDOIOfK+pvIqXuioi1hj8OSCQxWFBV2lrIRejxF0I04duTG
         Npuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pU76vjF549TgrGMDxTP+px3yFTf1TEh0R8Swc6QhucM=;
        b=CPPg1q/mw5mROQ0ehxnBIoT3L6eUWXnwcchd4eXfKLm4RweZSJpFx5yN985xeL+lxk
         /1nituZTuXW2iaS2hRXTpNQeINZ9LbKj5lamjV5JNyJOzDAH1wQQAlDU/4XVwVv1HmVk
         2yI8PLq6pjAP8gyTz7O+jyT4xmPxFmd2tXu86nRFmX2nDjYRCLT2hZWoNsYRLIBlwWt+
         KORCuO2fGYZdAdFj6PmnesqxZbWKQPsP31C+UiMvXUFNj/9TtCvmrvxT8qBgOD6/bdxd
         v+nRNI+qdtzsOVMl7fmMJpiGCOp+KEsV3CAauWq/8KAfCfk2bZsjngW9CfnPdIx5i/Eh
         3M/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hksldD9H;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z12si12200049pln.207.2019.06.11.07.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:41:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hksldD9H;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=pU76vjF549TgrGMDxTP+px3yFTf1TEh0R8Swc6QhucM=; b=hksldD9HOj5evI3EEsvNNZserQ
	9QfL5wF9gT7egY+bR9UULwLlKaDcw+8UV7m2/8Nx0LXz3UkxV9NozCDfZ44qqcS/1MjRrVmQH691W
	F+pa5IeoK2lMHw7zdweUhqWjsXhgXBNiVCgccTrkGw+N4DTtTTb6rdNpAcyxs2QNryR0hJKmc2s/b
	YhzCLeQqFaGRjbitn3ZJ5vYl9VFojSvxwCaSFpt+Sy1VKPlpBJYsDKNs5rLGgMg2fBrAGZ19Pbgp0
	SeqyCW789tSA3PxnOlwKgzjeyFyE2oxk6A62waWOoKoHh27uuHpxZYxoZuPf046XmMbKVyOakaQh1
	ZCwcvfmw==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahxV-0005Nh-VL; Tue, 11 Jun 2019 14:41:10 +0000
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
Subject: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast addresses
Date: Tue, 11 Jun 2019 16:40:47 +0200
Message-Id: <20190611144102.8848-2-hch@lst.de>
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

This will allow sparc64 to override its ADI tags for
get_user_pages and get_user_pages_fast.

Signed-off-by: Christoph Hellwig <hch@lst.de>
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

