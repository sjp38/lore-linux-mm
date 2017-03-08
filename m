Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D847831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 11:30:33 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id n141so91161963qke.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 08:30:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y134si3302339qkb.225.2017.03.08.08.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 08:30:21 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v2 8/9] mm: don't TestClearPageError in __filemap_fdatawait_range
Date: Wed,  8 Mar 2017 11:29:33 -0500
Message-Id: <20170308162934.21989-9-jlayton@redhat.com>
In-Reply-To: <20170308162934.21989-1-jlayton@redhat.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

The -EIO returned here can end up overriding whatever error is marked in
the address space. This means that an -ENOSPC error (AS_ENOSPC) can end
up being turned into -EIO if a page gets PG_error set on it during error
handling.

Read errors are also sometimes tracked on a per-page level using
PG_error. Suppose we have a read error on a page, and then that page is
subsequently dirtied by overwriting the whole page. Writeback doesn't
clear PG_error, so we can then end up successfully writing back that
page and still return -EIO on fsync.

Worse yet, PG_error is cleared during a sync() syscall, but the -EIO
return from this code is silently discarded. Any subsystem that is
relying on PG_error to report errors during fsync or close is already
broken due to this. All you need is a stray sync() call on the box
at the wrong time and you've lost the error.

Since the handling of the PG_error flag is somewhat inconsistent across
subsystems, let's just rely on marking the address space when there are
writeback errors. Change the TestClearPageError call to ClearPageError,
and make __filemap_fdatawait_range a void return function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/filemap.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index fc123b9833e1..150559e94f8a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -376,17 +376,16 @@ int filemap_flush(struct address_space *mapping)
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
@@ -403,14 +402,11 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
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
@@ -430,14 +426,8 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
