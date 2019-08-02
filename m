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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D128C41517
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 256E02084C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OcjBgeGu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 256E02084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F44A6B026E; Thu,  1 Aug 2019 22:20:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 752316B026F; Thu,  1 Aug 2019 22:20:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F30B6B0270; Thu,  1 Aug 2019 22:20:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7C06B026E
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:34 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so47142618pfd.3
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=qP04Ro6T7fJLSZPPjdXGrSZhutjHwdMuuKS6ysYJxSWSBFnXx5HNBtneQ7JWwyORTo
         TgMGRLbRrX1iSai6MHFJpWMPrwTHUWD8SEcaPYjPn++r+lNGloIFYg9jknL2R+0K50xk
         IhYn5vL6RPY8R0OTt0Eg4E4N+lruemngRdaHfbH739pYelbm8TyWtMONmmaKPb3Ns1zs
         t8nv9H1e0NlKArTZqx5gEA4A0AO+P51ysuwya1QZW6fhr4b7+BPNrg6MIvWPZLqRUTEU
         krMpkF8lyd5vs9IO5zoq4jtpK4Q8g2Xi0BQYc7bpzrtnWTNSPd4laIFjbKyuo2JwbGDI
         JtuQ==
X-Gm-Message-State: APjAAAVYAcliFIktqOUsh6w27IxD7NN5iJ4A9WBEvOoJXoHKGrPSXkMC
	+NoULCGwxabCoP6Eam5Uai9PphSlA5mBAkmIBMToHEpG9C7JgwS3mOOEpHlagbPizsFiC8X2jCr
	J0fUw2eO2N9vgpopf2KBJDZkIn6NhtsO/hmrI2ldV/5fH+Ea5M4rKks9m7tVM84Ta0A==
X-Received: by 2002:a63:dd16:: with SMTP id t22mr90682616pgg.140.1564712433778;
        Thu, 01 Aug 2019 19:20:33 -0700 (PDT)
X-Received: by 2002:a63:dd16:: with SMTP id t22mr90682567pgg.140.1564712432758;
        Thu, 01 Aug 2019 19:20:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712432; cv=none;
        d=google.com; s=arc-20160816;
        b=Ac/RjM/UNJlVTVUr40YAEqIHjq1f7mamFrbddWuhiva4w/f8Q8wYY7QCwJaZM7yhQF
         nqSjgkssXLQRAIJpAl5UbBVvdC5lORX3sa5/oMOlrDir776Ma0AnWN3kvKt2zPaNBD81
         ZateRnLJHQUDLS6xbOmdNo54xMcTXqjdjhEDUh+nd+3ZE1D8H+SEANe71CcPXB3FOwZ7
         8TbykTQ6uxoK9jgaHNAIPE2JJqTRjo05wYzuAez9eEmml2aNND2tlyr0hhKZVqXJLaXR
         I+H/42ah3PUSXixvuhf/NvPSSPlU9QHTELicKy68tK4VCGmxeIBPQ0/6BgeTBNDNkKCC
         mFlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=nwPJK+RSoQIxjbNpxbSJ0y9o0R6IHyXU6St0L0hBxEAYC+kkscdgXPuId1EM9ytkL0
         h0krdnzwDkc/HXqzjvofr1z5Y8nlnMU6KcmTdg7BPDnvhlBJea32Mg+sTGoO+jK2WJSE
         UNrkEGWXZaJAa6MCLNecT6ydlOam9QiTazOQ7woysub88LEJMKOfWpFrabWSOiHSMEHG
         huZ6JAkq/fd0OLtdd5O+ViN3saB+jMMHXRV/Uk82fJoWGJ89BpjRzaovsQ8h1LXYX7hF
         s5gUw5wuaDmNT4Z4e0fhwchuze6QhYiDBD0JzmCk46WBLEvGL8+MYpb4eJVS8zaiZMG4
         /CcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OcjBgeGu;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z64sor54779653pfz.10.2019.08.01.19.20.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OcjBgeGu;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=OcjBgeGu8UZCjg/O5HE3tZTmbKV/JxG356gcwN7XI4m7laLxmDfYwr2J+xgouxj3fQ
         Co0dhwd0qY47xArJmyB+EhpJv8h8AiGjGK24lKEHkHPsH9RjihM7pMRvNW+41GJgCLyu
         4QfSp0AC2zblPx9c01ipPR4kYld7HwcvdeZgybQdYrqzUfXd232AEHGN5xFwKTyZmR0/
         4nQ8d9yxpivs4/vMxrtO/9Xc8hiQJpvET/VRicWc2zu2qdEUBl4z9cTSyxwtCJdabvcM
         Ei+d8hsTWnZC71PLDlgF5ytQlKruZFkMxa42zlyyGk4z93JPolm9Mu5LN9FxicLHKdhc
         nCzA==
X-Google-Smtp-Source: APXvYqxJWuQ3PRZS25/rGW/r93tu8qJViELHafWX8OhR+SZHdvKx4eGJZdpIEmnFGk4IpVB5b1wjUA==
X-Received: by 2002:a62:d45d:: with SMTP id u29mr56669248pfl.135.1564712432510;
        Thu, 01 Aug 2019 19:20:32 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:32 -0700 (PDT)
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
Subject: [PATCH 13/34] rapidio: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:44 -0700
Message-Id: <20190802022005.5117-14-jhubbard@nvidia.com>
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

