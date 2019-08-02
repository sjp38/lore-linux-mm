Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A726C32753
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02CAB2080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TDJzpDwE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02CAB2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24C806B0270; Thu,  1 Aug 2019 22:20:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AFC66B0271; Thu,  1 Aug 2019 22:20:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 051D76B0272; Thu,  1 Aug 2019 22:20:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDD7E6B0270
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:37 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id i134so9204052pgd.11
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UPRfD7vyasD2XVfdl0NeBW26eHm6l3ABDQSSTKq1HX4=;
        b=UeiQBWMVwyGiSQaF/Ym4gs/0xnxsb787wrDqr9eqaxs1ioHxwYhAp2Kh+1UReb3+cN
         7Zg8lqjNjxix1eyUrj9oXsLK+v2aHxXhDVO3uEIXrF0l8Z2YZKvtdgm1Z9IL2d6lcrU2
         N9P5WniTLubfXL3Jjr65KPfwTx3GqIHUseZ9QrosxnS41DVkA/yx+GHKoHAdVggIgbUK
         9VQpKJvq+4qWczCUh/CZ5B6hD1XZo/uILf8wTK1MtoGLgO9WJpoVWeG0ehCj0AgDAFli
         GabOcgnTiklrPeOaYHRr/LdjGIpjVlZrriCDKDkZVpozKhutq5oeGy116c2FqPdorJfX
         2HxQ==
X-Gm-Message-State: APjAAAUAJxFy2zuleG985ls5hgZqh3t5dmxsmSc3LWfOLQzEfyZy4Gso
	NNUXJrll2kYtaDFuNLIWnnzlUwMU0haJN0hqBGYdTv+V3r0M761a+KYzYc0FNzDP5CefUI7taUd
	S6d4I2ldiunS/mWyGYl+OCJqCYTJ24j8r53uGVpCPq4igna7o3Upeg+GylvIBA+bmIQ==
X-Received: by 2002:a17:902:9a07:: with SMTP id v7mr21587718plp.245.1564712437454;
        Thu, 01 Aug 2019 19:20:37 -0700 (PDT)
X-Received: by 2002:a17:902:9a07:: with SMTP id v7mr21587645plp.245.1564712436165;
        Thu, 01 Aug 2019 19:20:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712436; cv=none;
        d=google.com; s=arc-20160816;
        b=bG/NSrMuhKNHI5mJIUvpvjYr6smOVhBr8IfKKKBq52/Dcj/JApKegz3BuOhUSOMj1V
         s/NwNxjTs1sNLS+uIX5yB7z5csj2ui2E/F7VKtnToORWMCO5fOCtxbuiJDuM2wN9jAka
         PT8P75QWZKbEpjeqLVl3z7CUDRqJpzCCl0unDtS+sfxFyR0iO8jbtO/rAIByL9c+rCXC
         hzhJaY2sDl+rtCHNYz1JQarXxWBVneQQEul4xTorJvwXR3RLjHRgmMpXIoQ2n8Ypnxzn
         PfN5qNGKnXZ5ngFMg950wyjRv2jS88ZVRrr/RSN/h0JHj1pEQbc6uZu5IXroFr2AogvT
         Vdqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UPRfD7vyasD2XVfdl0NeBW26eHm6l3ABDQSSTKq1HX4=;
        b=giZkv41DLVS2ZOoAqH0S7drXZizevkiR58I/7UvPylgbYEHyLKJ7vdwKsRK+CRKoIi
         IpOvkHfAYjk0d+m9LH1Bv/OUUl0h07mgSbLFpncnUmjYmoGnwuhjJ3HsNYpABOwlTZkC
         eBRr3tFnYy6SHIJE+3lTZiEHTUOYAmX2Lr2VUEnQWDyOV+JpQrYFSITuAqnL+p9tJkbZ
         R99qwmwyvUkTVHYu5jy7GPV/R6rAzfmGV7jAQtCIk+w0GavSLRrH95EP8VV/JmtFQ7aR
         o/hqn1GGPebTSooP0Qmx4kVTSlGLhR7cewJ/0449c9WT1d/A+MXpHYMD87VZ+q3dT5Lu
         2rOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TDJzpDwE;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bx14sor8438257pjb.21.2019.08.01.19.20.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TDJzpDwE;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UPRfD7vyasD2XVfdl0NeBW26eHm6l3ABDQSSTKq1HX4=;
        b=TDJzpDwE2oXFjm8cRNjQ8xrt4Ta2d3wf2Cpo0GoFM9thJ0XtvCvH4mP4rm1obsYrxe
         XfcKcMWeGW7+jGqqsIeZqIQivf0rjt9KMIQPJwYrX9aXaeynZfYblNMyZkWwFJwZth79
         e4fMCJd20kqdE18/wOh4Jbz0PSr2Nv8bt8KSNv7hBSUy22vg0EGXVDctxg6pWi24C6E/
         aytHIR9O0Oe5Nfk4mH6Tawu8cduDw0xsgEveOl493+9jCWiudUUBNmztlAbrHUK6dK5c
         cZre9/z25iL+oH1skqqYaquBXUxt6bEZ/OhP0nmn5k+Ox8GOIXBHEB9I8h3iWNYPWkz5
         1iug==
X-Google-Smtp-Source: APXvYqzQQn/4+/qhyIZ5gzUBopHqYfn0J/db4aXm+9arPe8eAWsGtJFKretZ1QBLJdXBLY5X+jbCWQ==
X-Received: by 2002:a17:90a:7f85:: with SMTP id m5mr1901500pjl.78.1564712435904;
        Thu, 01 Aug 2019 19:20:35 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:35 -0700 (PDT)
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
	Eric Anholt <eric@anholt.net>,
	Stefan Wahren <stefan.wahren@i2se.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mihaela Muraru <mihaela.muraru21@gmail.com>,
	Suniel Mahesh <sunil.m@techveda.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Sidong Yang <realwakka@gmail.com>,
	Kishore KP <kishore.p@techveda.org>
Subject: [PATCH 15/34] staging/vc04_services: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:46 -0700
Message-Id: <20190802022005.5117-16-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

