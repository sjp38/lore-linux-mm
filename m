Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E929C32755
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 23:47:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C877206A3
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 23:47:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E+zHlnIp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C877206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52BDA6B000C; Thu,  1 Aug 2019 19:47:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F5D96B0006; Thu,  1 Aug 2019 19:47:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10ED46B000A; Thu,  1 Aug 2019 19:47:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D15586B0005
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 19:47:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f25so46768201pfk.14
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 16:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=bPV6nfEV3AHRcVHmHFd901dCFd9E2IEGBfqWvoylgGpX5pHpiaf/ayP9aStXZDHTxS
         tc60L15s25nKYZHpxjOwtuDGrDhUBm0Q9CAivvsRdkdea/gewV3nYVYqZoJeTZCfoP2p
         /1dn2JMctL3i5J5hVlF5AyFK/jkrI7kIKaurQA2BUoX0E7+3rp3EzV8gAE3BTqObs5R0
         4Rz/nAm/fuK3dYuUT0Vm/CfIf2Rw+D8jFofKqVDqt4Yj7oYbmp2ZDiYQ9ytgRQQjZXUV
         +UBJZMCeKu5sIpgLU/EqCtGj41lt9N9F3/4S4iDADAuhC5uCk9R0ML0FhDpsErzMKKt0
         0UZQ==
X-Gm-Message-State: APjAAAVyxCveaUaJBB5Z7/mpSm39Ls0qY0Dq2I3CiARYqu3Fi8DXlmny
	CpspCt9vLN+EXx5vNRs5RSXOvsKdmUw09lLGIFph09lmGxA7/6WDRtFUeQebFe4/SGfR4Y0sX7E
	UsYfZ63idhpIvNb4sC+FJ9PsYlDYm/1gK9jPwvVeJ3WqpGkciHM7XZUSExVQxREOo+w==
X-Received: by 2002:aa7:940c:: with SMTP id x12mr57212261pfo.80.1564703265541;
        Thu, 01 Aug 2019 16:47:45 -0700 (PDT)
X-Received: by 2002:aa7:940c:: with SMTP id x12mr57212174pfo.80.1564703264367;
        Thu, 01 Aug 2019 16:47:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564703264; cv=none;
        d=google.com; s=arc-20160816;
        b=CKVUKY98NGJ/K/1BbSWR9lq6en98msXpV+HaPKKZc6Uzclwh4U4o14IcMALY7IEEDp
         gEd4IOTJS7A02WE4/HKiNGvVWGgjdvuQGwewuLPIc86sfxMJwu+0r79BQm9QzG1I2yQy
         UMhd/se3gI/M+nBwLO3jdVXxu8dzFN966e3ojOKwBroS9MaZuTy0aWWlZqyqeW/jSsgv
         xj0vaWoQ6chT2yNetKOQ7olv+kP4+3wMZX1nCZMwIzu2iZbYLYHhwxtpan0YqD/KXZyF
         vZl9C6pVc9uzE73e9fjSdOfEEI9kiL8xmY7106ue029T7IdtHGsd7s9jGuI0sl35LTFt
         hElQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=CcqjdR59RAnvk8ms8uMrSECkoNQlV523XTwQKbKaXz37ZFTXDYSDF0bRyx7zry3Mom
         dXJD5EeDaW/vZTDKx8Xj1ZppCQ4bHhDICiZHagDvYHExaTQQlr46W0quPYXiKD674IeI
         Wtv46rKjUV5czoC+aFO++w57x7Ot4RQ5YhLLggeeQEJJNJgxFYMYtehbD+OH/IOmNVvP
         WdG4HCCzCMZ4EsOccH7kRF6qi+vXDNq/NSCc8NkiurNsPoDRIMdrT4m7Wtb/g7bZoNzX
         v8is3mJKmps8aZ2KiU95sDJT+rXJcT+CDoSA2b+Zh8DyejnCGAwqybv1ljI39vTvflEW
         bUGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E+zHlnIp;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e63sor54328016pfa.50.2019.08.01.16.47.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 16:47:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E+zHlnIp;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=E+zHlnIpYzBr1HZfJIsD6iVbo/tVCWCbZWGouwMcKWXf5pRqLr+7fu6t6wyR76gxrS
         Pw0XWBh+4s5Kr4C0zZ1uLNkWtKi03BCdpa29tA51sk8I+Bq12u0svuAUfdj+sK8H6N5H
         /8lixInmiBO+tmKzSLyeiGhsebOFRuv5X1HYeJ9NG7mhRRnXPabVEo0th3yVnfWLj1Ya
         c7rmaefTzcGx11D0smecmd6tI08T3Ivoz0JbFA+LCWcAMomm5K9oYs5qsT1cHM0HE8Jc
         UMhXpM08RliBjrRUsniYuwevqpn1x1w55S5+T81xoskFTv+eqpjGrmLmlIP9IsRGKn2i
         cHVg==
X-Google-Smtp-Source: APXvYqwtPIy/q9DIVACpqZOM6oV+V9VPUP/5mN1kfjPMf5x4eodvXZuVHIq97aECtPB0t2lwdk42bg==
X-Received: by 2002:a62:ce8e:: with SMTP id y136mr57190606pfg.29.1564703264155;
        Thu, 01 Aug 2019 16:47:44 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id q7sm79090792pff.2.2019.08.01.16.47.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 16:47:43 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>,
	netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v5 3/3] net/xdp: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 16:47:35 -0700
Message-Id: <20190801234735.2149-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801234735.2149-1-jhubbard@nvidia.com>
References: <20190801234735.2149-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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

Acked-by: Björn Töpel <bjorn.topel@intel.com>
Cc: Magnus Karlsson <magnus.karlsson@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/xdp/xdp_umem.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 83de74ca729a..17c4b3d3dc34 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -166,14 +166,7 @@ void xdp_umem_clear_dev(struct xdp_umem *umem)
 
 static void xdp_umem_unpin_pages(struct xdp_umem *umem)
 {
-	unsigned int i;
-
-	for (i = 0; i < umem->npgs; i++) {
-		struct page *page = umem->pgs[i];
-
-		set_page_dirty_lock(page);
-		put_page(page);
-	}
+	put_user_pages_dirty_lock(umem->pgs, umem->npgs, true);
 
 	kfree(umem->pgs);
 	umem->pgs = NULL;
-- 
2.22.0

