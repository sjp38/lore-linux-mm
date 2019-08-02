Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54229C32753
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10FEA217D7
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ICzJUrYT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10FEA217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 113C46B0271; Thu,  1 Aug 2019 22:20:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09EB66B0272; Thu,  1 Aug 2019 22:20:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5AA76B0273; Thu,  1 Aug 2019 22:20:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE6666B0271
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so47044447pfk.14
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CBO3xGCo70BH915jG2N5Cwh2jdAxvuNp3xf6kgL3BUo=;
        b=TFC/5zLOY0aQjpi7xc2soor1hYrnxVZDS6v1FMeWRatHoAcJBqAuseCZZQ/fazhABa
         lIvwLG0260m/tfXiNbV/zNazGpHq41kBmH/h1LNo702DGkxC5N+x2z6K9rRzhwU4UyuN
         qdAVMz5aFJTZCBos7MkdfgT+tadS+bg+wBr4UoXiogzBcxn6+LvoX1pCIav6sofYPhqP
         wJx+vDNPbSgalAdVl8REXMMLlS7we9WPAV9EC48oEIRwQd1/ZJ/6ppYdV8dL81PSAoqk
         Y0lYgHxSvESk5Aw4X9suP5+clevAHFDc8f6zRaBQwxJWuFMp9neBbEkfQe2TOOh2fIsg
         MWzQ==
X-Gm-Message-State: APjAAAWMyMRM4x+L1UBtafV/qILV2JT+YoVTiWcRP3Dv6NaBZ+WbTXK8
	SevgQqYSMOv+KaTDvLWeljaozj1XnRKyKLjdd7X/mm+dn7vMMrjrFNeH/7TnP1j22Pb8N/0fJqR
	N/eVoUzZ/wwmDC/zibgxs/WzVMoQKjNtAqKH7AfSLNY0M3EelEZ5oYdd0UCWYpWOxLg==
X-Received: by 2002:a62:6:: with SMTP id 6mr55781262pfa.159.1564712438405;
        Thu, 01 Aug 2019 19:20:38 -0700 (PDT)
X-Received: by 2002:a62:6:: with SMTP id 6mr55781211pfa.159.1564712437734;
        Thu, 01 Aug 2019 19:20:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712437; cv=none;
        d=google.com; s=arc-20160816;
        b=ouO8ewB7ucqA9MFg3CeYE6f4u1gmIm9KdsK9mBzAG7d4UhtD1eCwcfjeHYsdIRIsWd
         84iMtjycrmHsrZZkrXbtktQulPpCylBa9KbI6I4WeLK6HA2ESlIdBdvBBDmwkurE93qt
         rPqRKed05khAOOGXue8Gh2SSIM4ld6/09UhkHrepBYApUUt9K/AfU4gpzpZQCeYNS0QG
         mTFR5tEVaAokAc8/Qk7ei+zI03F3Fh2toL4JJQqYdXXDpUd2w54BaYF4Zfa05sI23Bgo
         ITSCyvPiMe3qwb6oJdEpCVLQliZ+Fw1yQfieQ+fCZWlaHYga00HSk2qg/d761QAvYvr2
         WBnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CBO3xGCo70BH915jG2N5Cwh2jdAxvuNp3xf6kgL3BUo=;
        b=qMGel11o46pWFJfOvKOfn6eN+c+11H/oJlQ31P4o2ntFxsFEMv11iG0ESSu3+cY4k9
         rur/eZG5FgdjoD28xafP99N3agB7ZgztxN/qLHo9f2bKjdbGZkgCn6ALYdCBiWwA+bpG
         xXnb/TLFWkhuKi0I3VCPHG13bSsCPV31XjKMViJ4glYmKREcAye2JQq+/ZlCcNTXDaLI
         8CqwLzF4S41b03nKanQNESoYy7L9j1Etf69t+FYs7yyz3IS9dqTDChsOC+rdFMpJFWgl
         6fXpsqzeFfdsHkgwkiZSB6Njc4ixEouF3W6l4zIYa/CVsl92zuTKq9NwFeVO7pCKs1st
         moJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ICzJUrYT;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2sor15198017pgh.45.2019.08.01.19.20.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ICzJUrYT;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=CBO3xGCo70BH915jG2N5Cwh2jdAxvuNp3xf6kgL3BUo=;
        b=ICzJUrYTaIdsry/DtrBHUvha+R1kZxiR3TimqNDYFmB7o5jfa7m5UsfpaX/zpz7gqG
         QDNhfomKE98We8ADhaaApqL24L4GLju/2Iqw8fB/Gdc8zIwCPKElMlCmrcylshjiY6HA
         Wpq/jdgFFEI2UXPzsw4kiY3k+2UuXyC1t4Wgx970D5YK3PPwUf+ffB7bQXfIs3z5ka8f
         jIxsm6PzFlXfLaS3w/r9zrOwtEfiVXxBJ3zPq4sXYknfWxx8T3YIHBMUaH+laDDR6clX
         EbIaZCmFhhDYcIMZgiNQmuBlXcj32bO5TFJ498KeDHFEPtpyis1t2GqB2XiuUnW1fIm6
         uMYw==
X-Google-Smtp-Source: APXvYqxkmOrmri+Wx3FPhMPhDHr4oTLl0gd58UJ9/zI2U5cFZ+LG43cVChESIiZ/iGIXbamewPD5YA==
X-Received: by 2002:a65:51c1:: with SMTP id i1mr101132075pgq.417.1564712437381;
        Thu, 01 Aug 2019 19:20:37 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.35
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:36 -0700 (PDT)
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
	Jens Wiklander <jens.wiklander@linaro.org>
Subject: [PATCH 16/34] drivers/tee: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:47 -0700
Message-Id: <20190802022005.5117-17-jhubbard@nvidia.com>
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

Cc: Jens Wiklander <jens.wiklander@linaro.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/tee/tee_shm.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index 2da026fd12c9..c967d0420b67 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -31,16 +31,13 @@ static void tee_shm_release(struct tee_shm *shm)
 
 		poolm->ops->free(poolm, shm);
 	} else if (shm->flags & TEE_SHM_REGISTER) {
-		size_t n;
 		int rc = teedev->desc->ops->shm_unregister(shm->ctx, shm);
 
 		if (rc)
 			dev_err(teedev->dev.parent,
 				"unregister shm %p failed: %d", shm, rc);
 
-		for (n = 0; n < shm->num_pages; n++)
-			put_page(shm->pages[n]);
-
+		put_user_pages(shm->pages, shm->num_pages);
 		kfree(shm->pages);
 	}
 
@@ -313,16 +310,13 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
 	return shm;
 err:
 	if (shm) {
-		size_t n;
-
 		if (shm->id >= 0) {
 			mutex_lock(&teedev->mutex);
 			idr_remove(&teedev->idr, shm->id);
 			mutex_unlock(&teedev->mutex);
 		}
 		if (shm->pages) {
-			for (n = 0; n < shm->num_pages; n++)
-				put_page(shm->pages[n]);
+			put_user_pages(shm->pages, shm->num_pages);
 			kfree(shm->pages);
 		}
 	}
-- 
2.22.0

