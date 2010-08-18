Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 819876B01FE
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:45:50 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7IGW2WQ010549
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:32:02 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7IGjhrg127932
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:45:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7IGjhLv008838
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:45:43 -0400
Date: Wed, 18 Aug 2010 22:15:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Over-eager swapping
Message-ID: <20100818164539.GG28417@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100802124734.GI2486@arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100802124734.GI2486@arachsys.com>
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Chris Webb <chris@arachsys.com> [2010-08-02 13:47:35]:

> We run a number of relatively large x86-64 hosts with twenty or so qemu-kvm
> virtual machines on each of them, and I'm have some trouble with over-eager
> swapping on some (but not all) of the machines. This is resulting in
> customer reports of very poor response latency from the virtual machines
> which have been swapped out, despite the hosts apparently having large
> amounts of free memory, and running fine if swap is turned off.
> 
> All of the hosts are running a 2.6.32.7 kernel and have ksm enabled with
> 32GB of RAM and 2x quad-core processors. There is a cluster of Xeon E5420
> machines which apparently doesn't exhibit the problem, and a cluster of
> 2352/2378 Opteron (NUMA) machines, some of which do. The kernel config of
> the affected machines is at
> 
>   http://cdw.me.uk/tmp/config-2.6.32.7
> 
> This differs very little from the config on the unaffected Xeon machines,
> essentially just
> 
>   -CONFIG_MCORE2=y
>   +CONFIG_MK8=y
>   -CONFIG_X86_P6_NOP=y
> 
> On a typical affected machine, the virtual machines and other processes
> would apparently leave around 5.5GB of RAM available for buffers, but the
> system seems to want to swap out 3GB of anonymous pages to give itself more
> like 9GB of buffers:
> 
>   # cat /proc/meminfo 
>   MemTotal:       33083420 kB
>   MemFree:          693164 kB
>   Buffers:         8834380 kB
>   Cached:            11212 kB
>   SwapCached:      1443524 kB
>   Active:         21656844 kB
>   Inactive:        8119352 kB
>   Active(anon):   17203092 kB
>   Inactive(anon):  3729032 kB
>   Active(file):    4453752 kB
>   Inactive(file):  4390320 kB
>   Unevictable:        5472 kB
>   Mlocked:            5472 kB
>   SwapTotal:      25165816 kB
>   SwapFree:       21854572 kB
>   Dirty:              4300 kB
>   Writeback:             4 kB
>   AnonPages:      20780368 kB
>   Mapped:             6056 kB
>   Shmem:                56 kB
>   Slab:             961512 kB
>   SReclaimable:     438276 kB
>   SUnreclaim:       523236 kB
>   KernelStack:       10152 kB
>   PageTables:        67176 kB
>   NFS_Unstable:          0 kB
>   Bounce:                0 kB
>   WritebackTmp:          0 kB
>   CommitLimit:    41707524 kB
>   Committed_AS:   39870868 kB
>   VmallocTotal:   34359738367 kB
>   VmallocUsed:      150880 kB
>   VmallocChunk:   34342404996 kB
>   HardwareCorrupted:     0 kB
>   HugePages_Total:       0
>   HugePages_Free:        0
>   HugePages_Rsvd:        0
>   HugePages_Surp:        0
>   Hugepagesize:       2048 kB
>   DirectMap4k:        5824 kB
>   DirectMap2M:     3205120 kB
>   DirectMap1G:    30408704 kB
> 
> We see this despite the machine having vm.swappiness set to 0 in an attempt
> to skew the reclaim as far as possible in favour of releasing page cache
> instead of swapping anonymous pages.
>
> After running swapoff -a, the machine is immediately much healthier. Even
> while the swap is still being reduced, load goes down and response times in
> virtual machines are much improved. Once the swap is completely gone, there
> are still several gigabytes of RAM left free which are used for buffers, and
> the virtual machines are no longer laggy because they are no longer swapped
> out. Running swapon -a again, the affected machine waits for about a minute
> with zero swap in use, before the amount of swap in use very rapidly
> increases to around 2GB and then continues to increase more steadily to 3GB.
> 
> We could run with these machines without swap (in the worst cases we're
> already doing so), but I'd prefer to have a reserve of swap available in
> case of genuine emergency. If it's a choice between swapping out a guest or
> oom-killing it, I'd prefer to swap... but I really don't want to swap out
> running virtual machines in order to have eight gigabytes of page cache
> instead of five!
> 
> Is this a problem with the page reclaim priorities, or am I just tuning
> these hosts incorrectly? Is there more detailed info than /proc/meminfo
> available which might shed more light on what's going wrong here?
> 

Can you give an idea of what the meminfo inside the guest looks like.
Have you looked at
http://kerneltrap.org/mailarchive/linux-kernel/2010/6/8/4580772


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
