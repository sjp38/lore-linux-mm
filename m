Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC656B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 05:30:59 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so5873373pad.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:30:58 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id l3si4450783pbq.44.2015.09.02.02.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 02:30:58 -0700 (PDT)
Date: Wed, 2 Sep 2015 12:30:39 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150902093039.GA30160@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
 <20150901123612.GB8810@dhcp22.suse.cz>
 <20150901134003.GD21226@esperanza>
 <20150901150119.GF8810@dhcp22.suse.cz>
 <20150901165554.GG21226@esperanza>
 <20150901183849.GA28824@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150901183849.GA28824@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[
  I'll try to summarize my point in one hunk instead of spreading it all
  over the e-mail, because IMO it's becoming a kind of difficult to
  follow. If you think that there's a question I dodge, please let me
  now and I'll try to address it separately.

  Also, adding Johannes to Cc (I noticed that I accidentally left him
  out), because this discussion seems to be fundamental and may affect
  our further steps dramatically.
]

On Tue, Sep 01, 2015 at 08:38:50PM +0200, Michal Hocko wrote:
> On Tue 01-09-15 19:55:54, Vladimir Davydov wrote:
> > On Tue, Sep 01, 2015 at 05:01:20PM +0200, Michal Hocko wrote:
> > > On Tue 01-09-15 16:40:03, Vladimir Davydov wrote:
> > > > On Tue, Sep 01, 2015 at 02:36:12PM +0200, Michal Hocko wrote:
> [...]
> > > > > How the fallback is implemented and whether trying other node before
> > > > > reclaiming from the preferred one is reasonable I dunno. This is for
> > > > > SLAB to decide. But ignoring GFP_NOWAIT for this path makes the behavior
> > > > > for memcg enabled setups subtly different. And that is bad.
> > > > 
> > > > Quite the contrary. Trying to charge memcg w/o __GFP_WAIT while
> > > > inspecting if a NUMA node has free pages makes SLAB behaviour subtly
> > > > differently: SLAB will walk over all NUMA nodes for nothing instead of
> > > > invoking memcg reclaim once a free page is found.
> > > 
> > > So you are saying that the SLAB kmem accounting in this particular path
> > > is suboptimal because the fallback mode doesn't retry local node with
> > > the reclaim enabled before falling back to other nodes?
> > 
> > I'm just pointing out some subtle behavior changes in slab you were
> > opposed to.
> 
> I guess we are still not at the same page here. If the slab has a subtle
> behavior (and from what you are saying it seems it has the same behavior
> at the global scope) then we should strive to fix it rather than making
> it more obscure just to not expose GFP_NOWAIT to memcg which is not
> handled properly currently wrt. high limit (more on that below) which
> was the primary motivation for the patch AFAIU.

Slab is a kind of abnormal alloc_pages user. By calling alloc_pages_node
with __GFP_THISNODE and w/o __GFP_WAIT before falling back to
alloc_pages with the caller's context, it does the job normally done by
alloc_pages itself. It's not what is done massively.

Leaving slab charge path as is looks really ugly to me. Look, slab
iterates over all nodes, inspecting if they have free pages and fails
even if they do due to the memcg constraint...

My point is that what slab does is a pretty low level thing, normal
users call alloc_pages or kmalloc with flags corresponding to their
context. Of course, there may be special users trying optimistically
GFP_NOWAIT, but they aren't massive, and that simplifies things for
memcg a lot. I mean if we can rely on the fact that the number of
GFP_NOWAIT allocations that can occur in a row is limited we can use
direct reclaim (like memory.high) and/or task_work reclaim to fix
GFP_NOWAIT failures. Otherwise, we have to mimic the global alloc with
most its heuristics. I don't think that copying those heuristics is the
right thing to do, because in memcg case the same problems may be
resolved much easier, because we don't actually experience real memory
shortage when hitting the limit.

Moreover, we already treat some flags not in the same way as in case of
slab for simplicity. E.g. we let __GFP_NOFAIL allocations go uncharged
instead of retrying infinitely. We ignore __GFP_THISNODE thing and we
just cannot take it into account. We ignore allocation order, because
that makes no sense for memcg.

To sum it up. Basically, there are two ways of handling kmemcg charges:

 1. Make the memcg try_charge mimic alloc_pages behavior.
 2. Make API functions (kmalloc, etc) work in memcg as if they were
    called from the root cgroup, while keeping interactions between the
    low level subsys (slab) and memcg private.

Way 1 might look appealing at the first glance, but at the same time it
is much more complex, because alloc_pages has grown over the years to
handle a lot of subtle situations that may arise on global memory
pressure, but impossible in memcg. What does way 1 give us then? We
can't insert try_charge directly to alloc_pages and have to spread its
calls all over the code anyway, so why is it better? Easier to use it in
places where users depend on buddy allocator peculiarities? There are
not many such users.

I understand that the idea of way 1 is to provide a well-defined memcg
API independent of the rest of the code, but that's just impossible. You
need special casing anyway. E.g. you need those get/put_kmem_cache
helpers, which exist solely for SLAB/SLUB. You need all this special
stuff for growing per-memcg array in list_lru and kmem_cache, which
exists solely for memcg-vs-list_lru and memcg-vs-slab interactions. We
even handle kmem_cache destruction on memcg offline differently for SLAB
and SLUB for performance reasons.

Way 2 gives us more space to maneuver IMO. SLAB/SLUB may do weird tricks
for optimization, but their API is well defined, so we just make kmalloc
work as expected while providing inter-subsys calls, like
memcg_charge_slab, for SLAB/SLUB that have their own conventions. You
mentioned kmem users that allocate memory using alloc_pages. There is an
API function for them too, alloc_kmem_pages. Everything behind the API
is hidden and may be done in such a way to achieve optimal performance.

Thanks,
Vladimir

> 
> > > I would consider it quite surprising as well even for the global case
> > > because __GFP_THISNODE doesn't wake up kswapd to make room on that node.
> > > 
> > > > You are talking about memcg/kmem accounting as if it were done in the > > > > buddy allocator on top of which the slab layer is built knowing nothing
> > > > about memcg accounting on the lower layer. That's not true and that
> > > > simply can't be true. Kmem accounting is implemented at the slab layer.
> > > > Memcg provides its memcg_charge_slab/uncharge methods solely for
> > > > slab core, so it's OK to have some calling conventions between them.
> > > > What we are really obliged to do is to preserve behavior of slab's
> > > > external API, i.e. kmalloc and friends.
> > > 
> > > I guess I understand what you are saying here but it sounds like special
> > > casing which tries to be clever because the current code understands
> > > both the lower level allocator and kmem charge paths to decide how to
> > 
> > What do you mean by saying "it understands the lower level allocator"?
> 
> I mean it requires/abuses special behavior from the page allocator like
> __GFP_THISNODE && !wait for the hot path. 
> 
> > AFAIK we have memcg callbacks only in special places, like page fault
> > handler or kmalloc.
> 
> But anybody might opt-in to be charged. I can see some other buffers
> which are even not accounted for right now will be charged in future.
> 
> > > juggle with them. This is imho bad and hard to maintain long term.
> > 
> > We already juggle. Just grep where and how we insert
> > mem_cgroup_try_charge.
> 
> We should always preserve the gfp context (at least its reclaim
> part). If we are not then it is a bug.
>  
> > > > > >  2. SLUB. Someone calls kmalloc and there is enough free high order
> > > > > >     pages. If there is no memcg limit, we will allocate a high order
> > > > > >     slab page, which is in accordance with SLUB internal logic. With
> > > > > >     memcg limit set, we are likely to fail to charge high order page
> > > > > >     (because we currently try to charge high order pages w/o __GFP_WAIT)
> > > > > >     and fallback on a low order page. The latter is unexpected and
> > > > > >     unjustified.
> > > > > 
> > > > > And this case very similar and I even argue that it shows more
> > > > > brokenness with your patch. The SLUB allocator has _explicitly_ asked
> > > > > for an allocation _without_ reclaim because that would be unnecessarily
> > > > > too costly and there is other less expensive fallback. But memcg would
> > > > 
> > > > You are ignoring the fact that, in contrast to alloc_pages, for memcg
> > > > there is practically no difference between charging a 4-order page or a
> > > > 1-order page.
> > > 
> > > But this is an implementation details which might change anytime in
> > > future.
> > 
> > The fact that memcg reclaim does not invoke compactor is indeed an
> > implementation detail, but how can it change?
> 
> Compaction is indeed not something memcg reclaim cares about right now
> or will care in foreseeable future. I meant something else. order-1 vs.
> ordern-N differ in the reclaim target which then controls the potential
> latency of the reclaim. The fact that order-1 and order-4 do not really
> make any difference _right now_ because of the large SWAP_CLUSTER_MAX is
> the implementation detail I was referring to.
>  
> > > > OTOH, using 1-order pages where we could go with 4-order
> > > > pages increases page fragmentation at the global level. This subtly
> > > > breaks internal SLUB optimization. Once again, kmem accounting is not
> > > > something staying aside from slab core, it's a part of slab core.
> > > 
> > > This is certainly true and it is what you get when you put an additional
> > > constrain on top of an existing one. You simply cannot get both the
> > > great performance _and_ a local memory restriction.
> > 
> > So what? We shouldn't even try?
> 
> Of course you can try. Then the question is what are costs/benefits
> (both performance and maintainability). I didn't say those two patches
> are incorrect (the original kmalloc gfp mask is obeyed).
> They just seem targeting a wrong layer IMO. Alternative solutions were
> not attempted and measured for typical workloads. If we find out that
> addressing GFP_NOWAIT at memcg level will be viable for most reasonable
> loads and corner cases are at least not causing runaways which would be
> hard to address then let's put workarounds where they are necessary.
> 
> > > > > be ignoring this with your patch AFAIU and break the optimization. There
> > > > > are other cases like that. E.g. THP pages are allocated without GFP_WAIT
> > > > > when defrag is disabled.
> > > > 
> > > > It might be wrong. If we can't find a continuous 2Mb page, we should
> > > > probably give up instead of calling compactor. For memcg it might be
> > > > better to reclaim some space for 2Mb page right now and map a 2Mb page
> > > > instead of reclaiming space for 512 4Kb pages a moment later, because in
> > > > memcg case there is absolutely no difference between reclaiming 2Mb for
> > > > a huge page and 2Mb for 512 4Kb pages.
> > > 
> > > Or maybe the whole reclaim just doesn't pay off because the TLB savings
> > > will never compensate for the reclaim. The defrag knob basically says
> > > that we shouldn't try to opportunistically prepare a room for the THP
> > > page.
> > 
> > And why is it called "defrag" then?
> 
> Do not ask me about the naming. If this was only about compaction then
> the allocator might be told about that by a special GFP flag. The memcg
> could be in line with that. But the point remains. If the defrag is
> a knob to make the page fault THP path lighter then no memcg reclaim is a
> reasonable to do.
>  
> [...]
> > > > Quoting my e-mail to Tejun explaining why using task_work won't help if
> > > > we don't fix SLAB/SLUB:
> > > > 
> > > > : Generally speaking, handing over reclaim responsibility to task_work
> > > > : won't help, because there might be cases when a process spends quite a
> > > > : lot of time in kernel invoking lots of GFP_KERNEL allocations before
> > > > : returning to userspace. Without fixing slab/slub, such a process will
> > > > : charge w/o __GFP_WAIT and therefore can exceed memory.high and reach
> > > > : memory.max. If there are no other active processes in the cgroup, the
> > > > : cgroup can stay with memory.high excess for a relatively long time
> > > > : (suppose the process was throttled in kernel), possibly hurting the rest
> > > > : of the system. What is worse, if the process happens to invoke a real
> > > > : GFP_NOWAIT allocation when it's about to hit the limit, it will fail.
> > > > 
> > > > For a kmalloc user that's completely unexpected.
> > > 
> > > We have the global reclaim which handles the global memory pressure. And
> > > until the hard limit is enforced I do not see what is the huge problem
> > > here. Sure we can have high limit in excess but that is to be expected.
> > 
> > What exactly is to be expected? Is it OK if memory.high is just ignored?
> 
> It is not OK to be ignored altogether. The high limit is where the
> throttling should start. And we currently do not handle GFP_NOWAIT which
> is something to be solved. We shouldn't remove GFP_NOWAIT callers as a
> workaround.
> 
> There are more things to do here. We can perform the reclaim from the
> delayed context where the direct reclaim is not allowed/requested. And
> we can start failing GFP_NOWAIT on an excessive high limit breach when
> the delayed reclaim doesn't catch up with the demand. This is basically
> what we do on the global level.
> If even this is not sufficient and the kernel allows for a lot of
> allocations in the single run, which would be something to look at in
> the first place, then we have global mechanisms to mitigate that.
> 
> memory.high is an opportunistic memory isolation. It doesn't guarantee a
> complete isolation. The hard limit is for that purpose.
> 
> > > Same as failing allocations for the hard limit enforcement.
> > 
> > If a kmem allocation fails, your app is likely to fail too. Nobody
> > expects write/read fail with ENOMEM if there seems to be enough
> > reclaimable memory. If we try to fix the GFP_NOWAIT problem only by
> > using task_work reclaim, it won't be a complete fix, because a failure
> > may still occur as I described above.
> 
> You cannot have a system which cannot tolerate failures and require
> memory restrictions. These two requirements simply go against each other.
> Moreover GPF_NOWAIT context is really light and should always have a
> fallback mode otherwise you get what you are saying - failures with
> reclaimable memory. And this is very much the case for the global case
> as well.
> 
> > > Maybe moving whole high limit reclaim to the delayed context is not what
> > > we will end up with and reduce this only for GFP_NOWAIT or other weak
> > > reclaim contexts. This is to be discussed of course.
> > 
> > Yeah, but w/o fixing kmalloc it may happen that *every* allocation will
> > be GFP_NOWAIT. It'd complicate the implementation.
> 
> OK, but that is the case for the global case already. MM resp. memcg has
> to say at when to stop it. The global case handles that at the page
> allocator layer and memcg should do something similar at the charge
> level.
> 
> [...]
> > > > What do you mean by saying "all over the place"? It's a fix for kmem
> > > > implementation, to be more exact for the part of it residing in the slab
> > > > core.
> > > 
> > > I meant into two slab allocators currently because of the implementation
> > > details which are spread into three different places - page allocator,
> > > memcg charging code and the respective slab allocator specific details.
> > 
> > If we remove kmem accounting, we will still have implementation details
> > spread over page allocator, reclaimer, rmap, memcg. Slab is not the
> > worst part of it IMO. Anyway, kmem accounting can't be implemented
> > solely in memcg.
> 
> The current state is quite complex already and making it even more
> complex by making allocation and charge context inconsistent is not really
> desirable.
>  
> > > > Everyone else, except a couple of kmem users issuing alloc_page
> > > > directly like threadinfo, will use kmalloc and know nothing what's going
> > > > on there and how all this accounting stuff is handled - they will just
> > > > use plain old convenient kmalloc, which works exactly as it does in the
> > > > root cgroup.
> > > 
> > > If we ever grow more users and charge more kernel memory then they might
> > > be doing similar assumptions and tweak allocation/charge context and we
> > > would end up in a bigger mess. It makes much more sense to have
> > > allocation and charge context consistent.
> > 
> > What new users? Why can't they just call kmalloc?
> 
> What about direct users of the page allocator. Why should they pay cost
> for more complex/expensive code paths when they do not need sub-page
> sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
