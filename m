Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E21686B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:39:58 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e17so543658pgv.5
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 01:39:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t66si930353pgc.160.2018.03.20.01.39.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 01:39:57 -0700 (PDT)
Date: Tue, 20 Mar 2018 09:39:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiDnrZTlpI06IFtQQVRD?= =?utf-8?Q?H=5D?=
 mm/memcontrol.c: speed up to force empty a memory cgroup
Message-ID: <20180320083950.GD23100@dhcp22.suse.cz>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
 <20180319085355.GQ23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com>
 <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com>
 <alpine.DEB.2.20.1803191044310.177918@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803191044310.177918@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Li,Rongqing" <lirongqing@baidu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Mon 19-03-18 10:51:57, David Rientjes wrote:
> On Mon, 19 Mar 2018, Li,Rongqing wrote:
> 
> > > > Although SWAP_CLUSTER_MAX is used at the lower level, but the call
> > > > stack of try_to_free_mem_cgroup_pages is too long, increase the
> > > > nr_to_reclaim can reduce times of calling
> > > > function[do_try_to_free_pages, shrink_zones, hrink_node ]
> > > >
> > > > mem_cgroup_resize_limit
> > > > --->try_to_free_mem_cgroup_pages:  .nr_to_reclaim = max(1024,
> > > > --->SWAP_CLUSTER_MAX),
> > > >    ---> do_try_to_free_pages
> > > >      ---> shrink_zones
> > > >       --->shrink_node
> > > >        ---> shrink_node_memcg
> > > >          ---> shrink_list          <-------loop will happen in this place
> > > [times=1024/32]
> > > >            ---> shrink_page_list
> > > 
> > > Can you actually measure this to be the culprit. Because we should rethink
> > > our call path if it is too complicated/deep to perform well.
> > > Adding arbitrary batch sizes doesn't sound like a good way to go to me.
> > 
> > Ok, I will try
> > 
> 
> Looping in mem_cgroup_resize_limit(), which takes memcg_limit_mutex on 
> every iteration which contends with lowering limits in other cgroups (on 
> our systems, thousands), calling try_to_free_mem_cgroup_pages() with less 
> than SWAP_CLUSTER_MAX is lame.

Well, if the global lock is a bottleneck in your deployments then we
can come up with something more clever. E.g. per hierarchy locking
or even drop the lock for the reclaim altogether. If we reclaim in
SWAP_CLUSTER_MAX then the potential over-reclaim risk quite low when
multiple users are shrinking the same (sub)hierarchy.

> It would probably be best to limit the 
> nr_pages to the amount that needs to be reclaimed, though, rather than 
> over reclaiming.

How do you achieve that? The charging path is not synchornized with the
shrinking one at all.

> If you wanted to be invasive, you could change page_counter_limit() to 
> return the count - limit, fix up the callers that look for -EBUSY, and 
> then use max(val, SWAP_CLUSTER_MAX) as your nr_pages.

I am not sure I understand

-- 
Michal Hocko
SUSE Labs
