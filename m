Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4B106B0383
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 04:04:27 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id c58so1618509otd.17
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 01:04:27 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id q37si808697ote.530.2017.12.06.01.04.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 01:04:26 -0800 (PST)
Subject: Re: [question] handle the page table RAS error(Avoid kernel panic
 when killing an application)
From: gengdongjiu <gengdongjiu@huawei.com>
References: <0184EA26B2509940AA629AE1405DD7F2019C8B36@DGGEMA503-MBS.china.huawei.com>
 <20171205165727.GG3070@tassilo.jf.intel.com>
 <0276f3b3-94a5-8a47-dfb7-8773cd2f99c5@huawei.com>
Message-ID: <dedf9af6-7979-12dc-2a52-f00b2ec7f3b6@huawei.com>
Date: Wed, 6 Dec 2017 17:03:30 +0800
MIME-Version: 1.0
In-Reply-To: <0276f3b3-94a5-8a47-dfb7-8773cd2f99c5@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: "tony.luck@intel.com" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "wangxiongfeng
 (C)" <wangxiongfeng2@huawei.com>, Huangshaoyu <huangshaoyu@huawei.com>, Wuquanming <wuquanming@huawei.com>

change the mail subject and resend the mail

On 2017/12/6 16:56, gengdongjiu wrote:
> 
> On 2017/12/6 0:57, Andi Kleen wrote:
> x86 doesn't handle it.
>
> There are lots of memory types that are not handled by MCE recovery
> because it is just too difficult.  In general MCE recovery focuses on
> memory types that use up significant percent of total memory.  Page tables
> are normally not that big, so not really worth handling.
>
> I wouldn't bother about them unless you measure them to big a significant
> portion of memory on a real world workload.

Thanks for the reply and answer.
sorry, I need to explain my main purpose.
In fact, I mainly want to avoid kernel crash by reading the corrupt page table during application "exit",
not  want to make a very complicated solution to handle the page table RAS error. may be a user space
application error lead to whole OS panic is not a good.

This is the real case that I encountered when "kill" the application, the log is shown in [1].
do you think we needn't to handle this kernel panic when killing a application?

May be the simplest way is push the task to dead state when found his page table is poisoned, or not free the
poisoned page table, for this way, of course there will be a memory leak because the kernel relies on looking at which pages
were mapped to go and reduce the reference count and (if zero) free the page




[1]:
[  676.669053] Synchronous External Abort: level 0 (translation table walk) (0x82000214) at 0x0000000033ff7008
[  676.686469] Memory failure: 0xcd4b: already hardware poisoned
[  676.700652] Synchronous External Abort: synchronous external abort (0x96000410) at 0x0000000033ff7008
[  676.723301] Internal error: : 96000410 [#1] PREEMPT SMP
[  676.723616] Modules linked in: inject_memory_error(O)
[  676.724601] CPU: 0 PID: 1506 Comm: mca-recover Tainted: G           O    4.14.0-rc8-00019-g5b5c6f4-dirty #109
[  676.724844] task: ffff80000cd41d00 task.stack: ffff000009b30000
[  676.726616] PC is at unmap_page_range+0x78/0x6fc
[  676.726960] LR is at unmap_single_vma+0x88/0xdc
[  676.727122] pc : [<ffff0000081f109c>] lr : [<ffff0000081f17a8>] pstate: 80400149
[  676.727227] sp : ffff000009b339b0
[  676.727348] x29: ffff000009b339b0 x28: ffff80000cd41d00
[  676.727653] x27: 0000000000000000 x26: ffff80000cd42410
[  676.727919] x25: ffff80000cd41d00 x24: ffff80000cd1e180
[  676.728161] x23: ffff80000ce22300 x22: 0000000000000000
[  676.728407] x21: ffff000009b33b28 x20: 0000000000400000
[  676.728642] x19: ffff80000cd1e180 x18: 000000000000016d
[  676.728875] x17: 0000000000000190 x16: 0000000000000064
[  676.729117] x15: 0000000000000339 x14: 0000000000000000
[  676.729344] x13: 00000000000061a8 x12: 0000000000000339
[  676.729582] x11: 0000000000000018 x10: 0000000000000a80
[  676.729829] x9 : ffff000009b33c60 x8 : ffff80000cd427e0
[  676.730065] x7 : ffff000009b33de8 x6 : 00000000004a2000
[  676.730287] x5 : 0000000000400000 x4 : ffff80000cd4b000
[  676.730517] x3 : 00000000004a1fff x2 : 0000008000000000
[  676.730741] x1 : 0000007fffffffff x0 : 0000008000000000
[  676.731101] Process mca-recover (pid: 1506, stack limit = 0xffff000009b30000)
[  676.731281] Call trace:
[  676.734196] [<ffff0000081f109c>] unmap_page_range+0x78/0x6fc
[  676.734539] [<ffff0000081f17a8>] unmap_single_vma+0x88/0xdc
[  676.734892] [<ffff0000081f1aa8>] unmap_vmas+0x68/0xb4
[  676.735456] [<ffff0000081fa56c>] exit_mmap+0x90/0x140
[  676.736468] [<ffff0000080ccb34>] mmput+0x60/0x118
[  676.736791] [<ffff0000080d4060>] do_exit+0x240/0x9cc
[  676.736997] [<ffff0000080d4854>] do_group_exit+0x38/0x98
[  676.737384] [<ffff0000080df4d0>] get_signal+0x1ec/0x548
[  676.738313] [<ffff000008088b80>] do_signal+0x7c/0x668
[  676.738617] [<ffff000008089538>] do_notify_resume+0xcc/0x114
 [  676.740983] [<ffff0000080836c0>] work_pending+0x8/0x10
[  676.741360] Code: f94043a4 f9404ba2 f94037a3 d1000441 (f9400080)
[  676.741745] ---[ end trace e42d453027313552 ]---
[  676.804174] Fixing recursive fault but reboot is needed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
