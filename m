Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 27C8C6B028A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 20:08:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 25-v6so10070531pfs.5
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:08:21 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w11-v6si2615205pfn.212.2018.10.12.17.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 17:08:20 -0700 (PDT)
Subject: [PATCH 21/25] ocfs2: fix pagecache truncation prior to reflink
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Fri, 12 Oct 2018 17:08:11 -0700
Message-ID: <153938929138.8361.13789018254018500647.stgit@magnolia>
In-Reply-To: <153938912912.8361.13446310416406388958.stgit@magnolia>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
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
index 851ba3ae7ce8..b9e0418a1974 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4870,8 +4870,9 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 				  SINGLE_DEPTH_NESTING);
 
 	/* Zap any page cache for the destination file's range. */
-	truncate_inode_pages_range(&inode_out->i_data, pos_out,
-				   PAGE_ALIGN(pos_out + len) - 1);
+	truncate_inode_pages_range(&inode_out->i_data,
+				   round_down(pos_out, PAGE_SIZE),
+				   round_up(pos_out + len, PAGE_SIZE) - 1);
 
 	ret = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in, inode_out,
 					 out_bh, pos_out, len);
