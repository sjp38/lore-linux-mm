Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 3B3456B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 05:23:29 -0400 (EDT)
Received: by weys10 with SMTP id s10so1094284wey.14
        for <linux-mm@kvack.org>; Wed, 18 Jul 2012 02:23:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1342602398-24977-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1342602398-24977-1-git-send-email-liwanp@linux.vnet.ibm.com>
Date: Wed, 18 Jul 2012 17:23:27 +0800
Message-ID: <CAA_GA1eeawakG7Ox-HOy+HdM45NJ5Zudb5FiPbA6uDGqi3PDsw@mail.gmail.com>
Subject: Re: [PATCH] mm/memcg: use exist interface to get css from memcg
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On Wed, Jul 18, 2012 at 5:06 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
> ---
>  mm/memcontrol.c |   82 ++++++++++++++++++++++++++++---------------------------
>  1 files changed, 42 insertions(+), 40 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 20f6a15..42788b0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -467,7 +467,7 @@ mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
>
>  struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
>  {
> -       return &memcg->css;
> +       return mem_cgroup_css(memcg);
>  }

??

>
>  static struct mem_cgroup_per_zone *
> @@ -861,7 +861,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>                 memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
>                 if (unlikely(!memcg))
>                         break;
> -       } while (!css_tryget(&memcg->css));
> +       } while (!css_tryget(mem_cgroup_css(memcg)));
>         rcu_read_unlock();
>         return memcg;
>  }
> @@ -897,10 +897,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>                 root = root_mem_cgroup;
>
>         if (prev && !reclaim)
> -               id = css_id(&prev->css);
> +               id = css_id(mem_cgroup_css(prev));
>
>         if (prev && prev != root)
> -               css_put(&prev->css);
> +               css_put(mem_cgroup_css(prev));
>
>         if (!root->use_hierarchy && root != root_mem_cgroup) {
>                 if (prev)
> @@ -925,9 +925,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>                 }
>
>                 rcu_read_lock();
> -               css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
> +               css = css_get_next(&mem_cgroup_subsys,
> +                                       id + 1, mem_cgroup_css(root), &id);
>                 if (css) {
> -                       if (css == &root->css || css_tryget(css))
> +                       if (css == mem_cgroup_css(root) || css_tryget(css))
>                                 memcg = mem_cgroup_from_css(css,
>                                                      struct mem_cgroup, css);
>                 } else
> @@ -959,7 +960,7 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
>         if (!root)
>                 root = root_mem_cgroup;
>         if (prev && prev != root)
> -               css_put(&prev->css);
> +               css_put(mem_cgroup_css(prev));
>  }
>
>  /*
> @@ -1153,7 +1154,8 @@ static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  {
>         if (root_memcg != memcg) {
>                 return (root_memcg->use_hierarchy &&
> -                       css_is_ancestor(&memcg->css, &root_memcg->css));
> +                       css_is_ancestor(mem_cgroup_css(memcg),
> +                               mem_cgroup_css(root_memcg)));
>         }
>
>         return true;
> @@ -1178,7 +1180,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
>                 task_lock(task);
>                 curr = mem_cgroup_from_task(task);
>                 if (curr)
> -                       css_get(&curr->css);
> +                       css_get(mem_cgroup_css(curr));
>                 task_unlock(task);
>         }
>         if (!curr)
> @@ -1190,7 +1192,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
>          * hierarchy(even if use_hierarchy is disabled in "memcg").
>          */
>         ret = mem_cgroup_same_or_subtree(memcg, curr);
> -       css_put(&curr->css);
> +       css_put(mem_cgroup_css(curr));
>         return ret;
>  }
>
> @@ -1282,7 +1284,7 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
>
>  int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>  {
> -       struct cgroup *cgrp = memcg->css.cgroup;
> +       struct cgroup *cgrp = mem_cgroup_css(memcg)->cgroup;
>
>         /* root ? */
>         if (cgrp->parent == NULL)
> @@ -1402,7 +1404,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>
>         rcu_read_lock();
>
> -       mem_cgrp = memcg->css.cgroup;
> +       mem_cgrp = mem_cgroup_css(memcg)->cgroup;
>         task_cgrp = task_cgroup(p, mem_cgroup_subsys_id);
>
>         ret = cgroup_path(task_cgrp, memcg_name, PATH_MAX);
> @@ -2276,12 +2278,12 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  again:
>         if (*ptr) { /* css should be a valid one */
>                 memcg = *ptr;
> -               VM_BUG_ON(css_is_removed(&memcg->css));
> +               VM_BUG_ON(css_is_removed(mem_cgroup_css(memcg)));
>                 if (mem_cgroup_is_root(memcg))
>                         goto done;
>                 if (nr_pages == 1 && consume_stock(memcg))
>                         goto done;
> -               css_get(&memcg->css);
> +               css_get(mem_cgroup_css(memcg));
>         } else {
>                 struct task_struct *p;
>
> @@ -2317,7 +2319,7 @@ again:
>                         goto done;
>                 }
>                 /* after here, we may be blocked. we need to get refcnt */
> -               if (!css_tryget(&memcg->css)) {
> +               if (!css_tryget(mem_cgroup_css(memcg))) {
>                         rcu_read_unlock();
>                         goto again;
>                 }
> @@ -2329,7 +2331,7 @@ again:
>
>                 /* If killed, bypass charge */
>                 if (fatal_signal_pending(current)) {
> -                       css_put(&memcg->css);
> +                       css_put(mem_cgroup_css(memcg));
>                         goto bypass;
>                 }
>
> @@ -2345,29 +2347,29 @@ again:
>                         break;
>                 case CHARGE_RETRY: /* not in OOM situation but retry */
>                         batch = nr_pages;
> -                       css_put(&memcg->css);
> +                       css_put(mem_cgroup_css(memcg));
>                         memcg = NULL;
>                         goto again;
>                 case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
> -                       css_put(&memcg->css);
> +                       css_put(mem_cgroup_css(memcg));
>                         goto nomem;
>                 case CHARGE_NOMEM: /* OOM routine works */
>                         if (!oom) {
> -                               css_put(&memcg->css);
> +                               css_put(mem_cgroup_css(memcg));
>                                 goto nomem;
>                         }
>                         /* If oom, we never return -ENOMEM */
>                         nr_oom_retries--;
>                         break;
>                 case CHARGE_OOM_DIE: /* Killed by OOM Killer */
> -                       css_put(&memcg->css);
> +                       css_put(mem_cgroup_css(memcg));
>                         goto bypass;
>                 }
>         } while (ret != CHARGE_OK);
>
>         if (batch > nr_pages)
>                 refill_stock(memcg, batch - nr_pages);
> -       css_put(&memcg->css);
> +       css_put(mem_cgroup_css(memcg));
>  done:
>         *ptr = memcg;
>         return 0;
> @@ -2428,14 +2430,14 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>         lock_page_cgroup(pc);
>         if (PageCgroupUsed(pc)) {
>                 memcg = pc->mem_cgroup;
> -               if (memcg && !css_tryget(&memcg->css))
> +               if (memcg && !css_tryget(mem_cgroup_css(memcg)))
>                         memcg = NULL;
>         } else if (PageSwapCache(page)) {
>                 ent.val = page_private(page);
>                 id = lookup_swap_cgroup_id(ent);
>                 rcu_read_lock();
>                 memcg = mem_cgroup_lookup(id);
> -               if (memcg && !css_tryget(&memcg->css))
> +               if (memcg && !css_tryget(mem_cgroup_css(memcg)))
>                         memcg = NULL;
>                 rcu_read_unlock();
>         }
> @@ -2640,7 +2642,7 @@ static int mem_cgroup_move_parent(struct page *page,
>                                   struct mem_cgroup *child,
>                                   gfp_t gfp_mask)
>  {
> -       struct cgroup *cg = child->css.cgroup;
> +       struct cgroup *cg = mem_cgroup_css(child)->cgroup;
>         struct cgroup *pcg = cg->parent;
>         struct mem_cgroup *parent;
>         unsigned int nr_pages;
> @@ -2790,7 +2792,7 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>                 goto charge_cur_mm;
>         *memcgp = memcg;
>         ret = __mem_cgroup_try_charge(NULL, mask, 1, memcgp, true);
> -       css_put(&memcg->css);
> +       css_put(mem_cgroup_css(memcg));
>         if (ret == -EINTR)
>                 ret = 0;
>         return ret;
> @@ -2813,7 +2815,7 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
>                 return;
>         if (!memcg)
>                 return;
> -       cgroup_exclude_rmdir(&memcg->css);
> +       cgroup_exclude_rmdir(mem_cgroup_css(memcg));
>
>         pc = lookup_page_cgroup(page);
>         __mem_cgroup_commit_charge(memcg, page, 1, pc, ctype, true);
> @@ -2850,7 +2852,7 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
>          * So, rmdir()->pre_destroy() can be called while we do this charge.
>          * In that case, we need to call pre_destroy() again. check it here.
>          */
> -       cgroup_release_and_wakeup_rmdir(&memcg->css);
> +       cgroup_release_and_wakeup_rmdir(mem_cgroup_css(memcg));
>  }
>
>  void mem_cgroup_commit_charge_swapin(struct page *page,
> @@ -3089,7 +3091,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>          * mem_cgroup_get() was called in uncharge().
>          */
>         if (do_swap_account && swapout && memcg)
> -               swap_cgroup_record(ent, css_id(&memcg->css));
> +               swap_cgroup_record(ent, css_id(mem_cgroup_css(memcg)));
>  }
>  #endif
>
> @@ -3142,8 +3144,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
>  {
>         unsigned short old_id, new_id;
>
> -       old_id = css_id(&from->css);
> -       new_id = css_id(&to->css);
> +       old_id = css_id(mem_cgroup_css(from));
> +       new_id = css_id(mem_cgroup_css(to));
>
>         if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
>                 mem_cgroup_swap_statistics(from, false);
> @@ -3202,7 +3204,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>         lock_page_cgroup(pc);
>         if (PageCgroupUsed(pc)) {
>                 memcg = pc->mem_cgroup;
> -               css_get(&memcg->css);
> +               css_get(mem_cgroup_css(memcg));
>                 /*
>                  * At migrating an anonymous page, its mapcount goes down
>                  * to 0 and uncharge() will be called. But, even if it's fully
> @@ -3245,7 +3247,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>
>         *memcgp = memcg;
>         ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, memcgp, false);
> -       css_put(&memcg->css);/* drop extra refcnt */
> +       css_put(mem_cgroup_css(memcg));/* drop extra refcnt */
>         if (ret) {
>                 if (PageAnon(page)) {
>                         lock_page_cgroup(pc);
> @@ -3286,7 +3288,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
>         if (!memcg)
>                 return;
>         /* blocks rmdir() */
> -       cgroup_exclude_rmdir(&memcg->css);
> +       cgroup_exclude_rmdir(mem_cgroup_css(memcg));
>         if (!migration_ok) {
>                 used = oldpage;
>                 unused = newpage;
> @@ -3322,7 +3324,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
>          * So, rmdir()->pre_destroy() can be called while we do this charge.
>          * In that case, we need to call pre_destroy() again. check it here.
>          */
> -       cgroup_release_and_wakeup_rmdir(&memcg->css);
> +       cgroup_release_and_wakeup_rmdir(mem_cgroup_css(memcg));
>  }
>
>  /*
> @@ -3686,9 +3688,9 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
>         int ret;
>         int node, zid, shrink;
>         int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -       struct cgroup *cgrp = memcg->css.cgroup;
> +       struct cgroup *cgrp = mem_cgroup_css(memcg)->cgroup;
>
> -       css_get(&memcg->css);
> +       css_get(mem_cgroup_css(memcg));
>
>         shrink = 0;
>         /* should free all ? */
> @@ -3729,7 +3731,7 @@ move_account:
>         /* "ret" should also be checked to ensure all lists are empty. */
>         } while (memcg->res.usage > 0 || ret);
>  out:
> -       css_put(&memcg->css);
> +       css_put(mem_cgroup_css(memcg));
>         return ret;
>
>  try_to_free:
> @@ -3928,7 +3930,7 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
>
>         min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
>         min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -       cgroup = memcg->css.cgroup;
> +       cgroup = mem_cgroup_css(memcg)->cgroup;
>         if (!memcg->use_hierarchy)
>                 goto out;
>
> @@ -4842,7 +4844,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>         int node;
>
>         mem_cgroup_remove_from_trees(memcg);
> -       free_css_id(&mem_cgroup_subsys, &memcg->css);
> +       free_css_id(&mem_cgroup_subsys, mem_cgroup_css(memcg));
>
>         for_each_node(node)
>                 free_mem_cgroup_per_zone_info(memcg, node);
> @@ -4989,7 +4991,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>         atomic_set(&memcg->refcnt, 1);
>         memcg->move_charge_at_immigrate = 0;
>         mutex_init(&memcg->thresholds_lock);
> -       return &memcg->css;
> +       return mem_cgroup_css(memcg);
>  free_out:
>         __mem_cgroup_free(memcg);
>         return ERR_PTR(error);
> --
> 1.7.5.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
