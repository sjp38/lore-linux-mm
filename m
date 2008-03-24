Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m2OF3xmV011449
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 15:03:59 GMT
Received: from py-out-1112.google.com (pygz59.prod.google.com [10.34.227.59])
	by zps78.corp.google.com with ESMTP id m2OF3vM4005383
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 08:03:58 -0700
Received: by py-out-1112.google.com with SMTP id z59so2784253pyg.27
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 08:03:57 -0700 (PDT)
Message-ID: <6599ad830803240803s5160101bi2bf68b36085f777f@mail.gmail.com>
Date: Mon, 24 Mar 2008 08:03:56 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Memory controller add mm->owner
In-Reply-To: <20080324140142.28786.97267.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324140142.28786.97267.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 7:01 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  --- linux-2.6.25-rc5/include/linux/mm_types.h~memory-controller-add-mm-owner    2008-03-20 13:35:09.000000000 +0530
>  +++ linux-2.6.25-rc5-balbir/include/linux/mm_types.h    2008-03-20 15:11:05.000000000 +0530
>  @@ -228,7 +228,10 @@ struct mm_struct {
>         rwlock_t                ioctx_list_lock;
>         struct kioctx           *ioctx_list;
>   #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  -       struct mem_cgroup *mem_cgroup;
>  +       struct task_struct *owner;      /* The thread group leader that */
>  +                                       /* owns the mm_struct. This     */
>  +                                       /* might be useful even outside */
>  +                                       /* of the config option         */
>   #endif

This should probably be controlled by something like a CONFIG_MM_OWNER
that's selected by any Kconfig option (mem cgroup, etc) that needs
mm->owner to be maintained.

>  @@ -248,12 +248,40 @@ void mm_init_cgroup(struct mm_struct *mm
>
>         mem = mem_cgroup_from_task(p);
>         css_get(&mem->css);
>  -       mm->mem_cgroup = mem;
>  +       mm->owner = p;
>  +}
>  +
>  +void mem_cgroup_fork_init(struct task_struct *p)
>  +{
>  +       struct mm_struct *mm = get_task_mm(p);
>  +       struct mem_cgroup *mem, *oldmem;
>  +       if (!mm)
>  +               return;
>  +
>  +       /*
>  +        * Initial owner at mm_init_cgroup() time is the task itself.
>  +        * The thread group leader had not been setup then
>  +        */
>  +       oldmem = mem_cgroup_from_task(mm->owner);
>  +       /*
>  +        * Override the mm->owner after we know the thread group later
>  +        */
>  +       mm->owner = p->group_leader;
>  +       mem = mem_cgroup_from_task(mm->owner);
>  +       css_get(&mem->css);
>  +       css_put(&oldmem->css);
>  +       mmput(mm);
>   }
>
>   void mm_free_cgroup(struct mm_struct *mm)
>   {
>  -       css_put(&mm->mem_cgroup->css);
>  +       struct mem_cgroup *mem;
>  +
>  +       /*
>  +        * TODO: Should we assign mm->owner to NULL here?
>  +        */
>  +       mem = mem_cgroup_from_task(mm->owner);
>  +       css_put(&mem->css);
>   }

It seems to me that the code to setup/maintain mm->owner should be
independent of the control groups, but should be part of the generic
fork/exit code.

Also, if mm->owner exits but mm is still alive (unlikely, but could
happen with weird custom threading libraries?) then we need to
reassign mm->owner to one of the other users of the mm (by looking
first in the thread group, then among the parents/siblings/children,
and then among all processes as a last resort?)

>
>  -       rcu_read_lock();
>  -       mem = rcu_dereference(mm->mem_cgroup);
>  +       mem = mem_cgroup_from_task(mm->owner);

I think we still need the rcu_read_lock(), since mm->owner can move
cgroups any time.

>
>  @@ -1069,7 +1096,6 @@ static void mem_cgroup_move_task(struct
>                 goto out;
>
>         css_get(&mem->css);
>  -       rcu_assign_pointer(mm->mem_cgroup, mem);
>         css_put(&old_mem->css);
>

We shouldn't need reference counting on this pointer, since the
cgroups framework won't allow a subsystem to be freed while it has any
tasks in it.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
