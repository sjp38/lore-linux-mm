Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id E90906B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 10:09:53 -0500 (EST)
Message-ID: <1358521791.7383.11.camel@gandalf.local.home>
Subject: [RFC][PATCH v3] slub: Keep page and object in sync in
 slab_alloc_node()
From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 18 Jan 2013 10:09:51 -0500
In-Reply-To: <1358468924.23211.69.camel@gandalf.local.home>
References: <1358446258.23211.32.camel@gandalf.local.home>
	 <1358447864.23211.34.camel@gandalf.local.home>
	 <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
	 <1358458996.23211.46.camel@gandalf.local.home>
	 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com>
	 <1358462763.23211.57.camel@gandalf.local.home>
	 <1358464245.23211.62.camel@gandalf.local.home>
	 <1358464837.23211.66.camel@gandalf.local.home>
	 <1358468598.23211.67.camel@gandalf.local.home>
	 <1358468924.23211.69.camel@gandalf.local.home>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R.
 Goncalves" <lgoncalv@redhat.com>

In slab_alloc_node(), after the cpu_slab is assigned, if the task is
preempted and moves to another CPU, there's nothing keeping the page and
object in sync. The -rt kernel crashed because page was NULL and object
was not, and the node_match() dereferences page. Even though the crash
happened on -rt, there's nothing that's keeping this from happening on
mainline.

The easiest fix is to disable preemption for the entire time from
acquiring the current CPU cpu_slab and assigning the object and page.
After that, it's fine to allow preemption.

Also add a check if page is NULL in node_match().

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

diff --git a/mm/slub.c b/mm/slub.c
index ba2ca53..10714ee 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2041,7 +2041,7 @@ static void flush_all(struct kmem_cache *s)
 static inline int node_match(struct page *page, int node)
 {
 #ifdef CONFIG_NUMA
-	if (node != NUMA_NO_NODE && page_to_nid(page) != node)
+	if (!page || (node != NUMA_NO_NODE && page_to_nid(page) != node))
 		return 0;
 #endif
 	return 1;
@@ -2337,7 +2337,10 @@ redo:
 	 * enabled. We may switch back and forth between cpus while
 	 * reading from one cpu area. That does not matter as long
 	 * as we end up on the original cpu again when doing the cmpxchg.
+	 *
+	 * But we need to sync the setting of page and object.
 	 */
+	preempt_disable();
 	c = __this_cpu_ptr(s->cpu_slab);
 
 	/*
@@ -2347,10 +2350,14 @@ redo:
 	 * linked list in between.
 	 */
 	tid = c->tid;
+
+	/* Must have tid first in case an interrupt comes in */
 	barrier();
 
 	object = c->freelist;
 	page = c->page;
+	preempt_enable();
+
 	if (unlikely(!object || !node_match(page, node)))
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
