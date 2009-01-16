Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 423766B0047
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 01:25:20 -0500 (EST)
Message-ID: <49702827.2060207@cn.fujitsu.com>
Date: Fri, 16 Jan 2009 14:24:39 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG] memcg: panic when rmdir()
References: <497025E8.8050207@cn.fujitsu.com> <20090116151900.f86cc1a3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090116151900.f86cc1a3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 16 Jan 2009 14:15:04 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> Found this when testing memory resource controller, can be triggered
>> with:
>> - CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
>> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
>> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y && boot with noswapaccount
>>
>> # mount -t cgroup -o memory xxx /mnt
>> # mkdir /mnt/0
>> # for pid in `cat /mnt/tasks`; do echo $pid > /mnt/0/tasks; done
>> # echo "low limit" > /mnt/0/tasks
>> # do whatever to allocate some memory
>> # swapoff -a
>> killed (by OOM)
>> # for pid in `cat /mnt/0/tasks`; do echo $pid > /mnt/tasks; done
>> # rmdir /mnt/0
>>
> Isn't this a problem Nishimura fixed today ?
> 

Are you sure?

The changelog:
==========
The lifetime of struct cgroup and struct mem_cgroup is different and
mem_cgroup has its own reference count for handling references from swap_cgroup.

This causes strange problem that the parent mem_cgroup dies while
child mem_cgroup alive, and this problem causes a bug in case of use_hierarchy==1
because res_counter_uncharge climbs up the tree.
==========

I was not using hierarchy, and no "mem_cgroup dies while child mem_cgroup alive"
in my test.

Anyway, I'll try.

> could you try
> 
> memcg-get-put-parents-at-create-free.patch
> 
> in mm-commits ?
> 
> Sorry for inconvinience, I'll send you the patch in private mail if necessary.
> 
> Thanks,
> -Kame
> 
> 
> 
>> ------------[ cut here ]------------
>> WARNING: at kernel/res_counter.c:71 res_counter_uncharge_locked+0x25/0x36()
>> Hardware name: Aspire SA85
>> Modules linked in: bridge stp llc autofs4 dm_mirror dm_region_hash dm_log dm_mod parport_pc button sg r8169 mii parport sata_sis pata_sis ata_generic libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: scsi_wait_scan]
>> Pid: 2548, comm: rmdir Tainted: G        W  2.6.29-rc1-mm1 #4
>> Call Trace:
>>  [<c042ecb6>] warn_slowpath+0x79/0x8f
>>  [<c04496ce>] ? clockevents_program_event+0xe0/0xef
>>  [<c0463a1b>] ? res_counter_charge+0x35/0xb0
>>  [<c04639b0>] ? res_counter_uncharge+0x29/0x5f
>>  [<c0463941>] res_counter_uncharge_locked+0x25/0x36
>>  [<c04639ba>] res_counter_uncharge+0x33/0x5f
>>  [<c049b9ef>] mem_cgroup_force_empty+0x21b/0x498
>>  [<c049c82f>] mem_cgroup_pre_destroy+0x12/0x14
>>  [<c0460776>] cgroup_rmdir+0x5e/0x27e
>>  [<c0621d08>] ? _spin_unlock+0x2c/0x41
>>  [<c04a67fe>] vfs_rmdir+0x5b/0x9c
>>  [<c04a7b8c>] do_rmdir+0x89/0xc8
>>  [<c04438ed>] ? up_read+0x1b/0x2e
>>  [<c0623de4>] ? do_page_fault+0x356/0x5ed
>>  [<c04a7c14>] sys_rmdir+0x15/0x17
>>  [<c0403485>] sysenter_do_call+0x12/0x35
>> ---[ end trace 4eaa2a86a8e2da24 ]---
>> ------------[ cut here ]------------
>> kernel BUG at kernel/cgroup.c:2517!
>> invalid opcode: 0000 [#1] PREEMPT SMP
>> last sysfs file: /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/irq
>> Modules linked in: bridge stp llc autofs4 dm_mirror dm_region_hash dm_log dm_mod parport_pc button sg r8169 mii parport sata_sis pata_sis ata_generic libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: scsi_wait_scan]
>>
>> Pid: 2548, comm: rmdir Tainted: G        W  (2.6.29-rc1-mm1 #4) Aspire SA85
>> EIP: 0060:[<c04607f2>] EFLAGS: 00210046 CPU: 1
>> EIP is at cgroup_rmdir+0xda/0x27e
>> EAX: f442b800 EBX: ed00b3c0 ECX: c04607ca EDX: 00000000
>> ESI: c0778dc0 EDI: 00200246 EBP: ed252f30 ESP: ed252f14
>>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
>> Process rmdir (pid: 2548, ti=ed252000 task=e19aa8c0 task.ti=ed252000)
>> Stack:
>>  00000000 f442b800 c0621d08 e18a8014 e2d96a00 fffffff0 e2ccadf0 ed252f44
>>  c04a67fe e2d96a00 00000000 0804ca00 ed252fa8 c04a7b8c ed269080 e2d745a0
>>  00002121 00000001 f46a3000 00000000 00000000 00000000 ed0a6d34 00000004
>> Call Trace:
>>  [<c0621d08>] ? _spin_unlock+0x2c/0x41
>>  [<c04a67fe>] ? vfs_rmdir+0x5b/0x9c
>>  [<c04a7b8c>] ? do_rmdir+0x89/0xc8
>>  [<c04438ed>] ? up_read+0x1b/0x2e
>>  [<c0623de4>] ? do_page_fault+0x356/0x5ed
>>  [<c04a7c14>] ? sys_rmdir+0x15/0x17
>>  [<c0403485>] ? sysenter_do_call+0x12/0x35
>> Code: c8 fe ff 8b 43 40 8b 70 0c eb 3e 8b 46 28 8b 44 83 20 89 45 e8 8b 55 e8 8b 52 04 83 fa 01 89 55 e4 0f 8f 5f ff ff ff 85 d2 75 04 <0f> 0b eb fe 8b 45 e4 31 c9 8b 55 e8 f0 0f b1 4a 04 8b 55 e4 39
>> EIP: [<c04607f2>] cgroup_rmdir+0xda/0x27e SS:ESP 0068:ed252f14
>> ---[ end trace 4eaa2a86a8e2da25 ]---
>> 	
>>
>>
>>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
