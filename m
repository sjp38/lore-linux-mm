Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 6ECF56B007D
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 20:52:49 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so2035235bkc.14
        for <linux-mm@kvack.org>; Sat, 18 Aug 2012 17:52:48 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 16/16] tracing output: use new hashtable implementation
Date: Sun, 19 Aug 2012 02:52:30 +0200
Message-Id: <1345337550-24304-18-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch tracing to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the tracing module.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 kernel/trace/trace_output.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 123b189..1324c1a 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -8,15 +8,15 @@
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/ftrace.h>
+#include <linux/hashtable.h>
 
 #include "trace_output.h"
 
-/* must be a power of 2 */
-#define EVENT_HASHSIZE	128
+#define EVENT_HASH_BITS	7
 
 DECLARE_RWSEM(trace_event_mutex);
 
-static struct hlist_head event_hash[EVENT_HASHSIZE] __read_mostly;
+static DEFINE_HASHTABLE(event_hash, EVENT_HASH_BITS);
 
 static int next_event_type = __TRACE_LAST_TYPE + 1;
 
@@ -712,11 +712,8 @@ struct trace_event *ftrace_find_event(int type)
 {
 	struct trace_event *event;
 	struct hlist_node *n;
-	unsigned key;
 
-	key = type & (EVENT_HASHSIZE - 1);
-
-	hlist_for_each_entry(event, n, &event_hash[key], node) {
+	hash_for_each_possible(event_hash, event, n, node, type) {
 		if (event->type == type)
 			return event;
 	}
@@ -781,7 +778,6 @@ void trace_event_read_unlock(void)
  */
 int register_ftrace_event(struct trace_event *event)
 {
-	unsigned key;
 	int ret = 0;
 
 	down_write(&trace_event_mutex);
@@ -833,9 +829,7 @@ int register_ftrace_event(struct trace_event *event)
 	if (event->funcs->binary == NULL)
 		event->funcs->binary = trace_nop_print;
 
-	key = event->type & (EVENT_HASHSIZE - 1);
-
-	hlist_add_head(&event->node, &event_hash[key]);
+	hash_add(event_hash, &event->node, event->type);
 
 	ret = event->type;
  out:
@@ -850,7 +844,7 @@ EXPORT_SYMBOL_GPL(register_ftrace_event);
  */
 int __unregister_ftrace_event(struct trace_event *event)
 {
-	hlist_del(&event->node);
+	hash_del(&event->node);
 	list_del(&event->list);
 	return 0;
 }
@@ -1323,6 +1317,8 @@ __init static int init_events(void)
 		}
 	}
 
+	hash_init(event_hash);
+
 	return 0;
 }
 early_initcall(init_events);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
