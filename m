Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3496B025E
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 13:23:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e75so990407wmi.22
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 10:23:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r42si536306eda.155.2017.10.24.10.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Oct 2017 10:23:37 -0700 (PDT)
Date: Tue, 24 Oct 2017 13:23:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171024172330.GA3973@cmpxchg.org>
References: <20171009202613.GA15027@cmpxchg.org>
 <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
 <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
 <20171012190312.GA5075@cmpxchg.org>
 <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
 <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz>
 <20171013152421.yf76n7jui3z5bbn4@dhcp22.suse.cz>
 <20171024160637.GB32340@cmpxchg.org>
 <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 24, 2017 at 06:22:13PM +0200, Michal Hocko wrote:
> On Tue 24-10-17 12:06:37, Johannes Weiner wrote:
> > >  	 *
> > > -	 * That's why we don't do anything here except remember the
> > > -	 * OOM context and then deal with it at the end of the page
> > > -	 * fault when the stack is unwound, the locks are released,
> > > -	 * and when we know whether the fault was overall successful.
> > > +	 * Please note that mem_cgroup_oom_synchronize might fail to find a
> > > +	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
> > > +	 * we would fall back to the global oom killer in pagefault_out_of_memory
> > 
> > Ah, that's why... Ugh, that's really duct-tapey.
> 
> As you know, I really hate the #PF OOM path. We should get rid of it.

I agree, but this isn't getting rid of it, it just adds more layers.

> > > @@ -2007,8 +2021,11 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > >  
> > >  	mem_cgroup_event(mem_over_limit, MEMCG_OOM);
> > >  
> > > -	mem_cgroup_oom(mem_over_limit, gfp_mask,
> > > -		       get_order(nr_pages * PAGE_SIZE));
> > > +	if (mem_cgroup_oom(mem_over_limit, gfp_mask,
> > > +		       get_order(nr_pages * PAGE_SIZE))) {
> > > +		nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > > +		goto retry;
> > > +	}
> > 
> > As per the previous email, this has to goto force, otherwise we return
> > -ENOMEM from syscalls once in a blue moon, which makes verification an
> > absolute nightmare. The behavior should be reliable, without weird p99
> > corner cases.
> >
> > I think what we should be doing here is: if a charge fails, set up an
> > oom context and force the charge; add mem_cgroup_oom_synchronize() to
> > the end of syscalls and kernel-context faults.
> 
> What would prevent a runaway in case the only process in the memcg is
> oom unkillable then?

In such a scenario, the page fault handler would busy-loop right now.

Disabling oom kills is a privileged operation with dire consequences
if used incorrectly. You can panic the kernel with it. Why should the
cgroup OOM killer implement protective semantics around this setting?
Breaching the limit in such a setup is entirely acceptable.

Really, I think it's an enormous mistake to start modeling semantics
based on the most contrived and non-sensical edge case configurations.
Start the discussion with what is sane and what most users should
optimally experience, and keep the cornercases simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
