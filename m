Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 597FC6B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 13:34:18 -0500 (EST)
Date: Wed, 27 Jan 2010 12:33:32 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
In-Reply-To: <4B5F75B2.1000203@redhat.com>
Message-ID: <alpine.DEB.2.00.1001271229530.15736@router.home>
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home>
 <4B5E3CC0.2060006@redhat.com> <alpine.DEB.2.00.1001260947580.23549@router.home> <4B5F75B2.1000203@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010, Rik van Riel wrote:

> > Huge pages are already in use through hugetlbs for such workloads. That
> > works without swap. So why is this suddenly such a must have requirement?
> >
> > Why not swap 2M huge pages as a whole?
>
> A few reasons:
>
> 1) Fragmentation of swap space (or the need for a separate
>    swap area for 2MB pages)

Swap is already statically allocated. Would not be too difficult to add a
2M area.

> 2) There is no code to allow us to swap out 2MB pages

If the page descriptors stay the same for huge pages (one page struct
describes one 2MB page without any of the weird stuff added in this set)
then its simple to do with minor modifications to the existing code.

> 3) Internal fragmentation.  While 4kB pages are smaller than
>    the objects allocated by many programs, it is likely that
>    most 2MB pages contain both frequently used and rarely
>    used malloced objects.  Swapping out just the rarely used
>    4kB pages from a number of 2MB pages allows us to keep all
>    of the frequently used data in memory.

But that makes the huge page vanish. So no benefit at all from the huge
page logic. Just overhead.

>    Swapping out 2MB pages, on the other hand, makes it harder
>    to keep the working set in memory. TLB misses are much cheaper
>    than major page faults.

True. Thats why one should not swap if one wants decent performance.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
