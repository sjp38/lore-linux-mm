Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 448866B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 06:18:11 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c10so224109085pfg.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 03:18:11 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u143si26457124pgb.67.2017.05.25.03.18.09
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 03:18:10 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH] mm/migrate: Fix ref-count handling when !hugepage_migration_supported()
References: <20170524154728.2492-1-punit.agrawal@arm.com>
	<20170525015927.GA26520@hori1.linux.bs1.fc.nec.co.jp>
Date: Thu, 25 May 2017 11:18:06 +0100
In-Reply-To: <20170525015927.GA26520@hori1.linux.bs1.fc.nec.co.jp> (Naoya
	Horiguchi's message of "Thu, 25 May 2017 01:59:28 +0000")
Message-ID: <87tw49dyu9.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "manoj.iyer@arm.com" <manoj.iyer@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tbaicar@codeaurora.org" <tbaicar@codeaurora.org>, "timur@qti.qualcomm.com" <timur@qti.qualcomm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> On Wed, May 24, 2017 at 04:47:28PM +0100, Punit Agrawal wrote:
>> On failing to migrate a page, soft_offline_huge_page() performs the
>> necessary update to the hugepage ref-count. When
>> !hugepage_migration_supported() , unmap_and_move_hugepage() also
>> decrements the page ref-count for the hugepage. The combined behaviour
>> leaves the ref-count in an inconsistent state.
>> 
>> This leads to soft lockups when running the overcommitted hugepage test
>> from mce-tests suite.
>> 
>> Soft offlining pfn 0x83ed600 at process virtual address 0x400000000000
>> soft offline: 0x83ed600: migration failed 1, type
>> 1fffc00000008008 (uptodate|head)
>> INFO: rcu_preempt detected stalls on CPUs/tasks:
>>  Tasks blocked on level-0 rcu_node (CPUs 0-7): P2715
>>   (detected by 7, t=5254 jiffies, g=963, c=962, q=321)
>>   thugetlb_overco R  running task        0  2715   2685 0x00000008
>>   Call trace:
>>   [<ffff000008089f90>] dump_backtrace+0x0/0x268
>>   [<ffff00000808a2d4>] show_stack+0x24/0x30
>>   [<ffff000008100d34>] sched_show_task+0x134/0x180
>>   [<ffff0000081c90fc>] rcu_print_detail_task_stall_rnp+0x54/0x7c
>>   [<ffff00000813cfd4>] rcu_check_callbacks+0xa74/0xb08
>>   [<ffff000008143a3c>] update_process_times+0x34/0x60
>>   [<ffff0000081550e8>] tick_sched_handle.isra.7+0x38/0x70
>>   [<ffff00000815516c>] tick_sched_timer+0x4c/0x98
>>   [<ffff0000081442e0>] __hrtimer_run_queues+0xc0/0x300
>>   [<ffff000008144fa4>] hrtimer_interrupt+0xac/0x228
>>   [<ffff0000089a56d4>] arch_timer_handler_phys+0x3c/0x50
>>   [<ffff00000812f1bc>] handle_percpu_devid_irq+0x8c/0x290
>>   [<ffff0000081297fc>] generic_handle_irq+0x34/0x50
>>   [<ffff000008129f00>] __handle_domain_irq+0x68/0xc0
>>   [<ffff0000080816b4>] gic_handle_irq+0x5c/0xb0
>> 
>> Fix this by dropping the ref-count decrement in
>> unmap_and_move_hugepage() when !hugepage_migration_supported().
>> 
>> Fixes: 32665f2bbfed ("mm/migrate: correct failure handling if !hugepage_migration_support()")
>> Reported-by: Manoj Iyer <manoj.iyer@canonical.com>
>> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> Cc: Christoph Lameter <cl@linux.com>
>> 
>> --
>> Hi Andrew,
>> 
>> We ran into this bug when working towards enabling memory corruption
>> on arm64. The patch was tested on an arm64 platform running v4.12-rc2
>> with the series to enable memory corruption handling[0].
>> 
>> Please consider merging as a fix for the 4.12 release.
>> 
>> Thanks,
>> Punit
>> 
>> [0] https://www.spinics.net/lists/arm-kernel/msg581657.html
>> ---
>>  mm/migrate.c | 4 +---
>>  1 file changed, 1 insertion(+), 3 deletions(-)
>> 
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 89a0a1707f4c..187abd1526df 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -1201,10 +1201,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>>  	 * tables or check whether the hugepage is pmd-based or not before
>>  	 * kicking migration.
>>  	 */
>> -	if (!hugepage_migration_supported(page_hstate(hpage))) {
>> -		putback_active_hugepage(hpage);
>
> Thank you for reporting and suggestion, Punit, Manoj.
>
> Simply dropping this putback_active_hugepage() may resume the failure
> counting issue addressed in 32665f2bbfed, so I would recommend to call
> putback_movable_pages() in failure path in soft_offline_huge_page().
>
> @@ -1600,7 +1600,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  		 * only one hugepage pointed to by hpage, so we need not
>  		 * run through the pagelist here.
>  		 */
> -		putback_active_hugepage(hpage);
> +		if (!list_empty(&pagelist))
> +			putback_movable_pages(&pagelist);
>  		if (ret > 0)
>  			ret = -EIO;
>  	} else {
>
> Could you check this works for you?

Using this sequence works as well. I'll send out an update shortly.

Thanks

>
> Thanks,
> Naoya Horiguchi
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
