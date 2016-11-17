Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61A726B02FF
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:26:06 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o1so73048760ito.7
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:26:06 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id j100si252759ioo.69.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:05 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 18/29] btrfs: Fix race in btrfs_free_dummy_fs_info()
Date: Wed, 16 Nov 2016 16:16:45 -0800
Message-Id: <1479341856-30320-21-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

We drop the lock which protects the radix tree, so we must call
radix_tree_iter_next() in order to avoid a modification to the tree
invalidating the iterator state.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/tests/btrfs-tests.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
index bf62ad9..73076a0 100644
--- a/fs/btrfs/tests/btrfs-tests.c
+++ b/fs/btrfs/tests/btrfs-tests.c
@@ -162,6 +162,7 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
 				slot = radix_tree_iter_retry(&iter);
 			continue;
 		}
+		slot = radix_tree_iter_next(&iter);
 		spin_unlock(&fs_info->buffer_lock);
 		free_extent_buffer_stale(eb);
 		spin_lock(&fs_info->buffer_lock);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
