Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5E4806B01E0
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 13:12:50 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 41] Transparent Hugepage Support #15
Message-Id: <patchbomb.1269622804@v2.random>
Date: Fri, 26 Mar 2010 18:00:04 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hello,

this fixes a potential issue with regard to simultaneous 4k and 2M TLB entries
in split_huge_page (at pratically zero cost, so I didn't need to add a fake
feature flag and it's a lot safer to do it this way just in case).
split_large_page in change_page_attr has the same issue too, but I've no idea
how to fix it there because the pmd cannot be marked non present at any given
time as change_page_attr may be running on ram below 640k and that is the same
pmd where the kernel .text resides. However I doubt it'll ever be a practical
problem. Other cpus also has a lot of warnings and risks in allowing
simultaneous TLB entries of different size.

Johannes also sent a cute optimization to split split_huge_page_vma/mm he 
converted those in a single split_huge_page_pmd and in addition he also sent
native support for hugepages in both mincore and mprotect. Which shows how
deep he already understands the whole huge_memory.c and its usage in the
callers.  Seeing significant contributions like this I think further confirms
this is the way to go. Thanks a lot Johannes.

The ability to bisect before the mincore and mprotect native implementations 
is one of the huge benefits of this approach. The hardest of all will be to 
add swap native support to 2M pages later (as it involves to make the 
swapcache 2M capable and that in turn means it expodes more than the rest all
over the pagecache code) but I think first we've other priorities:

1) merge memory compaction
2) writing a HPAGE_PMD_ORDER front slab allocator. I don't think memory
   compaction is capable of relocating slab entries in-use (correct me if I'm
   wrong, I think it's impossible as long as the slab entries are mapped by 2M
   pages and not 4k ptes like vmalloc). So the idea is that we should have the
   slab allocate 2M if it fails, 1M if it fails 512k etc... until it fallbacks
   to 4k. Otherwise the slab will fragment the memory badly by allocating with
   alloc_page(). Basically the buddy allocator will guarantee the slab will
   generate as much fragement as possible because it does its best to keep the
   high order pages for who asks for them. Probably the fallback should
   happen inside the buddy allocator instead of calling alloc_pages
   repeteadly, that should avoid taking a flood of locks. Basically
   the buddy should give the worst possible fragmentation effect to users that
   should be relocated, while the other users that cannot be relocated and
   only use 4k pages will better use a front allocator on top of alloc_pages.
   Something like alloc_page_not_relocatable() that will do its stuff
   internally and try to keep those in the same 2M pages. This alone should
   help tremendously and I think it's orthogonal to the memory compaction of
   the relocatable stuff. Or maybe we should just live with a large chunk of
   the memory not being relocatable, but I like this idea because it's more
   dynamic and it won't have fixed rule "limit the slab to 0-1g range". And
   it'd tend to try to keep fragmentation down even if we spill over the 1G
   range. (1g is purely made up number)
3) teach ksm to merge hugepages. I talked about this with Izik and we agree
   the current ksm tree algorithm will be the best at that compared to ksm
   algorithms.


To run KVM on top on this and take advantage of hugepages you need a few liner
patch I posted to qemu-devel to take care of aligning the start of the guest
memory so that the guest physical address and host virtual address will have
the same subpage numbers.

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-15
	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-15.gz

I'd be nice to have this merged in -mm.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
