Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 351D36B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 22:56:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a7so67064904pfj.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 19:56:06 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x5si7433594plv.552.2017.10.09.19.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 19:56:05 -0700 (PDT)
Date: Tue, 10 Oct 2017 10:56:01 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2] mm/page_alloc.c: inline __rmqueue()
Message-ID: <20171010025601.GE1798@intel.com>
References: <20171009054434.GA1798@intel.com>
 <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
 <20171010025151.GD1798@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171010025151.GD1798@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

__rmqueue() is called by rmqueue_bulk() and rmqueue() under zone->lock
and the two __rmqueue() call sites are in very hot page allocator paths.

Since __rmqueue() is a small function, inline it can save us some time.
With the will-it-scale/page_fault1/process benchmark, when using nr_cpu
processes to stress buddy, this patch improved the benchmark by 6.3% on
a 2-sockets Intel-Skylake system and 4.6% on a 4-sockets Intel-Skylake
system. The benefit being less on 4 sockets machine is due to the lock
contention there(perf-profile/native_queued_spin_lock_slowpath=81%) is
less severe than on the 2 sockets machine(84%).

What the benchmark does is: it forks nr_cpu processes and then each
process does the following:
    1 mmap() 128M anonymous space;
    2 writes to each page there to trigger actual page allocation;
    3 munmap() it.
in a loop.
https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault1.c

This patch adds inline to __rmqueue() and vmlinux' size doesn't have any
change after this patch according to size(1).

without this patch:
   text    data     bss     dec     hex     filename
9968576 5793372 17715200  33477148  1fed21c vmlinux

with this patch:
   text    data     bss     dec     hex     filename
9968576 5793372 17715200  33477148  1fed21c vmlinux

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Tested-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
v2: change commit message according to Dave Hansen's suggestion.

 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0e309ce4a44a..c9605c7ebaf6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2291,7 +2291,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
  * Do the hard work of removing an element from the buddy allocator.
  * Call me with the zone->lock already held.
  */
-static struct page *__rmqueue(struct zone *zone, unsigned int order,
+static inline struct page *__rmqueue(struct zone *zone, unsigned int order,
 				int migratetype)
 {
 	struct page *page;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
