Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1E5766B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 22:38:34 -0500 (EST)
Received: by pwj9 with SMTP id 9so529927pwj.14
        for <linux-mm@kvack.org>; Mon, 01 Mar 2010 19:38:32 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] swapfile : fix the wrong return value
Date: Tue,  2 Mar 2010 11:38:22 +0800
Message-Id: <1267501102-24190-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

If the __swap_duplicate returns a negative value except of the -ENOMEM,
but the err is zero at this time, the return value of swap_duplicate is
wrong in this situation.

The caller, such as try_to_unmap_one(), will do the wrong operations too
in this situation.

This patch fix it.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/swapfile.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6c0585b..191d8fa 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2161,7 +2161,7 @@ int swap_duplicate(swp_entry_t entry)
 {
 	int err = 0;
 
-	while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
+	while (!err && (err = __swap_duplicate(entry, 1)) == -ENOMEM)
 		err = add_swap_count_continuation(entry, GFP_ATOMIC);
 	return err;
 }
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
