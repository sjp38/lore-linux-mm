Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFEF383294
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:35:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o41so42337721qtf.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:35:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r74si2680174qka.374.2017.06.16.12.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:35:28 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 07/22] mm: don't TestClearPageError in __filemap_fdatawait_range
Date: Fri, 16 Jun 2017 15:34:12 -0400
Message-Id: <20170616193427.13955-8-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

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
due to this. All you need is a stray sync() call to wait for writeback
to complete and you've lost the error.

Since the handling of the PG_error flag is somewhat inconsistent across
subsystems, let's just rely on marking the address space when there are
writeback errors. Change the TestClearPageError call to ClearPageError,
and make __filemap_fdatawait_range a void return function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/filemap.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c349a5d3a34b..21e65c6ef1a0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -388,17 +388,16 @@ int filemap_flush(struct address_space *mapping)
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
@@ -415,14 +414,11 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
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
@@ -442,14 +438,8 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 			    loff_t end_byte)
 {
-	int ret, ret2;
-
-	ret = __filemap_fdatawait_range(mapping, start_byte, end_byte);
-	ret2 = filemap_check_errors(mapping);
-	if (!ret)
-		ret = ret2;
-
-	return ret;
+	__filemap_fdatawait_range(mapping, start_byte, end_byte);
+	return filemap_check_errors(mapping);
 }
 EXPORT_SYMBOL(filemap_fdatawait_range);
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
