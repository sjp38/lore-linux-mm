Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6000282F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 05:28:07 -0400 (EDT)
Received: by lfbf136 with SMTP id f136so1826597lfb.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 02:28:06 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ue7si453030lbb.33.2015.10.29.02.28.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 02:28:05 -0700 (PDT)
Date: Thu, 29 Oct 2015 12:27:47 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Message-ID: <20151029092747.GR13221@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <20151022184509.GM18351@esperanza>
 <20151026172216.GC2214@cmpxchg.org>
 <20151027084320.GF13221@esperanza>
 <20151027155833.GB4665@cmpxchg.org>
 <20151028082003.GK13221@esperanza>
 <20151028185810.GA31488@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151028185810.GA31488@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 28, 2015 at 11:58:10AM -0700, Johannes Weiner wrote:
> On Wed, Oct 28, 2015 at 11:20:03AM +0300, Vladimir Davydov wrote:
> > Then you'd better not touch existing tcp limits at all, because they
> > just work, and the logic behind them is very close to that of global tcp
> > limits. I don't think one can simplify it somehow.
> 
> Uhm, no, there is a crapload of boilerplate code and complication that
> seems entirely unnecessary. The only thing missing from my patch seems
> to be the part where it enters memory pressure state when the limit is
> hit. I'm adding this for completeness, but I doubt it even matters.
> 
> > Moreover, frankly I still have my reservations about this vmpressure
> > propagation to skb you're proposing. It might work, but I doubt it
> > will allow us to throw away explicit tcp limit, as I explained
> > previously. So, even with your approach I think we can still need
> > per memcg tcp limit *unless* you get rid of global tcp limit
> > somehow.
> 
> Having the hard limit as a failsafe (or a minimum for other consumers)
> is one thing, and certainly something I'm open to for cgroupv2, should
> we have problems with load startup up after a socket memory landgrab.
> 
> That being said, if the VM is struggling to reclaim pages, or is even
> swapping, it makes perfect sense to let the socket memory scheduler
> know it shouldn't continue to increase its footprint until the VM
> recovers. Regardless of any hard limitations/minimum guarantees.
> 
> This is what my patch does and it seems pretty straight-forward to
> me. I don't really understand why this is so controversial.

I'm not arguing that the idea behind this patch set is necessarily bad.
Quite the contrary, it does look interesting to me. I'm just saying that
IMO it can't replace hard/soft limits. It probably could if it was
possible to shrink buffers, but I don't think it's feasible, even
theoretically. That's why I propose not to change the behavior of the
existing per memcg tcp limit at all. And frankly I don't get why you are
so keen on simplifying it. You say it's a "crapload of boilerplate
code". Well, I don't see how it is - it just replicates global knobs and
I don't see how it could be done in a better way. The code is hidden
behind jump labels, so the overhead is zero if it isn't used. If you
really dislike this code, we can isolate it under a separate config
option. But all right, I don't rule out the possibility that the code
could be simplified. If you do that w/o breaking it, that'll be OK to
me, but I don't see why it should be related to this particular patch
set.

> 
> The *next* step would be to figure out whether we can actually
> *reclaim* memory in the network subsystem--shrink windows and steal
> buffers back--and that might even be an avenue to replace tcp window
> limits. But it's not necessary for *this* patch series to be useful.

Again, I don't think we can *reclaim* network memory, but you're right.

> 
> > > So this seemed like a good way to prove a new mechanism before rolling
> > > it out to every single Linux setup, rather than switch everybody over
> > > after the limited scope testing I can do as a developer on my own.
> > > 
> > > Keep in mind that my patches are not committing anything in terms of
> > > interface, so we retain all the freedom to fix and tune the way this
> > > is implemented, including the freedom to re-add tcp window limits in
> > > case the pressure balancing is not a comprehensive solution.
> > 
> > I really dislike this kind of proof. It looks like you're trying to
> > push something you think is right covertly, w/o having a proper
> > discussion with networking people and then say that it just works
> > and hence should be done globally, but what if it won't? Revert it?
> > We already have a lot of dubious stuff in memcg that should be
> > reverted, so let's please try to avoid this kind of mistakes in
> > future. Note, I say "w/o having a proper discussion with networking
> > people", because I don't think they will really care *unless* you
> > change the global logic, simply because most of them aren't very
> > interested in memcg AFAICS.
> 
> Come on, Dave is the first To and netdev is CC'd. They might not care
> about memcg, but "pushing things covertly" is a bit of a stretch.

Sorry if it sounded rude to you. I just look back at my experience
patching slab internals to make kmem accountable, and AFAICS Christoph
didn't really care about *what* I was doing, he only cared about the
global case - if there was no performance degradation when kmemcg was
disabled, he was usually fine with it, even if from the memcg pov it was
a crap.

Anyway, I can't force you to patch the global case first or
simultaneously with the memcg case, so let's just hope I'm a bit too
overcautious.

> 
> > That effectively means you loose a chance to listen to networking
> > experts, who could point you at design flaws and propose an improvement
> > right away. Let's please not miss such an opportunity. You said that
> > you'd seen this problem happen w/o cgroups, so you have a use case that
> > might need fixing at the global level. IMO it shouldn't be difficult to
> > prepare an RFC patch for the global case first and see what people think
> > about it.
> 
> No, the problem we are running into is when network memory is not
> tracked per cgroup. The lack of containment means that the socket
> memory consumption of individual cgroups can trigger system OOM.
> 
> We tried using the per-memcg tcp limits, and that prevents the OOMs
> for sure, but it's horrendous for network performance. There is no
> "stop growing" phase, it just keeps going full throttle until it hits
> the wall hard.
> 
> Now, we could probably try to replicate the global knobs and add a
> per-memcg soft limit. But you know better than anyone else how hard it
> is to estimate the overall workingset size of a workload, and the
> margins on containerized loads are razor-thin. Performance is much
> more sensitive to input errors, and often times parameters must be
> adjusted continuously during the runtime of a workload. It'd be
> disasterous to rely on yet more static, error-prone user input here.

Yeah, but the dynamic approach proposed in your patch set doesn't
guarantee we won't hit OOM in memcg due to overgrown buffers. It just
reduces this possibility. Of course, memcg OOM is far not as disastrous
as the global one, but still it usually means the workload breakage.

The static approach is error-prone for sure, but it has existed for
years and worked satisfactory AFAIK.

> 
> What all this means to me is that fixing it on the cgroup level has
> higher priority. But it also means that once we figured it out under
> such a high-pressure environment, it's much easier to apply to the
> global case and potentially replace the soft limit there.
> 
> This seems like a better approach to me than starting globally, only
> to realize that the solution is not workable for cgroups and we need
> yet something else.
> 

Are we in rush? I think if you try your approach at the global level and
fail, it's still good, because it will probably give us all a better
understanding of the problem. If you successfully fix the global case,
but then realize that it doesn't fit memcg, it's even better, because
you actually fixed a problem. If you patch both global and memcg cases,
it's perfect.

But of course, that's my understanding and I may be mistaken. Let's hope
you're right.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
