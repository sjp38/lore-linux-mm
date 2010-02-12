Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 887326B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 03:49:48 -0500 (EST)
Received: by ewy22 with SMTP id 22so831887ewy.10
        for <linux-mm@kvack.org>; Fri, 12 Feb 2010 00:49:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100212171948.16346836.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100212154857.f9d8f28e.kamezawa.hiroyu@jp.fujitsu.com>
	 <cc557aab1002120007v1dfdfac0te0c2a8b750919c15@mail.gmail.com>
	 <20100212171948.16346836.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 12 Feb 2010 10:49:45 +0200
Message-ID: <cc557aab1002120049v28322a29sbe11d7f049806115@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: share event counter rather than duplicate
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 12, 2010 at 10:19 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 12 Feb 2010 10:07:25 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
>> On Fri, Feb 12, 2010 at 8:48 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > Memcg has 2 eventcountes which counts "the same" event. Just usages ar=
e
>> > different from each other. This patch tries to reduce event counter.
>> >
>> > This patch's logic uses "only increment, no reset" new_counter and mas=
ks for each
>> > checks. Softlimit chesk was done per 1000 events. So, the similar chec=
k
>> > can be done by !(new_counter & 0x3ff). Threshold check was done per 10=
0
>> > events. So, the similar check can be done by (!new_counter & 0x7f)
>>
>> IIUC, with this change we have to check counter after each update,
>> since we check
>> for exact value.
>
> Yes.
>> So we have to move checks to mem_cgroup_charge_statistics() or
>> call them after each statistics charging. I'm not sure how it affects
>> performance.
>>
>
> My patch 1/2 does it.
>
> But hmm, move-task does counter updates in asynchronous manner. Then, the=
re are
> bug. I'll add check in the next version.
>
> Maybe calling update_tree and threshold_check at the end of mova_task is
> better. Does thresholds user take care of batched-move manner in task_mov=
e ?
> Should we check one by one ?

No. mem_cgroup_threshold() at mem_cgroup_move_task() is enough.

But... Is task moving a critical path? If no, It's, probably, cleaner to ch=
eck
everything at mem_cgroup_charge_statistics().

> (Maybe there will be another trouble when we handle hugepages...)

Yes, hugepages support requires more testing.

> Thanks,
> -Kame
>
>
>> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
>> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > ---
>> > =C2=A0mm/memcontrol.c | =C2=A0 36 ++++++++++++------------------------
>> > =C2=A01 file changed, 12 insertions(+), 24 deletions(-)
>> >
>> > Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
>> > +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
>> > @@ -63,8 +63,8 @@ static int really_do_swap_account __init
>> > =C2=A0#define do_swap_account =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0(0)
>> > =C2=A0#endif
>> >
>> > -#define SOFTLIMIT_EVENTS_THRESH (1000)
>> > -#define THRESHOLDS_EVENTS_THRESH (100)
>> > +#define SOFTLIMIT_EVENTS_THRESH (0x3ff) /* once in 1024 */
>> > +#define THRESHOLDS_EVENTS_THRESH (0x7f) /* once in 128 */
>> >
>> > =C2=A0/*
>> > =C2=A0* Statistics for memory cgroup.
>> > @@ -79,10 +79,7 @@ enum mem_cgroup_stat_index {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_PGPGIN_COUNT, =C2=A0 /* # o=
f pages paged in */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_PGPGOUT_COUNT, =C2=A0/* # o=
f pages paged out */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swa=
pped out */
>> > - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on eac=
h page in/out.
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used by =
soft limit implementation */
>> > - =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_THRESHOLDS, /* decrements on ea=
ch page in/out.
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used by =
threshold implementation */
>> > + =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_EVENTS, =C2=A0 =C2=A0 =C2=A0/* incre=
mented by 1 at pagein/pageout */
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0MEM_CGROUP_STAT_NSTATS,
>> > =C2=A0};
>> > @@ -394,16 +391,12 @@ mem_cgroup_remove_exceeded(struct mem_cg
>> >
>> > =C2=A0static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
>> > =C2=A0{
>> > - =C2=A0 =C2=A0 =C2=A0 bool ret =3D false;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0s64 val;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGRO=
UP_STAT_SOFTLIMIT]);
>> > - =C2=A0 =C2=A0 =C2=A0 if (unlikely(val < 0)) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 this_cpu_write(mem-=
>stat->count[MEM_CGROUP_STAT_SOFTLIMIT],
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SOFTLIMIT_EVENTS_THRESH);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D true;
>> > - =C2=A0 =C2=A0 =C2=A0 }
>> > - =C2=A0 =C2=A0 =C2=A0 return ret;
>> > + =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGRO=
UP_EVENTS]);
>> > + =C2=A0 =C2=A0 =C2=A0 if (unlikely(!(val & SOFTLIMIT_EVENTS_THRESH)))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;
>> > + =C2=A0 =C2=A0 =C2=A0 return false;
>> > =C2=A0}
>> >
>> > =C2=A0static void mem_cgroup_update_tree(struct mem_cgroup *mem, struc=
t page *page)
>> > @@ -542,8 +535,7 @@ static void mem_cgroup_charge_statistics
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__this_cpu_inc(=
mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0else
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__this_cpu_inc(=
mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
>> > - =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT=
_SOFTLIMIT]);
>> > - =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT=
_THRESHOLDS]);
>> > + =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(mem->stat->count[MEM_CGROUP_EVEN=
TS]);
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0preempt_enable();
>> > =C2=A0}
>> > @@ -3211,16 +3203,12 @@ static int mem_cgroup_swappiness_write(s
>> >
>> > =C2=A0static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
>> > =C2=A0{
>> > - =C2=A0 =C2=A0 =C2=A0 bool ret =3D false;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0s64 val;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGRO=
UP_STAT_THRESHOLDS]);
>> > - =C2=A0 =C2=A0 =C2=A0 if (unlikely(val < 0)) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 this_cpu_write(mem-=
>stat->count[MEM_CGROUP_STAT_THRESHOLDS],
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 THRESHOLDS_EVENTS_THRESH);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D true;
>> > - =C2=A0 =C2=A0 =C2=A0 }
>> > - =C2=A0 =C2=A0 =C2=A0 return ret;
>> > + =C2=A0 =C2=A0 =C2=A0 val =3D this_cpu_read(mem->stat->count[MEM_CGRO=
UP_EVENTS]);
>> > + =C2=A0 =C2=A0 =C2=A0 if (unlikely(!(val & THRESHOLDS_EVENTS_THRESH))=
)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;
>> > + =C2=A0 =C2=A0 =C2=A0 return false;
>> > =C2=A0}
>> >
>> > =C2=A0static void __mem_cgroup_threshold(struct mem_cgroup *memcg, boo=
l swap)
>> >
>> >
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
