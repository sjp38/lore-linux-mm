Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9D7D6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 16:34:40 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id s33so52601677qtg.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 13:34:40 -0700 (PDT)
Received: from mail-qt0-x230.google.com (mail-qt0-x230.google.com. [2607:f8b0:400d:c0d::230])
        by mx.google.com with ESMTPS id 97si21115555qte.331.2017.06.05.13.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 13:30:40 -0700 (PDT)
Received: by mail-qt0-x230.google.com with SMTP id u12so79553959qth.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 13:30:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170605202345.GB32498@roeck-us.net>
References: <20170605202345.GB32498@roeck-us.net>
From: Guenter Roeck <groeck@google.com>
Date: Mon, 5 Jun 2017 13:30:39 -0700
Message-ID: <CABXOdTfZiMbLM2crzxdfcr74XoqabXiR5fL3ku=a8owiL6NyJA@mail.gmail.com>
Subject: Re: [hannes@cmpxchg.org: Re: [6/6] mm: memcontrol: account slab stats
 per lruvec]
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Guenter Roeck <linux@roeck-us.net>

Something in my original reply classifies the message as spam. Trying this way.

On Mon, Jun 5, 2017 at 1:23 PM, Guenter Roeck <linux@roeck-us.net> wrote:
> ----- Forwarded message from Johannes Weiner <hannes@cmpxchg.org> -----
>
> Date: Mon, 5 Jun 2017 13:52:54 -0400
> From: Johannes Weiner <hannes@cmpxchg.org>
> To: Guenter Roeck <linux@roeck-us.net>
> Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton
>         <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org,
>         linux-kernel@vger.kernel.org, kernel-team@fb.com
> Subject: Re: [6/6] mm: memcontrol: account slab stats per lruvec
> User-Agent: Mutt/1.8.2 (2017-04-18)
>
> On Mon, Jun 05, 2017 at 09:52:03AM -0700, Guenter Roeck wrote:
>> On Tue, May 30, 2017 at 02:17:24PM -0400, Johannes Weiner wrote:
>> > Josef's redesign of the balancing between slab caches and the page
>> > cache requires slab cache statistics at the lruvec level.
>> >
>> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> > Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
>>
>> Presumably this is already known, but a remarkable number of crashes
>> in next-20170605 bisects to this patch.
>
> Thanks Guenter.
>
> Can you test if the fix below resolves the problem?

xtensa and x86_64 pass after this patch has been applied. arm and
aarch64 still crash with the same symptoms. I didn't test any others.

Crash log for arm is at
http://kerneltests.org/builders/qemu-arm-next/builds/711/steps/qemubuildcommand/logs/stdio

Guenter

>
> ---
>
> From 47007dfcd7873cb93d11466a93b1f41f6a7a434f Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Sun, 4 Jun 2017 07:02:44 -0400
> Subject: [PATCH] mm: memcontrol: per-lruvec stats infrastructure fix 2
>
> Even with the previous fix routing !page->mem_cgroup stats to the root
> cgroup, we still see crashes in certain configurations as the root is
> not initialized for the earliest possible accounting sites in certain
> configurations.
>
> Don't track uncharged pages at all, not even in the root. This takes
> care of early accounting as well as special pages that aren't tracked.
>
> Because we still need to account at the pgdat level, we can no longer
> implement the lruvec_page_state functions on top of the lruvec_state
> ones. But that's okay. It was a little silly to look up the nodeinfo
> and descend to the lruvec, only to container_of() back to the nodeinfo
> where the lruvec_stat structure is sitting.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index bea6f08e9e16..da9360885260 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -585,27 +585,27 @@ static inline void mod_lruvec_state(struct lruvec *lruvec,
>  static inline void __mod_lruvec_page_state(struct page *page,
>                                            enum node_stat_item idx, int val)
>  {
> -       struct mem_cgroup *memcg;
> -       struct lruvec *lruvec;
> -
> -       /* Special pages in the VM aren't charged, use root */
> -       memcg = page->mem_cgroup ? : root_mem_cgroup;
> +       struct mem_cgroup_per_node *pn;
>
> -       lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
> -       __mod_lruvec_state(lruvec, idx, val);
> +       __mod_node_page_state(page_pgdat(page), idx, val);
> +       if (mem_cgroup_disabled() || !page->mem_cgroup)
> +               return;
> +       __mod_memcg_state(page->mem_cgroup, idx, val);
> +       pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
> +       __this_cpu_add(pn->lruvec_stat->count[idx], val);
>  }
>
>  static inline void mod_lruvec_page_state(struct page *page,
>                                          enum node_stat_item idx, int val)
>  {
> -       struct mem_cgroup *memcg;
> -       struct lruvec *lruvec;
> -
> -       /* Special pages in the VM aren't charged, use root */
> -       memcg = page->mem_cgroup ? : root_mem_cgroup;
> +       struct mem_cgroup_per_node *pn;
>
> -       lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
> -       mod_lruvec_state(lruvec, idx, val);
> +       mod_node_page_state(page_pgdat(page), idx, val);
> +       if (mem_cgroup_disabled() || !page->mem_cgroup)
> +               return;
> +       mod_memcg_state(page->mem_cgroup, idx, val);
> +       pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
> +       this_cpu_add(pn->lruvec_stat->count[idx], val);
>  }
>
>  unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
> --
> 2.13.0
>
>
> ----- End forwarded message -----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
