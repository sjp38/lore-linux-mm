Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11F666B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 01:44:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t63so17920783pfi.5
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 22:44:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n5si6143199pfn.150.2017.10.08.22.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Oct 2017 22:44:37 -0700 (PDT)
Date: Mon, 9 Oct 2017 13:44:35 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH] page_alloc.c: inline __rmqueue()
Message-ID: <20171009054434.GA1798@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>

__rmqueue() is called by rmqueue_bulk() and rmqueue() under zone->lock
and that lock can be heavily contended with memory intensive applications.

Since __rmqueue() is a small function, inline it can save us some time.
With the will-it-scale/page_fault1/process benchmark, when using nr_cpu
processes to stress buddy:

On a 2 sockets Intel-Skylake machine:
      base          %change       head
     77342            +6.3%      82203        will-it-scale.per_process_ops

On a 4 sockets Intel-Skylake machine:
      base          %change       head
     75746            +4.6%      79248        will-it-scale.per_process_ops

This patch adds inline to __rmqueue().

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
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
