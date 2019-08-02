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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 182F0C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C23462080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bFa24Z5m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C23462080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD3BE6B0277; Thu,  1 Aug 2019 22:20:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C37066B0278; Thu,  1 Aug 2019 22:20:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAED46B0279; Thu,  1 Aug 2019 22:20:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75C186B0277
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k9so40739256pls.13
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=qq7aHc2YXwEJkV2UMq1eOL2T1OaTMVpPABaOIz6MY2L0fjtaSa1cIL40siFOZJLEBV
         19+dTINILwvGN+huNLnq5+I0QbA3ZvCuwka/7yE1y/EEaP8gSRxM6AIZRLBM7vgdQ3ud
         olcg0A+Igdj8c/4glUEUsJfpRWkHY53ITNg9mFJwRi10JWMT0tSXT9ix9DRitjYMP6VX
         YLORPxvz6fu7vb6vHD5bIa2Bs3pNBXHx1LyS55MyWxyds9HhDHtAiDPgadU8D3HBxJwF
         TUSTesoqgQALNqa3S8lKrayENwbFBWXr+Kp2qZe9PqMKzGOsu4IN3Rte8IGeEOAfJdVs
         1B7A==
X-Gm-Message-State: APjAAAWiZhG2ZWc8u68Eve8wrU/swBW2EBDC9LtWCi261oEhdJbOeK78
	jPfv6c99L+meZ5UBBGMFjes066dvmlknCQJCGLNJ0yMudH7ReGLYSwGHcrpHH4fX13bJo9UUa5A
	MgoEYtcw8utsQixJVpwbpzai8aOnoJDUOWMxAXIv/A4PSIrhtwmtyPX16BWrvO3kflQ==
X-Received: by 2002:aa7:9dcd:: with SMTP id g13mr58150346pfq.204.1564712447170;
        Thu, 01 Aug 2019 19:20:47 -0700 (PDT)
X-Received: by 2002:aa7:9dcd:: with SMTP id g13mr58150299pfq.204.1564712446587;
        Thu, 01 Aug 2019 19:20:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712446; cv=none;
        d=google.com; s=arc-20160816;
        b=KTdfMZnRghsdOL8e73JTBoxld0f1lENJ5D7E6yfLZmyRMQuvygjtng9lyouVQg7uWJ
         jHtyC/EXlp22smEU02yxs6+BwiaDNJulQAYRr8zjCGBL2Qfsh4iGMPUZyhJ2lHITBov7
         QyP8G4hx+VxO4eHkpIRrjXI4zdb5SMi3DRlis2mFuZ20LFcE0iZDMJ7Zh7cF6SECA8mg
         AxmsEOfgj2GXKcJkdH9IexwKP5t/pO9SDKuFi8g+ym5MGiOfDwf6jYSMZgEIsYot0nmG
         53dw4CPZyspkie/trKXI6lB+W5IT89mI9TYQi/dbJE0oZPOEy7x3fs7b5qCFEB2/LJND
         Jj8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=M1H8dNTolxbFw0mCqVIsqOQBZOG0mAX+1zfdP+J+QXTcrl5twEIY0avGVllQNaLAmZ
         Go2tDYtK6cAEP0aSOhU510tjOA4rrmvtubVOzGMKjEAIkjnERYBB1EnmEhUlrKNY8JvX
         WOhi28ObTDkKpw5v/I2QRfQFjHZvuM66MrY5sVSyXE0ZEzwSNQl/k3mBAi57s9GfnOhd
         i+v4sAHnea9l/+eLm18BkoXzYznkYmVtuvB/M+8rTvVa/Y2epxEwKvWBCsvSHJl+pfpg
         tZZiXf3ALOHwcxW5sxGwLt8Xupb3y8i2jcAhbQ4/TxzMtZQqunXbQluWvEmsbVQh9LZq
         hX0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bFa24Z5m;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p61sor8449572pjp.0.2019.08.01.19.20.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bFa24Z5m;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=bFa24Z5mQSzxC4eOzJ4+7AblweRywqOmLHClqtb5KdjCAjd1PUSEw/ZsQSQOyWjUsC
         1nWyBkhFn3Be02SULNTaYtTCG2J6o3/uRCn091UpjmhLyF7xPQy8wXw/xt4PRY9wiXXM
         V1nMLk4YhEUMXleXPkZw51V9rlN393l9K+gVXIZUF6ECoqP/Y8CZfCnooK6DgUB0tUD4
         eFt7VWtlBH1sk6kipujvSPJHkQR53+eHLV2iAcuMnAVCEWZM24hHRYthkAG8xQ/D08vi
         iFZfyGckqNCA5JtaUEszagJMdsqH6lCds+G1LZm6Cvnsgs6SuhZpo2MKRXwMzsClRxnN
         IVug==
X-Google-Smtp-Source: APXvYqxR/U1dL3txs9pGjSe+FwW9uMtR0k4KNaBNNpf6pbzUbZzBuQi9NPNfHMjGx+8Bx8bZmFuKIw==
X-Received: by 2002:a17:90a:8c18:: with SMTP id a24mr1817929pjo.111.1564712446323;
        Thu, 01 Aug 2019 19:20:46 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.44
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:45 -0700 (PDT)
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
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>
Subject: [PATCH 22/34] orangefs: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:53 -0700
Message-Id: <20190802022005.5117-23-jhubbard@nvidia.com>
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

Cc: Mike Marshall <hubcap@omnibond.com>
Cc: Martin Brandenburg <martin@omnibond.com>
Cc: devel@lists.orangefs.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/orangefs/orangefs-bufmap.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/orangefs/orangefs-bufmap.c b/fs/orangefs/orangefs-bufmap.c
index 2bb916d68576..f2f33a16d604 100644
--- a/fs/orangefs/orangefs-bufmap.c
+++ b/fs/orangefs/orangefs-bufmap.c
@@ -168,10 +168,7 @@ static DEFINE_SPINLOCK(orangefs_bufmap_lock);
 static void
 orangefs_bufmap_unmap(struct orangefs_bufmap *bufmap)
 {
-	int i;
-
-	for (i = 0; i < bufmap->page_count; i++)
-		put_page(bufmap->page_array[i]);
+	put_user_pages(bufmap->page_array, bufmap->page_count);
 }
 
 static void
@@ -280,7 +277,7 @@ orangefs_bufmap_map(struct orangefs_bufmap *bufmap,
 
 		for (i = 0; i < ret; i++) {
 			SetPageError(bufmap->page_array[i]);
-			put_page(bufmap->page_array[i]);
+			put_user_page(bufmap->page_array[i]);
 		}
 		return -ENOMEM;
 	}
-- 
2.22.0

