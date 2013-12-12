Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6336B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 00:38:08 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so6183215qeb.25
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 21:38:08 -0800 (PST)
Received: from mail-ve0-x22a.google.com (mail-ve0-x22a.google.com [2607:f8b0:400c:c01::22a])
        by mx.google.com with ESMTPS id w9si6592268qad.60.2013.12.11.21.38.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 21:38:07 -0800 (PST)
Received: by mail-ve0-f170.google.com with SMTP id oy12so6776932veb.15
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 21:38:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131211124240.GA24557@htj.dyndns.org>
References: <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
 <20131204054533.GZ3556@cmpxchg.org> <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
 <20131205025026.GA26777@htj.dyndns.org> <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
 <20131206190105.GE13373@htj.dyndns.org> <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com>
 <20131210215037.GB9143@htj.dyndns.org> <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
 <20131211124240.GA24557@htj.dyndns.org>
From: Tim Hockin <thockin@hockin.org>
Date: Wed, 11 Dec 2013 21:37:46 -0800
Message-ID: <CAAAKZwsmM-C=kLGV=RW=Y4Mq=BWpQzuPruW6zvEr9p0Xs4GD5g@mail.gmail.com>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom notifications
 to access reserves
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>

The immediate problem I see with setting aside reserves "off the top"
is that we don't really know a priori how much memory the kernel
itself is going to use, which could still land us in an overcommitted
state.

In other words, if I have your 128 MB machine, and I set aside 8 MB
for OOM handling, and give 120 MB for jobs, I have not accounted for
the kernel.  So I set aside 8 MB for OOM and 100 MB for jobs, leaving
20 MB for jobs.  That should be enough right?  Hell if I know, and
nothing ensures that.

On Wed, Dec 11, 2013 at 4:42 AM, Tejun Heo <tj@kernel.org> wrote:
> Yo,
>
> On Tue, Dec 10, 2013 at 03:55:48PM -0800, David Rientjes wrote:
>> > Well, the gotcha there is that you won't be able to do that with
>> > system level OOM handler either unless you create a separately
>> > reserved memory, which, again, can be achieved using hierarchical
>> > memcg setup already.  Am I missing something here?
>>
>> System oom conditions would only arise when the usage of memcgs A + B
>> above cause the page allocator to not be able to allocate memory without
>> oom killing something even though the limits of both A and B may not have
>> been reached yet.  No userspace oom handler can allocate memory with
>> access to memory reserves in the page allocator in such a context; it's
>> vital that if we are to handle system oom conditions in userspace that we
>> given them access to memory that other processes can't allocate.  You
>> could attach a userspace system oom handler to any memcg in this scenario
>> with memory.oom_reserve_in_bytes and since it has PF_OOM_HANDLER it would
>> be able to allocate in reserves in the page allocator and overcharge in
>> its memcg to handle it.  This isn't possible only with a hierarchical
>> memcg setup unless you ensure the sum of the limits of the top level
>> memcgs do not equal or exceed the sum of the min watermarks of all memory
>> zones, and we exceed that.
>
> Yes, exactly.  If system memory is 128M, create top level memcgs w/
> 120M and 8M each (well, with some slack of course) and then overcommit
> the descendants of 120M while putting OOM handlers and friends under
> 8M without overcommitting.
>
> ...
>> The stronger rationale is that you can't handle system oom in userspace
>> without this functionality and we need to do so.
>
> You're giving yourself an unreasonable precondition - overcommitting
> at root level and handling system OOM from userland - and then trying
> to contort everything to fit that.  How can possibly "overcommitting
> at root level" be a goal of and in itself?  Please take a step back
> and look at and explain the *problem* you're trying to solve.  You
> haven't explained why that *need*s to be the case at all.
>
> I wrote this at the start of the thread but you're still doing the
> same thing.  You're trying to create a hidden memcg level inside a
> memcg.  At the beginning of this thread, you were trying to do that
> for !root memcgs and now you're arguing that you *need* that for root
> memcg.  Because there's no other limit we can make use of, you're
> suggesting the use of kernel reserve memory for that purpose.  It
> seems like an absurd thing to do to me.  It could be that you might
> not be able to achieve exactly the same thing that way, but the right
> thing to do would be improving memcg in general so that it can instead
> of adding yet more layer of half-baked complexity, right?
>
> Even if there are some inherent advantages of system userland OOM
> handling with a separate physical memory reserve, which AFAICS you
> haven't succeeded at showing yet, this is a very invasive change and,
> as you said before, something with an *extremely* narrow use case.
> Wouldn't it be a better idea to improve the existing mechanisms - be
> that memcg in general or kernel OOM handling - to fit the niche use
> case better?  I mean, just think about all the corner cases.  How are
> you gonna handle priority inversion through locked pages or
> allocations given out to other tasks through slab?  You're suggesting
> opening a giant can of worms for extremely narrow benefit which
> doesn't even seem like actually needing opening the said can.
>
> Thanks.
>
> --
> tejun
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
