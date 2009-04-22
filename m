Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A88E06B00FB
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 16:11:40 -0400 (EDT)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id n3MKBkMq021949
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:11:46 -0700
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by zps38.corp.google.com with ESMTP id n3MKBjKd010843
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:11:45 -0700
Received: by rv-out-0708.google.com with SMTP id k29so121866rvb.24
        for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:11:45 -0700 (PDT)
Date: Wed, 22 Apr 2009 13:11:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
In-Reply-To: <20090422171151.GF15367@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0904221244030.14558@chino.kir.corp.google.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-3-git-send-email-mel@csn.ul.ie> <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009, Mel Gorman wrote:

> If there are users with good reasons, then we could convert this to WARN_ON
> to fix up the callers. I suspect that the allocator can already cope with
> recieving a stupid order silently but slowly. It should go all the way to the
> bottom and just never find anything useful and return NULL.  zone_watermark_ok
> is the most dangerous looking part but even it should never get to MAX_ORDER
> because it should always find there are not enough free pages and return
> before it overruns.
> 

slub: enforce MAX_ORDER

slub_max_order may not be equal to or greater than MAX_ORDER.

Additionally, if a single object cannot be placed in a slab of
slub_max_order, it still must allocate slabs below MAX_ORDER.

Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1909,7 +1909,7 @@ static inline int calculate_order(int size)
 	 * Doh this slab cannot be placed using slub_max_order.
 	 */
 	order = slab_order(size, 1, MAX_ORDER, 1);
-	if (order <= MAX_ORDER)
+	if (order < MAX_ORDER)
 		return order;
 	return -ENOSYS;
 }
@@ -2522,6 +2522,7 @@ __setup("slub_min_order=", setup_slub_min_order);
 static int __init setup_slub_max_order(char *str)
 {
 	get_option(&str, &slub_max_order);
+	slub_max_order = min(slub_max_order, MAX_ORDER - 1);
 
 	return 1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
