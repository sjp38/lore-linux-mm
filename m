Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 12E9D6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 04:54:18 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p528sEoa022230
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 18:54:14 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p528rV0f1220726
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 18:53:31 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p528sDL0005006
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 18:54:13 +1000
Date: Thu, 2 Jun 2011 14:24:09 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 01/10] mm: Introduce the memory regions data structure
Message-ID: <20110602085409.GA28096@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <1306499498-14263-2-git-send-email-ankita@in.ibm.com>
 <1306510203.22505.69.camel@nimitz>
 <20110527182041.GM5654@dirshya.in.ibm.com>
 <1306531912.22505.84.camel@nimitz>
 <20110529081618.GC8333@in.ibm.com>
 <1306863260.15490.35.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306863260.15490.35.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: svaidy@linux.vnet.ibm.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, thomas.abraham@linaro.org

Hi Dave,

On Tue, May 31, 2011 at 10:34:20AM -0700, Dave Hansen wrote:
> On Sun, 2011-05-29 at 13:46 +0530, Ankita Garg wrote:
> > > It's worth noting that we already do targeted reclaim on boundaries
> > > other than zones.  The lumpy reclaim and memory compaction logically do
> > > the same thing.  So, it's at least possible to do this without having
> > > the global LRU designed around the way you want to reclaim.
> > >
> > My understanding maybe incorrect, but doesn't both lumpy reclaim and
> > memory compaction still work under zone boundary ? While trying to free
> > up higher order pages, lumpy reclaim checks to ensure that pages that
> > are selected do not cross zone boundary. Further, compaction walks
> > through the pages in a zone and tries to re-arrange them.
> 
> I'm asserting that we don't need memory regions in the
> 
> 	pgdat->regions[]->zones[]
> 
> layout to do what you're asking for.
> 
> Lumpy reclaim is limited to a zone because it's trying to satisfy and
> allocation request that came in for *THAT* *ZONE*.  It's useless to go
> clear out other zones.  In your case, you don't care about zone
> boundaries: you want to reclaim things regardless.
>

Ok true. So I guess lumpy reclaim could be extended to just free up
pages spanning the entire region and not just a particular zone.
 
> There was a "cma: Contiguous Memory Allocator added" patch posted a bit
> ago to linux-mm@.  You might want to take a look at it for some
> inspiration.
> 

We did take a look at CMA, but the use case seems to be slightly
different. Inorder to allocate large contiguous pages, CMA creates a new
miratetype called MIGRATE_CMA, which effectively isolates pages from the
buddy allocator.

> I think you also need to clearly establish here why any memory that
> you're going to want to power off can't use (or shouldn't use)
> ZONE_MOVABLE.  It seems a bit silly to have it there, and ignore it for
> such a similar use case.  Memory hot-remove and power-down are not
> horrifically different beasts.
> 

Memory hot add and remove are definite usecases for conserving memory
power. In this first version of the RFC patch, I have not yet added the
support for ZONE_MOVABLE. I am currently testing the patch that creates
movable zones under regions, thus ensuring that it can be easily
evacuated using page migration.

> BTW, that's probably something else to add to your list: make sure
> mem_map[]s for memory in a region get allocated *in* that region. 
> 

There are a few reasons why we decided that we must have all the kernel
non-movable data structures co-located in a single region as much as
possible:

- Having a region devoid of non-movable memory will enable the complete
  memory region to be even hot-removed
- If the memory is evacuated and later turned off (loss of content),
  then the mem_map[]s will be lost. So when the memory comes back on,
  the mem_map[]s will need to be reinitialized. While the hotplug
  approach will work for exploiting PASR, it may not be the most
  efficient one
- When the memory is put into a lower power state, having the
  mem_maps[]s in a single region would ensure that any references to
  just the struct pages will not lead to references to the actual memory

However, it might be worth taking a look at it again.

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
