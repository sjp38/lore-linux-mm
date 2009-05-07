Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AA9436B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 06:45:57 -0400 (EDT)
Date: Thu, 7 May 2009 12:46:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses
	registrations.
Message-ID: <20090507104635.GG16078@random.random>
References: <4A00DD4F.8010101@redhat.com> <4A015C69.7010600@redhat.com> <4A0181EA.3070600@redhat.com> <20090506131735.GW16078@random.random> <Pine.LNX.4.64.0905061424480.19190@blonde.anvils> <20090506140904.GY16078@random.random> <20090506152100.41266e4c@lxorguk.ukuu.org.uk> <Pine.LNX.4.64.0905061532240.25289@blonde.anvils> <20090506145641.GA16078@random.random> <20090507085547.24efb60f.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507085547.24efb60f.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Hugh Dickins <hugh@veritas.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 08:55:47AM +0900, Minchan Kim wrote:
> Hmm. Don't you consider 32-bit system ?

Sorry I was too short, don't worry, I meant hugemem 32bit systems,
like 32G. If there's not much highmem, no problem can ever
happen. Just like pagetables had to be moved to highmem on 32G 32bit
systems to make them workable, KSM on those systems may generate lots
of lowmem and triggering early OOM conditions when allocating inodes
or other slab objects etc... and we don't plan to move those
rmap_items that represents physical pages by the chain of the virtual
addresses that maps them in highmem.

> Many embedded system is so I/O bouneded that we can use much CPU time in there. 

Embedded systems with >4G of ram should run 64bit these days, so I
don't see a problem.

> I hope this feature will help saving memory in embedded system. 

It will (assuming that there are apps that are duplicating anonymous
memory of course ;).

> One more thing about interface. 
> 
> Ksm map regions are dynamic characteritic ?
> I mean sometime A application calls ioctl(0x800000, 0x10000) and sometime it calls ioctl(0xb7000000, 0x20000);
> Of course, It depends on application's behavior. 

Looks like the ioctl API is going away in favour of madvise so it'll
function like madvise, if you munmap the region the KSM registration
will go away.

> ex) echo 'pid 0x8050000 0x100000' > sysfs or procfs or cgroup. 

This was answered by Chris, and surely this is feasible, as it is
feasible for kksmd to scan the whole system regardless of any
madvise. Some sysfs mangling should allow it.

However regardless of the highmem issue (this applies to 64bit systems
too) you've to keep in mind that for kksmd to keep track all pages
under scan it has to build rbtree and allocate rmap_items and
tree_items for each page tracked, those objects take some memory, so
if there's not much ram sharing you may waste more memory in the kksmd
allocations than in the amount of memory actually freed by KSM. This
is why it's better to selectively only register ranges that we know in
advance there's an high probability to free memory.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
