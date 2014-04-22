Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 077D26B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:04:11 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id rd18so4895226iec.29
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 00:04:11 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id l9si10926195igm.4.2014.04.22.00.04.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 00:04:11 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id hl10so2644055igb.0
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 00:04:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2c63c535f8202c6b605300a834cdf1c07d1bafc3.1398147734.git.nasa4836@gmail.com>
References: <cover.1398147734.git.nasa4836@gmail.com> <2c63c535f8202c6b605300a834cdf1c07d1bafc3.1398147734.git.nasa4836@gmail.com>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 22 Apr 2014 15:03:31 +0800
Message-ID: <CAHz2CGW+yjt6yXDDn-pjykSf-q03YsD5acmuhDkSCg_iXKA88Q@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/memcontrol.c: use accessor to get id from css
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

Cc Andrew.

Thanks,
Jianyu Zhan


On Tue, Apr 22, 2014 at 2:30 PM, Jianyu Zhan <nasa4836@gmail.com> wrote:
> This is a prepared patch for converting from per-cgroup id to
> per-subsystem id.
>
> We should not access per-cgroup id directly, since this is implemetation
> detail. Use the accessor css_from_id() instead.
>
> This patch has no functional change.
>
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> ---
>  mm/memcontrol.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 80d9e38..46333cb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -528,10 +528,10 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>  static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
>  {
>         /*
> -        * The ID of the root cgroup is 0, but memcg treat 0 as an
> -        * invalid ID, so we return (cgroup_id + 1).
> +        * The ID of css for the root cgroup is 0, but memcg treat 0 as an
> +        * invalid ID, so we return (id + 1).
>          */
> -       return memcg->css.cgroup->id + 1;
> +       return css_to_id(&memcg->css) + 1;
>  }
>
>  static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
> @@ -6407,7 +6407,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>         struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>         struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(css));
>
> -       if (css->cgroup->id > MEM_CGROUP_ID_MAX)
> +       if (css_to_id(css) > MEM_CGROUP_ID_MAX)
>                 return -ENOSPC;
>
>         if (!parent)
> --
> 2.0.0-rc0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
