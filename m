Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 22915280947
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 12:52:18 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id l66so221561075pfl.6
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 09:52:18 -0800 (PST)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id s196si6757364pfs.153.2017.03.11.09.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Mar 2017 09:52:17 -0800 (PST)
Received: by mail-pg0-x233.google.com with SMTP id 25so49812332pgy.0
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 09:52:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1489240264-3290-1-git-send-email-ysxie@foxmail.com>
References: <1489240264-3290-1-git-send-email-ysxie@foxmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 11 Mar 2017 09:52:15 -0800
Message-ID: <CALvZod6dptidW33mpvSkQfMBM=xsfSPEEJzB+3u4ekr8m3bSOA@mail.gmail.com>
Subject: Re: [PATCH v2 RFC] mm/vmscan: more restrictive condition for retry in do_try_to_free_pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <ysxie@foxmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, riel@redhat.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, xieyisheng1@huawei.com, guohanjun@huawei.com, Xishi Qiu <qiuxishi@huawei.com>

On Sat, Mar 11, 2017 at 5:51 AM, Yisheng Xie <ysxie@foxmail.com> wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
>
> When we enter do_try_to_free_pages, the may_thrash is always clear, and
> it will retry shrink zones to tap cgroup's reserves memory by setting
> may_thrash when the former shrink_zones reclaim nothing.
>
> However, when memcg is disabled or on legacy hierarchy, it should not do
> this useless retry at all, for we do not have any cgroup's reserves
> memory to tap, and we have already done hard work but made no progress.
>
> To avoid this time costly and useless retrying, add a stub function
> may_thrash and return true when memcg is disabled or on legacy
> hierarchy.
>
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Shakeel Butt <shakeelb@google.com>
> ---
> v2:
>  - more restrictive condition for retry of shrink_zones (restricting
>    cgroup_disabled=memory boot option and cgroup legacy hierarchy) - Shakeel
>
>  - add a stub function may_thrash() to avoid compile error or warning.
>
>  - rename subject from "donot retry shrink zones when memcg is disable"
>    to "more restrictive condition for retry in do_try_to_free_pages"
>
> Any comment is more than welcome!
>
> Thanks
> Yisheng Xie
>
>  mm/vmscan.c | 20 +++++++++++++++++++-
>  1 file changed, 19 insertions(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bc8031e..415f800 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -184,6 +184,19 @@ static bool sane_reclaim(struct scan_control *sc)
>  #endif
>         return false;
>  }
> +
> +static bool may_thrash(struct scan_control *sc)
> +{
> +       /*
> +        * When memcg is disabled or on legacy hierarchy, there is no cgroup
> +        * reserves memory to tap.
> +        */
> +       if (!cgroup_subsys_enabled(memory_cgrp_subsys) ||
> +           !cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +               return true;
> +
> +       return sc->may_thrash;
> +}
>  #else
>  static bool global_reclaim(struct scan_control *sc)
>  {
> @@ -194,6 +207,11 @@ static bool sane_reclaim(struct scan_control *sc)
>  {
>         return true;
>  }
> +
> +static bool may_thrash(struct scan_control *sc)
> +{
> +       return true;
> +}
>  #endif
>
>  /*
> @@ -2808,7 +2826,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>                 return 1;
>
>         /* Untapped cgroup reserves?  Don't OOM, retry. */
> -       if (!sc->may_thrash) {
> +       if (!may_thrash(sc)) {

Thanks Yisheng. The name of the function may_thrash() is confusing in
the sense that it is returning exactly the opposite of what its name
implies. How about reversing the condition of may_thrash() function
and change the scan_control's field may_thrash to thrashed?

>                 sc->priority = initial_priority;
>                 sc->may_thrash = 1;
>                 goto retry;
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
