Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B44306B00A1
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 04:15:48 -0500 (EST)
Message-ID: <49744499.2040101@cn.fujitsu.com>
Date: Mon, 19 Jan 2009 17:15:05 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [memcg BUG] NULL pointer dereference wheng rmdir
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I tested it on IA64, below are the steps to reproduce the bug:

# mount -t cgroup -o memory xxx /mnt
# mkdir /mnt/0
# for pid in `cat /mnt/tasks`; do echo $pid > /mnt/0/tasks; done
# for pid in `cat /mnt/0/tasks`; do echo $pid > /mnt/tasks; done
# rmdir /mnt/0

===========================================================================
Unable to handle kernel NULL pointer dereference (address 0000000000002680)
rmdir[11520]: Oops 8821862825984 [1]
Modules linked in: autofs4 sunrpc ipmi_watchdog ipmi_devintf ipmi_si ipmi_msghandler vfat fat dm_mirror dm_region_hash dm_log dm_multipath dm_mod rng_core e100 iTCO_wdt mii iTCO_vendor_support button sg usb_storage lpfc scsi_transport_fc shpchp mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: ipmi_watchdog]

Pid: 11520, CPU 1, comm:                rmdir
psr : 00001010085a2010 ifs : 8000000000000001 ip  : [<a0000001002ca020>]    Not tainted (2.6.29-rc2-mm1-FOR_BISECT)
ip is at _raw_spin_trylock+0x20/0x80
unat: 0000000000000000 pfs : 0000000000000286 rsc : 0000000000000003
rnat: 0000000000555659 bsps: a000000100190380 pr  : 000000000055a699
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001006035c0 b6  : a000000100016760 b7  : a00000010000bae0
f6  : 1003e6b6b6b6b6b6b6b6b f7  : 0ffe8b01d00cce0000000
f8  : 1003e0000000000003bf0 f9  : 1003efffffffffffffbb8
f10 : 10002dffffffff5b74c91 f11 : 1003e0000000000000000
r1  : a000000100dc48c0 r2  : 0000000000000001 r3  : ffffffffffffffff
r8  : 0000000000000010 r9  : 0000000000004000 r10 : 0000000000000001
r11 : 0000000000000000 r12 : e0000040cabbfd90 r13 : e0000040cabb0000
r14 : e0000040cabb0e98 r15 : 0000000000000001 r16 : e000012085df54b8
r17 : e000012085df5468 r18 : e000012085df5468 r19 : 0000000000000000
r20 : 0000000000000000 r21 : 0000000000000000 r22 : 0000000000000000
r23 : e000012085df5468 r24 : e0000000011e2f88 r25 : e000012085b20238
r26 : 0000000000000080 r27 : e0000000011e2f08 r28 : e000012085b201a0
r29 : 0000000000000000 r30 : e0000000011e2f00 r31 : 0000000000000000

Call Trace:
 [<a000000100015c00>] show_stack+0x40/0xa0
                                sp=e0000040cabbf960 bsp=e0000040cabb1238
 [<a000000100016510>] show_regs+0x850/0x8a0
                                sp=e0000040cabbfb30 bsp=e0000040cabb11d8
 [<a000000100039f50>] die+0x230/0x360
                                sp=e0000040cabbfb30 bsp=e0000040cabb1190
 [<a000000100609a20>] ia64_do_page_fault+0xa00/0xb60
                                sp=e0000040cabbfb30 bsp=e0000040cabb1140
 [<a00000010000c2e0>] ia64_native_leave_kernel+0x0/0x280
                                sp=e0000040cabbfbc0 bsp=e0000040cabb1140
 [<a0000001002ca020>] _raw_spin_trylock+0x20/0x80
                                sp=e0000040cabbfd90 bsp=e0000040cabb1138
 [<a0000001006035c0>] _spin_lock_irqsave+0x60/0x1a0
                                sp=e0000040cabbfd90 bsp=e0000040cabb1110
 [<a00000010019db10>] mem_cgroup_force_empty+0x1f0/0xd60
                                sp=e0000040cabbfd90 bsp=e0000040cabb1070
 [<a0000001001a0fb0>] mem_cgroup_pre_destroy+0x30/0x60
                                sp=e0000040cabbfda0 bsp=e0000040cabb1048
 [<a0000001000edb50>] cgroup_rmdir+0x150/0x8e0
                                sp=e0000040cabbfda0 bsp=e0000040cabb1008
 [<a0000001001bbdd0>] vfs_rmdir+0x110/0x1e0
                                sp=e0000040cabbfda0 bsp=e0000040cabb0fc0
 [<a0000001001bfaf0>] do_rmdir+0x170/0x240
                                sp=e0000040cabbfda0 bsp=e0000040cabb0f88
 [<a0000001001bfc90>] sys_rmdir+0x30/0x60
                                sp=e0000040cabbfe30 bsp=e0000040cabb0f30
 [<a00000010000c090>] ia64_trace_syscall+0xf0/0x130
                                sp=e0000040cabbfe30 bsp=e0000040cabb0f30
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e0000040cabc0000 bsp=e0000040cabb0f30
note: rmdir[11520] exited with preempt_count 1
===========================================================================


And I've confirmed it's because (zone == NULL) in mem_cgroup_force_empty_list():

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
