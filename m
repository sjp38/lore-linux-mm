Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E35BC76190
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:26:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A91382253D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:26:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BXqsh80N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A91382253D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE2736B0008; Tue, 23 Jul 2019 21:26:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B94846B000A; Tue, 23 Jul 2019 21:26:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5B798E0002; Tue, 23 Jul 2019 21:26:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71E426B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:26:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j22so27367071pfe.11
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:26:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=YydwaAhS6jC6ouG/ISDrxHMuNeXQI90ARmOfRjrudFKrljByHBi9DHgH+X+OwSP9cb
         ichryyQqYFEIzhGUjSUSyl4SEM4NVJ7L0kot/Fj/R6+AXLaG/K+SL1yVrmDflSHv7t2s
         GfDKtrWA43WQZm1Woz4vVt379DNxuGoLZSeiAP8oif9zZtScMskd9e0NJQzjG6j06/rt
         M68JSmq08y08lLLmBzTG2GJaZnjPp3CIC00O4iLaIQrztmdroj4A1OAuNdjk/BQqDnoF
         k8QuMWFmBUPZAdJM0rgeCUvPKlBW/LvtSg3sS1dbsEv97obVD+6tzofPfKZieg1mxP0G
         vv7w==
X-Gm-Message-State: APjAAAWcL/YhSOyYKovge/55VpwI63vXjnYe0T9f4dSytZn54WEaXR47
	87huS8donDlhR64WryLljUGNo7n2yCyKZ5C9oqEfSkk0Zr7j3YnDUVmdNZqYI0T585znuLf1+1A
	/pxZJjlNVIMOZ+uO77eqpDKBwZQq3xU/vdUMYFN9oAIF6WBlvOai3XBW2pZjlHWg8yQ==
X-Received: by 2002:a17:902:d20a:: with SMTP id t10mr32927121ply.226.1563931575167;
        Tue, 23 Jul 2019 18:26:15 -0700 (PDT)
X-Received: by 2002:a17:902:d20a:: with SMTP id t10mr32927075ply.226.1563931574430;
        Tue, 23 Jul 2019 18:26:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563931574; cv=none;
        d=google.com; s=arc-20160816;
        b=WRJozLitcX4SP9xS/LnKBmXvwk5U2MpQ39f8r1r6nmKvwyPTstrqf6idoIz9oq+hQe
         1/gKfcHJcSQyEZFAm5RXtDmpK+OnZyoRfZCY/xKsSNzINoch/yKiDbtuz1O1DQomUB5q
         67y0uDJZWxRkk0nQN2YB0RPKcTCIQN8k0VW/j4vxWDGdJZ5er8mRpCt3ycCA91cysCiB
         FzD1vhn5r2Ita7hsSPAkbNCIcxiddQfMuICSUr3oiwCZb+tSgKEx8NV0OhEIMV2ws2JD
         5rj4SOXkWZXohjeLRp089qyoTyUbFdNSbb32O8hPP+s5D6Q1wa0GRcN+0sqP1z+/AIXB
         HugA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=dDfYpc63yGxltEROVUDlP+hG9T0AkoYmF8R0nI9KeWw8Bt1u+vr5RfW19GPuw1ngZp
         TxZZP72+AK9SSNUzKSf4qYvjaz3gJXHidqlpZqkY3c6NkBBs/qYWrKXkBP3FNX5SQpO0
         K5Bn6S9z6r4C02H9/S2H6/5AuDvBamWCfAx0WQRQCzWLTcPaUyY17R/cKZVzVC2fdIvu
         4qIrVGmNx/lK4LOvGLEKEzqVu2W6rBrMdnscjaNeduBiSX4PLmDvFQnY9xvS9s3lkGDf
         d9sk2f6RhARr+QvyoH9oiEZBx3PhksWsyEcslMSP2FtS0yE22TigGWgr9fOvBM7HHydi
         Qrcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BXqsh80N;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor53789634pjp.16.2019.07.23.18.26.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 18:26:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BXqsh80N;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=BXqsh80Nl4cDZcRUa+Nux4yM46naJJQtkxKxn8QzLhVcqDBWMLcxIvpEfojCwCxmNb
         KDP337fhhZiSsUY+ie+iYwy+2LsmwUDrAbCBafzWMLvZeUwJrYtszfn5BpBMhwbZRXEE
         ls7+Qu+a79sZuQw2/Y85G/uzux5nCGoCZnl7NXJeaNUrSOxj+wZ3LMZFEs4kUib49d55
         f/aP9kCOfXD7XfWhkmk5SMVUXE+iny9dOyzsBMo4r1sLMn0DtURnoVBQNLDjNrhOdtJB
         ZaPsyiQ+nd6BdhyOicPLzNhKQsZJ8Wv5E16OYyRJt7ANMgAFPyceIosc6BbyNvMrTUAr
         XRYw==
X-Google-Smtp-Source: APXvYqyCk61wnabNIK4Jxvfw+l2b6WmoUqrtPcNhmtW2WxlaOXFDgcDVuADNCkU4wpAGaRv/63OqTA==
X-Received: by 2002:a17:90a:db08:: with SMTP id g8mr82170764pjv.39.1563931574192;
        Tue, 23 Jul 2019 18:26:14 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id k36sm45950119pgl.42.2019.07.23.18.26.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 18:26:13 -0700 (PDT)
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
Subject: [PATCH v2 3/3] net/xdp: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 18:26:06 -0700
Message-Id: <20190724012606.25844-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724012606.25844-1-jhubbard@nvidia.com>
References: <20190724012606.25844-1-jhubbard@nvidia.com>
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

Cc: Björn Töpel <bjorn.topel@intel.com>
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

