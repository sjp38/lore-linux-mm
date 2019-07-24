Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ED15C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08B3422387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JkQ04mWE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08B3422387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7674B6B0010; Wed, 24 Jul 2019 00:25:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7184E8E0003; Wed, 24 Jul 2019 00:25:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E02A8E0002; Wed, 24 Jul 2019 00:25:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28C326B0010
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:33 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i2so27687818pfe.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BJP8QYXxp7VfUt7Eaw5PwJTw08pU7M/uVeuocSBpfVU=;
        b=DA5IJCeAFtuW24ako6q7h+ohCtJalbOa1P7CmQKzGQ7+GYkk1t8LO/WIWxBaNq7kIH
         O7TCW7pEEZCv+BZKz8nm3+okspO8YjbMxcLkHQvQvddSgs2p5GQixX26U1rtqwAp4XRJ
         aTPZMHWqthbJ69dy3OPIhXcFmCifwk3zFpj7h9tWtFAdlJYD4skBQJby4ZWobT9XRBej
         eqWhMr+ZtM1zcbDcZTej5ebU4IvHVchZMUxP6Z/+R2FOO4CrGxvcWOQ58Azlt6mIWmNB
         TtU/AUgzPGJuYVsLAbrBCw9sgLyjXj62xodbKJvJYzAVyQ1QfT7OEyqiQu+lSzVqbqz9
         QVnQ==
X-Gm-Message-State: APjAAAVoS68mH3bZK7sFGZws8MVVyfcKCSQBZjrQO+DdmpqS7LOWTpvm
	qJaStR7MMxd9XYPE+SllefSPw0pv6XLv7vIu6/5ef6mdBlYC5V35xjaaY9pDkwxpqXLWAso3mpA
	XjZWZmNvZqbPtinryY/XT8c15ook+hSOTKQne23crpMuoCSQEXc4BUs4QvtzI0165KA==
X-Received: by 2002:a63:7d05:: with SMTP id y5mr80538984pgc.425.1563942332754;
        Tue, 23 Jul 2019 21:25:32 -0700 (PDT)
X-Received: by 2002:a63:7d05:: with SMTP id y5mr80538923pgc.425.1563942331597;
        Tue, 23 Jul 2019 21:25:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942331; cv=none;
        d=google.com; s=arc-20160816;
        b=UJWZje5a6JLmLXrRVXxmsqSbbyI7gBcIll3qmedAn7NkcXI0KVxSozPrKLGgsbJH7i
         umFmfqrQBIbtRW/3PEj+z104s70KJ8IYq1cfCicgKCvdpPQaFlRvM/lVWkIzpYTemmyb
         UyQb/zaRl2K0QA7OOZ9oq4tYeXHYSRPB384J0Rj9K5vCv55mZU+4S8H7uMBmgy+8Dyon
         kYGnRzFugRPjclFb1wemIIbycSC55AAmoC/H58IvGu4HZkVuOg9EuaXzCQJIDvKqzuHn
         gHvQFFgnxBQ6mQHebpGsumBg1kHlpTW+NeH3hfXSkE/YoZvIECIJ8IemWYlsa5wUdYjQ
         32pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BJP8QYXxp7VfUt7Eaw5PwJTw08pU7M/uVeuocSBpfVU=;
        b=u6fd/zMW9xCCvxCK9qhuM7nbfQ7IugXy6bY7tfeKjBote4N3gKyD8gCXUmlpwzHqGb
         rLtF4/NEV/b6ZlmU0guui7DJAlnKO+wlzrXvXzzffGMZjzXbiwTpzJob7RYqou1MTgqU
         1+Um1JTGMAIs1P76vHQ7SEUsOxkgGvsY6x9O9npC/a5P3f0uMUAP68zoc2Rc8dJqNnqp
         PDwCd81mBO2ioXHqZgzgS6hBa2lX4TE+qhbQP5Fb6AmhvPksmnDhTteYbkkzlw2zxwsx
         Kd37OoRBSkpOw+6XBx3fDv7q9IugofEsS7a3KwUhu52cqu2/be9x1qaJMpkbDZhSTSqA
         g2Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JkQ04mWE;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor54832018pln.13.2019.07.23.21.25.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JkQ04mWE;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=BJP8QYXxp7VfUt7Eaw5PwJTw08pU7M/uVeuocSBpfVU=;
        b=JkQ04mWEAa/01zFb0tlIM6Uj/lB55wPCkF6GMvnL5gHq24gOeLxpu2syudv1ZeubVR
         o/2/SbGfs0MBuqHwUIG/UqiIYwjvwRdM1smByZv+PMbXD0dTKJlqPSntSI4p9XbD0/EP
         dCEFzTMQ+3jKQsrfKqZebfyOsyegrsrPG3hntSrqUGy/c3DI5jDFIn00D4+KacGWHwyg
         5+f61ycblG2ySUuAZOjASXUKEg6G7NHj0n1tTzQ86l9qr5EKD1HA2V/yosWmHzLAWWAj
         WxbUEPr8ZwbT/LJAb0AztRPHVuEiMh11F1nlDvqA1UHHjZuRTFB0keSEGorINX0fFgb2
         sO/w==
X-Google-Smtp-Source: APXvYqwp+g/SqY8cK+RhyrKnPd9NNEiEh2F/BoaBOdfDPn2MZtzIjgPt3GPtA4VFQfpQXahpL/YYYg==
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr84794603plr.198.1563942331371;
        Tue, 23 Jul 2019 21:25:31 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:30 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 07/12] vhost-scsi: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:25:13 -0700
Message-Id: <20190724042518.14363-8-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Changes from Jérôme's original patch:

* Changed a WARN_ON to a BUG_ON.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: virtualization@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>
---
 drivers/vhost/scsi.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index a9caf1bc3c3e..282565ab5e3f 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -329,11 +329,11 @@ static void vhost_scsi_release_cmd(struct se_cmd *se_cmd)
 
 	if (tv_cmd->tvc_sgl_count) {
 		for (i = 0; i < tv_cmd->tvc_sgl_count; i++)
-			put_page(sg_page(&tv_cmd->tvc_sgl[i]));
+			put_user_page(sg_page(&tv_cmd->tvc_sgl[i]));
 	}
 	if (tv_cmd->tvc_prot_sgl_count) {
 		for (i = 0; i < tv_cmd->tvc_prot_sgl_count; i++)
-			put_page(sg_page(&tv_cmd->tvc_prot_sgl[i]));
+			put_user_page(sg_page(&tv_cmd->tvc_prot_sgl[i]));
 	}
 
 	vhost_scsi_put_inflight(tv_cmd->inflight);
@@ -630,6 +630,13 @@ vhost_scsi_map_to_sgl(struct vhost_scsi_cmd *cmd,
 	size_t offset;
 	unsigned int npages = 0;
 
+	/*
+	 * Here in all cases we should have an IOVEC which use GUP. If that is
+	 * not the case then we will wrongly call put_user_page() and the page
+	 * refcount will go wrong (this is in vhost_scsi_release_cmd())
+	 */
+	WARN_ON(!iov_iter_get_pages_use_gup(iter));
+
 	bytes = iov_iter_get_pages(iter, pages, LONG_MAX,
 				VHOST_SCSI_PREALLOC_UPAGES, &offset);
 	/* No pages were pinned */
@@ -681,7 +688,7 @@ vhost_scsi_iov_to_sgl(struct vhost_scsi_cmd *cmd, bool write,
 			while (p < sg) {
 				struct page *page = sg_page(p++);
 				if (page)
-					put_page(page);
+					put_user_page(page);
 			}
 			return ret;
 		}
-- 
2.22.0

