Date: Mon, 5 May 2008 15:15:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 2/4] Enhance cgroup mm_owner_changed callback to
 add task information
Message-Id: <20080505151504.98c28f7c.akpm@linux-foundation.org>
In-Reply-To: <20080503213804.3140.26503.sendpatchset@localhost.localdomain>
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	<20080503213804.3140.26503.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sun, 04 May 2008 03:08:04 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> 
> This patch adds an additional field to the mm_owner callbacks. This field
> is required to get to the mm that changed.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/cgroup.h |    3 ++-
>  kernel/cgroup.c        |    2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff -puN kernel/cgroup.c~cgroup-add-task-to-mm--owner-callbacks kernel/cgroup.c
> --- linux-2.6.25/kernel/cgroup.c~cgroup-add-task-to-mm--owner-callbacks	2008-05-04 02:53:05.000000000 +0530
> +++ linux-2.6.25-balbir/kernel/cgroup.c	2008-05-04 02:53:05.000000000 +0530
> @@ -2772,7 +2772,7 @@ void cgroup_mm_owner_callbacks(struct ta
>  			if (oldcgrp == newcgrp)
>  				continue;
>  			if (ss->mm_owner_changed)
> -				ss->mm_owner_changed(ss, oldcgrp, newcgrp);
> +				ss->mm_owner_changed(ss, oldcgrp, newcgrp, new);
>  		}
>  	}
>  }
> diff -puN include/linux/cgroup.h~cgroup-add-task-to-mm--owner-callbacks include/linux/cgroup.h
> --- linux-2.6.25/include/linux/cgroup.h~cgroup-add-task-to-mm--owner-callbacks	2008-05-04 02:53:05.000000000 +0530
> +++ linux-2.6.25-balbir/include/linux/cgroup.h	2008-05-04 02:53:05.000000000 +0530
> @@ -310,7 +310,8 @@ struct cgroup_subsys {
>  	 */
>  	void (*mm_owner_changed)(struct cgroup_subsys *ss,
>  					struct cgroup *old,
> -					struct cgroup *new);
> +					struct cgroup *new,
> +					struct task_struct *p);

If mm_owner_changed() had any documentation I'd suggest that it be updated.
Sneaky.

The existing comment:

	/*
	 * This routine is called with the task_lock of mm->owner held
	 */
	void (*mm_owner_changed)(struct cgroup_subsys *ss,
					struct cgroup *old,
					struct cgroup *new);

Is rather mysterious.  To what mm does it refer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
