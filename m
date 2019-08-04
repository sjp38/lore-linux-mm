Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8860DC19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E1F9217F4
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JnEMIs3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E1F9217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CAFF6B026E; Sun,  4 Aug 2019 18:49:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02CC46B026F; Sun,  4 Aug 2019 18:49:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D72416B0270; Sun,  4 Aug 2019 18:49:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6426B026E
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i33so45048084pld.15
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JsaN0a6ImilSblrGqgWWjtVL4aaUVqoBD3LMggUShuU=;
        b=R5NGbqvb7teFhDoZfj3gYdURXwnlfofmHbzLtt0sYHZXHUUithQMABpnUKFbFXrUuq
         gn3DoPvCHeuIgvjZXyO7+XFdjUidCEYU0iVQpzp2v2HSinsOrAMbvmS5xHCUV8ueUtKM
         UjCNbpX3Tzo9tK9YMV/zywAm3fl7nWRwX/lxf4Z5Pc84SnaamAbevblNORDUM7JSNzpt
         nvi1M2QhRNWXtvp0aj4lRnDlXy/EGdbFPrbbngqrFJWPtpVKJa+HBMPu6c/NyL7o9X02
         ZTtRZH2Zoz4NmFdCx7ZdZtezF+WNxnC69MbzWXkhz7cOyXjcFiPnGvQ1O4LysK1Hyalk
         Zxyw==
X-Gm-Message-State: APjAAAU1YHB7GPooDshGKCLaUomAucppG6IQZIuuBKMncG9aXeuotiNo
	otowqk6X52syv5Ken86q9ibJcnBtE4LP6nDM+3PPgOOGYf5tYn3s0KBe9dHre8j5YxqyGVzunrw
	4ou4cCRR9aofXSvqUhEeNmzS/mCVCfXllAQ1v4ahGxKnGknB7SqNYgDMxFRt4dnTSTg==
X-Received: by 2002:aa7:9513:: with SMTP id b19mr70460642pfp.30.1564958984340;
        Sun, 04 Aug 2019 15:49:44 -0700 (PDT)
X-Received: by 2002:aa7:9513:: with SMTP id b19mr70460624pfp.30.1564958983449;
        Sun, 04 Aug 2019 15:49:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958983; cv=none;
        d=google.com; s=arc-20160816;
        b=nWLwMV227TsBKXHuikB4rwM5NNCNyOG0HpBqrDkYV4+7nYHZL3lefXKl5B/TNXmy9N
         iEe6x28MHph45usHTNWIs7i+HFGaPG+k9fI3HA3Y5iRYG4Ups2rib9KKo4rBXgcfAZfs
         h4k5Pz1pwx7dSStEgoN0kJQixuuu/gVo23NxatgtIcR54/KBucp4DqwYZ7zSPt9Sptj1
         0bDWpEh9I33G88P+0qzbNvauuJOV/nvphZGU0Gu6jnKSpoEPRxsLy0v6mZsqRp2h3MpC
         jcZjPT5L6+nUk0xvwvWidgi8CZRDgomutfIu2hbaDPmwh3sCAOXyFKfeQ5lyjZV2EB46
         4b+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JsaN0a6ImilSblrGqgWWjtVL4aaUVqoBD3LMggUShuU=;
        b=O5PVSe712pIQsw9wbP8u04U4Af8dxa/1MX/pAwnumTGk7peIoEdiUW/T4WeSENE8pZ
         hCa38RQucBgzjkbLAmmP47D3rZGerl8vNPaW9CkejZRwQA5gZbfcZ0LsvguiLcqlzF/X
         TtRRr2DEeZs/Mn96JKHv8iOVgyUHxFLwlpZmfPE6qBjwwHWIHs5Q97dCzY2Pb6EvCaSq
         OHulI/QE2KJ0nLnUcertzX+41uMD7r9Sch7cPANhTMH08URtadn/j1nLfIS9wAMGF9lO
         nS9HNJSqW+yAMTqLES+SW9XavkorUHyOSaTS5QkrP0oNKQ11UU0EkVY39aOVFsbGhTnW
         j+dA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JnEMIs3n;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor63170516pfr.48.2019.08.04.15.49.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JnEMIs3n;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JsaN0a6ImilSblrGqgWWjtVL4aaUVqoBD3LMggUShuU=;
        b=JnEMIs3nTK87TbKIsk78nYiw0PTY0ejtc4/1iVy6auz4dRHpNyRxFRwH1QA1daWzTN
         aXj9jYYTXz8+AYgGcMfTPEBfeFGtB4kpRaO8Pk0E6cwtra6dbEcp5zLBIuE/7ypkwlfT
         SpsJZfWDoouD9Zux+JSra/B270Q5FO6OQn2iMY62H9YA77q4YnCIt/dO49LC8oE1+DV3
         b+TloTS62XLmGXLlvmUrAcvGMvg3D8t/Jyb83QK6eNN0dmLM2VXZUouulBv1uv5lB+bU
         bCC0pVKtYc9eHNJ+luk9voAPhlxcPRRn3LwajJw/0mnVI63KipX9TSVsdQUN1tD1p56o
         UI1Q==
X-Google-Smtp-Source: APXvYqyPw77rNCbZJ7kQ+m4UN8hP7cU/4bhOvRnVoHevKNRjma2a+EIazJKEeGo0aqshVanFUuFV/w==
X-Received: by 2002:aa7:8acb:: with SMTP id b11mr67847354pfd.109.1564958983244;
        Sun, 04 Aug 2019 15:49:43 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:42 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Anholt <eric@anholt.net>,
	Stefan Wahren <stefan.wahren@i2se.com>,
	Mihaela Muraru <mihaela.muraru21@gmail.com>,
	Suniel Mahesh <sunil.m@techveda.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Sidong Yang <realwakka@gmail.com>,
	Kishore KP <kishore.p@techveda.org>
Subject: [PATCH v2 15/34] staging/vc04_services: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:56 -0700
Message-Id: <20190804224915.28669-16-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Cc: Eric Anholt <eric@anholt.net>
Cc: Stefan Wahren <stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mihaela Muraru <mihaela.muraru21@gmail.com>
Cc: Suniel Mahesh <sunil.m@techveda.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Sidong Yang <realwakka@gmail.com>
Cc: Kishore KP <kishore.p@techveda.org>
Cc: linux-rpi-kernel@lists.infradead.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: devel@driverdev.osuosl.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 .../vc04_services/interface/vchiq_arm/vchiq_2835_arm.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
index 61c69f353cdb..ec92b4c50e95 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
@@ -336,10 +336,7 @@ cleanup_pagelistinfo(struct vchiq_pagelist_info *pagelistinfo)
 	}
 
 	if (pagelistinfo->pages_need_release) {
-		unsigned int i;
-
-		for (i = 0; i < pagelistinfo->num_pages; i++)
-			put_page(pagelistinfo->pages[i]);
+		put_user_pages(pagelistinfo->pages, pagelistinfo->num_pages);
 	}
 
 	dma_free_coherent(g_dev, pagelistinfo->pagelist_buffer_size,
@@ -454,10 +451,7 @@ create_pagelist(char __user *buf, size_t count, unsigned short type)
 				       __func__, actual_pages, num_pages);
 
 			/* This is probably due to the process being killed */
-			while (actual_pages > 0) {
-				actual_pages--;
-				put_page(pages[actual_pages]);
-			}
+			put_user_pages(pages, actual_pages);
 			cleanup_pagelistinfo(pagelistinfo);
 			return NULL;
 		}
-- 
2.22.0

