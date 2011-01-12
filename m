Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5E07C6B00E8
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 20:13:31 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p0C1DRIM002704
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:28 -0800
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz1.hot.corp.google.com with ESMTP id p0C1DQLY010312
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:26 -0800
Received: by pzk36 with SMTP id 36so49395pzk.25
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:25 -0800 (PST)
Date: Tue, 11 Jan 2011 17:13:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/3] oom: suppress show_mem() for many nodes in irq context
 on page alloc failure
In-Reply-To: <alpine.DEB.2.00.1101111712190.20611@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1101111712410.20611@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101111712190.20611@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When a page allocation failure occurs, show_mem() is called to dump the
state of the VM so users may understand what happened to get into that
condition.

This output, however, can be extremely verbose.  In irq context, it may
result in significant delays that incur NMI watchdog timeouts when the
machine is large (we use CONFIG_NODES_SHIFT > 8 here to define a "large"
machine since the length of the show_mem() output is proportional to the
number of possible nodes).

This patch suppresses the show_mem() call in irq context when the kernel
has CONFIG_NODES_SHIFT > 8.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1700,6 +1700,20 @@ try_next_zone:
 	return page;
 }
 
+/*
+ * Large machines with many possible nodes should not always dump per-node
+ * meminfo in irq context.
+ */
+static inline bool should_suppress_show_mem(void)
+{
+	bool ret = false;
+
+#if NODES_SHIFT > 8
+	ret = in_interrupt();
+#endif
+	return ret;
+}
+
 static inline int
 should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 				unsigned long pages_reclaimed)
@@ -2110,7 +2124,8 @@ nopage:
 			" order:%d, mode:0x%x\n",
 			p->comm, order, gfp_mask);
 		dump_stack();
-		show_mem();
+		if (!should_suppress_show_mem())
+			show_mem();
 	}
 	return page;
 got_pg:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
