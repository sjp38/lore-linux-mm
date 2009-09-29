Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D7A4B6B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 05:14:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8T9ZYsg031514
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 29 Sep 2009 18:35:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1903745DE51
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 18:35:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E733945DE53
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 18:35:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C546A1DB8043
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 18:35:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 14C4D1DB803F
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 18:35:33 +0900 (JST)
Date: Tue, 29 Sep 2009 18:33:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: some modification to softlimit under
 hierarchical memory reclaim.
Message-Id: <20090929183321.3d4fbc1d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090929061132.GA498@balbir.in.ibm.com>
References: <20090929150141.0e672290.kamezawa.hiroyu@jp.fujitsu.com>
	<20090929061132.GA498@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Sep 2009 11:41:32 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-29 15:01:41]:
> 
> > No major changes in this patch for 3 weeks.
> > While testing, I found a few css->refcnt bug in softlimit.(and posted patches)
> > But it seems no more (easy) ones.
> >
> 
> Kamezawa-San, this worries me, could you please confirm if you are
> able to see this behaviour without your patches applied as well? I am
> doing some more stress tests on my side.
>  
I found an easy way to reprocue. And yes, it can happen without this series.

==
#!/bin/bash -x

mount -tcgroup none /cgroups -omemory
mkdir /cgroups/A

while true;do
        mkdir /cgroups/A/01
        echo 3M > /cgroups/A/01/memory.soft_limit_in_bytes
        echo $$ > /cgroups/A/01/tasks
        dd if=/dev/zero of=./tmpfile bs=4096 count=1024
        rm ./tmpfile
        sync
        sleep 1
        echo $$ > /cgroups/A/tasks
        rmdir /cgroups/A/01
done
==
Run this scipt under memory pressure.
Then folloiwng happens. refcnt goes bad. (WARN_ON is my css_refcnt patch's one)

My patch fixes this as far as I tested. 

Bye,
-Kame
==
ep 29 18:24:57 localhost kernel: [  253.756803] Modules linked in: sco bridge stp bnep l2cap crc16 bluetooth rfkill iptable_filter ip_tables
ip6table_filter ip6_tables x_tables ipv6 cpufreq_ondemand acpi_cpufreq dm_mirror dm_region_hash dm_log dm_multipath dm_mod uinput ppdev i2c_i8
01 pcspkr i2c_core bnx2 sg e1000e parport_pc parport button shpchp megaraid_sas sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unlo
aded: microcode]
Sep 29 18:24:57 localhost kernel: [  253.756846] Pid: 3561, comm: rmdir Not tainted 2.6.32-rc2 #5
Sep 29 18:24:57 localhost kernel: [  253.756849] Call Trace:
Sep 29 18:24:57 localhost kernel: [  253.756853]  [<ffffffff810a62d6>] ? __css_put+0x106/0x120
Sep 29 18:24:57 localhost kernel: [  253.756859]  [<ffffffff810502a0>] warn_slowpath_common+0x80/0xd0
Sep 29 18:24:57 localhost kernel: [  253.756863]  [<ffffffff81050304>] warn_slowpath_null+0x14/0x20
Sep 29 18:24:57 localhost kernel: [  253.756866]  [<ffffffff810a62d6>] __css_put+0x106/0x120
Sep 29 18:24:57 localhost kernel: [  253.756870]  [<ffffffff810a61d0>] ? __css_put+0x0/0x120
Sep 29 18:24:57 localhost kernel: [  253.756875]  [<ffffffff81132f42>] mem_cgroup_force_empty+0x7c2/0x870
Sep 29 18:24:57 localhost kernel: [  253.756880]  [<ffffffff8108a45d>] ? trace_hardirqs_on+0xd/0x10
Sep 29 18:24:57 localhost kernel: [  253.756884]  [<ffffffff81133004>] mem_cgroup_pre_destroy+0x14/0x20
Sep 29 18:24:57 localhost kernel: [  253.756887]  [<ffffffff810a7531>] cgroup_rmdir+0xb1/0x4e0
Sep 29 18:24:57 localhost kernel: [  253.756892]  [<ffffffff81076890>] ? autoremove_wake_function+0x0/0x40
Sep 29 18:24:57 localhost kernel: [  253.756897]  [<ffffffff81147a21>] vfs_rmdir+0x131/0x160
Sep 29 18:24:57 localhost kernel: [  253.756901]  [<ffffffff8114a453>] do_rmdir+0x113/0x130
Sep 29 18:24:57 localhost kernel: [  253.756907]  [<ffffffff8100c9e9>] ? retint_swapgs+0xe/0x13
Sep 29 18:24:57 localhost kernel: [  253.756912]  [<ffffffff810b82b2>] ? audit_syscall_entry+0x202/0x230
Sep 29 18:24:57 localhost kernel: [  253.756915]  [<ffffffff8114a4c6>] sys_rmdir+0x16/0x20
Sep 29 18:24:57 localhost kernel: [  253.756919]  [<ffffffff8100bf9b>] system_call_fastpath+0x16/0x1b
Sep 29 18:24:57 localhost kernel: [  253.756922] ---[ end trace 871ca24f2f871b2a ]---
Sep 29 18:25:00 localhost kernel: [  256.363888] ------------[ cut here ]------------
Sep 29 18:25:00 localhost kernel: [  256.363895] kernel BUG at kernel/cgroup.c:3057!
Sep 29 18:25:00 localhost kernel: [  256.363899] invalid opcode: 0000 [#1] SMP
Sep 29 18:25:00 localhost kernel: [  256.363904] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
Sep 29 18:25:00 localhost kernel: [  256.363907] CPU 4
Sep 29 18:25:00 localhost kernel: [  256.363910] Modules linked in: sco bridge stp bnep l2cap crc16 bluetooth rfkill iptable_filter ip_tables
ip6table_filter ip6_tables x_tables ipv6 cpufreq_ondemand acpi_cpufreq dm_mirror dm_region_hash dm_log dm_multipath dm_mod uinput ppdev i2c_i8
01 pcspkr i2c_core bnx2 sg e1000e parport_pc parport button shpchp megaraid_sas sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unlo
aded: microcode]
Sep 29 18:25:00 localhost kernel: [  256.363962] Pid: 3574, comm: rmdir Tainted: G        W  2.6.32-rc2 #5 PRIMERGY
Sep 29 18:25:00 localhost kernel: [  256.363965] RIP: 0010:[<ffffffff810a7740>]  [<ffffffff810a7740>] cgroup_rmdir+0x2c0/0x4e0
Sep 29 18:25:00 localhost kernel: [  256.363977] RSP: 0018:ffff880620c7bdf8  EFLAGS: 00010046
Sep 29 18:25:00 localhost kernel: [  256.363980] RAX: 0000000000000003 RBX: ffff880621e7bf08 RCX: ffff8806131bd800
Sep 29 18:25:00 localhost kernel: [  256.363983] RDX: 0000000000000000 RSI: ffff880621e7c000 RDI: ffffffff818c1940
Sep 29 18:25:00 localhost kernel: [  256.363986] RBP: ffff880620c7be68 R08: ffff880621e7c020 R09: 0000000000000000
Sep 29 18:25:00 localhost kernel: [  256.363989] R10: 0000000000000001 R11: 0000000000000000 R12: ffff88061e773800
Sep 29 18:25:00 localhost kernel: [  256.363993] R13: 0000000000000282 R14: ffff88061e773820 R15: ffff88062206e800
Sep 29 18:25:00 localhost kernel: [  256.363996] FS:  00007fc7eb91f6f0(0000) GS:ffff880050200000(0000) knlGS:0000000000000000
Sep 29 18:25:00 localhost kernel: [  256.364000] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Sep 29 18:25:00 localhost kernel: [  256.364003] CR2: 0000003f6b0d9cd0 CR3: 0000000622c60000 CR4: 00000000000006e0
Sep 29 18:25:00 localhost kernel: [  256.364007] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep 29 18:25:00 localhost kernel: [  256.364011] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Sep 29 18:25:00 localhost kernel: [  256.364014] Process rmdir (pid: 3574, threadinfo ffff880620c7a000, task ffff880622de2860)
Sep 29 18:25:00 localhost kernel: [  256.364017] Stack:
Sep 29 18:25:00 localhost kernel: [  256.364019]  0000000000000000 ffff880622de2860 0000000000000000 ffff880622de2860
Sep 29 18:25:00 localhost kernel: [  256.364024] <0> ffffffff81076890 ffffffff8181ebe0 ffffffff8181ebe0 ffff88061ebd1000
Sep 29 18:25:00 localhost kernel: [  256.364030] <0> 0000000000000000 0000000000000000 ffff880614158dc8 ffff88061ebd1000
Sep 29 18:25:00 localhost kernel: [  256.364038] Call Trace:
Sep 29 18:25:00 localhost kernel: [  256.364046]  [<ffffffff81076890>] ? autoremove_wake_function+0x0/0x40
Sep 29 18:25:00 localhost kernel: [  256.364053]  [<ffffffff81147a21>] vfs_rmdir+0x131/0x160
Sep 29 18:25:00 localhost kernel: [  256.364057]  [<ffffffff8114a453>] do_rmdir+0x113/0x130
Sep 29 18:25:00 localhost kernel: [  256.364064]  [<ffffffff8100c9e9>] ? retint_swapgs+0xe/0x13
Sep 29 18:25:00 localhost kernel: [  256.364071]  [<ffffffff810b82b2>] ? audit_syscall_entry+0x202/0x230
Sep 29 18:25:00 localhost kernel: [  256.364076]  [<ffffffff8114a4c6>] sys_rmdir+0x16/0x20
Sep 29 18:25:00 localhost kernel: [  256.364080]  [<ffffffff8100bf9b>] system_call_fastpath+0x16/0x1b
Sep 29 18:25:00 localhost kernel: [  256.364083] Code: 1f 40 00 48 8b 87 18 01 00 00 49 8b 74 24 68 48 8d b8 e8 fe ff ff e9 8f fe ff ff e8 1b
2d fe ff 41 55 9d eb 87 66 0f 1f 44 00 00 <0f> 0b eb fe 0f 1f 40 00 f0 41 80 24 24 f7 48 83 c4 48 5b 41 5c
Sep 29 18:25:00 localhost kernel: [  256.364141] RIP  [<ffffffff810a7740>] cgroup_rmdir+0x2c0/0x4e0
Sep 29 18:25:00 localhost kernel: [  256.364146]  RSP <ffff880620c7bdf8>
Sep 29 18:25:00 localhost kernel: [  256.364152] ---[ end trace 871ca24f2f871b2b ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
