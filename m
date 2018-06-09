Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C08036B026F
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:32:14 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c4-v6so2670691qtp.16
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:32:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r86-v6si6237160qkr.36.2018.06.09.05.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:32:14 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 08/30] block: introduce chunk_last_segment()
Date: Sat,  9 Jun 2018 20:29:52 +0800
Message-Id: <20180609123014.8861-9-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

BTRFS and guard_bio_eod() need to get the last singlepage segment
from one multipage chunk, so introduce this helper to make them happy.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 9e082d023392..aac75d87d884 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -219,4 +219,29 @@ static inline bool bvec_iter_chunk_advance(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+/*
+ * Get the last singlepage segment from the multipage bvec and store it
+ * in @seg
+ */
+static inline void chunk_last_segment(const struct bio_vec *bvec,
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
