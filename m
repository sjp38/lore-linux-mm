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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30070C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC6CD2173C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EFr+1Ao3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC6CD2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B7DB6B026F; Tue,  6 Aug 2019 21:34:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 042D06B0270; Tue,  6 Aug 2019 21:34:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D395A6B0271; Tue,  6 Aug 2019 21:34:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA866B026F
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l12so9327528pgt.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=NLBZvKwyPr0lv8cBtTcD76iEYceqHabEHUNgZD0Zi8/jw0F31pFjzwWX4CXrfrLUza
         tsEgZ10ZEpDynTB+8UkACz/XZ5vinKPjiZBX6S2e8k+kPFfcLk5YZZnSt2LSRzQJhTCh
         GhhFhOdD3wsGVC5X/ONmtuOhXMQaC86EWMcklXMrmLBhoCoCjMFVpwi1MdsWFdkZ1Ryp
         XdlzYFlLqKzTLwvmY0A4F50MdKC+Nqdgh8adRZV1nqx3S3W5Okf6xa9qOMO/tgkyDXvL
         iiS/qEDvI0L2/WB24XM5B87acLdKW2xpf0QtokbP5bjdFm1XSCNerDY3nFWh02YdA9Dt
         /HcQ==
X-Gm-Message-State: APjAAAW1d8IO98jJr5yUiT1S+wXUgHQflRzGvzL8Yn6Eh1ZRFIh6+e/N
	VSicX6ljl3X7g6450H5F7AV5G9jE+o6RWkc1CGCEsW2FxD6Ac0K5o/ax4F4wMA/Ium2SeMQb6M8
	TXD9aFqYLNrElxuWw80bxz2OcGgkeqSON+26xBCKBi6qSrBaAuP0PTIvh5Ce/ZMcOCw==
X-Received: by 2002:aa7:8f2c:: with SMTP id y12mr6987033pfr.38.1565141651253;
        Tue, 06 Aug 2019 18:34:11 -0700 (PDT)
X-Received: by 2002:aa7:8f2c:: with SMTP id y12mr6986976pfr.38.1565141650355;
        Tue, 06 Aug 2019 18:34:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141650; cv=none;
        d=google.com; s=arc-20160816;
        b=HbhJXR58hwp+l0ARAy7BwK3be/0BiCqgzEaiySBZXV2O3Xu1zLnMOl7oCHIZs6bvXR
         kzruvsjoy8VGFu52jADxjOWYQfXlM+AD5jVxfXDYFrV0hvv+NM5We/ooW4E+Vt0XI6Dv
         PB2m1qLt9eTkL0L/CSPGbjJg+A2T2byRSQ+0mpqnB5NbKhW5QLE0Mw2KTQYQx708zQ9C
         dfQ8XZhnxAcZIqlXwh36dmr40wSjh3d+ZEEW4qymFXqy3t2NUyZNTiYnjBm2LhsRDoE1
         rp/DZg2wbYQrS7DexMqqsaLYMEGIWey4EXz4bduIJ91oVyHXn1mvnn+2ZTw+h1i/bKTh
         3Hjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=tekx5sbnVxphvj+Cho7wi8HomDUXQUhrlucn0BSq4jJXULWmLuj0YiRP3LF38/UBsk
         72d/80+Yjm9VtaWHD0ya06mK7cA9sJje8D44FDPuDxndb6O5iicUXG8Bg6qy2KY4oSEs
         yhY+RPiJn7uQv8JVHBz3Qn/3AWMKCxsxL1fz3rLbPyLJ2WNO4aAHoUYSDRMNFiEVpyiA
         mYv3ZBxTd2u0tsVjIUqoGCAjPaxHGSzZF7PigZsjs6PzfQ+K+YaYLkwXeTsUqnYa5Beu
         yrRjrbbqflDjRocHGF/Bnh8HV+AwWLlbcBsBGmV0co31sW8EdlOdwg5MTmx9k+lknyCD
         YXqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EFr+1Ao3;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor106774691pld.15.2019.08.06.18.34.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EFr+1Ao3;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=EFr+1Ao3qBWmnJE02e7LcpB6YUVuRVbr9fx2rTH0O8yhq0D77M0YGPm0P+jSp6Jtuq
         2YlUZC321Nw3VSKn/00GLAANBgeiSrRJFaGZRoVjMnZ04FL9NLT6sKwnd0vV7JxKBdum
         Sqd0ag8jbhm9lcgz/XGxcy282zyTuU0Inaax4Btd/pAUlY3wTglSAc2wTFu9hSsedu/U
         Ux8BLgDEL4leQ7GXOOnEQmGonJeNt4nNmRZIhNi+Q94mV14xLfJWcwz4/pgXWu55VGQ6
         7Ogfd27qokaRQiNc+s9HO/wimpOVcSkVDqUWnVlQuzAm83PkUtGh2xlJDzKo+0GLPz99
         7D+w==
X-Google-Smtp-Source: APXvYqwoNo1PQmUv0ey0ILQvIwCoxxeyMFQeV7g8XASyN0XYGLEtQs3kplEx5vqWyqtJhS4NAvKAHg==
X-Received: by 2002:a17:902:20e5:: with SMTP id v34mr2979392plg.136.1565141650096;
        Tue, 06 Aug 2019 18:34:10 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:09 -0700 (PDT)
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
Subject: [PATCH v3 16/41] oradax: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:15 -0700
Message-Id: <20190807013340.9706-17-jhubbard@nvidia.com>
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

