Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 6651D6B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 16:56:42 -0500 (EST)
Date: Tue, 17 Jan 2012 22:56:26 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
Message-ID: <20120117215626.GA2380@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
 <1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com>
 <20120112085904.GG24386@cmpxchg.org>
 <CALWz4iz3sQX+pCr19rE3_SwV+pRFhDJ7Lq-uJuYBq6u3mRU3AQ@mail.gmail.com>
 <20120113224424.GC1653@cmpxchg.org>
 <4F158418.2090509@gmail.com>
 <20120117145348.GA3144@cmpxchg.org>
 <CALWz4iwYpkP6Dfz+3NFXQK9ToaKdm8WCsbBmHRLVwRjVp0wjOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iwYpkP6Dfz+3NFXQK9ToaKdm8WCsbBmHRLVwRjVp0wjOQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Sha <handai.szj@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 17, 2012 at 12:25:31PM -0800, Ying Han wrote:
> On Tue, Jan 17, 2012 at 6:53 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Tue, Jan 17, 2012 at 10:22:16PM +0800, Sha wrote:
> >> IMHO, it may checking the cgroup's soft limit standalone without
> >> looking up its ancestors just as Ying said.
> >
> > Again, this would be a regression as soft limits have been applied
> > hierarchically forever.
> 
> If we are comparing it to the current implementation, agree that the
> soft reclaim is applied hierarchically. In the example above, A2 will
> be picked for soft reclaim while A is hitting its hard limit, which in
> turns reclaim from B1 and B2 regardless of their soft limit setting.
> However, I haven't convinced myself this is how we are gonna use the
> soft limit.

Of course I'm comparing it to the current implementation, this is what
I'm changing!

> The soft limit setting for each cgroup is a hit for applying pressure
> under memory contention. One way of setting the soft limit is based on
> the cgroup's working set size. Thus, we allow cgroup to grow above its
> soft limit with cold page cache unless there is a memory pressure
> comes from above. Under the hierarchical reclaim, we will exam the
> soft limit and only apply extra pressure to the ones above their soft
> limit. Here the same example:
> 
> root
> -> A (hard limit 20G, soft limit 12G, usage 20G)
>    -> A1 ( soft limit 2G,   usage 1G)
>    -> A2 ( soft limit 10G, usage 19G)
> 
>           ->B1 (soft limit 5G, usage 4G)
>           ->B2 (soft limit 5G, usage 15G)
> 
> If A is hitting its hard limit, we will reclaim all the children under
> A hierarchically but only adding extra pressure to the ones above
> their soft limits (A2, B2). Adding extra pressure to B1 will introduce
> known regression based on customer expectation since the 4G usage are
> hot memory.

I can only repeat myself: A has a soft limit set, so the customer
expects global pressure to arise sooner or later.  If that happens, A
will be soft-limit reclaimed hierarchically in the _existing code_.
That's how the soft limit currently works and I don't mean to change
it _with this patch_.  The customer has to expect that B1 can be
reclaimed as a consequence of the soft limit in A or A2 today, so I
don't know where this expectation of different behaviour should even
come from.  How can this be a regression?!

> I am not aware of how the existing soft reclaim being used, i bet
> there are not a lot. If we are making changes on the current
> implementation, we should also take the opportunity to think about the
> initial design as well. Thoughts?

I agree that these semantics should be up for debate.  And I think
changing it to something like you have in mind is indeed a good idea;
to not have soft limits apply hierarchically but instead follow down
the whole chain and only soft limit reclaim those that are themselves
above their soft limit.  But it's an entirely different matter!

This patch is supposed to do only two things: 1. refactor the soft
limit implementation, staying as close as possible/practical to the
current semantics and 2. fix the inconsistency that soft limits are
ignored when pressure does not originate at the root_mem_cgroup.  If
that is too much change in semantics I can easily ditch 2., I just
didn't see the use of maintaining an inconsistency that resulted
purely from the limitations of the current implementation by re-adding
more code and because I think that this would not be surprising
behaviour.  It would be as simple as adding an extra check in reclaim
that only minds soft limits upon global pressure:

	if (global_reclaim(sc) && mem_cgroup_over_soft_limit(root, memcg))
		/* resulting action */

and it would have nothing to do how soft limits are actually applied
once triggered.  I can include this in the next version, but it won't
fix the problem you seem to be having with the _existing_ behaviour.

I also don't think that my patch will get in the way of what you are
planning to do: in fact, you already have code that easily turns
mem_cgroup_over_soft_limit() into a non-hierarchical predicate.

Even more will change when you invert the soft limits to become actual
guarantees and skip reclaiming memcgs that are below their soft limits
but I don't think this patch is in the way of doing that, either.

I feel that these are all orthogonal changes.  So if possible, could
we take just one step at a time and leave hypothetical behaviour out
of it unless the proposed changes clearly get in the way of where we
agreed we want to go?

If I misunderstood everything completely and you actually believe this
patch will get in the way, could you tell me where and how?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
