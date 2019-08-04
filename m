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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DBA1C19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07D5221850
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IixwRKA1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07D5221850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F22346B000D; Sun,  4 Aug 2019 18:49:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED2F66B000E; Sun,  4 Aug 2019 18:49:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4F136B0010; Sun,  4 Aug 2019 18:49:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAAF6B000D
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so44493615pgv.0
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=RxC5cBQSqE4JVgNUIuPIbO9xTV82gmuqU7eAYjZUGKmSW7gZzbTS/thb49OXzSsJiy
         cEvqF+TvvBZuNrL9Ukarx1IWdZsLJGEDot0ZPV7TWFf6s0e8ojmOs+3TCIs5y9xDKzlu
         ngVrFYyBWe6al3a/na+DC8VmXi2ZKl0i7P8zNMDq4VD8q4Boy5hiw3fP4qj5mozA1ECa
         6Ng8NEPVh+9sTsXOPDwwvwW1RVuelNVYcKCEfgC5+Sz02fcSBnj/CPKaPIeGlrfoi0kO
         +thES3noqT0zmQD2cadOdbrB99z4eyJdsXCM+7nXMf1qFLj4PYGUXrvmolbpImOtFR2j
         +Evg==
X-Gm-Message-State: APjAAAWQyRvuc7U7QECGUAV7VIl7LeGXl6I2QyhW5bp9QvFXH3UXG3P6
	G4hyTT5Ycq+4GUijWbNZEKDQOUjgjXzPQfl7me684Kk2OwRfTCfImdDQAs1bwD6BMy5vvRI9HAe
	Bly2Tlnp7taGe1lEBsygk9YZonVuODrGTI+H50Zfvwx09VXFlZVeuaQkEJbaGrWxQYg==
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr144461261plb.237.1564958971266;
        Sun, 04 Aug 2019 15:49:31 -0700 (PDT)
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr144461236plb.237.1564958970450;
        Sun, 04 Aug 2019 15:49:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958970; cv=none;
        d=google.com; s=arc-20160816;
        b=01A6l9Enct+Gn3hY3tWOndZkyXzOalAvZ7DDVt+4S2xlIxrX3ovbH7S8Hfssq+SEyy
         Gh+OMy4Gw8fIvVP1b4ShQrKMcXLJBokR45V0RG+bS+Bulyp23OpR2MIVa/AV8fJ1aoHM
         zOzTA2M/M1blu1YeeIMhnoihbPt8UuFopcp3piz50xsfNG42hQeCvmg5PGtHb3CePMgX
         y0h5dHfT5i48nCBRKSc/MY0QvUkhLslxqh70E/nN6o6Su3rTFjHeZLjOHT6/XJtIMWVB
         d1aF3BrZnqBIaJj38L+e+GebJh0T0CqW4WUbX5O1vIfrzC8PB19+r0E8JK/N58i0nFxk
         rTpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=zGzb6KOzO7+oP5N9t9eS/d3diV4CuOHd7zg9javZleWoqHRnd9rh2e4eQWXtaz4rr3
         R8qi/sMqtZx+f3qFjlDVEKlmmLvgesoVdMjX/QwJT8x9IiQEP1DOivxBOgH/53P9ZGm7
         kxsQfQ1Ipqu+zyk2zf2FCqSuAIf2mBM7IazEdBxplI27OJjY5i7GL5mDMYyV517+1zMk
         kT2JWajv7DDa0rINN1swdogFKq2anQtJLU3ZiQVNyoluBJ0lS/sftgxJqDlDUDfqdqBL
         xXqG4tJNMPGNaH3eXr5j8mUivN1prCZRItfA16GmElkYsS6y3V9uPhr18RsZRkeiVgMh
         1Dpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IixwRKA1;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h90sor97579026plb.26.2019.08.04.15.49.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IixwRKA1;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=IixwRKA1QE3hWrmSzVu2XYy+JWLjNAQrucyf3NmNwYmsVM90KnIP/Y31YnkjOev47U
         W5BLgfFrXSW8PROIAFlomTaKNpVy1Vu5By67adxMe4BBJxN/wVE8FkT1LMOB065Mk0v2
         mSKCOGzenGHlXCxavESBy8UzJUM5v3SbHyYItPfvN0BCRa3ugcdFoCHED6cZcBJjkH8M
         ktZ6/qTMPJteWEcAIxyF4khSUAdUalV8iDMz2BZGmRYRaKNynSgB+6FWP696OD7W7rKp
         ihl6Zic4VgOX9hVo+fby0upSQX/BJURRdR3g7cpl9a4Zd0ppOamvzLqwtGuG3Jg66+lE
         8+nQ==
X-Google-Smtp-Source: APXvYqzkwKiNRyTGG1wY4vsK+VenpXGpZnU+FOR0NniR/kq9Ywi59tDMXfkUVow9nHIhYFHAcQFleQ==
X-Received: by 2002:a17:902:e282:: with SMTP id cf2mr143340556plb.301.1564958970256;
        Sun, 04 Aug 2019 15:49:30 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:29 -0700 (PDT)
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
	Alex Deucher <alexander.deucher@amd.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	David Zhou <David1.Zhou@amd.com>,
	David Airlie <airlied@linux.ie>
Subject: [PATCH v2 07/34] drm/radeon: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:48 -0700
Message-Id: <20190804224915.28669-8-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
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

Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: David (ChunMing) Zhou <David1.Zhou@amd.com>
Cc: David Airlie <airlied@linux.ie>
Cc: amd-gfx@lists.freedesktop.org
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/radeon/radeon_ttm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index fb3696bc616d..4c9943fa10df 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -540,7 +540,7 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 	kfree(ttm->sg);
 
 release_pages:
-	release_pages(ttm->pages, pinned);
+	put_user_pages(ttm->pages, pinned);
 	return r;
 }
 
-- 
2.22.0

