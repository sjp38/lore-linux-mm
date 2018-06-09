Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 161FA6B0275
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:32:55 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p190-v6so15099096qkc.17
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:32:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h23-v6si534726qve.139.2018.06.09.05.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:32:54 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 11/30] block: implement bio_pages_all() via bio_for_each_segment_all()
Date: Sat,  9 Jun 2018 20:29:55 +0800
Message-Id: <20180609123014.8861-12-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

As multipage bvec will be enabled soon, bio->bi_vcnt isn't same with
page count in the bio any more, so use bio_for_each_segment_all() to
compute the number because we will keep bio_for_each_segment_all()
to iterate each page.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index e9f74c73bbe6..c17b8f80d650 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -339,8 +339,14 @@ static inline void bio_get_last_bvec(struct bio *bio, struct bio_vec *bv)
 
 static inline unsigned bio_pages_all(struct bio *bio)
 {
+	unsigned i;
+	struct bio_vec *bv;
+
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
-	return bio->bi_vcnt;
+
+	bio_for_each_segment_all(bv, bio, i)
+		;
+	return i;
 }
 
 static inline struct bio_vec *bio_first_bvec_all(struct bio *bio)
-- 
2.9.5
