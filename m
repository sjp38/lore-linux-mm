Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 121976B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 03:15:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f27so8314350wra.9
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 00:15:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m76si1480956wmi.31.2017.10.25.00.15.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 00:15:25 -0700 (PDT)
Date: Wed, 25 Oct 2017 09:15:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
References: <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
 <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz>
 <20171013152421.yf76n7jui3z5bbn4@dhcp22.suse.cz>
 <20171024160637.GB32340@cmpxchg.org>
 <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
 <20171024172330.GA3973@cmpxchg.org>
 <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 24-10-17 23:51:30, Greg Thelen wrote:
> Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > I am definitely not pushing that thing right now. It is good to discuss
> > it, though. The more kernel allocations we will track the more careful we
> > will have to be. So maybe we will have to reconsider the current
> > approach. I am not sure we need it _right now_ but I feel we will
> > eventually have to reconsider it.
> 
> The kernel already attempts to charge radix_tree_nodes.  If they fail
> then we fallback to unaccounted memory. 

I am not sure which code path you have in mind. All I can see is that we
drop __GFP_ACCOUNT when preloading radix tree nodes. Anyway...

> So the memcg limit already
> isn't an air tight constraint.

... we shouldn't make it more loose though.

> I agree that unchecked overcharging could be bad, but wonder if we could
> overcharge kmem so long as there is a pending oom kill victim.

Why is this any better than simply trying to charge as long as the oom
killer makes progress?

> If
> current is the victim or no victim, then fail allocations (as is
> currently done).

we actually force the charge in that case so we will proceed.

> The current thread can loop in syscall exit until
> usage is reconciled (either via reclaim or kill).  This seems consistent
> with pagefault oom handling and compatible with overcommit use case.

But we do not really want to make the syscall exit path any more complex
or more expensive than it is. The point is that we shouldn't be afraid
about triggering the oom killer from the charge patch because we do have
async OOM killer. This is very same with the standard allocator path. So
why should be memcg any different?

> Here's an example of an overcommit case we've found quite useful.  Memcg A has
> memory which is shared between children B and C.  B is more important the C.
> B and C are unprivileged, neither has the authority to kill the other.
> 
>     /A(limit=100MB) - B(limit=80MB,prio=high)
>                      \ C(limit=80MB,prio=low)
> 
> If memcg charge drives B.usage+C.usage>=A.limit, then C should be killed due to
> its low priority.  B pagefault can kill, but if a syscall returns ENOMEM then B
> can't do anything useful with it.

well, my proposal was to not return ENOMEM and rather loop in the charge
path and wait for the oom killer to free up some charges. Who gets
killed is really out of scope of this discussion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
