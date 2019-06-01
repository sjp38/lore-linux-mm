Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05028C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B74C024A78
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xsLahh6P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B74C024A78
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 591EB6B0296; Sat,  1 Jun 2019 09:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 546246B0298; Sat,  1 Jun 2019 09:22:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 457CA6B0299; Sat,  1 Jun 2019 09:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDF06B0296
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:22:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so6570969pga.4
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:22:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=t6Fl88iIFJgCuug/gOU/GStjFeTxMXWBYV9Og2AjAmc=;
        b=VjnIL79qQo4FvTEnXoCibPhp8BoOYi3YZMmhsA9eF8hVmky1EVTjA3KPbzmSVe+mhV
         oPrIq1u7kznj934n9XpcUGATA5u0AeBXLwy4DvTYnydaro0DbdwlCwzLwPuy1jr7rnsM
         6dMXQn9LVKz1vvWpUTImctAgbEyPzcwhK8y9wtqVXDqt7+/yLcIiHOFXNnRz6KxPE1TV
         2njrptN1dRYzu16yfKteGxr2Q1gIXUwfjQ1BM1YVtoM83VH/LQos/3z6OQJ4AMFK/a12
         3AHWLN3aMhUQahC/ou44oBJSiFjPA/ombf1jF8HrXsp4CKJ8ODoFjregn4uk0uvaK9kT
         iDoQ==
X-Gm-Message-State: APjAAAWvP3ZaIbzy2AuA7A0heTOX1wPJ1W2NId9mq1A1OCv4+sS9wN8q
	QFHIxfYJZGWqH9m2sYSbNx70FpOHPXxw6Xp0XDvakUzf8+dXjTb6dPCi2DEVK8LaeLlFqRU490Z
	1askrI629Pc/N+dqKRgvPN+KzTGtrG7NRPdQfC7CC4UVXjYzGJI4PLxLgMxhDoX+PcA==
X-Received: by 2002:a17:90a:e17:: with SMTP id v23mr15817047pje.139.1559395346713;
        Sat, 01 Jun 2019 06:22:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/PSSin/kts07Ae4gZu2cbyeAl1HQqB0HDCdQrkkXHN+upZLNe6NxEzRfAfOR0fEZKS3LB
X-Received: by 2002:a17:90a:e17:: with SMTP id v23mr15817004pje.139.1559395346168;
        Sat, 01 Jun 2019 06:22:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395346; cv=none;
        d=google.com; s=arc-20160816;
        b=t7v7CURf0VzFNhWNjGXk8P/HAQLKiX2OM7H5RacqlyZDWOrWHstj8gocryBgeuAXrd
         grjjKzpB+ZRP2Uv+XuWLtcQs4/fPi8ZQ6qUN9yzEzWId2pfjc9CWyHfVD7EzZys/GlTl
         TqMBjTpLYt5WeXlYUohPO30ROMnYrs1AsWg20Ech4+Mn5U23mk5AVIC4KPuH8Bkp7X3e
         u7jFr2SzevNkj/VDcs1KCXod1hnLl9jIqEc79M0YHWknLa7vYX+QCY2N6eqEaTTmA8Js
         yLJd49nqwNowlqLaC+Bd2eQJhIjITD6CZlXxNBGzFCvyCDdBagvcjUGgiP1oKOCvTULt
         7t0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=t6Fl88iIFJgCuug/gOU/GStjFeTxMXWBYV9Og2AjAmc=;
        b=mSOhvvEPw6fGhV+Qz6ODM3Ybvgfl4PrJawiMmiCHStuc/p0KzNM6b9q3JOOr2SEl4k
         w9Rg0MwR2uulBOxGah5mD9DB9Fs+API0Xwi9M3ljM3ame6w87k6cu0UOTt24gebY1FAT
         BaOaXZWs5zjnTkApkkiN+m0AkqLHO1qhti8GFb40YrcBG+99J8xrTXkqn5D/gt7l1Jx1
         eLejqu9c1vEPcpolrYNDinvdDAm09pC6zvmERZt+o0zHZbD9kPt0jY3ZbN+gca4lCk6k
         RKKLL2TXS/5BWsDctd3mAQnG+ssfQrr189VJBlTodu06QSl8LMoeCOGqMK9pDsQi418J
         Cl2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xsLahh6P;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 14si12507489pfz.120.2019.06.01.06.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:22:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xsLahh6P;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A742923AB6;
	Sat,  1 Jun 2019 13:22:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395345;
	bh=jxmY/tW9bUFHPmfZjN8lFuoueNpy2Exoj7rcWXAi9p8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=xsLahh6PG+RKpeyNPAfquNBIAnKB+FsHOueJYmlqOBGY4teDLqaiJcuURpUSRHXvg
	 ekcuESw9XvdjhkbgqcdPZHhTeZ5rJmYHiYmMutrzYQa/D0O+M/HjXstobSP/MfmiOG
	 2c9wOltR7JHfl22f9UF53OH6+O533z58jXEOdChc=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Laura Abbott <labbott@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 010/141] mm/cma.c: fix crash on CMA allocation if bitmap allocation fails
Date: Sat,  1 Jun 2019 09:19:46 -0400
Message-Id: <20190601132158.25821-10-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132158.25821-1-sashal@kernel.org>
References: <20190601132158.25821-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

[ Upstream commit 1df3a339074e31db95c4790ea9236874b13ccd87 ]

f022d8cb7ec7 ("mm: cma: Don't crash on allocation if CMA area can't be
activated") fixes the crash issue when activation fails via setting
cma->count as 0, same logic exists if bitmap allocation fails.

Link: http://lkml.kernel.org/r/20190325081309.6004-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index bfe9f5397165c..6ce6e22f82d9c 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -106,8 +106,10 @@ static int __init cma_activate_area(struct cma *cma)
 
 	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 
-	if (!cma->bitmap)
+	if (!cma->bitmap) {
+		cma->count = 0;
 		return -ENOMEM;
+	}
 
 	WARN_ON_ONCE(!pfn_valid(pfn));
 	zone = page_zone(pfn_to_page(pfn));
-- 
2.20.1

