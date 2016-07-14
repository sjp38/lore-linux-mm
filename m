Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE5EF6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 07:23:01 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g8so147436378itb.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 04:23:01 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00116.outbound.protection.outlook.com. [40.107.0.116])
        by mx.google.com with ESMTPS id 27si2113652otz.198.2016.07.14.04.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 04:23:01 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] radix-tree: fix radix_tree_iter_retry() for tagged iterators.
Date: Thu, 14 Jul 2016 14:19:56 +0300
Message-ID: <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <CACT4Y+a99OW7TYeLsuEic19uY2j45DGXL=LowUMq3TywWS3f2Q@mail.gmail.com>
References: <CACT4Y+a99OW7TYeLsuEic19uY2j45DGXL=LowUMq3TywWS3f2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, stable@vger.kernel.org

radix_tree_iter_retry() resets slot to NULL, but it doesn't reset tags.
Then NULL slot and non-zero iter.tags passed to radix_tree_next_slot()
leading to crash:

RIP: [<     inline     >] radix_tree_next_slot include/linux/radix-tree.h:473
  [<ffffffff816951a4>] find_get_pages_tag+0x334/0x930 mm/filemap.c:1452
....
Call Trace:
 [<ffffffff816cd91a>] pagevec_lookup_tag+0x3a/0x80 mm/swap.c:960
 [<ffffffff81ab4231>] mpage_prepare_extent_to_map+0x321/0xa90 fs/ext4/inode.c:2516
 [<ffffffff81ac883e>] ext4_writepages+0x10be/0x2b20 fs/ext4/inode.c:2736
 [<ffffffff816c99c7>] do_writepages+0x97/0x100 mm/page-writeback.c:2364
 [<ffffffff8169bee8>] __filemap_fdatawrite_range+0x248/0x2e0 mm/filemap.c:300
 [<ffffffff8169c371>] filemap_write_and_wait_range+0x121/0x1b0 mm/filemap.c:490
 [<ffffffff81aa584d>] ext4_sync_file+0x34d/0xdb0 fs/ext4/fsync.c:115
 [<ffffffff818b667a>] vfs_fsync_range+0x10a/0x250 fs/sync.c:195
 [<     inline     >] vfs_fsync fs/sync.c:209
 [<ffffffff818b6832>] do_fsync+0x42/0x70 fs/sync.c:219
 [<     inline     >] SYSC_fdatasync fs/sync.c:232
 [<ffffffff818b6f89>] SyS_fdatasync+0x19/0x20 fs/sync.c:230
 [<ffffffff86a94e00>] entry_SYSCALL_64_fastpath+0x23/0xc1 arch/x86/entry/entry_64.S:207

We must reset iterator's tags to bail out from radix_tree_next_slot() and
go to the slow-path in radix_tree_next_chunk().

Fixes: 46437f9a554f ("radix-tree: fix race in gang lookup")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: <stable@vger.kernel.org>
---
 include/linux/radix-tree.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index cb4b7e8..eca6f62 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -407,6 +407,7 @@ static inline __must_check
 void **radix_tree_iter_retry(struct radix_tree_iter *iter)
 {
 	iter->next_index = iter->index;
+	iter->tags = 0;
 	return NULL;
 }
 
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
