Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87FA0280941
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 22:40:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e129so193406348pfh.1
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 19:40:53 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id h8si11636094plk.10.2017.03.10.19.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 19:40:52 -0800 (PST)
Received: by mail-pf0-x22c.google.com with SMTP id w189so48756925pfb.0
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 19:40:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1489198798-6632-1-git-send-email-ysxie@foxmail.com>
References: <1489198798-6632-1-git-send-email-ysxie@foxmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 10 Mar 2017 19:40:51 -0800
Message-ID: <CALvZod5X3sLQT-We2VNCiAN9zi9MJvdk4fVGERVpw=GQGrGHEg@mail.gmail.com>
Subject: Re: [PATCH RFC] mm/vmscan: donot retry shrink zones when memcg is disabled
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <ysxie@foxmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, riel@redhat.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, xieyisheng1@huawei.com

On Fri, Mar 10, 2017 at 6:19 PM, Yisheng Xie <ysxie@foxmail.com> wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
>
> When we enter do_try_to_free_pages, the may_thrash is always clear, and
> it will retry shrink zones to tap cgroup's reserves memory by setting
> may_thrash when the former shrink_zones reclaim nothing.
>
> However, if CONFIG_MEMCG=n, it should not do this useless retry at all,
> for we do not have any cgroup's reserves memory to tap, and we have
> already done hard work and made no progress.
>
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bc8031e..b03ccc1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2808,7 +2808,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>                 return 1;
>
>         /* Untapped cgroup reserves?  Don't OOM, retry. */
> -       if (!sc->may_thrash) {
> +       if (!sc->may_thrash && IS_ENABLED(CONFIG_MEMCG)) {

In my opinion it should be even more restrictive (restricting
cgroup_disabled=memory boot option and cgroup legacy hierarchy). So,
instead of IS_ENABLED(CONFIG_MEMCG), the check should be something
like (cgroup_subsys_enabled(memory_cgrp_subsys) &&
cgroup_subsys_on_dfl(memory_cgrp_subsys)).

>                 sc->priority = initial_priority;
>                 sc->may_thrash = 1;
>                 goto retry;
> --
> 1.9.1
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
