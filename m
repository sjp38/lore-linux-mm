Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D527A6B0298
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:50:51 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 12-v6so1792215qtq.8
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:50:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n10-v6si3941819qtn.198.2018.06.27.05.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:50:50 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 24/24] block: document usage of bio iterator helpers
Date: Wed, 27 Jun 2018 20:45:48 +0800
Message-Id: <20180627124548.3456-25-ming.lei@redhat.com>
In-Reply-To: <20180627124548.3456-1-ming.lei@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

Now multipage bvec is supported, and some helpers may return page by
page, and some may return segment by segment, this patch documents the
usage for helping us use them correctly.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 Documentation/block/biovecs.txt | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/Documentation/block/biovecs.txt b/Documentation/block/biovecs.txt
index 25689584e6e0..f63af564ae89 100644
--- a/Documentation/block/biovecs.txt
+++ b/Documentation/block/biovecs.txt
@@ -117,3 +117,30 @@ Other implications:
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
+	bio_first_bvec_all()
+	bio_first_page_all()
+	bio_last_bvec_all()
+
+* The following helpers iterate over singlepage bvec, and the local
+variable of 'struct bio_vec' or the reference records single page io
+vector during the itearation:
+
+	bio_for_each_segment()
+	bio_for_each_segment_all()
+
+* The following helper iterates over multipage bvec, and each bvec may
+include multiple physically contiguous pages, and the local variable of
+'struct bio_vec' or the reference records multi page io vector during the
+itearation:
+
+	bio_for_each_bvec()
-- 
2.9.5
