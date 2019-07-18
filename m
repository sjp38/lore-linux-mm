Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63150C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 00:32:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10B2421783
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 00:31:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="B6i9mX1u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10B2421783
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85E1C6B0005; Wed, 17 Jul 2019 20:31:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80D2A8E0001; Wed, 17 Jul 2019 20:31:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FB0C6B000A; Wed, 17 Jul 2019 20:31:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 49EFF6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 20:31:59 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id v3so19913912ywe.21
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:31:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=a5nww+FIgcrkzpl292v2S0tnBBlUcMp0J8Dj1g5VBHs=;
        b=eL+9wlFz+wQ37DuGYIxYur2K9MVxfAYNMruD2Xw/4WZ58nR0g9iOStb2XM5glRKNwk
         VDXxrTCV0jzs4GbpHeqQO4uam/zzA/NUaGHylgNvf9JkHhqh8bJsXo59XZdc+Ic6C4B8
         4w9vmCIDL3Yhw3Oz0PlePoBIF39ROoahCkTqSoDQ5vDA5OxBHFZo5S4wN5k+tMlNsSTP
         wwQ5vU6Qf7x8pSDLR3I2oK2oWQ2GZYSAzlW+QoEuikSVEQC5vWAEcjcdmq8opwHmsw3x
         AIVWKLRdv6XnqAA07W0950FzAhT/VDC5soKfIHkCJZ1dLuFVXBZS4DQ7CZFnrO77LMxs
         fQKw==
X-Gm-Message-State: APjAAAVeCc+cAuu6jJZyqeWdwkMEBijG4KYoX4jE5pjI55RVAyPrGh6O
	C3ZnTLipRMUcG00bZJahuLqm9Y/h51M+HgcVvcbkDzYpgP6mzCJHAer3WRagq7d+M7442L9gsta
	cdWSq0ZPHGJaCImXy/iqMN2oqNpFaU+j1WlG8+taSSN+EjU5UZlt+aUutO+BDhpSDJw==
X-Received: by 2002:a81:af06:: with SMTP id n6mr22258366ywh.449.1563409918970;
        Wed, 17 Jul 2019 17:31:58 -0700 (PDT)
X-Received: by 2002:a81:af06:: with SMTP id n6mr22258323ywh.449.1563409918218;
        Wed, 17 Jul 2019 17:31:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563409918; cv=none;
        d=google.com; s=arc-20160816;
        b=TGjcPqv8gPCV1iqgC6OjXs7vjFWUYUq1eJS46aQpK0ldTNRxjNDFtmAxPnw5vwp/zF
         sTlMuUPD+P9DxNQ1o6VFspeyJG2hZPX2GV557OffdIxYWuZGFJEVMu9NI+LQVSe36Ny3
         q+7F/yzezpB0luiKpgh7LgAZqk8SgtUToEsZ32T1cZvxI0wUz3D8R/dLEKoIRqfc8reT
         wl3oQQiQlz+iHCLRqM/O/CPB6p/Q4aETZlVseiuM7enJmcyqvKdIbd+SEH2L5Um1Tktc
         xfgj8rJxxMAF88xz2sOSgWxwY/Y2l/W3uGqhEeoqyEK/sLIxdpurr48V5Hyeee2wnMA+
         LEnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=a5nww+FIgcrkzpl292v2S0tnBBlUcMp0J8Dj1g5VBHs=;
        b=Xu4Uro+mnhFPW7/szniURuOM710JSyHrbmsVDQ1oHTmRjNJmutq/gmceWJroUOz7FN
         MdSbCxxOvK+z2fOtXJ2fMQIOy40nGDObiNMDdZKtu44pnAobH/PrpFEPNtDSlQoNIVou
         vsuFmW+oBYj16TualpZvmj0ReVPDHEOlSzdnaPpMdpQdZl0OTdFRDEicRtE7QBHS0byr
         06ud1eP4/2v/gcPp7Njei8Axs+cbAWNOHWYHl3+YStQzvSlhzDXLx4FY+Vf5kg4BXcZq
         1HgqaDTcFtE452w2VL9eo+sxYvTllEuzkWP560qjhUYxKrDJ0ASVPvs1fHSESTKFMd70
         +rYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B6i9mX1u;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r124sor3173193ywg.55.2019.07.17.17.31.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 17:31:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B6i9mX1u;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=a5nww+FIgcrkzpl292v2S0tnBBlUcMp0J8Dj1g5VBHs=;
        b=B6i9mX1uS+U7WA4Yuzqi/Y7y/LKa2rAQTxp7s771klDZdOyBFrr/6TrFgA1fmX4Uqt
         13MScyhzNt/Tl9Wj6dfAN8ssGYLS8VnwNZzUafwzPMbrX3vjVLlbW3NuMQSbQYlrVDs1
         LJNNYfl5f1smGgIqGBOlDdv+Q+diKg38+gkDjfiMSnU98RvXOtXpR/Y3luIBHp1nQZ0x
         0Mbpv/R0rHFT9kHS8Yq22QsDf0NWvBqc2WW3Lo4EoS6LsmI041QnoQGtUYRVOG14W9Y8
         wH1XscX8wT6kcx+KO6ge3bF9I93eCHd3ToEOIsitOiSiGJj9RLdG7W6a1Sl/KmdxkhaU
         1coA==
X-Google-Smtp-Source: APXvYqyuXgwTtnh61KbYpzmKDFbt2br21UJhKcNk73HGF2FMWCgzwjx7whZor33iNfoqRjRU2T9HhxRw9wBSzMky5P0=
X-Received: by 2002:a81:4c44:: with SMTP id z65mr25445781ywa.4.1563409917325;
 Wed, 17 Jul 2019 17:31:57 -0700 (PDT)
MIME-Version: 1.0
References: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 17 Jul 2019 17:31:46 -0700
Message-ID: <CALvZod7kBpDC+rdz=-FrLn_jVAEdBNSLNEgAzGKeBe9HpJvkpA@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: avoid printk() iteration under RCU
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 3:55 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> Currently dump_tasks() might call printk() for many thousands times under
> RCU, which might take many minutes for slow consoles. Therefore, split
> dump_tasks() into three stages; take a snapshot of possible OOM victim
> candidates under RCU, dump the snapshot from reschedulable context, and
> destroy the snapshot.
>
> In a future patch, the first stage would be moved to select_bad_process()
> and the third stage would be moved to after oom_kill_process(), and will
> simplify refcount handling.
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Roman Gushchin <guro@fb.com>
> ---
>  include/linux/sched.h |  1 +
>  mm/oom_kill.c         | 67 +++++++++++++++++++++++++--------------------------
>  2 files changed, 34 insertions(+), 34 deletions(-)
>
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 8dc1811..cb6696b 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1246,6 +1246,7 @@ struct task_struct {
>  #ifdef CONFIG_MMU
>         struct task_struct              *oom_reaper_list;
>  #endif
> +       struct list_head                oom_victim_list;

Shouldn't there be INIT_LIST_HEAD(&tsk->oom_victim_list) somewhere?

>  #ifdef CONFIG_VMAP_STACK
>         struct vm_struct                *stack_vm_area;
>  #endif
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index eda2e2a..bd22ca0 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -377,36 +377,13 @@ static void select_bad_process(struct oom_control *oc)
>         }
>  }
>
> -static int dump_task(struct task_struct *p, void *arg)
> -{
> -       struct oom_control *oc = arg;
> -       struct task_struct *task;
> -
> -       if (oom_unkillable_task(p))
> -               return 0;
> -
> -       /* p may not have freeable memory in nodemask */
> -       if (!is_memcg_oom(oc) && !oom_cpuset_eligible(p, oc))
> -               return 0;
>
> -       task = find_lock_task_mm(p);
> -       if (!task) {
> -               /*
> -                * This is a kthread or all of p's threads have already
> -                * detached their mm's.  There's no need to report
> -                * them; they can't be oom killed anyway.
> -                */
> -               return 0;
> +static int add_candidate_task(struct task_struct *p, void *arg)
> +{
> +       if (!oom_unkillable_task(p)) {
> +               get_task_struct(p);
> +               list_add_tail(&p->oom_victim_list, (struct list_head *) arg);
>         }
> -
> -       pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
> -               task->pid, from_kuid(&init_user_ns, task_uid(task)),
> -               task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
> -               mm_pgtables_bytes(task->mm),
> -               get_mm_counter(task->mm, MM_SWAPENTS),
> -               task->signal->oom_score_adj, task->comm);
> -       task_unlock(task);
> -
>         return 0;
>  }
>
> @@ -422,19 +399,41 @@ static int dump_task(struct task_struct *p, void *arg)
>   */
>  static void dump_tasks(struct oom_control *oc)
>  {
> -       pr_info("Tasks state (memory values in pages):\n");
> -       pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> +       static LIST_HEAD(list);
> +       struct task_struct *p;
> +       struct task_struct *t;
>
>         if (is_memcg_oom(oc))
> -               mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
> +               mem_cgroup_scan_tasks(oc->memcg, add_candidate_task, &list);
>         else {
> -               struct task_struct *p;
> -
>                 rcu_read_lock();
>                 for_each_process(p)
> -                       dump_task(p, oc);
> +                       add_candidate_task(p, &list);
>                 rcu_read_unlock();
>         }
> +       pr_info("Tasks state (memory values in pages):\n");
> +       pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> +       list_for_each_entry(p, &list, oom_victim_list) {
> +               cond_resched();
> +               /* p may not have freeable memory in nodemask */
> +               if (!is_memcg_oom(oc) && !oom_cpuset_eligible(p, oc))
> +                       continue;
> +               /* All of p's threads might have already detached their mm's. */
> +               t = find_lock_task_mm(p);
> +               if (!t)
> +                       continue;
> +               pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
> +                       t->pid, from_kuid(&init_user_ns, task_uid(t)),
> +                       t->tgid, t->mm->total_vm, get_mm_rss(t->mm),
> +                       mm_pgtables_bytes(t->mm),
> +                       get_mm_counter(t->mm, MM_SWAPENTS),
> +                       t->signal->oom_score_adj, t->comm);
> +               task_unlock(t);
> +       }
> +       list_for_each_entry_safe(p, t, &list, oom_victim_list) {
> +               list_del(&p->oom_victim_list);
> +               put_task_struct(p);
> +       }
>  }
>
>  static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
> --
> 1.8.3.1
>

