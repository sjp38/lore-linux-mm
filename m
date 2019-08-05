Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DCA6C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 02:32:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 539982075C
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 02:32:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CKraWwqk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 539982075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDE436B0006; Sun,  4 Aug 2019 22:32:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8E9F6B0007; Sun,  4 Aug 2019 22:32:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7C2D6B0008; Sun,  4 Aug 2019 22:32:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 942E46B0006
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 22:32:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t2so45334780plo.10
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 19:32:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=UZHhZu7UO1jH1fQJkZzMyLRgsNTiTLatRpcoqCnRJ18=;
        b=OKz1gXdMBa8s/AOt6ZksG13vzzR9HCCq2SDTQqdK2qXDXWOf5DUFSIJBibQAaObXdw
         1OvJ0+RBv8C5pQ05vNen1XUZTb4XqEBhmNBAWokJ+DqHGv/GXUFz/BMfc8OgQOEl/xaL
         61afx0hdxykKTgDmGx+SslyyV/W2qtf0VVb4Fc7fAKVZ61Ylp33iswWOZA1bdpzh2RlX
         i3qc/jTB98kC7mfi2PjqVzrU8gT+tzbTvq55uL2/nb49YxBije9N9RKFcj3vZ+4RmXvh
         6WulaJy66JseqQhcUJ9wPhLhrEgoVdfEPJhm14HhBcOO9IdyTotdUI6UTRnHS5tw9cEj
         wWRw==
X-Gm-Message-State: APjAAAW8K7Yt/qeOSBOJ7JeBid1VXsqbyEXzHeBLfrHMdJC9g9VWgH+9
	vEQRNB05GupmQmOmFAuaROo8OoNRTarHN87oDKfw/VwOwgjN1TcedaMWK+yrsf5Dz4MnuLWTKvY
	PJ2ejOzuCtHAPC7IveJ3qOEljpwpqxORW1GJ7ZLCXUPfe/IpaRhpEyYu+ooBnJOI1Ww==
X-Received: by 2002:aa7:98da:: with SMTP id e26mr70527614pfm.34.1564972330271;
        Sun, 04 Aug 2019 19:32:10 -0700 (PDT)
X-Received: by 2002:aa7:98da:: with SMTP id e26mr70527556pfm.34.1564972329204;
        Sun, 04 Aug 2019 19:32:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564972329; cv=none;
        d=google.com; s=arc-20160816;
        b=KD4/ybabCJUt6FcTQpUSNU01WAjin4xZCDZrTq3ZA+W+/LXtjuJAqMP/d0ce0yKYdN
         cob98j2P4DRMpg71UiAMEyT++Pm5zYb/Ln3Qpu8gNo1xeHsj9r8nemUnFdAOfkx7EBnt
         BlIviNiodDJjXHjfy5T4uremSjfWeGjgxuXGuzG2nwTOGQXXj0WiVYCd1OjnKqJip/AK
         UuD/EA9pnfc8rCgEZqFkSLtrgh9nOz8FJHTSWsNh3a0hxnaVA/hh11KBvvgxj/IBI90n
         ZOBnOvNZXxq+YP5/b0xSeaEeHhqJ3rmWgDONXGcTyX/ax88SRqnk3lG4wGnzHgSn8Y29
         IKyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=UZHhZu7UO1jH1fQJkZzMyLRgsNTiTLatRpcoqCnRJ18=;
        b=NJNXlSg+VbjHIFcJtE2nL4+FRSbebzuUor3EOQDTB2O5R2zxGKIPASU0Ds1ROtwl+s
         RcgXP4bm9mzLMvxCvsvK5n3ENx+D/tC8Gyl0kLJHteC+UIMIZKfrUTAoITz9+/9BWGqj
         L/w6JzmS3Y4zqJn0mHU3sbn68LVKw0U0YGh5l8/763kCPs8p/Bi1PXIJnr8mdCmQ+xD9
         jjNUKQUEM7QRhzYyL3jDZSHjtox1ZQ/LQ5U49Z2Bih0/xhav2BaiT8BuUk4rfVElPgzd
         +lpq8Ez7o5ZmOyi3AsWR23UNaYRQbkdRGrNjfIqtPDa9pyp0IFJuMcvbQXT8Z5DrV7lU
         O/Zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CKraWwqk;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g22sor63722815pfh.16.2019.08.04.19.32.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 19:32:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CKraWwqk;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=UZHhZu7UO1jH1fQJkZzMyLRgsNTiTLatRpcoqCnRJ18=;
        b=CKraWwqkZg3c2qd7Q6WpNuUpw+dh0cgfSan9Gc4M6oztcD2jYks4Hb4bo13E6rJErQ
         DuEnbjTFVBizjVe4SAifSMkHIVfWrYlU2SpY1yqvnSK9ALH06GWdibnMn+oDJEwWttwM
         8XEzY1NThUu/6KjyO2+/vNzjE1iJ93hyj7kKNrgI+4bFKwBxpqxmIcLvBXB2s/AREGLZ
         2yLtMRwvlAputd3raT0mu/uXk6A2qPMy/pwibQjdm/jNFkKe52tcH02yIHG/cbtBomqb
         /JwAbGqvZ/xlURNEF75r57r9uENgKlgqGcwtmrtgsfQt3aWi0bzleotTEDpQekp9eKkx
         mTAw==
X-Google-Smtp-Source: APXvYqyLrqI7gGqCgmIwbmF9a0CEz3uJYMrD1LI9rhekWLAO8LK0W3mWt00RvgrLzC1hsNBPyLQDdg==
X-Received: by 2002:aa7:86cc:: with SMTP id h12mr63989613pfo.2.1564972328962;
        Sun, 04 Aug 2019 19:32:08 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id y128sm102095363pgy.41.2019.08.04.19.32.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 19:32:08 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jens Axboe <axboe@kernel.dk>,
	linux-block@vger.kernel.org
Subject: [PATCH] fs/io_uring.c: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 19:32:06 -0700
Message-Id: <20190805023206.8831-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
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

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/io_uring.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/io_uring.c b/fs/io_uring.c
index d542f1cf4428..8a1de5ab9c6d 100644
--- a/fs/io_uring.c
+++ b/fs/io_uring.c
@@ -2815,7 +2815,7 @@ static int io_sqe_buffer_unregister(struct io_ring_ctx *ctx)
 		struct io_mapped_ubuf *imu = &ctx->user_bufs[i];
 
 		for (j = 0; j < imu->nr_bvecs; j++)
-			put_page(imu->bvec[j].bv_page);
+			put_user_page(imu->bvec[j].bv_page);
 
 		if (ctx->account_mem)
 			io_unaccount_mem(ctx->user, imu->nr_bvecs);
@@ -2959,10 +2959,8 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
 			 * if we did partial map, or found file backed vmas,
 			 * release any pages we did get
 			 */
-			if (pret > 0) {
-				for (j = 0; j < pret; j++)
-					put_page(pages[j]);
-			}
+			if (pret > 0)
+				put_user_pages(pages, pret);
 			if (ctx->account_mem)
 				io_unaccount_mem(ctx->user, nr_pages);
 			kvfree(imu->bvec);
-- 
2.22.0

