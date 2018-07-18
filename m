Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCF36B0271
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 06:42:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v26-v6so1765617eds.9
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 03:42:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a16-v6si2740557edc.228.2018.07.18.03.42.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 03:42:32 -0700 (PDT)
Date: Wed, 18 Jul 2018 12:42:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some
 machines
Message-ID: <20180718104230.GC1431@dhcp22.suse.cz>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruce Merry <bmerry@ska.ac.za>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

[CC some more people]

On Tue 17-07-18 21:23:07, Andrew Morton wrote:
> (cc linux-mm)
> 
> On Tue, 3 Jul 2018 08:43:23 +0200 Bruce Merry <bmerry@ska.ac.za> wrote:
> 
> > Hi
> > 
> > I've run into an odd performance issue in the kernel, and not being a
> > kernel dev or knowing terribly much about cgroups, am looking for
> > advice on diagnosing the problem further (I discovered this while
> > trying to pin down high CPU load in cadvisor).
> > 
> > On some machines in our production system, cat
> > /sys/fs/cgroup/memory/memory.stat is extremely slow (500ms on one
> > machine), while on other nominally identical machines it is fast
> > (2ms).

Could you try to use ftrace to see where the time is spent?
memory_stat_show should only scale with the depth of the cgroup
hierarchy for memory.stat to get cumulative numbers. All the rest should
be simply reads of gathered counters. There is no locking involved in
the current kernel. What is the kernel version you are using, btw?

Keeping the reset of the email for new people on the CC

> > 
> > One other thing I've noticed is that the affected machines generally
> > have much larger values for SUnreclaim in /proc/memstat (up to several
> > GB), and slabtop reports >1GB of dentry.
> > 
> > Before I tracked the original problem (high CPU usage in cadvisor)
> > down to this, I rebooted one of the machines and the original problem
> > went away, so it seems to be cleared by a reboot; I'm reluctant to
> > reboot more machines to confirm since I don't have a sure-fire way to
> > reproduce the problem again to debug it.
> > 
> > The machines are running Ubuntu 16.04 with kernel 4.13.0-41-generic.
> > They're running Docker, which creates a bunch of cgroups, but not an
> > excessive number: there are 106 memory.stat files in
> > /sys/fs/cgroup/memory.
> > 
> > Digging a bit further, cat
> > /sys/fs/cgroup/memory/system.slice/memory.stat also takes ~500ms, but
> > "find /sys/fs/cgroup/memory/system.slice -mindepth 2 -name memory.stat
> > | xargs cat" takes only 8ms.
> > 
> > Any thoughts, particularly on what I should compare between the good
> > and bad machines to narrow down the cause, or even better, how to
> > prevent it happening?
> > 
> > Thanks
> > Bruce
> > -- 
> > Bruce Merry
> > Senior Science Processing Developer
> > SKA South Africa

-- 
Michal Hocko
SUSE Labs
