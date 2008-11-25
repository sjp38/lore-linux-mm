Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAPF1RBd014170
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 20:31:27 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAPF0pWc4317428
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 20:30:51 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAPF1Qxm006376
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 20:31:27 +0530
Message-ID: <492C1345.9090201@linux.vnet.ibm.com>
Date: Tue, 25 Nov 2008 20:31:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v4)
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop> <20081116081055.25166.85066.sendpatchset@balbir-laptop> <20081125205832.38f8c365.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081125205832.38f8c365.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> Hi.
> 
> Unfortunately, trying to hold cgroup_mutex at reclaim causes dead lock.
> 
> For example, when attaching a task to some cpuset directory(memory_migrate=on),
> 
>     cgroup_tasks_write (hold cgroup_mutex)
>         attach_task_by_pid
>             cgroup_attach_task
>                 cpuset_attach
>                     cpuset_migrate_mm
>                         :
>                         unmap_and_move
>                             mem_cgroup_prepare_migration
>                                 mem_cgroup_try_charge
>                                     mem_cgroup_hierarchical_reclaim
> 

Did lockdep complain about it?

1. We could probably move away from cgroup_mutex to a memory controller specific
mutex.
2. We could give up cgroup_mutex before migrate_mm, since it seems like we'll
hold the cgroup lock for long and holding it during reclaim will definitely be
visible to users trying to create/delete nodes.

I prefer to do (2), I'll look at the code more closely

> I think similar problem can also happen when removing memcg's directory.
> 

Why removing a directory? memcg (now) marks the directory as obsolete and we
check for obsolete directories and get/put references.

Thanks for the bug report!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
