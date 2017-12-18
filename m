Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3925A6B02BD
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:33:43 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id z81so6973432oig.16
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:33:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l64si3682131oib.279.2017.12.18.04.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:33:42 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 45/45] block: document usage of bio iterator helpers
Date: Mon, 18 Dec 2017 20:22:47 +0800
Message-Id: <20171218122247.3488-46-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

Now multipage bvec is supported, and some helpers may return page by
page, and some may return segment by segment, this patch documents the
usage for helping us use them correctly.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 Documentation/block/biovecs.txt | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/Documentation/block/biovecs.txt b/Documentation/block/biovecs.txt
index b4d238b8d9fc..32a6643caeca 100644
--- a/Documentation/block/biovecs.txt
+++ b/Documentation/block/biovecs.txt
@@ -117,3 +117,35 @@ Other implications:
    size limitations and the limitations of the underlying devices. Thus
    there's no need to define ->merge_bvec_fn() callbacks for individual block
    drivers.
+
+Usage of helpers:
+=================
+
+* The following helpers which name has suffix of "_all" can only be used on
+non-BIO_CLONED bio, and ususally they are used by filesystem code, and driver
+shouldn't use them becasue bio may have been splitted before they got to the
+driver:
+
+	bio_for_each_segment_all()
+	bio_for_each_page_all()
+	bio_pages_all()
+	bio_first_bvec_all()
+	bio_first_page_all()
+	bio_last_bvec_all()
+	segment_for_each_page_all()
+
+* The following helpers iterate bio page by page, and the local variable of
+'struct bio_vec' or the reference records single page io vector during the
+itearation:
+
+	bio_for_each_page()
+	bio_for_each_page_all()
+	segment_for_each_page_all()
+
+* The following helpers iterate bio segment by segment, and each segment may
+include multiple physically contiguous pages, and the local variable of
+'struct bio_vec' or the reference records multi page io vector during the
+itearation:
+
+	bio_for_each_segment()
+	bio_for_each_segment_all()
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
