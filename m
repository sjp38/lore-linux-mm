Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 6EE556B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 17:25:09 -0400 (EDT)
Received: by lagz14 with SMTP id z14so6780074lag.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 14:25:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F72EE86.9030005@jp.fujitsu.com>
References: <4F72EB84.7080000@jp.fujitsu.com>
	<4F72EE86.9030005@jp.fujitsu.com>
Date: Tue, 17 Apr 2012 14:25:07 -0700
Message-ID: <CALWz4iy-TM_vHCmgZ4e+DEx6WqLJD6QRYut75L4Qz681pOgvkw@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/6] memcg: add PageCgroupReset()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>

On Wed, Mar 28, 2012 at 3:57 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> =A0A commit "memcg: simplify LRU handling by new rule" removes PCG_ACCT_L=
RU.
> =A0and the bug introduced by it was fixed by "memcg: fix GPF when cgroup =
removal
> =A0races with last exit"
>
> This was for reducing flags on pc->flags....Now, we have 3bits of flags.
> but this patch adds a new flag, I'm sorry. (Considering alignment of
> kmalloc(), we'll able to have 5 bits..)
>
> This patch adds PCG_RESET which is similar to PCG_ACCT_LRU.



This is set
> when mem_cgroup_add_lru_list() finds we cannot trust the pc's mem_cgroup.

Do we still need the new flag? I assume some of the upcoming patches
will provide the guarantee of pc->mem_cgroup.

--Ying
>
> The reason why this patch adds a (renamed) flag again is for merging
> pc->flags and pc->mem_cgroup. Assume pc's mem_cgroup is encoded as
>
> =A0 =A0 =A0 =A0mem_cgroup =3D pc->flags & ~0x7
>
> Updating multiple bits of pc->flags without talking lock_page_cgroup()
> is very dangerous. And mem_cgroup_add_lru_list() updates pc->mem_cgroup
> without taking lock. Then I add RESET bit. After this, pc_to_mem_cgroup()
> is written as
>
> =A0 =A0 =A0 =A0if (PageCgroupReset(pc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return root_mem_cgroup;
> =A0 =A0 =A0 =A0return pc->mem_cgroup;
>
> This update of Reset bit can be done in atomic by set_bit(). And
> cleared when USED bit is set.
>
> Considering kmalloc()'s alignment, having 4bits of flags will be ok....
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/page_cgroup.h | =A0 15 ++++++++-------
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +++--
> =A02 files changed, 11 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 2707809..3f3b4ff 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -8,6 +8,7 @@ enum {
> =A0 =A0 =A0 =A0PCG_LOCK, =A0/* Lock for pc->mem_cgroup and following bits=
. */
> =A0 =A0 =A0 =A0PCG_USED, /* this object is in use. */
> =A0 =A0 =A0 =A0PCG_MIGRATION, /* under page migration */
> + =A0 =A0 =A0 PCG_RESET, =A0 =A0 /* have been reset to root_mem_cgroup */
> =A0 =A0 =A0 =A0__NR_PCG_FLAGS,
> =A0};
>
> @@ -70,6 +71,9 @@ SETPCGFLAG(Migration, MIGRATION)
> =A0CLEARPCGFLAG(Migration, MIGRATION)
> =A0TESTPCGFLAG(Migration, MIGRATION)
>
> +TESTPCGFLAG(Reset, RESET)
> +SETPCGFLAG(Reset, RESET)
> +
> =A0static inline void lock_page_cgroup(struct page_cgroup *pc)
> =A0{
> =A0 =A0 =A0 =A0/*
> @@ -84,16 +88,13 @@ static inline void unlock_page_cgroup(struct page_cgr=
oup *pc)
> =A0 =A0 =A0 =A0bit_spin_unlock(PCG_LOCK, &pc->flags);
> =A0}
>
> +extern struct mem_cgroup* =A0root_mem_cgroup;
>
> =A0static inline struct mem_cgroup* pc_to_mem_cgroup(struct page_cgroup *=
pc)
> =A0{
> - =A0 =A0 =A0 return pc->mem_cgroup;
> -}
> -
> -static inline void
> -pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
> -{
> - =A0 =A0 =A0 pc->mem_cgroup =3D memcg;
> + =A0 =A0 =A0 if (likely(!PageCgroupReset(pc)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return pc->mem_cgroup;
> + =A0 =A0 =A0 return root_mem_cgroup;
> =A0}
>
> =A0static inline void
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d366b60..622fd2e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1080,7 +1080,8 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone =
*zone, struct page *page,
> =A0 =A0 =A0 =A0 * of pc's mem_cgroup safe.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc) && memcg !=3D root_mem_cgroup) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc_set_mem_cgroup(pc, root_mem_cgroup);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* this reset bit is cleared when the page =
is charged */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageCgroupReset(pc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg =3D root_mem_cgroup;
> =A0 =A0 =A0 =A0}
>
> @@ -2626,7 +2627,7 @@ static int mem_cgroup_move_account(struct page *pag=
e,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgroup_cancel_charge(from, nr_pages)=
;
>
> =A0 =A0 =A0 =A0/* caller should have done css_get */
> - =A0 =A0 =A0 pc_set_mem_cgroup(pc, to);
> + =A0 =A0 =A0 pc_set_mem_cgroup_and_flags(pc, to, BIT(PCG_USED) | BIT(PCG=
_LOCK));
> =A0 =A0 =A0 =A0mem_cgroup_charge_statistics(to, anon, nr_pages);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * We charges against "to" which may not have any tasks. T=
hen, "to"
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
