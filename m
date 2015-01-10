Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1716B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 19:54:34 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so21448289pab.12
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:54:33 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id c8si15432321pat.105.2015.01.09.16.54.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 16:54:32 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id z10so20329621pdj.0
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:54:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1420801555-22659-6-git-send-email-mhocko@suse.cz>
References: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
	<1420801555-22659-6-git-send-email-mhocko@suse.cz>
Date: Fri, 9 Jan 2015 16:54:31 -0800
Message-ID: <CAM_iQpVZT4Wd+5CX4MxaCtuPzU8u7fXn+XfJVdXq4LZ8jXNu6Q@mail.gmail.com>
Subject: Re: [PATCH -v3 5/5] oom, PM: make OOM detection in the freezer path raceless
From: Cong Wang <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "\\Rafael J. Wysocki\\" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>

On Fri, Jan 9, 2015 at 3:05 AM, Michal Hocko <mhocko@suse.cz> wrote:
>  /**
>   * freeze_processes - Signal user space processes to enter the refrigerator.
>   * The current thread will not be frozen.  The same process that calls
> @@ -142,7 +118,6 @@ static bool check_frozen_processes(void)
>  int freeze_processes(void)
>  {
>         int error;
> -       int oom_kills_saved;
>
>         error = __usermodehelper_disable(UMH_FREEZING);
>         if (error)
> @@ -157,29 +132,22 @@ int freeze_processes(void)
>         pm_wakeup_clear();
>         pr_info("Freezing user space processes ... ");
>         pm_freezing = true;
> -       oom_kills_saved = oom_kills_count();
>         error = try_to_freeze_tasks(true);
>         if (!error) {
>                 __usermodehelper_set_disable_depth(UMH_DISABLED);
> -               oom_killer_disable();
> -
> -               /*
> -                * There might have been an OOM kill while we were
> -                * freezing tasks and the killed task might be still
> -                * on the way out so we have to double check for race.
> -                */
> -               if (oom_kills_count() != oom_kills_saved &&
> -                   !check_frozen_processes()) {
> -                       __usermodehelper_set_disable_depth(UMH_ENABLED);
> -                       pr_cont("OOM in progress.");
> -                       error = -EBUSY;
> -               } else {
> -                       pr_cont("done.");
> -               }
> +               pr_cont("done.");
>         }
>         pr_cont("\n");
>         BUG_ON(in_atomic());
>
> +       /*
> +        * Now that the whole userspace is frozen we need to disbale


disable


> +        * the OOM killer to disallow any further interference with
> +        * killable tasks.
> +        */
> +       if (!error && !oom_killer_disable())
> +               error = -EBUSY;
> +
[...]
>  void unmark_oom_victim(void)
>  {
> -       clear_thread_flag(TIF_MEMDIE);
> +       if (!test_and_clear_thread_flag(TIF_MEMDIE))
> +               return;
> +
> +       down_read(&oom_sem);
> +       /*
> +        * There is no need to signal the lasst oom_victim if there

last

> +        * is nobody who cares.
> +        */
> +       if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
> +               wake_up_all(&oom_victims_wait);
> +       up_read(&oom_sem);
> +}
[...]
>  /*
>   * The pagefault handler calls here because it is out of memory, so kill a
>   * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
> @@ -727,12 +806,25 @@ void pagefault_out_of_memory(void)
>  {
>         struct zonelist *zonelist;
>
> +       down_read(&oom_sem);
>         if (mem_cgroup_oom_synchronize(true))
> -               return;
> +               goto unlock;
>
>         zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
>         if (oom_zonelist_trylock(zonelist, GFP_KERNEL)) {
> -               out_of_memory(NULL, 0, 0, NULL, false);
> +               if (!oom_killer_disabled)
> +                       __out_of_memory(NULL, 0, 0, NULL, false);
> +               else
> +                       /*
> +                        * There shouldn't be any user tasks runable while the

runnable


> +                        * OOM killer is disabled so the current task has to
> +                        * be a racing OOM victim for which oom_killer_disable()
> +                        * is waiting for.
> +                        */
> +                       WARN_ON(test_thread_flag(TIF_MEMDIE));
> +
>                 oom_zonelist_unlock(zonelist, GFP_KERNEL);
>         }
> +unlock:
> +       up_read(&oom_sem);
>  }


Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
