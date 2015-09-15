Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFC76B025C
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 04:01:14 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so16361242wic.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 01:01:13 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id s3si22590663wis.64.2015.09.15.01.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 01:01:12 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so15277720wic.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 01:01:12 -0700 (PDT)
Date: Tue, 15 Sep 2015 10:01:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] memcg: ratify and consolidate over-charge handling
Message-ID: <20150915080110.GA14532@dhcp22.suse.cz>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
 <20150914193225.GA26273@dhcp22.suse.cz>
 <20150914195608.GF25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914195608.GF25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Mon 14-09-15 15:56:08, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Sep 14, 2015 at 09:32:25PM +0200, Michal Hocko wrote:
> > >   mem_cgroup_try_charge() needs to switch
> > >   the returned cgroup to the root one.
> > > 
> > > The reality is that in memcg there are cases where we are forced
> > > and/or willing to go over the limit.  Each such case needs to be
> > > scrutinized and justified but there definitely are situations where
> > > that is the right thing to do.  We alredy do this but with a
> > > superficial and inconsistent disguise which leads to unnecessary
> > > complications.
> > >
> > > This patch updates try_charge() so that it over-charges and returns 0
> > > when deemed necessary.  -EINTR return is removed along with all
> > > special case handling in the callers.
> > 
> > OK the code is easier in the end, although I would argue that try_charge
> > could return ENOMEM for GFP_NOWAIT instead of overcharging (this would
> > e.g. allow precharge to bail out earlier). Something for a separate patch I
> > guess.
> 
> Hmm... GFP_NOWAIT is failed unless it also has __GFP_NOFAIL.

Yes I wasn't clear, sorry, it fails but TIF_MEMDIE or killed/exiting
context would still overcharge GFP_NOWAIT requests rather than failing
them. Something for a separate patch though.

> > Anyway I still do not like usage > max/hard limit presented to userspace
> > because it looks like a clear breaking of max/hard limit semantic. I
> > realize that we cannot solve the underlying problem easily or it might
> > be unfeasible but we should consider how to present this state to the
> > userspace.
> > We have basically 2 options AFAICS. We can either document that a
> > _temporal_ breach of the max/hard limit is allowed or we can hide this
> > fact and always present max(current,max).
> > The first one might be better for an easier debugging and it is also
> > more honest about the current state but the definition of the hard limit
> > is a bit weird. It also exposes implementation details to the userspace.
> > The other choice is clearly lying but users shouldn't care about the
> > implementation details and if the state is really temporal then the
> > userspace shouldn't even notice. There is also a risk that somebody is
> > already depending on current < max which happened to work without kmem
> > until now.
> > This is something to be solved in a separate patch I guess but we
> > should think about that. I am not entirely clear on that myself but I am
> > more inclined to the first option and simply document the potential
> > corner case and temporal breach.
> 
> I'm pretty sure we don't wanna lie.  Just document that temporal
> small-scale breaches may happen. 

It goes against hard limit semantic but I am more and more convinced this
is the right way to go because I think we want to mimic the global case
which allows to access accounted reserves in some cases (e.g. reclaimers
should be able to get access to more memory to free memory). I will cook
up a documentation patch sometimes this week but we have an internal
conference so I might be too busy to do it right away.

> I don't even think this is an implementation detail.

I really think this is an implementation detail because we can force
the implementation to never overcharge. Just retry indefinitely for
__GFP_NOFAIL, fail the charge for others and be done with that. Of
course it is not that easy. Retrying indefinitely is deadlock prone.
Relaxing conditions for exiting tasks is merely an optimization.  The
slab code could be reorganized to cope with the ENOMEM as well. But I
guess this is not worth the effort and a small and ephemeral overcharge
is justified.

> The fact that we have separate high and max
> limits is already admitting that this is inherently different from
> global case and that memcg is consciously and actively making
> trade-offs regarding handling of global and local memory pressure and

I am not sure I understand here. High and max are basically resembling
watermarks for the global case. Sure max/high can be set independently
which is not the case for the global case which calculates them from
min_free_kbytes but why would that matter and make them different?

As mentioned above the resemblance with the global case should make it
more understandable for users.

> I think that's the right thing to do and something inherent to what
> memcg is doing here.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
