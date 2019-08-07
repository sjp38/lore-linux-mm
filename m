Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC466C31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 763CB217F4
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a57ErTyt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 763CB217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76D076B026E; Tue,  6 Aug 2019 21:34:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AB596B026F; Tue,  6 Aug 2019 21:34:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43A056B0270; Tue,  6 Aug 2019 21:34:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 096D86B026E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:10 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id i134so18798339pgd.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=MIAh0RkBO9P4HN8Pk0yB+LXcpO+0UEwsyK9+9tUcY3gL9nQLcKakWz2bHlPvGgomEV
         UA9TTZNEM9xUTP2xVbXtWqp/++EQDHW+Cz9CF60NZq+Nx36OJPdJKh/zwmPgAy2Yk6bJ
         5WXTrD9ZPLtNObf1Y2abexGMTTX9rwLYvwJTmoIQVzg936dssfbr+0/Tg6rmWrA93sOk
         V30fZi7Qm/PKU/bN6shNsm8+ZJFZEdZnYsj45xwb04NWVUtYfz13c3thXUzlbjxT6OJu
         R3xWNa3COaIgFZSVAVoxvvj66iF4nuCr9QU5/sjBAIv0MLqzsJQfoX7M2sHEXE18dOb0
         pk9Q==
X-Gm-Message-State: APjAAAW+zIrc3A80/6uR0/NlDm900zP61jB7uLH0MuOe9Cfa2X8sq6Go
	exOtvZ8TU7fsmWHhogD2irTzQUgQ31tfmfCTeqYY99e5P6AzHI458bwXL8QNVWtqNjJQ1iP7/Cn
	P7eh77B1CVfqWXpnYGiVM4+eYninGyhXx/09xqyEC6h+2rqosBEnNR2XdvbcGjUHDFw==
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr5653941plp.95.1565141649707;
        Tue, 06 Aug 2019 18:34:09 -0700 (PDT)
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr5653894plp.95.1565141648767;
        Tue, 06 Aug 2019 18:34:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141648; cv=none;
        d=google.com; s=arc-20160816;
        b=nku0RZsAqGIovNLSgmBnMwejsCyr8TbK5VpZz9cmyPDAv8WVrZMvFQ1fkp39OSnRTg
         c0PDEpOxR14AYly+HJs5thoec6mbrClem1vaCFgydoOnqx1wPB8BckOd6DG9m+qUItR4
         OXVxL3DbJxgic05oYYOx6j6pE30GzZPC09Pn3nCHOWEv8+RIeR0XqLIkpgjuUkIJVJsw
         SH4AH5KBr7zBIuWOnpOevqYYU1lhG2Fe7m0jrUIm56PtbGFZUuF3PpIGHbKdxVYvJeCD
         PS5zPbST0VXfELq4D2vnp54WG5waykBLCLrYTAx3zqbNFfHq3JZzpwQ7Ty06xGFDKCXs
         52qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=UgOO8dwI1Wd8RHAEaq+fUXIn8YIHthj5gb4/UoPQGuC3KSNFMSlLbVXa4PuixjwETE
         UcAx0PfetJ2ZXzjnU1S7sXtSRipCl1GKf0F/42UIWV+8JByeRcWEaE/rxjRIJrUoswgq
         SphY8aUUAeXcoENB8dEeg5UpuIxV/YkBvYz24/M5n3wGMXL0Qq4nN3e2O1Bovf6RAMiy
         VpfluxekojyEUzDFdPMnp/MjqvuABkdSsp80aABI3jRFV2Se4+dPzRbeKNgTigpW1eM1
         icECtdhertRJgVzNiNu0L5I1C94AQybUaHsoheO9Ej7LYGwiyLFOD87eW4CmKmq8pv4A
         pjrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a57ErTyt;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e16sor27227747pjp.20.2019.08.06.18.34.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a57ErTyt;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=a57ErTytVAxkauYkEPzZRHeGlc0u/A4U5ejAgWPi4ESjwpiFFk6hlPoBGFaPNr39C+
         Kh0xSgXuJrsK4KZTKR2yEzoaLeUoioeGoUgaErqheNBeKc06PHRqwui84Q8EBbD2l+tL
         nX9d4d0RSUpPYxjPCjQnBkDN0+Zv6eOTSEhKauRBsgQJexRHp+YFYc3bVaLsL+EpeITh
         /oPeL3Ga9GujoFOOg6Eq3QUGMLurJ7MLYFEtSSTI2Z3ruqYxpiTRqopLyKlPWxV9WtYJ
         j/nNcaVxSU6fzyomhmIYzgCq04OEkW1OTZBrVWiS6qgJ9uqJ806PfvtCbg/QGSrKMhpY
         gQvw==
X-Google-Smtp-Source: APXvYqzZ9ri0aFEivC8E1vtnTLu0Xt+gGlbh6d5zu26K18i0vLRAS3fRLqoUWVmE7o4ev8ojfCHrHg==
X-Received: by 2002:a17:90a:ad41:: with SMTP id w1mr5931335pjv.52.1565141648506;
        Tue, 06 Aug 2019 18:34:08 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.06
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:08 -0700 (PDT)
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
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Logan Gunthorpe <logang@deltatee.com>,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
	Ioan Nicu <ioan.nicu.ext@nokia.com>,
	Kees Cook <keescook@chromium.org>,
	Tvrtko Ursulin <tvrtko.ursulin@intel.com>
Subject: [PATCH v3 15/41] rapidio: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:14 -0700
Message-Id: <20190807013340.9706-16-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

Cc: Matt Porter <mporter@kernel.crashing.org>
Cc: Alexandre Bounine <alex.bou9@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: Ioan Nicu <ioan.nicu.ext@nokia.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/rapidio/devices/rio_mport_cdev.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
index 8155f59ece38..0e8ea0e5a89e 100644
--- a/drivers/rapidio/devices/rio_mport_cdev.c
+++ b/drivers/rapidio/devices/rio_mport_cdev.c
@@ -572,14 +572,12 @@ static void dma_req_free(struct kref *ref)
 	struct mport_dma_req *req = container_of(ref, struct mport_dma_req,
 			refcount);
 	struct mport_cdev_priv *priv = req->priv;
-	unsigned int i;
 
 	dma_unmap_sg(req->dmach->device->dev,
 		     req->sgt.sgl, req->sgt.nents, req->dir);
 	sg_free_table(&req->sgt);
 	if (req->page_list) {
-		for (i = 0; i < req->nr_pages; i++)
-			put_page(req->page_list[i]);
+		put_user_pages(req->page_list, req->nr_pages);
 		kfree(req->page_list);
 	}
 
@@ -815,7 +813,7 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
 	struct mport_dma_req *req;
 	struct mport_dev *md = priv->md;
 	struct dma_chan *chan;
-	int i, ret;
+	int ret;
 	int nents;
 
 	if (xfer->length == 0)
@@ -946,8 +944,7 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
 
 err_pg:
 	if (!req->page_list) {
-		for (i = 0; i < nr_pages; i++)
-			put_page(page_list[i]);
+		put_user_pages(page_list, nr_pages);
 		kfree(page_list);
 	}
 err_req:
-- 
2.22.0

