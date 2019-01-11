Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 70BA98E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:59:55 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x64so8458481ywc.6
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:59:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v4sor10669047ywd.1.2019.01.11.12.59.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 12:59:49 -0800 (PST)
Date: Fri, 11 Jan 2019 15:59:48 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3] memcg: schedule high reclaim for remote memcgs on
 high_work
Message-ID: <20190111205948.GA4591@cmpxchg.org>
References: <20190110174432.82064-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190110174432.82064-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Shakeel,

On Thu, Jan 10, 2019 at 09:44:32AM -0800, Shakeel Butt wrote:
> If a memcg is over high limit, memory reclaim is scheduled to run on
> return-to-userland.  However it is assumed that the memcg is the current
> process's memcg.  With remote memcg charging for kmem or swapping in a
> page charged to remote memcg, current process can trigger reclaim on
> remote memcg.  So, schduling reclaim on return-to-userland for remote
> memcgs will ignore the high reclaim altogether. So, record the memcg
> needing high reclaim and trigger high reclaim for that memcg on
> return-to-userland.  However if the memcg is already recorded for high
> reclaim and the recorded memcg is not the descendant of the the memcg
> needing high reclaim, punt the high reclaim to the work queue.

The idea behind remote charging is that the thread allocating the
memory is not responsible for that memory, but a different cgroup
is. Why would the same thread then have to work off any high excess
this could produce in that unrelated group?

Say you have a inotify/dnotify listener that is restricted in its
memory use - now everybody sending notification events from outside
that listener's group would get throttled on a cgroup over which it
has no control. That sounds like a recipe for priority inversions.

It seems to me we should only do reclaim-on-return when current is in
the ill-behaved cgroup, and punt everything else - interrupts and
remote charges - to the workqueue.
