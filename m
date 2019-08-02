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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22A6DC32757
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C603A20840
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g/PNAVO1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C603A20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AB566B000C; Thu,  1 Aug 2019 22:20:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 335306B000D; Thu,  1 Aug 2019 22:20:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 187E56B000E; Thu,  1 Aug 2019 22:20:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D59B86B000C
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:17 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id p15so2815108pgl.18
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=weSPcOAlMB+nks0BWLOsxsBmAu907UZGrfndvq6oQnc=;
        b=SCZofcUrpvn/j+LPY8F9zc3BJ+vXlD1Kh/yxqS/KUob93I2XUinFmYDg4GU3nm9/eY
         H/cIuluDy5IFSzkZYUlAXtILWOhdvfnJiMK2xou54kToqstmLhrMgZobtFoKG1zX2FhY
         oVgmmFRI8EnQK+ReIBCyTwrO88uj0VhhEFx7CBhRM+LAf6X1WQDoWGzcs2m2A+8qCSUV
         JVU8ZeRFPWNzUuEq6+wOdHDI1d9+EAZ/ytOSxyoajOoo9PPlX0NfmCgSzg3VCAJJKVGJ
         a8BXxh7IeN1eoqMxUukaVktsZ1zEStRuDYQ83f+OgKcIh4xfwz+1+SE2etA4qtMuqhnc
         u+zg==
X-Gm-Message-State: APjAAAUubcgPpXxpCwgxMHUGWX/mXNXbrVF2iFwaqkEnJUoNqJGaoVRP
	yEGCCfoVeM4muUXW+exEPLi2kUZc/6Tdadj3OS0hlEHLxKowgcjhJQgIUMeuv2YfqZlm8d4X0OE
	/D30kwVfuH0gLNjjKOQTSAprzd/ln59DlD3+98Y479rAoYX4jJkUPd60Z2AGJJu3oBw==
X-Received: by 2002:a17:902:2ac8:: with SMTP id j66mr123173293plb.273.1564712417521;
        Thu, 01 Aug 2019 19:20:17 -0700 (PDT)
X-Received: by 2002:a17:902:2ac8:: with SMTP id j66mr123173247plb.273.1564712416705;
        Thu, 01 Aug 2019 19:20:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712416; cv=none;
        d=google.com; s=arc-20160816;
        b=D3EChVHO/WfnbSC29Oh2EQ/UxnVo73+mGqhE83rA5hMg+GAAJT13VMN5JbEnIGJPJy
         kfZvf2PoFXvJFIK5OtuirbGmHBB3ek9tRcQ82DM4uovozRnMpgZQbFkcdgRh+oGXwwGl
         cHoQuV13eiHzSfqeGyE0YPbZCkaGEj5vFGoC2A9q8gO2mhx91RkWaOAgo+FxD7Ka2VVg
         3glghlKZokS+QCT8UhK/wmTmxqAIwIq1rM8WfknKdTb1JuIl/44z2Cjnvs1jLVEXRa2Z
         ks7H/5nOKMs8HOAWzNwn1Vw9jxGeK7qs5yVGDkYmTSudoUFCBxLqLyMRd5XGDs7zbGwc
         +PKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=weSPcOAlMB+nks0BWLOsxsBmAu907UZGrfndvq6oQnc=;
        b=N5iDwgag+m9FVnGtMw/RZuimC5SkDmXMDMxZ3GVLbHBFuGXQKxJ5txhtAlMsGGt/Vi
         v6YjW8J5bYjSh+OVqkvqKLcYaTa6C6gTliQGFF3KSraWhI7cmqFXNB1LhAlXED1QXd/h
         rYYd3AIUFfjDq7HAFOCrMj7+d6GCNlE8kbt/8rucdz3NSs6wjK6Io41jSfeLuSJpnYDW
         xu46T205MyRa16pyv7HPKZ8TMyKxMwtyibrEEGy2twoV+guwx7gGMOU1gduhtuLuIOtM
         DTuAO1i5+o5B2EdKai7XwgWzKm9ulqU+n/2qg6YMHKig9BieKET07J3LrxGLQWlXAK/R
         myGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="g/PNAVO1";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g4sor89047610plt.30.2019.08.01.19.20.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="g/PNAVO1";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=weSPcOAlMB+nks0BWLOsxsBmAu907UZGrfndvq6oQnc=;
        b=g/PNAVO1jcA7rjmvur5Gi5SyBm+cHCwd0FZu0S4Yd4WKYY8nqKUy+Kjq5L8LbAIDam
         oq+DMw/apiFaV6V9t2AYTvJ0UtZRGdqpPgiFYeIHq5U9A659jHv3iijVBsi80zStn1WW
         yA7d3ZYX2ikKALXpz54vXEPMXgXSlYxT87JksMZBQueD34Vn0QLhvvHOTCuzyirgAxhY
         PS1hXIRKbtV044f7MD5ThhAFxJavcS5DN9nP30sURDOyWv4TACAbp0MhELnCZVrxEr+Y
         L5R1pu68TEBkTXOjXzFMyL79KTHMlgJNcYv+KmIulF31bskwh/7J7wKRv6nstiIy1Eix
         KMbg==
X-Google-Smtp-Source: APXvYqxciGgcMDXcQ3A2dbcQcp1f7eltXWtJvGVKyn0lRu+bq9UEFtA9QCl9A6sNDZqj7/W8XpREEA==
X-Received: by 2002:a17:90a:2385:: with SMTP id g5mr1977411pje.12.1564712416439;
        Thu, 01 Aug 2019 19:20:16 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:16 -0700 (PDT)
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
	Ilya Dryomov <idryomov@gmail.com>,
	Sage Weil <sage@redhat.com>,
	"David S . Miller" <davem@davemloft.net>
Subject: [PATCH 03/34] net/ceph: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:34 -0700
Message-Id: <20190802022005.5117-4-jhubbard@nvidia.com>
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

Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Sage Weil <sage@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: ceph-devel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/ceph/pagevec.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 64305e7056a1..c88fff2ab9bd 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -12,13 +12,7 @@
 
 void ceph_put_page_vector(struct page **pages, int num_pages, bool dirty)
 {
-	int i;
-
-	for (i = 0; i < num_pages; i++) {
-		if (dirty)
-			set_page_dirty_lock(pages[i]);
-		put_page(pages[i]);
-	}
+	put_user_pages_dirty_lock(pages, num_pages, dirty);
 	kvfree(pages);
 }
 EXPORT_SYMBOL(ceph_put_page_vector);
-- 
2.22.0

