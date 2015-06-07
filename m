Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id C4B14900016
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 10:31:02 -0400 (EDT)
Received: by qgg3 with SMTP id 3so17505999qgg.2
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 07:31:02 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d34si12633548qgd.127.2015.06.07.07.31.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 07:31:01 -0700 (PDT)
Message-ID: <5574555C.4080905@oracle.com>
Date: Sun, 07 Jun 2015 10:29:48 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: catch memory commitment underflow
References: <20140624201606.18273.44270.stgit@zurg>	<20140624201614.18273.39034.stgit@zurg>	<54BB9A32.7080703@oracle.com> <CALYGNiPbTpTNme_Cp4AF0cDjRB=rQ2FJ=qRJ+G5cihQMhzsZEw@mail.gmail.com> <553AF8D4.7070703@oracle.com>
In-Reply-To: <553AF8D4.7070703@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On 04/24/2015 10:15 PM, Sasha Levin wrote:
> On 01/18/2015 01:36 PM, Konstantin Khlebnikov wrote:
>> On Sun, Jan 18, 2015 at 2:34 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
>>> On 06/24/2014 04:16 PM, Konstantin Khlebnikov wrote:
>>>> This patch prints warning (if CONFIG_DEBUG_VM=y) when
>>>> memory commitment becomes too negative.
>>>>
>>>> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
>>>
>>> Hi Konstantin,
>>>
>>> I seem to be hitting this warning when fuzzing on the latest -next kernel:
>>
>> That might be unexpected change of shmem file which holds anon-vma data,
>> thanks to checkpoint-restore they are expoted via /proc/.../map_files
>>
>> I've fixed truncate (https://lkml.org/lkml/2014/6/24/729) but there
>> are some other ways
>> to change i_size: write, fallocate and maybe something else.
> 
> deja vu!
> 
> With the latest -next:

Ping? I'm still seeing this in -next:


[668829.173774] ------------[ cut here ]------------
[668829.175259] WARNING: CPU: 18 PID: 4414 at mm/mmap.c:160 __vm_enough_memory+0x39f/0x430()
[668829.177864] memory commitment underflow
[668829.179049] Modules linked in:
[668829.180183] CPU: 18 PID: 4414 Comm: trinity-c21 Tainted: G        W       4.1.0-rc6-next-20150604-sasha-00039-g07bbbaf-dirty #2269
[668829.183509]  ffff8805326b0000 0000000059024457 ffff88008d387cb8 ffffffff9fa02938
[668829.186008]  0000000000000000 ffff88008d387d38 ffff88008d387d08 ffffffff961e5336
[668829.188330]  ffff8805326b1190 ffffffff965639df ffff8805326b0000 ffffed0011a70fa3
[668829.189512] Call Trace:
[668829.189863]  [<ffffffff9fa02938>] dump_stack+0x4f/0x7b
[668829.190745]  [<ffffffff961e5336>] warn_slowpath_common+0xc6/0x120
[668829.191735]  [<ffffffff965639df>] ? __vm_enough_memory+0x39f/0x430
[668829.192740]  [<ffffffff961e5445>] warn_slowpath_fmt+0xb5/0xf0
[668829.193588]  [<ffffffff961e5390>] ? warn_slowpath_common+0x120/0x120
[668829.194554]  [<ffffffff96018040>] ? arch_get_unmapped_area+0x5e0/0x5e0
[668829.195709]  [<ffffffff962f08dc>] ? do_raw_spin_unlock+0x16c/0x260
[668829.196897]  [<ffffffff97dae510>] ? check_preemption_disabled+0x70/0x1f0
[668829.198035]  [<ffffffff965639df>] __vm_enough_memory+0x39f/0x430
[668829.199086]  [<ffffffff97b052df>] security_vm_enough_memory_mm+0x7f/0xa0
[668829.200248]  [<ffffffff9656ab64>] do_brk+0x3a4/0x910
[668829.201063]  [<ffffffff9656b213>] ? SyS_brk+0x63/0x3e0
[668829.202033]  [<ffffffff9656b213>] ? SyS_brk+0x63/0x3e0
[668829.202896]  [<ffffffff9656b445>] SyS_brk+0x295/0x3e0
[668829.203701]  [<ffffffff9fa6f6e2>] tracesys_phase2+0x88/0x8d
[668829.205084] ---[ end trace 3d1f7fa1a382323f ]---
[668829.205871] ------------[ cut here ]------------
[668829.205883] WARNING: CPU: 21 PID: 4719 at mm/mmap.c:160 __vm_enough_memory+0x39f/0x430()
[668829.205887] memory commitment underflow
[668829.205890] Modules linked in:
[668829.205899] CPU: 21 PID: 4719 Comm: kworker/u56:0 Tainted: G        W       4.1.0-rc6-next-20150604-sasha-00039-g07bbbaf-dirty #2269
[668829.205910]  ffff8808663d0000 000000009a8c3981 ffff880866207738 ffffffff9fa02938
[668829.205918]  0000000000000000 ffff8808662077b8 ffff880866207788 ffffffff961e5336
[668829.205926]  ffff880866207768 ffffffff965639df ffff880a70f2455c ffffed010cc40ef3
[668829.205927] Call Trace:
[668829.205938]  [<ffffffff9fa02938>] dump_stack+0x4f/0x7b
[668829.205948]  [<ffffffff961e5336>] warn_slowpath_common+0xc6/0x120
[668829.205957]  [<ffffffff965639df>] ? __vm_enough_memory+0x39f/0x430
[668829.205966]  [<ffffffff961e5445>] warn_slowpath_fmt+0xb5/0xf0
[668829.205975]  [<ffffffff961e5390>] ? warn_slowpath_common+0x120/0x120
[668829.205986]  [<ffffffff97dae6a7>] ? debug_smp_processor_id+0x17/0x20
[668829.205996]  [<ffffffff965639df>] __vm_enough_memory+0x39f/0x430
[668829.206008]  [<ffffffff97b052df>] security_vm_enough_memory_mm+0x7f/0xa0
[668829.206017]  [<ffffffff96568cc8>] expand_downwards+0x3f8/0xd30
[668829.206028]  [<ffffffff9fa6e485>] ? _raw_spin_unlock+0x35/0x60
[668829.206039]  [<ffffffff96558812>] handle_mm_fault+0x24b2/0x4440
[668829.206049]  [<ffffffff962d711e>] ? trace_hardirqs_on_caller+0x2de/0x670
[668829.206057]  [<ffffffff962d9920>] ? lockdep_init+0xf0/0xf0
[668829.206067]  [<ffffffff96556360>] ? copy_page_range+0x1a00/0x1a00
[668829.206073]  [<ffffffff962da139>] ? __lock_is_held+0xa9/0xf0
[668829.206080]  [<ffffffff962da316>] ? lock_is_held+0x196/0x1f0
[668829.206091]  [<ffffffff965465f7>] ? follow_page_mask+0x87/0xa70
[668829.206098]  [<ffffffff965472e2>] __get_user_pages+0x302/0xfb0
[668829.206103]  [<ffffffff962d9920>] ? lockdep_init+0xf0/0xf0
[668829.206112]  [<ffffffff966047a0>] ? default_llseek+0x270/0x270
[668829.206122]  [<ffffffff9667407a>] ? generic_getxattr+0xda/0x130
[668829.206129]  [<ffffffff96546fe0>] ? follow_page_mask+0xa70/0xa70
[668829.206135]  [<ffffffff962da316>] ? lock_is_held+0x196/0x1f0
[668829.206142]  [<ffffffff965485b2>] get_user_pages+0x52/0x60
[668829.206151]  [<ffffffff96617484>] copy_strings.isra.24+0x284/0x660
[668829.206158]  [<ffffffff96617200>] ? get_user_arg_ptr.isra.20+0x70/0x70
[668829.206165]  [<ffffffff966178e9>] copy_strings_kernel+0x89/0x110
[668829.206171]  [<ffffffff9661ba56>] do_execveat_common.isra.28+0xfa6/0x1b10
[668829.206177]  [<ffffffff9661aedd>] ? do_execveat_common.isra.28+0x42d/0x1b10
[668829.206184]  [<ffffffff965c2d25>] ? arch_local_irq_restore+0x15/0x20
[668829.206197]  [<ffffffff9661aab0>] ? prepare_bprm_creds+0x100/0x100
[668829.206331]  [<ffffffff962da316>] ? lock_is_held+0x196/0x1f0
[668829.206342]  [<ffffffff96321563>] ? rcu_read_lock_sched_held+0x1a3/0x1c0
[668829.206349]  [<ffffffff965c7d08>] ? kmem_cache_alloc+0x248/0x2d0
[668829.206357]  [<ffffffff965cd19a>] ? memcpy+0x3a/0x50
[668829.206363]  [<ffffffff9661c5ec>] do_execve+0x2c/0x30
[668829.206372]  [<ffffffff96226d1f>] ____call_usermodehelper+0x29f/0x440
[668829.206378]  [<ffffffff96226a80>] ? __call_usermodehelper+0xc0/0xc0
[668829.206385]  [<ffffffff9fa6fa1f>] ret_from_fork+0x3f/0x70
[668829.206392]  [<ffffffff96226a80>] ? __call_usermodehelper+0xc0/0xc0


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
