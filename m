Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7FFEF6B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 02:15:37 -0500 (EST)
Received: by pwj9 with SMTP id 9so1322674pwj.14
        for <linux-mm@kvack.org>; Wed, 03 Mar 2010 23:15:35 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] swapfile : export more return values for swap_duplicate()
Date: Thu,  4 Mar 2010 15:14:30 +0800
Message-Id: <1267686870-2303-1-git-send-email-shijie8@gmail.com>
In-Reply-To: <1267501102-24190-1-git-send-email-shijie8@gmail.com>
References: <1267501102-24190-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

Exporting more return values for swap_duplicate() is useful for
try_to_unmap(). It could check the swap entry more carefully which
is helpful for the system stability.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/memory.c   |    3 ++-
 mm/swapfile.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 72fb5f3..72d1d1c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -586,7 +586,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		if (!pte_file(pte)) {
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
-			if (swap_duplicate(entry) < 0)
+			/* add_swap_count_continuation() failed ? */
+			if (swap_duplicate(entry) == -ENOMEM)
 				return entry.val;
 
 			/* make sure dst_mm is on swapoff's mmlist. */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6c0585b..a2720d0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2161,7 +2161,7 @@ int swap_duplicate(swp_entry_t entry)
 {
 	int err = 0;
 
-	while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
+	while (!err && (err =  __swap_duplicate(entry, 1)) == -ENOMEM)
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
