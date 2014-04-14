Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 096B36B00E7
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 13:23:43 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x12so8348764wgg.6
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 10:23:43 -0700 (PDT)
Received: from e06smtp18.uk.ibm.com (e06smtp18.uk.ibm.com. [195.75.94.114])
        by mx.google.com with ESMTPS id fl9si4967462wib.124.2014.04.14.10.23.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 10:23:40 -0700 (PDT)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sebott@linux.vnet.ibm.com>;
	Mon, 14 Apr 2014 18:23:39 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 52C1317D805A
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 18:24:32 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3EHNaa153805064
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 17:23:37 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3EHNZhr018535
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 11:23:36 -0600
Date: Mon, 14 Apr 2014 19:23:34 +0200 (CEST)
From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: [PATCH] mm/mempool: warn about __GFP_ZERO usage
Message-ID: <alpine.LFD.2.11.1404141918170.1561@denkbrett>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

I recently found out the hard way, that using mempool_alloc together with
__GFP_ZERO is not a good idea since memory which comes from the pool of
preallocated elemtents is not zeroed. Fixing this doesn't seem to be trivial
since mempool is not aware of the size of the objects it manages.

Last time someone addressed this on lkml just the callers of mempool_alloc
were fixed which obviously didn't help new users of mempool...
How about the following patch?

Regards,
Sebastian
---

mm/mempool: warn about __GFP_ZERO usage

Memory obtained via mempool_alloc is not always zeroed even when
called with __GFP_ZERO. Add a note and VM_BUG_ON statement to make
that clear.

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
---
 mm/mempool.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -192,6 +192,7 @@ EXPORT_SYMBOL(mempool_resize);
  * returns NULL. Note that due to preallocation, this function
  * *never* fails when called from process contexts. (it might
  * fail if called from an IRQ context.)
+ * Note: using __GFP_ZERO is not supported.
  */
 void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 {
@@ -200,6 +201,7 @@ void * mempool_alloc(mempool_t *pool, gf
 	wait_queue_t wait;
 	gfp_t gfp_temp;
 
+	VM_BUG_ON(gfp_mask & __GFP_ZERO);
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
 	gfp_mask |= __GFP_NOMEMALLOC;	/* don't allocate emergency reserves */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
