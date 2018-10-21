Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B36D6B0008
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:15:28 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id 191-v6so25608012ywg.10
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:15:28 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i18-v6si1741687ywc.151.2018.10.21.09.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:15:27 -0700 (PDT)
Subject: [PATCH 03/28] vfs: exit early from zero length remap operations
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:15:23 -0700
Message-ID: <154013852390.29026.2594942938207791308.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

If a remap caller asks us to remap to the source file's EOF and the
source file length leaves us with a zero byte request, exit early.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c |    2 ++
 1 file changed, 2 insertions(+)


diff --git a/fs/read_write.c b/fs/read_write.c
index d6e8e242a15f..2456da3f8a41 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1748,6 +1748,8 @@ int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
 		if (pos_in > isize)
 			return -EINVAL;
 		*len = isize - pos_in;
+		if (*len == 0)
+			return 0;
 	}
 
 	/* Check that we don't violate system file offset limits. */
