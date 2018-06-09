Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39D846B029C
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:36:14 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l29-v6so15557627qkh.1
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:36:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v19-v6si2845035qkb.310.2018.06.09.05.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:36:13 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 30/30] block: document usage of bio iterator helpers
Date: Sat,  9 Jun 2018 20:30:14 +0800
Message-Id: <20180609123014.8861-31-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

Now multipage bvec is supported, and some helpers may return page by
page, and some may return segment by segment, this patch documents the
usage for helping us use them correctly.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 Documentation/block/biovecs.txt | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/Documentation/block/biovecs.txt b/Documentation/block/biovecs.txt
index 25689584e6e0..3ab72566141f 100644
--- a/Documentation/block/biovecs.txt
+++ b/Documentation/block/biovecs.txt
@@ -117,3 +117,33 @@ Other implications:
    size limitations and the limitations of the underlying devices. Thus
    there's no need to define ->merge_bvec_fn() callbacks for individual block
    drivers.
+
+Usage of helpers:
+=================
+
+* The following helpers, whose names have the suffix "_all", can only be
+used on non-BIO_CLONED bio, and usually they are used by filesystem code,
+and driver shouldn't use them because bio may have been split before they
+got to the driver:
+
+	bio_for_each_chunk_segment_all()
+	bio_for_each_chunk_all()
+	bio_pages_all()
+	bio_first_bvec_all()
+	bio_first_page_all()
+	bio_last_bvec_all()
+
+* The following helpers iterate bio page by page, and the local variable of
+'struct bio_vec' or the reference records single page io vector during the
+iteration:
+
+	bio_for_each_segment()
+	bio_for_each_segment_all()
+
+* The following helpers iterate bio chunk by chunk, and each chunk may
+include multiple physically contiguous pages, and the local variable of
+'struct bio_vec' or the reference records multi page io vector during the
+iteration:
+
+	bio_for_each_chunk()
+	bio_for_each_chunk_all()
-- 
2.9.5
