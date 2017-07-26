Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0266B02F4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:55:47 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p62so13537715oih.12
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:55:47 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z126si8861971oiz.119.2017.07.26.10.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 10:55:46 -0700 (PDT)
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 3/4] fs: convert sync_file_range to use errseq_t based error-tracking
Date: Wed, 26 Jul 2017 13:55:37 -0400
Message-Id: <20170726175538.13885-4-jlayton@kernel.org>
In-Reply-To: <20170726175538.13885-1-jlayton@kernel.org>
References: <20170726175538.13885-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

From: Jeff Layton <jlayton@redhat.com>

sync_file_range doesn't call down into the filesystem directly at all.
It only kicks off writeback of pagecache pages and optionally waits
on the result.

Convert sync_file_range to use errseq_t based error tracking, under the
assumption that most users will prefer this behavior when errors occur.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/sync.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/sync.c b/fs/sync.c
index 2a54c1f22035..27d6b8bbcb6a 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -342,7 +342,7 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
 
 	ret = 0;
 	if (flags & SYNC_FILE_RANGE_WAIT_BEFORE) {
-		ret = filemap_fdatawait_range(mapping, offset, endbyte);
+		ret = file_fdatawait_range(f.file, offset, endbyte);
 		if (ret < 0)
 			goto out_put;
 	}
@@ -355,7 +355,7 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
 	}
 
 	if (flags & SYNC_FILE_RANGE_WAIT_AFTER)
-		ret = filemap_fdatawait_range(mapping, offset, endbyte);
+		ret = file_fdatawait_range(f.file, offset, endbyte);
 
 out_put:
 	fdput(f);
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
