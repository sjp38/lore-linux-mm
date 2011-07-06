Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B74756B004A
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 12:47:29 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p66GfvV3003507
	for <linux-mm@kvack.org>; Thu, 7 Jul 2011 02:41:57 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p66GecSH1290304
	for <linux-mm@kvack.org>; Thu, 7 Jul 2011 02:40:38 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p66GfuYD010224
	for <linux-mm@kvack.org>; Thu, 7 Jul 2011 02:41:57 +1000
Date: Wed, 6 Jul 2011 22:11:46 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110706164146.GD4356@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110629130038.GA7909@in.ibm.com>
 <CAOJsxLHQP=-srK_uYYBsPb7+rUBnPZG7bzwtCd-rRaQa4ikUFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJsxLHQP=-srK_uYYBsPb7+rUBnPZG7bzwtCd-rRaQa4ikUFg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, thomas.abraham@linaro.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Lameter <cl@linux.com>

* Pekka Enberg <penberg@kernel.org> [2011-07-06 11:45:41]:

> Hi Ankita,
> 
> [ I don't really know anything about memory power management but
>   here's my two cents since you asked for it. ]
> 
> On Wed, Jun 29, 2011 at 4:00 PM, Ankita Garg <ankita@in.ibm.com> wrote:
> > I) Dynamic Power Transition
> >
> > The goal here is to ensure that as much as possible, on an idle system,
> > the memory references do not get spread across the entire RAM, a problem
> > similar to memory fragmentation. The proposed approach is as below:
> >
> > 1) One of the first things is to ensure that the memory allocations do
> > not spill over to more number of regions. Thus the allocator needs to
> > be aware of the address boundary of the different regions.
> 
> Why does the allocator need to know about address boundaries? Why
> isn't it enough to make the page allocator and reclaim policies favor using
> memory from lower addresses as aggressively as possible? That'd mean
> we'd favor the first memory banks and could keep the remaining ones
> powered off as much as possible.

Yes, this will work to a limited extent when we have few regions to
account for.  However if applications start and stop leaving large
holes in the address map, it may not worth the effort of migrating
pages to lower addresses to pack the holes.

> IOW, why do we need to support scenarios such as this:
> 
>    bank 0     bank 1   bank 2    bank3
>  | online  | offline | online  | offline |
> 
> instead of using memory compaction and possibly something like the
> SLUB defragmentation patches to turn the memory map into this:
> 
>    bank 0     bank 1   bank 2   bank3
>  | online  | online  | offline | offline |

Yes, this is what we need, but also have a notion of how many pages
are used in each bank so that we can pack pages from under utilized
banks into a reasonably used bank and thereby free more banks.

Freeing more banks + clustering all used or free banks gives us more
power saving benefits.

> > 2) At the time of allocation, before spilling over allocations to the
> > next logical region, the allocator needs to make a best attempt to
> > reclaim some memory from within the existing region itself first. The
> > reclaim here needs to be in LRU order within the region.  However, if
> > it is ascertained that the reclaim would take a lot of time, like there
> > are quite a fe write-backs needed, then we can spill over to the next
> > memory region (just like our NUMA node allocation policy now).
> 
> I think a much more important question is what happens _after_ we've
> allocated and free'd tons of memory few times. AFAICT, memory
> regions don't help with that kind of fragmentation that will eventually
> happen anyway.
 
Memory regions allow us to have a zone per-region.  This helps in the
cases were allocations are fragments into multiple regions by
potentially reclaiming very low utilized regions and packing the pages
into higher utilized regions.  The requirement is a standard
de-fragmentation approach, except that the cluster of allocations
should fall within a region (any region) as much as possible.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
