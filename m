Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A92546B000A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 20:11:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i14-v6so5407793wrq.1
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 17:11:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t130-v6sor911157wmf.64.2018.06.22.17.11.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 17:11:01 -0700 (PDT)
MIME-Version: 1.0
References: <CALvZod7G-ggYTpmdDsNeQRf4upYa34ccOerVmEkEkLOVFrBr2w@mail.gmail.com>
 <20180623000600.5818-1-guro@fb.com> <20180623000600.5818-2-guro@fb.com>
In-Reply-To: <20180623000600.5818-2-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 22 Jun 2018 17:10:48 -0700
Message-ID: <CALvZod7-VAjyHE7f7bLx7c_1LpWtCy2VV=fB0GLR4bNr1MMx9w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: introduce mem_cgroup_put() helper
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 22, 2018 at 5:06 PM Roman Gushchin <guro@fb.com> wrote:
>
> Introduce the mem_cgroup_put() helper, which helps to eliminate
> guarding memcg css release with "#ifdef CONFIG_MEMCG" in multiple
> places.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memcontrol.h | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index cf1c3555328f..3607913032be 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -383,6 +383,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
>         return css ? container_of(css, struct mem_cgroup, css) : NULL;
>  }
>
> +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> +{
> +       css_put(&memcg->css);
> +}
> +
>  #define mem_cgroup_from_counter(counter, member)       \
>         container_of(counter, struct mem_cgroup, member)
>
> @@ -852,6 +857,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
>         return true;
>  }
>
> +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> +{
> +}
> +
>  static inline struct mem_cgroup *
>  mem_cgroup_iter(struct mem_cgroup *root,
>                 struct mem_cgroup *prev,
> --
> 2.14.4
>
