Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 1F1756B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:22:44 -0500 (EST)
Received: by vbip1 with SMTP id p1so5287539vbi.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:22:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120214121424.91a1832b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com> <20120214121424.91a1832b.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 13 Feb 2012 23:22:22 -0800
Message-ID: <CAHH2K0a45xCTFz5qD-M_wX4DqsyfOZeL_G2JSs5NdHp1ZLHT_g@mail.gmail.com>
Subject: Re: [PATCH 4/6 v4] memcg: use new logic for page stat accounting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, Feb 13, 2012 at 7:14 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From ad2905362ef58a44d96a325193ab384739418050 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 11:49:59 +0900
> Subject: [PATCH 4/6] memcg: use new logic for page stat accounting.
>
> Now, page-stat-per-memcg is recorded into per page_cgroup flag by
> duplicating page's status into the flag. The reason is that memcg
> has a feature to move a page from a group to another group and we
> have race between "move" and "page stat accounting",
>
> Under current logic, assume CPU-A and CPU-B. CPU-A does "move"
> and CPU-B does "page stat accounting".
>
> When CPU-A goes 1st,
>
> =A0 =A0 =A0 =A0 =A0 =A0CPU-A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 CPU-B
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0up=
date "struct page" info.
> =A0 =A0move_lock_mem_cgroup(memcg)
> =A0 =A0see flags

pc->flags?

> =A0 =A0copy page stat to new group
> =A0 =A0overwrite pc->mem_cgroup.
> =A0 =A0move_unlock_mem_cgroup(memcg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mo=
ve_lock_mem_cgroup(mem)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0se=
t pc->flags
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0up=
date page stat accounting
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mo=
ve_unlock_mem_cgroup(mem)
>
> stat accounting is guarded by move_lock_mem_cgroup() and "move"
> logic (CPU-A) doesn't see changes in "struct page" information.
>
> But it's costly to have the same information both in 'struct page' and
> 'struct page_cgroup'. And, there is a potential problem.
>
> For example, assume we have PG_dirty accounting in memcg.
> PG_..is a flag for struct page.
> PCG_ is a flag for struct page_cgroup.
> (This is just an example. The same problem can be found in any
> =A0kind of page stat accounting.)
>
> =A0 =A0 =A0 =A0 =A0CPU-A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 CPU-B
> =A0 =A0 =A0TestSet PG_dirty
> =A0 =A0 =A0(delay) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TestCle=
ar PG_dirty_

PG_dirty

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i=
f (TestClear(PCG_dirty))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0memcg->nr_dirty--
> =A0 =A0 =A0if (TestSet(PCG_dirty))
> =A0 =A0 =A0 =A0 =A0memcg->nr_dirty++
>

> @@ -141,6 +141,31 @@ static inline bool mem_cgroup_disabled(void)
> =A0 =A0 =A0 =A0return false;
> =A0}
>
> +void __mem_cgroup_begin_update_page_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 bool *lock, unsigned long *flags);
> +
> +static inline void mem_cgroup_begin_update_page_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 bool *lock, unsigned long *flags)
> +{
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 *lock =3D false;

This seems like a strange place to set *lock=3Dfalse.  I think it's
clearer if __mem_cgroup_begin_update_page_stat() is the only routine
that sets or clears *lock.  But I do see that in patch 6/6 'memcg: fix
performance of mem_cgroup_begin_update_page_stat()' this position is
required.

> + =A0 =A0 =A0 return __mem_cgroup_begin_update_page_stat(page, lock, flag=
s);
> +}

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ecf8856..30afea5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1877,32 +1877,54 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem=
cg, gfp_t mask)
> =A0* If there is, we take a lock.
> =A0*/
>
> +void __mem_cgroup_begin_update_page_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool *lock,=
 unsigned long *flags)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 struct page_cgroup *pc;
> +
> + =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
> +again:
> + =A0 =A0 =A0 memcg =3D pc->mem_cgroup;
> + =A0 =A0 =A0 if (unlikely(!memcg || !PageCgroupUsed(pc)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 if (!mem_cgroup_stealed(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 move_lock_mem_cgroup(memcg, flags);
> + =A0 =A0 =A0 if (memcg !=3D pc->mem_cgroup || !PageCgroupUsed(pc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_unlock_mem_cgroup(memcg, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto again;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 *lock =3D true;
> +}
> +
> +void __mem_cgroup_end_update_page_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool *lock,=
 unsigned long *flags)

'lock' looks like an unused parameter.  If so, then remove it.

> +{
> + =A0 =A0 =A0 struct page_cgroup *pc =3D lookup_page_cgroup(page);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* It's guaranteed that pc->mem_cgroup never changes whil=
e
> + =A0 =A0 =A0 =A0* lock is held

Please continue comment describing what provides this guarantee.  I
assume it is because rcu_read_lock() is held by
mem_cgroup_begin_update_page_stat().  Maybe it's best to to just make
small reference to the locking protocol description in
mem_cgroup_start_move().

> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 move_unlock_mem_cgroup(pc->mem_cgroup, flags);
> +}
> +
> +

I think it would be useful to add a small comment here declaring that
all callers of this routine must be in a
mem_cgroup_begin_update_page_stat(), mem_cgroup_end_update_page_stat()
critical section to keep pc->mem_cgroup stable.

> =A0void mem_cgroup_update_page_stat(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_=
cgroup_page_stat_item idx, int val)
> =A0{

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
