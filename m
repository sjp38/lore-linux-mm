Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 8CC1E6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 16:56:16 -0500 (EST)
Date: Thu, 23 Feb 2012 13:56:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 2/2] mm: do not reset mm->free_area_cache on every
 single munmap
Message-Id: <20120223135614.7c4e02db.akpm@linux-foundation.org>
In-Reply-To: <20120223150034.2c757b3a@cuia.bos.redhat.com>
References: <20120223145417.261225fd@cuia.bos.redhat.com>
	<20120223150034.2c757b3a@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

On Thu, 23 Feb 2012 15:00:34 -0500
Rik van Riel <riel@redhat.com> wrote:

> Some programs have a large number of VMAs, and make frequent calls
> to mmap and munmap. Having munmap constantly cause the search
> pointer for get_unmapped_area to get reset can cause a significant
> slowdown for such programs. 
> 
> Likewise, starting all the way from the top any time we mmap a small 
> VMA can greatly increase the amount of time spent in 
> arch_get_unmapped_area_topdown.
> 
> For programs with many VMAs, a next-fit algorithm would be fastest,
> however that could waste a lot of virtual address space, and potentially
> page table memory.
> 
> A compromise is to reset the search pointer for get_unmapped_area
> after we have unmapped 1/8th of the normal memory in a process.

ick!

> For
> a process with 1000 similar sized VMAs, that means the search pointer
> will only be reset once every 125 or so munmaps.  The cost is that
> the program may use about 1/8th more virtual space for these VMAs,
> and up to 1/8th more page tables.
> 
> We do not count special mappings, since there are programs that
> use a large fraction of their address space mapping device memory,
> etc.
> 
> The benefit is that things scale a lot better, and we remove about
> 200 lines of code.

We've been playing whack-a-mole with this search for many years.  What
about developing a proper data structure with which to locate a
suitable-sized hole in O(log(N)) time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
