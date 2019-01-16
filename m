Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 258368E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 02:02:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so2040445eda.3
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 23:02:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r23-v6si280465ejb.173.2019.01.15.23.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 23:02:20 -0800 (PST)
Date: Wed, 16 Jan 2019 08:02:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] memcg: schedule high reclaim for remote memcgs on
 high_work
Message-ID: <20190116070218.GF24149@dhcp22.suse.cz>
References: <20190110174432.82064-1-shakeelb@google.com>
 <20190111205948.GA4591@cmpxchg.org>
 <CALvZod7O2CJuhbuLUy9R-E4dTgL4WBg8CayW_AFnCCG6KCDjUA@mail.gmail.com>
 <20190113183402.GD1578@dhcp22.suse.cz>
 <CALvZod6paX4_vtgP8AJm5PmW_zA_ecLLP2qTvQz8rRyKticgDg@mail.gmail.com>
 <20190115072551.GO21345@dhcp22.suse.cz>
 <CALvZod6U+OGZJ1mcSG++Q5CJtEjLbr3pwvLRBbkpbZbqf6YSsA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6U+OGZJ1mcSG++Q5CJtEjLbr3pwvLRBbkpbZbqf6YSsA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 15-01-19 11:38:23, Shakeel Butt wrote:
> On Mon, Jan 14, 2019 at 11:25 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 14-01-19 12:18:07, Shakeel Butt wrote:
> > > On Sun, Jan 13, 2019 at 10:34 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Fri 11-01-19 14:54:32, Shakeel Butt wrote:
> > > > > Hi Johannes,
> > > > >
> > > > > On Fri, Jan 11, 2019 at 12:59 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > > >
> > > > > > Hi Shakeel,
> > > > > >
> > > > > > On Thu, Jan 10, 2019 at 09:44:32AM -0800, Shakeel Butt wrote:
> > > > > > > If a memcg is over high limit, memory reclaim is scheduled to run on
> > > > > > > return-to-userland.  However it is assumed that the memcg is the current
> > > > > > > process's memcg.  With remote memcg charging for kmem or swapping in a
> > > > > > > page charged to remote memcg, current process can trigger reclaim on
> > > > > > > remote memcg.  So, schduling reclaim on return-to-userland for remote
> > > > > > > memcgs will ignore the high reclaim altogether. So, record the memcg
> > > > > > > needing high reclaim and trigger high reclaim for that memcg on
> > > > > > > return-to-userland.  However if the memcg is already recorded for high
> > > > > > > reclaim and the recorded memcg is not the descendant of the the memcg
> > > > > > > needing high reclaim, punt the high reclaim to the work queue.
> > > > > >
> > > > > > The idea behind remote charging is that the thread allocating the
> > > > > > memory is not responsible for that memory, but a different cgroup
> > > > > > is. Why would the same thread then have to work off any high excess
> > > > > > this could produce in that unrelated group?
> > > > > >
> > > > > > Say you have a inotify/dnotify listener that is restricted in its
> > > > > > memory use - now everybody sending notification events from outside
> > > > > > that listener's group would get throttled on a cgroup over which it
> > > > > > has no control. That sounds like a recipe for priority inversions.
> > > > > >
> > > > > > It seems to me we should only do reclaim-on-return when current is in
> > > > > > the ill-behaved cgroup, and punt everything else - interrupts and
> > > > > > remote charges - to the workqueue.
> > > > >
> > > > > This is what v1 of this patch was doing but Michal suggested to do
> > > > > what this version is doing. Michal's argument was that the current is
> > > > > already charging and maybe reclaiming a remote memcg then why not do
> > > > > the high excess reclaim as well.
> > > >
> > > > Johannes has a good point about the priority inversion problems which I
> > > > haven't thought about.
> > > >
> > > > > Personally I don't have any strong opinion either way. What I actually
> > > > > wanted was to punt this high reclaim to some process in that remote
> > > > > memcg. However I didn't explore much on that direction thinking if
> > > > > that complexity is worth it. Maybe I should at least explore it, so,
> > > > > we can compare the solutions. What do you think?
> > > >
> > > > My question would be whether we really care all that much. Do we know of
> > > > workloads which would generate a large high limit excess?
> > > >
> > >
> > > The current semantics of memory.high is that it can be breached under
> > > extreme conditions. However any workload where memory.high is used and
> > > a lot of remote memcg charging happens (inotify/dnotify example given
> > > by Johannes or swapping in tmpfs file or shared memory region) the
> > > memory.high breach will become common.
> >
> > This is exactly what I am asking about. Is this something that can
> > happen easily? Remote charges on themselves should be rare, no?
> >
> 
> At the moment, for kmem we can do remote charging for fanotify,
> inotify and buffer_head and for anon pages we can do remote charging
> on swap in. Now based on the workload's cgroup setup the remote
> charging can be very frequent or rare.
> 
> At Google, remote charging is very frequent but since we are still on
> cgroup-v1 and do not use memory.high, the issue this patch is fixing
> is not observed. However for the adoption of cgroup-v2, this fix is
> needed.

Adding some numbers into the changelog would be really valuable to judge
the urgency and the scale of the problem. If we are going via kworker
then it is also important to evaluate what kind of effect on the system
this has.  How big of the excess can we get? Why don't those memcgs
resolve the excess by themselves on the first direct charge? Is it
possible that kworkers simply swamp the system with many parallel memcgs
with remote charges?

In other words we need deeper analysis of the problem and the solution.
-- 
Michal Hocko
SUSE Labs
