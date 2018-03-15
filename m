Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0592B6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 16:01:40 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m198so3348211pga.4
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:01:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h2sor1453122pfd.61.2018.03.15.13.01.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 13:01:37 -0700 (PDT)
Date: Thu, 15 Mar 2018 13:01:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, memcg: evaluate root and leaf memcgs fairly on
 oom
In-Reply-To: <20180315164646.GA1853@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.20.1803151259450.44030@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803131720470.247949@chino.kir.corp.google.com> <20180314121700.GA20850@castle.DHCP.thefacebook.com> <alpine.DEB.2.20.1803141337110.163553@chino.kir.corp.google.com>
 <20180315164646.GA1853@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 15 Mar 2018, Roman Gushchin wrote:

> > Seems like it was dropped from the patch somehow.  It is intended to do 
> > atomic_long_add(nr_pages) in mem_cgroup_charge_skmem() and 
> > atomic_long_add(-nr_pages) mem_cgroup_uncharge_skmem().
> > 
> > > I also doubt that global atomic variable can work here,
> > > we probably need something better scaling.
> > > 
> > 
> > Why do you think an atomic_long_add() is too expensive when we're already 
> > disabling irqs and dong try_charge()?
> 
> Hard to say without having full code :)
> try_charge() is batched, if you'll batch it too, it will probably work.
> 

The full code is what's specified above: it does the 
atomic_long_add(nr_pages) in mem_cgroup_charge_skmem() and 
atomic_long_add(-nr_pages) mem_cgroup_uncharge_skmem().

The patch is comparing the root mem cgroup and leaf mem cgroups fairly.  
For this, it requires that we have stats that can be directly compared or 
at least very close approximations.  We don't want to get in a situation 
where root and leaf mem cgroups are being compared based on different 
stats.
