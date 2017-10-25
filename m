Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF89F6B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 09:13:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 196so390051wma.6
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 06:13:08 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b31si1678062ede.175.2017.10.25.06.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Oct 2017 06:13:07 -0700 (PDT)
Date: Wed, 25 Oct 2017 09:11:51 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171025131151.GA8210@cmpxchg.org>
References: <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz>
 <20171013152421.yf76n7jui3z5bbn4@dhcp22.suse.cz>
 <20171024160637.GB32340@cmpxchg.org>
 <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
 <20171024172330.GA3973@cmpxchg.org>
 <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 25, 2017 at 09:15:22AM +0200, Michal Hocko wrote:
> On Tue 24-10-17 23:51:30, Greg Thelen wrote:
> > Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > I am definitely not pushing that thing right now. It is good to discuss
> > > it, though. The more kernel allocations we will track the more careful we
> > > will have to be. So maybe we will have to reconsider the current
> > > approach. I am not sure we need it _right now_ but I feel we will
> > > eventually have to reconsider it.
> > 
> > The kernel already attempts to charge radix_tree_nodes.  If they fail
> > then we fallback to unaccounted memory. 
> 
> I am not sure which code path you have in mind. All I can see is that we
> drop __GFP_ACCOUNT when preloading radix tree nodes. Anyway...
> 
> > So the memcg limit already
> > isn't an air tight constraint.

I fully agree with this. Socket buffers overcharge too. There are
plenty of memory allocations that aren't even tracked.

The point is, it's a hard limit in the sense that breaching it will
trigger the OOM killer. It's not a hard limit in the sense that the
kernel will deadlock to avoid crossing it.

> ... we shouldn't make it more loose though.

Then we can end this discussion right now. I pointed out right from
the start that the only way to replace -ENOMEM with OOM killing in the
syscall is to force charges. If we don't, we either deadlock or still
return -ENOMEM occasionally. Nobody has refuted that this is the case.

> > The current thread can loop in syscall exit until
> > usage is reconciled (either via reclaim or kill).  This seems consistent
> > with pagefault oom handling and compatible with overcommit use case.
> 
> But we do not really want to make the syscall exit path any more complex
> or more expensive than it is. The point is that we shouldn't be afraid
> about triggering the oom killer from the charge patch because we do have
> async OOM killer. This is very same with the standard allocator path. So
> why should be memcg any different?

I have nothing against triggering the OOM killer from the allocation
path. I am dead-set against making the -ENOMEM return from syscalls
rare and unpredictable. They're a challenge as it is.

The only sane options are to stick with the status quo, or make sure
the task never returns before the allocation succeeds. Making things
in this path more speculative is a downgrade, not an improvement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
