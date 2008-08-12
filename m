Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m7C0dYcs012946
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 01:39:35 +0100
Received: from yx-out-1718.google.com (yxh36.prod.google.com [10.190.2.228])
	by zps19.corp.google.com with ESMTP id m7C0dXkg011588
	for <linux-mm@kvack.org>; Mon, 11 Aug 2008 17:39:34 -0700
Received: by yx-out-1718.google.com with SMTP id 36so800951yxh.4
        for <linux-mm@kvack.org>; Mon, 11 Aug 2008 17:39:33 -0700 (PDT)
Message-ID: <6599ad830808111739x27078313x16ac270b42abee3c@mail.gmail.com>
Date: Mon, 11 Aug 2008 17:39:33 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 2/2] Memory rlimit enhance mm_owner_changed callback to deal with exited owner
In-Reply-To: <20080811100743.26336.6497.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
	 <20080811100743.26336.6497.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 11, 2008 at 3:07 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>
> mm_owner_changed callback can also be called with new task set to NULL.
> (race between try_to_unuse() and mm->owner exiting). Surprisingly the order
> of cgroup arguments being passed was incorrect (proves that we did not
> run into mm_owner_changed callback at all).
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Acked-by: Paul Menage <menage@google.com>


> ---
>
>  mm/memrlimitcgroup.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
>
> diff -puN mm/memrlimitcgroup.c~memrlimit-handle-mm-owner-notification-with-task-null mm/memrlimitcgroup.c
> --- linux-2.6.27-rc1/mm/memrlimitcgroup.c~memrlimit-handle-mm-owner-notification-with-task-null 2008-08-05 10:56:56.000000000 +0530
> +++ linux-2.6.27-rc1-balbir/mm/memrlimitcgroup.c        2008-08-05 11:24:04.000000000 +0530
> @@ -73,6 +73,12 @@ void memrlimit_cgroup_uncharge_as(struct
>  {
>        struct memrlimit_cgroup *memrcg;
>
> +       /*
> +        * Uncharge happened as a part of the mm_owner_changed callback
> +        */
> +       if (!mm->owner)
> +               return;
> +
>        memrcg = memrlimit_cgroup_from_task(mm->owner);
>        res_counter_uncharge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
>  }
> @@ -235,8 +241,8 @@ out:
>  * This callback is called with mmap_sem held
>  */
>  static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
> -                                               struct cgroup *cgrp,
>                                                struct cgroup *old_cgrp,
> +                                               struct cgroup *cgrp,
>                                                struct task_struct *p)
>  {
>        struct memrlimit_cgroup *memrcg, *old_memrcg;
> @@ -246,7 +252,12 @@ static void memrlimit_cgroup_mm_owner_ch
>        memrcg = memrlimit_cgroup_from_cgrp(cgrp);
>        old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
>
> -       if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
> +       /*
> +        * If we don't have a new cgroup, we just uncharge from the old one.
> +        * It means that the task is going away
> +        */
> +       if (memrcg &&
> +           res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
>                goto out;
>        res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
>  out:
> _
>
> --
>        Warm Regards,
>        Balbir Singh
>        Linux Technology Center
>        IBM, ISTL
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
