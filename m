Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 025B36B026A
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so16601673pfy.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:17:55 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p124si213482pga.159.2017.01.18.05.17.54
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:17:55 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 04/13] lockdep: Refactor save_trace()
Date: Wed, 18 Jan 2017 22:17:30 +0900
Message-Id: <1484745459-2055-5-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Currently, save_trace() allocates a buffer for saving stack_trace from
the global buffer, and then saves the trace. However, it would be more
useful if a separate buffer can be used. Actually, crossrelease needs
to use separate temporal buffers where to save stack_traces.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 2081c31..e63ff97 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -392,13 +392,13 @@ static void print_lockdep_off(const char *bug_msg)
 #endif
 }
 
-static int save_trace(struct stack_trace *trace)
+static unsigned int __save_trace(struct stack_trace *trace, unsigned long *buf,
+				 unsigned long max_nr, int skip)
 {
 	trace->nr_entries = 0;
-	trace->max_entries = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
-	trace->entries = stack_trace + nr_stack_trace_entries;
-
-	trace->skip = 3;
+	trace->max_entries = max_nr;
+	trace->entries = buf;
+	trace->skip = skip;
 
 	save_stack_trace(trace);
 
@@ -415,7 +415,15 @@ static int save_trace(struct stack_trace *trace)
 
 	trace->max_entries = trace->nr_entries;
 
-	nr_stack_trace_entries += trace->nr_entries;
+	return trace->nr_entries;
+}
+
+static int save_trace(struct stack_trace *trace)
+{
+	unsigned long *buf = stack_trace + nr_stack_trace_entries;
+	unsigned long max_nr = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
+
+	nr_stack_trace_entries += __save_trace(trace, buf, max_nr, 3);
 
 	if (nr_stack_trace_entries >= MAX_STACK_TRACE_ENTRIES-1) {
 		if (!debug_locks_off_graph_unlock())
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
