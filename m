Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8989B6B029A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:48:26 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x2-v6so2830343qto.10
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:48:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n12-v6si5817090qkl.306.2018.05.24.20.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:48:25 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 08/33] block: introduce segment_last_page()
Date: Fri, 25 May 2018 11:45:56 +0800
Message-Id: <20180525034621.31147-9-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

BTRFS and guard_bio_eod() need to get the last page from one segment, so
introduce this helper to make them happy.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 84c395feed49..217afcd83a15 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -219,4 +219,26 @@ static inline bool bvec_iter_seg_advance(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+/* get the last page from the multipage bvec and store it in @pg */
+static inline void segment_last_page(const struct bio_vec *seg,
+		struct bio_vec *pg)
+{
+	unsigned total = seg->bv_offset + seg->bv_len;
+	unsigned last_page = total / PAGE_SIZE;
+
+	if (last_page * PAGE_SIZE == total)
+		last_page--;
+
+	pg->bv_page = nth_page(seg->bv_page, last_page);
+
+	/* the whole segment is inside the last page */
+	if (seg->bv_offset >= last_page * PAGE_SIZE) {
+		pg->bv_offset = seg->bv_offset % PAGE_SIZE;
+		pg->bv_len = seg->bv_len;
+	} else {
+		pg->bv_offset = 0;
+		pg->bv_len = total - last_page * PAGE_SIZE;
+	}
+}
+
 #endif /* __LINUX_BVEC_ITER_H */
-- 
2.9.5
