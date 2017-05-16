Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 302AE6B02EE
	for <linux-mm@kvack.org>; Tue, 16 May 2017 18:03:05 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j58so61924814qtc.2
        for <linux-mm@kvack.org>; Tue, 16 May 2017 15:03:05 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id m44si113045qtm.130.2017.05.16.15.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 15:03:04 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id j13so22618915qta.3
        for <linux-mm@kvack.org>; Tue, 16 May 2017 15:03:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170512164206.GA22367@cmpxchg.org>
References: <1494530183-30808-1-git-send-email-guro@fb.com>
 <1494555922.21563.1.camel@gmail.com> <20170512164206.GA22367@cmpxchg.org>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 17 May 2017 08:03:03 +1000
Message-ID: <CAKTCnz=vj9-C2-XPcijB=fZOVVdxvqZvLEA93xXtRZmF+y3-Lg@mail.gmail.com>
Subject: Re: [PATCH] mm: per-cgroup memory reclaim stats
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sat, May 13, 2017 at 2:42 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Fri, May 12, 2017 at 12:25:22PM +1000, Balbir Singh wrote:
>> On Thu, 2017-05-11 at 20:16 +0100, Roman Gushchin wrote:
>> > The meaning of each value is the same as for global counters,
>> > available using /proc/vmstat.
>> >
>> > Also, for consistency, rename mem_cgroup_count_vm_event() to
>> > count_memcg_event_mm().
>> >
>>
>> I still prefer the mem_cgroup_count_vm_event() name, or memcg_count_vm_event(),
>> the namespace upfront makes it easier to parse where to look for the the
>> implementation and also grep. In any case the rename should be independent
>> patch, but I don't like the name you've proposed.
>
> The memory controller is no longer a tacked-on feature to the VM - the
> entire reclaim path is designed around cgroups at this point. The
> namespacing is just cumbersome and doesn't add add any value, IMO.
>
> This name is also more consistent with the stats interface, where we
> use nodes, zones, memcgs all equally to describe scopes/containers:
>
> inc_node_state(), inc_zone_state(), inc_memcg_state()
>

I don't have a very strong opinion, but I find memcg_* easier to parse
than inc_memcg_*
If memcg is going to be present everywhere we may consider abstracting
them inside
the main routines

>> > @@ -357,6 +357,17 @@ static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
>> >  }
>> >  struct mem_cgroup *mem_cgroup_from_id(unsigned short id);
>> >
>> > +static inline struct mem_cgroup *lruvec_memcg(struct lruvec *lruvec)
>>
>> mem_cgroup_from_lruvec()?
>
> This name is consistent with other lruvec accessors such as
> lruvec_pgdat() and lruvec_lru_size() etc.
>

lruvec_ being the namespace, the same comment as above.

>> > @@ -1741,11 +1748,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>> >
>> >     spin_lock_irq(&pgdat->lru_lock);
>> >
>> > -   if (global_reclaim(sc)) {
>> > -           if (current_is_kswapd())
>> > +   if (current_is_kswapd()) {
>> > +           if (global_reclaim(sc))
>> >                     __count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
>> > -           else
>> > +           count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
>> > +                              nr_reclaimed);
>>
>> Has the else gone missing? What happens if it's global_reclaim(), do
>> we still account the count in memcg?
>>
>> > +   } else {
>> > +           if (global_reclaim(sc))
>> >                     __count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
>> > +           count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
>> > +                              nr_reclaimed);
>>
>> It sounds like memcg accumlates both global and memcg reclaim driver
>> counts -- is this what we want?
>
> Yes.
>
> Consider a fully containerized system that is using only memory.low
> and thus exclusively global reclaim to enforce the partitioning, NOT
> artificial limits and limit reclaim. In this case, we still want to
> know how much reclaim activity each group is experiencing.

But its also confusing to see memcg.stat's value being greater
than the global value? At-least for me. For example PGSTEAL_DIRECT
inside a memcg > global value of PGSTEAL_DIRECT. Do we make
memcg.stat values sum of all impact on memcg or local to memcg?

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
