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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09150C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:45:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADF58227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:45:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="arDVEhmz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADF58227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EF016B000A; Wed, 24 Jul 2019 00:45:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A0DE6B000C; Wed, 24 Jul 2019 00:45:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EABB38E0003; Wed, 24 Jul 2019 00:45:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC6D76B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:45:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m19so13024641pgv.7
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:45:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=pXfzO/dIslXDu7SrLVtG0W8X/HKzCYpkMIsA13eRhI8D4qcd/rVMigJ8P3/d5A1FkO
         auO3YVnmMcdYvltfh+kDkvaS9Nk1KKZraY+6C3I5bBzIT+uCaATbRCaEFes1Q7kbfyOU
         orEts5H5thGISlWD0jgV199Ys6bECkLuDHmYoAjwPu1DL8INZ3/oqMeoLbSupH5M/PR3
         CgioM9lMwXYp7jNo2Eo1WAT5eGf8EthvkAruDP19u630Wohob2QWz27usdKGZPjsrx0Z
         m32sazfNZa7CsAizrt9a6gXE1sf3Ytygc/Y96Wn4bT31VrELT+Az7Zp66r0UQXB/t/Sf
         V+yA==
X-Gm-Message-State: APjAAAUUlfMRS0ZfBC58d71UZXuNmimA/8t6iBtCitn6BhBQOzTWrjMO
	EwOI97HrYTJgN9HaCimHQJcZQnoX3tiwDstmg3zZG8I8Kx8yvBCQPPfUfX1tz+60ovNpgHhVfXG
	3zLxkuXifaIJ07L35y3X6mtUjEOhPJR65T8I0ejVTk9pTns0g3ZCroNrvHGMI3vwRjQ==
X-Received: by 2002:a65:5183:: with SMTP id h3mr79412377pgq.250.1563943548315;
        Tue, 23 Jul 2019 21:45:48 -0700 (PDT)
X-Received: by 2002:a65:5183:: with SMTP id h3mr79412337pgq.250.1563943547509;
        Tue, 23 Jul 2019 21:45:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563943547; cv=none;
        d=google.com; s=arc-20160816;
        b=yRoTkX2JVke6h6Qg/DLyHUePB6Zm9S2GLazxA4i5v11Tyn6f5qIdJFWiMYZDhu471E
         pfgKejBNGLdFaj6Qs0R413fVnoF9O35MlJLKNNNYn/HcS1OyFNY2ujxnLvpqRA03KuTD
         H0xhoGgfpmwW6ekTKT4+1VaUo5zY/LkfwoIw0i4G1RMQWdIV6+ODaGT2XV23yIT9937B
         FtLEuO66htdDy3RKRTJgegYMhHHG2sdsU0h4VZ867p8QwGkEmk2ZtarpplhFVYWEonV7
         4jbLScc4tefFZ4bJN8n+3EE8D9f1ViB3k6HpbiH0Bv/C5vffYOrrdnqh2eEyd50b5TYf
         PeWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=lV6kY/nfPnPb228FLSgEXwnHy3HJBBlfpTyXbwZmm4+ftpsf6egBZZlNF4Kny3dv9s
         TWoGCbNXCmyZM3QXrqr7+fo3XVmCoXgPmWZUT/k37ITKGGw5eGW4Um644M0N0+fzbWtt
         0zfUGiiNFznpJamPJh4YwYYqZfYDEaYRrWhvZkTvrXB1/19jNeRzVZbQphGj2KrFkodW
         IPkp6YQwIQRC9lHPqZjbk9C3GDd8+kkUVoz/UMU0mgiv623Dgx8OSOvjkvFGxFS1gVUN
         IKSd+5Y9GUtJ0EgYe1uewrIM+4pxkbhAGKkkVflJwA/BZI9U7u/sRBcaQhM5qP5anPmr
         YWJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=arDVEhmz;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o39sor54370513pjb.10.2019.07.23.21.45.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:45:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=arDVEhmz;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=arDVEhmzmwYc0UEKQFalOXDiIHqPt1pV7vU0JUv5mKmQ089wfTwsdopP42Bp86zZ12
         9WIcbg0FL0S7NcMN8EBa/ZsKL/7UCA0dKCKuCKM+lXn0ABjHzkKf7GbzTzgsqLNlu959
         x8Wf+GMGeki27TD3sIzrhRYDi+0to0FseWV9eOKqeTdGtNvmAsbUvqbDLALoFmNeN8lC
         q8qaQ09EwqFPHJ0FosCJ6TkG/MI4KAUit4mNdGB4LeHjfVsf4BvlJpxIDvO5f0c0rcDz
         cnxHWz5yRd1W3BrSj7Xo/RaJcRj1t3haKXhTaAtTRDrTJ75HdwRRYeQcAOlujCws3i0K
         8Xcg==
X-Google-Smtp-Source: APXvYqxa/GK/rSekD6RsEbqfAEidKg6pPzN0E429BN4FKlNPqtfCT9Yymo4uvci3p2qlK1ysgtHEgw==
X-Received: by 2002:a17:90a:fa07:: with SMTP id cm7mr83262648pjb.138.1563943547267;
        Tue, 23 Jul 2019 21:45:47 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id b30sm65685861pfr.117.2019.07.23.21.45.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:45:46 -0700 (PDT)
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
Subject: [PATCH v3 3/3] net/xdp: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:45:37 -0700
Message-Id: <20190724044537.10458-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724044537.10458-1-jhubbard@nvidia.com>
References: <20190724044537.10458-1-jhubbard@nvidia.com>
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

