Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E57206B039F
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:27 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o4so41615407qkb.5
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s4si18004850qtc.275.2017.04.24.06.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:27 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 16/20] mm: don't TestClearPageError in __filemap_fdatawait_range
Date: Mon, 24 Apr 2017 09:22:55 -0400
Message-Id: <20170424132259.8680-17-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

The -EIO returned here can end up overriding whatever error is marked in
the address space, and be returned at fsync time, even when there is a
more appropriate error stored in the mapping.

Read errors are also sometimes tracked on a per-page level using
PG_error. Suppose we have a read error on a page, and then that page is
subsequently dirtied by overwriting the whole page. Writeback doesn't
clear PG_error, so we can then end up successfully writing back that
page and still return -EIO on fsync.

Worse yet, PG_error is cleared during a sync() syscall, but the -EIO
return from that is silently discarded. Any subsystem that is relying on
PG_error to report errors during fsync can easily lose writeback errors
due to this. All you need is a stray sync() call on the box at the wrong
time and you've lost the error.

Since the handling of the PG_error flag is somewhat inconsistent across
subsystems, let's just rely on marking the address space when there are
writeback errors. Change the TestClearPageError call to ClearPageError,
and make __filemap_fdatawait_range a void return function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/filemap.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d94a76d4e023..47e7f50fb830 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -363,17 +363,16 @@ int filemap_flush(struct address_space *mapping)
 }
 EXPORT_SYMBOL(filemap_flush);
 
-static int __filemap_fdatawait_range(struct address_space *mapping,
+static void __filemap_fdatawait_range(struct address_space *mapping,
 				     loff_t start_byte, loff_t end_byte)
 {
 	pgoff_t index = start_byte >> PAGE_SHIFT;
 	pgoff_t end = end_byte >> PAGE_SHIFT;
 	struct pagevec pvec;
 	int nr_pages;
-	int ret = 0;
 
 	if (end_byte < start_byte)
-		goto out;
+		return;
 
 	pagevec_init(&pvec, 0);
 	while ((index <= end) &&
@@ -390,14 +389,11 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 				continue;
 
 			wait_on_page_writeback(page);
-			if (TestClearPageError(page))
-				ret = -EIO;
+			ClearPageError(page);
 		}
 		pagevec_release(&pvec);
 		cond_resched();
 	}
-out:
-	return ret;
 }
 
 /**
@@ -417,15 +413,10 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 			    loff_t end_byte)
 {
-	int ret, ret2;
 	errseq_t since = filemap_sample_wb_error(mapping);
 
-	ret = __filemap_fdatawait_range(mapping, start_byte, end_byte);
-	ret2 = filemap_check_wb_error(mapping, since);
-	if (!ret)
-		ret = ret2;
-
-	return ret;
+	__filemap_fdatawait_range(mapping, start_byte, end_byte);
+	return filemap_check_wb_error(mapping, since);
 }
 EXPORT_SYMBOL(filemap_fdatawait_range);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
