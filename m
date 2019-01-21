Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8F38E0025
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:22:19 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w185so18690742qka.9
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:22:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k60si1995935qtd.396.2019.01.21.00.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:22:18 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V14 16/18] block: document usage of bio iterator helpers
Date: Mon, 21 Jan 2019 16:18:03 +0800
Message-Id: <20190121081805.32727-17-ming.lei@redhat.com>
In-Reply-To: <20190121081805.32727-1-ming.lei@redhat.com>
References: <20190121081805.32727-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

Now multi-page bvec is supported, some helpers may return page by
page, meantime some may return segment by segment, this patch
documents the usage.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 Documentation/block/biovecs.txt | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/Documentation/block/biovecs.txt b/Documentation/block/biovecs.txt
index 25689584e6e0..4a466bcb9611 100644
--- a/Documentation/block/biovecs.txt
+++ b/Documentation/block/biovecs.txt
@@ -117,3 +117,28 @@ Other implications:
    size limitations and the limitations of the underlying devices. Thus
    there's no need to define ->merge_bvec_fn() callbacks for individual block
    drivers.
+
+Usage of helpers:
+=================
+
+* The following helpers whose names have the suffix of "_all" can only be used
+on non-BIO_CLONED bio. They are usually used by filesystem code. Drivers
+shouldn't use them because the bio may have been split before it reached the
+driver.
+
+	bio_for_each_segment_all()
+	bio_first_bvec_all()
+	bio_first_page_all()
+	bio_last_bvec_all()
+
+* The following helpers iterate over single-page segment. The passed 'struct
+bio_vec' will contain a single-page IO vector during the iteration
+
+	bio_for_each_segment()
+	bio_for_each_segment_all()
+
+* The following helpers iterate over multi-page bvec. The passed 'struct
+bio_vec' will contain a multi-page IO vector during the iteration
+
+	bio_for_each_mp_bvec()
+	rq_for_each_mp_bvec()
-- 
2.9.5
