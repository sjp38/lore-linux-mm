Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id C5BBF6B007E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 17:17:59 -0400 (EDT)
Received: by lagz14 with SMTP id z14so6774014lag.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 14:17:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F72ED25.60307@jp.fujitsu.com>
References: <4F72EB84.7080000@jp.fujitsu.com>
	<4F72ED25.60307@jp.fujitsu.com>
Date: Tue, 17 Apr 2012 14:17:57 -0700
Message-ID: <CALWz4izNDGdGYmkJzHCRFspCk9QwoZtvRWpKmn=0YZRaVrcVAA@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/6] memcg: add pc_set_mem_cgroup_and_flags()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>

On Wed, Mar 28, 2012 at 3:51 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Consolidate a code for setting pc->mem_cgroup and USED bit which requires=
 smp_wmb().
> And remove a macro PCGF_NOCOPY_AT_SPLIT which isn't helpful to read code,=
 now.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/page_cgroup.h | =A0 18 ++++++++++++++++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 18 ++++--------------
> =A02 files changed, 22 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 92768cb..2707809 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -1,6 +1,8 @@
> =A0#ifndef __LINUX_PAGE_CGROUP_H
> =A0#define __LINUX_PAGE_CGROUP_H
>
> +#include <linux/smp.h>
> +
> =A0enum {
> =A0 =A0 =A0 =A0/* flags for mem_cgroup */
> =A0 =A0 =A0 =A0PCG_LOCK, =A0/* Lock for pc->mem_cgroup and following bits=
. */
> @@ -94,6 +96,22 @@ pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_c=
group *memcg)
> =A0 =A0 =A0 =A0pc->mem_cgroup =3D memcg;
> =A0}
>
> +static inline void
> +pc_set_mem_cgroup_and_flags(struct page_cgroup *pc, struct mem_cgroup *m=
emcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags)
> +{
> + =A0 =A0 =A0 pc->mem_cgroup =3D memcg;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We access a page_cgroup asynchronously without lock_pa=
ge_cgroup().
> + =A0 =A0 =A0 =A0* Especially when a page_cgroup is taken from a page, pc=
's mem_cgroup
> + =A0 =A0 =A0 =A0* is accessed after testing USED bit. To make pc's mem_c=
group visible
> + =A0 =A0 =A0 =A0* before USED bit, we need memory barrier here.
> + =A0 =A0 =A0 =A0* See mem_cgroup_add_lru_list(), etc.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 smp_wmb();
> + =A0 =A0 =A0 pc->flags =3D flags;
> +}
> +
> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> =A0struct page_cgroup;
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8077460..d366b60 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2511,16 +2511,7 @@ static void __mem_cgroup_commit_charge(struct mem_=
cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 pc_set_mem_cgroup(pc, memcg);
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* We access a page_cgroup asynchronously without lock_pa=
ge_cgroup().
> - =A0 =A0 =A0 =A0* Especially when a page_cgroup is taken from a page, pc=
's mem_cgroup
> - =A0 =A0 =A0 =A0* is accessed after testing USED bit. To make pc's mem_c=
group visible
> - =A0 =A0 =A0 =A0* before USED bit, we need memory barrier here.
> - =A0 =A0 =A0 =A0* See mem_cgroup_add_lru_list(), etc.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 smp_wmb();
> - =A0 =A0 =A0 SetPageCgroupUsed(pc);

I might be confused. We removed this SetPageCgroupUsed() but not
adding it back elsewhere ?

--Ying

> + =A0 =A0 =A0 pc_set_mem_cgroup_and_flags(pc, memcg, BIT(PCG_USED) | BIT(=
PCG_LOCK));
>
> =A0 =A0 =A0 =A0if (lrucare) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (was_on_lru) {
> @@ -2549,7 +2540,6 @@ static void __mem_cgroup_commit_charge(struct mem_c=
group *memcg,
>
> =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>
> -#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MIGRATION))
> =A0/*
> =A0* Because tail pages are not marked as "used", set it. We're under
> =A0* zone->lru_lock, 'splitting on pmd' and compound_lock.
> @@ -2565,11 +2555,11 @@ void mem_cgroup_split_huge_fixup(struct page *hea=
d)
>
> =A0 =A0 =A0 =A0if (mem_cgroup_disabled())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> + =A0 =A0 =A0 if (!PageCgroupUsed(head_pc))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> =A0 =A0 =A0 =A0for (i =3D 1; i < HPAGE_PMD_NR; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D head_pc + i;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc_set_mem_cgroup(pc, memcg);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_wmb();/* see __commit_charge() */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc->flags =3D head_pc->flags & ~PCGF_NOCOPY=
_AT_SPLIT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc_set_mem_cgroup_and_flags(pc, memcg, BIT(=
PCG_USED));
> =A0 =A0 =A0 =A0}
> =A0}
> =A0#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> --
> 1.7.4.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
