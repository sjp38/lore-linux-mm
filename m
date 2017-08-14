Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 12D236B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 03:02:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 83so120479036pgb.14
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:02:13 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 7si3806924pfl.430.2017.08.14.00.02.11
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 00:02:12 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH 1/2] lockdep: Add a comment about crossrelease_hist_end() in lockdep_sys_exit()
Date: Mon, 14 Aug 2017 16:00:51 +0900
Message-Id: <1502694052-16085-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502694052-16085-1-git-send-email-byungchul.park@lge.com>
References: <1502694052-16085-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

In lockdep_sys_exit(), crossrelease_hist_end() is called unconditionally
even when getting here without having started e.g. just after forked.
But it's no problem since it anyway would rollback to an invalid element.
A comment would be helpful to understand this situation.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 1114dc4..1ae4258 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4623,6 +4623,10 @@ asmlinkage __visible void lockdep_sys_exit(void)
 	/*
 	 * The lock history for each syscall should be independent. So wipe the
 	 * slate clean on return to userspace.
+	 *
+	 * crossrelease_hist_end() would work well even when getting here
+	 * without starting just after forked, it rollbacks back the index
+	 * to point to the last which is already invalid.
 	 */
 	crossrelease_hist_end(XHLOCK_PROC);
 	crossrelease_hist_start(XHLOCK_PROC);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
