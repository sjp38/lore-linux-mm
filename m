Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCD126B02F4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:55:48 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p62so13537753oih.12
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:55:48 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q189si9179913oih.549.2017.07.26.10.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 10:55:48 -0700 (PDT)
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 4/4] gfs2: convert to errseq_t based writeback error reporting for fsync
Date: Wed, 26 Jul 2017 13:55:38 -0400
Message-Id: <20170726175538.13885-5-jlayton@kernel.org>
In-Reply-To: <20170726175538.13885-1-jlayton@kernel.org>
References: <20170726175538.13885-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

From: Jeff Layton <jlayton@redhat.com>

This means that we need to export the new file_fdatawait_range symbol.

Also, fix a place where a writeback error might get dropped in the
gfs2_is_jdata case.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/gfs2/file.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index c2062a108d19..c53ac6efd04c 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -668,12 +668,14 @@ static int gfs2_fsync(struct file *file, loff_t start, loff_t end,
 		if (ret)
 			return ret;
 		if (gfs2_is_jdata(ip))
-			filemap_write_and_wait(mapping);
+			ret = file_write_and_wait(file);
+		if (ret)
+			return ret;
 		gfs2_ail_flush(ip->i_gl, 1);
 	}
 
 	if (mapping->nrpages)
-		ret = filemap_fdatawait_range(mapping, start, end);
+		ret = file_fdatawait_range(file, start, end);
 
 	return ret ? ret : ret1;
 }
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
