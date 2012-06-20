Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 521136B0080
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 23:45:06 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so26762lbj.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 20:45:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120619112901.GC27816@cmpxchg.org>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
	<20120619112901.GC27816@cmpxchg.org>
Date: Tue, 19 Jun 2012 20:45:03 -0700
Message-ID: <CALWz4iyC2di8ueaHnCE-ENv5td4buK9DOWF5rLfN0bhR68bSAw@mail.gmail.com>
Subject: Re: [PATCH V5 1/5] mm: memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jun 19, 2012 at 4:29 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Mon, Jun 18, 2012 at 09:47:27AM -0700, Ying Han wrote:
>> This patch reverts all the existing softlimit reclaim implementations an=
d
>> instead integrates the softlimit reclaim into existing global reclaim lo=
gic.
>>
>> The new softlimit reclaim includes the following changes:
>>
>> 1. add function should_reclaim_mem_cgroup()
>>
>> Add the filter function should_reclaim_mem_cgroup() under the common fun=
ction
>> shrink_zone(). The later one is being called both from per-memcg reclaim=
 as
>> well as global reclaim.
>>
>> Today the softlimit takes effect only under global memory pressure. The =
memcgs
>> get free run above their softlimit until there is a global memory conten=
tion.
>> This patch doesn't change the semantics.
>
> But it's quite a performance regression. =A0Maybe it would be better
> after all to combine this change with 'make 0 the default'?
>
> Yes, I was the one asking for the changes to be separated, if
> possible, but I didn't mean regressing in between. =A0No forward
> dependencies in patch series, please.

Ok, I don't have problem to squash that patch in next time.

>
>> Under the global reclaim, we try to skip reclaiming from a memcg under i=
ts
>> softlimit. To prevent reclaim from trying too hard on hitting memcgs
>> (above softlimit) w/ only hard-to-reclaim pages, the reclaim priority is=
 used
>> to skip the softlimit check. This is a trade-off of system performance a=
nd
>> resource isolation.
>>
>> 2. "hierarchical" softlimit reclaim
>>
>> This is consistant to how softlimit was previously implemented, where th=
e
>> pressure is put for the whole hiearchy as long as the "root" of the hier=
archy
>> over its softlimit.
>>
>> This part is not in my previous posts, and is quite different from my
>> understanding of softlimit reclaim. After quite a lot of discussions wit=
h
>> Johannes and Michal, i decided to go with it for now. And this is design=
ed
>> to work with both trusted setups and untrusted setups.
>
> This may be really confusing to someone uninvolved reading the
> changelog as it doesn't have anything to do with what the patch
> actually does.
>
> It may be better to include past discussion outcomes in the
> introductary email of a series.

I will try to include some of the points from our last discussion in
the commit log.

>> @@ -870,8 +672,6 @@ static void memcg_check_events(struct mem_cgroup *me=
mcg, struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable();
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_threshold(memcg);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(do_softlimit))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_tree(memcg, =
page);
>> =A0#if MAX_NUMNODES > 1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(do_numainfo))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_inc(&memcg->numainfo_=
events);
>> @@ -922,6 +722,31 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struc=
t mm_struct *mm)
>> =A0 =A0 =A0 return memcg;
>> =A0}
>>
>> +bool should_reclaim_mem_cgroup(struct mem_cgroup *memcg)
>
> I'm not too fond of the magical name. =A0The API provides an information
> about soft limits, the decision should rest with vmscan.c.
>
> mem_cgroup_over_soft_limit() e.g.?

That is fine w/ me.

>
>> +{
>> + =A0 =A0 if (mem_cgroup_disabled())
>> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* We treat the root cgroup special here to always reclaim p=
ages.
>> + =A0 =A0 =A0* Now root cgroup has its own lru, and the only chance to r=
eclaim
>> + =A0 =A0 =A0* pages from it is through global reclaim. note, root cgrou=
p does
>> + =A0 =A0 =A0* not trigger targeted reclaim.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (mem_cgroup_is_root(memcg))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>
> With the soft limit at 0, the comment is no longer accurate because
> this check turns into a simple optimization. =A0We could check the
> res_counter soft limit, which would always result in the root group
> being above the limit, but we take the short cut.

For root group, my intention here is always reclaim pages from it
regardless of the softlimit setting. And the reason is exactly the one
in the comment. If the softlimit is set to 0 as default, I agree this
is then a short cut.

Anything you suggest that I need to change here?

>
>> + =A0 =A0 for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* This is global reclaim, stop at root cgroup=
 */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_is_root(memcg))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> I don't see why you add this check and the comment does not help.

The root cgroup would have softlimit set to 0 ( in most of the cases
), and not skipping root will make everyone reclaimable here.

Thank you for reviewing !

--Ying
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (res_counter_soft_limit_excess(&memcg->res)=
)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return false;
>> +}
>> +
>> =A0/**
>> =A0 * mem_cgroup_iter - iterate over memory cgroup hierarchy
>> =A0 * @root: hierarchy root

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
