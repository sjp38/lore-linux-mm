Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2091C31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8B5221743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DBS4QEOY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8B5221743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8583C6B0266; Tue,  6 Aug 2019 21:34:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E8EC6B0269; Tue,  6 Aug 2019 21:34:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E98E6B026A; Tue,  6 Aug 2019 21:34:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4F36B0266
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j9so2032074pgk.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=UmfdJ/1TGpnN6Cc0qcE0Vn56Eoofa2EVts/NPicKMpGYtfsvp9YlsDJPuioeX2z8BN
         Hc+kEtYsEHGhGshTWoKtRzmcOgtGaQZybB9m0whLD2g3ac2LhdwHbPogy+YbAQvL1V6a
         gpZb4CCxqyaZRT+3UXRhxLPIPAzibobmwyLIFbVBrVCf2Yv/K176NJ5FDCRo1A5JqFNi
         H2Vhpy7KV/2k9RVvWlxffWm/1xN6ke/M1gL/RQ1TYSLoNjB13g8Kg1ZdWOQi+JCDrx/A
         zgMul6R1Lcm15vYfEQ/nWTXLWbg4/ezuluijAdu+87IOHS/3GKqd2zImRLYPBAc+OpNr
         qzEA==
X-Gm-Message-State: APjAAAWTqsjrfawEwG18FNV1337VSKo8NapZRCs2EmtZ1H+RUnD2yJMg
	EvBe5Ez8xNo38KgAmznUDPqsEc4IKfU2rN4WwIUp1GdA7oca0d6ji3XMnBikTR5X5e1OVMdpe4E
	XQHseOgA0NLA+xHh+uClTtw5shY5JkGtbOskNlwQEx6Qg9v5605CxQi4g6CcmocWhOg==
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr5971851plb.84.1565141639726;
        Tue, 06 Aug 2019 18:33:59 -0700 (PDT)
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr5971809plb.84.1565141639118;
        Tue, 06 Aug 2019 18:33:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141639; cv=none;
        d=google.com; s=arc-20160816;
        b=Foe4vlXPTRtWnfabwNTg3z8B/lhzQ/lDvmpym5INxd3eHiwwkCGwkDoNKdbk2x/ROk
         mOqKOpG15yodvSUFYjk2e9wH5tulR6dAM/+1++0CuzO5XnqaunOcBKjkssxvrw+14941
         +ClxQ+eKA+RTzqz1lqqazADKJU3+m6kFu+hkxAfYMcSKt951RX7ePQjlovT3sYt+YnVL
         XNAYEznr6fZZlsvPeVCohWUfEUjrR6ki1TC+R3Hw2r/sqgLlQJqYxAZcqqS6Oti1j8eY
         ExD/tmcgyaPRHrxNB5ZOnqcp2tZ4ILIh1Jnv6z8GBcnABb4Zl/Rm1mw1Y4H2VI0qgCT+
         lqwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=WZdN/wGrAxSyTkr7uaVBP6FIXN49oS8KOddf7luu6tK6EdtT7ujG94WGxkfeelsFKN
         BtK2nOQQxDvQdHIQ+esh50wAhxpRxz4iTn96hy3UU1j5KOEC7o9cz5a8aE0PTvu4XQ4q
         VJDXjayqhAA9T1WqUbtB88/XITWAcUPjG5BeHFBVMFV8qL3zYuh1v8lc56MEIgh+jCDT
         kv1tSydEUHFhiejRIXUH4v0M81akWlyMuoItIH7tk2+wsi+y3Yf7Y8OZYkP6M4QWII+7
         vcgE+rL1PWTmo+B5ZXxWxRgho9ZMI91fzyJT3pgiaUFnbi/iJXXjnR4uHoWlIs2aI5fD
         Mg0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DBS4QEOY;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4sor26077714pji.23.2019.08.06.18.33.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DBS4QEOY;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=DBS4QEOYd7JEbPuapIEybK6yPbT9yH436NCQH6rDrbBzuYucty6BaNvhoi5hH6v0CL
         JtOgJ70gNZTF533IB2dCY0X/unBQS7PQHTF2oj+dliPmRRfT3OJ5pHnotZJGhHxVZbfq
         YQRB/9ot1828nW5dFsiXI0WjJ5tnCXQL7Z7DBkE4dxbfbAjeZHXxEyOO1PgLYGM0R/tb
         bQj3p4j+QH0APLbNBrYDCK8UA7Rjj5eJjYvOiTQSaFgxud4esYtpeLsQ7vEEpZptaSxw
         yfJ/AgnnMUJmxUFLjnK1nFuoz+yKZ9OxcxA/Lu5XV7Z6R3lgOiOVPkE/r0yTZn6GHACF
         KMsQ==
X-Google-Smtp-Source: APXvYqy30p2NohP2KIU0EnEWVyTf80c7khXPPY91tyi1XYk0o5oiq5Uprgt54o6LNZgppKd61nE9YQ==
X-Received: by 2002:a17:90a:6097:: with SMTP id z23mr6014303pji.75.1565141638870;
        Tue, 06 Aug 2019 18:33:58 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:58 -0700 (PDT)
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
Subject: [PATCH v3 09/41] drm/radeon: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:08 -0700
Message-Id: <20190807013340.9706-10-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

