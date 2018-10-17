Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9617B6B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:46:42 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id i64-v6so17584931ywa.22
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:46:42 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d81-v6si6977816ywe.206.2018.10.17.15.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:46:41 -0700 (PDT)
Subject: [PATCH 19/29] ocfs2: truncate page cache for clone destination file
 before remapping
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 17 Oct 2018 15:46:32 -0700
Message-ID: <153981639268.5568.1964703365268884972.stgit@magnolia>
In-Reply-To: <153981625504.5568.2708520119290577378.stgit@magnolia>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

When cloning blocks into another file, truncate the page cache before we
start remapping blocks so that concurrent reads wait for us to finish.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/ocfs2/refcounttree.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)


diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 46bbd315c39f..2a5c96bc9677 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4861,14 +4861,12 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 		down_write_nested(&OCFS2_I(inode_out)->ip_alloc_sem,
 				  SINGLE_DEPTH_NESTING);
 
-	ret = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in, inode_out,
-					 out_bh, pos_out, len);
-
 	/* Zap any page cache for the destination file's range. */
-	if (!ret)
-		truncate_inode_pages_range(&inode_out->i_data, pos_out,
-					   PAGE_ALIGN(pos_out + len) - 1);
+	truncate_inode_pages_range(&inode_out->i_data, pos_out,
+				   PAGE_ALIGN(pos_out + len) - 1);
 
+	ret = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in, inode_out,
+					 out_bh, pos_out, len);
 	up_write(&OCFS2_I(inode_in)->ip_alloc_sem);
 	if (!same_inode)
 		up_write(&OCFS2_I(inode_out)->ip_alloc_sem);
