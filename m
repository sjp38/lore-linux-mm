Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3630E6B01E3
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 13:37:19 -0400 (EDT)
Date: Fri, 26 Mar 2010 17:36:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #15
Message-ID: <20100326173655.GC2024@csn.ul.ie>
References: <patchbomb.1269622804@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <patchbomb.1269622804@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 06:00:04PM +0100, Andrea Arcangeli wrote:
> Hello,
> 
> this fixes a potential issue with regard to simultaneous 4k and 2M TLB entries
> in split_huge_page (at pratically zero cost, so I didn't need to add a fake
> feature flag and it's a lot safer to do it this way just in case).
> split_large_page in change_page_attr has the same issue too, but I've no idea
> how to fix it there because the pmd cannot be marked non present at any given
> time as change_page_attr may be running on ram below 640k and that is the same
> pmd where the kernel .text resides. However I doubt it'll ever be a practical
> problem. Other cpus also has a lot of warnings and risks in allowing
> simultaneous TLB entries of different size.
> 
> Johannes also sent a cute optimization to split split_huge_page_vma/mm he 
> converted those in a single split_huge_page_pmd and in addition he also sent
> native support for hugepages in both mincore and mprotect. Which shows how
> deep he already understands the whole huge_memory.c and its usage in the
> callers.  Seeing significant contributions like this I think further confirms
> this is the way to go. Thanks a lot Johannes.
> 
> The ability to bisect before the mincore and mprotect native implementations 
> is one of the huge benefits of this approach. The hardest of all will be to 
> add swap native support to 2M pages later (as it involves to make the 
> swapcache 2M capable and that in turn means it expodes more than the rest all
> over the pagecache code) but I think first we've other priorities:
> 
> 1) merge memory compaction

Testing V6 at the moment.

> 2) writing a HPAGE_PMD_ORDER front slab allocator. I don't think memory
>    compaction is capable of relocating slab entries in-use (correct me if I'm
>    wrong, I think it's impossible as long as the slab entries are mapped by 2M
>    pages and not 4k ptes like vmalloc).So the idea is that we should have the

Correct, slab pages currently cannot migrate. Framentation within slab
is minimised by anti-fragmentation by distinguishing between reclaimable
and unreclaimable slab and grouping them appropriately. The objective is
to put all the unmovable pages in as few 2M (or 4M or 16M) pages as
possible. If min_free_kbytes is tuned as hugeadm
--recommended-min_free_kbytes suggests, this works pretty well.

>    slab allocate 2M if it fails, 1M if it fails 512k etc... until it fallbacks
>    to 4k. Otherwise the slab will fragment the memory badly by allocating with
>    alloc_page().

Again, if min_free_kbytes is tuned appropriately, anti-frag should
mitigate most of the fragmentation-related damage.

On the notion of having a 2M front slab allocator, SLUB is not far off
being capable of such a thing but there are risks. If a 2M page is
dedicated to a slab, then other slabs will need their own 2M pages.
Overall memory usage grows and you end up worse off.

If you suggest that slab uses 2M pages and breaks them up for slabs, you
are very close to what anti-frag already does. The difference might be
that slab would guarantee that the 2M page is only use for slab. Again,
you could force this situation with anti-frag but the decision was made
to allow a certain amount of fragmentation to avoid the memory overhead
of such a thing. Again, tuning min_free_kbytes + anti-fragmentation gets
much of what you need.

Arguably, min_free_kbytes should be tuned appropriately once it's detected
that huge pages are in use. It would not be hard at all, we just don't do it.

Stronger guarantees on layout are possible but not done today because of
the cost.

>    Basically the buddy allocator will guarantee the slab will
>    generate as much fragement as possible because it does its best to keep the
>    high order pages for who asks for them.

Again, already does this up to a point. rmqueue_fallback() could refuse to
break up small contiguous pages for slab to force better layout in terms of
fragmentation but it costs heavily when memory is low because you now have to
reclaim (or relocate) more pages than necessary to satisfy anti-fragmentation.

> Probably the fallback should
>    happen inside the buddy allocator instead of calling alloc_pages
>    repeteadly, that should avoid taking a flood of locks. Basically
>    the buddy should give the worst possible fragmentation effect to users that
>    should be relocated, while the other users that cannot be relocated and
>    only use 4k pages will better use a front allocator on top of alloc_pages.
>    Something like alloc_page_not_relocatable() that will do its stuff
>    internally and try to keep those in the same 2M pages.

Sounds very similar to anti-frag again.

> This alone should
>    help tremendously and I think it's orthogonal to the memory compaction of
>    the relocatable stuff. Or maybe we should just live with a large chunk of
>    the memory not being relocatable,

You could force such a situation by always having X number of lower blocks
MIGRATE_UNMOVABLE and forcing a situation where fallback never happens to those
areas. You'd need to do some juggling with counters and watermarks. It's not
impossible and I considered doing it when anti-fragmentation was introduced
but again, there was insufficient data to support such a move.

> but I like this idea because it's more
>    dynamic and it won't have fixed rule "limit the slab to 0-1g range". And
>    it'd tend to try to keep fragmentation down even if we spill over the 1G
>    range. (1g is purely made up number)
> 3) teach ksm to merge hugepages. I talked about this with Izik and we agree
>    the current ksm tree algorithm will be the best at that compared to ksm
>    algorithms.
> 
> 
> To run KVM on top on this and take advantage of hugepages you need a few liner
> patch I posted to qemu-devel to take care of aligning the start of the guest
> memory so that the guest physical address and host virtual address will have
> the same subpage numbers.
> 
> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-15
> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-15.gz
> 
> I'd be nice to have this merged in -mm.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
