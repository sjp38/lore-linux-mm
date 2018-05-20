Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBDA86B06E2
	for <linux-mm@kvack.org>; Sun, 20 May 2018 02:26:07 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id f19-v6so3285075qkm.23
        for <linux-mm@kvack.org>; Sat, 19 May 2018 23:26:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j25-v6sor8085902qtn.24.2018.05.19.23.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 May 2018 23:26:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <714E0B73-BE6C-408B-98A6-2A7C82E7BB11@oracle.com>
References: <5BB682E1-DD52-4AA9-83E9-DEF091E0C709@oracle.com>
 <20180517152333.GA26718@bombadil.infradead.org> <714E0B73-BE6C-408B-98A6-2A7C82E7BB11@oracle.com>
From: Song Liu <liu.song.a23@gmail.com>
Date: Sat, 19 May 2018 23:26:06 -0700
Message-ID: <CAPhsuW5mJYXwExScmRTMuh=dCQ-bufBsisTEmvWJBVbtP8ziyg@mail.gmail.com>
Subject: Re: [RFC] mm, THP: Map read-only text segments using large THP pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, May 17, 2018 at 10:31 AM, William Kucharski
<william.kucharski@oracle.com> wrote:
>
>
>> On May 17, 2018, at 9:23 AM, Matthew Wilcox <willy@infradead.org> wrote:
>>
>> I'm certain it is.  The other thing I believe is true that we should be
>> able to share page tables (my motivation is thousands of processes each
>> mapping the same ridiculously-sized file).  I was hoping this prototype
>> would have code that would be stealable for that purpose, but you've
>> gone in a different direction.  Which is fine for a prototype; you've
>> produced useful numbers.
>
> Definitely, and that's why I mentioned integration with the page cache
> would be crucial. This prototype allocates pages for each invocation of
> the executable, which would never fly on a real system.
>
>> I think the first step is to get variable sized pages in the page cache
>> working.  Then the map-around functionality can probably just notice if
>> they're big enough to map with a PMD and make that happen.  I don't immediately
>> see anything from this PoC that can be used, but it at least gives us a
>> good point of comparison for any future work.
>
> Yes, that's the first step to getting actual usable code designed and
> working; this prototype was designed just to get something working and
> to get a first swag at some performance numbers.
>
> I do think that adding code to map larger pages as a fault_around variant
> is a good start as the code is already going to potentially map in
> fault_around_bytes from the file to satisfy the fault. It makes sense
> to extend that paradigm to be able to tune when large pages might be
> read in and/or mapped using large pages extant in the page cache.
>
> Filesystem support becomes more important once writing to large pages
> is allowed.
>
>> I think that really tells the story.  We almost entirely eliminate
>> dTLB load misses (down to almost 0.1%) and iTLB load misses drop to 4%
>> of what they were.  Does this test represent any kind of real world load,
>> or is it designed to show the best possible improvement?
>
> It's admittedly designed to thrash the caches pretty hard and doesn't
> represent any type of actual workload I'm aware of. It basically calls
> various routines within a huge text area while scribbling to automatic
> arrays declared at the top of each routine. It wasn't designed as a worst
> case scenario, but rather as one that would hopefully show some obvious
> degree of difference when large text pages were supported.
>
> Thanks for your comments.
>
>     -- Bill

We (Facebook) have quite a few real workloads that take advantage of
text on huge
pages. For some of them, we can see savings close to the number above.

Currently, we "hugify" the text region through some hack in user
space. We are very
interested in supporting it natively in the kernel, because the hack
breaks other
features.

We also tested enabling text on huge pages through shmem, and it does work. The
downside is that it requires putting the whole file in memory (or at
least in swap).
This doesn't work very well for large binaries with GBs of debugging data.

Song
