Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D81F76B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 19:58:42 -0500 (EST)
Date: Mon, 26 Jan 2009 16:58:23 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [FIX][PATCH 6/7] cgroup/memcg: fix frequent -EBUSY at rmdir
Message-Id: <20090126165823.dcf9cf78.randy.dunlap@oracle.com>
In-Reply-To: <20090122184018.5cd3c3b9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090122184018.5cd3c3b9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jan 2009 18:40:18 +0900 KAMEZAWA Hiroyuki wrote:

>  Documentation/cgroups/cgroups.txt |    6 +-
>  include/linux/cgroup.h            |   16 +-----
>  kernel/cgroup.c                   |   97 ++++++++++++++++++++++++++++++++------
>  mm/memcontrol.c                   |    5 +
>  4 files changed, 93 insertions(+), 31 deletions(-)
> 
> Index: mmotm-2.6.29-Jan16/Documentation/cgroups/cgroups.txt
> ===================================================================
> --- mmotm-2.6.29-Jan16.orig/Documentation/cgroups/cgroups.txt
> +++ mmotm-2.6.29-Jan16/Documentation/cgroups/cgroups.txt
> @@ -478,11 +478,13 @@ cgroup->parent is still valid. (Note - c
>  newly-created cgroup if an error occurs after this subsystem's
>  create() method has been called for the new cgroup).
>  
> -void pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +int pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  
>  Called before checking the reference count on each subsystem. This may
>  be useful for subsystems which have some extra references even if
> -there are not tasks in the cgroup.
> +there are not tasks in the cgroup. If pre_destroy() returns error code,
> +rmdir() will fail with it. From this behavior, pre_destroy() can be
> +called plural times against a cgroup.

s/plural/multiple/ please.

>  
>  int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
>  	       struct task_struct *task)


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
