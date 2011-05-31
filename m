Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 224916B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:34:30 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4VHEJuY020383
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:14:19 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4VHYSBJ085698
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:34:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4VHYRQD021583
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:34:27 -0400
Subject: Re: [PATCH 01/10] mm: Introduce the memory regions data structure
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110529081618.GC8333@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	 <1306499498-14263-2-git-send-email-ankita@in.ibm.com>
	 <1306510203.22505.69.camel@nimitz>
	 <20110527182041.GM5654@dirshya.in.ibm.com>
	 <1306531912.22505.84.camel@nimitz>  <20110529081618.GC8333@in.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 31 May 2011 10:34:20 -0700
Message-ID: <1306863260.15490.35.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: svaidy@linux.vnet.ibm.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, thomas.abraham@linaro.org

On Sun, 2011-05-29 at 13:46 +0530, Ankita Garg wrote:
> > It's worth noting that we already do targeted reclaim on boundaries
> > other than zones.  The lumpy reclaim and memory compaction logically do
> > the same thing.  So, it's at least possible to do this without having
> > the global LRU designed around the way you want to reclaim.
> >
> My understanding maybe incorrect, but doesn't both lumpy reclaim and
> memory compaction still work under zone boundary ? While trying to free
> up higher order pages, lumpy reclaim checks to ensure that pages that
> are selected do not cross zone boundary. Further, compaction walks
> through the pages in a zone and tries to re-arrange them.

I'm asserting that we don't need memory regions in the

	pgdat->regions[]->zones[]

layout to do what you're asking for.

Lumpy reclaim is limited to a zone because it's trying to satisfy and
allocation request that came in for *THAT* *ZONE*.  It's useless to go
clear out other zones.  In your case, you don't care about zone
boundaries: you want to reclaim things regardless.

There was a "cma: Contiguous Memory Allocator added" patch posted a bit
ago to linux-mm@.  You might want to take a look at it for some
inspiration.

I think you also need to clearly establish here why any memory that
you're going to want to power off can't use (or shouldn't use)
ZONE_MOVABLE.  It seems a bit silly to have it there, and ignore it for
such a similar use case.  Memory hot-remove and power-down are not
horrifically different beasts.

BTW, that's probably something else to add to your list: make sure
mem_map[]s for memory in a region get allocated *in* that region. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
