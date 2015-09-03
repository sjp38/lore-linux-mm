Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 252A86B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 02:09:25 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so46519523ioi.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 23:09:24 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id m185si4603064iom.21.2015.09.02.23.09.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 23:09:24 -0700 (PDT)
Received: by igcpb10 with SMTP id pb10so6966893igc.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 23:09:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150902215512.9d0d62e74fa2f0a460a42af9@linux-foundation.org>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903023125.GC27804@redhat.com>
	<alpine.DEB.2.11.1509022152470.18064@east.gentwo.org>
	<20150902215512.9d0d62e74fa2f0a460a42af9@linux-foundation.org>
Date: Thu, 3 Sep 2015 09:09:24 +0300
Message-ID: <CAOJsxLGa9fLWUrdjnm-A-Frxr1bzBvfNZRsmFFcjQSvGX48a4w@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Mike Snitzer <snitzer@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Heinz Mauelshagen <heinzm@redhat.com>, Viresh Kumar <viresh.kumar@linaro.org>, Dave Chinner <dchinner@redhat.com>, Joe Thornber <ejt@redhat.com>, linux-mm <linux-mm@kvack.org>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alasdair G Kergon <agk@redhat.com>

Hi Andrew,

On Wed, 2 Sep 2015 22:10:12 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
>> > But I'd still like some pointers/help on what makes slab merging so
>> > beneficial.  I'm sure Christoph and others have justification.  But if
>> > not then yes the default to slab merging probably should be revisited.
>>
>> ...
>>
>> Check out the linux-mm archives for these dissussions.

On Thu, Sep 3, 2015 at 7:55 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> Somewhat OT, but...  The question Mike asks should be comprehensively
> answered right there in the switch-to-merging patch's changelog.
>
> The fact that it is not answered in the appropriate place and that
> we're reduced to vaguely waving at the list archives is a fail.  And a
> lesson!

Slab merging is a technique to reduce memory footprint and memory
fragmentation. Joonsoo reports 3% slab memory reduction after boot
when he added the feature to SLAB:

commit 12220dea07f1ac6ac717707104773d771c3f3077
Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Date:   Thu Oct 9 15:26:24 2014 -0700

    mm/slab: support slab merge

    Slab merge is good feature to reduce fragmentation.  If new creating slab
    have similar size and property with exsitent slab, this feature reuse it
    rather than creating new one.  As a result, objects are packed into fewer
    slabs so that fragmentation is reduced.

    Below is result of my testing.

    * After boot, sleep 20; cat /proc/meminfo | grep Slab

    <Before>
    Slab: 25136 kB

    <After>
    Slab: 24364 kB

    We can save 3% memory used by slab.

    For supporting this feature in SLAB, we need to implement SLAB specific
    kmem_cache_flag() and __kmem_cache_alias(), because SLUB implements some
    SLUB specific processing related to debug flag and object size change on
    these functions.

    Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

We don't have benchmarks to directly measure its performance impact
but you should see its effect via something like netperf that stresses
the allocator heavily. The assumed benefit is that you're able to
recycle cache hot objects much more efficiently as SKB cache and
friends are merged to regular kmalloc caches.

In any case, reducing kernel memory footprint already is a big win for
various use cases, so keeping slab merging on by default is desirable.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
