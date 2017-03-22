Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A37A6B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 00:41:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q126so386314556pga.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 21:41:21 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k65si212952pfj.246.2017.03.21.21.41.19
        for <linux-mm@kvack.org>;
        Tue, 21 Mar 2017 21:41:20 -0700 (PDT)
Date: Wed, 22 Mar 2017 13:41:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Message-ID: <20170322044117.GD30149@bbox>
References: <20170317231636.142311-1-timmurray@google.com>
 <20170320055930.GA30167@bbox>
 <CAEe=SxnYXGg+s15imF4D93DVzvhVT+yo5fvAvDtKrQKdXz2kyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEe=SxnYXGg+s15imF4D93DVzvhVT+yo5fvAvDtKrQKdXz2kyA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Murray <timmurray@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Suren Baghdasaryan <surenb@google.com>, Patrik Torstensson <totte@google.com>, Android Kernel Team <kernel-team@android.com>, vinmenon@codeaurora.org

Hi Tim,

On Tue, Mar 21, 2017 at 10:18:26AM -0700, Tim Murray wrote:
> On Sun, Mar 19, 2017 at 10:59 PM, Minchan Kim <minchan@kernel.org> wrote:
> > However, I'm not sure your approach is good. It seems your approach just
> > reclaims pages from groups (DEF_PRIORITY - memcg->priority) >= sc->priority.
> > IOW, it is based on *temporal* memory pressure fluctuation sc->priority.
> >
> > Rather than it, I guess pages to be reclaimed should be distributed by
> > memcg->priority. Namely, if global memory pressure happens and VM want to
> > reclaim 100 pages, VM should reclaim 90 pages from memcg-A(priority-10)
> > and 10 pages from memcg-B(prioirty-90).
> 
> This is what I debated most while writing this patch. If I'm
> understanding your concern correctly, I think I'm doing more than
> skipping high-priority cgroups:

Yes, that is my concern. It could give too much pressure lower-priority
group. You already reduced scanning window for high-priority group so
I guess it would be enough for working.

The rationale from my thining is high-priority group can have cold pages(
for instance, used-once pages, madvise_free pages and so on) so, VM should
age every groups to reclaim cold pages but we can reduce scanning window
for high-priority group to keep more workingset as you did. By that, we
already give more pressure to lower priority group than high-prioirty group.

> 
> - If the scan isn't high priority yet, then skip high-priority cgroups.

This part is the one I think it's too much ;-)
I think no need to skip but just reduce scanning window by the group's
prioirty.

> - When the scan is high priority, scan fewer pages from
> higher-priority cgroups (using the priority to modify the shift in
> get_scan_count).

That sounds lkie a good idea but need to tune more.

How about this?

get_scan_count for memcg-A:
        ..
        size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx) *
                        (memcg-A / sum(memcg all priorities))

get_scan_count for memcg-B:
        ..
        size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx) *
                        (memcg-B / sum(memcg all priorities))

By that, can't it support memcg-hierarchy as well? I don't know. ;(
Hope memcg guys give more thought.

> 
> This is tightly coupled with the question of what to do with
> vmpressure. The right thing to do on an Android device under memory
> pressure is probably something like this:
> 
> 1. Reclaim aggressively from low-priority background processes. The
> goal here is to reduce the pages used by background processes to the
> size of their heaps (or smaller with ZRAM) but zero file pages.
> They're already likely to be killed by userspace and we're keeping
> them around opportunistically, so a performance hit if they run and
> have to do IO to restore some of that working set is okay.
> 2. Reclaim a small amount from persistent processes. These often have
> a performance-critical subset of pages that we absolutely don't want
> paged out, but some reclaim of these processes is fine. They're large,
> some of them only run sporadically and don't impact performance, it's
> okay to touch these sometimes.

That's why I wanted to age LRU from all of memcg but slow for high-priority
group via reduing scanning window, which means high-priority group's
pages makes more chance to be activated. So, it's already prioirty-boost.

> 3. If there still aren't enough free pages, notify userspace to kill
> any processes it can. If I put my "Android performance engineer
> working on userspace" hat on, what I'd want to know from userspace is
> that kswapd/direct reclaim probably has to scan foreground processes
> in order to reclaim enough free pages to satisfy watermarks. That's a
> signal I could directly act on from userspace.

Hmm, could you tell us how many of memcg groups do you thinking now?

background, foreground? Just two?

The reason I ask is if you want to make foregroud/background memcg
and move apps between them back and forth when the status changed,
we need to remember lru pages are not moved from originated memcg
so it wouldn't work as expected.


> 4. If that still isn't enough, reclaim from foreground processes,
> since those processes are performance-critical.
> 
> As a result, I like not being fair about which cgroups are scanned
> initially. Some cgroups are strictly more important than others. (With

Yeb, *initially* is arguable point. I hope only reducing scanning
window would work. However, just my two cent. If it have a problem,
yes, need more thing.


> that said, I'm not tied to enforcing unfairness in scanning. Android
> would probably use different priority levels for each app level for
> fair scanning vs unfair scanning, but my guess is that the actual
> reclaiming behavior would look similar in both schemes.)
> 
> Mem cgroup priority suggests a useful signal for vmpressure. If
> scanning is starting to touch cgroups at a higher priority than
> persistent processes, then the userspace lowmemorykiller could kill
> one or more background processes (which would be in low-priority
> cgroups that have already been scanned aggressively). The current lmk
> hand-tuned watermarks would be gone, and tuning the /proc/sys/vm knobs
> would be all that's required to make an Android device do the right
> thing in terms of memory.

Yes, it's better way. I think.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
