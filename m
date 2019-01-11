Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id A316B8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 17:54:45 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id d73so8669919ywd.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 14:54:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j14sor21554560ybh.72.2019.01.11.14.54.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 14:54:44 -0800 (PST)
MIME-Version: 1.0
References: <20190110174432.82064-1-shakeelb@google.com> <20190111205948.GA4591@cmpxchg.org>
In-Reply-To: <20190111205948.GA4591@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 11 Jan 2019 14:54:32 -0800
Message-ID: <CALvZod7O2CJuhbuLUy9R-E4dTgL4WBg8CayW_AFnCCG6KCDjUA@mail.gmail.com>
Subject: Re: [PATCH v3] memcg: schedule high reclaim for remote memcgs on high_work
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Johannes,

On Fri, Jan 11, 2019 at 12:59 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> Hi Shakeel,
>
> On Thu, Jan 10, 2019 at 09:44:32AM -0800, Shakeel Butt wrote:
> > If a memcg is over high limit, memory reclaim is scheduled to run on
> > return-to-userland.  However it is assumed that the memcg is the current
> > process's memcg.  With remote memcg charging for kmem or swapping in a
> > page charged to remote memcg, current process can trigger reclaim on
> > remote memcg.  So, schduling reclaim on return-to-userland for remote
> > memcgs will ignore the high reclaim altogether. So, record the memcg
> > needing high reclaim and trigger high reclaim for that memcg on
> > return-to-userland.  However if the memcg is already recorded for high
> > reclaim and the recorded memcg is not the descendant of the the memcg
> > needing high reclaim, punt the high reclaim to the work queue.
>
> The idea behind remote charging is that the thread allocating the
> memory is not responsible for that memory, but a different cgroup
> is. Why would the same thread then have to work off any high excess
> this could produce in that unrelated group?
>
> Say you have a inotify/dnotify listener that is restricted in its
> memory use - now everybody sending notification events from outside
> that listener's group would get throttled on a cgroup over which it
> has no control. That sounds like a recipe for priority inversions.
>
> It seems to me we should only do reclaim-on-return when current is in
> the ill-behaved cgroup, and punt everything else - interrupts and
> remote charges - to the workqueue.

This is what v1 of this patch was doing but Michal suggested to do
what this version is doing. Michal's argument was that the current is
already charging and maybe reclaiming a remote memcg then why not do
the high excess reclaim as well.

Personally I don't have any strong opinion either way. What I actually
wanted was to punt this high reclaim to some process in that remote
memcg. However I didn't explore much on that direction thinking if
that complexity is worth it. Maybe I should at least explore it, so,
we can compare the solutions. What do you think?

Shakeel
