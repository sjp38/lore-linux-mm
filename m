Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B782F6B0006
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 18:57:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v4-v6so8852057oix.2
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 15:57:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l126-v6sor9473297oib.35.2018.07.25.15.57.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 15:57:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180717122327.GG7193@dhcp22.suse.cz>
References: <20180712172942.10094-1-hannes@cmpxchg.org> <20180716155745.10368-1-drake@endlessm.com>
 <20180717112515.GE7193@dhcp22.suse.cz> <CAD8Lp45W00ga-P-nb6iytgSGW4xwSzmaTHA87DOvSotN0S2edw@mail.gmail.com>
 <20180717122327.GG7193@dhcp22.suse.cz>
From: Daniel Drake <drake@endlessm.com>
Date: Wed, 25 Jul 2018 17:57:26 -0500
Message-ID: <CAD8Lp44P2X5BNj14QjJBiv-_MxdVTP2UPQk3pX5iX4NEL46zwA@mail.gmail.com>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory, and
 IO v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Upstreaming Team <linux@endlessm.com>, linux-block@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Tue, Jul 17, 2018 at 7:23 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 17-07-18 07:13:52, Daniel Drake wrote:
>> On Tue, Jul 17, 2018 at 6:25 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > Yes this is really unfortunate. One thing that could help would be to
>> > consider a trashing level during the reclaim (get_scan_count) to simply
>> > forget about LRUs which are constantly refaulting pages back. We already
>> > have the infrastructure for that. We just need to plumb it in.
>>
>> Can you go into a bit more detail about that infrastructure and how we
>> might detect which pages are being constantly refaulted? I'm
>> interested in spending a few hours on this topic to see if I can come
>> up with anything.
>
> mm/workingset.c allows for tracking when an actual page got evicted.
> workingset_refault tells us whether a give filemap fault is a recent
> refault and activates the page if that is the case. So what you need is
> to note how many refaulted pages we have on the active LRU list. If that
> is a large part of the list and if the inactive list is really small
> then we know we are trashing.

Thanks for the guidance. So this sounds like it is something that
should be done on a timer (or on some other condition?), check the
state of the active LRU list as described and if things are bad then
invoke the OOM killer?

I'm having trouble linking that idea to your original suggestion:

> One thing that could help would be to consider a trashing level during the reclaim
> (get_scan_count) to simply forget about LRUs which are constantly refaulting
> pages back.

which I interpret to mean that the  for_each_evictable_lru loop in
get_scan_count should skip over constantly-refaulty LRUs rather than
add them to nr[] and lru_pages, which I assume would then cause direct
reclaim to fail when we are thrashing, leading to OOM kill?

Are these two different ideas, or am I just misunderstanding something basic?

That confusion aside, studying the code to understand how I can
determine if a page is being constantly refaulted or not, I see that
the well documented condition for this (in workingset_refault) is:

  (refault - eviction) & EVICTION_MASK <= active_file

refault and active_file are just values from the lruvec which seems
easily accessible. However the eviction value is taken at the point of
page eviction, and it is then stored in the shadow entries stored in
the page cache for pages that have been evicted, but the shadow entry
is then lost when the page is reactivated.

The suggestion(s) seem to revolve around checking if currently-active
pages are refaulting a lot, and I am still not clear on how to
determine that, given that the shadow/eviction information was lost at
the point when those active pages were refaulted.


BTW feel free to drop this thread if you are busy, or delay your
response to a convenient time. I'm new to this area and probably
making silly mistakes, and not yet convinced that I'll be able to see
it through.

Daniel
