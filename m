Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DB3F06B00E9
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 14:00:42 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so230166lbb.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:00:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120418122448.GB1771@cmpxchg.org>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
	<20120418122448.GB1771@cmpxchg.org>
Date: Wed, 18 Apr 2012 11:00:40 -0700
Message-ID: <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Apr 18, 2012 at 5:24 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Tue, Apr 17, 2012 at 09:37:46AM -0700, Ying Han wrote:
>> The "soft_limit" was introduced in memcg to support over-committing the
>> memory resource on the host. Each cgroup configures its "hard_limit" whe=
re
>> it will be throttled or OOM killed by going over the limit. However, the
>> cgroup can go above the "soft_limit" as long as there is no system-wide
>> memory contention. So, the "soft_limit" is the kernel mechanism for
>> re-distributing system spare memory among cgroups.
>>
>> This patch reworks the softlimit reclaim by hooking it into the new glob=
al
>> reclaim scheme. So the global reclaim path including direct reclaim and
>> background reclaim will respect the memcg softlimit.
>>
>> v3..v2:
>> 1. rebase the patch on 3.4-rc3
>> 2. squash the commits of replacing the old implementation with new
>> implementation into one commit. This is to make sure to leave the tree
>> in stable state between each commit.
>> 3. removed the commit which changes the nr_to_reclaim for global reclaim
>> case. The need of that patch is not obvious now.
>>
>> Note:
>> 1. the new implementation of softlimit reclaim is rather simple and firs=
t
>> step for further optimizations. there is no memory pressure balancing be=
tween
>> memcgs for each zone, and that is something we would like to add as foll=
ow-ups.
>>
>> 2. this patch is slightly different from the last one posted from Johann=
es
>> http://comments.gmane.org/gmane.linux.kernel.mm/72382
>> where his patch is closer to the reverted implementation by doing hierar=
chical
>> reclaim for each selected memcg. However, that is not expected behavior =
from
>> user perspective. Considering the following example:
>>
>> root (32G capacity)
>> --> A (hard limit 20G, soft limit 15G, usage 16G)
>> =A0 =A0--> A1 (soft limit 5G, usage 4G)
>> =A0 =A0--> A2 (soft limit 10G, usage 12G)
>> --> B (hard limit 20G, soft limit 10G, usage 16G)
>>
>> Under global reclaim, we shouldn't add pressure on A1 although its paren=
t(A)
>> exceeds softlimit. This is what admin expects by setting softlimit to th=
e
>> actual working set size and only reclaim pages under softlimit if system=
 has
>> trouble to reclaim.
>
> Actually, this is exactly what the admin expects when creating a
> hierarchy, because she defines that A1 is a child of A and is
> responsible for the memory situation in its parent.

> That's the single point of having a hierarchy. =A0Why do you create them
> if you don't want their behaviour?

I agree with the hierarchical reclaim which pushing the pressure down
from A to A1 and A2. But that only apply naturally to hard_limit but
not soft_limit.

One of the use cases to create hierarchy is to get finer granularity
of accounting for subset of processes, and they share the same
hardlimit at the same time.

Imagine there were no A1 and A2 created and all the processes running
under A to start with. The problem with for that they all share a
single accounting and memcg naturally provide finer granularity
accounting by creating sub-cgroups under A. After setting
"use_hierarchy" to 1, the direct reclaim from A (A hits its
hard_limit) should also reclaim from A1 and A2 regardless of each
individual usage_in_bytes since both A1 and A2 contribute to A's
charge.

However, we need to be more selective for soft_limit since most users
setting it to protect the cgroup's working_set_size. We don't want to
reclaim from A1's anon pages while reclaiming from A2's cold page
cache pages could satisfy the page allocation.

Note, soft_limit setting is always optional not like hard_limit. Once
admin chooses to set it, he/she wants to protect the hot memory of
each cgroup.

>
> And A does not have its own pages (usage is just the sum of its
> children), what SHOULD its soft limit even mean in your example?

A does have pages on its LRU which are pages allocated for processes
running directly under A and also the re-parented pages after rmdir of
A1/A2. The softlimit of A will include both cases.

>
> If you had
>
> =A0 =A0A (hard 20G, usage 16G)
> =A0 =A0 =A0 A1 (soft =A05G, usage =A04G)
> =A0 =A0 =A0 A2 (soft 10G, usage 12G)
> =A0 =A0B (hard 20G, soft 10G, usage 16G)
>
> (i.e. no soft limit on A), you could reasonably make it so that on
> global reclaim, only A2 and B would get reclaimed, like you want it
> to, while still keeping the hierarchical properties of soft limits.

> If you want soft limits applied to leaf nodes only, don't set them
> anywhere else..?

No softlimit on A means leave it as default value:

unlimited (now) : then pages linked to A's lru will not get chance to
be reclaimed at all under softlimit reclaim.

0 (after this patch):  it will end up reclaiming from A's children always.

> Ultimately, we want to support nesting memcgs within containers. =A0For
> this reason, they need to be applied hierarchically, or the admin of
> the host does not have soft limit control over untrusted guest groups:
>
> =A0 =A0container A (hard 20G, soft 16G)
> =A0 =A0 =A0group A-1 (soft 100G)
> =A0 =A0container B (hard 20G, soft 16G)
> =A0 =A0 =A0group B-1
>
> In this case under global memory pressure, contrary to your claims, we
> actually do want to from reclaim A-1, not just from B-1. =A0Otherwise, a
> container could gain priority over another one by setting ridiculous
> soft limits.

This is a mis-configuration of softlimit assuming the machine capacity
< 100G. I am wondering if we should design the system to compromise
the mis-configuration with drawback of breaking the exception of
properly configured system.

> We have been at this point a couple times. =A0Could you please explain
> what you are trying to do in the first place, why you need
> hierarchies, why you configure them like you do?

The hierarchy is needed for sharing one hard_limit but also finer
granularity of accounting. The soft_limit is set to protect working
set for each cgroup of the system and it works purely like a filtering
and prioritize the reclaim order only after the whole system under
memory contention.

In my mind, soft_limit should be optional and admin only set them if
they know what they want to do with it. The main use case we use it
for now is to protect the working set and that is the exception when
they choose to set that.

--Ying

>
> Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
