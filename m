Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 49F966B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 15:06:27 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id t5-v6so6235303ybg.6
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:06:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p205si8659305qke.192.2018.04.17.12.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 12:06:26 -0700 (PDT)
Date: Tue, 17 Apr 2018 15:06:24 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1804171454020.26973@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org



On Tue, 17 Apr 2018, Christopher Lameter wrote:

> On Mon, 16 Apr 2018, Mikulas Patocka wrote:
> 
> > This patch introduces a flag SLAB_MINIMIZE_WASTE for slab and slub. This
> > flag causes allocation of larger slab caches in order to minimize wasted
> > space.
> >
> > This is needed because we want to use dm-bufio for deduplication index and
> > there are existing installations with non-power-of-two block sizes (such
> > as 640KB). The performance of the whole solution depends on efficient
> > memory use, so we must waste as little memory as possible.
> 
> Hmmm. Can we come up with a generic solution instead?
> 
> This may mean relaxing the enforcement of the allocation max order a bit
> so that we can get dense allocation through higher order allocs.
> 
> But then higher order allocs are generally seen as problematic.
> 
> Note that SLUB will fall back to smallest order already if a failure
> occurs so increasing slub_max_order may not be that much of an issue.
> 
> Maybe drop the max order limit completely and use MAX_ORDER instead? That
> means that callers need to be able to tolerate failures.

I can make a slub-only patch with no extra flag (on a freshly booted 
system it increases only the order of caches "TCPv6" and "sighand_cache" 
by one - so it should not have unexpected effects):

Doing a generic solution for slab would be more comlpicated because slab 
assumes that all slabs have the same order, so it can't fall-back to 
lower-order allocations.


From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] slub: minimize wasted space

When object size is greater than slub_max_order, the slub subsystem rounds
up the size to the next power of two. This causes a lot of wasted space -
i.e. 640KB block consumes 1MB of memory.

This patch makes the slub subsystem increase the order if it is benefical.
The order is increased as long as it reduces wasted space. There is cutoff
at 32 objects per slab.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 mm/slub.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2018-04-17 19:59:49.000000000 +0200
+++ linux-2.6/mm/slub.c	2018-04-17 20:58:23.000000000 +0200
@@ -3252,6 +3252,7 @@ static inline unsigned int slab_order(un
 static inline int calculate_order(unsigned int size, unsigned int reserved)
 {
 	unsigned int order;
+	unsigned int test_order;
 	unsigned int min_objects;
 	unsigned int max_objects;
 
@@ -3277,7 +3278,7 @@ static inline int calculate_order(unsign
 			order = slab_order(size, min_objects,
 					slub_max_order, fraction, reserved);
 			if (order <= slub_max_order)
-				return order;
+				goto ret_order;
 			fraction /= 2;
 		}
 		min_objects--;
@@ -3289,15 +3290,25 @@ static inline int calculate_order(unsign
 	 */
 	order = slab_order(size, 1, slub_max_order, 1, reserved);
 	if (order <= slub_max_order)
-		return order;
+		goto ret_order;
 
 	/*
 	 * Doh this slab cannot be placed using slub_max_order.
 	 */
 	order = slab_order(size, 1, MAX_ORDER, 1, reserved);
-	if (order < MAX_ORDER)
-		return order;
-	return -ENOSYS;
+	if (order >= MAX_ORDER)
+		return -ENOSYS;
+
+ret_order:
+	for (test_order = order + 1; test_order < MAX_ORDER; test_order++) {
+		unsigned long order_objects = ((PAGE_SIZE << order) - reserved) / size;
+		unsigned long test_order_objects = ((PAGE_SIZE << test_order) - reserved) / size;
+		if (test_order_objects > min(32, MAX_OBJS_PER_PAGE))
+			break;
+		if (test_order_objects > order_objects << (test_order - order))
+			order = test_order;
+	}
+	return order;
 }
 
 static void
