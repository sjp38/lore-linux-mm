Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 1FB9B6B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 20:21:15 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so73610lbj.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 17:21:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334573091-18602-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1334573091-18602-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 1 May 2012 20:20:42 -0400
Message-ID: <CAP=VYLqgaCabQGDVgUXnCwKCZHtz0nWxpm_a6Cgz_ciMzGe9gQ@mail.gmail.com>
Subject: Re: [PATCH -V6 07/14] memcg: Add HugeTLB extension
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-next@vger.kernel.org

On Mon, Apr 16, 2012 at 6:44 AM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> This patch implements a memcg extension that allows us to control HugeTLB
> allocations via memory controller. The extension allows to limit the

Hi Aneesh,

This breaks linux-next on some arch because they don't have any
HUGE_MAX_HSTATE in scope with the current #ifdef layout.

The breakage is in sh4, m68k, s390, and possibly others.

http://kisskb.ellerman.id.au/kisskb/buildresult/6228689/
http://kisskb.ellerman.id.au/kisskb/buildresult/6228670/
http://kisskb.ellerman.id.au/kisskb/buildresult/6228484/

This is a commit in akpm's mmotm queue, which used to be here:

http://userweb.kernel.org/~akpm/mmotm

Of course the above is invalid since userweb.kernel.org is dead.
I don't have a post-kernel.org break-in link handy and a quick
search didn't give me one, but I'm sure you'll recognize the change.

Thanks,
Paul.
--

> HugeTLB usage per control group and enforces the controller limit during
> page fault. Since HugeTLB doesn't support page reclaim, enforcing the lim=
it
> at page fault time implies that, the application will get SIGBUS signal i=
f it
> tries to access HugeTLB pages beyond its limit. This requires the applica=
tion
> to know beforehand how much HugeTLB pages it would require for its use.
>
> The charge/uncharge calls will be added to HugeTLB code in later patch.
> Support for memcg removal will be added in later patches.
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> =A0include/linux/hugetlb.h =A0 =A0| =A0 =A01 +
> =A0include/linux/memcontrol.h | =A0 42 ++++++++++++++
> =A0init/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A08 +++
> =A0mm/hugetlb.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0132 ++++++++++++++++++++++=
++++++++++++++++++++++
> =A05 files changed, 184 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 46c6cbd..995c238 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -226,6 +226,7 @@ struct hstate *size_to_hstate(unsigned long size);
> =A0#define HUGE_MAX_HSTATE 1
> =A0#endif
>
> +extern int hugetlb_max_hstate;
> =A0extern struct hstate hstates[HUGE_MAX_HSTATE];
> =A0extern unsigned int default_hstate_idx;
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f94efd2..1d07e14 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -448,5 +448,47 @@ static inline void sock_release_memcg(struct sock *s=
k)
> =A0{
> =A0}
> =A0#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> +
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +extern int mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_page=
s,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 struct mem_cgroup **ptr);
> +extern void mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_p=
ages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0struct page *page);
> +extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_p=
ages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0struct page *page);
> +extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_=
pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 struct mem_cgroup *memcg);
> +
> +#else
> +static inline int
> +mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup **ptr)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static inline void
> +mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct m=
em_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct p=
age *page)
> +{
> + =A0 =A0 =A0 return;
> +}
> +
> +static inline void
> +mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct p=
age *page)
> +{
> + =A0 =A0 =A0 return;
> +}
> +
> +static inline void
> +mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 return;
> +}
> +#endif =A0/* CONFIG_MEM_RES_CTLR_HUGETLB */
> =A0#endif /* _LINUX_MEMCONTROL_H */
>
> diff --git a/init/Kconfig b/init/Kconfig
> index 72f33fa..a3b5665 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -716,6 +716,14 @@ config CGROUP_PERF
>
> =A0 =A0 =A0 =A0 =A0Say N if unsure.
>
> +config MEM_RES_CTLR_HUGETLB
> + =A0 =A0 =A0 bool "Memory Resource Controller HugeTLB Extension (EXPERIM=
ENTAL)"
> + =A0 =A0 =A0 depends on CGROUP_MEM_RES_CTLR && HUGETLB_PAGE && EXPERIMEN=
TAL
> + =A0 =A0 =A0 default n
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 Add HugeTLB management to memory resource controller. W=
hen you
> + =A0 =A0 =A0 =A0 enable this, you can put a per cgroup limit on HugeTLB =
usage.
> +
> =A0menuconfig CGROUP_SCHED
> =A0 =A0 =A0 =A0bool "Group CPU scheduler"
> =A0 =A0 =A0 =A0default n
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a3ac624..8cd89b4 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -35,7 +35,7 @@ const unsigned long hugetlb_zero =3D 0, hugetlb_infinit=
y =3D ~0UL;
> =A0static gfp_t htlb_alloc_mask =3D GFP_HIGHUSER;
> =A0unsigned long hugepages_treat_as_movable;
>
> -static int hugetlb_max_hstate;
> +int hugetlb_max_hstate;
> =A0unsigned int default_hstate_idx;
> =A0struct hstate hstates[HUGE_MAX_HSTATE];
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 901bb03..884f479 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -252,6 +252,10 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* the counter to account for hugepages from hugetlb.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct res_counter hugepage[HUGE_MAX_HSTATE];
> + =A0 =A0 =A0 /*
> =A0 =A0 =A0 =A0 * Per cgroup active and inactive list, similar to the
> =A0 =A0 =A0 =A0 * per zone LRU lists.
> =A0 =A0 =A0 =A0 */
> @@ -3213,6 +3217,114 @@ static inline int mem_cgroup_move_swap_account(sw=
p_entry_t entry,
> =A0}
> =A0#endif
>
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 int idx;
> + =A0 =A0 =A0 for (idx =3D 0; idx < hugetlb_max_hstate; idx++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((res_counter_read_u64(&memcg->hugepage[=
idx], RES_USAGE)) > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +int mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct mem_cgroup **ptr)
> +{
> + =A0 =A0 =A0 int ret =3D 0;
> + =A0 =A0 =A0 struct mem_cgroup *memcg =3D NULL;
> + =A0 =A0 =A0 struct res_counter *fail_res;
> + =A0 =A0 =A0 unsigned long csize =3D nr_pages * PAGE_SIZE;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> +again:
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> + =A0 =A0 =A0 if (!memcg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg =3D root_mem_cgroup;
> +
> + =A0 =A0 =A0 if (!css_tryget(&memcg->css)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto again;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 ret =3D res_counter_charge(&memcg->hugepage[idx], csize, &f=
ail_res);
> + =A0 =A0 =A0 css_put(&memcg->css);
> +done:
> + =A0 =A0 =A0 *ptr =3D memcg;
> + =A0 =A0 =A0 return ret;
> +}
> +
> +void mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct page *page)
> +{
> + =A0 =A0 =A0 struct page_cgroup *pc;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
> + =A0 =A0 =A0 lock_page_cgroup(pc);
> + =A0 =A0 =A0 if (unlikely(PageCgroupUsed(pc))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page_cgroup(pc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_hugetlb_uncharge_memcg(idx, nr_p=
ages, memcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 pc->mem_cgroup =3D memcg;
> + =A0 =A0 =A0 SetPageCgroupUsed(pc);
> + =A0 =A0 =A0 unlock_page_cgroup(pc);
> + =A0 =A0 =A0 return;
> +}
> +
> +void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct page *page)
> +{
> + =A0 =A0 =A0 struct page_cgroup *pc;
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 unsigned long csize =3D nr_pages * PAGE_SIZE;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
> + =A0 =A0 =A0 if (unlikely(!PageCgroupUsed(pc)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 lock_page_cgroup(pc);
> + =A0 =A0 =A0 if (!PageCgroupUsed(pc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page_cgroup(pc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 memcg =3D pc->mem_cgroup;
> + =A0 =A0 =A0 pc->mem_cgroup =3D root_mem_cgroup;
> + =A0 =A0 =A0 ClearPageCgroupUsed(pc);
> + =A0 =A0 =A0 unlock_page_cgroup(pc);
> +
> + =A0 =A0 =A0 res_counter_uncharge(&memcg->hugepage[idx], csize);
> + =A0 =A0 =A0 return;
> +}
> +
> +void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 unsigned long csize =3D nr_pages * PAGE_SIZE;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 res_counter_uncharge(&memcg->hugepage[idx], csize);
> + =A0 =A0 =A0 return;
> +}
> +#else
> +static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +#endif /* CONFIG_MEM_RES_CTLR_HUGETLB */
> +
> =A0/*
> =A0* Before starting migration, account PAGE_SIZE to mem_cgroup that the =
old
> =A0* page belongs to.
> @@ -4955,6 +5067,7 @@ err_cleanup:
> =A0static struct cgroup_subsys_state * __ref
> =A0mem_cgroup_create(struct cgroup *cont)
> =A0{
> + =A0 =A0 =A0 int idx;
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg, *parent;
> =A0 =A0 =A0 =A0long error =3D -ENOMEM;
> =A0 =A0 =A0 =A0int node;
> @@ -4997,9 +5110,22 @@ mem_cgroup_create(struct cgroup *cont)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * mem_cgroup(see mem_cgroup_put).
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_get(parent);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We could get called before hugetlb ini=
t is called.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Use HUGE_MAX_HSTATE as the max index.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (idx =3D 0; idx < HUGE_MAX_HSTATE; idx+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_init(&memcg->hu=
gepage[idx],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0&parent->hugepage[idx]);
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_init(&memcg->res, NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_init(&memcg->memsw, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We could get called before hugetlb ini=
t is called.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Use HUGE_MAX_HSTATE as the max index.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (idx =3D 0; idx < HUGE_MAX_HSTATE; idx+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_init(&memcg->hu=
gepage[idx], NULL);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0memcg->last_scanned_node =3D MAX_NUMNODES;
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&memcg->oom_notify);
> @@ -5030,6 +5156,12 @@ free_out:
> =A0static int mem_cgroup_pre_destroy(struct cgroup *cont)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cont);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Don't allow memcg removal if we have HugeTLB resource
> + =A0 =A0 =A0 =A0* usage.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (mem_cgroup_have_hugetlb_usage(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
>
> =A0 =A0 =A0 =A0return mem_cgroup_force_empty(memcg, false);
> =A0}
> --
> 1.7.10
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
