Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E54596B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 02:06:03 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p8165wIL017640
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 23:05:58 -0700
Received: from qyk30 (qyk30.prod.google.com [10.241.83.158])
	by hpaq1.eem.corp.google.com with ESMTP id p8165c8i006170
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 23:05:56 -0700
Received: by qyk30 with SMTP id 30so1026553qyk.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2011 23:05:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110830084245.GC13061@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110808124333.GA31739@redhat.com>
	<20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20110829155113.GA21661@redhat.com>
	<20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830070424.GA13061@redhat.com>
	<20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830084245.GC13061@redhat.com>
Date: Wed, 31 Aug 2011 23:05:51 -0700
Message-ID: <CALWz4iyXbrgcrZEOsgvvW9mu6fr7Qwbn2d1FR_BVw6R_pMZPsQ@mail.gmail.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 30, 2011 at 1:42 AM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> On Tue, Aug 30, 2011 at 04:20:50PM +0900, KAMEZAWA Hiroyuki wrote:
>> On Tue, 30 Aug 2011 09:04:24 +0200
>> Johannes Weiner <jweiner@redhat.com> wrote:
>>
>> > On Tue, Aug 30, 2011 at 10:12:33AM +0900, KAMEZAWA Hiroyuki wrote:
>> > > @@ -1710,11 +1711,18 @@ static void mem_cgroup_record_scanstat(s
>> > > =A0 spin_lock(&memcg->scanstat.lock);
>> > > =A0 __mem_cgroup_record_scanstat(memcg->scanstat.stats[context], rec=
);
>> > > =A0 spin_unlock(&memcg->scanstat.lock);
>> > > -
>> > > - memcg =3D rec->root;
>> > > - spin_lock(&memcg->scanstat.lock);
>> > > - __mem_cgroup_record_scanstat(memcg->scanstat.rootstats[context], r=
ec);
>> > > - spin_unlock(&memcg->scanstat.lock);
>> > > + cgroup =3D memcg->css.cgroup;
>> > > + do {
>> > > + =A0 =A0 =A0 =A0 spin_lock(&memcg->scanstat.lock);
>> > > + =A0 =A0 =A0 =A0 __mem_cgroup_record_scanstat(
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->scanstat.hierarchy_stats[co=
ntext], rec);
>> > > + =A0 =A0 =A0 =A0 spin_unlock(&memcg->scanstat.lock);
>> > > + =A0 =A0 =A0 =A0 if (!cgroup->parent)
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > > + =A0 =A0 =A0 =A0 cgroup =3D cgroup->parent;
>> > > + =A0 =A0 =A0 =A0 memcg =3D mem_cgroup_from_cont(cgroup);
>> > > + } while (memcg->use_hierarchy && memcg !=3D rec->root);
>> >
>> > Okay, so this looks correct, but it sums up all parents after each
>> > memcg scanned, which could have a performance impact. =A0Usually,
>> > hierarchy statistics are only summed up when a user reads them.
>> >
>> Hmm. But sum-at-read doesn't work.
>>
>> Assume 3 cgroups in a hierarchy.
>>
>> =A0 =A0 =A0 A
>> =A0 =A0 =A0 =A0/
>> =A0 =A0 =A0 B
>> =A0 =A0 =A0/
>> =A0 =A0 C
>>
>> C's scan contains 3 causes.
>> =A0 =A0 =A0 C's scan caused by limit of A.
>> =A0 =A0 =A0 C's scan caused by limit of B.
>> =A0 =A0 =A0 C's scan caused by limit of C.
>>
>> If we make hierarchy sum at read, we think
>> =A0 =A0 =A0 B's scan_stat =3D B's scan_stat + C's scan_stat
>> But in precice, this is
>>
>> =A0 =A0 =A0 B's scan_stat =3D B's scan_stat caused by B +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 B's scan_stat caused by A +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C's scan_stat caused by C +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C's scan_stat caused by B +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C's scan_stat caused by A.
>>
>> In orignal version.
>> =A0 =A0 =A0 B's scan_stat =3D B's scan_stat caused by B +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C's scan_stat caused by B +
>>
>> After this patch,
>> =A0 =A0 =A0 B's scan_stat =3D B's scan_stat caused by B +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 B's scan_stat caused by A +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C's scan_stat caused by C +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C's scan_stat caused by B +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C's scan_stat caused by A.
>>
>> Hmm...removing hierarchy part completely seems fine to me.
>
> I see.
>
> You want to look at A and see whether its limit was responsible for
> reclaim scans in any children. =A0IMO, that is asking the question
> backwards. =A0Instead, there is a cgroup under reclaim and one wants to
> find out the cause for that. =A0Not the other way round.
>
> In my original proposal I suggested differentiating reclaim caused by
> internal pressure (due to own limit) and reclaim caused by
> external/hierarchical pressure (due to limits from parents).
>
> If you want to find out why C is under reclaim, look at its reclaim
> statistics. =A0If the _limit numbers are high, C's limit is the problem.
> If the _hierarchical numbers are high, the problem is B, A, or
> physical memory, so you check B for _limit and _hierarchical as well,
> then move on to A.
>
> Implementing this would be as easy as passing not only the memcg to
> scan (victim) to the reclaim code, but also the memcg /causing/ the
> reclaim (root_mem):
>
> =A0 =A0 =A0 =A0root_mem =3D=3D victim -> account to victim as _limit
> =A0 =A0 =A0 =A0root_mem !=3D victim -> account to victim as _hierarchical
>
> This would make things much simpler and more natural, both the code
> and the way of tracking down a problem, IMO.

This is pretty much the stats I am currently using for debugging the
reclaim patches. For example:

scanned_pages_by_system 0
scanned_pages_by_system_under_hierarchy 50989

scanned_pages_by_limit 0
scanned_pages_by_limit_under_hierarchy 0

"_system" is count under global reclaim, and "_limit" is count under
per-memcg reclaim.
"_under_hiearchy" is set if memcg is not the one triggering pressure.

So in the previous example:

>       A (root)
>        /
>       B
>      /
>     C

For cgroup C:
scanned_pages_by_system:
scanned_pages_by_system_under_hierarchy: # of pages scanned under
global memory pressure

scanned_pages_by_limit: # of pages scanned while C hits the limit
scanned_pages_by_limit_under_hierarchy: # of pages scanned while B
hits the limit

--Ying

>
>> > I don't get why this has to be done completely different from the way
>> > we usually do things, without any justification, whatsoever.
>> >
>> > Why do you want to pass a recording structure down the reclaim stack?
>>
>> Just for reducing number of passed variables.
>
> It's still sitting on bottom of the reclaim stack the whole time.
>
> With my proposal, you would only need to pass the extra root_mem
> pointer.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
