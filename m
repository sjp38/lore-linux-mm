Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 48A786B00CE
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:56:51 -0400 (EDT)
Received: by qgez102 with SMTP id z102so48349806qge.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:56:51 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id p64si11242798qha.8.2015.03.22.21.56.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:56:27 -0700 (PDT)
Received: by qgfa8 with SMTP id a8so137702105qgf.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:56:27 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 47/48] mpage: make __mpage_writepage() honor cgroup writeback
Date: Mon, 23 Mar 2015 00:54:58 -0400
Message-Id: <1427086499-15657-48-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
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
