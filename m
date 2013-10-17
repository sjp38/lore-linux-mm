Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 12AA26B00A2
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 13:52:30 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2619807pbb.41
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 10:52:29 -0700 (PDT)
From: Damien Ramonda <damien.ramonda@intel.com>
Subject: [PATCH] readahead: fix sequential read cache miss detection
Date: Thu, 17 Oct 2013 20:09:12 +0200
Message-Id: <1382033352-21225-1-git-send-email-damien.ramonda@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, damien.ramonda@intel.com, pierre.tardy@intel.com, fengguang.wu@intel.com, david.a.cohen@intel.com

The kernel's readahead algorithm sometimes interprets random read
accesses as sequential and triggers unnecessary data prefecthing
from storage device (impacting random read average latency).

In order to identify sequential cache read misses, the readahead
algorithm intends to check whether offset - previous offset == 1
(trivial sequential reads) or offset - previous offset == 0
(sequential reads not aligned on page boundary):

if (offset - (ra->prev_pos >> PAGE_CACHE_SHIFT) <= 1UL)

The current offset is stored in the "offset" variable of type
"pgoff_t" (unsigned long), while previous offset is stored in
"ra->prev_pos" of type "loff_t" (long long). Therefore,
operands of the if statement are implicitly converted to type
long long. Consequently, when previous offset > current offset
(which happens on random pattern), the if condition is true
and access is wrongly interpeted as sequential. An unnecessary
data prefetching is triggered, impacting the average
random read latency.

Storing the previous offset value in a "pgoff_t" variable
(unsigned long) fixes the sequential read detection logic.

Signed-off-by: Damien Ramonda <damien.ramonda@intel.com>
Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>
Acked-by: Pierre Tardy <pierre.tardy@intel.com>
Acked-by: David Cohen <david.a.cohen@linux.intel.com>
---
 mm/readahead.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index e4ed041..5b637b5 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -401,6 +401,7 @@ ondemand_readahead(struct address_space *mapping,
 		   unsigned long req_size)
 {
 	unsigned long max = max_sane_readahead(ra->ra_pages);
+	pgoff_t prev_offset;
 
 	/*
 	 * start of file
@@ -452,8 +453,11 @@ ondemand_readahead(struct address_space *mapping,
 
 	/*
 	 * sequential cache miss
+	 * trivial case: (offset - prev_offset) == 1
+	 * unaligned reads: (offset - prev_offset) == 0
 	 */
-	if (offset - (ra->prev_pos >> PAGE_CACHE_SHIFT) <= 1UL)
+	prev_offset = (unsigned long long)ra->prev_pos >> PAGE_CACHE_SHIFT;
+	if (offset - prev_offset <= 1UL)
 		goto initial_readahead;
 
 	/*
-- 
1.7.0.4

---------------------------------------------------------------------
Intel Corporation SAS (French simplified joint stock company)
Registered headquarters: "Les Montalets"- 2, rue de Paris, 
92196 Meudon Cedex, France
Registration Number:  302 456 199 R.C.S. NANTERRE
Capital: 4,572,000 Euros

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
