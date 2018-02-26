Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79E2C6B0009
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 14:11:32 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id c40so10421217uae.18
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:11:32 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id q18si3021391uaa.65.2018.02.26.11.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 11:11:31 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/1] make start_isolate_page_range() thread safe
Date: Mon, 26 Feb 2018 11:10:53 -0800
Message-Id: <20180226191054.14025-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This patch was included in the RFC series "Interface for higher order
contiguous allocations".
http://lkml.kernel.org/r/20180212222056.9735-1-mike.kravetz@oracle.com

Since there have been few comments on the RFC and this patch addresses
a real issue with the current code, I am sending it separately.

To verify this is a real issue, I created a large CMA area at boot time.
I wrote some code to exercise large allocations and frees via cma_alloc()
and cma_release().  At the same time, I had a script just allocate and
free gigantic pages via the sysfs interface.

After a little bit of running, 'free memory' on the system went to
zero.  After 'stopping' the tests, I observed that most zone normal
page blocks were marked as MIGRATE_ISOLATE.  Hence 'not available'.

I suspect there are few (if any) systems employing both CMA and
dynamic gigantic huge page allocation.  However, it is probably a
good idea to fix this issue.  Because this is so unlikely, I am not
sure if this should got to stable releases as well.

Mike Kravetz (1):
  mm: make start_isolate_page_range() fail if already isolated

 mm/page_alloc.c     |  8 ++++----
 mm/page_isolation.c | 10 +++++++++-
 2 files changed, 13 insertions(+), 5 deletions(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
