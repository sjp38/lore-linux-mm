Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DFC7A6B0092
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 03:42:29 -0400 (EDT)
Date: Mon, 31 Aug 2009 15:42:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] slqb: add common slab debug bits
Message-ID: <20090831074221.GA10263@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a simple copy&paste from slub.c:

- lockdep annotation
- might sleep annotation
- fault injection

CC: Nick Piggin <nickpiggin@yahoo.com.au>
CC: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/slqb.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- linux-mm.orig/mm/slqb.c	2009-08-28 15:51:15.000000000 +0800
+++ linux-mm/mm/slqb.c	2009-08-28 16:05:33.000000000 +0800
@@ -19,6 +19,7 @@
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
+#include <linux/fault-inject.h>
 
 /*
  * TODO
@@ -1541,6 +1542,12 @@ static __always_inline void *slab_alloc(
 
 	gfpflags &= gfp_allowed_mask;
 
+	lockdep_trace_alloc(gfpflags);
+	might_sleep_if(gfpflags & __GFP_WAIT);
+
+	if (should_failslab(s->objsize, gfpflags))
+		return NULL;
+
 again:
 	local_irq_save(flags);
 	object = __slab_alloc(s, gfpflags, node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
