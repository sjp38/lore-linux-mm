Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEB66B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:50:09 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id t10so136615eei.0
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 02:50:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id v6si12455153eel.91.2013.12.12.02.50.08
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 02:50:08 -0800 (PST)
Date: Thu, 12 Dec 2013 11:50:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131212105003.GC2630@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
 <20131204111318.GE8410@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com>
 <20131209124840.GC3597@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
 <20131210103827.GB20242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
 <20131211095549.GA18741@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
 <20131212103159.GB2630@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212103159.GB2630@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu 12-12-13 11:31:59, Michal Hocko wrote:
[...]
> > > Anyway.
> > > Does the reclaim make any sense for PF_EXITING tasks? Shouldn't we
> > > simply bypass charges of these tasks automatically. Those tasks will
> > > free some memory anyway so why to trigger reclaim and potentially OOM
> > > in the first place? Do we need to go via TIF_MEMDIE loop in the first
> > > place?
> > > 
> > 
> > I don't see any reason to make an optimization there since they will get 
> > TIF_MEMDIE set if reclaim has failed on one of their charges or if it 
> > results in a system oom through the page allocator's oom killer.
> 
> This all will happen after MEM_CGROUP_RECLAIM_RETRIES full reclaim
> rounds. Is it really worth the addional overhead just to later say "OK
> go ahead and skipp charges"?
> And for the !oom memcg it might reclaim some pages which could have
> stayed on LRUs just to free some memory little bit later and release the
> memory pressure.
> So I would rather go with
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c72b03bf9679..fee25c5934d2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2692,7 +2693,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  	 * MEMDIE process.
>  	 */
>  	if (unlikely(test_thread_flag(TIF_MEMDIE)
> -		     || fatal_signal_pending(current)))
> +		     || fatal_signal_pending(current))
> +		     || current->flags & PF_EXITING)
>  		goto bypass;
>  
>  	if (unlikely(task_in_memcg_oom(current)))
> 
> rather than the later checks down the oom_synchronize paths. The comment
> already mentions dying process...

With the full changelog. I will repost it in a separate thread if you
are OK with this.
---
