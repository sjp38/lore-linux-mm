Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 26EC26B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:16:35 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id l6so2586543qcy.13
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 03:16:34 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id a5si30653781qat.0.2015.01.14.03.16.33
        for <linux-mm@kvack.org>;
        Wed, 14 Jan 2015 03:16:33 -0800 (PST)
Message-ID: <54B6500D.6080206@arm.com>
Date: Wed, 14 Jan 2015 11:16:29 +0000
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH cgroup/for-3.19-fixes] cgroup: implement cgroup_subsys->unbind()
 callback
References: <54B01335.4060901@arm.com> <20150110085525.GD2110@esperanza> <20150110214316.GF25319@htj.dyndns.org> <20150111205543.GA5480@phnom.home.cmpxchg.org>
In-Reply-To: <20150111205543.GA5480@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

On 11/01/15 20:55, Johannes Weiner wrote:
> On Sat, Jan 10, 2015 at 04:43:16PM -0500, Tejun Heo wrote:
>> Currently, if a hierarchy doesn't have any live children when it's
>> unmounted, the hierarchy starts dying by killing its refcnt.  The
>> expectation is that even if there are lingering dead children which
>> are lingering due to remaining references, they'll be put in a finite
>> amount of time.  When the children are finally released, the hierarchy
>> is destroyed and all controllers bound to it also are released.
>>
>> However, for memcg, the premise that the lingering refs will be put in
>> a finite amount time is not true.  In the absense of memory pressure,
>> dead memcg's may hang around indefinitely pinned by its pages.  This
>> unfortunately may lead to indefinite hang on the next mount attempt
>> involving memcg as the mount logic waits for it to get released.
>>
>> While we can change hierarchy destruction logic such that a hierarchy
>> is only destroyed when it's not mounted anywhere and all its children,
>> live or dead, are gone, this makes whether the hierarchy gets
>> destroyed or not to be determined by factors opaque to userland.
>> Userland may or may not get a new hierarchy on the next mount attempt.
>> Worse, if it explicitly wants to create a new hierarchy with different
>> options or controller compositions involving memcg, it will fail in an
>> essentially arbitrary manner.
>>
>> We want to guarantee that a hierarchy is destroyed once the
>> conditions, unmounted and no visible children, are met.  To aid it,
>> this patch introduces a new callback cgroup_subsys->unbind() which is
>> invoked right before the hierarchy a subsystem is bound to starts
>> dying.  memcg can implement this callback and initiate draining of
>> remaining refs so that the hierarchy can eventually be released in a
>> finite amount of time.
>>
>> Signed-off-by: Tejun Heo <tj@kernel.org>
>> Cc: Li Zefan <lizefan@huawei.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Vladimir Davydov <vdavydov@parallels.com>
>> ---
>> Hello,
>>
>>> May be, we should kill the ref counter to the memory controller root in
>>> cgroup_kill_sb only if there is no children at all, neither online nor
>>> offline.
>>
>> Ah, thanks for the analysis, but I really wanna avoid making hierarchy
>> destruction conditions opaque to userland.  This is userland visible
>> behavior.  It shouldn't be determined by kernel internals invisible
>> outside.  This patch adds ss->unbind() which memcg can hook into to
>> kick off draining of residual refs.  If this would work, I'll add this
>> patch to cgroup/for-3.19-fixes, possibly with stable cc'd.
>
> How about this ->unbind() for memcg?
>
>  From d527ba1dbfdb58e1f7c7c4ee12b32ef2e5461990 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Sun, 11 Jan 2015 10:29:05 -0500
> Subject: [patch] mm: memcontrol: zap outstanding cache/swap references du=
ring
>   unbind
>
This patch doesn't cleanly apply on 3.19-rc4 for me (hunks in=20
mm/memcontrol.c). I have manually applied it.

With these two patches in, I am still getting the failure. Also, the=20
kworker thread is taking up 100% time (unbind_work) and continues to do=20
so even after 6minutes.

Is there something I missed ?

Thanks
Suzuki




> Cgroup core assumes that any outstanding css references after
> offlining are temporary in nature, and e.g. mount waits for them to
> disappear and release the root cgroup.  But leftover page cache and
> swapout records in an offlined memcg are only dropped when the pages
> get reclaimed under pressure or the swapped out pages get faulted in
> from other cgroups, and so those cgroup operations can hang forever.
>
> Implement the ->unbind() callback to actively get rid of outstanding
> references when cgroup core wants them gone.  Swap out records are
> deleted, such that the swap-in path will charge those pages to the
> faulting task.  Page cache pages are moved to the root memory cgroup.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>   include/linux/swap_cgroup.h |   6 +++
>   mm/memcontrol.c             | 126 +++++++++++++++++++++++++++++++++++++=
+++++++
>   mm/swap_cgroup.c            |  38 +++++++++++++
>   3 files changed, 170 insertions(+)
>
> diff --git a/include/linux/swap_cgroup.h b/include/linux/swap_cgroup.h
> index 145306bdc92f..ffe0866d2997 100644
> --- a/include/linux/swap_cgroup.h
> +++ b/include/linux/swap_cgroup.h
> @@ -9,6 +9,7 @@ extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent=
,
>   =09=09=09=09=09unsigned short old, unsigned short new);
>   extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned shor=
t id);
>   extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
> +extern unsigned long swap_cgroup_zap_records(unsigned short id);
>   extern int swap_cgroup_swapon(int type, unsigned long max_pages);
>   extern void swap_cgroup_swapoff(int type);
>
> @@ -26,6 +27,11 @@ unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
>   =09return 0;
>   }
>
> +static inline unsigned long swap_cgroup_zap_records(unsigned short id)
> +{
> +=09return 0;
> +}
> +
>   static inline int
>   swap_cgroup_swapon(int type, unsigned long max_pages)
>   {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 692e96407627..40c426add613 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5197,6 +5197,131 @@ static void mem_cgroup_bind(struct cgroup_subsys_=
state *root_css)
>   =09=09mem_cgroup_from_css(root_css)->use_hierarchy =3D true;
>   }
>
> +static void unbind_lru_list(struct mem_cgroup *memcg,
> +=09=09=09    struct zone *zone, enum lru_list lru)
> +{
> +=09struct lruvec *lruvec =3D mem_cgroup_zone_lruvec(zone, memcg);
> +=09struct list_head *list =3D &lruvec->lists[lru];
> +
> +=09while (!list_empty(list)) {
> +=09=09unsigned int nr_pages;
> +=09=09unsigned long flags;
> +=09=09struct page *page;
> +
> +=09=09spin_lock_irqsave(&zone->lru_lock, flags);
> +=09=09if (list_empty(list)) {
> +=09=09=09spin_unlock_irqrestore(&zone->lru_lock, flags);
> +=09=09=09break;
> +=09=09}
> +=09=09page =3D list_last_entry(list, struct page, lru);
> +=09=09if (!get_page_unless_zero(page)) {
> +=09=09=09list_move(&page->lru, list);
> +=09=09=09spin_unlock_irqrestore(&zone->lru_lock, flags);
> +=09=09=09continue;
> +=09=09}
> +=09=09BUG_ON(!PageLRU(page));
> +=09=09ClearPageLRU(page);
> +=09=09del_page_from_lru_list(page, lruvec, lru);
> +=09=09spin_unlock_irqrestore(&zone->lru_lock, flags);
> +
> +=09=09compound_lock(page);
> +=09=09nr_pages =3D hpage_nr_pages(page);
> +
> +=09=09if (!mem_cgroup_move_account(page, nr_pages,
> +=09=09=09=09=09     memcg, root_mem_cgroup)) {
> +=09=09=09/*
> +=09=09=09 * root_mem_cgroup page counters are not used,
> +=09=09=09 * otherwise we'd have to charge them here.
> +=09=09=09 */
> +=09=09=09page_counter_uncharge(&memcg->memory, nr_pages);
> +=09=09=09if (do_swap_account)
> +=09=09=09=09page_counter_uncharge(&memcg->memsw, nr_pages);
> +=09=09=09css_put_many(&memcg->css, nr_pages);
> +=09=09}
> +
> +=09=09compound_unlock(page);
> +
> +=09=09putback_lru_page(page);
> +=09}
> +}
> +
> +static void unbind_work_fn(struct work_struct *work)
> +{
> +=09struct cgroup_subsys_state *css;
> +retry:
> +=09drain_all_stock(root_mem_cgroup);
> +
> +=09rcu_read_lock();
> +=09css_for_each_child(css, &root_mem_cgroup->css) {
> +=09=09struct mem_cgroup *memcg =3D mem_cgroup_from_css(css);
> +
> +=09=09/* Drop references from swap-out records */
> +=09=09if (do_swap_account) {
> +=09=09=09long zapped;
> +
> +=09=09=09zapped =3D swap_cgroup_zap_records(memcg->css.id);
> +=09=09=09page_counter_uncharge(&memcg->memsw, zapped);
> +=09=09=09css_put_many(&memcg->css, zapped);
> +=09=09}
> +
> +=09=09/* Drop references from leftover LRU pages */
> +=09=09css_get(css);
> +=09=09rcu_read_unlock();
> +=09=09atomic_inc(&memcg->moving_account);
> +=09=09synchronize_rcu();
> +=09=09while (page_counter_read(&memcg->memory) -
> +=09=09       page_counter_read(&memcg->kmem) > 0) {
> +=09=09=09struct zone *zone;
> +=09=09=09enum lru_list lru;
> +
> +=09=09=09lru_add_drain_all();
> +
> +=09=09=09for_each_zone(zone)
> +=09=09=09=09for_each_lru(lru)
> +=09=09=09=09=09unbind_lru_list(memcg, zone, lru);
> +
> +=09=09=09cond_resched();
> +=09=09}
> +=09=09atomic_dec(&memcg->moving_account);
> +=09=09rcu_read_lock();
> +=09=09css_put(css);
> +=09}
> +=09rcu_read_unlock();
> +=09/*
> +=09 * Swap-in is racy:
> +=09 *
> +=09 * #0                        #1
> +=09 *                           lookup_swap_cgroup_id()
> +=09 *                           rcu_read_lock()
> +=09 *                           mem_cgroup_lookup()
> +=09 *                           css_tryget_online()
> +=09 *                           rcu_read_unlock()
> +=09 * cgroup_kill_sb()
> +=09 *   !css_has_online_children()
> +=09 *     ->unbind()
> +=09 *                           page_counter_try_charge()
> +=09 *                           css_put()
> +=09 *                             css_free()
> +=09 *                           pc->mem_cgroup =3D dead memcg
> +=09 *                           add page to lru
> +=09 *
> +=09 * Loop until until all references established from previously
> +=09 * existing swap-out records have been transferred to pages on
> +=09 * the LRU and then uncharged from there.
> +=09 */
> +=09if (!list_empty(&root_mem_cgroup->css.children)) {
> +=09=09msleep(10);
> +=09=09goto retry;
> +=09}
> +}
> +
> +static DECLARE_WORK(unbind_work, unbind_work_fn);
> +
> +static void mem_cgroup_unbind(struct cgroup_subsys_state *root_css)
> +{
> +=09schedule_work(&unbind_work);
> +}
> +
>   static u64 memory_current_read(struct cgroup_subsys_state *css,
>   =09=09=09       struct cftype *cft)
>   {
> @@ -5360,6 +5485,7 @@ struct cgroup_subsys memory_cgrp_subsys =3D {
>   =09.cancel_attach =3D mem_cgroup_cancel_attach,
>   =09.attach =3D mem_cgroup_move_task,
>   =09.bind =3D mem_cgroup_bind,
> +=09.unbind =3D mem_cgroup_unbind,
>   =09.dfl_cftypes =3D memory_files,
>   =09.legacy_cftypes =3D mem_cgroup_legacy_files,
>   =09.early_init =3D 0,
> diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
> index b5f7f24b8dd1..665923a558c4 100644
> --- a/mm/swap_cgroup.c
> +++ b/mm/swap_cgroup.c
> @@ -140,6 +140,44 @@ unsigned short lookup_swap_cgroup_id(swp_entry_t ent=
)
>   =09return lookup_swap_cgroup(ent, NULL)->id;
>   }
>
> +/**
> + * swap_cgroup_zap_records - delete all swapout records of one cgroup
> + * @id: memcg id
> + *
> + * Returns the number of deleted records.
> + */
> +unsigned long swap_cgroup_zap_records(unsigned short id)
> +{
> +=09unsigned long zapped =3D 0;
> +=09unsigned int type;
> +
> +=09for (type =3D 0; type < MAX_SWAPFILES; type++) {
> +=09=09struct swap_cgroup_ctrl *ctrl;
> +=09=09unsigned long flags;
> +=09=09unsigned int page;
> +
> +=09=09ctrl =3D &swap_cgroup_ctrl[type];
> +=09=09spin_lock_irqsave(&ctrl->lock, flags);
> +=09=09for (page =3D 0; page < ctrl->length; page++) {
> +=09=09=09struct swap_cgroup *base;
> +=09=09=09pgoff_t offset;
> +
> +=09=09=09base =3D page_address(ctrl->map[page]);
> +=09=09=09for (offset =3D 0; offset < SC_PER_PAGE; offset++) {
> +=09=09=09=09struct swap_cgroup *sc;
> +
> +=09=09=09=09sc =3D base + offset;
> +=09=09=09=09if (sc->id =3D=3D id) {
> +=09=09=09=09=09sc->id =3D 0;
> +=09=09=09=09=09zapped++;
> +=09=09=09=09}
> +=09=09=09}
> +=09=09}
> +=09=09spin_unlock_irqrestore(&ctrl->lock, flags);
> +=09}
> +=09return zapped;
> +}
> +
>   int swap_cgroup_swapon(int type, unsigned long max_pages)
>   {
>   =09void *array;
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
