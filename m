Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 610C06B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 17:17:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so273806wmr.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 14:17:35 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id lp5si29154397wjb.121.2016.06.27.14.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 14:17:34 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id r201so108628wme.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 14:17:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1467029719-17602-2-git-send-email-mhocko@kernel.org>
References: <1467029719-17602-1-git-send-email-mhocko@kernel.org> <1467029719-17602-2-git-send-email-mhocko@kernel.org>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 27 Jun 2016 23:17:33 +0200
Message-ID: <CAJZ5v0iGE+4RYq81GwyF3H-si06H_qPOqkrtzNZw7CC9E4h2ww@mail.gmail.com>
Subject: Re: [PATCH 1/2] freezer, oom: check TIF_MEMDIE on the correct task
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Miao Xie <miaox@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Jun 27, 2016 at 2:15 PM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> freezing_slow_path is checking TIF_MEMDIE to skip OOM killed
> tasks. It is, however, checking the flag on the current task rather than
> the given one. This is really confusing because freezing() can be called
> also on !current tasks. It would end up working correctly for its main
> purpose because __refrigerator will be always called on the current task
> so the oom victim will never get frozen. But it could lead to surprising
> results when a task which is freezing a cgroup got oom killed because
> only part of the cgroup would get frozen. This is highly unlikely but
> worth fixing as the resulting code would be more clear anyway.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks reasonable to me, so ACK.

> ---
>  kernel/freezer.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/kernel/freezer.c b/kernel/freezer.c
> index a8900a3bc27a..6f56a9e219fa 100644
> --- a/kernel/freezer.c
> +++ b/kernel/freezer.c
> @@ -42,7 +42,7 @@ bool freezing_slow_path(struct task_struct *p)
>         if (p->flags & (PF_NOFREEZE | PF_SUSPEND_TASK))
>                 return false;
>
> -       if (test_thread_flag(TIF_MEMDIE))
> +       if (test_tsk_thread_flag(p, TIF_MEMDIE))
>                 return false;
>
>         if (pm_nosig_freezing || cgroup_freezing(p))
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
