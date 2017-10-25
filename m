Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9986B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 13:29:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q127so721787wmd.1
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 10:29:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a13si1869534eda.209.2017.10.25.10.29.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 10:29:25 -0700 (PDT)
Date: Wed, 25 Oct 2017 19:29:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171025172924.i7du5wnkeihx2fgl@dhcp22.suse.cz>
References: <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
 <20171024172330.GA3973@cmpxchg.org>
 <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025164402.GA11582@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed 25-10-17 12:44:02, Johannes Weiner wrote:
> On Wed, Oct 25, 2017 at 04:12:21PM +0200, Michal Hocko wrote:
[...]

I yet have to digest the first path of the email but the remaining
just sounds we are not on the same page.

> > So how about we start with a BIG FAT WARNING for the failure case?
> > Something resembling warn_alloc for the failure case.
> >
> > ---
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 5d9323028870..3ba62c73eee5 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1547,9 +1547,14 @@ static bool mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> >  	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
> >  	 * we would fall back to the global oom killer in pagefault_out_of_memory
> >  	 */
> > -	if (!memcg->oom_kill_disable &&
> > -			mem_cgroup_out_of_memory(memcg, mask, order))
> > -		return true;
> > +	if (!memcg->oom_kill_disable) {
> > +		if (mem_cgroup_out_of_memory(memcg, mask, order))
> > +			return true;
> > +
> > +		WARN(!current->memcg_may_oom,
> > +				"Memory cgroup charge failed because of no reclaimable memory! "
> > +				"This looks like a misconfiguration or a kernel bug.");
> > +	}
> 
> That's crazy!
> 
> We shouldn't create interfaces that make it possible to accidentally
> livelock the kernel. Then warn about it and let it crash. That is a
> DOS-level lack of OS abstraction.
> 
> In such a situation, we should ignore oom_score_adj or ignore the hard
> limit. Even panic() would be better from a machine management point of
> view than leaving random tasks inside infinite loops.
> 
> Why is OOM-disabling a thing? Why isn't this simply a "kill everything
> else before you kill me"? It's crashing the kernel in trying to
> protect a userspace application. How is that not insane?

I really do not follow. What kind of livelock or crash are you talking
about. All this code does is that the charge request (which is not
explicitly GFP_NOFAIL) fails with ENOMEM if the oom killer is not able
to make a forward progress. That sounds like a safer option than failing
with ENOMEM unconditionally which is what we do currently. So the only
change I am really proposing is to keep retrying as long as the oom
killer makes a forward progress and ENOMEM otherwise.

I am also not trying to protect an userspace application. Quite
contrary, I would like the application gets ENOMEM when it should run
away from the constraint it runs within. I am protecting everything
outside of the hard limited memcg actually.

So what is that I am missing?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
