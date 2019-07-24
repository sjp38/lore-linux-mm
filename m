Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EACFC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42B8620644
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IDkGONdX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42B8620644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9A0F6B0010; Wed, 24 Jul 2019 02:53:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E25448E0003; Wed, 24 Jul 2019 02:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D10288E0002; Wed, 24 Jul 2019 02:53:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6E46B0010
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:53:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e25so27913777pfn.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=igXh/3abv0ooQdkv/Vfc/WSfVB4lkdoSYebCAR1TL48=;
        b=m7c/dgvj26JRHK6jE+GfbJaO70YSV2c6Hiqp+UV93aecJbcsaSKjyVScHRW4OLJlFV
         BWkVNU6cPNBVOzEcgk4UaZ8TKsWByTDP45XMVA6njMRA2pNH7XQqIR6uF+CQOp1BPSq3
         ALWiYxb/UqtHmC5ZbSdFw5oDEJ70eYFTY4fzBzPt6m/9sXZx/PUJcpZoH4nvPm5LRJE6
         VUyqQSPimmRQ+JNpUERZ7hLXhzk5q33+xEkp8DCw8o055KSvU9sjL3ckfqdncv3onpQl
         R9voDVGFi3yUDeVHxvC+U65el3dfNKfpp49U4G5BCqXDtLw3vur/oi3LSiYPKGnf4WQG
         RLrQ==
X-Gm-Message-State: APjAAAUF4CD4/rUB4L4A8wUOnpZhYQBa9SZQpdp3Zlj5a2gznX07P+rl
	G51HXuZ3yRLDEk4oCK5nFIlcn1Sp/GOxbA4N3fb8cNlRrzKnSmKkqPzJR5ytAZTSusObICEVErH
	VyMo2qN9GTSAQ1oRiIkb6kA7XXCmt/ry66/dUzfwMwYDqseEeQe0cECFa7jSXBAI=
X-Received: by 2002:aa7:8555:: with SMTP id y21mr9791573pfn.104.1563951200219;
        Tue, 23 Jul 2019 23:53:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBWBXNfOg/EvdMNTRgA09BKpvdpDhCu7oKijxsT1UMoYORPULx/zTnzMYzm+vKrZDouttg
X-Received: by 2002:aa7:8555:: with SMTP id y21mr9791539pfn.104.1563951199583;
        Tue, 23 Jul 2019 23:53:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951199; cv=none;
        d=google.com; s=arc-20160816;
        b=EeR4Vq+E90yANJFzd2jnIn+4WmN/c1ar0pOH6hukcdHHmNMvf5mYiXQe826iRrAAZq
         7eewcjad6skty3Y+dYLkAqHcLICyBs+1L/crn6mzpDRsJNLoEg+EHoJ1nwMk6dGkg8UK
         AmttsrNitSvq6DqK85hXhHdA7spt7youLp23tV1hzxXAo8TdjMnwD8j/Z1HSu53tob6N
         5VQhrf+hOG2wVO6m3pUEX+xAwRBlPhKSymg0w4KAjcy3mtQEggv8Rx/TidVRVATOEZj5
         YwvD8UqAgcXPB7jtf/FR1TH02l1L6x8lALGWmS4XiB1qDJ9jz3fBI9Ew9y0b+h43D+Ll
         qJWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=igXh/3abv0ooQdkv/Vfc/WSfVB4lkdoSYebCAR1TL48=;
        b=anOe0OiW7hXM4b6WI41FO5X3pyAqxIa/i9KDC7f5gTfZUpt/zvHRplPV/RY5EVGTJg
         t2fCZNNdkpkqRP94O7NMm55YEo8aN/msF1h8XGPZZXh4fxFccnoHH6L9kEsrjuE7d4hU
         /gyE54EIJ2NVVhiJn6Jkm24E5K+2Yqhf9/ZduaBvq/HgbzDb8A3u3lc9cZGika5Td6X9
         IM9mbo/dajtwbB8rm/1KW7zR9aU3CHyOyWGDh1Lg2DSVnub7fUngv+KqriyJltV/fLSs
         GH33hIVj7OgbB7SjbA+tg7JBHGIs6qI+kVmHbMgVDTdMEcwdFQJwHFqDLpeoIYTnsy+Q
         q6gA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IDkGONdX;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d5si13166777pls.233.2019.07.23.23.53.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:53:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IDkGONdX;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=igXh/3abv0ooQdkv/Vfc/WSfVB4lkdoSYebCAR1TL48=; b=IDkGONdXpH3tW1oxhx++LkR9Lr
	WtaFZ+boWB9F31gk5CqaFbhNeFfrtl5YLLAPAezcvPdlRxacMmzCyuUcbJkfsIU6ge7zEVv6VK3Lp
	BVN8c2sSrD9gXy2zzFgQNQxPeES0fjs+kwg6uO+b6FRTGfvZoI4LaBGXq5SxfAg1diq5NAYBrGEmT
	LgBCFZZp8wWhbrk+FwzSlyBkPvD4HtkVG7f4VC7cE6HJ/umGb0LSiSUT67UWqJ0MlfM/eAnG+yM66
	VhwUGjcVxt/otVXADUHsEEIdhJYMPPs8S9yngWBDr8DsSJQqvQUpJqMoQJQ2kuAdZG+rSN7e5CHvH
	SlT6wdaA==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqB9J-0004Ko-0z; Wed, 24 Jul 2019 06:53:17 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 5/7] nouveau: return -EBUSY when hmm_range_wait_until_valid fails
Date: Wed, 24 Jul 2019 08:52:56 +0200
Message-Id: <20190724065258.16603-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724065258.16603-1-hch@lst.de>
References: <20190724065258.16603-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

-EAGAIN has a magic meaning for non-blocking faults, so don't overload
it.  Given that the caller doesn't check for specific error codes this
change is purely cosmetic.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index a835cebb6d90..545100f7c594 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -502,7 +502,7 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 
 	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
 		up_read(&range->vma->vm_mm->mmap_sem);
-		return -EAGAIN;
+		return -EBUSY;
 	}
 
 	ret = hmm_range_fault(range, true);
-- 
2.20.1

