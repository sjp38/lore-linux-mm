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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 310A8C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDFE4217D6
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:17:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ri/g8fH5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDFE4217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50D446B0006; Thu,  1 Aug 2019 22:17:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E4CD6B0008; Thu,  1 Aug 2019 22:17:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 386F96B000A; Thu,  1 Aug 2019 22:17:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F39D86B0006
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:17:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x18so47073311pfj.4
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:17:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=gKHAXkRC21Ub2hKMlujhWjvqZcAz9mfqMRLL0nDeHtNKMX7S5cNWpGGeIxJ8qm1J/5
         lsvT10awBoymp4HisNxmXCQxAZAIQYnYmMrR6RumaGIupwi6+dnt76P9i1A3jmEnPvPY
         42SITNCmB/w5NE2uEOPjO72VRBZSxK2fOd4pciiI6Atobi0KApk3jBNbN0R8jcLBRdS/
         YzSo0JCizcGOozzDCxwrU8OFOiHtm4OZx35d7QQuPKI7WnATfUn93N56Owe3RE0ilYeK
         fnKWDukfGQdRvZoSfL++Wpx8sxS5j+UDHVV8Nmhdr222jQG/jx5PLb/PGqkk+N/1eTF1
         ioWQ==
X-Gm-Message-State: APjAAAUropEqXel3nsD5hFK+C+W6S6nyX+mDE+ZkLckdezCwXRe455n6
	V62PkUljV823sdEJ+fw79tychMQFKJ+YPaDRNWXJYnzOlI5Ql8knf9tljLmdPYeOel+BJOtOCqZ
	cFod55f543fmoLP/T7puOgpmkwNCNIb6U77lgt+uvQNA3D7wxOOcTKCjJz0Lotwudew==
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr1908085pjb.30.1564712222567;
        Thu, 01 Aug 2019 19:17:02 -0700 (PDT)
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr1908044pjb.30.1564712221794;
        Thu, 01 Aug 2019 19:17:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712221; cv=none;
        d=google.com; s=arc-20160816;
        b=ROHrq0ufI7ejhkvN1XvA7Nwd6rM1l1ValFrkzgkPobQ1MAVZ/m+KKADbVDy4fDvoo0
         VhqL4VGOpl8Hj4bWw4VcGEIaRSNXb5lD/OBsaWjsFGmSNZNv0C37ra/KIYsv5EqdfGs5
         b0B+xz6HkOhgalxADoAcWQ5RfsWMZOlB563YDG30FbCNmb9NZObuQBw1s03u4sDuMruM
         Ra4klAjY8C8ZUcOJ+iIRBmN6O1ARSF0FINGJjK3DPrSGToLCK2AJTW5s0FVnKC7ihta2
         rYUvAxaCm7DGJHM18NbloHU1RyTKlfYuTFSIQNQQWEcnQ0fKVPBW5wCKjknYpEEatQHe
         dwFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=sY0La9B4RycbhvCj8hvd+2HFFUt9qulAiQsHMvh6N2MBA7g4+wgmfYUfiHoJKPqevW
         nGZkd/+waBN/IGrZcssTze8RJhQ+NmEiriHWqaBD5Nxi9OshmvvHWXuwNTxXhXHpuRvM
         oi+baFBfs6rYzqIgZKTB1f4ECZjdt18CS2Rr4Y6lv3xHSClxV3hFgG5JdkZK7eHdALeW
         zSb2V8Dh5mY/ZD/8tgljcosEaBQmqVgRcoLCNQpw/x0KMphQ/VE/roBbM9qB0ZdlA0ML
         Ti4ou0paBVz3+hsxE70kbQsSOd+1ikpkPFrYj30D4Qo82juEmIok6f4pvm76UQ7RKCto
         gzLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ri/g8fH5";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4sor8172794pji.23.2019.08.01.19.17.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:17:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ri/g8fH5";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=ri/g8fH5EMbaRGeRCBUMa0gqvf5sZKxxRTcoGNlKvndtobuEMarAmuyiWR0Or0yt3d
         ZgeLr0P+kW4cqW28KQH/rOYsII5pR9Pk0M0WFYUApB7SKz6vEgjXY+F34hxONagLYY9L
         Py6Blyj3NR1ZdTatlTm5llaJcajjxdcYrAkl23WVqTVg9XAD+0Qg+cC1rauwop+vVeNx
         bVVFBfM1nAEvoH8ncIKlerRWnqRBlhjzlfCDLJ981KoDXyQRyzFGpLUw/iRcSWFkJ5xl
         t+5zV5laKnX+3Bq/BiZ3lREDjIqp5Q8qRulPXvOqGHi7pfUVWIrfUbywjbnDPsqYnoHP
         +z/w==
X-Google-Smtp-Source: APXvYqzbu0fqyx1S9wHk9TZWdOKFNLR8W4aJ20JQpVBVWnaUPwqEe+RFqTrVv58Rvjaf0s5gNM1HPA==
X-Received: by 2002:a17:90a:ba93:: with SMTP id t19mr1809345pjr.139.1564712221494;
        Thu, 01 Aug 2019 19:17:01 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id p187sm118200292pfg.89.2019.08.01.19.16.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:17:00 -0700 (PDT)
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
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	"David S . Miller" <davem@davemloft.net>
Subject: [PATCH 02/34] net/rds: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:16:21 -0700
Message-Id: <20190802021653.4882-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802021653.4882-1-jhubbard@nvidia.com>
References: <20190802021653.4882-1-jhubbard@nvidia.com>
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

Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Cc: rds-devel@oss.oracle.com
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/rds/info.c    |  5 ++---
 net/rds/message.c |  2 +-
 net/rds/rdma.c    | 15 +++++++--------
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/rds/info.c b/net/rds/info.c
index 03f6fd56d237..ca6af2889adf 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -162,7 +162,6 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
 	struct rds_info_lengths lens;
 	unsigned long nr_pages = 0;
 	unsigned long start;
-	unsigned long i;
 	rds_info_func func;
 	struct page **pages = NULL;
 	int ret;
@@ -235,8 +234,8 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
 		ret = -EFAULT;
 
 out:
-	for (i = 0; pages && i < nr_pages; i++)
-		put_page(pages[i]);
+	if (pages)
+		put_user_pages(pages, nr_pages);
 	kfree(pages);
 
 	return ret;
diff --git a/net/rds/message.c b/net/rds/message.c
index 50f13f1d4ae0..d7b0d266c437 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -404,7 +404,7 @@ static int rds_message_zcopy_from_user(struct rds_message *rm, struct iov_iter *
 			int i;
 
 			for (i = 0; i < rm->data.op_nents; i++)
-				put_page(sg_page(&rm->data.op_sg[i]));
+				put_user_page(sg_page(&rm->data.op_sg[i]));
 			mmp = &rm->data.op_mmp_znotifier->z_mmp;
 			mm_unaccount_pinned_pages(mmp);
 			ret = -EFAULT;
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 916f5ec373d8..6762e8696b99 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -162,8 +162,7 @@ static int rds_pin_pages(unsigned long user_addr, unsigned int nr_pages,
 				  pages);
 
 	if (ret >= 0 && ret < nr_pages) {
-		while (ret--)
-			put_page(pages[ret]);
+		put_user_pages(pages, ret);
 		ret = -EFAULT;
 	}
 
@@ -276,7 +275,7 @@ static int __rds_rdma_map(struct rds_sock *rs, struct rds_get_mr_args *args,
 
 	if (IS_ERR(trans_private)) {
 		for (i = 0 ; i < nents; i++)
-			put_page(sg_page(&sg[i]));
+			put_user_page(sg_page(&sg[i]));
 		kfree(sg);
 		ret = PTR_ERR(trans_private);
 		goto out;
@@ -464,9 +463,10 @@ void rds_rdma_free_op(struct rm_rdma_op *ro)
 		 * to local memory */
 		if (!ro->op_write) {
 			WARN_ON(!page->mapping && irqs_disabled());
-			set_page_dirty(page);
+			put_user_pages_dirty_lock(&page, 1, true);
+		} else {
+			put_user_page(page);
 		}
-		put_page(page);
 	}
 
 	kfree(ro->op_notifier);
@@ -481,8 +481,7 @@ void rds_atomic_free_op(struct rm_atomic_op *ao)
 	/* Mark page dirty if it was possibly modified, which
 	 * is the case for a RDMA_READ which copies from remote
 	 * to local memory */
-	set_page_dirty(page);
-	put_page(page);
+	put_user_pages_dirty_lock(&page, 1, true);
 
 	kfree(ao->op_notifier);
 	ao->op_notifier = NULL;
@@ -867,7 +866,7 @@ int rds_cmsg_atomic(struct rds_sock *rs, struct rds_message *rm,
 	return ret;
 err:
 	if (page)
-		put_page(page);
+		put_user_page(page);
 	rm->atomic.op_active = 0;
 	kfree(rm->atomic.op_notifier);
 
-- 
2.22.0

