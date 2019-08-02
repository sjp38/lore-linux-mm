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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B55CC19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC6642080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F6zwcO4L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC6642080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 224436B026F; Thu,  1 Aug 2019 22:20:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D5FA6B0270; Thu,  1 Aug 2019 22:20:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 050166B0271; Thu,  1 Aug 2019 22:20:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2A166B026F
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:35 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q14so47138309pff.8
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=Q0uqyhjDn5CAHW1mIYEldoESJTNTYtWB7EhVn9sTRY1eea0CVgJs1pdpYQXPobtBeC
         q5hF6BuuFAKjfjoHe8QGzHaT07GzfEVqhW05BOeZPJIRo0paflnpvCnnqVDugs24dcud
         uNIuB4IE9SOB4wcM97VV9Z8104GGtKhuDI3rlw9RXnOJlJPSYzbCH8TsPI4exaOHgLqk
         yd/nja/QEP7E0PtHTkO6rtIqZ2ZvwaJElOGNvKq01OC6LO9VwwDmBUnnxkmO/mJE1zoY
         K4veEBRFKNpUY8iqb3xQJw4IT5Sid5FbKCdrNgaa0N3e6D7jGfOkTKT4TX3My6J50BVq
         MhCw==
X-Gm-Message-State: APjAAAXkdng9AOyN1tvjZzs1xvdkdFY/3uJr4kxfaoVKPaH/Tt3w8u8h
	V9/LZ8lOSw8YwSIHGwY0Vv9fHOvQqRaH1D+bn2VUaOWLKvfyhL+wa+77s7lcmEg4V13/DQFW6ld
	WIk5i+jrdvXmRNss7caCioG86tfqe6Y8AkqWhbMMYq/LQ/CrXfY9W6UZYbX22O4S6tw==
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr33907607plz.191.1564712435467;
        Thu, 01 Aug 2019 19:20:35 -0700 (PDT)
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr33907544plz.191.1564712434448;
        Thu, 01 Aug 2019 19:20:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712434; cv=none;
        d=google.com; s=arc-20160816;
        b=hk1mhp3q5YL98kDMav+0aDiKJAgf3aUI6lpYy5z44937XKCAvttwSeZ5ypqYdvBlVg
         c/UHkhRG2s94FUWSM3yHSB4xo8sTVj9ibaqP1KdEW6IYFA6ENhC7Rwxp/sOjkRy3EXBE
         XnFVccfxBaHZivwN52ym+nmQybdpZnxSgde/7LlGqAkA8eD/ZnA0u/Q9j7ZHIERVLm+b
         BUh0cMKmr057SGQ+MZVgIuxE2ER3IkplT5tDyo+3DKVbgtJTaEGNWPXDwurLXq+X5YGn
         sDujTL2ot1XtHpM62m6nLVHWII18OhOwpcqCufUY1ZLGT4DMW4Tj8xGXErteOTuxN4kX
         VOOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=mQzYhe2mZFD3E3JcR5Fs/co/nIWVFa6+0nliPSDQJxzzLAK/EJml8AjN5uhAZTuRMC
         IwysVkN+6/oswf9iDre7nguG98hMWY4APzjxp8539wojaHAnxvjcK1Qp0qFHsgm6aJd/
         e0SkGuAeGcI9yhkexzbx2XcKptQWdtN8QgN9+vsh2X/12cxr5sM2Xlu2P4xxiDyxjSTo
         KJNVtU3qHc+Lj+A4nReibZGX3ApUuLlbndkwYh+rn+Aqt28ihLekCnNd0vicJdqy6mYe
         Qd4LsTxUhHLNB3tb2FeWt8s8Wc+sAGo3XzwYK+bOr1MBnKTwzUWvLs1bPMPF7g8c/P02
         9ckg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=F6zwcO4L;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31sor49670783pgy.17.2019.08.01.19.20.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=F6zwcO4L;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=F6zwcO4LIlIH0MhJxHttCJTdvFyVFQT/4arw8VEiUMf3H4eEoUX+759aMNEB4E5yQk
         Nz2fCbsNakzpI2Ix1oQ23cChuh59P2OEpLwWSX6x9IY/wvMOZe6lEWSb2zFdzp0gprdi
         y9rnyWNc6RyhaZMvzhG8ve4bXMhMFks51tm4rHvgstN2tswx5ZOG0+I0UrLn8K8liKz6
         o59abaE04tV7AfXXxMZta+A8VG8S0kkDg1uyI4tR9b3t+a4fVwe1pYra9FjftWzgoUTS
         x4tLp6R3lAg/evT8dl18ZgG3qJOUMIaQFDribAsCQyGjHMfkpuycFyZQ36o14QJqnxy+
         vrdA==
X-Google-Smtp-Source: APXvYqxawjrrBWhVHWqru35UkhsNUwOEktD3Ze9ukSGMVZSHmBDx+KHUyZVGOPhrL6EFpIA4EvvUgw==
X-Received: by 2002:a63:b64:: with SMTP id a36mr113099405pgl.215.1564712434076;
        Thu, 01 Aug 2019 19:20:34 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:33 -0700 (PDT)
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
	"David S . Miller" <davem@davemloft.net>,
	Jonathan Helman <jonathan.helman@oracle.com>,
	Rob Gardner <rob.gardner@oracle.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Wei Yongjun <weiyongjun1@huawei.com>,
	Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Subject: [PATCH 14/34] oradax: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:45 -0700
Message-Id: <20190802022005.5117-15-jhubbard@nvidia.com>
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

Cc: David S. Miller <davem@davemloft.net>
Cc: Jonathan Helman <jonathan.helman@oracle.com>
Cc: Rob Gardner <rob.gardner@oracle.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Wei Yongjun <weiyongjun1@huawei.com>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: sparclinux@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/sbus/char/oradax.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/sbus/char/oradax.c b/drivers/sbus/char/oradax.c
index 8af216287a84..029e619992fc 100644
--- a/drivers/sbus/char/oradax.c
+++ b/drivers/sbus/char/oradax.c
@@ -412,7 +412,7 @@ static void dax_unlock_pages(struct dax_ctx *ctx, int ccb_index, int nelem)
 				dax_dbg("freeing page %p", p);
 				if (j == OUT)
 					set_page_dirty(p);
-				put_page(p);
+				put_user_page(p);
 				ctx->pages[i][j] = NULL;
 			}
 		}
-- 
2.22.0

