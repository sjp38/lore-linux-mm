Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 363E26B026B
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 20:05:27 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e93-v6so2308526plb.5
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:05:27 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 7-v6si2480897pgf.687.2018.07.26.17.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 17:05:25 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v2] RFC: clear 1G pages with streaming stores on x86
References: <20180724210923.GA20168@bombadil.infradead.org>
	<20180725023728.44630-1-cannonmatthews@google.com>
	<20180725125741.GL28386@dhcp22.suse.cz>
	<CAJfu=UcVygNivApyumjTBn897yZmU=VD3WGuPioRDDrkej1XKw@mail.gmail.com>
Date: Fri, 27 Jul 2018 08:05:21 +0800
In-Reply-To: <CAJfu=UcVygNivApyumjTBn897yZmU=VD3WGuPioRDDrkej1XKw@mail.gmail.com>
	(Cannon Matthews's message of "Wed, 25 Jul 2018 10:55:40 -0700")
Message-ID: <87bmat7dby.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, akpm@linux-foundation.org, willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>

Hi, Cannon,

Cannon Matthews <cannonmatthews@google.com> writes:

> On Wed, Jul 25, 2018 at 5:57 AM Michal Hocko <mhocko@kernel.org> wrote:
>>
>> [Cc Huang]
>> On Tue 24-07-18 19:37:28, Cannon Matthews wrote:
>> > Reimplement clear_gigantic_page() to clear gigabytes pages using the
>> > non-temporal streaming store instructions that bypass the cache
>> > (movnti), since an entire 1GiB region will not fit in the cache anyway.
>> >
>> > Doing an mlock() on a 512GiB 1G-hugetlb region previously would take on
>> > average 134 seconds, about 260ms/GiB which is quite slow. Using `movnti`
>> > and optimizing the control flow over the constituent small pages, this
>> > can be improved roughly by a factor of 3-4x, with the 512GiB mlock()
>> > taking only 34 seconds on average, or 67ms/GiB.

I am impressed with the improvement number!  Thanks!

>> > The assembly code for the __clear_page_nt routine is more or less
>> > taken directly from the output of gcc with -O3 for this function with
>> > some tweaks to support arbitrary sizes and moving memory barriers:
>> >
>> > void clear_page_nt_64i (void *page)
>> > {
>> >   for (int i = 0; i < GiB /sizeof(long long int); ++i)
>> >     {
>> >       _mm_stream_si64 (((long long int*)page) + i, 0);
>> >     }
>> >   sfence();
>> > }
>> >
>> > In general I would love to hear any thoughts and feedback on this
>> > approach and any ways it could be improved.
>>
>> Well, I like it. In fact 2MB pages are in a similar situation even
>> though they fit into the cache so the problem is not that pressing.
>> Anyway if you are a standard DB wokrload which simply preallocates large
>> hugetlb shared files then it would help. Huang has gone a different
>> direction c79b57e462b5 ("mm: hugetlb: clear target sub-page last when
>> clearing huge page") and I was asking about using the mechanism you are
>> proposing back then http://lkml.kernel.org/r/20170821115235.GD25956@dhcp22.suse.cz
>> I've got an explanation http://lkml.kernel.org/r/87h8x0whfs.fsf@yhuang-dev.intel.com
>> which hasn't really satisfied me but I didn't really want to block the
>> obvious optimization. The similar approach has been proposed for GB
>> pages IIRC but I do not see it in linux-next so I am not sure what
>> happened with it.
>>
>> Is there any reason to use a different scheme for GB an 2MB pages? Why
>> don't we settle with movnti for both? The first access will be a miss
>> but I am not really sure it matters all that much.
>>
> My only hesitation is that while the benefits of doing it faster seem
> obvious at a
> 1GiB granularity, things become more subtle at 2M, and they are used much
> more frequently, where negative impacts from this approach could outweigh.
>
> Not that that is actually the case, but I am not familiar enough to be
> confident
> proposing that, especially when it gets into the stuff in that
> response you liked
> about synchronous RAM loads and such.
>
> With the right benchmarking we could
> certainly motivate it one way or the other, but I wouldn't know where
> to begin to
> do so in a robust enough way.
>
> For the first access being a miss, there is the suggestion that Robert
> Elliot had
> above of doing a normal caching store on the sub-page that contains the faulting
> address, as an optimization to avoid that. Perhaps that would be enough.

Yes.  We should consider caching too.  It shouldn't be an issue for 1G
huge page because it cannot fit in cache.  But that is important for 2M
huge page.  I think we should try Robert's idea.  Measure the difference
between no-cache, cache target sub-page, full cache cases.  With
per-thread cache size <2M and >2M.

>> Keeping the rest of the email for reference
>>
>> > Some specific questions:
>> >
>> > - What is the appropriate method for defining an arch specific
>> > implementation like this, is the #ifndef code sufficient, and did stuff
>> > land in appropriate files?
>> >
>> > - Are there any obvious pitfalls or caveats that have not been
>> > considered? In particular the iterator over mem_map_next() seemed like a
>> > no-op on x86, but looked like it could be important in certain
>> > configurations or architectures I am not familiar with.
>> >
>> > - Is there anything that could be improved about the assembly code? I
>> > originally wrote it in C and don't have much experience hand writing x86
>> > asm, which seems riddled with optimization pitfalls.
>> >
>> > - Is the highmem codepath really necessary? would 1GiB pages really be
>> > of much use on a highmem system? We recently removed some other parts of
>> > the code that support HIGHMEM for gigantic pages (see:
>> > http://lkml.kernel.org/r/20180711195913.1294-1-mike.kravetz@oracle.com)
>> > so this seems like a logical continuation.
>> >
>> > - The calls to cond_resched() have been reduced from between every 4k
>> > page to every 64, as between all of the 256K page seemed overly
>> > frequent.  Does this seem like an appropriate frequency? On an idle
>> > system with many spare CPUs it get's rescheduled typically once or twice
>> > out of the 4096 times it calls cond_resched(), which seems like it is
>> > maybe the right amount, but more insight from a scheduling/latency point
>> > of view would be helpful. See the "Tested:" section below for some more data.
>> >
>> > - Any other thoughts on the change overall and ways that this could
>> > be made more generally useful, and designed to be easily extensible to
>> > other platforms with non-temporal instructions and 1G pages, or any
>> > additional pitfalls I have not thought to consider.
>> >
>> > Tested:
>> >       Time to `mlock()` a 512GiB region on broadwell CPU
>> >                               AVG time (s)    % imp.  ms/page
>> >       clear_page_erms         133.584         -       261
>> >       clear_page_nt           34.154          74.43%  67
>> >
>> > For a more in depth look at how the frequency we call cond_resched() affects
>> > the time this takes, I tested both on an idle system, and a system running
>> > `stress -c N` program to overcommit CPU to ~115%, and ran 10 replications of
>> > the 512GiB mlock test.
>> >
>> > Unfortunately there wasn't as clear of a pattern as I had hoped. On an
>> > otherwise idle system there is no substantive difference different values of
>> > PAGES_BETWEEN_RESCHED.
>> >
>> > On a stressed system, there appears to be a pattern, that resembles something
>> > of a bell curve: constantly offering to yield, or never yielding until the end
>> > produces the fastest results, but yielding infrequently increases latency to a
>> > slight degree.
>> >
>> > That being said, it's not clear this is actually a significant difference, the
>> > std deviation is occasionally quite high, and perhaps a larger sample set would
>> > be more informative. From looking at the log messages indicating the number of
>> > times cond_resched() returned 1, there wasn't that much variance, with it
>> > usually being 1 or 2 when idle, and only increasing to ~4-7 when stressed.
>> >
>> >
>> >       PAGES_BETWEEN_RESCHED   state   AVG     stddev
>> >       1       4 KiB           idle    36.086  1.920
>> >       16      64 KiB          idle    34.797  1.702
>> >       32      128 KiB         idle    35.104  1.752
>> >       64      256 KiB         idle    34.468  0.661
>> >       512     2048 KiB        idle    36.427  0.946
>> >       2048    8192 KiB        idle    34.988  2.406
>> >       262144  1048576 KiB     idle    36.792  0.193
>> >       infin   512 GiB         idle    38.817  0.238  [causes softlockup]
>> >       1       4 KiB           stress  55.562  0.661
>> >       16      64 KiB          stress  57.509  0.248
>> >       32      128 KiB         stress  69.265  3.913
>> >       64      256 KiB         stress  70.217  4.534
>> >       512     2048 KiB        stress  68.474  1.708
>> >       2048    8192 KiB        stress  70.806  1.068
>> >       262144  1048576 KiB     stress  55.217  1.184
>> >       infin   512 GiB         stress  55.062  0.291  [causes softlockup]

I think it may be good to separate the two optimization into 2 patches.
This makes it easier to evaluate the benefit of individual optimization.

Best Regards,
Huang, Ying
