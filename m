Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id mB5DqIg0012835
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 19:22:18 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB5DqKFJ3248380
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 19:22:20 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id mB5DqInS030686
	for <linux-mm@kvack.org>; Sat, 6 Dec 2008 00:52:18 +1100
Date: Fri, 5 Dec 2008 19:22:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH -mmotm 3/4] memcg: avoid dead lock caused by race
	between oom and cpuset_attach
Message-ID: <20081205135232.GB10004@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp> <20081205212450.574f498c.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081205212450.574f498c.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2008-12-05 21:24:50]:

> mpol_rebind_mm(), which can be called from cpuset_attach(), does down_write(mm->mmap_sem).
> This means down_write(mm->mmap_sem) can be called under cgroup_mutex.
> 
> OTOH, page fault path does down_read(mm->mmap_sem) and calls mem_cgroup_try_charge_xxx(), 
> which may eventually calls mem_cgroup_out_of_memory(). And mem_cgroup_out_of_memory()
> calls cgroup_lock().
> This means cgroup_lock() can be called under down_read(mm->mmap_sem).
> 
> If those two paths race, dead lock can happen.
> 
> This patch avoid this dead lock by:
>   - remove cgroup_lock() from mem_cgroup_out_of_memory().
>   - define new mutex (memcg_tasklist) and serialize mem_cgroup_move_task()
>     (->attach handler of memory cgroup) and mem_cgroup_out_of_memory. 

A similar race has been reported for cpuset_migrate_mm(), which is
called holding the cgroup_mutex and further calls do_migrate_pages,
which can call reclaim and thus try to acquire cgroup_lock. If we
avoid reclaiming pages with cpuset_migrate_mm(), as the first patch
did, it also solves the reported race.

> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
