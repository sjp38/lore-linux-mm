Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1F626B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 01:20:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p189so265918547pfp.5
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 22:20:18 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r21si394422pgo.226.2017.03.21.22.20.16
        for <linux-mm@kvack.org>;
        Tue, 21 Mar 2017 22:20:17 -0700 (PDT)
Date: Wed, 22 Mar 2017 14:20:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Message-ID: <20170322052013.GE30149@bbox>
References: <20170317231636.142311-1-timmurray@google.com>
 <20170320055930.GA30167@bbox>
 <CAEe=SxnYXGg+s15imF4D93DVzvhVT+yo5fvAvDtKrQKdXz2kyA@mail.gmail.com>
 <20170322044117.GD30149@bbox>
MIME-Version: 1.0
In-Reply-To: <20170322044117.GD30149@bbox>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Murray <timmurray@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Suren Baghdasaryan <surenb@google.com>, Patrik Torstensson <totte@google.com>, Android Kernel Team <kernel-team@android.com>, vinmenon@codeaurora.org

On Wed, Mar 22, 2017 at 01:41:17PM +0900, Minchan Kim wrote:
> Hi Tim,
> 
> On Tue, Mar 21, 2017 at 10:18:26AM -0700, Tim Murray wrote:
> > On Sun, Mar 19, 2017 at 10:59 PM, Minchan Kim <minchan@kernel.org> wrote:
> > > However, I'm not sure your approach is good. It seems your approach just
> > > reclaims pages from groups (DEF_PRIORITY - memcg->priority) >= sc->priority.
> > > IOW, it is based on *temporal* memory pressure fluctuation sc->priority.
> > >
> > > Rather than it, I guess pages to be reclaimed should be distributed by
> > > memcg->priority. Namely, if global memory pressure happens and VM want to
> > > reclaim 100 pages, VM should reclaim 90 pages from memcg-A(priority-10)
> > > and 10 pages from memcg-B(prioirty-90).
> > 
> > This is what I debated most while writing this patch. If I'm
> > understanding your concern correctly, I think I'm doing more than
> > skipping high-priority cgroups:
> 
> Yes, that is my concern. It could give too much pressure lower-priority
> group. You already reduced scanning window for high-priority group so
> I guess it would be enough for working.
> 
> The rationale from my thining is high-priority group can have cold pages(
> for instance, used-once pages, madvise_free pages and so on) so, VM should
> age every groups to reclaim cold pages but we can reduce scanning window
> for high-priority group to keep more workingset as you did. By that, we
> already give more pressure to lower priority group than high-prioirty group.
> 
> > 
> > - If the scan isn't high priority yet, then skip high-priority cgroups.
> 
> This part is the one I think it's too much ;-)
> I think no need to skip but just reduce scanning window by the group's
> prioirty.
> 
> > - When the scan is high priority, scan fewer pages from
> > higher-priority cgroups (using the priority to modify the shift in
> > get_scan_count).
> 
> That sounds lkie a good idea but need to tune more.
> 
> How about this?
> 
> get_scan_count for memcg-A:
>         ..
>         size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx) *
>                         (memcg-A / sum(memcg all priorities))
> 
> get_scan_count for memcg-B:
>         ..
>         size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx) *
>                         (memcg-B / sum(memcg all priorities))
> 

Huh, correction.

        size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
        scan = size >> sc->priority;
        scan =  scan * (sum(memcg) - memcg A) / sum(memcg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
