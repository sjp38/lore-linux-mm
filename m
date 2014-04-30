Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id BF92C6B0036
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 15:21:30 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so2160987pdj.10
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 12:21:30 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id zp5si14543854pac.352.2014.04.30.12.21.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 12:21:29 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 1 May 2014 05:21:26 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 2B00B2BB004A
	for <linux-mm@kvack.org>; Thu,  1 May 2014 05:21:23 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3UJ0L6w62324974
	for <linux-mm@kvack.org>; Thu, 1 May 2014 05:00:21 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3UJLMTH032659
	for <linux-mm@kvack.org>; Thu, 1 May 2014 05:21:22 +1000
Message-ID: <53614CFF.7040200@linux.vnet.ibm.com>
Date: Thu, 01 May 2014 00:50:31 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com> <alpine.LSU.2.11.1404281500180.2861@eggly.anvils> <1398723290.25549.20.camel@buesod1.americas.hpqcorp.net> <CA+55aFwGjYS7PqsD6A-q+Yp9YZmiM6mB4MUYmfR7ro02poxxCQ@mail.gmail.com> <535F77E8.2040000@linux.vnet.ibm.com> <53614BFE.9090804@linux.vnet.ibm.com> <53614CA2.4000707@linux.vnet.ibm.com>
In-Reply-To: <53614CA2.4000707@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Dave Jones <davej@redhat.com>

On 05/01/2014 12:48 AM, Srivatsa S. Bhat wrote:
> On 05/01/2014 12:46 AM, Srivatsa S. Bhat wrote:
>> On 04/29/2014 03:29 PM, Srivatsa S. Bhat wrote:
>>> On 04/29/2014 03:55 AM, Linus Torvalds wrote:
>>>> On Mon, Apr 28, 2014 at 3:14 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>>>>
>>>>> I think that returning some stale/bogus vma is causing those segfaults
>>>>> in udev. It shouldn't occur in a normal scenario. What puzzles me is
>>>>> that it's not always reproducible. This makes me wonder what else is
>>>>> going on...
>>>>
>>>> I've replaced the BUG_ON() with a WARN_ON_ONCE(), and made it be
>>>> unconditional (so you don't have to trigger the range check).
>>>>
>>>> That might make it show up earlier and easier (and hopefully closer to
>>>> the place that causes it). Maybe that makes it easier for Srivatsa to
>>>> reproduce this. It doesn't make *my* machine do anything different,
>>>> though.
>>>>
>>>> Srivatsa? It's in current -git.
>>>>
>>>
>>> I tried this, but still nothing so far. I rebooted 10-20 times, and also
>>> tried multiple runs of multi-threaded ebizzy and kernel compilations,
>>> but none of this hit the warning.
>>>
>>
>> I tried to recall the *exact* steps that I had carried out when I first
>> hit the bug. I realized that I had actually used kexec to boot the new
>> kernel. I had originally booted into a 3.7.7 kernel that happens to be
>> on that machine, and then kexec()'ed 3.15-rc3 on it. And that had caused
>> the kernel crash. Fresh boots of 3.15-rc3, as well as kexec from 3.15+
>> to itself, seems to be pretty robust and has never resulted in any bad
>> behavior (this is why I couldn't reproduce the issue earlier, since I was
>> doing fresh boots of 3.15-rc).
>>
>> So I tried the same recipe again (boot into 3.7.7 and kexec into 3.15-rc3+)
>> and I got totally random crashes so far, once in sys_kill and two times in
>> exit_mmap. So I guess the bug is in 3.7.x and probably 3.15-rc is fine after
>> all...
>>
>>
>> Here is the crash around sys_kill:
>>
>>
> 
> And here are the exit_mmap related ones:
> 
> 1.

And here is the second one related to exit_mmap:

2.

mpt2sas0: port enable: SUCCESS
scsi 0:1:0:0: Direct-Access     LSI      Logical Volume   3000 PQ: 0 ANSI: 6
scsi 0:1:0:0: RAID0: handle(0x00b5), wwid(0x02c5d3368a5aef06), pd_count(1), type(SSP)
scsi 0:1:0:0: qdepth(254), tagged(1), simple(0), ordered(0), scsi_level(7), cmd_que(1)
scsi 0:0:0:0: Direct-Access     IBM-ESXS ST9500620SS      BD2C PQ: 0 ANSI: 6
scsi 0:0:0:0: SSP: handle(0x0005), sas_addr(0x5000c500559ffab5), phy(0), device_name(0x5000c500559ffab4)
scsi 0:0:0:0: SSP: enclosure_logical_id(0x5005076056434d90), slot(0)
scsi 0:0:0:0: qdepth(254), tagged(1), simple(0), ordered(0), scsi_level(7), cmd_que(1)
sd 0:1:0:0: [sda] 974608384 512-byte logical blocks: (498 GB/464 GiB)
sd 0:1:0:0: [sda] Write Protect is off
sd 0:1:0:0: [sda] Mode Sense: 03 00 00 08
sd 0:1:0:0: [sda] No Caching mode page found
sd 0:1:0:0: [sda] Assuming drive cache: write through
 sda: sda1 sda2 sda3 sda4
sd 0:1:0:0: [sda] Attached SCSI disk
random: nonblocking pool is initialized
EXT4-fs (sda2): INFO: recovery required on readonly filesystem
EXT4-fs (sda2): write access will be enabled during recovery
EXT4-fs (sda2): recovery complete
EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
dracut: Mounted root filesystem /dev/sda2
dracut: Switching root
                Welcome to Red Hat Enterprise Linux Server
Starting udev: udev: starting version 147
WARNING! power/level is deprecated; use power/control instead
mm/pgtable-generic.c:21: bad pgd ffff88103b135000(00000200005e0001)
kdump[4653]: segfault at 8 ip 0000003c8d278f87 sp 00007ffffc4a4db0 error 4kdump[1648]: segfault at 0 ip           (null) sp 00007ffffc4a4d58 error 14 in bash[400000+d4000]

 in libc-2.12.so[3c8d200000+18a000]------------[ cut here ]------------
WARNING: CPU: 14 PID: 1648 at mm/mmap.c:2741 exit_mmap+0x157/0x170()
Modules linked in: acpi_cpufreq(+) ext4(E) jbd2(E) mbcache(E) sd_mod(E) crc_t10dif(E) crct10dif_common(E) mpt2sas(E) scsi_transport_sas(E) raid_class(E)
CPU: 14 PID: 1648 Comm: kdump Tainted: G            E 3.15.0-rc3-mmdbg #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
 0000000000000ab5 ffff88103b139bb8 ffffffff815a9b38 0000000000000ab5
 0000000000000000 ffff88103b139bf8 ffffffff81050f2c 0000000000000000
 ffff88103b13d440 00000000000000d8 ffff88103b13d440 ffff88103b13d4d8
Call Trace:
 [<ffffffff815a9b38>] dump_stack+0x51/0x71
 [<ffffffff81050f2c>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff81050f7a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8116e8e7>] exit_mmap+0x157/0x170
 [<ffffffff811ee740>] ? exit_aio+0xb0/0x100
 [<ffffffff8104ead3>] mmput+0x73/0x110
 [<ffffffff81052434>] exit_mm+0x164/0x1d0
 [<ffffffff815af470>] ? _raw_spin_unlock_irq+0x30/0x40
 [<ffffffff81052feb>] do_exit+0x15b/0x490
 [<ffffffff8105337e>] do_group_exit+0x5e/0xd0
 [<ffffffff810654be>] get_signal_to_deliver+0x22e/0x470
 [<ffffffff810039ab>] do_signal+0x4b/0x140
 [<ffffffff815a9ab2>] ? printk+0x4d/0x4f
 [<ffffffff81171123>] ? SyS_brk+0x43/0x190
 [<ffffffff8117116e>] ? SyS_brk+0x8e/0x190
 [<ffffffff815afb8d>] ? retint_signal+0x11/0x84
 [<ffffffff81003b05>] do_notify_resume+0x65/0x90
 [<ffffffff812aeb9e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff815afbc2>] retint_signal+0x46/0x84
---[ end trace 417c6e4c2254c917 ]---
BUG: Bad rss-counter state mm:ffff88103b13d440 idx:0 val:553
BUG: Bad rss-counter state mm:ffff88103b13d440 idx:1 val:130

udevd-work[1645]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

kdump[1227]: segfault at 0 ip 0000003c8d27b6d7 sp 00007ffffa45cdf8 error 4 in libc-2.12.so[3c8d200000+18a000]
udevd-work[1224]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

udevd[1424]: segfault at 1ffffff ip 0000000001ffffff sp 00007fffe09d6598 error 14 in libnss_files-2.12.so[7f3b4e736000+c000]
general protection fault: 0000 [#1] SMP 
Modules linked in: acpi_cpufreq(+) ext4(E) jbd2(E) mbcache(E) sd_mod(E) crc_t10dif(E) crct10dif_common(E) mpt2sas(E) scsi_transport_sas(E) raid_class(E)
CPU: 14 PID: 7669 Comm: kdump Tainted: G        W   E 3.15.0-rc3-mmdbg #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
task: ffff88103e2846d0 ti: ffff8810375be000 task.ti: ffff8810375be000
RIP: 0010:[<ffffffff810c118c>]  [<ffffffff810c118c>] rcu_do_batch+0x18c/0x410
RSP: 0018:ffff88207fcc3e28  EFLAGS: 00010202
RAX: ffff88103e2846d0 RBX: ffff88103b10d690 RCX: 0000000000000001
RDX: ffff88103e2852f8 RSI: ffffffff81a4d560 RDI: ffff88103b10d690
RBP: ffff88207fcc3ea8 R08: 00000000000000c7 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000004 R14: 1e00000005f93403 R15: 000000000000000a
FS:  00007fb6c8d69700(0000) GS:ffff88207fcc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fff7d858f90 CR3: 000000007904e000 CR4: 00000000000407e0
Stack:
 ffffffff810c114d ffff88103e2846d0 0000000000000003 ffff88207fccd640
 ffffffff81a4d680 ffff88103b3a5740 ffff88103e2846d0 ffff8810375be010
 ffff88207fccd668 0000000000000000 ffff88207fcc3e98 ffff88207fccd640
Call Trace:
 <IRQ> 
 [<ffffffff810c114d>] ? rcu_do_batch+0x14d/0x410
 [<ffffffff810c14b6>] __rcu_process_callbacks+0xa6/0x190
 [<ffffffff810c1a88>] rcu_process_callbacks+0x58/0x110
 [<ffffffff8105608c>] __do_softirq+0x12c/0x320
 [<ffffffff810563b5>] irq_exit+0xc5/0xd0
 [<ffffffff815ba6ea>] smp_apic_timer_interrupt+0x4a/0x5a
 [<ffffffff815b922f>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff8118fdd2>] ? kmem_cache_free+0x102/0x280
 [<ffffffff8116e786>] remove_vma+0x76/0x80
 [<ffffffff8116e8ac>] exit_mmap+0x11c/0x170
 [<ffffffff811ee740>] ? exit_aio+0xb0/0x100
 [<ffffffff8104ead3>] mmput+0x73/0x110
 [<ffffffff811a8197>] exec_mmap+0x1b7/0x290
 [<ffffffff811a82fb>] flush_old_exec+0x8b/0xf0
 [<ffffffff811f9fe6>] load_elf_binary+0x316/0xdc0
 [<ffffffff811a76ae>] ? search_binary_handler+0xee/0x1c0
 [<ffffffff811a76ae>] ? search_binary_handler+0xee/0x1c0
 [<ffffffff811a7665>] ? search_binary_handler+0xa5/0x1c0
 [<ffffffff811a7673>] search_binary_handler+0xb3/0x1c0
 [<ffffffff81072620>] ? alloc_pid+0x280/0x280
 [<ffffffff811a7823>] exec_binprm+0xa3/0x1a0
 [<ffffffff811a7780>] ? search_binary_handler+0x1c0/0x1c0
 [<ffffffff811a9128>] do_execve_common+0x2b8/0x380
 [<ffffffff811a9287>] do_execve+0x37/0x40
 [<ffffffff811a92bf>] SyS_execve+0x2f/0x40
 [<ffffffff815b8bc9>] stub_execve+0x69/0xa0
Code: 00 00 48 c7 c7 60 d5 a4 81 48 c7 04 24 4d 11 0c 81 e8 79 51 fe ff 41 0f 18 0c 24 49 81 fe ff 0f 00 00 76 8b 48 89 df 49 83 c5 01 <ff> 53 08 48 c7 c2 85 11 0c 81 be 01 00 00 00 48 c7 c7 60 d5 a4 
RIP  [<ffffffff810c118c>] rcu_do_batch+0x18c/0x410
 RSP <ffff88207fcc3e28>
---[ end trace 417c6e4c2254c918 ]---
Kernel panic - not syncing: Fatal exception in interrupt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
