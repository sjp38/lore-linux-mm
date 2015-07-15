Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 43D0B2802A6
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 14:59:23 -0400 (EDT)
Received: by ieik3 with SMTP id k3so40668013iei.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 11:59:23 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com. [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id lq3si11768662igb.3.2015.07.15.11.59.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 11:59:22 -0700 (PDT)
Received: by ietj16 with SMTP id j16so40460202iet.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 11:59:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <40a2af5afc7b70a133737226cd9e975df42936e7.1436967694.git.vdavydov@parallels.com>
References: <cover.1436967694.git.vdavydov@parallels.com>
	<40a2af5afc7b70a133737226cd9e975df42936e7.1436967694.git.vdavydov@parallels.com>
Date: Wed, 15 Jul 2015 11:59:22 -0700
Message-ID: <CAJu=L5_Hc-p7n79S-qoSepFR4nVhjR8QkFysKvWPvzb5tqhZOw@mail.gmail.com>
Subject: Re: [PATCH -mm v8 1/7] memcg: add page_cgroup_ino helper
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 15, 2015 at 6:54 AM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> This function returns the inode number of the closest online ancestor of
> the memory cgroup a page is charged to. It is required for exporting
> information about which page is charged to which cgroup to userspace,
> which will be introduced by a following patch.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>

> ---
>  include/linux/memcontrol.h |  1 +
>  mm/memcontrol.c            | 23 +++++++++++++++++++++++
>  2 files changed, 24 insertions(+)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 73b02b0a8f60..50069abebc3c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -116,6 +116,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
>
>  extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
>  extern struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
> +extern unsigned long page_cgroup_ino(struct page *page);
>
>  struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
>                                    struct mem_cgroup *,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index acb93c554f6e..894dc2169979 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -631,6 +631,29 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
>         return &memcg->css;
>  }
>
> +/**
> + * page_cgroup_ino - return inode number of the memcg a page is charged to
> + * @page: the page
> + *
> + * Look up the closest online ancestor of the memory cgroup @page is charged to
> + * and return its inode number or 0 if @page is not charged to any cgroup. It
> + * is safe to call this function without holding a reference to @page.
> + */
> +unsigned long page_cgroup_ino(struct page *page)
> +{
> +       struct mem_cgroup *memcg;
> +       unsigned long ino = 0;
> +
> +       rcu_read_lock();
> +       memcg = READ_ONCE(page->mem_cgroup);
> +       while (memcg && !(memcg->css.flags & CSS_ONLINE))
> +               memcg = parent_mem_cgroup(memcg);
> +       if (memcg)
> +               ino = cgroup_ino(memcg->css.cgroup);
> +       rcu_read_unlock();
> +       return ino;
> +}
> +
>  static struct mem_cgroup_per_zone *
>  mem_cgroup_page_zoneinfo(struct mem_cgroup *memcg, struct page *page)
>  {
> --
> 2.1.4
>



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
