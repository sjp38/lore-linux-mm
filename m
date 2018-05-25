Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B059E6B02CC
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:52:53 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id g12-v6so2792844qtj.22
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:52:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 63-v6si5192788qkz.182.2018.05.24.20.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:52:52 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 33/33] block: document usage of bio iterator helpers
Date: Fri, 25 May 2018 11:46:21 +0800
Message-Id: <20180525034621.31147-34-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
