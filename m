Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70BE06B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 02:11:39 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w8-v6so3995745qkf.8
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 23:11:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h188-v6sor1924094qkc.2.2018.08.02.23.11.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 23:11:38 -0700 (PDT)
MIME-Version: 1.0
References: <1533275285-12387-1-git-send-email-zhaoyang.huang@spreadtrum.com>
In-Reply-To: <1533275285-12387-1-git-send-email-zhaoyang.huang@spreadtrum.com>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Fri, 3 Aug 2018 14:11:26 +0800
Message-ID: <CAGWkznE_Z+eJ+81eZN_KT7KXSFyCxfoafeMFSzirT7OaL+vbRA@mail.gmail.com>
Subject: Re: [PATCH v1] mm:memcg: skip memcg of current in mem_cgroup_soft_limit_reclaim
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org

On Fri, Aug 3, 2018 at 1:48 PM Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
>
> for the soft_limit reclaim has more directivity than global reclaim, we40960
> have current memcg be skipped to avoid potential page thrashing.
>
The patch is tested in our android system with 2GB ram.  The case
mainly focus on the smooth slide of pictures on a gallery, which used
to stall on the direct reclaim for over several hundred
millionseconds. By further debugging, we find that the direct reclaim
spend most of time to reclaim pages on its own with softlimit set to
40960KB. I add a ftrace event to verify that the patch can help
escaping such scenario. Furthermore, we also measured the major fault
of this process(by dumpsys of android). The result is the patch can
help to reduce 20% of the major fault during the test.

> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
> ---
>  mm/memcontrol.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8c0280b..9d09e95 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2537,12 +2537,21 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
>                         mz = mem_cgroup_largest_soft_limit_node(mctz);
>                 if (!mz)
>                         break;
> -
> +               /*
> +                * skip current memcg to avoid page thrashing, for the
> +                * mem_cgroup_soft_reclaim has more directivity than
> +                * global reclaim.
> +                */
> +               if (get_mem_cgroup_from_mm(current->mm) == mz->memcg) {
> +                       reclaimed = 0;
> +                       goto next;
> +               }
>                 nr_scanned = 0;
>                 reclaimed = mem_cgroup_soft_reclaim(mz->memcg, pgdat,
>                                                     gfp_mask, &nr_scanned);
>                 nr_reclaimed += reclaimed;
>                 *total_scanned += nr_scanned;
> +next:
>                 spin_lock_irq(&mctz->lock);
>                 __mem_cgroup_remove_exceeded(mz, mctz);
>
> --
> 1.9.1
>
