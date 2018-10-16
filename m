Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F19EE6B0289
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 23:20:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s15-v6so16233832pgv.9
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:20:32 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u12-v6si12241318pls.150.2018.10.15.20.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 20:20:31 -0700 (PDT)
Subject: [PATCH 21/26] ocfs2: fix pagecache truncation prior to reflink
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Mon, 15 Oct 2018 20:20:28 -0700
Message-ID: <153966002809.3607.17959416355714610983.stgit@magnolia>
In-Reply-To: <153965939489.1256.7400115244528045860.stgit@magnolia>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Prior to remapping blocks, it is necessary to remove pages from the
destination file's page cache.  Unfortunately, the truncation is not
aggressive enough -- if page size > block size, we'll end up zeroing
subpage blocks instead of removing them.  So, round the start offset
down and the end offset up to page boundaries.  We already wrote all
the dirty data so the larger range should be fine.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/ocfs2/refcounttree.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)


diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 2a5c96bc9677..7c709229e108 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4862,8 +4862,9 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 				  SINGLE_DEPTH_NESTING);
 
 	/* Zap any page cache for the destination file's range. */
-	truncate_inode_pages_range(&inode_out->i_data, pos_out,
-				   PAGE_ALIGN(pos_out + len) - 1);
+	truncate_inode_pages_range(&inode_out->i_data,
+				   round_down(pos_out, PAGE_SIZE),
+				   round_up(pos_out + len, PAGE_SIZE) - 1);
 
 	ret = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in, inode_out,
 					 out_bh, pos_out, len);
