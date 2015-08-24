Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id A0CCF6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:17:52 -0400 (EDT)
Received: by laba3 with SMTP id a3so74402709lab.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:17:52 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id bf12si1041398lab.77.2015.08.24.03.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 03:17:50 -0700 (PDT)
Received: by lbbtg9 with SMTP id tg9so77075024lbb.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:17:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150821183132.GA12835@akamai.com>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
	<1439097776-27695-4-git-send-email-emunson@akamai.com>
	<20150812115909.GA5182@dhcp22.suse.cz>
	<20150819213345.GB4536@akamai.com>
	<20150820075611.GD4780@dhcp22.suse.cz>
	<20150820170309.GA11557@akamai.com>
	<20150821072552.GF23723@dhcp22.suse.cz>
	<20150821183132.GA12835@akamai.com>
Date: Mon, 24 Aug 2015 13:17:49 +0300
Message-ID: <CALYGNiPcruTM+2KKNZr7ebCVCPsqytSrW8rSzSmj+1Qp4OqXEw@mail.gmail.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On Fri, Aug 21, 2015 at 9:31 PM, Eric B Munson <emunson@akamai.com> wrote:
> On Fri, 21 Aug 2015, Michal Hocko wrote:
>
>> On Thu 20-08-15 13:03:09, Eric B Munson wrote:
>> > On Thu, 20 Aug 2015, Michal Hocko wrote:
>> >
>> > > On Wed 19-08-15 17:33:45, Eric B Munson wrote:
>> > > [...]
>> > > > The group which asked for this feature here
>> > > > wants the ability to distinguish between LOCKED and LOCKONFAULT regions
>> > > > and without the VMA flag there isn't a way to do that.
>> > >
>> > > Could you be more specific on why this is needed?
>> >
>> > They want to keep metrics on the amount of memory used in a LOCKONFAULT
>> > region versus the address space of the region.
>>
>> /proc/<pid>/smaps already exports that information AFAICS. It exports
>> VMA flags including VM_LOCKED and if rss < size then this is clearly
>> LOCKONFAULT because the standard mlock semantic is to populate. Would
>> that be sufficient?
>>
>> Now, it is true that LOCKONFAULT wouldn't be distinguishable from
>> MAP_LOCKED which failed to populate but does that really matter? It is
>> LOCKONFAULT in a way as well.
>
> Does that matter to my users?  No, they do not use MAP_LOCKED at all so
> any VMA with VM_LOCKED set and rss < size is lock on fault.  Will it
> matter to others?  I suspect so, but these are likely to be the same
> group of users which will be suprised to learn that MAP_LOCKED does not
> guarantee that the entire range is faulted in on return from mmap.
>
>>
>> > > > Do we know that these last two open flags are needed right now or is
>> > > > this speculation that they will be and that none of the other VMA flags
>> > > > can be reclaimed?
>> > >
>> > > I do not think they are needed by anybody right now but that is not a
>> > > reason why it should be used without a really strong justification.
>> > > If the discoverability is really needed then fair enough but I haven't
>> > > seen any justification for that yet.
>> >
>> > To be completely clear you believe that if the metrics collection is
>> > not a strong enough justification, it is better to expand the mm_struct
>> > by another unsigned long than to use one of these bits right?
>>
>> A simple bool is sufficient for that. And yes I think we should go with
>> per mm_struct flag rather than the additional vma flag if it has only
>> the global (whole address space) scope - which would be the case if the
>> LOCKONFAULT is always an mlock modifier and the persistance is needed
>> only for MCL_FUTURE. Which is imho a sane semantic.
>
> I am in the middle of implementing lock on fault this way, but I cannot
> see how we will hanlde mremap of a lock on fault region.  Say we have
> the following:
>
>     addr = mmap(len, MAP_ANONYMOUS, ...);
>     mlock(addr, len, MLOCK_ONFAULT);
>     ...
>     mremap(addr, len, 2 * len, ...)
>
> There is no way for mremap to know that the area being remapped was lock
> on fault so it will be locked and prefaulted by remap.  How can we avoid
> this without tracking per vma if it was locked with lock or lock on
> fault?

remap can count filled ptes and prefault only completely populated areas.

There might be a problem after failed populate: remap will handle them
as lock on fault. In this case we can fill ptes with swap-like non-present
entries to remember that fact and count them as should-be-locked pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
