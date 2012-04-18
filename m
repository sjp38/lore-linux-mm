Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id DB58C6B00EC
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 14:18:08 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so248701lbb.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:18:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F8E6BDC.6050703@jp.fujitsu.com>
References: <4F72EB84.7080000@jp.fujitsu.com>
	<4F72ED25.60307@jp.fujitsu.com>
	<CALWz4izNDGdGYmkJzHCRFspCk9QwoZtvRWpKmn=0YZRaVrcVAA@mail.gmail.com>
	<4F8E6BDC.6050703@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 11:18:06 -0700
Message-ID: <CALWz4iwWdjqhOFDsuJ2OFPH2v8pgjtttQfrrjkPT=aX9zu-5hQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/6] memcg: add pc_set_mem_cgroup_and_flags()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>

On Wed, Apr 18, 2012 at 12:23 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/04/18 6:17), Ying Han wrote:
>
>> On Wed, Mar 28, 2012 at 3:51 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> Consolidate a code for setting pc->mem_cgroup and USED bit which requir=
es smp_wmb().
>>> And remove a macro PCGF_NOCOPY_AT_SPLIT which isn't helpful to read cod=
e, now.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> ---
>>> =A0include/linux/page_cgroup.h | =A0 18 ++++++++++++++++++
>>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 18 ++++--------------
>>> =A02 files changed, 22 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
>>> index 92768cb..2707809 100644
>>> --- a/include/linux/page_cgroup.h
>>> +++ b/include/linux/page_cgroup.h
>>> @@ -1,6 +1,8 @@
>>> =A0#ifndef __LINUX_PAGE_CGROUP_H
>>> =A0#define __LINUX_PAGE_CGROUP_H
>>>
>>> +#include <linux/smp.h>
>>> +
>>> =A0enum {
>>> =A0 =A0 =A0 =A0/* flags for mem_cgroup */
>>> =A0 =A0 =A0 =A0PCG_LOCK, =A0/* Lock for pc->mem_cgroup and following bi=
ts. */
>>> @@ -94,6 +96,22 @@ pc_set_mem_cgroup(struct page_cgroup *pc, struct mem=
_cgroup *memcg)
>>> =A0 =A0 =A0 =A0pc->mem_cgroup =3D memcg;
>>> =A0}
>>>
>>> +static inline void
>>> +pc_set_mem_cgroup_and_flags(struct page_cgroup *pc, struct mem_cgroup =
*memcg,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags)
>>> +{
>>> + =A0 =A0 =A0 pc->mem_cgroup =3D memcg;
>>> + =A0 =A0 =A0 /*
>>> + =A0 =A0 =A0 =A0* We access a page_cgroup asynchronously without lock_=
page_cgroup().
>>> + =A0 =A0 =A0 =A0* Especially when a page_cgroup is taken from a page, =
pc's mem_cgroup
>>> + =A0 =A0 =A0 =A0* is accessed after testing USED bit. To make pc's mem=
_cgroup visible
>>> + =A0 =A0 =A0 =A0* before USED bit, we need memory barrier here.
>>> + =A0 =A0 =A0 =A0* See mem_cgroup_add_lru_list(), etc.
>>> + =A0 =A0 =A0 =A0*/
>>> + =A0 =A0 =A0 smp_wmb();
>>> + =A0 =A0 =A0 pc->flags =3D flags;
>>> +}
>>> +
>>> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
>>> =A0struct page_cgroup;
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 8077460..d366b60 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -2511,16 +2511,7 @@ static void __mem_cgroup_commit_charge(struct me=
m_cgroup *memcg,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>> =A0 =A0 =A0 =A0}
>>>
>>> - =A0 =A0 =A0 pc_set_mem_cgroup(pc, memcg);
>>> - =A0 =A0 =A0 /*
>>> - =A0 =A0 =A0 =A0* We access a page_cgroup asynchronously without lock_=
page_cgroup().
>>> - =A0 =A0 =A0 =A0* Especially when a page_cgroup is taken from a page, =
pc's mem_cgroup
>>> - =A0 =A0 =A0 =A0* is accessed after testing USED bit. To make pc's mem=
_cgroup visible
>>> - =A0 =A0 =A0 =A0* before USED bit, we need memory barrier here.
>>> - =A0 =A0 =A0 =A0* See mem_cgroup_add_lru_list(), etc.
>>> - =A0 =A0 =A0 =A0*/
>>> - =A0 =A0 =A0 smp_wmb();
>>> - =A0 =A0 =A0 SetPageCgroupUsed(pc);
>>
>> I might be confused. We removed this SetPageCgroupUsed() but not
>> adding it back elsewhere ?
>>
>> --Ying
>>
>>> + =A0 =A0 =A0 pc_set_mem_cgroup_and_flags(pc, memcg, BIT(PCG_USED) | BI=
T(PCG_LOCK));
>
>
> Added here. This sets
>
> =A0| memcg pointer | Used | Locked |

Ah. I missed that part.

Thanks

--Ying

>
>
> Thanks,
> -Kame
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
