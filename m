Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9D46B0270
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:24:30 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id c85so7040891oib.13
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:24:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d22si4220196otd.252.2017.12.18.04.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:24:29 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 06/45] dm: limit the max bio size as BIO_MAX_PAGES * PAGE_SIZE
Date: Mon, 18 Dec 2017 20:22:08 +0800
Message-Id: <20171218122247.3488-7-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>, Mike Snitzer <snitzer@redhat.com>

For BIO based DM, some targets aren't ready for dealing with bigger
incoming bio than 1Mbyte, such as crypt target.

Cc: Mike Snitzer <snitzer@redhat.com>
Cc:dm-devel@redhat.com
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/dm.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index de17b7193299..7475739fee49 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -920,7 +920,15 @@ int dm_set_target_max_io_len(struct dm_target *ti, sector_t len)
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
+	ti->max_io_len = min_t(uint32_t, len, BIO_MAX_PAGES * PAGE_SIZE);
 
 	return 0;
 }
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
