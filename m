Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 54E966B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 11:02:31 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id e16so9179569qcx.27
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 08:02:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f33si6334005qgf.50.2014.03.31.08.02.30
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 08:02:30 -0700 (PDT)
Date: Mon, 31 Mar 2014 11:02:20 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53398386.a41f8c0a.2cce.ffffa9a1SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <533946D4.1060305@jp.fujitsu.com>
References: <533946D4.1060305@jp.fujitsu.com>
Subject: Re: [PATCH] mm: hugetlb: fix softlockup when a large number of
 hugepages are freed.
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.mizuma@jp.fujitsu.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, mhocko@suse.cz, liwanp@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, kosaki.motohiro@jp.fujitsu.com

On Mon, Mar 31, 2014 at 07:43:32PM +0900, Mizuma, Masayoshi wrote:
> Hi,
> 
> When I decrease the value of nr_hugepage in procfs a lot, softlockup happens.
> It is because there is no chance of context switch during this process.
> 
> On the other hand, when I allocate a large number of hugepages,
> there is some chance of context switch. Hence softlockup doesn't happen
> during this process. So it's necessary to add the context switch
> in the freeing process as same as allocating process to avoid softlockup.
> 
> When I freed 12 TB hugapages with kernel-2.6.32-358.el6, the freeing process
> occupied a CPU over 150 seconds and following softlockup message appeared
> twice or more.
> 
> --
> $ echo 6000000 > /proc/sys/vm/nr_hugepages
> $ cat /proc/sys/vm/nr_hugepages
> 6000000
> $ grep ^Huge /proc/meminfo
> HugePages_Total:   6000000
> HugePages_Free:    6000000
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> $ echo 0 > /proc/sys/vm/nr_hugepages
> 
> BUG: soft lockup - CPU#16 stuck for 67s! [sh:12883] ...
> Pid: 12883, comm: sh Not tainted 2.6.32-358.el6.x86_64 #1
> Call Trace:
>  [<ffffffff8115a438>] ? free_pool_huge_page+0xb8/0xd0
>  [<ffffffff8115a578>] ? set_max_huge_pages+0x128/0x190
>  [<ffffffff8115c663>] ? hugetlb_sysctl_handler_common+0x113/0x140
>  [<ffffffff8115c6de>] ? hugetlb_sysctl_handler+0x1e/0x20
>  [<ffffffff811f3097>] ? proc_sys_call_handler+0x97/0xd0
>  [<ffffffff811f30e4>] ? proc_sys_write+0x14/0x20
>  [<ffffffff81180f98>] ? vfs_write+0xb8/0x1a0
>  [<ffffffff81181891>] ? sys_write+0x51/0x90
>  [<ffffffff810dc565>] ? __audit_syscall_exit+0x265/0x290
>  [<ffffffff8100b072>] ? system_call_fastpath+0x16/0x1b
> --
> I have not confirmed this problem with upstream kernels because I am not
> able to prepare the machine equipped with 12TB memory now.
> However I confirmed that the amount of decreasing hugepages was directly
> proportional to the amount of required time.
> 
> I measured required times on a smaller machine. It showed 130-145 hugepages
> decreased in a millisecond.
> 
> Amount of decreasing     Required time      Decreasing rate
> hugepages                     (msec)         (pages/msec)
> ------------------------------------------------------------
> 10,000 pages == 20GB         70 -  74          135-142
> 30,000 pages == 60GB        208 - 229          131-144
> 
> It means decrement of 6TB hugepages will trigger softlockup with the default
> threshold 20sec, in this decreasing rate.
> 
> Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/hugetlb.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7d57af2..fe67f2c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1535,6 +1535,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  	while (min_count < persistent_huge_pages(h)) {
>  		if (!free_pool_huge_page(h, nodes_allowed, 0))
>  			break;
> +		cond_resched_lock(&hugetlb_lock);
>  	}
>  	while (count < persistent_huge_pages(h)) {
>  		if (!adjust_pool_surplus(h, nodes_allowed, 1))

It seems that the same thing could happen when freeing a number of surplus pages,
so how about adding cond_resched_lock() also in return_unused_surplus_pages()?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
