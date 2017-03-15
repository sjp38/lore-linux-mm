Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE6B6B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:07:54 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id k13so24137691ywk.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:07:54 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id b17si258215ybj.323.2017.03.14.22.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 22:07:53 -0700 (PDT)
From: Theodore Ts'o <tytso@mit.edu>
Subject: [RFC PATCH] mm: retry writepages() on ENOMEM when doing an data integrity writeback
Date: Wed, 15 Mar 2017 01:07:43 -0400
Message-Id: <20170315050743.5539-1-tytso@mit.edu>
In-Reply-To: <20170309090449.GD15874@quack2.suse.cz>
References: <20170309090449.GD15874@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

Currently, file system's writepages() function must not fail with an
ENOMEM, since if they do, it's possible for buffered data to be lost.
This is because on a data integrity writeback writepages() gets called
but once, and if it returns ENOMEM and you're lucky the error will get
reflected back to the userspace process calling fsync() --- at which
point the application may or may not be properly checking error codes.
If you aren't lucky, the user is unmounting the file system, and the
dirty pages will simply be lost.

For this reason, file system code generally will use GFP_NOFS, and in
some cases, will retry the allocation in a loop, on the theory that
"kernel livelocks are temporary; data loss is forever".
Unfortunately, this can indeed cause livelocks, since inside the
writepages() call, the file system is holding various mutexes, and
these mutexes may prevent the OOM killer from killing its targetted
victim if it is also holding on to those mutexes.

A better solution would be to allow writepages() to call the memory
allocator with flags that give greater latitude to the allocator to
fail, and then release its locks and return ENOMEM, and in the case of
background writeback, the writes can be retried at a later time.  In
the case of data-integrity writeback retry after waiting a brief
amount of time.

Signed-off-by: Theodore Ts'o <tytso@mit.edu>
---

As we had discussed in an e-mail thread last week, I'm interested in
allowing ext4_writepages() to return ENOMEM without causing dirty
pages from buffered writes getting list.  It looks like doing so
should be fairly straightforward.   What do folks think?

 mm/page-writeback.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 290e8b7d3181..8666d3f3c57a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2352,10 +2352,16 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 
 	if (wbc->nr_to_write <= 0)
 		return 0;
-	if (mapping->a_ops->writepages)
-		ret = mapping->a_ops->writepages(mapping, wbc);
-	else
-		ret = generic_writepages(mapping, wbc);
+	while (1) {
+		if (mapping->a_ops->writepages)
+			ret = mapping->a_ops->writepages(mapping, wbc);
+		else
+			ret = generic_writepages(mapping, wbc);
+		if ((ret != ENOMEM) || (wbc->sync_mode != WB_SYNC_ALL))
+			break;
+		cond_resched();
+		congestion_wait(BLK_RW_ASYNC, HZ/50);
+	}
 	return ret;
 }
 
-- 
2.11.0.rc0.7.gbe5a750

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
