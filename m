Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 431C86B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 18:19:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 10so40097922wml.4
        for <linux-mm@kvack.org>; Wed, 24 May 2017 15:19:28 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id f27si6147327wmi.75.2017.05.24.15.19.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 15:19:26 -0700 (PDT)
Date: Wed, 24 May 2017 17:19:16 -0500 (CDT)
From: Manoj Iyer <manoj.iyer@canonical.com>
Subject: Re: mm/migrate: Fix ref-count handling when
 !hugepage_migration_supported()
In-Reply-To: <20170524154728.2492-1-punit.agrawal@arm.com>
Message-ID: <alpine.DEB.2.20.1705241713240.3333@lazy>
References: <20170524154728.2492-1-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, will.deacon@arm.com, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, tbaicar@codeaurora.org, "Tabi, Timur" <timur@qti.qualcomm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Wed, 24 May 2017, Punit Agrawal wrote:

> On failing to migrate a page, soft_offline_huge_page() performs the
> necessary update to the hugepage ref-count. When
> !hugepage_migration_supported() , unmap_and_move_hugepage() also
> decrements the page ref-count for the hugepage. The combined behaviour
> leaves the ref-count in an inconsistent state.
>
> This leads to soft lockups when running the overcommitted hugepage test
> from mce-tests suite.
>
> Soft offlining pfn 0x83ed600 at process virtual address 0x400000000000
> soft offline: 0x83ed600: migration failed 1, type
> 1fffc00000008008 (uptodate|head)
> INFO: rcu_preempt detected stalls on CPUs/tasks:
> Tasks blocked on level-0 rcu_node (CPUs 0-7): P2715
>  (detected by 7, t=5254 jiffies, g=963, c=962, q=321)
>  thugetlb_overco R  running task        0  2715   2685 0x00000008
>  Call trace:
>  [<ffff000008089f90>] dump_backtrace+0x0/0x268
>  [<ffff00000808a2d4>] show_stack+0x24/0x30
>  [<ffff000008100d34>] sched_show_task+0x134/0x180
>  [<ffff0000081c90fc>] rcu_print_detail_task_stall_rnp+0x54/0x7c
>  [<ffff00000813cfd4>] rcu_check_callbacks+0xa74/0xb08
>  [<ffff000008143a3c>] update_process_times+0x34/0x60
>  [<ffff0000081550e8>] tick_sched_handle.isra.7+0x38/0x70
>  [<ffff00000815516c>] tick_sched_timer+0x4c/0x98
>  [<ffff0000081442e0>] __hrtimer_run_queues+0xc0/0x300
>  [<ffff000008144fa4>] hrtimer_interrupt+0xac/0x228
>  [<ffff0000089a56d4>] arch_timer_handler_phys+0x3c/0x50
>  [<ffff00000812f1bc>] handle_percpu_devid_irq+0x8c/0x290
>  [<ffff0000081297fc>] generic_handle_irq+0x34/0x50
>  [<ffff000008129f00>] __handle_domain_irq+0x68/0xc0
>  [<ffff0000080816b4>] gic_handle_irq+0x5c/0xb0
>
> Fix this by dropping the ref-count decrement in
> unmap_and_move_hugepage() when !hugepage_migration_supported().
>
> Fixes: 32665f2bbfed ("mm/migrate: correct failure handling if !hugepage_migration_support()")
> Reported-by: Manoj Iyer <manoj.iyer@canonical.com>
> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Christoph Lameter <cl@linux.com>
> ---
> Hi Andrew,
>
> We ran into this bug when working towards enabling memory corruption
> on arm64. The patch was tested on an arm64 platform running v4.12-rc2
> with the series to enable memory corruption handling[0].
>
> Please consider merging as a fix for the 4.12 release.
>
> Thanks,
> Punit
>

I applied this patch applied to Ubuntu Zesty (4.10) kernel and tested on 
QDF2400 platform with mce-test without config migration enabled.

== dmesg ==
[   91.569358] Soft offlining page 0x1763c00 at 0x400000000000
[   91.569364] soft offline: 0x1763c00: migration failed 1, type 
100000000008008
[  150.282911] Soft offlining page 0x1763c00 at 0x400000000000
[  150.282917] soft offline: 0x1763c00: migration failed 1, type 
100000000008008

The mce-test failed as expected but did not encounter the soft lockups. 
(The test case might have an error it is missing an 'echo' in failure 
case.)

$ sudo ./run_hugepage_overcommit.sh

***************************************************************************
Pay attention:

This test checks that hugepage soft-offlining works under overcommitting.
***************************************************************************


-------------------------------------
TestCase ./thugetlb_overcommit 1
FAIL: migration failed.
Unpoisoning.

 	Num of Executed Test Case: 1	Num of Failed Case: 1

Tested-By: Manoj Iyer <manoj.iyer@canonical.com>

Thanks
Manoj Iyer

> [0] https://www.spinics.net/lists/arm-kernel/msg581657.html
> ---
> mm/migrate.c | 4 +---
> 1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 89a0a1707f4c..187abd1526df 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1201,10 +1201,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
> 	 * tables or check whether the hugepage is pmd-based or not before
> 	 * kicking migration.
> 	 */
> -	if (!hugepage_migration_supported(page_hstate(hpage))) {
> -		putback_active_hugepage(hpage);
> +	if (!hugepage_migration_supported(page_hstate(hpage)))
> 		return -ENOSYS;
> -	}
>
> 	new_hpage = get_new_page(hpage, private, &result);
> 	if (!new_hpage)
>

--
============================
Manoj Iyer
Ubuntu/Canonical
ARM Servers - Cloud
============================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
