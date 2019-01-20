Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84F5D8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 18:20:24 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id i2so10455119ywb.1
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 15:20:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a84sor1466993ywh.132.2019.01.20.15.20.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 15:20:23 -0800 (PST)
MIME-Version: 1.0
References: <CAHbLzkoRGk9nE6URO9xJKaAQ+8HDPJQosJuPyR1iYuaUBroDMg@mail.gmail.com>
 <20190120231551.213847-1-shakeelb@google.com>
In-Reply-To: <20190120231551.213847-1-shakeelb@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 20 Jan 2019 15:20:11 -0800
Message-ID: <CALvZod6eTa7vvf2c41yx3Yew7RYa56WvNE+HwmFUDzXCsO7PVg@mail.gmail.com>
Subject: Re: memory cgroup pagecache and inode problem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>, Fam Zheng <zhengfeiran@bytedance.com>
Cc: Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?UTF-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Sun, Jan 20, 2019 at 3:16 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Wed, Jan 16, 2019 at 9:07 PM Yang Shi <shy828301@gmail.com> wrote:
> ...
> > > > You mean it solves the problem by retrying more times?  Actually, I'm
> > > > not sure if you have swap setup in your test, but force_empty does do
> > > > swap if swap is on. This may cause it can't reclaim all the page cache
> > > > in 5 retries.  I have a patch within that series to skip swap.
> > >
> > > Basically yes, retrying solves the problem. But compared to immediate retries, a scheduled retry in a few seconds is much more effective.
> >
> > This may suggest doing force_empty in a worker is more effective in
> > fact. Not sure if this is good enough to convince Johannes or not.
> >
>
> From what I understand what we actually want is to force_empty an
> offlined memcg. How about we change the semantics of force_empty on
> root_mem_cgroup? Currently force_empty on root_mem_cgroup returns
> -EINVAL. Rather than that, let's do force_empty on all offlined memcgs
> if user does force_empty on root_mem_cgroup. Something like following.
>

Basically we don't need to add more complexity in kernel like
async/workers/timeouts/workqueues to run force_empty, if we expose a
way to force_empty offlined memcgs.

> ---
>  mm/memcontrol.c | 22 +++++++++++++++-------
>  1 file changed, 15 insertions(+), 7 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a4ac554be7e8..51daa2935c41 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2898,14 +2898,16 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>   *
>   * Caller is responsible for holding css reference for memcg.
>   */
> -static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
> +static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool online)
>  {
>         int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>
>         /* we call try-to-free pages for make this cgroup empty */
> -       lru_add_drain_all();
>
> -       drain_all_stock(memcg);
> +       if (online) {
> +               lru_add_drain_all();
> +               drain_all_stock(memcg);
> +       }
>
>         /* try to free all pages in this cgroup */
>         while (nr_retries && page_counter_read(&memcg->memory)) {
> @@ -2915,7 +2917,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>                         return -EINTR;
>
>                 progress = try_to_free_mem_cgroup_pages(memcg, 1,
> -                                                       GFP_KERNEL, true);
> +                                                       GFP_KERNEL, online);
>                 if (!progress) {
>                         nr_retries--;
>                         /* maybe some writeback is necessary */
> @@ -2932,10 +2934,16 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
>                                             loff_t off)
>  {
>         struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> +       struct mem_cgroup *mi;
>
> -       if (mem_cgroup_is_root(memcg))
> -               return -EINVAL;
> -       return mem_cgroup_force_empty(memcg) ?: nbytes;
> +       if (mem_cgroup_is_root(memcg)) {
> +               for_each_mem_cgroup_tree(mi, memcg) {
> +                       if (!mem_cgroup_online(mi))
> +                               mem_cgroup_force_empty(mi, false);
> +               }
> +               return 0;
> +       }
> +       return mem_cgroup_force_empty(memcg, true) ?: nbytes;
>  }
>
>  static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
> --
> 2.20.1.321.g9e740568ce-goog
>
