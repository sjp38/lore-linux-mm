Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F67C6B02A2
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:49:10 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z140-v6so2893571qka.12
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:49:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s13-v6si1883248qve.15.2018.05.24.20.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:49:09 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 12/33] block: introduce bio_segments()
Date: Fri, 25 May 2018 11:46:00 +0800
Message-Id: <20180525034621.31147-13-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

There are still cases in which we need to use bio_segments() for get the
number of segment, so introduce it.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 08af9272687f..b24c00f99c9c 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -227,9 +227,9 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
-static inline unsigned bio_pages(struct bio *bio)
+static inline unsigned __bio_elements(struct bio *bio, bool seg)
 {
-	unsigned segs = 0;
+	unsigned elems = 0;
 	struct bio_vec bv;
 	struct bvec_iter iter;
 
@@ -249,10 +249,25 @@ static inline unsigned bio_pages(struct bio *bio)
 		break;
 	}
 
-	bio_for_each_page(bv, bio, iter)
-		segs++;
+	if (!seg) {
+		bio_for_each_page(bv, bio, iter)
+			elems++;
+	} else {
+		bio_for_each_segment(bv, bio, iter)
+			elems++;
+	}
+
+	return elems;
+}
+
+static inline unsigned bio_pages(struct bio *bio)
+{
+	return __bio_elements(bio, false);
+}
 
-	return segs;
+static inline unsigned bio_segments(struct bio *bio)
+{
+	return __bio_elements(bio, true);
 }
 
 /*
-- 
2.9.5
