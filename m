Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2578F6B02F4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 05:00:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d127so108587575pga.11
        for <linux-mm@kvack.org>; Wed, 24 May 2017 02:00:43 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e27si17353578pfj.41.2017.05.24.02.00.41
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 02:00:42 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v7 03/16] lockdep: Change the meaning of check_prev_add()'s return value
Date: Wed, 24 May 2017 17:59:36 +0900
Message-Id: <1495616389-29772-4-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Firstly, return 1 instead of 2 when 'prev -> next' dependency already
exists. Since the value 2 is not referenced anywhere, just return 1
indicating success in this case.

Secondly, return 2 instead of 1 when successfully added a lock_list
entry with saving stack_trace. With that, a caller can decide whether
to avoid redundant save_trace() on the caller site.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index eb39474..4709110 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1854,7 +1854,7 @@ static inline void inc_chains(void)
 		if (entry->class == hlock_class(next)) {
 			if (distance == 1)
 				entry->distance = 1;
-			return 2;
+			return 1;
 		}
 	}
 
@@ -1894,9 +1894,10 @@ static inline void inc_chains(void)
 		print_lock_name(hlock_class(next));
 		printk(KERN_CONT "\n");
 		dump_stack();
-		return graph_lock();
+		if (!graph_lock())
+			return 0;
 	}
-	return 1;
+	return 2;
 }
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
