Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 25EB96B0236
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 14:24:04 -0400 (EDT)
Date: Fri, 26 Mar 2010 19:23:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #15
Message-ID: <20100326182311.GD5825@random.random>
References: <patchbomb.1269622804@v2.random>
 <alpine.DEB.2.00.1003261256080.31109@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003261256080.31109@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 01:00:12PM -0500, Christoph Lameter wrote:
> On Fri, 26 Mar 2010, Andrea Arcangeli wrote:
> 
> > 2) writing a HPAGE_PMD_ORDER front slab allocator. I don't think memory
> >    compaction is capable of relocating slab entries in-use (correct me if I'm
> >    wrong, I think it's impossible as long as the slab entries are mapped by 2M
> 
> SLUB is capable of using huge pages. Specify slub_min_order=9 on boot and
> it will make the kernel use huge pages.
> 
> >    pages and not 4k ptes like vmalloc). So the idea is that we should have the
> >    slab allocate 2M if it fails, 1M if it fails 512k etc... until it fallbacks
> >    to 4k. Otherwise the slab will fragment the memory badly by allocating with
> >    alloc_page(). Basically the buddy allocator will guarantee the slab will
> >    generate as much fragement as possible because it does its best to keep the
> >    high order pages for who asks for them. Probably the fallback should
> 
> Fallback is another issue. SLUB can handle various orders of pages in the
> same slab cache and already implements fallback to order 0. To implement
> a scheme as you suggest here would not require any changes to data
> structures but only to the slab allocation functions. See allocate_slab()
> in mm/slub.c

Thanks for the information! Luckily it seems Mel already taken care of
this part in his patchset. But in my view, this feature should be
available outside of SLUB/SLAB and potentially available to drivers
and such. SLUB having this embedded is nice to know!!!

BTW, unfortunately according to tons of measurements done so far, SLUB
is too slow on most workstations and small/mid servers (usually single
digits but in some case even double digits percentage slowdowns
depending on the workload, hackbench tends to stress it the
most). It's a tradeoff between avoiding wasting tons of ram on
1024-way and running fast. Either that or something's wrong with SLUB
implementation (and I'm talking about 2.6.32, no earlier code). I'd
also like to save memory so it'd be great if SLUB can be fixed to
perform faster!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
