Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA8986B02A0
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:48:57 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m7-v6so2924581qtg.1
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:48:57 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z60-v6si523950qvz.49.2018.05.24.20.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:48:57 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 11/33] block: implement bio_pages_all() via bio_for_each_page_all()
Date: Fri, 25 May 2018 11:45:59 +0800
Message-Id: <20180525034621.31147-12-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

As multipage bvec will be enabled soon, bio->bi_vcnt isn't same with
page count in the bio any more, so use bio_for_each_page_all() to
compute the number.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 3d3795b9a353..08af9272687f 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -334,8 +334,14 @@ static inline void bio_get_last_bvec(struct bio *bio, struct bio_vec *bv)
 
 static inline unsigned bio_pages_all(struct bio *bio)
 {
+	unsigned i;
+	struct bio_vec *bv;
+
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
-	return bio->bi_vcnt;
+
+	bio_for_each_page_all(bv, bio, i)
+		;
+	return i;
 }
 
 static inline struct bio_vec *bio_first_bvec_all(struct bio *bio)
-- 
2.9.5
