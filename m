Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 670236B0083
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 08:05:06 -0500 (EST)
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and mems_allowed
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1267713110.29020.26.camel@useless.americas.hpqcorp.net>
References: <4B8E3F77.6070201@cn.fujitsu.com>
	 <1267713110.29020.26.camel@useless.americas.hpqcorp.net>
Content-Type: text/plain
Date: Fri, 05 Mar 2010 08:05:00 -0500
Message-Id: <1267794300.1928.5.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-03-04 at 09:31 -0500, Lee Schermerhorn wrote: 
> On Wed, 2010-03-03 at 18:52 +0800, Miao Xie wrote:
> > if MAX_NUMNODES > BITS_PER_LONG, loading/storing task->mems_allowed or mems_allowed in
> > task->mempolicy are not atomic operations, and the kernel page allocator gets an empty
> > mems_allowed when updating task->mems_allowed or mems_allowed in task->mempolicy. So we
> > use a rwlock to protect them to fix this probelm.
> > 
> > Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
> > ---
> >  include/linux/cpuset.h    |  104 +++++++++++++++++++++++++++++-
> >  include/linux/init_task.h |    8 +++
> >  include/linux/mempolicy.h |   24 ++++++--
> >  include/linux/sched.h     |   17 ++++-
> >  kernel/cpuset.c           |  113 +++++++++++++++++++++++++++------
> >  kernel/exit.c             |    4 +
> >  kernel/fork.c             |   13 ++++-
> >  mm/hugetlb.c              |    3 +
> >  mm/mempolicy.c            |  153 ++++++++++++++++++++++++++++++++++----------
> >  mm/slab.c                 |   27 +++++++-
> >  mm/slub.c                 |   10 +++
> >  11 files changed, 403 insertions(+), 73 deletions(-)
> > 
> <snip>
> > 
<snip even more> 
> > @@ -1381,8 +1434,16 @@ static struct mempolicy *get_vma_policy(struct task_struct *task,
> >  		} else if (vma->vm_policy)
> >  			pol = vma->vm_policy;
> >  	}
> > +	if (!pol) {
> > +		read_mem_lock_irqsave(task, irqflags);
> > +		pol = task->mempolicy;
> > +		mpol_get(pol);
> > +		read_mem_unlock_irqrestore(task, irqflags);
> > +	}
> > +
> 
> Please note that this change is in the fast path of task page
> allocations.  We tried real hard when reworking the mempolicy reference
> counts not to reference count the task's mempolicy because only the task
> could change its' own task mempolicy.  cpuset rebinding breaks this
> assumption, of course.
> 
> I'll run some page fault overhead tests on this series to see whether
> the effect of the additional lock round trip and reference count is
> measurable and unacceptable.

Well, I wanted to run page fault overhead tests, but when I added this
series to the 3March mmotm [applied w/ offsets, no rejects], I got NULL
pointer derefs during boot, and then the remainder of the boot crept
along for a while with looooong pauses between chunks of console output.
Finally appeared to hang. 

Stack traces below.  

Config available on request.

Lee

-----------------------
Excerpt from console output:

Platform is 8 socket x 6 core AMD numa w/ 512GB memory.

...
Loading drivers, configuring devices: input: Power Button
as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
ACPI: Power Button [PWRF]
ipmi message handler version 39.2
hpilo 0000:00:04.2: PCI INT B -> GSI 41 (level, low) -> IRQ 41
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
BUG: unable to handle kernel NULL pointer dereference at
0000000000000001
IP: [<ffffffff8106197e>] sysctl_check_table+0x277/0x35e
PGD 3049162067 PUD 3049056067 PMD 0 
input: PC Speaker as /devices/platform/pcspkr/input/input1
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/LNXSYSTM:00/modalias
CPU 10 
Modules linked in: pcspkr cdrom(+) pci_hotplug hpilo ipmi_msghandler
i2c_core container button ohci_hcd uhci_hcd ehci_hcd usbcore edd ext3
mbcache jbd fan ide_pci_generic serverworks ide_core ata_generic
pata_serverworks libata cciss scsi_mod thermal processor thermal_sys
hwmon

Pid: 2429, comm: modprobe Not tainted
2.6.33-mmotm-100302-1838-mx-mempolicy #6 /ProLiant DL785 G6   
RIP: 0010:[<ffffffff8106197e>]  [<ffffffff8106197e>] sysctl_check_table
+0x277/0x35e
RSP: 0018:ffff8840484a3d58  EFLAGS: 00010246
RAX: 0000000000000002 RBX: ffffffffa0184340 RCX: ffff883049d090c0
RDX: ffffffff81530864 RSI: ffff88104895ca00 RDI: ffffffff816e4910
RBP: ffff8840484a3da8 R08: ffffffff810bb073 R09: 0000000000000000
R10: ffff883049d7eb40 R11: 0000000000000002 R12: 0000000000000001
R13: ffffffffa0184210 R14: 0000000000000002 R15: ffff88104895ca00
FS:  00007f8c4c7316f0(0000) GS:ffff882088240000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000001 CR3: 0000003049250000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 2429, threadinfo ffff8840484a2000, task
ffff8840493aa140)
Stack:
0000000000000000 ffffffff816ab520 0000000200000000 ffff882050001c08
<0> 0000000000000000 ffffffffa01842c0 ffff883049d090c0 ffffffff8140aba0
<0> ffffffff816a4430 ffffffffa0184210 ffff8840484a3e08 ffffffff81061a0d
Call Trace:
[<ffffffff81061a0d>] sysctl_check_table+0x306/0x35e
[<ffffffffa017e004>] ? cdrom_dummy_generic_packet+0x4/0x3c [cdrom]
[<ffffffff8101c461>] ? do_ftrace_mod_code+0xb5/0x147
[<ffffffff81061a0d>] sysctl_check_table+0x306/0x35e
[<ffffffff81049537>] ? __register_sysctl_paths+0x4a/0x297
[<ffffffff810495ec>] __register_sysctl_paths+0xff/0x297
[<ffffffff81094a1b>] ? tracepoint_module_notify+0x2c/0x30
[<ffffffff812f05cf>] ? notifier_call_chain+0x38/0x60
[<ffffffffa00b5000>] ? cdrom_init+0x0/0x6a [cdrom]
EDAC MC: Ver: 2.1.0 Mar  4 2010
[<ffffffff810497b2>] register_sysctl_paths+0x2e/0x30
[<ffffffff810497cc>] register_sysctl_table+0x18/0x1a
[<ffffffffa00b5019>] cdrom_init+0x19/0x6a [cdrom]
[<ffffffff8100020e>] do_one_initcall+0x73/0x180
[<ffffffff810714d8>] sys_init_module+0xd5/0x22e
[<ffffffff81002b9b>] system_call_fastpath+0x16/0x1b
Code: 7c 24 18 00 74 21 49 8b 7d 00 48 85 ff 74 18 e8 3d fb 12 00 85 c0
75 0f 45 85 f6 74 2e 41 ff ce 4d 8b 64 24 18 eb b9 49 83 c4 40 <49> 8b
34 24 48 85 f6 75 c5 4c 89 fe 48 8b 7d b8 e8 b7 7e fe ff 
RIP  [<ffffffff8106197e>] sysctl_check_table+0x277/0x35e
RSP <ffff8840484a3d58>
CR2: 0000000000000001
QLogic/NetXen Network Driver v4.0.72
netxen_nic 0000:04:00.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
netxen_nic 0000:04:00.0: setting latency timer to 64
---[ end trace 42261946992ac8eb ]---

Then, another one:

...
netxen_nic: Dual XGb SFP+ LP Board S/N CM9BBK0915  Chip rev 0x42
netxen_nic 0000:04:00.0: firmware v4.0.406 [cut-through]
IPMI System Interface driver.
ipmi_si: Trying SMBIOS-specified kcs state machine at i/o address 0xca2,
slave address 0x20, irq 0
netxen_nic 0000:04:00.0: irq 72 for MSI/MSI-X
netxen_nic 0000:04:00.0: irq 73 for MSI/MSI-X
netxen_nic 0000:04:00.0: irq 74 for MSI/MSI-X
netxen_nic 0000:04:00.0: irq 75 for MSI/MSI-X
netxen_nic 0000:04:00.0: using msi-x interrupts
BUG: unable to handle kernel NULL pointer dereference at
0000000000000001
IP: [<ffffffff8106197e>] sysctl_check_table+0x277/0x35e
PGD 0 
Oops: 0000 [#2] SMP 
last sysfs
file: /sys/devices/pci0000:00/0000:00:06.1/host0/target0:0:0/0:0:0:0/type
CPU 0 
Modules linked in: ipmi_si(+) shpchp(+) rtc_cmos hid i2c_piix4 tpm_bios
amd64_edac_mod sg rtc_core rtc_lib serio_raw netxen_nic(+) edac_core
pcspkr cdrom(+) pci_hotplug hpilo ipmi_msghandler i2c_core container
button ohci_hcd uhci_hcd ehci_hcd usbcore edd ext3 mbcache jbd fan
ide_pci_generic serverworks ide_core ata_generic pata_serverworks libata
cciss scsi_mod thermal processor thermal_sys hwmon

Pid: 3105, comm: work_for_cpu Tainted: G      D
2.6.33-mmotm-100302-1838-mx-mempolicy #6 /ProLiant DL785 G6   
RIP: 0010:[<ffffffff8106197e>]  [<ffffffff8106197e>] sysctl_check_table
+0x277/0x35e
RSP: 0018:ffff8870495ff9a0  EFLAGS: 00010246
RAX: 0000000000000004 RBX: ffff881048432808 RCX: ffff8810451eb9f0
RDX: ffffffff81530869 RSI: ffff88104895ca00 RDI: ffffffff816e4910
RBP: ffff8870495ff9f0 R08: 0000000000000083 R09: ffffffff81946190
R10: ffff880001a16178 R11: ffff8870495ffc70 R12: 0000000000000001
R13: ffff8810451eb858 R14: 0000000000000004 R15: ffff88104895ca00
FS:  00007f65e914e6f0(0000) GS:ffff880001a00000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000001 CR3: 0000000001693000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process work_for_cpu (pid: 3105, threadinfo ffff8870495fe000, task
ffff8870493b8680)
Stack:
ffff8870495ffac0 ffff8870495ffc00 0000000400000000 00000000000412d0
<0> 0000000000000000 ffff8810451eb9d8 ffff8810451eb800 ffff8870495ffc70
<0> ffffffff816e4910 ffff881048432808 ffff8870495ffa50 ffffffff81061a0d
Call Trace:
[<ffffffff81061a0d>] sysctl_check_table+0x306/0x35e
[<ffffffff81061a0d>] sysctl_check_table+0x306/0x35e
[<ffffffff81061a0d>] sysctl_check_table+0x306/0x35e
[<ffffffff81061a0d>] sysctl_check_table+0x306/0x35e
[<ffffffff81048591>] ? sysctl_set_parent+0x29/0x38
[<ffffffff810495ec>] __register_sysctl_paths+0xff/0x297
[<ffffffff812d6b4b>] register_net_sysctl_table+0x50/0x55
[<ffffffff8127207e>] neigh_sysctl_register+0x1e4/0x21d
[<ffffffff810474bf>] ? local_bh_enable_ip+0xc1/0xc6
[<ffffffff812b6d40>] devinet_sysctl_register+0x29/0x44
[<ffffffff812b6e76>] inetdev_init+0x11b/0x158
[<ffffffff812b6f13>] inetdev_event+0x60/0x3d6
[<ffffffff81225706>] ? device_add+0x46e/0x541
[<ffffffff812f05cf>] notifier_call_chain+0x38/0x60
[<ffffffff8105e338>] raw_notifier_call_chain+0x14/0x16
[<ffffffff8126e142>] register_netdevice+0x346/0x3c2
[<ffffffff8126e1fd>] register_netdev+0x3f/0x4d
[<ffffffffa01a7b0e>] netxen_nic_probe+0x8b9/0xac4 [netxen_nic]
[<ffffffff81056910>] ? do_work_for_cpu+0x0/0x2a
[<ffffffff811a54b5>] local_pci_probe+0x17/0x1b
ipmi: Found new BMC (man_id: 0x00000b,  prod_id: 0x0000, dev_id: 0x11)
IPMI kcs interface initialized
ipmi_si: Trying SPMI-specified kcs state machine at i/o address 0xca2,
slave address 0x0, irq 0
ipmi_si: duplicate interface
[<ffffffff81056928>] do_work_for_cpu+0x18/0x2a
[<ffffffff81056910>] ? do_work_for_cpu+0x0/0x2a
[<ffffffff81059d54>] kthread+0x82/0x8a
[<ffffffff81003994>] kernel_thread_helper+0x4/0x10
[<ffffffff812ed5e9>] ? restore_args+0x0/0x30
[<ffffffff81059cd2>] ? kthread+0x0/0x8a
[<ffffffff81003990>] ? kernel_thread_helper+0x0/0x10
Code: 7c 24 18 00 74 21 49 8b 7d 00 48 85 ff 74 18 e8 3d fb 12 00 85 c0
75 0f 45 85 f6 74 2e 41 ff ce 4d 8b 64 24 18 eb b9 49 83 c4 40 <49> 8b
34 24 48 85 f6 75 c5 4c 89 fe 48 8b 7d b8 e8 b7 7e fe ff 
RIP  [<ffffffff8106197e>] sysctl_check_table+0x277/0x35e
RSP <ffff8870495ff9a0>
CR2: 0000000000000001
---[ end trace 42261946992ac8ec ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
