Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 055586B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 13:02:56 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so2251743lbj.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 10:02:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABEgKgrXqbF8XBc6vHa2b5KQe9E7_+WODvq3hE0vaT0Eyxo5=w@mail.gmail.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
	<4F9A375D.7@jp.fujitsu.com>
	<CALWz4iyiM-CFgVaHiE1Lgd1ZwJzHwY3tx9XX6HeDPUV_wVPAtQ@mail.gmail.com>
	<CABEgKgrXqbF8XBc6vHa2b5KQe9E7_+WODvq3hE0vaT0Eyxo5=w@mail.gmail.com>
Date: Mon, 30 Apr 2012 10:02:54 -0700
Message-ID: <CALWz4ix_rVpgzDme06f2U44EaqWcZKCEb0ueByh1-dSmbaO1jA@mail.gmail.com>
Subject: Re: [RFC][PATCH 9/9 v2] memcg: never return error at pre_destroy()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Apr 27, 2012 at 5:25 PM, Hiroyuki Kamezawa
<kamezawa.hiroyuki@gmail.com> wrote:
> On Sat, Apr 28, 2012 at 6:28 AM, Ying Han <yinghan@google.com> wrote:
>> On Thu, Apr 26, 2012 at 11:06 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> When force_empty() called by ->pre_destroy(), no memory reclaim happens
>>> and it doesn't take very long time which requires signal_pending() chec=
k.
>>> And if we return -EINTR from pre_destroy(), cgroup.c show warning.
>>>
>>> This patch removes signal check in force_empty(). By this, ->pre_destro=
y()
>>> returns success always.
>>>
>>> Note: check for 'cgroup is empty' remains for force_empty interface.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> ---
>>> =A0mm/hugetlb.c =A0 =A0| =A0 10 +---------
>>> =A0mm/memcontrol.c | =A0 14 +++++---------
>>> =A02 files changed, 6 insertions(+), 18 deletions(-)
>>>
>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>> index 4dd6b39..770f1642 100644
>>> --- a/mm/hugetlb.c
>>> +++ b/mm/hugetlb.c
>>> @@ -1922,20 +1922,12 @@ int hugetlb_force_memcg_empty(struct cgroup *cg=
roup)
>>> =A0 =A0 =A0 =A0int ret =3D 0, idx =3D 0;
>>>
>>> =A0 =A0 =A0 =A0do {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* see memcontrol.c::mem_cgroup_force_emp=
ty() */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cgroup_task_count(cgroup)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|| !list_empty(&cgroup->=
children)) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EBUSY;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the task doing the cgroup_rmdir g=
ot a signal
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we don't really need to loop till th=
e hugetlb resource
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* usage become zero.
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (signal_pending(current)) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINTR;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_hstate(h) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&hugetlb_lock)=
;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry(page=
, &h->hugepage_activelist, lru) {
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 2715223..ee350c5 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -3852,8 +3852,6 @@ static int mem_cgroup_force_empty_list(struct mem=
_cgroup *memcg,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_move_parent(page, pc,=
 memcg, GFP_KERNEL);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret =3D=3D -ENOMEM || ret =3D=3D -EIN=
TR)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret =3D=3D -EBUSY || ret =3D=3D -EIN=
VAL) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* found lock contention=
 or "pc" is obsolete. */
>>> @@ -3863,7 +3861,7 @@ static int mem_cgroup_force_empty_list(struct mem=
_cgroup *memcg,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0busy =3D NULL;
>>> =A0 =A0 =A0 =A0}
>>>
>>> - =A0 =A0 =A0 if (!ret && !list_empty(list))
>>> + =A0 =A0 =A0 if (!loop)
>>
>> This looks a bit strange to me... why we make the change ?
>>
> Ah, I should this move to an independet patch.
> Because we don't have -ENOMEM path to exit loop, the return value of
> this function
> is
> =A00 (if loop !=3D0 this means lru is empty under the lru lock )
> =A0-EBUSY (if loop=3D=3D 0)

>
> I'll move this part out as an independent clean up patch

Thanks ~

--Ying

> thanks,
> -kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
