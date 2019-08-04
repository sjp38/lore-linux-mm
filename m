Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05650C19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3EA621849
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ep9s674E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3EA621849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA2A66B0270; Sun,  4 Aug 2019 18:49:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28FE6B0271; Sun,  4 Aug 2019 18:49:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A1AC6B0272; Sun,  4 Aug 2019 18:49:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1F06B0270
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so45055645plp.12
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kTcRkfjdEL9HxbTfItIV90QFm+wmUvO1k55I5bm4do4=;
        b=bbPkGZODxSZAtwqrellL2LNQAuTq0Bo/SShSfgYmi7u4PH8D+uW7fI+N97tFLTUt3W
         skCuxPZHLA0JzSCf1uGOoHlUTQfb4ruBSRk0n7W16izzrpaoSfXHmHFT7euOJVU0rIyu
         mSqAe5hyLcNRL3sBqFjjaW8zwY+fKXDU9bDfW8Gks5NQbAq29X2ACyPXvMtYe2sxto6N
         eKk5oQMy7YLrm875XSogsW2Ur4upWWtvN2ED9GECaXZ2BuvHRgzmtCLjZSsMP8sJuB9A
         DzaXwZ4VHuovyb58+BoLXsIoyJm1wYkttlUU2n2gDNRroIhoqzhcVycWA14v75loAT9/
         hvfQ==
X-Gm-Message-State: APjAAAXxEz+9ht7o8kgUlKiPz80uwA4swEGFv8qAtJ84PE/ln36KzFtt
	Ra0uogk5zSHs3yyHKRjR/HN0MAjQhrsMa4hoaKP3U+AUaSnLdyseLO0uCVlOhS8fM5EELl5yi4k
	TzJxiNHrYFLhTQvVZGheqcjI/xjDei7xU2g+w7ViFyt0sWKBAsj28RRRbISULnP8ABw==
X-Received: by 2002:a65:57ca:: with SMTP id q10mr137715314pgr.52.1564958985923;
        Sun, 04 Aug 2019 15:49:45 -0700 (PDT)
X-Received: by 2002:a65:57ca:: with SMTP id q10mr137715263pgr.52.1564958984947;
        Sun, 04 Aug 2019 15:49:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958984; cv=none;
        d=google.com; s=arc-20160816;
        b=xpg2bezfKFzzkiYHko5ebvOtKR7kLSLN6VH6RAX2P9b+BkW+PLeDRMK+CZ2jporXoT
         RoXRf2QGq7/42KBlFGk/iyEjUuQGlNNMcQFbS9qssELt02O7tOCt2madW55VPG55rqbt
         Q5i07eeb5C4b/fizVjr7UIq3hESlWykZs36XXlYAMSxxpRU/JSjd/ubP3+gn66iPdstQ
         tsE13sdBvbSWJDWvWSlDKQHvXiaj6sMKzhTG4mpb5fkK1NEmNNmCaCB0PFm54swSHMoF
         DR2RcM6WmZw8ALw2B6BidmBpv5zI1ML2zcGIH+2BhjMFTt3kMZRCWwXefnJm7e/3PcrH
         Obvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=kTcRkfjdEL9HxbTfItIV90QFm+wmUvO1k55I5bm4do4=;
        b=ID04uPn6a/Liug/scN7sxIVn+nJQbtjmVLnMDolKBTjQ4aEXRqC/CrBnD7djirpnOn
         vx+nqBlKBWtIz5Pu4ch2Lm4LMnYqfbvgqV6gvXVtwE9vRpWeO8g4o7U7CQDNc0rBTQfD
         HCrMIu0M/UM5FJ2AndU9gEs/o1HDEknESk0R76SlIzWea+oBK98D9vZZYB9yt+NWQLdS
         CECPO2vGMm2a4grQR9N69sV4csgX9fBnNvyfZxRdR62HThFjGAJSJClJPST/3lPm3DKx
         noDw+4RBoaV4T/ENTUu415K0z6Ju8cCsz1WjhNjSuUP0kz6gt7kUIDSdnhitLlVGfySB
         gcag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ep9s674E;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 134sor10072551pgh.67.2019.08.04.15.49.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ep9s674E;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kTcRkfjdEL9HxbTfItIV90QFm+wmUvO1k55I5bm4do4=;
        b=Ep9s674EttVY3vG9GU1V4CO0VAp8GtJx3E70Bw+ivefofNFR36jNbbRP9fe5FIQZE4
         umVMqO9egu8yEOZzzqqbwwV1I7DYNsWdtnMpjSDCOFHvVqNv36JvlrRHoOsRwSxTWTVP
         /zl1MVdDjGI3HP9tmkhM/nHneNlxFDUc/CIkN9kekhNbRfvwnuxQq6VAF9qYXEoT57y3
         qK7R3sgIPEBixUJFK2/dzWLhYDFU1YjPdLTEb28hPm7RM/mK7OCKl8gL81RQyvUkO6K/
         G7Yqf9jdy89IiWSIhZQ4nu37WAPJIhU0zlRaxZyxotIkxhGrgPKDGLU2Jo37XMi2DkW4
         GJ3g==
X-Google-Smtp-Source: APXvYqxK0LrtPmyfw6JWYh2YgP6+bfFhY9MmK0zn3g5ZQLaZJtrpA2Yd1v8gV+8lSuqs4iprBin/bw==
X-Received: by 2002:a63:c442:: with SMTP id m2mr4964322pgg.286.1564958984667;
        Sun, 04 Aug 2019 15:49:44 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:44 -0700 (PDT)
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
Subject: [PATCH v2 16/34] drivers/tee: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:57 -0700
Message-Id: <20190804224915.28669-17-jhubbard@nvidia.com>
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

Acked-by: Jens Wiklander <jens.wiklander@linaro.org>
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

