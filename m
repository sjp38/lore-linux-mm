Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 05EE082A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:35:39 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so938352pde.34
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:35:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dn2si756915pdb.500.2014.07.11.00.35.38
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:35:38 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 06/30] mm, tracing: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:23 +0800
Message-Id: <1405064267-11678-7-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 kernel/trace/ring_buffer.c  |   12 ++++++------
 kernel/trace/trace_uprobe.c |    2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index 7c56c3d06943..38c51583f968 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -1124,13 +1124,13 @@ static int __rb_allocate_pages(int nr_pages, struct list_head *pages, int cpu)
 		 */
 		bpage = kzalloc_node(ALIGN(sizeof(*bpage), cache_line_size()),
 				    GFP_KERNEL | __GFP_NORETRY,
-				    cpu_to_node(cpu));
+				    cpu_to_mem(cpu));
 		if (!bpage)
 			goto free_pages;
 
 		list_add(&bpage->list, pages);
 
-		page = alloc_pages_node(cpu_to_node(cpu),
+		page = alloc_pages_node(cpu_to_mem(cpu),
 					GFP_KERNEL | __GFP_NORETRY, 0);
 		if (!page)
 			goto free_pages;
@@ -1183,7 +1183,7 @@ rb_allocate_cpu_buffer(struct ring_buffer *buffer, int nr_pages, int cpu)
 	int ret;
 
 	cpu_buffer = kzalloc_node(ALIGN(sizeof(*cpu_buffer), cache_line_size()),
-				  GFP_KERNEL, cpu_to_node(cpu));
+				  GFP_KERNEL, cpu_to_mem(cpu));
 	if (!cpu_buffer)
 		return NULL;
 
@@ -1198,14 +1198,14 @@ rb_allocate_cpu_buffer(struct ring_buffer *buffer, int nr_pages, int cpu)
 	init_waitqueue_head(&cpu_buffer->irq_work.waiters);
 
 	bpage = kzalloc_node(ALIGN(sizeof(*bpage), cache_line_size()),
-			    GFP_KERNEL, cpu_to_node(cpu));
+			    GFP_KERNEL, cpu_to_mem(cpu));
 	if (!bpage)
 		goto fail_free_buffer;
 
 	rb_check_bpage(cpu_buffer, bpage);
 
 	cpu_buffer->reader_page = bpage;
-	page = alloc_pages_node(cpu_to_node(cpu), GFP_KERNEL, 0);
+	page = alloc_pages_node(cpu_to_mem(cpu), GFP_KERNEL, 0);
 	if (!page)
 		goto fail_free_reader;
 	bpage->page = page_address(page);
@@ -4378,7 +4378,7 @@ void *ring_buffer_alloc_read_page(struct ring_buffer *buffer, int cpu)
 	struct buffer_data_page *bpage;
 	struct page *page;
 
-	page = alloc_pages_node(cpu_to_node(cpu),
+	page = alloc_pages_node(cpu_to_mem(cpu),
 				GFP_KERNEL | __GFP_NORETRY, 0);
 	if (!page)
 		return NULL;
diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
index 3c9b97e6b1f4..e585fb67472b 100644
--- a/kernel/trace/trace_uprobe.c
+++ b/kernel/trace/trace_uprobe.c
@@ -692,7 +692,7 @@ static int uprobe_buffer_init(void)
 		return -ENOMEM;
 
 	for_each_possible_cpu(cpu) {
-		struct page *p = alloc_pages_node(cpu_to_node(cpu),
+		struct page *p = alloc_pages_node(cpu_to_mem(cpu),
 						  GFP_KERNEL, 0);
 		if (p == NULL) {
 			err_cpu = cpu;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
