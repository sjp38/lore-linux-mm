Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF78C6B0253
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:44:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n8so671928wmg.4
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 09:44:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y39si2081978edb.258.2017.10.25.09.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Oct 2017 09:44:12 -0700 (PDT)
Date: Wed, 25 Oct 2017 12:44:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171025164402.GA11582@cmpxchg.org>
References: <20171024160637.GB32340@cmpxchg.org>
 <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
 <20171024172330.GA3973@cmpxchg.org>
 <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 25, 2017 at 04:12:21PM +0200, Michal Hocko wrote:
> On Wed 25-10-17 09:11:51, Johannes Weiner wrote:
> > On Wed, Oct 25, 2017 at 09:15:22AM +0200, Michal Hocko wrote:
> [...]
> > > ... we shouldn't make it more loose though.
> > 
> > Then we can end this discussion right now. I pointed out right from
> > the start that the only way to replace -ENOMEM with OOM killing in the
> > syscall is to force charges. If we don't, we either deadlock or still
> > return -ENOMEM occasionally. Nobody has refuted that this is the case.
> 
> Yes this is true. I guess we are back to the non-failing allocations
> discussion...  Currently we are too ENOMEM happy for memcg !PF paths which
> can lead to weird issues Greg has pointed out earlier. Going to opposite
> direction to basically never ENOMEM and rather pretend a success (which
> allows runaways for extreme setups with no oom eligible tasks) sounds
> like going from one extreme to another. This basically means that those
> charges will effectively GFP_NOFAIL. Too much to guarantee IMHO.

We're talking in circles.

Overrunning the hard limit in the syscall path isn't worse than an
infinite loop in the page fault path. Once you make tasks ineligible
for OOM, that's what you have to expect. It's the OOM disabling that
results in extreme consequences across the board.

It's silly to keep bringing this up as an example.

> > They're a challenge as it is.  The only sane options are to stick with
> > the status quo,
> 
> One thing that really worries me about the current status quo is that
> the behavior depends on whether you run under memcg or not. The global
> policy is "almost never fail unless something horrible is going on".
> But we _do not_ guarantee that ENOMEM stays inside the kernel.
> 
> So if we need to do something about that I would think we need an
> universal solution rather than something memcg specific. Sure global
> ENOMEMs are so rare that nobody will probably trigger those but that is
> just a wishful thinking...

The difference in current behavior comes from the fact that real-life
workloads could trigger a deadlock with memcg looping indefinitely in
the charge path, but not with the allocator looping indefinitely in
the allocation path.

That also means that if we change it like you proposed, it'll be much
more likely to trigger -ENOMEM from syscalls inside memcg than it is
outside.

The margins are simply tighter inside cgroups. You often have only a
few closely interacting tasks in there, and the probability for
something to go wrong is much higher than on the system scope.

But also, the system is constrained by physical limits. It's a hard
wall; once you hit it, the kernel is dead, so we don't have a lot of
options. Memcg on the other hand is a completely artificial limit. It
doesn't make sense to me to pretend it's a hard wall to the point
where we actively *create* for ourselves the downsides of a physical
limitation.

> So how about we start with a BIG FAT WARNING for the failure case?
> Something resembling warn_alloc for the failure case.
>
> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5d9323028870..3ba62c73eee5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1547,9 +1547,14 @@ static bool mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
>  	 * we would fall back to the global oom killer in pagefault_out_of_memory
>  	 */
> -	if (!memcg->oom_kill_disable &&
> -			mem_cgroup_out_of_memory(memcg, mask, order))
> -		return true;
> +	if (!memcg->oom_kill_disable) {
> +		if (mem_cgroup_out_of_memory(memcg, mask, order))
> +			return true;
> +
> +		WARN(!current->memcg_may_oom,
> +				"Memory cgroup charge failed because of no reclaimable memory! "
> +				"This looks like a misconfiguration or a kernel bug.");
> +	}

That's crazy!

We shouldn't create interfaces that make it possible to accidentally
livelock the kernel. Then warn about it and let it crash. That is a
DOS-level lack of OS abstraction.

In such a situation, we should ignore oom_score_adj or ignore the hard
limit. Even panic() would be better from a machine management point of
view than leaving random tasks inside infinite loops.

Why is OOM-disabling a thing? Why isn't this simply a "kill everything
else before you kill me"? It's crashing the kernel in trying to
protect a userspace application. How is that not insane?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
