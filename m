Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m71G4wZE055956
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 16:04:58 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m71G4vKT3940436
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 17:04:57 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m71G4uMG015972
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 17:04:57 +0100
Subject: Re: memory hotplug: hot-add to ZONE_MOVABLE vs. min_free_kbytes
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <20080801192646.EC99.E1E9C6FF@jp.fujitsu.com>
References: <20080731132213.GF1704@csn.ul.ie>
	 <1217526327.4643.35.camel@localhost.localdomain>
	 <20080801192646.EC99.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 01 Aug 2008 18:04:55 +0200
Message-Id: <1217606695.5678.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-08-01 at 20:16 +0900, Yasunori Goto wrote:
> > My assumption is now, that the reserved 3 MB in ZONE_MOVABLE won't be
> > usable by the kernel anymore, e.g. for PF_MEMALLOC, because it is in
> > ZONE_MOVABLE now.
> 
> I don't make sense here. I suppose there is no relationship between
> ZONE_MOVABLE, PF_MEMALLOC and MIGRATE_RESERVE pages.
> Could you tell me more?

Ok, I thought that PF_MEMALLOC allocations work on the MIGRATE_RESERVE
pageblocks, and that only kernel allocations can use PF_MEMALLOC. I also
thought that kernel allocations cannot use ZONE_MOVABLE, e.g. for page
cache memory, because such pages would not be migratable. So I assumed
that MIGRATE_RESERVE pageblocks in ZONE_MOVABLE would not be available
for PF_MEMALLOC allocations.

With this assumption, which can be totally wrong, the redistribution
of MIGRATE_RESERVE pageblocks in setup_per_zone_pages_min() looks like
it will take away reserved pageblocks that should be available to the
kernel in emergency situations.

Maybe I should have explained this assumption earlier, because my whole
min_free_kbytes issue depends on it. If I'm wrong, I apologize for
confusing you all with this "issue", and I will go back to the original
problem with removing the lowest memory chunk in ZONE_MOVABLE...

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
