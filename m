Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6EE6B004F
	for <linux-mm@kvack.org>; Fri,  1 May 2009 10:12:27 -0400 (EDT)
Date: Fri, 1 May 2009 15:12:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
Message-ID: <20090501141234.GB27831@csn.ul.ie>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils> <20090430132544.GB21997@csn.ul.ie> <Pine.LNX.4.64.0905011202530.8513@blonde.anvils> <20090501140015.GA27831@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090501140015.GA27831@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 01, 2009 at 03:00:15PM +0100, Mel Gorman wrote:
> > <SNIP>
> > 
> > Andrew noticed another oddity: that if it goes the hashdist __vmalloc()
> > way, it won't be limited by MAX_ORDER.  Makes one wonder whether it
> > ought to fall back to __vmalloc() if the alloc_pages_exact() fails.
> 
> I don't believe so. __vmalloc() is only used when hashdist= is used or on IA-64
> (according to the documentation).

I was foolish to believe the documentation. vmalloc() will be used by
default on 64-bit NUMA, not just IA-64.

> It is used in the case that the caller is
> willing to deal with the vmalloc() overhead (e.g. using base page PTEs) in
> exchange for the pages being interleaved on different nodes so that access
> to the hash table has average performance[*]
> 
> If we automatically fell back to vmalloc(), I bet 2c we'd eventually get
> a mysterious performance regression report for a workload that depended on
> the hash tables performance but that there was enough memory for the hash
> table to be allocated with vmalloc() instead of alloc_pages_exact().
> 

I think this point still holds. On non-NUMA machine, we don't want to fall
back to using vmalloc() just because the machine happened to have enough
memory. It's really tricky to know for sure though - will there be enough
performance benefits from having a bigger hash table to offset using base
pages to back it? It's probably unknowable because it depends on the exact
hardware and how the hash table is being used.

> [*] I speculate that on non-IA64 NUMA machines that we see different
>     performance for large filesystem benchmarks depending on whether we are
>     running on the boot-CPU node or not depending on whether hashdist=
>     is used or not.

This speculation is junk because using vmalloc() for hash tables is not
specific to IA-64.

> <SNIP>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
