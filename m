Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB2B26B0005
	for <linux-mm@kvack.org>; Sun, 10 Jul 2016 19:46:42 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id wu1so208504861obb.0
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 16:46:42 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id u107si305178otb.100.2016.07.10.16.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jul 2016 16:46:42 -0700 (PDT)
Received: by mail-oi0-x232.google.com with SMTP id u201so126378719oie.0
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 16:46:42 -0700 (PDT)
Date: Sun, 10 Jul 2016 16:46:32 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: fix regression hang in fallocate undo
Message-ID: <alpine.LSU.2.11.1607101637420.6514@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Anthony Romano <anthony.romano@coreos.com>, Brandon Philips <brandon@ifup.co>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The well-spotted fallocate undo fix is good in most cases, but not when
fallocate failed on the very first page.  index 0 then passes lend -1
to shmem_undo_range(), and that has two bad effects: (a) that it will
undo every fallocation throughout the file, unrestricted by the current
range; but more importantly (b) it can cause the undo to hang, because
lend -1 is treated as truncation, which makes it keep on retrying until
every page has gone, but those already fully instantiated will never go
away.  Big thank you to xfstests generic/269 which demonstrates this.

Fixes: b9b4bb26af01 ("tmpfs: don't undo fallocate past its last page")
Cc: stable@vger.kernel.org
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- 4.7-rc6/mm/shmem.c	2016-06-26 22:02:27.543373427 -0700
+++ linux/mm/shmem.c	2016-07-10 15:19:24.000000000 -0700
@@ -2225,9 +2225,11 @@ static long shmem_fallocate(struct file
 			error = shmem_getpage(inode, index, &page, SGP_FALLOC);
 		if (error) {
 			/* Remove the !PageUptodate pages we added */
-			shmem_undo_range(inode,
-				(loff_t)start << PAGE_SHIFT,
-				((loff_t)index << PAGE_SHIFT) - 1, true);
+			if (index > start) {
+				shmem_undo_range(inode,
+				    (loff_t)start << PAGE_SHIFT,
+				    ((loff_t)index << PAGE_SHIFT) - 1, true);
+			}
 			goto undone;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
