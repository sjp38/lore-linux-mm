Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F9636B01B0
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 17:27:48 -0400 (EDT)
Message-Id: <20100625212106.384650677@quilx.com>
Date: Fri, 25 Jun 2010 16:20:35 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
References: <20100625212026.810557229@quilx.com>
Content-Disposition: inline; filename=percpu_make_usable_during_early_boot
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, tj@kernel.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

allocpercpu() may be used during early boot after the page allocator
has been bootstrapped but when interrupts are still off. Make sure
that we do not do GFP_KERNEL allocations if this occurs.

Cc: tj@kernel.org
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/percpu.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/percpu.c
===================================================================
--- linux-2.6.orig/mm/percpu.c	2010-06-23 14:43:54.000000000 -0500
+++ linux-2.6/mm/percpu.c	2010-06-23 14:44:05.000000000 -0500
@@ -275,7 +275,8 @@ static void __maybe_unused pcpu_next_pop
  * memory is always zeroed.
  *
  * CONTEXT:
- * Does GFP_KERNEL allocation.
+ * Does GFP_KERNEL allocation (May be called early in boot when
+ * interrupts are still disabled. Will then do GFP_NOWAIT alloc).
  *
  * RETURNS:
  * Pointer to the allocated area on success, NULL on failure.
@@ -286,7 +287,7 @@ static void *pcpu_mem_alloc(size_t size)
 		return NULL;
 
 	if (size <= PAGE_SIZE)
-		return kzalloc(size, GFP_KERNEL);
+		return kzalloc(size, GFP_KERNEL & gfp_allowed_mask);
 	else {
 		void *ptr = vmalloc(size);
 		if (ptr)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
