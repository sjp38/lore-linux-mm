Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46C466B000A
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 20:54:26 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id t14-v6so11468810uao.6
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 17:54:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h23-v6sor8599120vkh.72.2018.08.14.17.54.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Aug 2018 17:54:25 -0700 (PDT)
MIME-Version: 1.0
References: <20180815003620.15678-1-guro@fb.com> <20180815003620.15678-2-guro@fb.com>
In-Reply-To: <20180815003620.15678-2-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 14 Aug 2018 17:54:13 -0700
Message-ID: <CALvZod4qhJA3NHnV_cTO0XEH1d4u62vxwug707sti7cZL6bgPw@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm: drain memcg stocks on css offlining
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, koct9i@gmail.com, Tejun Heo <tj@kernel.org>

On Tue, Aug 14, 2018 at 5:36 PM Roman Gushchin <guro@fb.com> wrote:
>
> Memcg charge is batched using per-cpu stocks, so an offline memcg
> can be pinned by a cached charge up to a moment, when a process
> belonging to some other cgroup will charge some memory on the same
> cpu. In other words, cached charges can prevent a memory cgroup
> from being reclaimed for some time, without any clear need.
>
> Let's optimize it by explicit draining of all stocks on css offlining.
> As draining is performed asynchronously, and is skipped if any
> parallel draining is happening, it's cheap.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Seems reasonable.

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4e3c1315b1de..cfb64b5b9957 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4575,6 +4575,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>         memcg_offline_kmem(memcg);
>         wb_memcg_offline(memcg);
>
> +       drain_all_stock(memcg);
> +
>         mem_cgroup_id_put(memcg);
>  }
>
> --
> 2.14.4
>
