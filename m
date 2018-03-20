Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC20A6B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 16:30:00 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x8-v6so1787178pln.9
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:30:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a14sor741002pff.5.2018.03.20.13.29.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 13:29:59 -0700 (PDT)
Date: Tue, 20 Mar 2018 13:29:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: =?UTF-8?Q?Re=3A_=E7=AD=94=E5=A4=8D=3A_=E7=AD=94=E5=A4=8D=3A_=5BPATCH=5D_mm=2Fmemcontrol=2Ec=3A_speed_up_to_force_empty_a_memory_cgroup?=
In-Reply-To: <20180320083950.GD23100@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1803201327060.167205@chino.kir.corp.google.com>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com> <20180319085355.GQ23100@dhcp22.suse.cz> <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com> <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com> <alpine.DEB.2.20.1803191044310.177918@chino.kir.corp.google.com> <20180320083950.GD23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Li,Rongqing" <lirongqing@baidu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Tue, 20 Mar 2018, Michal Hocko wrote:

> > > > > Although SWAP_CLUSTER_MAX is used at the lower level, but the call
> > > > > stack of try_to_free_mem_cgroup_pages is too long, increase the
> > > > > nr_to_reclaim can reduce times of calling
> > > > > function[do_try_to_free_pages, shrink_zones, hrink_node ]
> > > > >
> > > > > mem_cgroup_resize_limit
> > > > > --->try_to_free_mem_cgroup_pages:  .nr_to_reclaim = max(1024,
> > > > > --->SWAP_CLUSTER_MAX),
> > > > >    ---> do_try_to_free_pages
> > > > >      ---> shrink_zones
> > > > >       --->shrink_node
> > > > >        ---> shrink_node_memcg
> > > > >          ---> shrink_list          <-------loop will happen in this place
> > > > [times=1024/32]
> > > > >            ---> shrink_page_list
> > > > 
> > > > Can you actually measure this to be the culprit. Because we should rethink
> > > > our call path if it is too complicated/deep to perform well.
> > > > Adding arbitrary batch sizes doesn't sound like a good way to go to me.
> > > 
> > > Ok, I will try
> > > 
> > 
> > Looping in mem_cgroup_resize_limit(), which takes memcg_limit_mutex on 
> > every iteration which contends with lowering limits in other cgroups (on 
> > our systems, thousands), calling try_to_free_mem_cgroup_pages() with less 
> > than SWAP_CLUSTER_MAX is lame.
> 
> Well, if the global lock is a bottleneck in your deployments then we
> can come up with something more clever. E.g. per hierarchy locking
> or even drop the lock for the reclaim altogether. If we reclaim in
> SWAP_CLUSTER_MAX then the potential over-reclaim risk quite low when
> multiple users are shrinking the same (sub)hierarchy.
> 

I don't believe this to be a bottleneck if nr_pages is increased in 
mem_cgroup_resize_limit().

> > It would probably be best to limit the 
> > nr_pages to the amount that needs to be reclaimed, though, rather than 
> > over reclaiming.
> 
> How do you achieve that? The charging path is not synchornized with the
> shrinking one at all.
> 

The point is to get a better guess at how many pages, up to 
SWAP_CLUSTER_MAX, that need to be reclaimed instead of 1.

> > If you wanted to be invasive, you could change page_counter_limit() to 
> > return the count - limit, fix up the callers that look for -EBUSY, and 
> > then use max(val, SWAP_CLUSTER_MAX) as your nr_pages.
> 
> I am not sure I understand
> 

Have page_counter_limit() return the number of pages over limit, i.e. 
count - limit, since it compares the two anyway.  Fix up existing callers 
and then clamp that value to SWAP_CLUSTER_MAX in 
mem_cgroup_resize_limit().  It's a more accurate guess than either 1 or 
1024.
