Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 955848E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:04:06 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so16114396qtj.21
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 03:04:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p8si2509811qki.221.2019.01.11.03.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 03:04:05 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V13 09/19] block: introduce bvec_last_segment()
Date: Fri, 11 Jan 2019 19:01:17 +0800
Message-Id: <20190111110127.21664-10-ming.lei@redhat.com>
In-Reply-To: <20190111110127.21664-1-ming.lei@redhat.com>
References: <20190111110127.21664-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

BTRFS and guard_bio_eod() need to get the last singlepage segment
from one multipage bvec, so introduce this helper to make them happy.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index d441486db605..ca6e630f88ab 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -131,4 +131,26 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+/*
+ * Get the last single-page segment from the multi-page bvec and store it
+ * in @seg
+ */
+static inline void bvec_last_segment(const struct bio_vec *bvec,
+				     struct bio_vec *seg)
+{
+	unsigned total = bvec->bv_offset + bvec->bv_len;
+	unsigned last_page = (total - 1) / PAGE_SIZE;
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
