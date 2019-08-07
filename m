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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FAA0C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEE84217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oy39nkO9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEE84217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DF386B0007; Tue,  6 Aug 2019 21:33:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F34616B0008; Tue,  6 Aug 2019 21:33:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D86BA6B000A; Tue,  6 Aug 2019 21:33:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A06556B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:33:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o6so49406040plk.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:33:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=SfKxYtnE5oAzYwqpQgcAAlbhT1Lx9k5TwowTl1zxLBVWEiw6B6EpKx254nz+160iM3
         FkfLH3vXUkF54Jaiszgxsuhuzsa0VwKLGvlbU4Q+r2yHUxustUycuK4C1E6ZWiWx4j/n
         z8wYrCP0FQMHrEP3FkY0cR6P6Mnw9FyfjlS1cOITcEI97lMHLEx2FcUk6LIyqucCWSRK
         7Ey54T75B7OzA39jyXxtEfa/tcLFl28dtfux7BAyJQ4UMbAC4kQxQk3mz03rtp7A9BTD
         zRlC0jR4oxeFhAjRREkOqWtTlp0cMHZsdtziHYGX28yhys3SkZmD7HpNEsWA17meqrnn
         Ryaw==
X-Gm-Message-State: APjAAAUWujfJzN4BUrnGUOlGY6FaAFXpTdL393sS1IsP+LB9mTcBX/kI
	416MKbcSr/IbbmV6Q1gy1O5BcVuVqvO+pYeUQUxUsaEDWsueradiciOlRZeQBA/jtI9k4Mh/0+j
	nhj2DH0AmonATjocHfczk4s3TGh0hUl4hBJWt9VXG+6QTWEi1X4oP/ugtHBHvntHLIg==
X-Received: by 2002:a63:194f:: with SMTP id 15mr5668817pgz.382.1565141629161;
        Tue, 06 Aug 2019 18:33:49 -0700 (PDT)
X-Received: by 2002:a63:194f:: with SMTP id 15mr5668771pgz.382.1565141628236;
        Tue, 06 Aug 2019 18:33:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141628; cv=none;
        d=google.com; s=arc-20160816;
        b=LyYwlC+q/z5HBmI+NoFGYOhsm1PioyPa2hmVQcl17L414Y4zL+88sAXqH/x/4z0eDE
         QI+3b5+8mps8F3G7R8orbL7gmURK44hYHZUzq+NTHAFygQAUsOR6AO2DN6k1UeamzLLm
         9T3FMNwnnuJa36SYvjvhE7R+dIPDKHWWLDk7iLknAUZqMKqPwWVTIL48Lu1UvKAbs8yv
         dxV5MHa4oKUlkx3pMEA7vzzQ2lw5LWHU7x9gEGIWUWfy4r/hfWS+vd05QUIdq4LYvhPn
         JpVuvGM9ke1S43+hR3F+kpgfBOaQRoc/WoN474HxhdK6N3bRX2vMa9NjSMqTbZasBGzT
         o9Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=o59BwHeFv8yF1fBlBqjhCXUjzb85RBY3sWpEp04hbw5DdGhEVV/kwibcG30FkuzbyV
         2cT2BapkDHylhToZXfdjs1HN3x9jj6VCku9ipiXpPUY+9IIf/OygFICnBo4gimekgmZW
         LmettHlJyo4p/AibybDebAmwvIyiHxsYrmTYpJToY7YtzMSVBBzxAs1pxz8TOb3csuWH
         B7xDtKL1fXA3naV+NDSGijCAF2m05VaKpNmjgCQ35K3AwmYDj0nRLiwmk+CFn+dQAxPT
         L2vqtxRtRKIWzCnQRvo1HZWx06lqv4wdB2xsHFJOtWQxn9gLrfUPNPhNWE7t8t9EgEpG
         UZ0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oy39nkO9;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f30sor23849135plf.49.2019.08.06.18.33.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oy39nkO9;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=oy39nkO9q1zN/Pd7fO3C4Y4Vuneozl9x+qPetN0JbILtppFPMIJXMHmaepq54m3Jyf
         dGw1nmQHR/jSbWupXGSsRUasNJHlcTqjhcU1O3ugIdE2PmE9G2UKn/efT28f7zQkZ/Ek
         6jjzfDGA5QraOK0hXzeRVBVVIV3bR/w8Kh69UQWoMH+W+Rs7nDww5sxmxjDiUlnV+Y3J
         JNNDHJK/Y4qoZIHDRhd8qo6y5WM/sdBlLMt8Tk0CmXA/ZqUqxMK+oSWhp+t1g0ER8Qps
         3F4GSUTyaFhoBkjoAMVyL8y9bOwlhzuxjjb1EKe6sSD4G4rjFtE3kxZ1sD03IRQMEghY
         QO3A==
X-Google-Smtp-Source: APXvYqxzrRdxX4nRlyikVVwrMH2CyIAMqdQl6neWQaDEBd9Z3PCuWH0kRX4lRsXl8HO2TxD71Nthng==
X-Received: by 2002:a17:902:1122:: with SMTP id d31mr172269pla.254.1565141627872;
        Tue, 06 Aug 2019 18:33:47 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:47 -0700 (PDT)
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
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>
Subject: [PATCH v3 02/41] drivers/gpu/drm/via: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:01 -0700
Message-Id: <20190807013340.9706-3-jhubbard@nvidia.com>
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

Also reverse the order of a comparison, in order to placate
checkpatch.pl.

Cc: David Airlie <airlied@linux.ie>
Cc: Daniel Vetter <daniel@ffwll.ch>
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/via/via_dmablit.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 062067438f1d..b5b5bf0ba65e 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -171,7 +171,6 @@ via_map_blit_for_device(struct pci_dev *pdev,
 static void
 via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 {
-	struct page *page;
 	int i;
 
 	switch (vsg->state) {
@@ -186,13 +185,8 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 		kfree(vsg->desc_pages);
 		/* fall through */
 	case dr_via_pages_locked:
-		for (i = 0; i < vsg->num_pages; ++i) {
-			if (NULL != (page = vsg->pages[i])) {
-				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
-					SetPageDirty(page);
-				put_page(page);
-			}
-		}
+		put_user_pages_dirty_lock(vsg->pages, vsg->num_pages,
+					  (vsg->direction == DMA_FROM_DEVICE));
 		/* fall through */
 	case dr_via_pages_alloc:
 		vfree(vsg->pages);
-- 
2.22.0

