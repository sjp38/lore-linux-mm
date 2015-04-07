Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 75F236B006C
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 12:41:26 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so58796330ied.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 09:41:26 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id h38si7007974ioi.92.2015.04.07.09.41.25
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 09:41:25 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 04/16] tools lib traceevent: Honor operator priority
Date: Tue,  7 Apr 2015 13:40:50 -0300
Message-Id: <1428424862-30032-5-git-send-email-acme@kernel.org>
In-Reply-To: <1428424862-30032-1-git-send-email-acme@kernel.org>
References: <1428424862-30032-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Namhyung Kim <namhyung@kernel.org>

Currently it ignores operator priority and just sets processed args as a
right operand.  But it could result in priority inversion in case that
the right operand is also a operator arg and its priority is lower.

For example, following print format is from new kmem events.

  "page=%p", REC->pfn != -1UL ? (((struct page *)(0xffffea0000000000UL)) + (REC->pfn)) : ((void *)0)

But this was treated as below:

  REC->pfn != ((null - 1UL) ? ((struct page *)0xffffea0000000000UL + REC->pfn) : (void *) 0)

In this case, the right arg was '?' operator which has lower priority.
But it just sets the whole arg so making the output confusing - page was
always 0 or 1 since that's the result of logical operation.

With this patch, it can handle it properly like following:

  ((REC->pfn != (null - 1UL)) ? ((struct page *)0xffffea0000000000UL + REC->pfn) : (void *) 0)

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Acked-by: Steven Rostedt <rostedt@goodmis.org>
Cc: David Ahern <dsahern@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1428298576-9785-10-git-send-email-namhyung@kernel.org
[ Replaced 'swap' with 'rotate' in a comment as requested by Steve and agreed by Namhyung ]
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/lib/traceevent/event-parse.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/tools/lib/traceevent/event-parse.c b/tools/lib/traceevent/event-parse.c
index 6d31b6419d37..12a7e2a40c89 100644
--- a/tools/lib/traceevent/event-parse.c
+++ b/tools/lib/traceevent/event-parse.c
@@ -1939,7 +1939,22 @@ process_op(struct event_format *event, struct print_arg *arg, char **tok)
 			goto out_warn_free;
 
 		type = process_arg_token(event, right, tok, type);
-		arg->op.right = right;
+
+		if (right->type == PRINT_OP &&
+		    get_op_prio(arg->op.op) < get_op_prio(right->op.op)) {
+			struct print_arg tmp;
+
+			/* rotate ops according to the priority */
+			arg->op.right = right->op.left;
+
+			tmp = *arg;
+			*arg = *right;
+			*right = tmp;
+
+			arg->op.left = right;
+		} else {
+			arg->op.right = right;
+		}
 
 	} else if (strcmp(token, "[") == 0) {
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
