Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id EBC2A6B006E
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 03:55:48 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so2267448pbc.21
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 00:55:48 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id xr10si3171032pab.275.2014.03.14.00.55.46
        for <linux-mm@kvack.org>;
        Fri, 14 Mar 2014 00:55:48 -0700 (PDT)
Date: Fri, 14 Mar 2014 16:56:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/6] mm: support madvise(MADV_FREE)
Message-ID: <20140314075611.GF20556@bbox>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
 <5322B1B8.3010403@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5322B1B8.3010403@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>

Hello Zhang,

On Fri, Mar 14, 2014 at 03:37:28PM +0800, Zhang Yanfei wrote:
> Hello Minchan
> 
> On 03/14/2014 02:37 PM, Minchan Kim wrote:
> > This patch is an attempt to support MADV_FREE for Linux.
> > 
> > Rationale is following as.
> > 
> > Allocators call munmap(2) when user call free(3) if ptr is
> > in mmaped area. But munmap isn't cheap because it have to clean up
> > all pte entries, unlinking a vma and returns free pages to buddy
> > so overhead would be increased linearly by mmaped area's size.
> > So they like madvise_dontneed rather than munmap.
> > 
> > "dontneed" holds read-side lock of mmap_sem so other threads
> > of the process could go with concurrent page faults so it is
> > better than munmap if it's not lack of address space.
> > But the problem is that most of allocator reuses that address
> > space soonish so applications see page fault, page allocation,
> > page zeroing if allocator already called madvise_dontneed
> > on the address space.
> > 
> > For avoidng that overheads, other OS have supported MADV_FREE.
> > The idea is just mark pages as lazyfree when madvise called
> > and purge them if memory pressure happens. Otherwise, VM doesn't
> > detach pages on the address space so application could use
> > that memory space without above overheads.
> 
> I didn't look into the code. Does this mean we just keep the vma,
> the pte entries, and page itself for later possible reuse? If so,

Just clear pte access bit and dirty bit so the VM could notice
that user made page dirty since it called madvise(MADV_FREE).
If then, VM couldn't purge the page. Otherwise, VM could purge
the page instead of swapping and later, user could see the zeroed
pages.

> how can we reuse the vma? The kernel would mark the vma kinds of
> special so that it can be reused other than unmapped? Do you have

I don't get it. Could you elaborate it a bit?

> an example about this reuse?

As I said, jemalloc and tcmalloc have supported it for other OS.

> 
> Another thing is when I search MADV_FREE in the internet, I see that
> Rik posted the similar patch in 2007 but that patch didn't
> go into the upstream kernel.  And some explanation from Andrew:
> 
> ------------------------------------------------------
>  lazy-freeing-of-memory-through-madv_free.patch
> 
>  lazy-freeing-of-memory-through-madv_free-vs-mm-madvise-avoid-exclusive-mmap_sem.patch
> 
>  restore-madv_dontneed-to-its-original-linux-behaviour.patch
> 
> 
> 
> I think the MADV_FREE changes need more work:
> 
> 
> 
> We need crystal-clear statements regarding the present functionality, the new
> 
> functionality and how these relate to the spec and to implmentations in other
> 
> OS'es.  Once we have that info we are in a position to work out whether the
> 
> code can be merged as-is, or if additional changes are needed.
> 
> 
> 
> Because right now, I don't know where we are with respect to these things and
> 
> I doubt if many of our users know either.  How can Michael write a manpage for
> 
> this is we don't tell him what it all does?
> ------------------------------------------------------

True. I need more documentation and will do it if everybody agree on
this new feature.

Thanks.

> 
> Thanks
> Zhang Yanfei
> 
> > 
> > I tweaked jamalloc to use MADV_FREE for the testing.
> > 
> > diff --git a/src/chunk_mmap.c b/src/chunk_mmap.c
> > index 8a42e75..20e31af 100644
> > --- a/src/chunk_mmap.c
> > +++ b/src/chunk_mmap.c
> > @@ -131,7 +131,7 @@ pages_purge(void *addr, size_t length)
> >  #  else
> >  #    error "No method defined for purging unused dirty pages."
> >  #  endif
> > -       int err = madvise(addr, length, JEMALLOC_MADV_PURGE);
> > +       int err = madvise(addr, length, 5);
> >         unzeroed = (JEMALLOC_MADV_ZEROS == false || err != 0);
> >  #  undef JEMALLOC_MADV_PURGE
> >  #  undef JEMALLOC_MADV_ZEROS
> > 
> > 
> > RAM 2G, CPU 4, ebizzy benchmark(./ebizzy -S 30 -n 512)
> > 
> > (1.1) stands for 1 process and 1 thread so for exmaple,
> > (1.4) is 1 process and 4 thread.
> > 
> > vanilla jemalloc	 patched jemalloc
> > 
> > 1.1       1.1
> > records:  5              records:  5
> > avg:      7404.60        avg:      14059.80
> > std:      116.67(1.58%)  std:      93.92(0.67%)
> > max:      7564.00        max:      14152.00
> > min:      7288.00        min:      13893.00
> > 1.4       1.4
> > records:  5              records:  5
> > avg:      16160.80       avg:      30173.00
> > std:      509.80(3.15%)  std:      3050.72(10.11%)
> > max:      16728.00       max:      33989.00
> > min:      15216.00       min:      25173.00
> > 1.8       1.8
> > records:  5              records:  5
> > avg:      16003.00       avg:      30080.20
> > std:      290.40(1.81%)  std:      2063.57(6.86%)
> > max:      16537.00       max:      32735.00
> > min:      15727.00       min:      27381.00
> > 4.1       4.1
> > records:  5              records:  5
> > avg:      4003.60        avg:      8064.80
> > std:      65.33(1.63%)   std:      143.89(1.78%)
> > max:      4118.00        max:      8319.00
> > min:      3921.00        min:      7888.00
> > 4.4       4.4
> > records:  5              records:  5
> > avg:      3907.40        avg:      7199.80
> > std:      48.68(1.25%)   std:      80.21(1.11%)
> > max:      3997.00        max:      7320.00
> > min:      3863.00        min:      7113.00
> > 4.8       4.8
> > records:  5              records:  5
> > avg:      3893.00        avg:      7195.20
> > std:      19.11(0.49%)   std:      101.55(1.41%)
> > max:      3927.00        max:      7309.00
> > min:      3869.00        min:      7012.00
> > 8.1       8.1
> > records:  5              records:  5
> > avg:      1942.00        avg:      3602.80
> > std:      34.60(1.78%)   std:      22.97(0.64%)
> > max:      2010.00        max:      3632.00
> > min:      1913.00        min:      3563.00
> > 8.4       8.4
> > records:  5              records:  5
> > avg:      1938.00        avg:      3405.60
> > std:      32.77(1.69%)   std:      36.25(1.06%)
> > max:      1998.00        max:      3468.00
> > min:      1905.00        min:      3374.00
> > 8.8       8.8
> > records:  5              records:  5
> > avg:      1977.80        avg:      3434.20
> > std:      25.75(1.30%)   std:      57.95(1.69%)
> > max:      2011.00        max:      3533.00
> > min:      1937.00        min:      3363.00
> > 
> > So, MADV_FREE is 2 time faster than MADV_DONTNEED for
> > every cases.
> > 
> > I didn't test a lot but it's enough to show the concept and
> > direction before LSF/MM.
> > 
> > Patchset is based on 3.14-rc6.
> > 
> > Welcome any comment!
> > 
> > Minchan Kim (6):
> >   mm: clean up PAGE_MAPPING_FLAGS
> >   mm: work deactivate_page with anon pages
> >   mm: support madvise(MADV_FREE)
> >   mm: add stat about lazyfree pages
> >   mm: reclaim lazyfree pages in swapless system
> >   mm: ksm: don't merge lazyfree page
> > 
> >  include/asm-generic/tlb.h              |  9 ++++++++
> >  include/linux/mm.h                     | 39 +++++++++++++++++++++++++++++++++-
> >  include/linux/mm_inline.h              |  9 ++++++++
> >  include/linux/mmzone.h                 |  1 +
> >  include/linux/rmap.h                   |  1 +
> >  include/linux/swap.h                   | 15 +++++++++++++
> >  include/linux/vm_event_item.h          |  1 +
> >  include/uapi/asm-generic/mman-common.h |  1 +
> >  mm/ksm.c                               | 18 +++++++++++-----
> >  mm/madvise.c                           | 17 +++++++++++++--
> >  mm/memory.c                            | 12 ++++++++++-
> >  mm/page_alloc.c                        |  5 ++++-
> >  mm/rmap.c                              | 25 ++++++++++++++++++----
> >  mm/swap.c                              | 20 ++++++++---------
> >  mm/swap_state.c                        | 38 ++++++++++++++++++++++++++++++++-
> >  mm/vmscan.c                            | 32 +++++++++++++++++++++++++---
> >  mm/vmstat.c                            |  2 ++
> >  17 files changed, 217 insertions(+), 28 deletions(-)
> > 
> 
> 
> -- 
> Thanks.
> Zhang Yanfei
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
