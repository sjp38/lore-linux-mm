Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC8C76B0008
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 23:10:15 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k14-v6so9293971qta.23
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:10:15 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a9-v6si7327607qkj.205.2018.10.15.20.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 20:10:15 -0700 (PDT)
Subject: [PATCH 02/26] vfs: vfs_clone_file_prep_inodes should return EINVAL
 for a clone from beyond EOF
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Mon, 15 Oct 2018 20:10:10 -0700
Message-ID: <153965941007.1256.17570514092450613034.stgit@magnolia>
In-Reply-To: <153965939489.1256.7400115244528045860.stgit@magnolia>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

vfs_clone_file_prep_inodes cannot return 0 if it is asked to remap from
a zero byte file because that's what btrfs does.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c |    3 ---
 1 file changed, 3 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index 8a2737f0d61d..260797b01851 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1740,10 +1740,7 @@ int vfs_clone_file_prep_inodes(struct inode *inode_in, loff_t pos_in,
 	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
 		return -EINVAL;
 
-	/* Are we going all the way to the end? */
 	isize = i_size_read(inode_in);
-	if (isize == 0)
-		return 0;
 
 	/* Zero length dedupe exits immediately; reflink goes to EOF. */
 	if (*len == 0) {
