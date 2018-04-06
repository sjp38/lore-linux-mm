Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDD476B0023
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 09:01:18 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 61-v6so813381plz.20
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 06:01:18 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 185si7069811pgd.561.2018.04.06.06.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 06:01:15 -0700 (PDT)
Message-Id: <20180406130113.687518198@goodmis.org>
Date: Fri, 06 Apr 2018 09:00:48 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [for-next][PATCH 13/18] ring-buffer: Check if memory is available before allocation
References: <20180406130035.400292196@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=0013-ring-buffer-Check-if-memory-is-available-before-allo.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, Zhaoyang Huang <huangzhaoyang@gmail.com>, Joel Fernandes <joelaf@google.com>

From: "Steven Rostedt (VMware)" <rostedt@goodmis.org>

The ring buffer is made up of a link list of pages. When making the ring
buffer bigger, it will allocate all the pages it needs before adding to the
ring buffer, and if it fails, it frees them and returns an error. This makes
increasing the ring buffer size an all or nothing action. When this was
first created, the pages were allocated with "NORETRY". This was to not
cause any Out-Of-Memory (OOM) actions from allocating the ring buffer. But
NORETRY was too strict, as the ring buffer would fail to expand even when
there's memory available, but was taken up in the page cache.

Commit 848618857d253 ("tracing/ring_buffer: Try harder to allocate") changed
the allocating from NORETRY to RETRY_MAYFAIL. The RETRY_MAYFAIL would
allocate from the page cache, but if there was no memory available, it would
simple fail the allocation and not trigger an OOM.

This worked fine, but had one problem. As the ring buffer would allocate one
page at a time, it could take up all memory in the system before it failed
to allocate and free that memory. If the allocation is happening and the
ring buffer allocates all memory and then tries to take more than available,
its allocation will not trigger an OOM, but if there's any allocation that
happens someplace else, that could trigger an OOM, even though once the ring
buffer's allocation fails, it would free up all the previous memory it tried
to allocate, and allow other memory allocations to succeed.

Commit d02bd27bd33dd ("mm/page_alloc.c: calculate 'available' memory in a
separate function") separated out si_mem_availble() as a separate function
that could be used to see how much memory is available in the system. Using
this function to make sure that the ring buffer could be allocated before it
tries to allocate pages we can avoid allocating all memory in the system and
making it vulnerable to OOMs if other allocations are taking place.

Link: http://lkml.kernel.org/r/1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com

CC: stable@vger.kernel.org
Cc: linux-mm@kvack.org
Fixes: 848618857d253 ("tracing/ring_buffer: Try harder to allocate")
Requires: d02bd27bd33dd ("mm/page_alloc.c: calculate 'available' memory in a separate function")
Reported-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
Tested-by: Joel Fernandes <joelaf@google.com>
Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
 kernel/trace/ring_buffer.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index 515be03e3009..966128f02121 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -1164,6 +1164,11 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 	struct buffer_page *bpage, *tmp;
 	long i;
 
+	/* Check if the available memory is there first */
+	i = si_mem_available();
+	if (i < nr_pages)
+		return -ENOMEM;
+
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
 		/*
-- 
2.15.1
