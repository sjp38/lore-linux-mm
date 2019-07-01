Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19A66C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0B75212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iKEi8d7g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0B75212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1296B0010; Mon,  1 Jul 2019 02:21:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07A7D8E000E; Mon,  1 Jul 2019 02:21:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E382D8E000D; Mon,  1 Jul 2019 02:21:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f207.google.com (mail-pg1-f207.google.com [209.85.215.207])
	by kanga.kvack.org (Postfix) with ESMTP id A0C036B0010
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:21:09 -0400 (EDT)
Received: by mail-pg1-f207.google.com with SMTP id e16so7038893pga.4
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IzZcWaqQrWGdZeOcxQugf7n/YqC01MqphcLxaz0+wR0=;
        b=M60/jGbRls27D5/eYucR7XOF/3qyPZn488PwXwx6JiEogcjO7s/6do21tRQSvNMylc
         CUcvtOQztSEGTTtuLDWJf78XWAiNdMgzrRvYXdxPMcsKUAdNyzqOc0DI6qxeJdRiRrAV
         BCT73C1wb2Ob3ilSCEyqzo/huQAuxnfnloPS1cxWRuiUpv52r3HKBv/FySDP0d0d4iGj
         Xdn3IiLIoxCsrgeWPrJOgUVPZAj1uJJsSacduiEKlIveS6y4aZLBo964DAUMZX+amr0O
         OGjmeXnAjaOfgP/o56Fbbg8pjMC3sHDbwnu7xF0SqWMPoWi30MnE5q1X/zAPzmymuuN+
         Ob5A==
X-Gm-Message-State: APjAAAXGP0VBpolK5kOPnFELYESdlkCJ2gGsrtMebVEzPuoBBEW9qZAm
	iUag8hcMftN4jYmoQ2bGG98cdpUL+fOwSdSAYoiyX4SJRR4nZH9c0EF3uLdlG1cMnptdSuV6SBL
	8GiIMrmvAsHf+MzeJBso4niTBwbYAZQMQpty+lOTnJRX6ecNuHaWOTVjdqLfD9jE=
X-Received: by 2002:a17:902:a409:: with SMTP id p9mr27420982plq.218.1561962069336;
        Sun, 30 Jun 2019 23:21:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5Q0DzgvLKt9iPz/dGG/cjFl8deSRrULt/llfivASOIbwBWgoLxTVWotJQFYu/ShF4F0pC
X-Received: by 2002:a17:902:a409:: with SMTP id p9mr27420944plq.218.1561962068649;
        Sun, 30 Jun 2019 23:21:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962068; cv=none;
        d=google.com; s=arc-20160816;
        b=R6gkUJD2YE8jCQiG4kF+f6OYhZV78w2hI8EeWrch3WwQE6f2jUQ2X5oCqIsATEPzEI
         EuXOoxGDPRGX+jU0Gzty0KulbjljNjjn1/TtGOOolmHwvLg87D+5WK9m8fh5M1qf7Yhm
         hONHKepqMm3/9EXmLVFnmo5spWq8njgdENsFsmkDqwGHfcH4cHCHVYze7ocgFPOKE4aN
         /UAqv2j6tBr+VT/clFa0dCVU913jgVKicD8wLZhkAQFKPZZOUI7XwSxm0d2mIbM/MRyJ
         vO13nyh4wRPA3QHEpUgCcpcIh405w9tyKzzDfI3ULMxmoO1jvFZfwYMW0fO2On54XclQ
         WRsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IzZcWaqQrWGdZeOcxQugf7n/YqC01MqphcLxaz0+wR0=;
        b=zBaqIXIkFUjmXtCVuR9NLKyoCT4QzK1xTxmTZEshKQk2/jX2a1zVdYaeRJ9Locx8cX
         lEWOkulh58PZ0cZFc+rFEOrZESPzuuPrORcvwXJ/ZlnQaX3myycuIlwUt+SOoDKsQ0a3
         dNuHmjKkRt7ok7cj5ZNM8DUNLNx5AUKY/J/YklNL88eCQ0iKHRc9CyWAPa0nk0qji6XN
         Y5CGJK35u7FeVXoXWJ2mq8ZlpGvSV2kq1DTeb+yOBEkgNAzMBKW7eb7iunpVV8oB0M18
         ROAbc2een/Bq6jpbMTxv1jJCN1lwgl9wIktJGFB4UOedyHjD31ZKBJJmFjkMEwExxXOg
         0AIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iKEi8d7g;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l184si5117928pge.286.2019.06.30.23.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:21:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iKEi8d7g;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=IzZcWaqQrWGdZeOcxQugf7n/YqC01MqphcLxaz0+wR0=; b=iKEi8d7gceCqjmsj3y6uTQglI6
	NtyilHlo/Z3cOVWCQphycuVqQ9ZQEAaUmLuPbPaLq8x+TUQ4nPQItVtJhEJtMCQJXUZZyE10291/3
	/dabnPYnGrVGTga/rAs5SVW+jf9uVsAeL5AaxVeQdjMWxlyZygrHjfY498GAHgBJlLG/qdbo7Qntr
	l/rPVwz9p2HuKbtcYVxPcUdGtLeSCQZMVE6Ev8BYFiKy+/6rYLpa5KX6wp4Uhe+17QegQ7nBpRiaR
	MLNX+XmpbzcP/dTJzryRXIqgDprZnE9ZupEE72sMJwkCLSY4so6Z5irk7JglSSP6q8vxZyFsiEJ/m
	AzaC/mig==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgX-0003Jv-Ab; Mon, 01 Jul 2019 06:21:05 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 19/22] mm: always return EBUSY for invalid ranges in hmm_range_{fault,snapshot}
Date: Mon,  1 Jul 2019 08:20:17 +0200
Message-Id: <20190701062020.19239-20-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We should not have two different error codes for the same condition.  In
addition this really complicates the code due to the special handling of
EAGAIN that drops the mmap_sem due to the FAULT_FLAG_ALLOW_RETRY logic
in the core vm.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c85ed7d4e2ce..d125df698e2b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -974,7 +974,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 	do {
 		/* If range is no longer valid force retry. */
 		if (!range->valid)
-			return -EAGAIN;
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
@@ -1069,10 +1069,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 
 	do {
 		/* If range is no longer valid force retry. */
-		if (!range->valid) {
-			up_read(&hmm->mm->mmap_sem);
-			return -EAGAIN;
-		}
+		if (!range->valid)
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
-- 
2.20.1

