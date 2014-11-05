Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id B4F0B6B0098
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 12:00:18 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id f15so1127899lbj.27
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 09:00:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ap1si7182868lac.54.2014.11.05.09.00.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 09:00:16 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Fix comment before truncate_setsize()
Date: Wed,  5 Nov 2014 18:00:06 +0100
Message-Id: <1415206806-6173-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Beulich <JBeulich@suse.com>, Jan Kara <jack@suse.cz>

XFS doesn't always hold i_mutex when calling truncate_setsize() and it
uses a different lock to serialize truncates and writes. So fix the
comment before truncate_setsize().

Reported-by: Jan Beulich <JBeulich@suse.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/truncate.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index b248c0c8dcd1..ed33e8f811e9 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -715,8 +715,9 @@ EXPORT_SYMBOL(truncate_pagecache);
  * necessary) to @newsize. It will be typically be called from the filesystem's
  * setattr function when ATTR_SIZE is passed in.
  *
- * Must be called with inode_mutex held and before all filesystem specific
- * block truncation has been performed.
+ * Must be called with a lock serializing truncates and writes (generally
+ * i_mutex but e.g. xfs uses a different lock) and before all filesystem
+ * specific block truncation has been performed.
  */
 void truncate_setsize(struct inode *inode, loff_t newsize)
 {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
