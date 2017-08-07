Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E79936B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r187so86592804pfr.8
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:13 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id h90si4877450plb.303.2017.08.07.00.14.12
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:12 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 03/14] lockdep: Change the meaning of check_prev_add()'s return value
Date: Mon,  7 Aug 2017 16:12:50 +0900
Message-Id: <1502089981-21272-4-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
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
index 9d16723..b23e930 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1870,7 +1870,7 @@ static inline void inc_chains(void)
 		if (entry->class == hlock_class(next)) {
 			if (distance == 1)
 				entry->distance = 1;
-			return 2;
+			return 1;
 		}
 	}
 
@@ -1910,9 +1910,10 @@ static inline void inc_chains(void)
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
