Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE926B04B7
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:05:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c23so135626616pfe.11
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:05:11 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id d5si9356606pfg.220.2017.07.10.23.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 23:05:10 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id e7so61564031pfk.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:05:10 -0700 (PDT)
From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH] tracing/ring_buffer: Try harder to allocate
Date: Mon, 10 Jul 2017 23:05:00 -0700
Message-Id: <20170711060500.17016-1-joelaf@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com, linux-mm@kvack.org, Joel Fernandes <joelaf@google.com>, Alexander Duyck <alexander.h.duyck@intel.com>, Mel Gorman <mgorman@suse.de>, Hao Lee <haolee.swjtu@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Tim Murray <timmurray@google.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org

ftrace can fail to allocate per-CPU ring buffer on systems with a large
number of CPUs coupled while large amounts of cache happening in the
page cache. Currently the ring buffer allocation doesn't retry in the VM
implementation even if direct-reclaim made some progress but still
wasn't able to find a free page. On retrying I see that the allocations
almost always succeed. The retry doesn't happen because __GFP_NORETRY is
used in the tracer to prevent the case where we might OOM, however if we
drop __GFP_NORETRY, we risk destabilizing the system if OOM killer is
triggered. To prevent this situation, use the __GFP_RETRY_MAYFAIL flag
introduced recently [1].

Tested the following still succeeds without destabilizing a system with
1GB memory.
echo 300000 > /sys/kernel/debug/tracing/buffer_size_kb

[1] https://marc.info/?l=linux-mm&m=149820805124906&w=2

Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hao Lee <haolee.swjtu@gmail.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tim Murray <timmurray@google.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: stable@vger.kernel.org
Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 kernel/trace/ring_buffer.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index 4ae268e687fe..529cc50d7243 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -1136,12 +1136,12 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
 		/*
-		 * __GFP_NORETRY flag makes sure that the allocation fails
-		 * gracefully without invoking oom-killer and the system is
-		 * not destabilized.
+		 * __GFP_RETRY_MAYFAIL flag makes sure that the allocation fails
+		 * gracefully without invoking oom-killer and the system is not
+		 * destabilized.
 		 */
 		bpage = kzalloc_node(ALIGN(sizeof(*bpage), cache_line_size()),
-				    GFP_KERNEL | __GFP_NORETRY,
+				    GFP_KERNEL | __GFP_RETRY_MAYFAIL,
 				    cpu_to_node(cpu));
 		if (!bpage)
 			goto free_pages;
@@ -1149,7 +1149,7 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 		list_add(&bpage->list, pages);
 
 		page = alloc_pages_node(cpu_to_node(cpu),
-					GFP_KERNEL | __GFP_NORETRY, 0);
+					GFP_KERNEL | __GFP_RETRY_MAYFAIL, 0);
 		if (!page)
 			goto free_pages;
 		bpage->page = page_address(page);
-- 
2.13.2.725.g09c95d1e9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
