Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B520D6B0028
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:44:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i127so1797018pgc.22
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:44:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v45si3467449pgn.379.2018.03.21.15.44.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 15:44:48 -0700 (PDT)
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Subject: [PATCH 3/3] fs: Use memalloc_nofs_save in generic_perform_write
Date: Wed, 21 Mar 2018 17:44:29 -0500
Message-Id: <20180321224429.15860-4-rgoldwyn@suse.de>
In-Reply-To: <20180321224429.15860-1-rgoldwyn@suse.de>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, willy@infradead.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.com>

From: Goldwyn Rodrigues <rgoldwyn@suse.com>

Perform generic_perform_write() under memalloc_nofs because any allocations
should not recurse into fs writebacks.
This covers grab and write cache pages,

Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
---
 mm/filemap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 3c9ead9a1e32..5fe54614c69f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,6 +36,7 @@
 #include <linux/cleancache.h>
 #include <linux/shmem_fs.h>
 #include <linux/rmap.h>
+#include <linux/sched/mm.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -3105,6 +3106,7 @@ ssize_t generic_perform_write(struct file *file,
 	long status = 0;
 	ssize_t written = 0;
 	unsigned int flags = 0;
+	unsigned nofs_flags = memalloc_nofs_save();
 
 	do {
 		struct page *page;
@@ -3177,6 +3179,8 @@ ssize_t generic_perform_write(struct file *file,
 		balance_dirty_pages_ratelimited(mapping);
 	} while (iov_iter_count(i));
 
+	memalloc_nofs_restore(nofs_flags);
+
 	return written ? written : status;
 }
 EXPORT_SYMBOL(generic_perform_write);
-- 
2.16.2
