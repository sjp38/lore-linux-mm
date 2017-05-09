Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55A0E280730
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:51:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g39so1606965qkh.3
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:51:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 1si380560qkn.263.2017.05.09.08.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:51:07 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 27/27] mm: clean up comments in me_pagecache_dirty
Date: Tue,  9 May 2017 11:49:30 -0400
Message-Id: <20170509154930.29524-28-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

This no longer applies with the new writeback error tracking and
reporting infrastructure.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/memory-failure.c | 35 +++++------------------------------
 1 file changed, 5 insertions(+), 30 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 4b56e53e5378..be5f998a0772 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -642,37 +642,12 @@ static int me_pagecache_dirty(struct page *p, unsigned long pfn)
 	if (mapping) {
 		/*
 		 * IO error will be reported by write(), fsync(), etc.
-		 * who check the mapping.
-		 * This way the application knows that something went
-		 * wrong with its dirty file data.
+		 * who check the mapping. This way the application knows that
+		 * something went wrong when writing back its dirty file data.
 		 *
-		 * There's one open issue:
-		 *
-		 * The EIO will be only reported on the next IO
-		 * operation and then cleared through the IO map.
-		 * Normally Linux has two mechanisms to pass IO error
-		 * first through the AS_EIO flag in the address space
-		 * and then through the PageError flag in the page.
-		 * Since we drop pages on memory failure handling the
-		 * only mechanism open to use is through AS_AIO.
-		 *
-		 * This has the disadvantage that it gets cleared on
-		 * the first operation that returns an error, while
-		 * the PageError bit is more sticky and only cleared
-		 * when the page is reread or dropped.  If an
-		 * application assumes it will always get error on
-		 * fsync, but does other operations on the fd before
-		 * and the page is dropped between then the error
-		 * will not be properly reported.
-		 *
-		 * This can already happen even without hwpoisoned
-		 * pages: first on metadata IO errors (which only
-		 * report through AS_EIO) or when the page is dropped
-		 * at the wrong time.
-		 *
-		 * So right now we assume that the application DTRT on
-		 * the first EIO, but we're not worse than other parts
-		 * of the kernel.
+		 * Note that errors are reported only once per file
+		 * description, but should be reported on all open file
+		 * descriptions for this inode.
 		 */
 		mapping_set_error(mapping, -EIO);
 	}
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
