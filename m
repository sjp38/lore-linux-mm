Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E21C06B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:53:14 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 91-v6so1995893plf.6
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:53:14 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 7-v6si3493876plf.552.2018.04.04.08.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:53:13 -0700 (PDT)
Date: Wed, 4 Apr 2018 11:53:10 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH] ring-buffer: Add set/clear_current_oom_origin() during
 allocations
Message-ID: <20180404115310.6c69e7b9@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

From: "Steven Rostedt (VMware)" <rostedt@goodmis.org>

As si_mem_available() can say there is enough memory even though the memory
available is not useable by the ring buffer, it is best to not kill innocent
applications because the ring buffer is taking up all the memory while it is
trying to allocate a great deal of memory.

If the allocator is user space (because kernel threads can also increase the
size of the kernel ring buffer on boot up), then after si_mem_available()
says there is enough memory, set the OOM killer to kill the current task if
an OOM triggers during the allocation.

Link: http://lkml.kernel.org/r/20180404062340.GD6312@dhcp22.suse.cz

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
 kernel/trace/ring_buffer.c | 48 ++++++++++++++++++++++++++++++++++++----------
 1 file changed, 38 insertions(+), 10 deletions(-)

diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index 966128f02121..c9cb9767d49b 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -22,6 +22,7 @@
 #include <linux/hash.h>
 #include <linux/list.h>
 #include <linux/cpu.h>
+#include <linux/oom.h>
 
 #include <asm/local.h>
 
@@ -1162,35 +1163,60 @@ static int rb_check_pages(struct ring_buffer_per_cpu *cpu_buffer)
 static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 {
 	struct buffer_page *bpage, *tmp;
+	bool user_thread = current->mm != NULL;
+	gfp_t mflags;
 	long i;
 
-	/* Check if the available memory is there first */
+	/*
+	 * Check if the available memory is there first.
+	 * Note, si_mem_available() only gives us a rough estimate of available
+	 * memory. It may not be accurate. But we don't care, we just want
+	 * to prevent doing any allocation when it is obvious that it is
+	 * not going to succeed.
+	 */
 	i = si_mem_available();
 	if (i < nr_pages)
 		return -ENOMEM;
 
+	/*
+	 * __GFP_RETRY_MAYFAIL flag makes sure that the allocation fails
+	 * gracefully without invoking oom-killer and the system is not
+	 * destabilized.
+	 */
+	mflags = GFP_KERNEL | __GFP_RETRY_MAYFAIL;
+
+	/*
+	 * If a user thread allocates too much, and si_mem_available()
+	 * reports there's enough memory, even though there is not.
+	 * Make sure the OOM killer kills this thread. This can happen
+	 * even with RETRY_MAYFAIL because another task may be doing
+	 * an allocation after this task has taken all memory.
+	 * This is the task the OOM killer needs to take out during this
+	 * loop, even if it was triggered by an allocation somewhere else.
+	 */
+	if (user_thread)
+		set_current_oom_origin();
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
-		/*
-		 * __GFP_RETRY_MAYFAIL flag makes sure that the allocation fails
-		 * gracefully without invoking oom-killer and the system is not
-		 * destabilized.
-		 */
+
 		bpage = kzalloc_node(ALIGN(sizeof(*bpage), cache_line_size()),
-				    GFP_KERNEL | __GFP_RETRY_MAYFAIL,
-				    cpu_to_node(cpu));
+				    mflags, cpu_to_node(cpu));
 		if (!bpage)
 			goto free_pages;
 
 		list_add(&bpage->list, pages);
 
-		page = alloc_pages_node(cpu_to_node(cpu),
-					GFP_KERNEL | __GFP_RETRY_MAYFAIL, 0);
+		page = alloc_pages_node(cpu_to_node(cpu), mflags, 0);
 		if (!page)
 			goto free_pages;
 		bpage->page = page_address(page);
 		rb_init_page(bpage->page);
+
+		if (user_thread && fatal_signal_pending(current))
+			goto free_pages;
 	}
+	if (user_thread)
+		clear_current_oom_origin();
 
 	return 0;
 
@@ -1199,6 +1225,8 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 		list_del_init(&bpage->list);
 		free_buffer_page(bpage);
 	}
+	if (user_thread)
+		clear_current_oom_origin();
 
 	return -ENOMEM;
 }
-- 
2.13.6
