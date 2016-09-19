Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8ADA46B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 03:08:09 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u18so250618436ita.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 00:08:09 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y63si24085985itd.90.2016.09.19.00.08.07
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 00:08:08 -0700 (PDT)
Date: Mon, 19 Sep 2016 16:08:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Message-ID: <20160919070805.GA4083@bbox>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <20160909054336.GA2114@bbox>
 <87sht824n3.fsf@yhuang-mobile.sh.intel.com>
 <20160913061349.GA4445@bbox>
 <87y42wgv5r.fsf@yhuang-dev.intel.com>
 <20160913070524.GA4973@bbox>
 <87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
 <20160913091652.GB7132@bbox>
 <87intu9dng.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87intu9dng.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Hi Huang,

On Sun, Sep 18, 2016 at 09:53:39AM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Tue, Sep 13, 2016 at 04:53:49PM +0800, Huang, Ying wrote:
> >> Minchan Kim <minchan@kernel.org> writes:
> >> > On Tue, Sep 13, 2016 at 02:40:00PM +0800, Huang, Ying wrote:
> >> >> Minchan Kim <minchan@kernel.org> writes:
> >> >> 
> >> >> > Hi Huang,
> >> >> >
> >> >> > On Fri, Sep 09, 2016 at 01:35:12PM -0700, Huang, Ying wrote:
> >> >> >
> >> >> > < snip >
> >> >> >
> >> >> >> >> Recently, the performance of the storage devices improved so fast that
> >> >> >> >> we cannot saturate the disk bandwidth when do page swap out even on a
> >> >> >> >> high-end server machine.  Because the performance of the storage
> >> >> >> >> device improved faster than that of CPU.  And it seems that the trend
> >> >> >> >> will not change in the near future.  On the other hand, the THP
> >> >> >> >> becomes more and more popular because of increased memory size.  So it
> >> >> >> >> becomes necessary to optimize THP swap performance.
> >> >> >> >> 
> >> >> >> >> The advantages of the THP swap support include:
> >> >> >> >> 
> >> >> >> >> - Batch the swap operations for the THP to reduce lock
> >> >> >> >>   acquiring/releasing, including allocating/freeing the swap space,
> >> >> >> >>   adding/deleting to/from the swap cache, and writing/reading the swap
> >> >> >> >>   space, etc.  This will help improve the performance of the THP swap.
> >> >> >> >> 
> >> >> >> >> - The THP swap space read/write will be 2M sequential IO.  It is
> >> >> >> >>   particularly helpful for the swap read, which usually are 4k random
> >> >> >> >>   IO.  This will improve the performance of the THP swap too.
> >> >> >> >> 
> >> >> >> >> - It will help the memory fragmentation, especially when the THP is
> >> >> >> >>   heavily used by the applications.  The 2M continuous pages will be
> >> >> >> >>   free up after THP swapping out.
> >> >> >> >
> >> >> >> > I just read patchset right now and still doubt why the all changes
> >> >> >> > should be coupled with THP tightly. Many parts(e.g., you introduced
> >> >> >> > or modifying existing functions for making them THP specific) could
> >> >> >> > just take page_list and the number of pages then would handle them
> >> >> >> > without THP awareness.
> >> >> >> 
> >> >> >> I am glad if my change could help normal pages swapping too.  And we can
> >> >> >> change these functions to work for normal pages when necessary.
> >> >> >
> >> >> > Sure but it would be less painful that THP awareness swapout is
> >> >> > based on multiple normal pages swapout. For exmaple, we don't
> >> >> > touch delay THP split part(i.e., split a THP into 512 pages like
> >> >> > as-is) and enhances swapout further like Tim's suggestion
> >> >> > for mulitple normal pages swapout. With that, it might be enough
> >> >> > for fast-storage without needing THP awareness.
> >> >> >
> >> >> > My *point* is let's approach step by step.
> >> >> > First of all, go with batching normal pages swapout and if it's
> >> >> > not enough, dive into further optimization like introducing
> >> >> > THP-aware swapout.
> >> >> >
> >> >> > I believe it's natural development process to evolve things
> >> >> > without over-engineering.
> >> >> 
> >> >> My target is not only the THP swap out acceleration, but also the full
> >> >> THP swap out/in support without splitting THP.  This patchset is just
> >> >> the first step of the full THP swap support.
> >> >> 
> >> >> >> > For example, if the nr_pages is larger than SWAPFILE_CLUSTER, we
> >> >> >> > can try to allocate new cluster. With that, we could allocate new
> >> >> >> > clusters to meet nr_pages requested or bail out if we fail to allocate
> >> >> >> > and fallback to 0-order page swapout. With that, swap layer could
> >> >> >> > support multiple order-0 pages by batch.
> >> >> >> >
> >> >> >> > IMO, I really want to land Tim Chen's batching swapout work first.
> >> >> >> > With Tim Chen's work, I expect we can make better refactoring
> >> >> >> > for batching swap before adding more confuse to the swap layer.
> >> >> >> > (I expect it would share several pieces of code for or would be base
> >> >> >> > for batching allocation of swapcache, swapslot)
> >> >> >> 
> >> >> >> I don't think there is hard conflict between normal pages swapping
> >> >> >> optimizing and THP swap optimizing.  Some code may be shared between
> >> >> >> them.  That is good for both sides.
> >> >> >> 
> >> >> >> > After that, we could enhance swap for big contiguous batching
> >> >> >> > like THP and finally we might make it be aware of THP specific to
> >> >> >> > enhance further.
> >> >> >> >
> >> >> >> > A thing I remember you aruged: you want to swapin 512 pages
> >> >> >> > all at once unconditionally. It's really worth to discuss if
> >> >> >> > your design is going for the way.
> >> >> >> > I doubt it's generally good idea. Because, currently, we try to
> >> >> >> > swap in swapped out pages in THP page with conservative approach
> >> >> >> > but your direction is going to opposite way.
> >> >> >> >
> >> >> >> > [mm, thp: convert from optimistic swapin collapsing to conservative]
> >> >> >> >
> >> >> >> > I think general approach(i.e., less effective than targeting
> >> >> >> > implement for your own specific goal but less hacky and better job
> >> >> >> > for many cases) is to rely/improve on the swap readahead.
> >> >> >> > If most of subpages of a THP page are really workingset, swap readahead
> >> >> >> > could work well.
> >> >> >> >
> >> >> >> > Yeah, it's fairly vague feedback so sorry if I miss something clear.
> >> >> >> 
> >> >> >> Yes.  I want to go to the direction that to swap in 512 pages together.
> >> >> >> And I think it is a good opportunity to discuss that now.  The advantages
> >> >> >> of swapping in 512 pages together are:
> >> >> >> 
> >> >> >> - Improve the performance of swapping in IO via turning small read size
> >> >> >>   into 512 pages big read size.
> >> >> >> 
> >> >> >> - Keep THP across swap out/in.  With the memory size become more and
> >> >> >>   more large, the 4k pages bring more and more burden to memory
> >> >> >>   management.  One solution is to use 2M pages as much as possible, that
> >> >> >>   will reduce the management burden greatly, such as much reduced length
> >> >> >>   of LRU list, etc.
> >> >> >> 
> >> >> >> The disadvantage are:
> >> >> >> 
> >> >> >> - Increase the memory pressure when swap in THP.
> >> >> >> 
> >> >> >> - Some pages swapped in may not needed in the near future.
> >> >> >> 
> >> >> >> Because of the disadvantages, the 512 pages swapping in should be made
> >> >> >> optional.  But I don't think we should make it impossible.
> >> >> >
> >> >> > Yeb. No need to make it impossible but your design shouldn't be coupled
> >> >> > with non-existing feature yet.
> >> >> 
> >> >> Sorry, what is the "non-existing feature"?  The full THP swap out/in
> >> >
> >> > THP swapin.
> >> >
> >> > You said you increased cluster size to fit a THP size for recording
> >> > some meta in there for THP swapin.
> >> 
> >> And to find the head of the THP to swap in the whole THP when an address
> >> in the middle of a THP is accessed.
> >> 
> >> > You gave number about how scale bad current swapout so try to enhance
> >> > that path. I agree it alghouth I don't like your approach for first step.
> >> > However, you didn't give any clue why we should swap in a THP. How bad
> >> > current conservative swapin from khugepagd is really bad and why cannot
> >> > enhance that.
> >> >
> >> >> support without splitting THP?  If so, this patchset is the just the
> >> >> first step of that.  I plan to finish the the full THP swap out/in
> >> >> support in 3 steps:
> >> >> 
> >> >> 1. Delay splitting the THP after adding it into swap cache
> >> >> 
> >> >> 2. Delay splitting the THP after swapping out being completed
> >> >> 
> >> >> 3. Avoid splitting the THP during swap out, and swap in the full THP if
> >> >>    possible
> >> >> 
> >> >> I plan to do it step by step to make it easier to review the code.
> >> >
> >> > 1. If we solve batching swapout, then how is THP split for swapout bad?
> >> > 2. Also, how is current conservatie swapin from khugepaged bad?
> >> >
> >> > I think it's one of decision point for the motivation of your work
> >> > and for 1, we need batching swapout feature.
> >> >
> >> > I am saying again that I'm not against your goal but only concern
> >> > is approach. If you don't agree, please ignore me.
> >> 
> >> I am glad to discuss my final goal, that is, swapping out/in the full
> >> THP without splitting.  Why I want to do that is copied as below,
> >
> > Yes, it's your *final* goal but what if it couldn't be acceptable
> > on second step you mentioned above, for example?
> >
> >         Unncessary binded implementation to rejected work.
> 
> So I want to discuss my final goal.  If people accept my final goal,
> this is resolved.  If people don't accept, I will reconsider it.

No.

Please keep it in mind. There are lots of factors the project would
be broken during going on by several reasons because we are human being
so we can simply miss something clear and realize it later that it's
not feasible. Otherwise, others can show up with better idea for the
goal or fix other subsystem which can affect your goals.
I don't want to say such boring theoretical stuffs any more.

My point is patchset should be self-contained if you really want to go
with step-by-step approach because we are likely to miss something
*easily*.

> 
> > If you want to achieve your goal step by step, please consider if
> > one of step you are thinking could be rejected but steps already
> > merged should be self-contained without side-effect.
> 
> What is the side-effect or possible regressions of the step 1 as in this

Adding code complexity for unproved feature.

When I read your steps, your *most important* goal is to avoid split/
collapsing anon THP page for swap out/in. As a bonus with the approach,
we could increase swapout/in bandwidth, too. Do I understand correctly?

However, swap-in/out bandwidth enhance is common requirement for both
normal and THP page and with Tim's work, we could enhance swapout path.

So, I think you should give us to number about how THP split is bad
for the swapout bandwidth even though we applied Tim's work.
If it's serious, next approach is yours that we could tweak swap code
be aware of a THP to avoid splitting a THP.

For THP swap-in, I think it's another topic we should discuss.
For each step, it's orthogonal work so it shouldn't rely on next goal.


> patchset?  Lacks the opportunity to allocate consecutive 512 swap slots
> in 2 non-free swap clusters?  I don't think that is a regression,
> because the patchset will NOT make free swap clusters consumed faster
> than that in current code.  Even if it were better to allocate
> consecutive 512 swap slots in 2 non-free swap clusters, it could be an
> incremental improvement to the simple solution in this patchset.  That
> is, to allocate 512 swap slots, the simple solution is:
> 
> a) Try to allocate a free swap cluster
> b) If a) fails, give up
> 
> The improved solution could be (if it were needed finally)
> 
> a) Try to allocate a free swap cluster
> b) If a) fails, try to allocate consecutive 512 swap slots in 2 non-free
>    swap clusters
> c) If b) fails, give up

I didn't mean it. Please read above.

> 
> > If it's hard, send full patchset all at once so reviewers can think
> > what you want of right direction and implementation is good for it.
> 
> Thanks for suggestion.

Huang,

I'm sorry if I misunderstand something. And I should admit I'm not a THP
user even so I'm blind on a THP workload so sorry too if I miss really
something clear. However, my concern is adding more complexity to swap
layer without justfication and to me, it's really hard to understand your
motivation from your description.

If you want step by step approach, for the first step, please prove
how THP split is bad in swapout path and it would be better to consider
how to make codes shareable with normal pages batching so THP awareness
on top of normal page batching, it would be more easy to prove/review,
I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
