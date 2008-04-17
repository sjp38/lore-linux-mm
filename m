Date: Thu, 17 Apr 2008 16:03:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: 2.6.25-mm1: not looking good
Message-Id: <20080417160331.b4729f0c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

I repulled all the trees an hour or two ago, installed everything on an
8-way x86_64 box and:


stack-protector:

Testing -fstack-protector-all feature
No -fstack-protector-stack-frame!
-fstack-protector-all test failed
------------[ cut here ]------------
WARNING: at kernel/panic.c:369 __stack_chk_test+0x4b/0x51()
Modules linked in:
Pid: 1, comm: swapper Not tainted 2.6.25-mm1 #4

Call Trace:
 [<ffffffff80256692>] ? print_modules+0x88/0x8f
 [<ffffffff80237b70>] warn_on_slowpath+0x58/0x7f
 [<ffffffff802388fe>] ? printk+0x67/0x69
 [<ffffffff8034ec74>] ? debug_write_lock_after+0x18/0x1f
 [<ffffffff8034ed43>] ? _raw_write_unlock+0x29/0x7b
 [<ffffffff804f0254>] ? _write_unlock+0x9/0xb
 [<ffffffff8023d25e>] ? insert_resource+0xe3/0xea
 [<ffffffff80237be2>] __stack_chk_test+0x4b/0x51
 [<ffffffff8092f912>] kernel_init+0x16c/0x29e
 [<ffffffff8020ce58>] child_rip+0xa/0x12
 [<ffffffff8092f7a6>] ? kernel_init+0x0/0x29e
 [<ffffffff8020ce4e>] ? child_rip+0x0/0x12

---[ end trace da2bc9ee81defeda ]---


usb/sysfs:

ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 17 (level, low) -> IRQ 17
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:1d.0: irq 17, io base 0x00002080
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
sysfs: duplicate filename '189:0' can not be created
------------[ cut here ]------------
WARNING: at fs/sysfs/dir.c:425 sysfs_add_one+0x42/0x7c()
Modules linked in: uhci_hcd(+)
Pid: 600, comm: insmod Tainted: G        W 2.6.25-mm1 #4

Call Trace:
 [<ffffffff80256692>] ? print_modules+0x88/0x8f
 [<ffffffff80237b70>] warn_on_slowpath+0x58/0x7f
 [<ffffffff802388fe>] ? printk+0x67/0x69
 [<ffffffff804f0249>] ? _spin_unlock+0x9/0xb
 [<ffffffff802a932f>] ? ifind+0x72/0x82
 [<ffffffff802e0c49>] ? sysfs_ilookup_test+0x0/0x14
 [<ffffffff802a93b4>] ? ilookup5_nowait+0x35/0x3e
 [<ffffffff802e0ee2>] sysfs_add_one+0x42/0x7c
 [<ffffffff802e1a0f>] sysfs_create_link+0xc9/0xfd
 [<ffffffff803c1a39>] device_add+0x15d/0x581
 [<ffffffff803c1e74>] device_register+0x17/0x1b
 [<ffffffff803c1f55>] device_create+0xdd/0x110
 [<ffffffff802e1a1a>] ? sysfs_create_link+0xd4/0xfd
 [<ffffffff8034eb5f>] ? debug_spin_lock_after+0x18/0x1f
 [<ffffffff8034efec>] ? _raw_spin_lock+0x116/0x122
 [<ffffffff8042fca8>] usb_classdev_notify+0x53/0x85
 [<ffffffff804f281b>] notifier_call_chain+0x31/0x63
 [<ffffffff8024d7e1>] __blocking_notifier_call_chain+0x44/0x5e
 [<ffffffff8024d80a>] blocking_notifier_call_chain+0xf/0x11
 [<ffffffff804324ce>] usb_notify_add_device+0x18/0x1a
 [<ffffffff8043280e>] generic_probe+0x94/0x9e
 [<ffffffff803c3ae7>] ? __device_attach+0x0/0xd
 [<ffffffff8042c48f>] usb_probe_device+0x3d/0x3f
 [<ffffffff803c39e3>] driver_probe_device+0xbe/0x14b
 [<ffffffff803c3ae7>] ? __device_attach+0x0/0xd
 [<ffffffff803c3af0>] __device_attach+0x9/0xd
 [<ffffffff803c2bb5>] bus_for_each_drv+0x4a/0x7d
 [<ffffffff803c390e>] device_attach+0x61/0x78
 [<ffffffff803c2e2a>] bus_attach_device+0x28/0x5c
 [<ffffffff803c1ccf>] device_add+0x3f3/0x581
 [<ffffffff804267f3>] usb_new_device+0x4d/0x8c
 [<ffffffff80428ef2>] usb_add_hcd+0x464/0x5c2
 [<ffffffff80432d84>] usb_hcd_pci_probe+0x1e4/0x298
 [<ffffffff80356d7f>] pci_device_probe+0xde/0x137
 [<ffffffff803c39e3>] driver_probe_device+0xbe/0x14b
 [<ffffffff803c3abc>] __driver_attach+0x4c/0x77
 [<ffffffff803c3a70>] ? __driver_attach+0x0/0x77
 [<ffffffff803c291c>] bus_for_each_dev+0x4d/0x7e
 [<ffffffff80291b83>] ? __kmalloc+0x8f/0xbe
 [<ffffffff803c360b>] driver_attach+0x1c/0x1e
 [<ffffffff803c3007>] bus_add_driver+0xaf/0x1e1
 [<ffffffff803c3d6c>] driver_register+0x55/0xbd
 [<ffffffff80356b19>] __pci_register_driver+0x71/0xa9
 [<ffffffffa000f07e>] :uhci_hcd:uhci_hcd_init+0x7e/0xae
 [<ffffffff80258435>] sys_init_module+0x18ae/0x19f5
 [<ffffffff8026855a>] ? __raw_local_irq_save+0xc/0x12
 [<ffffffff80356b51>] ? pci_unregister_driver+0x0/0x78
 [<ffffffff8020c03b>] system_call_after_swapgs+0x7b/0x80

---[ end trace da2bc9ee81defeda ]---

more usb/sysfs:

hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
sysfs: duplicate filename '189:128' can not be created
------------[ cut here ]------------
WARNING: at fs/sysfs/dir.c:425 sysfs_add_one+0x42/0x7c()
Modules linked in: uhci_hcd(+)
Pid: 600, comm: insmod Tainted: G        W 2.6.25-mm1 #4

Call Trace:
 [<ffffffff80256692>] ? print_modules+0x88/0x8f
 [<ffffffff80237b70>] warn_on_slowpath+0x58/0x7f
 [<ffffffff802388fe>] ? printk+0x67/0x69
 [<ffffffff804f0249>] ? _spin_unlock+0x9/0xb
 [<ffffffff802a932f>] ? ifind+0x72/0x82
 [<ffffffff802e0c49>] ? sysfs_ilookup_test+0x0/0x14
 [<ffffffff802a93b4>] ? ilookup5_nowait+0x35/0x3e
 [<ffffffff802e0ee2>] sysfs_add_one+0x42/0x7c
 [<ffffffff802e1a0f>] sysfs_create_link+0xc9/0xfd
 [<ffffffff803c1a39>] device_add+0x15d/0x581
 [<ffffffff803c1e74>] device_register+0x17/0x1b
 [<ffffffff803c1f55>] device_create+0xdd/0x110
 [<ffffffff802e1a1a>] ? sysfs_create_link+0xd4/0xfd
 [<ffffffff8034eb5f>] ? debug_spin_lock_after+0x18/0x1f
 [<ffffffff8034efec>] ? _raw_spin_lock+0x116/0x122


After 10 or fifteen minutes uptime, slab declared game over:

kernel BUG at mm/slab.c:590!
invalid opcode: 0000 [1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:02.0/0000:01:00.0/0000:02:02.0/0000:05:00.1/irq
CPU 5 
Modules linked in: nfsd auth_rpcgss exportfs lockd nfs_acl autofs4 hidp rfcomm l2cap bluetooth sunrpc ipv6 dm_mirror dm_log dm_multipath dm_mod sbs sbshc battery ac parport_pc lp parport sg floppy snd_hda_intel snd_seq_dummy ide_cd_mod cdrom snd_seq_oss snd_seq_midi_event snd_seq serio_raw snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer i2c_i801 snd button soundcore i2c_core snd_page_alloc shpchp pcspkr ehci_hcd ohci_hcd uhci_hcd
Pid: 0, comm: swapper Tainted: G        W 2.6.25-mm1 #4
RIP: 0010:[<ffffffff8028fea8>]  [<ffffffff8028fea8>] page_get_cache+0x19/0x24
RSP: 0018:ffff81025f22fe88  EFLAGS: 00010046
RAX: 0000000000000000 RBX: ffffe20000028440 RCX: 0000000000000007
RDX: 0000000000000000 RSI: ffffe20000028440 RDI: 0000000000000040
RBP: ffff81025f22fe90 R08: 0000000000000006 R09: ffff810001080fe8
R10: ffff8100010b7a40 R11: ffff8100010b7a28 R12: 0000000000000282
R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff81025f1616c0(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000003e5f0948f0 CR3: 000000024a01e000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff81025f22a000, task ffff81025f2294a0)
Stack:  ffffffff80a11690 ffff81025f22fea0 ffffffff8028fec4 ffff81025f22fec0
 ffffffff802909af 0000000000000000 ffff8100010b4820 ffff81025f22fed0
 ffffffff80327789 ffff81025f22ff00 ffffffff80268932 0000000000000001
Call Trace:
 <IRQ>  [<ffffffff8028fec4>] virt_to_cache+0x11/0x13
 [<ffffffff802909af>] kfree+0x20/0x38
 [<ffffffff80327789>] sel_netnode_free+0xd/0xf
 [<ffffffff80268932>] __rcu_process_callbacks+0x147/0x1b6
 [<ffffffff802689c4>] rcu_process_callbacks+0x23/0x44
 [<ffffffff8023cc04>] __do_softirq+0x58/0xae
 [<ffffffff8020d1cc>] call_softirq+0x1c/0x28
 [<ffffffff8020ed5c>] do_softirq+0x2f/0x6f
 [<ffffffff8023c72e>] irq_exit+0x36/0x38
 [<ffffffff8021dedc>] smp_apic_timer_interrupt+0x74/0x81
 [<ffffffff8020cc76>] apic_timer_interrupt+0x66/0x70
 <EOI>  [<ffffffff8020a2e1>] ? mwait_idle+0x38/0x42
 [<ffffffff8020a2a9>] ? mwait_idle+0x0/0x42
 [<ffffffff8020b2ff>] ? cpu_idle+0xcb/0xe0
 [<ffffffff804eaefe>] ? start_secondary+0xb2/0xb4


Code: 3a 48 69 c0 80 0e 00 00 48 03 04 d5 00 35 92 80 c9 c3 55 48 89 e5 53 e8 87 ff ff ff 48 89 c7 48 89 c3 e8 69 ff ff ff 85 c0 75 04 <0f> 0b eb fe 48 8b 43 30 5b c9 c3 55 48 89 e5 e8 87 ff ff ff 48 
RIP  [<ffffffff8028fea8>] page_get_cache+0x19/0x24
 RSP <ffff81025f22fe88>

security/selinux/netnode.c looks to be doing simple old kzalloc/kfree, so
I'd be suspecting slab.  But there are significant changes netnode.c in
git-selinux.

config: http://userweb.kernel.org/~akpm/config-akpm2.txt
dmesg: http://userweb.kernel.org/~akpm/dmesg-2.6.25-mm1.txt
full tree: http://userweb.kernel.org/~akpm/mmotm/

I have maybe two hours in which to weed out whatever very-recently-added
dud patches are causing this.  Any suggestions are welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
