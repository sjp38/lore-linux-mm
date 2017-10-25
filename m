Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2BC6B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 14:11:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p96so351898wrb.12
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 11:11:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f20si1907803edm.199.2017.10.25.11.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Oct 2017 11:11:13 -0700 (PDT)
Date: Wed, 25 Oct 2017 14:11:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171025181106.GA14967@cmpxchg.org>
References: <20171024172330.GA3973@cmpxchg.org>
 <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
 <20171025172924.i7du5wnkeihx2fgl@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025172924.i7du5wnkeihx2fgl@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 25, 2017 at 07:29:24PM +0200, Michal Hocko wrote:
> On Wed 25-10-17 12:44:02, Johannes Weiner wrote:
> > On Wed, Oct 25, 2017 at 04:12:21PM +0200, Michal Hocko wrote:
> > > So how about we start with a BIG FAT WARNING for the failure case?
> > > Something resembling warn_alloc for the failure case.
> > >
> > > ---
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 5d9323028870..3ba62c73eee5 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1547,9 +1547,14 @@ static bool mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> > >  	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
> > >  	 * we would fall back to the global oom killer in pagefault_out_of_memory
> > >  	 */
> > > -	if (!memcg->oom_kill_disable &&
> > > -			mem_cgroup_out_of_memory(memcg, mask, order))
> > > -		return true;
> > > +	if (!memcg->oom_kill_disable) {
> > > +		if (mem_cgroup_out_of_memory(memcg, mask, order))
> > > +			return true;
> > > +
> > > +		WARN(!current->memcg_may_oom,
> > > +				"Memory cgroup charge failed because of no reclaimable memory! "
> > > +				"This looks like a misconfiguration or a kernel bug.");
> > > +	}
> > 
> > That's crazy!
> > 
> > We shouldn't create interfaces that make it possible to accidentally
> > livelock the kernel. Then warn about it and let it crash. That is a
> > DOS-level lack of OS abstraction.
> > 
> > In such a situation, we should ignore oom_score_adj or ignore the hard
> > limit. Even panic() would be better from a machine management point of
> > view than leaving random tasks inside infinite loops.
> > 
> > Why is OOM-disabling a thing? Why isn't this simply a "kill everything
> > else before you kill me"? It's crashing the kernel in trying to
> > protect a userspace application. How is that not insane?
> 
> I really do not follow. What kind of livelock or crash are you talking
> about. All this code does is that the charge request (which is not
> explicitly GFP_NOFAIL) fails with ENOMEM if the oom killer is not able
> to make a forward progress. That sounds like a safer option than failing
> with ENOMEM unconditionally which is what we do currently.

I pointed out multiple times now that consistent -ENOMEM is better
than a rare one because it's easier to verify application behavior
with test runs. And I don't understand what your counter-argument is.

"Safe" is a vague term, and it doesn't make much sense to me in this
situation. The OOM behavior should be predictable and consistent.

Yes, global might in the rarest cases also return -ENOMEM. Maybe. We
don't have to do that in memcg because we're not physically limited.

> So the only change I am really proposing is to keep retrying as long
> as the oom killer makes a forward progress and ENOMEM otherwise.

That's the behavior change I'm against.

> I am also not trying to protect an userspace application. Quite
> contrary, I would like the application gets ENOMEM when it should run
> away from the constraint it runs within. I am protecting everything
> outside of the hard limited memcg actually.
> 
> So what is that I am missing?

The page fault path.

Maybe that's not what you set out to fix, but it will now not only
enter an infinite loop, it will also WARN() on each iteration.

It would make sense to step back and think about the comprehensive
user-visible behavior of an out-of-memory situation, and not just the
one syscall aspect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
