Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 694078E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 12:24:31 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x64so2332875ywc.6
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 09:24:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u192sor9384816ywf.109.2019.01.08.09.24.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 09:24:30 -0800 (PST)
MIME-Version: 1.0
References: <20190103015638.205424-1-shakeelb@google.com> <20190108145942.GZ31793@dhcp22.suse.cz>
In-Reply-To: <20190108145942.GZ31793@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 8 Jan 2019 09:24:18 -0800
Message-ID: <CALvZod6sx6tA2EvnXZ_h=qZu6xtcL14uSMyp-gqxedy8T0L6qg@mail.gmail.com>
Subject: Re: [PATCH] memcg: schedule high reclaim for remote memcgs on high_work
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 8, 2019 at 6:59 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 02-01-19 17:56:38, Shakeel Butt wrote:
> > If a memcg is over high limit, memory reclaim is scheduled to run on
> > return-to-userland. However it is assumed that the memcg is the current
> > process's memcg. With remote memcg charging for kmem or swapping in a
> > page charged to remote memcg, current process can trigger reclaim on
> > remote memcg. So, schduling reclaim on return-to-userland for remote
> > memcgs will ignore the high reclaim altogether. So, punt the high
> > reclaim of remote memcgs to high_work.
>
> Have you seen this happening in real life workloads?

No, just during code review.

> And is this offloading what we really want to do?

That's the question I am brainstorming nowadays. More generally how
memcg-oom-kill should work in the remote memcg charging case.

> I mean it is clearly the current
> task that has triggered the remote charge so why should we offload that
> work to a system? Is there any reason we cannot reclaim on the remote
> memcg from the return-to-userland path?
>

The only reason I did this was the code was much simpler but I see
that the current is charging the given memcg and maybe even
reclaiming, so, why not do the high reclaim as well. I will update the
patch.

thanks,
Shakeel
