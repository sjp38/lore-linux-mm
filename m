Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CD7556B0080
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 01:37:53 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so34227519pab.3
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:53 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id nc10si5020152pbc.89.2015.04.05.22.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Apr 2015 22:37:53 -0700 (PDT)
Received: by patj18 with SMTP id j18so34245167pat.2
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:52 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 9/9] tools lib traceevent: Honor operator priority
Date: Mon,  6 Apr 2015 14:36:16 +0900
Message-Id: <1428298576-9785-10-git-send-email-namhyung@kernel.org>
In-Reply-To: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>

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

Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
---
 tools/lib/traceevent/event-parse.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/tools/lib/traceevent/event-parse.c b/tools/lib/traceevent/event-parse.c
index 6d31b6419d37..604bea5c3fb0 100644
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
+			/* swap ops according to the priority */
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
2.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
