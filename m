Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D18E66B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 08:24:53 -0400 (EDT)
Received: by bwz17 with SMTP id 17so3255984bwz.14
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 05:24:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110610110412.GE4110@tiehlicka.suse.cz>
References: <20110609093045.1f969d30.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610081218.GC4832@tiehlicka.suse.cz>
	<20110610173958.d9ab901c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610090802.GB4110@tiehlicka.suse.cz>
	<20110610185952.a07b968f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610110412.GE4110@tiehlicka.suse.cz>
Date: Fri, 10 Jun 2011 21:24:51 +0900
Message-ID: <BANLkTingsPiS81KEkOb6+eKdz=2UMUHmQg@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH v3] memcg: fix behavior of per cpu charge cache draining.
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>

2011/6/10 Michal Hocko <mhocko@suse.cz>:
> On Fri 10-06-11 18:59:52, KAMEZAWA Hiroyuki wrote:
>> On Fri, 10 Jun 2011 11:08:02 +0200
>> Michal Hocko <mhocko@suse.cz> wrote:
>>
>> > On Fri 10-06-11 17:39:58, KAMEZAWA Hiroyuki wrote:
>> > > On Fri, 10 Jun 2011 10:12:19 +0200
>> > > Michal Hocko <mhocko@suse.cz> wrote:
>> > >
>> > > > On Thu 09-06-11 09:30:45, KAMEZAWA Hiroyuki wrote:
>> > [...]
>> > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> > > > > index bd9052a..3baddcb 100644
>> > > > > --- a/mm/memcontrol.c
>> > > > > +++ b/mm/memcontrol.c
>> > > > [...]
>> > > > > =A0static struct mem_cgroup_per_zone *
>> > > > > =A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
>> > > > > @@ -1670,8 +1670,6 @@ static int mem_cgroup_hierarchical_reclaim=
(struct mem_cgroup *root_mem,
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim =3D mem_cgroup_select_victim(=
root_mem);
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (victim =3D=3D root_mem) {
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;
>> > > > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop >=3D 1)
>> > > > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_=
all_stock_async();
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop >=3D 2) {
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*=
 If we have not been able to reclaim
>> > > > > @@ -1723,6 +1721,7 @@ static int mem_cgroup_hierarchical_reclaim=
(struct mem_cgroup *root_mem,
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retu=
rn total;
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (mem_cgroup_margin(root_me=
m))
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return total;
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 drain_all_stock_async(root_mem);
>> > > > > =A0 =A0 =A0 }
>> > > > > =A0 =A0 =A0 return total;
>> > > > > =A0}
>> > > >
>> > > > I still think that we pointlessly reclaim even though we could hav=
e a
>> > > > lot of pages pre-charged in the cache (the more CPUs we have the m=
ore
>> > > > significant this might be).
>> > >
>> > > The more CPUs, the more scan cost for each per-cpu memory, which mak=
es
>> > > cache-miss.
>> > >
>> > > I know placement of drain_all_stock_async() is not big problem on my=
 host,
>> > > which has 2socket/8core cpus. But, assuming 1000+ cpu host,
>> >
>> > Hmm, it really depends what you want to optimize for. Reclaim path is
>> > already slow path and cache misses, while not good, are not the most
>> > significant issue, I guess.
>> > What I would see as a much bigger problem is that there might be a lot
>> > of memory pre-charged at those per-cpu caches. Falling into a reclaim
>> > costs us much more IMO and we can evict something that could be useful
>> > for no good reason.
>> >
>>
>> It's waste of time to talk this kind of things without the numbers.
>>
>> ok, I don't change the caller's logic. Discuss this when someone gets
>> number of LARGE smp box.
>
> Sounds reasonable.
>
> [..,]
>> please test/ack if ok.
>
> see comment bellow.
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
> [...]
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index bd9052a..75713cb 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -359,7 +359,7 @@ enum charge_type {
>> =A0static void mem_cgroup_get(struct mem_cgroup *mem);
>> =A0static void mem_cgroup_put(struct mem_cgroup *mem);
>> =A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
>> -static void drain_all_stock_async(void);
>> +static void drain_all_stock_async(struct mem_cgroup *mem);
>>
>> =A0static struct mem_cgroup_per_zone *
>> =A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
>> @@ -1670,8 +1670,7 @@ static int mem_cgroup_hierarchical_reclaim(struct =
mem_cgroup *root_mem,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim =3D mem_cgroup_select_victim(root_mem=
);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (victim =3D=3D root_mem) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop >=3D 1)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_stoc=
k_async();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_stock_async(root_mem=
);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop >=3D 2) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we h=
ave not been able to reclaim
>
> This still doesn't prevent from direct reclaim even though we have freed
> enough pages from pcp caches. Should I post it as a separate patch?
>

yes. please in different thread. Maybe moving this out of loop will
make sense. (And I have a cleanup patch for this loop. I'll do that
when I post it later, anyway)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
