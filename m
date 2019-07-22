Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 196B3C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:30:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBC092199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:30:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p3HGgaIN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBC092199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D61C36B0006; Mon, 22 Jul 2019 00:30:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D10D26B0008; Mon, 22 Jul 2019 00:30:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDDE36B0007; Mon, 22 Jul 2019 00:30:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 847668E0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:30:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so19105154pla.7
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 21:30:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WbaMzabtgu3hCeOMPX09tru106PZHAIJnqruZQI71c8=;
        b=Cac3Xw4w6FRbQ2HFSCNGoA/lMbykPp/wIVZ9skHJOerM8zVryft0XYfIT9yKPgtuc1
         Ei3WY5zEr1LqMl8YnUVNTKE866tSmMCABp3L3krg6E1MBcRxECHiw8Yw9hfSgYna+3oX
         drdj3YDYievSMukVHOVynY982uvwfZuz+EPEp2gDHDhDl9tKctUHr4eF7NlPljDM56jY
         hkOd2Cqw00akbBG1mqj+/WqcbA/brk35Y/ewfBuFqLXu7+BvrelRaflolfxe8ndfu+NO
         pth1AZnzdmsSq7gGZeryg4TB8ayFHS+gKVafULqc8U5zxknQaYus8EAoM1FHuNeZjpgC
         PNYw==
X-Gm-Message-State: APjAAAVmwSMvpqWMp8MMo76rOZtjlrZikQikbq5QjSfDEfJHxWUIe37e
	noEnGTgHtkhEXc+UqPSvEUhhFFeeAmUzA4x1bJarxEYO0YufkVPErTdeU6evctVdcL0RarWXju8
	+omWFos6trkcr8msQZ/71u58iZCrGtdGktiv3T8LTus9k2yBATULnwQdGmzEjtaC7qg==
X-Received: by 2002:a17:90a:9505:: with SMTP id t5mr74252241pjo.96.1563769818004;
        Sun, 21 Jul 2019 21:30:18 -0700 (PDT)
X-Received: by 2002:a17:90a:9505:: with SMTP id t5mr74252161pjo.96.1563769817179;
        Sun, 21 Jul 2019 21:30:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563769817; cv=none;
        d=google.com; s=arc-20160816;
        b=Mhw4YAe5wPuG+81STUpBtX58dGeAABLbwYyRp/c4s3kXNTLt2gemBNILFAd/BHsDSQ
         53fOYQNDqwNMW7dAzthHOpJNS+5R/MIbrZb1/REkNQkvUv+hItJ9U3MFXxoZquJWfIhC
         3MOJS3LS/4lLr+P1Lo0L/eMdwpIS7SSNqADJ6JMl+YyPLx3ZdnmeHG0PwnQ/Ikqheqml
         XPyt5s4s1pj+ODd8H//9IwHq/fGD0uo33I6IaDsR+zoFL9QpxirYQahtlRGVRRB6CBeZ
         GaYG54IPbp8P6i4Qp5Kgjms4FY0DavxZnPT9YY5bKsyzc+RjcFbvJyO1a+BheIza56Cs
         INVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WbaMzabtgu3hCeOMPX09tru106PZHAIJnqruZQI71c8=;
        b=raTrLmnByrUhKrd9oJXshQz1DFsDcwrDZYsbmakEgUHW7j6M777C4SI4pvzwUM5+RJ
         Nm9XD7wz2dJh0ojdxw5OgFCwLs8lbV/MpbdSu4SLoeWGqCgqgscDnCCPl2K/dJbPPgAO
         Oez2LCeegS4IdOZYOCjmgBi6xW9uqkLFPDIfxiVvOP4ED8CSQPLNnly9JrSCrYjNdCvE
         Y9Wl2IObYBeBwY3SD2RCUW7wlNPYoJoYRwj6PG/a62t89ly6ZtdmOBiMoJ/8jBue8+Na
         6lDKerx/JDbzEoV05A+Z0n6h79xIgvOF1fGjplqk+AxWJJWdAgW6jakO/f6geZoLXig7
         +MnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=p3HGgaIN;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gn6sor46393970plb.66.2019.07.21.21.30.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 21:30:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=p3HGgaIN;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WbaMzabtgu3hCeOMPX09tru106PZHAIJnqruZQI71c8=;
        b=p3HGgaINx4UXmNtxMRxq9ZG6NzncIA85CDVJwUAyirDvW3yCo2di+TLZl5eFlPnNmI
         tKBmRpm/+GE33EtGsFzwMuLEx975vOoVhficjaLeRIsopct9Hcl7v/XU1KBwOEf2xMZN
         BHRmQquzbiIcI70dnx/HawsVNNS5fDl4FFWtUv/EmNTaCRi74oUprzweRieVqW1lCakX
         xGU3Yfp0T2yQHASWYcYkRONsVHYAjwfmIRSdrvV1yxpWlXG/IgI4pD2tDC41W7YDhh8Y
         2xv+vtpzYgX36LzrXQsbqLPBzjZi80AqFoHhWGNEYVEtoMdLjAhgYaYrgI/kXAfMuWv+
         Cbsw==
X-Google-Smtp-Source: APXvYqyKR4WrwxhhqPsiCdGlG1x0qIsswj14hIfFs7IMQOgAz1KccUwekZlyy0ZSOgH/yneXklBTJA==
X-Received: by 2002:a17:902:ac87:: with SMTP id h7mr75701953plr.36.1563769816971;
        Sun, 21 Jul 2019 21:30:16 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id t96sm34285690pjb.1.2019.07.21.21.30.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 21:30:16 -0700 (PDT)
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
Subject: [PATCH 1/3] drivers/gpu/drm/via: convert put_page() to put_user_page*()
Date: Sun, 21 Jul 2019 21:30:10 -0700
Message-Id: <20190722043012.22945-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190722043012.22945-1-jhubbard@nvidia.com>
References: <20190722043012.22945-1-jhubbard@nvidia.com>
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

Cc: David Airlie <airlied@linux.ie>
Cc: Daniel Vetter <daniel@ffwll.ch>
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/via/via_dmablit.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 062067438f1d..219827ae114f 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -189,8 +189,9 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 		for (i = 0; i < vsg->num_pages; ++i) {
 			if (NULL != (page = vsg->pages[i])) {
 				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
-					SetPageDirty(page);
-				put_page(page);
+					put_user_pages_dirty(&page, 1);
+				else
+					put_user_page(page);
 			}
 		}
 		/* fall through */
-- 
2.22.0

