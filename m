Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4B48E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:12:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so2371411edc.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:12:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l17si2867049edq.20.2019.01.16.05.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:12:20 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: migrate: Make buffer_migrate_page_norefs() actually succeed
Date: Wed, 16 Jan 2019 14:12:17 +0100
Message-Id: <20190116131217.7226-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, Jan Kara <jack@suse.cz>

Currently, buffer_migrate_page_norefs() was constantly failing because
buffer_migrate_lock_buffers() grabbed reference on each buffer. In fact,
there's no reason for buffer_migrate_lock_buffers() to grab any buffer
references as the page is locked during all our operation and thus
nobody can reclaim buffers from the page. So remove grabbing of buffer
references which also makes buffer_migrate_page_norefs() succeed.

Fixes: 89cb0888ca14 "mm: migrate: provide buffer_migrate_page_norefs()"
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/migrate.c | 5 -----
 1 file changed, 5 deletions(-)

Andrew, can you please merge this patch? Sadly my previous testing only tested
that page migration in general didn't get broken but I forgot to test whether
the new migrate page callback actually results in more successful migrations
for block device pages. So the bug got only revealed by customer testing. Now
I've reproduced the workload internally and verified that the patch indeed
fixes the issue.

diff --git a/mm/migrate.c b/mm/migrate.c
index a16b15090df3..712b231a7376 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -709,7 +709,6 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	/* Simple case, sync compaction */
 	if (mode != MIGRATE_ASYNC) {
 		do {
-			get_bh(bh);
 			lock_buffer(bh);
 			bh = bh->b_this_page;
 
@@ -720,18 +719,15 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 
 	/* async case, we cannot block on lock_buffer so use trylock_buffer */
 	do {
-		get_bh(bh);
 		if (!trylock_buffer(bh)) {
 			/*
 			 * We failed to lock the buffer and cannot stall in
 			 * async migration. Release the taken locks
 			 */
 			struct buffer_head *failed_bh = bh;
-			put_bh(failed_bh);
 			bh = head;
 			while (bh != failed_bh) {
 				unlock_buffer(bh);
-				put_bh(bh);
 				bh = bh->b_this_page;
 			}
 			return false;
@@ -818,7 +814,6 @@ static int __buffer_migrate_page(struct address_space *mapping,
 	bh = head;
 	do {
 		unlock_buffer(bh);
-		put_bh(bh);
 		bh = bh->b_this_page;
 
 	} while (bh != head);
-- 
2.16.4
