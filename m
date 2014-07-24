Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 44AAA6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 21:16:33 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id tr6so1643397ieb.7
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:16:33 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id rh7si15060069igc.32.2014.07.23.18.16.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 18:16:32 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so1737648ier.13
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:16:32 -0700 (PDT)
Date: Wed, 23 Jul 2014 18:16:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/3] mm, oom: ensure memoryless node zonelist always includes
 zones
Message-ID: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

With memoryless node support being worked on, it's possible that for 
optimizations that a node may not have a non-NULL zonelist.  When CONFIG_NUMA is 
enabled and node 0 is memoryless, this means the zonelist for first_online_node 
may become NULL.

The oom killer requires a zonelist that includes all memory zones for the sysrq 
trigger and pagefault out of memory handler.

Ensure that a non-NULL zonelist is always passed to the oom killer.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/tty/sysrq.c      |  2 +-
 include/linux/nodemask.h | 10 +++++++++-
 mm/oom_kill.c            |  2 +-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -355,7 +355,7 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(first_online_node, GFP_KERNEL), GFP_KERNEL,
+	out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL), GFP_KERNEL,
 		      0, NULL, true);
 }
 
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -430,7 +430,15 @@ static inline int num_node_state(enum node_states state)
 	for_each_node_mask((__node), node_states[__state])
 
 #define first_online_node	first_node(node_states[N_ONLINE])
-#define next_online_node(nid)	next_node((nid), node_states[N_ONLINE])
+#define first_memory_node	first_node(node_states[N_MEMORY])
+static inline int next_online_node(int nid)
+{
+	return next_node(nid, node_states[N_ONLINE]);
+}
+static inline int next_memory_node(int nid)
+{
+	return next_node(nid, node_states[N_MEMORY]);
+}
 
 extern int nr_node_ids;
 extern int nr_online_nodes;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -694,7 +694,7 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	zonelist = node_zonelist(first_online_node, GFP_KERNEL);
+	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
 	if (try_set_zonelist_oom(zonelist, GFP_KERNEL)) {
 		out_of_memory(NULL, 0, 0, NULL, false);
 		clear_zonelist_oom(zonelist, GFP_KERNEL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
