Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D63796B0087
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:06:54 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4F12pX3008422
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 15 May 2009 10:02:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E3A145DE55
	for <linux-mm@kvack.org>; Fri, 15 May 2009 10:02:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E27AF45DD79
	for <linux-mm@kvack.org>; Fri, 15 May 2009 10:02:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF4421DB803F
	for <linux-mm@kvack.org>; Fri, 15 May 2009 10:02:50 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 854311DB803A
	for <linux-mm@kvack.org>; Fri, 15 May 2009 10:02:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <alpine.DEB.1.10.0905141602010.1381@qirst.com>
References: <20090513152256.GM7601@sgi.com> <alpine.DEB.1.10.0905141602010.1381@qirst.com>
Message-Id: <20090515082836.F5B9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 May 2009 10:02:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Robin Holt <holt@sgi.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> Not having zone reclaim on a NUMA system often means that per node
> allocations will fall back. Optimized node local allocations become very
> difficult for the page allocator. If the latency penalties are not
> significant then this may not matter. The larger the system, the larger
> the NUMA latencies become.
> 
> One possibility would be to disable zone reclaim for low node numbers.
> Eanble it only if more than 4 nodes exist?

I think this idea works good every machine and doesn't cause confusion
to HPC user.

How about this?

==============================
Subject: [PATCH] zone_reclaim is always 0 by default on small machine

Current linux policy is, zone_reclaim_mode is enabled by default if the machine
has large remote node distance. it's because we could assume that large distance 
mean large server until recently.

Unfortunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
memory controller. IOW it's seen as NUMA from software view.

Some Core i7 machine has large remote node distance, but zone_reclaim don't
fit desktop and small file server. it cause performance degression.

Thus, zone_reclaim == 0 is better by default if the machine is small.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Robin Holt <holt@sgi.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2497,7 +2497,7 @@ static void build_zonelists(pg_data_t *p
 		 * If another node is sufficiently far away then it is better
 		 * to reclaim pages in a zone before going off node.
 		 */
-		if (distance > RECLAIM_DISTANCE)
+		if (nr_online_nodes >= 4 && distance > RECLAIM_DISTANCE)
 			zone_reclaim_mode = 1;
 
 		/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
