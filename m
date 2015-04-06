Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id B2D806B00DF
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:00:51 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so15139423qcy.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:51 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id p9si5167217qca.25.2015.04.06.13.00.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:00:45 -0700 (PDT)
Received: by qgeb100 with SMTP id b100so14903336qge.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:45 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 48/49] mpage: make __mpage_writepage() honor cgroup writeback
Date: Mon,  6 Apr 2015 15:58:37 -0400
Message-Id: <1428350318-8215-49-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>

__mpage_writepage() is used to implement mpage_writepages() which in
turn is used for ->writepages() of various filesystems.  All writeback
logic is now updated to handle cgroup writeback and the block cgroup
to issue IOs for is encoded in writeback_control and can be retrieved
from the inode; however, __mpage_writepage() currently ignores the
blkcg indicated by the inode and issues all bio's without explicit
blkcg association.

This patch updates __mpage_writepage() so that the issued bio's are
associated with inode_to_writeback_blkcg_css(inode).

v2: Updated for per-inode wb association.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
---
 fs/mpage.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/mpage.c b/fs/mpage.c
index 3e79220..a3ccb0b 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -605,6 +605,8 @@ alloc_new:
 				bio_get_nr_vecs(bdev), GFP_NOFS|__GFP_HIGH);
 		if (bio == NULL)
 			goto confused;
+
+		bio_associate_blkcg(bio, inode_to_wb_blkcg_css(inode));
 	}
 
 	/*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
