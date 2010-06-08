Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A81B06B0241
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 08:36:42 -0400 (EDT)
Date: Tue, 8 Jun 2010 13:36:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.6.35-rc2: GPF while executing libhugetlbfs tests on x86_64
Message-ID: <20100608123622.GE27717@csn.ul.ie>
References: <4C0BC7F0.8030109@in.ibm.com> <20100608091817.GA27717@csn.ul.ie> <4C0E2E84.6060605@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4C0E2E84.6060605@in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Sachin Sant <sachinp@in.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 08, 2010 at 05:20:28PM +0530, Sachin Sant wrote:
> Mel Gorman wrote:
>> On Sun, Jun 06, 2010 at 09:38:16PM +0530, Sachin Sant wrote:
>>   
>>> While executing libhugetlbfs tests against 2.6.35-rc2 on
>>> a x86_64 box came across the following GPF
>>>
>>> eneral protection fault: 0000 [#1] SMP
>>> last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
>>> CPU 3
>>> Modules linked in: ipv6 mperf fuse loop dm_mod sr_mod cdrom usb_storage sg i2c_piix4 rtc_cmos bnx2 k8temp pcspkr serio_raw mptctl i2c_core rtc_core rtc_lib shpchp button pci_hotplug usbhid hid ohci_hcd ehci_hcd sd_mod crc_t10dif usbcore edd ext3 jbd fan thermal processor thermal_sys hwmon mptsas mptscsih mptbase scsi_transport_sas scsi_mod
>>>
>>> Pid: 20232, comm: autotest Not tainted 2.6.35-rc2-autotest #1 Server Blade/BladeCenter LS21 -[79716AA]-
>>> RIP: 0010:[<ffffffff813968ca>]  [<ffffffff813968ca>] _raw_spin_lock+0x9/0x20
>>> RSP: 0018:ffff880126e43d88  EFLAGS: 00010202
>>> RAX: 0000000000010000 RBX: 0720072007200720 RCX: 0000000000000000
>>> RDX: 0000000000000011 RSI: ffff8801293a7470 RDI: 0720072007200720
>>> RBP: ffff880126e43d88 R08: ffff8801279df270 R09: 09f911029d74e35b
>>> R10: 09f911029d74e35b R11: dead000000100100 R12: ffff8801278cae00
>>> R13: 0720072007200710 R14: ffff8801297e71f8 R15: 0000000000000000
>>> FS:  00007f461d6866f0(0000) GS:ffff880006180000(0000) knlGS:0000000055731b00
>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> CR2: 00007f461d45a7b8 CR3: 0000000001713000 CR4: 00000000000006e0
>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Process autotest (pid: 20232, threadinfo ffff880126e42000, task ffff8801297e4190)
>>> Stack:
>>> ffff880126e43db8 ffffffff810f6b80 ffff8801297ae858 ffff8801297e7190
>>> <0> ffff8801297e7190 00007f461940e000 ffff880126e43e08 ffffffff810f025e
>>> <0> 00000000ffffffff 0000000000000000 ffff88000618d690 ffff88000618d690
>>> Call Trace:
>>> [<ffffffff810f6b80>] unlink_anon_vmas+0x37/0xf2
>>> [<ffffffff810f025e>] free_pgtables+0x5f/0xc9
>>> [<ffffffff810f1ac1>] exit_mmap+0xe6/0x141
>>>     
>>
>> While at first glance this looks like a general bug, it might still be
>> some oddity in hugetlbfs. Sachin, how reproducible is this? I just ran the
>> libhugetlbfs tests just fine on x86-64. Can you post your .config please?
>>   
> I think the root cause for this problem was same as the one
> mentioned in this thread (Bug kmalloc-4096 : Poison overwritten)
>
> http://marc.info/?l=linux-kernel&m=127586004308747&w=2 <http://marc.info/?l=linux-kernel&m=127586004308747&w=2>
>

It's very likely. 

> Some of the registers from the trace does seem to contain the
> peculiar pattern : 0720072007200720
>
> I was not able to recreate this problem again with latest snapshot.
>

If the problem has gone away since 2.6.35-rc2, the most likely candidate fix
patch is commit [386f40: Revert "tty: fix a little bug in scrup, vt.c"] which
reverts the patch you previously identified as being a problem.  The commit
message also matches roughly what you are seeing with the 0x0720 patterns.

Can you retest with 2.6.35-rc2 with commit 386f40 applied and see if it
also fixes up your problem please?

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
