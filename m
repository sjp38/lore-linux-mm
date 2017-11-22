Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id F099D6B02EA
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:16:25 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id l13so13943392qtc.9
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:16:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor11249266qtt.161.2017.11.22.13.16.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 13:16:25 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH v2 11/11] btrfs: add NR_METADATA_BYTES accounting
Date: Wed, 22 Nov 2017 16:16:06 -0500
Message-Id: <1511385366-20329-12-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Now that we have these counters, account for the private pages we
allocate in NR_METADATA_BYTES.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 fs/btrfs/extent_io.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index e11372455fb0..7536352f424d 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -4802,6 +4802,8 @@ static void btrfs_release_extent_buffer_page(struct extent_buffer *eb)
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
 
+		mod_node_page_state(page_pgdat(page), NR_METADATA_BYTES,
+				    -(long)PAGE_SIZE);
 		/* Once for the page private. */
 		put_page(page);
 
@@ -5081,6 +5083,8 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 			goto free_eb;
 		}
 		attach_extent_buffer_page(eb, p);
+		mod_node_page_state(page_pgdat(p), NR_METADATA_BYTES,
+				    PAGE_SIZE);
 		eb->pages[i] = p;
 	}
 again:
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
