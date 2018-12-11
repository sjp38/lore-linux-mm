Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 709188E00B9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:21:53 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id p4so10234182pgj.21
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:21:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b36si6875828pgl.596.2018.12.11.09.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:21:51 -0800 (PST)
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2544DB063
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:21:49 +0000 (UTC)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 5/6] blkdev: Avoid migration stalls for blkdev pages
Date: Tue, 11 Dec 2018 18:21:42 +0100
Message-Id: <20181211172143.7358-6-jack@suse.cz>
In-Reply-To: <20181211172143.7358-1-jack@suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, mgorman@suse.de, Jan Kara <jack@suse.cz>

Currently, block device pages don't provide a ->migratepage callback and
thus fallback_migrate_page() is used for them. This handler cannot deal
with dirty pages in async mode and also with the case a buffer head is in
the LRU buffer head cache (as it has elevated b_count). Thus such page can
block memory offlining.

Fix the problem by using buffer_migrate_page_norefs() for migrating
block device pages. That function takes care of dropping bh LRU in case
migration would fail due to elevated buffer refcount to avoid stalls and
can also migrate dirty pages without writing them.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/block_dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index a80b4f0ee7c4..de2135178e62 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1966,6 +1966,7 @@ static const struct address_space_operations def_blk_aops = {
 	.writepages	= blkdev_writepages,
 	.releasepage	= blkdev_releasepage,
 	.direct_IO	= blkdev_direct_IO,
+	.migratepage	= buffer_migrate_page_norefs,
 	.is_dirty_writeback = buffer_check_dirty_writeback,
 };
 
-- 
2.16.4
