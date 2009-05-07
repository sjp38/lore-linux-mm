Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E9CF46B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 08:01:30 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so369770ywm.26
        for <linux-mm@kvack.org>; Thu, 07 May 2009 05:01:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090507104635.GG16078@random.random>
References: <4A00DD4F.8010101@redhat.com> <4A0181EA.3070600@redhat.com>
	 <20090506131735.GW16078@random.random>
	 <Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
	 <20090506140904.GY16078@random.random>
	 <20090506152100.41266e4c@lxorguk.ukuu.org.uk>
	 <Pine.LNX.4.64.0905061532240.25289@blonde.anvils>
	 <20090506145641.GA16078@random.random>
	 <20090507085547.24efb60f.minchan.kim@barrios-desktop>
	 <20090507104635.GG16078@random.random>
Date: Thu, 7 May 2009 21:01:30 +0900
Message-ID: <44c63dc40905070501j1a468e16yde46403da19460e6@mail.gmail.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses
	registrations.
From: Minchan Kim <barrioskmc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hugh@veritas.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

>> Many embedded system is so I/O bouneded that we can use much CPU time in there.
>
> Embedded systems with >4G of ram should run 64bit these days, so I
> don't see a problem.

What I mean is that many embedded applications don't use so much cpu
time that we can use extra cpu time to scan identical pages for KSM.
:)

>> One more thing about interface.
>>
>> Ksm map regions are dynamic characteritic ?
>> I mean sometime A application calls ioctl(0x800000, 0x10000) and sometime it calls ioctl(0xb7000000, 0x20000);
>> Of course, It depends on application's behavior.
>
> Looks like the ioctl API is going away in favour of madvise so it'll
> function like madvise, if you munmap the region the KSM registration
> will go away.
>
>> ex) echo 'pid 0x8050000 0x100000' > sysfs or procfs or cgroup.
>
> This was answered by Chris, and surely this is feasible, as it is
> feasible for kksmd to scan the whole system regardless of any
> madvise. Some sysfs mangling should allow it.
>
> However regardless of the highmem issue (this applies to 64bit systems
> too) you've to keep in mind that for kksmd to keep track all pages
> under scan it has to build rbtree and allocate rmap_items and
> tree_items for each page tracked, those objects take some memory, so
> if there's not much ram sharing you may waste more memory in the kksmd
> allocations than in the amount of memory actually freed by KSM. This
> is why it's better to selectively only register ranges that we know in
> advance there's an high probability to free memory.

Indeed.

This interface can use for just simple test and profiling.
If it don't add memory pressure and latency, we can use it without
modifying source code.
Unfortunately, it's not in usual case. ;-)

So if KSM can provide profiling information, we can tune easily than now.

ex)
pfn : 0x12, shared [pid 103, vaddr 0x80010000] [pid 201, vaddr 0x800ac000] .....
pfn : 0x301, shared [pid 103, vaddr 0x80020000] [pid 203, vaddr
0x801ac000] .....
...
...

If KSM can provide this profiling information, firstly we try to use
ksm without madive and next we can add madvise call on most like
sharable vma range using profiling data.

> Thanks!
> Andrea
>



-- 
Thanks,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
