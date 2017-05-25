Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE1056B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 05:49:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c10so223304294pfg.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 02:49:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r76si27452432pfg.285.2017.05.25.02.49.51
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 02:49:51 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH] mm/migrate: Fix ref-count handling when !hugepage_migration_supported()
References: <20170524154728.2492-1-punit.agrawal@arm.com>
	<20170524125610.8fbc644f8fa1cf8175b7757b@linux-foundation.org>
Date: Thu, 25 May 2017 10:49:47 +0100
In-Reply-To: <20170524125610.8fbc644f8fa1cf8175b7757b@linux-foundation.org>
	(Andrew Morton's message of "Wed, 24 May 2017 12:56:10 -0700")
Message-ID: <87y3tle05g.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: will.deacon@arm.com, catalin.marinas@arm.com, manoj.iyer@arm.com, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, tbaicar@codeaurora.org, timur@qti.qualcomm.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed, 24 May 2017 16:47:28 +0100 Punit Agrawal <punit.agrawal@arm.com> wrote:
>
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
>
> 32665f2bbfed was three years ago.  Do you have any theory as to why
> this took so long to be detected?

This only triggers on systems that enable memory failure handling
(ARCH_SUPPORTS_MEMORY_FAILURE) but not hugepage migration
(!ARCH_ENABLE_HUGEPAGE_MIGRATION).

I imagine this wasn't triggered as there aren't many systems running
this configuration.

> And do you believe a -stable backport is warranted?

I'll defer to Horiguchi-san's judgement here.

>
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
