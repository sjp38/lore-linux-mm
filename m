Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 8F1A16B004D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 19:16:19 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1515286yen.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 16:16:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F5C602B.4050806@parallels.com>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	<1331325556-16447-4-git-send-email-ssouhlal@FreeBSD.org>
	<4F5C602B.4050806@parallels.com>
Date: Tue, 13 Mar 2012 16:16:18 -0700
Message-ID: <CABCjUKBUQ7QS-pJbzrN=8_AFj20uP+dgOH44AWfK4ZecpprybA@mail.gmail.com>
Subject: Re: [PATCH v2 03/13] memcg: Uncharge all kmem when deleting a cgroup.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@hansenpartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On Sun, Mar 11, 2012 at 12:19 AM, Glauber Costa <glommer@parallels.com> wro=
te:
> On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
>>
>> Signed-off-by: Suleiman Souhlal<suleiman@google.com>
>> ---
>> =A0mm/memcontrol.c | =A0 31 ++++++++++++++++++++++++++++++-
>> =A01 files changed, 30 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index e6fd558..6fbb438 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -382,6 +382,7 @@ static void mem_cgroup_get(struct mem_cgroup *memcg)=
;
>> =A0static void mem_cgroup_put(struct mem_cgroup *memcg);
>> =A0static void memcg_kmem_init(struct mem_cgroup *memcg,
>> =A0 =A0 =A0struct mem_cgroup *parent);
>> +static void memcg_kmem_move(struct mem_cgroup *memcg);
>>
>> =A0static inline bool
>> =A0mem_cgroup_test_flag(const struct mem_cgroup *memcg, enum memcg_flags
>> flag)
>> @@ -3700,6 +3701,7 @@ static int mem_cgroup_force_empty(struct mem_cgrou=
p
>> *memcg, bool free_all)
>> =A0 =A0 =A0 =A0int ret;
>> =A0 =A0 =A0 =A0int node, zid, shrink;
>> =A0 =A0 =A0 =A0int nr_retries =3D MEM_CGROUP_RECLAIM_RETRIES;
>> + =A0 =A0 =A0 unsigned long usage;
>> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D memcg->css.cgroup;
>>
>> =A0 =A0 =A0 =A0css_get(&memcg->css);
>> @@ -3719,6 +3721,8 @@ move_account:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* This is for making all *used* pages to=
 be on LRU. */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru_add_drain_all();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0drain_all_stock_sync(memcg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!free_all)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_kmem_move(memcg);
>
> Any reason we're not moving kmem charges when free_all is set as well?

Because the slab moving code expects to be synchronized with
allocations (and itself). We can't call it when there are still tasks
in the cgroup.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
