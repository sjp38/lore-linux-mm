Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8848D6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:13:53 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id o7so359239155oif.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 23:13:53 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t19si8655739ioi.250.2016.09.12.23.13.51
        for <linux-mm@kvack.org>;
        Mon, 12 Sep 2016 23:13:52 -0700 (PDT)
Date: Tue, 13 Sep 2016 15:13:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Message-ID: <20160913061349.GA4445@bbox>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <20160909054336.GA2114@bbox>
 <87sht824n3.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87sht824n3.fsf@yhuang-mobile.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Hi Huang,

On Fri, Sep 09, 2016 at 01:35:12PM -0700, Huang, Ying wrote:

< snip >

> >> Recently, the performance of the storage devices improved so fast that
> >> we cannot saturate the disk bandwidth when do page swap out even on a
> >> high-end server machine.  Because the performance of the storage
> >> device improved faster than that of CPU.  And it seems that the trend
> >> will not change in the near future.  On the other hand, the THP
> >> becomes more and more popular because of increased memory size.  So it
> >> becomes necessary to optimize THP swap performance.
> >> 
> >> The advantages of the THP swap support include:
> >> 
> >> - Batch the swap operations for the THP to reduce lock
> >>   acquiring/releasing, including allocating/freeing the swap space,
> >>   adding/deleting to/from the swap cache, and writing/reading the swap
> >>   space, etc.  This will help improve the performance of the THP swap.
> >> 
> >> - The THP swap space read/write will be 2M sequential IO.  It is
> >>   particularly helpful for the swap read, which usually are 4k random
> >>   IO.  This will improve the performance of the THP swap too.
> >> 
> >> - It will help the memory fragmentation, especially when the THP is
> >>   heavily used by the applications.  The 2M continuous pages will be
> >>   free up after THP swapping out.
> >
> > I just read patchset right now and still doubt why the all changes
> > should be coupled with THP tightly. Many parts(e.g., you introduced
> > or modifying existing functions for making them THP specific) could
> > just take page_list and the number of pages then would handle them
> > without THP awareness.
> 
> I am glad if my change could help normal pages swapping too.  And we can
> change these functions to work for normal pages when necessary.

Sure but it would be less painful that THP awareness swapout is
based on multiple normal pages swapout. For exmaple, we don't
touch delay THP split part(i.e., split a THP into 512 pages like
as-is) and enhances swapout further like Tim's suggestion
for mulitple normal pages swapout. With that, it might be enough
for fast-storage without needing THP awareness.

My *point* is let's approach step by step.
First of all, go with batching normal pages swapout and if it's
not enough, dive into further optimization like introducing
THP-aware swapout.

I believe it's natural development process to evolve things
without over-engineering.

> 
> > For example, if the nr_pages is larger than SWAPFILE_CLUSTER, we
> > can try to allocate new cluster. With that, we could allocate new
> > clusters to meet nr_pages requested or bail out if we fail to allocate
> > and fallback to 0-order page swapout. With that, swap layer could
> > support multiple order-0 pages by batch.
> >
> > IMO, I really want to land Tim Chen's batching swapout work first.
> > With Tim Chen's work, I expect we can make better refactoring
> > for batching swap before adding more confuse to the swap layer.
> > (I expect it would share several pieces of code for or would be base
> > for batching allocation of swapcache, swapslot)
> 
> I don't think there is hard conflict between normal pages swapping
> optimizing and THP swap optimizing.  Some code may be shared between
> them.  That is good for both sides.
> 
> > After that, we could enhance swap for big contiguous batching
> > like THP and finally we might make it be aware of THP specific to
> > enhance further.
> >
> > A thing I remember you aruged: you want to swapin 512 pages
> > all at once unconditionally. It's really worth to discuss if
> > your design is going for the way.
> > I doubt it's generally good idea. Because, currently, we try to
> > swap in swapped out pages in THP page with conservative approach
> > but your direction is going to opposite way.
> >
> > [mm, thp: convert from optimistic swapin collapsing to conservative]
> >
> > I think general approach(i.e., less effective than targeting
> > implement for your own specific goal but less hacky and better job
> > for many cases) is to rely/improve on the swap readahead.
> > If most of subpages of a THP page are really workingset, swap readahead
> > could work well.
> >
> > Yeah, it's fairly vague feedback so sorry if I miss something clear.
> 
> Yes.  I want to go to the direction that to swap in 512 pages together.
> And I think it is a good opportunity to discuss that now.  The advantages
> of swapping in 512 pages together are:
> 
> - Improve the performance of swapping in IO via turning small read size
>   into 512 pages big read size.
> 
> - Keep THP across swap out/in.  With the memory size become more and
>   more large, the 4k pages bring more and more burden to memory
>   management.  One solution is to use 2M pages as much as possible, that
>   will reduce the management burden greatly, such as much reduced length
>   of LRU list, etc.
> 
> The disadvantage are:
> 
> - Increase the memory pressure when swap in THP.
> 
> - Some pages swapped in may not needed in the near future.
> 
> Because of the disadvantages, the 512 pages swapping in should be made
> optional.  But I don't think we should make it impossible.

Yeb. No need to make it impossible but your design shouldn't be coupled
with non-existing feature yet.

> 
> Best Regards,
> Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
