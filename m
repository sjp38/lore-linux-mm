Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3C96B02C3
	for <linux-mm@kvack.org>; Sun,  9 Jul 2017 18:49:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g14so98818587pgu.9
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 15:49:25 -0700 (PDT)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id s2si6627511pfd.455.2017.07.09.15.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 15:49:24 -0700 (PDT)
Received: by mail-pg0-x22e.google.com with SMTP id j186so39964280pge.2
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 15:49:24 -0700 (PDT)
From: Joel Fernandes <joelaf@google.com>
Subject: [RFC v1 2/2] tracing/ring_buffer: Try harder to allocate
Date: Sun,  9 Jul 2017 15:49:11 -0700
Message-Id: <20170709224911.13030-2-joelaf@google.com>
In-Reply-To: <20170709224911.13030-1-joelaf@google.com>
References: <20170709224911.13030-1-joelaf@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Joel Fernandes <joelaf@google.com>, Alexander Duyck <alexander.h.duyck@intel.com>, Mel Gorman <mgorman@suse.de>, Hao Lee <haolee.swjtu@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org

ftrace can fail to allocate per-CPU ring buffer on systems with a large
number of CPUs coupled while large amounts of cache happening in the
page cache. Currently the ring buffer allocation doesn't retry in the VM
implementation even if direct-reclaim made some progress but still
wasn't able to find a free page. On retrying I see that the allocations
almost always succeed. The retry doesn't happen because __GFP_NORETRY is
used in the tracer to prevent the case where we might OOM, however if we
drop __GFP_NORETRY, we risk destabilizing the system if OOM killer is
triggered. To prevent this situation, use the __GFP_DONTOOM flag
introduced in earlier patches while droppping __GFP_NORETRY.

With this the following succeed without destabilizing a system with 8
CPU cores and 4GB of memory:
echo 100000 > /sys/kernel/debug/tracing/buffer_size_kb
On an 8-core system, that would allocate ~800MB.

Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hao Lee <haolee.swjtu@gmail.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 kernel/trace/ring_buffer.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index 4ae268e687fe..b1cdcac6ca89 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -1141,7 +1141,7 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 		 * not destabilized.
 		 */
 		bpage = kzalloc_node(ALIGN(sizeof(*bpage), cache_line_size()),
-				    GFP_KERNEL | __GFP_NORETRY,
+				    GFP_KERNEL | __GFP_DONTOOM,
 				    cpu_to_node(cpu));
 		if (!bpage)
 			goto free_pages;
@@ -1149,7 +1149,7 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 		list_add(&bpage->list, pages);
 
 		page = alloc_pages_node(cpu_to_node(cpu),
-					GFP_KERNEL | __GFP_NORETRY, 0);
+					GFP_KERNEL | __GFP_DONTOOM, 0);
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
