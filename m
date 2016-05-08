Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A08BB6B0005
	for <linux-mm@kvack.org>; Sun,  8 May 2016 09:14:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so327697010pfy.2
        for <linux-mm@kvack.org>; Sun, 08 May 2016 06:14:49 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id h64si31020232pfh.211.2016.05.08.06.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 06:14:48 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id y69so65572231pfb.1
        for <linux-mm@kvack.org>; Sun, 08 May 2016 06:14:48 -0700 (PDT)
From: Anthony Romano <anthony.romano@coreos.com>
Subject: [PATCH] tmpfs: don't undo fallocate past its last page
Date: Sun,  8 May 2016 06:16:27 -0700
Message-Id: <1462713387-16724-1-git-send-email-anthony.romano@coreos.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Anthony Romano <anthony.romano@coreos.com>

When fallocate is interrupted it will undo a range that extends one byte
past its range of allocated pages. This can corrupt an in-use page by
zeroing out its first byte. Instead, undo using the inclusive byte range.

Signed-off-by: Anthony Romano <anthony.romano@coreos.com>
---
 mm/shmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 719bd6b..f0f9405 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2238,7 +2238,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 			/* Remove the !PageUptodate pages we added */
 			shmem_undo_range(inode,
 				(loff_t)start << PAGE_SHIFT,
-				(loff_t)index << PAGE_SHIFT, true);
+				((loff_t)index << PAGE_SHIFT) - 1, true);
 			goto undone;
 		}
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
