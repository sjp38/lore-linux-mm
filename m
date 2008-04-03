From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v5)
Date: Thu, 03 Apr 2008 14:19:42 +0800
Message-ID: <47F476FE.6040800@cn.fujitsu.com>
References: <20080403055901.31796.41411.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760456AbYDCGV7@vger.kernel.org>
In-Reply-To: <20080403055901.31796.41411.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Balbir Singh wrote:
> Changelog v4
> ------------
> 1. Release rcu_read_lock() after acquiring task_lock(). Also get a reference
>    to the task_struct
> 2. Change cgroup mm_owner_changed callback to callback only if the
>    cgroup of old and new task is different and to pass the old and new
>    cgroups instead of task pointers
> 3. Port the patch to 2.6.25-rc8-mm1
> 
> Changelog v3
> ------------
> 
> 1. Add mm->owner change callbacks using cgroups
> 
> This patch removes the mem_cgroup member from mm_struct and instead adds
> an owner. This approach was suggested by Paul Menage. The advantage of
> this approach is that, once the mm->owner is known, using the subsystem
> id, the cgroup can be determined. It also allows several control groups
> that are virtually grouped by mm_struct, to exist independent of the memory
> controller i.e., without adding mem_cgroup's for each controller,
> to mm_struct.
> 
> A new config option CONFIG_MM_OWNER is added and the memory resource
> controller selects this config option.
> 
> This patch also adds cgroup callbacks to notify subsystems when mm->owner
> changes. The mm_cgroup_changed callback is called with the task_lock()
> of the new task held and is called just prior to changing the mm->owner.
> 
> I am indebted to Paul Menage for the several reviews of this patchset
> and helping me make it lighter and simpler.
> 
> This patch was tested on a powerpc box.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  fs/exec.c                  |    1 
>  include/linux/cgroup.h     |   15 ++++++++
>  include/linux/init_task.h  |    2 -
>  include/linux/memcontrol.h |   17 ++-------
>  include/linux/mm_types.h   |    5 +-
>  include/linux/sched.h      |   14 ++++++++
>  init/Kconfig               |   15 ++++++++
>  kernel/cgroup.c            |   30 +++++++++++++++++
>  kernel/exit.c              |   77 +++++++++++++++++++++++++++++++++++++++++++++
>  kernel/fork.c              |   11 ++++--
>  mm/memcontrol.c            |   21 +-----------
>  11 files changed, 171 insertions(+), 37 deletions(-)
> 
> diff -puN fs/exec.c~memory-controller-add-mm-owner fs/exec.c
> --- linux-2.6.25-rc8/fs/exec.c~memory-controller-add-mm-owner	2008-04-03 10:08:23.000000000 +0530
> +++ linux-2.6.25-rc8-balbir/fs/exec.c	2008-04-03 10:08:23.000000000 +0530
> @@ -735,6 +735,7 @@ static int exec_mmap(struct mm_struct *m
>  	tsk->active_mm = mm;
>  	activate_mm(active_mm, mm);
>  	task_unlock(tsk);
> +	mm_update_next_owner(mm);
>  	arch_pick_mmap_layout(mm);
>  	if (old_mm) {
>  		up_read(&old_mm->mmap_sem);
> diff -puN include/linux/cgroup.h~memory-controller-add-mm-owner include/linux/cgroup.h
> --- linux-2.6.25-rc8/include/linux/cgroup.h~memory-controller-add-mm-owner	2008-04-03 10:08:23.000000000 +0530
> +++ linux-2.6.25-rc8-balbir/include/linux/cgroup.h	2008-04-03 10:33:25.000000000 +0530
> @@ -300,6 +300,12 @@ struct cgroup_subsys {
>  			struct cgroup *cgrp);
>  	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
> +	/*
> +	 * This routine is called with the task_lock of mm->owner held
> +	 */
> +	void (*mm_owner_changed)(struct cgroup_subsys *ss,
> +					struct cgroup *old,
> +					struct cgroup *new);
>  	int subsys_id;
>  	int active;
>  	int disabled;
> @@ -385,4 +391,13 @@ static inline int cgroupstats_build(stru
>  
>  #endif /* !CONFIG_CGROUPS */
>  
> +#ifdef CONFIG_MM_OWNER
> +extern void
> +cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new);
> +#else /* !CONFIG_MM_OWNER */
> +static inline void
> +cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
> +{
> +}
> +#endif /* CONFIG_MM_OWNER */
>  #endif /* _LINUX_CGROUP_H */
> diff -puN include/linux/init_task.h~memory-controller-add-mm-owner include/linux/init_task.h
> --- linux-2.6.25-rc8/include/linux/init_task.h~memory-controller-add-mm-owner	2008-04-03 10:08:23.000000000 +0530
> +++ linux-2.6.25-rc8-balbir/include/linux/init_task.h	2008-04-03 10:08:23.000000000 +0530
> @@ -57,6 +57,7 @@
>  	.page_table_lock =  __SPIN_LOCK_UNLOCKED(name.page_table_lock),	\
>  	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
>  	.cpu_vm_mask	= CPU_MASK_ALL,				\
> +	.owner		= &init_task,				\

#ifdef CONFIG_MM_OWNER
	.owner		= &init_task,
#endif

Otherwise building broken with CONFIG_MM_OWNER disabled.
