Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 501146B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 15:19:58 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id fa1so2449052pad.34
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 12:19:55 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id wh9si17956053pac.254.2014.04.30.12.19.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 12:19:54 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 1 May 2014 05:19:50 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id DF44F2CE8047
	for <linux-mm@kvack.org>; Thu,  1 May 2014 05:19:47 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3UJJWL92818446
	for <linux-mm@kvack.org>; Thu, 1 May 2014 05:19:33 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3UJJkS8028895
	for <linux-mm@kvack.org>; Thu, 1 May 2014 05:19:47 +1000
Message-ID: <53614CA2.4000707@linux.vnet.ibm.com>
Date: Thu, 01 May 2014 00:48:58 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com> <alpine.LSU.2.11.1404281500180.2861@eggly.anvils> <1398723290.25549.20.camel@buesod1.americas.hpqcorp.net> <CA+55aFwGjYS7PqsD6A-q+Yp9YZmiM6mB4MUYmfR7ro02poxxCQ@mail.gmail.com> <535F77E8.2040000@linux.vnet.ibm.com> <53614BFE.9090804@linux.vnet.ibm.com>
In-Reply-To: <53614BFE.9090804@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Dave Jones <davej@redhat.com>

On 05/01/2014 12:46 AM, Srivatsa S. Bhat wrote:
> On 04/29/2014 03:29 PM, Srivatsa S. Bhat wrote:
>> On 04/29/2014 03:55 AM, Linus Torvalds wrote:
>>> On Mon, Apr 28, 2014 at 3:14 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>>>
>>>> I think that returning some stale/bogus vma is causing those segfaults
>>>> in udev. It shouldn't occur in a normal scenario. What puzzles me is
>>>> that it's not always reproducible. This makes me wonder what else is
>>>> going on...
>>>
>>> I've replaced the BUG_ON() with a WARN_ON_ONCE(), and made it be
>>> unconditional (so you don't have to trigger the range check).
>>>
>>> That might make it show up earlier and easier (and hopefully closer to
>>> the place that causes it). Maybe that makes it easier for Srivatsa to
>>> reproduce this. It doesn't make *my* machine do anything different,
>>> though.
>>>
>>> Srivatsa? It's in current -git.
>>>
>>
>> I tried this, but still nothing so far. I rebooted 10-20 times, and also
>> tried multiple runs of multi-threaded ebizzy and kernel compilations,
>> but none of this hit the warning.
>>
> 
> I tried to recall the *exact* steps that I had carried out when I first
> hit the bug. I realized that I had actually used kexec to boot the new
> kernel. I had originally booted into a 3.7.7 kernel that happens to be
> on that machine, and then kexec()'ed 3.15-rc3 on it. And that had caused
> the kernel crash. Fresh boots of 3.15-rc3, as well as kexec from 3.15+
> to itself, seems to be pretty robust and has never resulted in any bad
> behavior (this is why I couldn't reproduce the issue earlier, since I was
> doing fresh boots of 3.15-rc).
> 
> So I tried the same recipe again (boot into 3.7.7 and kexec into 3.15-rc3+)
> and I got totally random crashes so far, once in sys_kill and two times in
> exit_mmap. So I guess the bug is in 3.7.x and probably 3.15-rc is fine after
> all...
> 
> 
> Here is the crash around sys_kill:
> 
> 

And here are the exit_mmap related ones:

1.

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
EXT4-fs (sda2): INFO: recovery required on readonly filesystem
EXT4-fs (sda2): write access will be enabled during recovery
random: nonblocking pool is initialized
EXT4-fs (sda2): recovery complete
EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
dracut: Mounted root filesystem /dev/sda2
dracut: Switching root
                Welcome to Red Hat Enterprise Linux Server
Starting udev: udev: starting version 147
WARNING! power/level is deprecated; use power/control instead
cat[11602]: segfault at 0 ip           (null) sp 00007fff85a583f0 error 14traps: kdump[5307] general protection ip:3c8d22a8db sp:7fff03d1b418 error:0 in libc-2.12.so[3c8d200000+18a000]

 in cat[400000+b000]
udevd-work[1304]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

plymouth[12452]: segfault at 0 ip           (null) sp 00007fff49a9e570 error 14 in plymouth[400000+7000]
------------[ cut here ]------------
WARNING: CPU: 13 PID: 12452 at mm/mmap.c:2741 exit_mmap+0x157/0x170()
Modules linked in: acpi_cpufreq(+) ext4(E) jbd2(E) mbcache(E) sd_mod(E) crc_t10dif(E) crct10dif_common(E) mpt2sas(E) scsi_transport_sas(E) raid_class(E)
CPU: 13 PID: 12452 Comm: plymouth Tainted: G            E 3.15.0-rc3-mmdbg #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
BUG: Bad page map in process kdump  pte:1e00000005f98701 pmd:1031489067
addr:0000003c9e01f000 vm_flags:00100073 anon_vma:ffff88103a654550 mapping:ffff88103e91fb28 index:1f
vma->vm_ops->fault: filemap_fault+0x0/0x450
vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 [ext4]
 0000000000000ab5 ffff88202fe45bb8 ffffffff815a9b38 0000000000000ab5BUG: Bad page map in process kdump  pte:1e00000005f98701 pmd:103420b067
addr:0000003c9e01f000 vm_flags:00100073 anon_vma:ffff88102d55ce58 mapping:ffff88103e91fb28 index:1f
vma->vm_ops->fault: filemap_fault+0x0/0x450
vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 [ext4]


 0000000000000000 ffff88202fe45bf8 ffffffff81050f2c 0000000000000000
 ffff881032ca0140 0000000000000039 ffff881032ca0140 ffff881032ca01d8
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
 [<ffffffff81081c18>] ? finish_task_switch+0x48/0x120
 [<ffffffff810039ab>] do_signal+0x4b/0x140
 [<ffffffff810a4d9d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff815a9ab2>] ? printk+0x4d/0x4f
 [<ffffffff81081c55>] ? finish_task_switch+0x85/0x120
 [<ffffffff81081c18>] ? finish_task_switch+0x48/0x120
 [<ffffffff815afb8d>] ? retint_signal+0x11/0x84
 [<ffffffff81003b05>] do_notify_resume+0x65/0x90
 [<ffffffff812aeb9e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff815afbc2>] retint_signal+0x46/0x84
---[ end trace b8be17f8a0dd8372 ]---
CPU: 2 PID: 9649 Comm: kdump Tainted: G            E 3.15.0-rc3-mmdbg #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
 0000003c9e01f000 ffff881031705b40 ffffffff815a9b38 0000000000000001
 ffff8810335f28b8 ffff881031705b90 ffffffff811660b3 0000000000000000
 ffff88102fe67668 0000000000000000 0000003c9e01f000 0000000000000002
Call Trace:
 [<ffffffff815a9b38>] dump_stack+0x51/0x71
 [<ffffffff811660b3>] print_bad_pte+0x193/0x260
 [<ffffffff811661de>] vm_normal_page+0x5e/0x70
 [<ffffffff811693d7>] copy_pte_range+0x217/0x5d0
 [<ffffffff81169a0a>] copy_page_range+0x27a/0x4b0
 [<ffffffff8104e58f>] dup_mmap+0x24f/0x3f0
 [<ffffffff8104ec3c>] dup_mm+0xcc/0x170
 [<ffffffff8105009c>] copy_process+0x122c/0x1260
 [<ffffffff810a67f4>] ? __lock_release+0x84/0x180
 [<ffffffff81050581>] do_fork+0x61/0x220
 [<ffffffff811654ef>] ? might_fault+0xaf/0xc0
 [<ffffffff811654a6>] ? might_fault+0x66/0xc0
[ 8118]     0  8118    27161      807      17        0         -1000 kdump
/sbin/start_udev[14046]     0 14046     1011       65       7        0         -1000 logger
[ 1003]     0  1003     2854      556      10        0         -1000 udevd
: line 204:  116[ 6046]     0  6046     3084      796      10        0         -1000 udevd
6 Killed        [14313]     0 14313     3612     1298      11        0         -1000 udevd
[ 1618]     0  1618     3018      716      10        0         -1000 udevd
          /sbin/[13741]     0 13741     1014       65       8        0         -1000 logger
CPU: 12 PID: 8596 Comm: udevd Tainted: G    B       E 3.15.0-rc3-mmdbg #1
[ 1453]     0  1453     2985      685      10        0         -1000 udevd

Wait timeout. W[14270]     0 14270     4338      159      20        0         -1000 multipath
ill continue in swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
the background.swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
 [<ffffffff811a7780>] ? search_binary_handler+0x1c0/0x1c0
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000
swap_dup: Bad swap file entry 002a0000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
