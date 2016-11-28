Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1616B02C0
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:26 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id r94so259023603ioe.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:26 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id h190si19920428ite.62.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 19/33] btrfs: Fix race in btrfs_free_dummy_fs_info()
Date: Mon, 28 Nov 2016 13:50:57 -0800
Message-Id: <1480369871-5271-54-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

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
