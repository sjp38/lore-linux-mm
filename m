Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6716B0275
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:54:43 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a199so43307672qkb.23
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:54:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v8si263689qkb.11.2018.11.15.00.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:54:42 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V10 05/19] block: introduce bvec_last_segment()
Date: Thu, 15 Nov 2018 16:52:52 +0800
Message-Id: <20181115085306.9910-6-ming.lei@redhat.com>
In-Reply-To: <20181115085306.9910-1-ming.lei@redhat.com>
References: <20181115085306.9910-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

BTRFS and guard_bio_eod() need to get the last singlepage segment
from one multipage bvec, so introduce this helper to make them happy.

Cc: Dave Chinner <dchinner@redhat.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: dm-devel@redhat.com
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
Cc: linux-erofs@lists.ozlabs.org
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: Gao Xiang <gaoxiang25@huawei.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org
Cc: Coly Li <colyli@suse.de>
Cc: linux-bcache@vger.kernel.org
Cc: Boaz Harrosh <ooo@electrozaur.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: cluster-devel@redhat.com
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 3d61352cd8cf..01616a0b6220 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -216,4 +216,29 @@ static inline bool mp_bvec_iter_advance(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+/*
+ * Get the last singlepage segment from the multipage bvec and store it
+ * in @seg
+ */
+static inline void bvec_last_segment(const struct bio_vec *bvec,
+		struct bio_vec *seg)
+{
+	unsigned total = bvec->bv_offset + bvec->bv_len;
+	unsigned last_page = total / PAGE_SIZE;
+
+	if (last_page * PAGE_SIZE == total)
+		last_page--;
+
+	seg->bv_page = nth_page(bvec->bv_page, last_page);
+
+	/* the whole segment is inside the last page */
+	if (bvec->bv_offset >= last_page * PAGE_SIZE) {
+		seg->bv_offset = bvec->bv_offset % PAGE_SIZE;
+		seg->bv_len = bvec->bv_len;
+	} else {
+		seg->bv_offset = 0;
+		seg->bv_len = total - last_page * PAGE_SIZE;
+	}
+}
+
 #endif /* __LINUX_BVEC_ITER_H */
-- 
2.9.5
