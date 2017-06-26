Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E10DD6B0343
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:14:24 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id l87so47679795qki.7
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:14:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l91si4325222qtd.7.2017.06.26.05.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:14:24 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 10/51] dm: limit the max bio size as BIO_MAX_PAGES * PAGE_SIZE
Date: Mon, 26 Jun 2017 20:09:53 +0800
Message-Id: <20170626121034.3051-11-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Mike Snitzer <snitzer@redhat.com>

For BIO based DM, some targets aren't ready for dealing with
bigger incoming bio than 1Mbyte, such as crypt target.

Cc: Mike Snitzer <snitzer@redhat.com>
Cc:dm-devel@redhat.com
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/dm.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index 96bd13e581cd..49583c623cdd 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -921,7 +921,16 @@ int dm_set_target_max_io_len(struct dm_target *ti, sector_t len)
 		return -EINVAL;
 	}
 
-	ti->max_io_len = (uint32_t) len;
+	/*
+	 * BIO based queue uses its own splitting. When multipage bvecs
+	 * is switched on, size of the incoming bio may be too big to
+	 * be handled in some targets, such as crypt.
+	 *
+	 * When these targets are ready for the big bio, we can remove
+	 * the limit.
+	 */
+	ti->max_io_len = min_t(uint32_t, len,
+			       (BIO_MAX_PAGES * PAGE_SIZE));
 
 	return 0;
 }
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
