Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m6VHjTGm275754
	for <linux-mm@kvack.org>; Thu, 31 Jul 2008 17:45:29 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6VHjTB12593022
	for <linux-mm@kvack.org>; Thu, 31 Jul 2008 18:45:29 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6VHjSEh025814
	for <linux-mm@kvack.org>; Thu, 31 Jul 2008 18:45:29 +0100
Subject: memory hotplug: hot-add to ZONE_MOVABLE vs. min_free_kbytes
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <20080731132213.GF1704@csn.ul.ie>
References: <20080723105318.81BC.E1E9C6FF@jp.fujitsu.com>
	 <1217347653.4829.17.camel@localhost.localdomain>
	 <20080730110444.27DE.E1E9C6FF@jp.fujitsu.com>
	 <1217420161.4545.10.camel@localhost.localdomain>
	 <20080731132213.GF1704@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 31 Jul 2008 19:45:27 +0200
Message-Id: <1217526327.4643.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-31 at 14:22 +0100, Mel Gorman wrote:
> > The more memory we add to ZONE_MOVABLE, the less reserved pages will
> > remain to the other zones. In setup_per_zone_pages_min(), min_free_kbytes
> > will be redistributed to a zone where the kernel cannot make any use of
> > it, effectively reducing the available min_free_kbytes. 
> 
> I'm not sure what you mean by "available min_free_kbytes". The overall value
> for min_free_kbytes should be approximately the same whether the zone exists
> or not. However, you're right in that the distribution of minimum free pages
> changes with ZONE_MOVABLE because the zones are different sizes now. This
> affects reclaim, not memory hot-remove.

Sorry for mixing things up in this thread, the min_free_kbytes issue is
not related to memory hot-remove, but rather to hot-add and the things that
happen in setup_per_zone_pages_min(), which is called from online_pages().
It may well be that my assumptions are wrong, but I'd like to explain my
concerns again:

If we have a system with 1 GB of memory, min_free_kbytes will be calculated
to 4 MB for ZONE_NORMAL, for example. Now, if we add 3 GB of hotplug memory
to ZONE_MOVABLE, the total min_free_kbytes will still remain 4 MB but it
will be distributed differently: ZONE_NORMAL will now have only 1 MB of
MIGRATE_RESERVE memory left, while ZONE_MOVABLE will have 3 MB, e.g.

My assumption is now, that the reserved 3 MB in ZONE_MOVABLE won't be
usable by the kernel anymore, e.g. for PF_MEMALLOC, because it is in
ZONE_MOVABLE now. This is what I mean with "effectively reducing the
available min_free_kbytes". The system would now behave in the same way
as a system which only had 1 MB of min_free_kbytes, although
/proc/sys/vm/min_free_kbytes would still say 4 MB. After all, this tunable
can have a rather negative impact on a system, especially if it is too
low, hence my concerns.


> > This just doesn't
> > sound right. I believe that a similar situation is the reason why highmem
> > pages are skipped in the calculation and I think that we need that for
> > ZONE_MOVABLE too. Any thoughts on that problem?
> > 
> 
> is_highmem(ZONE_MOVABLE) should be returning true if the zone is really
> part of himem.

We don't have highmem on s390, I was just trying to give an example: I
noticed that there is special treatment for highmem pages in
setup_per_zone_pages_min(), and thought that we may also need to handle
ZONE_MOVABLE in a special way.


> > Setting pages_min to 0 for ZONE_MOVABLE, while not capping pages_low
> > and pages_high, could be an option. I don't have a sufficient memory
> > managment overview to tell if that has negative side effects, maybe
> > someone with a deeper insight could comment on that.
> > 
> 
> pages_min of 0 means the other values would be 0 as well. This means that
> kswapd may never be woken up to free pages within that zone and lead to
> poor utilisation of the zone as allocators fallback to other zones to
> avoid direct reclaim. I don't think that is your intention nor will it
> help memory hot-remove.

Do you mean pages_low and pages_high? In setup_per_zone_pages_min(),
those would not be set to 0, even if we set pages_min to 0. Again, a
similar strategy is being used for highmem in that function, only that
pages_min is set to a small value instead of 0 in that case. So it should
not affect kswapd but only __GFP_HIGH and PF_MEMALLOC allocations, which
won't be allocated from ZONE_MOVABLE anyway if I understood that right.


Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
