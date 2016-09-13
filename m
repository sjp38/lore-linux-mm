Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2974B6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 04:53:55 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ex14so242934540pac.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 01:53:55 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s127si26579518pfb.4.2016.09.13.01.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 01:53:54 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping out
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<20160909054336.GA2114@bbox>
	<87sht824n3.fsf@yhuang-mobile.sh.intel.com>
	<20160913061349.GA4445@bbox> <87y42wgv5r.fsf@yhuang-dev.intel.com>
	<20160913070524.GA4973@bbox>
Date: Tue, 13 Sep 2016 16:53:49 +0800
In-Reply-To: <20160913070524.GA4973@bbox> (Minchan Kim's message of "Tue, 13
	Sep 2016 16:05:24 +0900")
Message-ID: <87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Minchan Kim <minchan@kernel.org> writes:
> On Tue, Sep 13, 2016 at 02:40:00PM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > Hi Huang,
>> >
>> > On Fri, Sep 09, 2016 at 01:35:12PM -0700, Huang, Ying wrote:
>> >
>> > < snip >
>> >
>> >> >> Recently, the performance of the storage devices improved so fast that
>> >> >> we cannot saturate the disk bandwidth when do page swap out even on a
>> >> >> high-end server machine.  Because the performance of the storage
>> >> >> device improved faster than that of CPU.  And it seems that the trend
>> >> >> will not change in the near future.  On the other hand, the THP
>> >> >> becomes more and more popular because of increased memory size.  So it
>> >> >> becomes necessary to optimize THP swap performance.
>> >> >> 
>> >> >> The advantages of the THP swap support include:
>> >> >> 
>> >> >> - Batch the swap operations for the THP to reduce lock
>> >> >>   acquiring/releasing, including allocating/freeing the swap space,
>> >> >>   adding/deleting to/from the swap cache, and writing/reading the swap
>> >> >>   space, etc.  This will help improve the performance of the THP swap.
>> >> >> 
>> >> >> - The THP swap space read/write will be 2M sequential IO.  It is
>> >> >>   particularly helpful for the swap read, which usually are 4k random
>> >> >>   IO.  This will improve the performance of the THP swap too.
>> >> >> 
>> >> >> - It will help the memory fragmentation, especially when the THP is
>> >> >>   heavily used by the applications.  The 2M continuous pages will be
>> >> >>   free up after THP swapping out.
>> >> >
>> >> > I just read patchset right now and still doubt why the all changes
>> >> > should be coupled with THP tightly. Many parts(e.g., you introduced
>> >> > or modifying existing functions for making them THP specific) could
>> >> > just take page_list and the number of pages then would handle them
>> >> > without THP awareness.
>> >> 
>> >> I am glad if my change could help normal pages swapping too.  And we can
>> >> change these functions to work for normal pages when necessary.
>> >
>> > Sure but it would be less painful that THP awareness swapout is
>> > based on multiple normal pages swapout. For exmaple, we don't
>> > touch delay THP split part(i.e., split a THP into 512 pages like
>> > as-is) and enhances swapout further like Tim's suggestion
>> > for mulitple normal pages swapout. With that, it might be enough
>> > for fast-storage without needing THP awareness.
>> >
>> > My *point* is let's approach step by step.
>> > First of all, go with batching normal pages swapout and if it's
>> > not enough, dive into further optimization like introducing
>> > THP-aware swapout.
>> >
>> > I believe it's natural development process to evolve things
>> > without over-engineering.
>> 
>> My target is not only the THP swap out acceleration, but also the full
>> THP swap out/in support without splitting THP.  This patchset is just
>> the first step of the full THP swap support.
>> 
>> >> > For example, if the nr_pages is larger than SWAPFILE_CLUSTER, we
>> >> > can try to allocate new cluster. With that, we could allocate new
>> >> > clusters to meet nr_pages requested or bail out if we fail to allocate
>> >> > and fallback to 0-order page swapout. With that, swap layer could
>> >> > support multiple order-0 pages by batch.
>> >> >
>> >> > IMO, I really want to land Tim Chen's batching swapout work first.
>> >> > With Tim Chen's work, I expect we can make better refactoring
>> >> > for batching swap before adding more confuse to the swap layer.
>> >> > (I expect it would share several pieces of code for or would be base
>> >> > for batching allocation of swapcache, swapslot)
>> >> 
>> >> I don't think there is hard conflict between normal pages swapping
>> >> optimizing and THP swap optimizing.  Some code may be shared between
>> >> them.  That is good for both sides.
>> >> 
>> >> > After that, we could enhance swap for big contiguous batching
>> >> > like THP and finally we might make it be aware of THP specific to
>> >> > enhance further.
>> >> >
>> >> > A thing I remember you aruged: you want to swapin 512 pages
>> >> > all at once unconditionally. It's really worth to discuss if
>> >> > your design is going for the way.
>> >> > I doubt it's generally good idea. Because, currently, we try to
>> >> > swap in swapped out pages in THP page with conservative approach
>> >> > but your direction is going to opposite way.
>> >> >
>> >> > [mm, thp: convert from optimistic swapin collapsing to conservative]
>> >> >
>> >> > I think general approach(i.e., less effective than targeting
>> >> > implement for your own specific goal but less hacky and better job
>> >> > for many cases) is to rely/improve on the swap readahead.
>> >> > If most of subpages of a THP page are really workingset, swap readahead
>> >> > could work well.
>> >> >
>> >> > Yeah, it's fairly vague feedback so sorry if I miss something clear.
>> >> 
>> >> Yes.  I want to go to the direction that to swap in 512 pages together.
>> >> And I think it is a good opportunity to discuss that now.  The advantages
>> >> of swapping in 512 pages together are:
>> >> 
>> >> - Improve the performance of swapping in IO via turning small read size
>> >>   into 512 pages big read size.
>> >> 
>> >> - Keep THP across swap out/in.  With the memory size become more and
>> >>   more large, the 4k pages bring more and more burden to memory
>> >>   management.  One solution is to use 2M pages as much as possible, that
>> >>   will reduce the management burden greatly, such as much reduced length
>> >>   of LRU list, etc.
>> >> 
>> >> The disadvantage are:
>> >> 
>> >> - Increase the memory pressure when swap in THP.
>> >> 
>> >> - Some pages swapped in may not needed in the near future.
>> >> 
>> >> Because of the disadvantages, the 512 pages swapping in should be made
>> >> optional.  But I don't think we should make it impossible.
>> >
>> > Yeb. No need to make it impossible but your design shouldn't be coupled
>> > with non-existing feature yet.
>> 
>> Sorry, what is the "non-existing feature"?  The full THP swap out/in
>
> THP swapin.
>
> You said you increased cluster size to fit a THP size for recording
> some meta in there for THP swapin.

And to find the head of the THP to swap in the whole THP when an address
in the middle of a THP is accessed.

> You gave number about how scale bad current swapout so try to enhance
> that path. I agree it alghouth I don't like your approach for first step.
> However, you didn't give any clue why we should swap in a THP. How bad
> current conservative swapin from khugepagd is really bad and why cannot
> enhance that.
>
>> support without splitting THP?  If so, this patchset is the just the
>> first step of that.  I plan to finish the the full THP swap out/in
>> support in 3 steps:
>> 
>> 1. Delay splitting the THP after adding it into swap cache
>> 
>> 2. Delay splitting the THP after swapping out being completed
>> 
>> 3. Avoid splitting the THP during swap out, and swap in the full THP if
>>    possible
>> 
>> I plan to do it step by step to make it easier to review the code.
>
> 1. If we solve batching swapout, then how is THP split for swapout bad?
> 2. Also, how is current conservatie swapin from khugepaged bad?
>
> I think it's one of decision point for the motivation of your work
> and for 1, we need batching swapout feature.
>
> I am saying again that I'm not against your goal but only concern
> is approach. If you don't agree, please ignore me.

I am glad to discuss my final goal, that is, swapping out/in the full
THP without splitting.  Why I want to do that is copied as below,

>> >> The advantages of swapping in 512 pages together are:
>> >> 
>> >> - Improve the performance of swapping in IO via turning small read size
>> >>   into 512 pages big read size.
>> >> 
>> >> - Keep THP across swap out/in.  With the memory size become more and
>> >>   more large, the 4k pages bring more and more burden to memory
>> >>   management.  One solution is to use 2M pages as much as possible, that
>> >>   will reduce the management burden greatly, such as much reduced length
>> >>   of LRU list, etc.

- Avoid CPU time for splitting, collapsing THP across swap out/in.

>> >> 
>> >> The disadvantage are:
>> >> 
>> >> - Increase the memory pressure when swap in THP.
>> >> 
>> >> - Some pages swapped in may not needed in the near future.

I think it is important to use 2M pages as much as possible to deal with
the big memory problem.  Do you agree?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
