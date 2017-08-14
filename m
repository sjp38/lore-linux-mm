Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 320816B02B4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 03:02:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 83so120479154pgb.14
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:02:13 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id h10si4212612plk.237.2017.08.14.00.02.11
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 00:02:12 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH 2/2] lockdep: Fix the rollback and overwrite detection in crossrelease
Date: Mon, 14 Aug 2017 16:00:52 +0900
Message-Id: <1502694052-16085-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502694052-16085-1-git-send-email-byungchul.park@lge.com>
References: <1502694052-16085-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

As Boqun pointed out, current->hist_id should be aligned with the latest
valid xhlock->hist_id so that hist_id_save[] storing current->hist_id
can be comparable with xhlock->hist_id. Fix it.

Additionally, the condition for overwrite-detection should be the
opposite. Fix it with modifying comment.

           <- direction to visit
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh (h: history)
                 ^^        ^
                 ||        start from here
                 |previous entry
                 current entry

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 1ae4258..f0e6649 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4853,7 +4853,7 @@ static void add_xhlock(struct held_lock *hlock)
 
 	/* Initialize hist_lock's members */
 	xhlock->hlock = *hlock;
-	xhlock->hist_id = current->hist_id++;
+	xhlock->hist_id = ++current->hist_id;
 
 	xhlock->trace.nr_entries = 0;
 	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
@@ -5030,11 +5030,11 @@ static void commit_xhlocks(struct cross_lock *xlock)
 
 			/*
 			 * Filter out the cases that the ring buffer was
-			 * overwritten and the previous entry has a bigger
-			 * hist_id than the following one, which is impossible
+			 * overwritten and the current entry has a bigger
+			 * hist_id than the previous one, which is impossible
 			 * otherwise.
 			 */
-			if (unlikely(before(xhlock->hist_id, prev_hist_id)))
+			if (unlikely(before(prev_hist_id, xhlock->hist_id)))
 				break;
 
 			prev_hist_id = xhlock->hist_id;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
