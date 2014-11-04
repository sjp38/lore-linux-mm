Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id DAF976B00BF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 06:58:24 -0500 (EST)
Received: by mail-la0-f54.google.com with SMTP id s18so702166lam.41
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 03:58:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wt3si404846lbb.44.2014.11.04.03.58.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 03:58:23 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Improve comment before pagecache_isize_extended()
Date: Tue,  4 Nov 2014 12:43:10 +0100
Message-Id: <1415101390-18301-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Beulich <JBeulich@suse.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>

Not all filesystems are using i_mutex for serialization - reflect that
in the comment. Also expand the reasoning a bit. It is complex enough
that it deserves more details.

Reported-by: Jan Beulich <JBeulich@suse.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/truncate.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

BTW Dave has queued patch which removes the
WARN_ON(!mutex_locked(inode->i_mutex)) from the function. That should go to
Linus ASAP.

diff --git a/mm/truncate.c b/mm/truncate.c
index 261eaf6e5a19..b248c0c8dcd1 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -743,10 +743,13 @@ EXPORT_SYMBOL(truncate_setsize);
  * changed.
  *
  * The function must be called after i_size is updated so that page fault
- * coming after we unlock the page will already see the new i_size.
- * The function must be called while we still hold i_mutex - this not only
- * makes sure i_size is stable but also that userspace cannot observe new
- * i_size value before we are prepared to store mmap writes at new inode size.
+ * coming after we unlock the page will already see the new i_size.  The caller
+ * must make sure (generally by holding i_mutex but e.g. XFS uses its private
+ * lock) i_size cannot change from the new value while we are called. It must
+ * also make sure userspace cannot observe new i_size value before we are
+ * prepared to store mmap writes upto new inode size (otherwise userspace could
+ * think it stored data via mmap within i_size but they would get zeroed due to
+ * writeback & reclaim because they have no backing blocks).
  */
 void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
