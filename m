Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC3C6B02C2
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:52:01 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q185-v6so2891518qke.7
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:52:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c6-v6si1847013qvd.163.2018.05.24.20.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:52:00 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 28/33] block: kill bio_for_each_page_all()
Date: Fri, 25 May 2018 11:46:16 +0800
Message-Id: <20180525034621.31147-29-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

No one uses it any more, so kill it and we can reuse this helper
name.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 5ae2bc876295..c5e692d43f23 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -159,8 +159,10 @@ static inline void *bio_data(struct bio *bio)
 /*
  * drivers should _never_ use the all version - the bio may have been split
  * before it got to the driver and the driver won't own all of it
+ *
+ * This helper iterates bio segment by segment.
  */
-#define bio_for_each_page_all(bvl, bio, i)				\
+#define bio_for_each_segment_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
 static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
@@ -225,9 +227,6 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment(bvl, bio, iter)			\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
-#define bio_for_each_segment_all(bvl, bio, i) \
-	bio_for_each_page_all((bvl), (bio), (i))
-
 /*
  * This helper returns singlepage bvec to caller, and the sp bvec is
  * generated in-flight from multipage bvec stored in bvec table. So we
-- 
2.9.5
