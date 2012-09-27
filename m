Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id C47FC6B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 20:54:09 -0400 (EDT)
Message-ID: <5063A507.3030004@cn.fujitsu.com>
Date: Thu, 27 Sep 2012 08:59:51 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v9 PATCH 00/21] memory-hotplug: hot-remove physical memory
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com> <20120926164649.GA7559@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20120926164649.GA7559@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

At 09/27/2012 12:46 AM, Vasilis Liaskovitis Wrote:
> Hi,
> 
> I am testing 3.6.0-rc7 with this v9 patchset plus more recent fixes [1],[2],[3]
> Running in a guest (qemu+seabios from [4]). 
> CONFIG_SLAB=y
> CONFIG_DEBUG_SLAB=y
> 
> After succesfull hot-add and online, I am doing a hot-remove with "echo 1 > /sys/bus/acpi/devices/PNP/eject"
> When I do the OSPM-eject, I often get slab corruption in "acpi-state" cache, or in other caches
> 
> [  170.566995] Slab corruption (Not tainted): Acpi-State start=ffff88009fc1e548, len=80
> [  170.567265] Redzone: 0x0/0x0.
> [  170.567399] Last user: [<          (null)>](0x0)
> [  170.567667] 000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  170.568078] 010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  170.568487] 020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  170.568894] 030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  170.569302] 040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  170.569712] Prev obj: start=000000009fc1e4d0, len=80
> [  170.569869] BUG: unable to handle kernel paging request at 000000009fc1e520
> [  170.570171] IP: [<ffffffff8112803c>] print_objinfo+0x9c/0x110
> [  170.570397] PGD 7cf37067 PUD 0 
> [  170.570619] Oops: 0000 [#1] SMP 
> [  170.570843] Modules linked in: netconsole acpiphp pci_hotplug acpi_memhotplug loop kvm_amd kvm tpm_tis microcode tpm tpm_bios psmouse parport_pc serio_raw evdev parport i2c_piix4 processor thermal_sys i2c_core button ext3 jbd mbcache sg sr_mod cdrom ata_generic virtio_net virtio_blk ata_piix libata scsi_mod virtio_pci virtio_ring virtio
> [  170.573474] CPU 0 
> [  170.573568] Pid: 29, comm: kworker/0:1 Not tainted 3.6.0-rc7-guest #12 Bochs Bochs
> [  170.573830] RIP: 0010:[<ffffffff8112803c>]  [<ffffffff8112803c>] print_objinfo+0x9c/0x110
> [  170.574106] RSP: 0018:ffff88003eaf3a70  EFLAGS: 00010202
> [  170.574268] RAX: 000000009fc1e4c8 RBX: 0000000000000002 RCX: 00000000000024b8
> [  170.574468] RDX: 000000009fc1e4c8 RSI: 000000009fc1e4c8 RDI: ffff88003e9bb980
> [  170.574668] RBP: ffff88003e9bb980 R08: ffff880037964078 R09: 0000000000000000
> [  170.574870] R10: 000000000000021e R11: 0000000000000002 R12: 000000009fc1e4c8
> [  170.575070] R13: 000000009fc1e520 R14: 000000000000004f R15: 00000000ffffffa5
> [  170.575274] FS:  00007fc6b7530700(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
> [  170.575494] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  170.575665] CR2: 000000009fc1e520 CR3: 000000007c9c1000 CR4: 00000000000006f0
> [  170.575870] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  170.576075] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  170.576276] Process kworker/0:1 (pid: 29, threadinfo ffff88003eaf2000, task ffff88003ea941c0)
> [  170.576507] Stack:
> [  170.576599]  0000000000000010 0000000001893fbe ffff88009fc1e000 0000000000000050
> [  170.576938]  000000009fc1e4c8 000000000000004f 00000000ffffffa5 ffffffff8112899f
> [  170.576938]  ffff88003eb309d8 ffffffff81712d6d ffff88003e9bb980 ffff88009fc1e540
> [  170.576938] Call Trace:
> [  170.576938]  [<ffffffff8112899f>] ? check_poison_obj+0x1df/0x1f0
> [  170.576938]  [<ffffffff813047d0>] ? acpi_ut_create_generic_state+0x2f/0x4c
> [  170.576938]  [<ffffffff813047d0>] ? acpi_ut_create_generic_state+0x2f/0x4c
> [  170.576938]  [<ffffffff81128a9d>] ? cache_alloc_debugcheck_after.isra.52+0xed/0x220
> [  170.576938]  [<ffffffff813047d0>] ? acpi_ut_create_generic_state+0x2f/0x4c
> [  170.576938]  [<ffffffff8112beb5>] ? kmem_cache_alloc+0xb5/0x1e0
> [  170.576938]  [<ffffffff813047d0>] ? acpi_ut_create_generic_state+0x2f/0x4c
> [  170.576938]  [<ffffffff812edf2d>] ? acpi_ds_result_push+0x5d/0x12e
> [  170.576938]  [<ffffffff812ed127>] ? acpi_ds_exec_end_op+0x28e/0x3d3
> [  170.576938]  [<ffffffff812fd86a>] ? acpi_ps_parse_loop+0x79f/0x931
> [  170.576938]  [<ffffffff812fdd6c>] ? acpi_ps_parse_aml+0x89/0x261
> [  170.576938]  [<ffffffff812fe50c>] ? acpi_ps_execute_method+0x1be/0x266
> [  170.576938]  [<ffffffff812f91f7>] ? acpi_ns_evaluate+0xd3/0x19a
> [  170.576938]  [<ffffffff812fb93e>] ? acpi_evaluate_object+0xf3/0x1f4
> [  170.576938]  [<ffffffff812e1104>] ? acpi_os_wait_events_complete+0x1b/0x1b
> [  170.576938]  [<ffffffff812e4782>] ? acpi_bus_hot_remove_device+0xeb/0x123
> [  170.576938]  [<ffffffff812e1121>] ? acpi_os_execute_deferred+0x1d/0x29
> [  170.576938]  [<ffffffff81058ec5>] ? process_one_work+0x125/0x560
> [  170.576938]  [<ffffffff81059e7a>] ? worker_thread+0x16a/0x4e0
> [  170.576938]  [<ffffffff81059d10>] ? manage_workers+0x310/0x310
> [  170.576938]  [<ffffffff8105e6c5>] ? kthread+0x85/0x90
> [  170.576938]  [<ffffffff814eb2c4>] ? kernel_thread_helper+0x4/0x10
> [  170.576938]  [<ffffffff8105e640>] ? flush_kthread_worker+0xa0/0xa0
> [  170.576938]  [<ffffffff814eb2c0>] ? gs_change+0x13/0x13
> [  170.576938] Code: cb 75 dc 48 83 c4 08 5b 5d 41 5c 41 5d 41 5e 41 5f c3 8b 7f 0c 4c 89 e2 e8 02 fd ff ff 4c 89 e6 49 89 c5 48 89 ef e8 d4 fc ff ff <49> 8b 55 00 48 8b 30 48 c7 c7 8c 39 6f 81 31 c0 e8 3e 34 3b 00 
> 
> Other times, the problem happens on a slab object free:
> 
> [   52.313366] Offlined Pages 32768
> [   52.800232] slab error in verify_redzone_free(): cache `Acpi-ParseExt': memory outside object was overwritten
> [   52.801298] Pid: 29, comm: kworker/0:1 Not tainted 3.6.0-rc7-guest #12
> [   52.802039] Call Trace:
> [   52.802443]  [<ffffffff811280cb>] ? __slab_error.isra.46+0x1b/0x30
> [   52.803199]  [<ffffffff811287b6>] ? cache_free_debugcheck+0x256/0x260
> [   52.803940]  [<ffffffff812e1b0e>] ? acpi_os_release_object+0x7/0xc
> [   52.804645]  [<ffffffff81128fe3>] ? kmem_cache_free+0x63/0x260
> [   52.805321]  [<ffffffff812e1b0e>] ? acpi_os_release_object+0x7/0xc
> [   52.806023]  [<ffffffff812fe298>] ? acpi_ps_delete_parse_tree+0x34/0x58
> [   52.806762]  [<ffffffff812fe517>] ? acpi_ps_execute_method+0x1c9/0x266
> [   52.807499]  [<ffffffff812f91f7>] ? acpi_ns_evaluate+0xd3/0x19a
> [   52.808183]  [<ffffffff812fb93e>] ? acpi_evaluate_object+0xf3/0x1f4
> [   52.808897]  [<ffffffff812e1104>] ? acpi_os_wait_events_complete+0x1b/0x1b
> [   52.809659]  [<ffffffff812e4782>] ? acpi_bus_hot_remove_device+0xeb/0x123
> [   52.810032]  [<ffffffff812e1121>] ? acpi_os_execute_deferred+0x1d/0x29
> [   52.810032]  [<ffffffff81058ec5>] ? process_one_work+0x125/0x560
> [   52.810032]  [<ffffffff81059e7a>] ? worker_thread+0x16a/0x4e0
> [   52.810032]  [<ffffffff81059d10>] ? manage_workers+0x310/0x310
> [   52.810032]  [<ffffffff8105e6c5>] ? kthread+0x85/0x90
> [   52.810032]  [<ffffffff814eb2c4>] ? kernel_thread_helper+0x4/0x10
> [   52.810032]  [<ffffffff8105e640>] ? flush_kthread_worker+0xa0/0xa0
> [   52.810032]  [<ffffffff814eb2c0>] ? gs_change+0x13/0x13
> [   52.810032] ffff88008f809670: redzone 1:0x0, redzone 2:0x0.
> [   52.810032] ------------[ cut here ]------------
> [   52.810032] kernel BUG at mm/slab.c:3125!
> [   52.810032] invalid opcode: 0000 [#1] SMP 
> [   52.810032] Modules linked in: netconsole acpiphp pci_hotplug acpi_memhotplug loop kvm_amd kvm tpm_tis tpm tpm_bios microcode parport_pc parport evdev processor thermal_sys psmouse i2c_piix4 serio_raw i2c_core button ext3 jbd mbcache sg sr_mod cdrom virtio_net ata_generic virtio_blk virtio_pci virtio_ring virtio ata_piix libata scsi_mod
> [   52.810032] CPU 0 
> [   52.810032] Pid: 29, comm: kworker/0:1 Not tainted 3.6.0-rc7-guest #12 Bochs Bochs
> [   52.810032] RIP: 0010:[<ffffffff81128733>]  [<ffffffff81128733>] cache_free_debugcheck+0x1d3/0x260
> [   52.810032] RSP: 0018:ffff88003eaf3bc0  EFLAGS: 00010093
> [   52.810032] RAX: 00000000017eac3c RBX: ffff88003e9bb700 RCX: 0000000002aaaaab
> [   52.810032] RDX: 0000000000000000 RSI: 0000000000010000 RDI: 0000000000000060
> [   52.810032] RBP: ffff88008f809670 R08: 09f911029d74e35b R09: 0000000000000000
> [   52.810032] R10: 00000000000001d3 R11: 0000000000000002 R12: ffff88008f809000
> [   52.810032] R13: ffffffff812e1b0e R14: 0000000000000000 R15: 0000000000010c00
> [   52.810032] FS:  00007f63fc263700(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
> [   52.810032] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   52.810032] CR2: 00007fff8d895b78 CR3: 000000007c866000 CR4: 00000000000006f0
> [   52.810032] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   52.810032] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   52.810032] Process kworker/0:1 (pid: 29, threadinfo ffff88003eaf2000, task ffff88003ea941c0)
> [   52.810032] Stack:
> [   52.810032]  ffff88003e9bb980 ffff88008f809670 ffff880037ba8e18 ffff88008f809678
> [   52.810032]  ffff88003e9bb700 0000000000000282 ffff88003e9bf270 ffffffff812e1b0e
> [   52.810032]  0000000000000001 ffffffff81128fe3 ffff88003e80f5e8 ffff88003eb31748
> [   52.810032] Call Trace:
> [   52.810032]  [<ffffffff812e1b0e>] ? acpi_os_release_object+0x7/0xc
> [   52.810032]  [<ffffffff81128fe3>] ? kmem_cache_free+0x63/0x260
> [   52.810032]  [<ffffffff812e1b0e>] ? acpi_os_release_object+0x7/0xc
> [   52.810032]  [<ffffffff812fe298>] ? acpi_ps_delete_parse_tree+0x34/0x58
> [   52.810032]  [<ffffffff812fe517>] ? acpi_ps_execute_method+0x1c9/0x266
> [   52.810032]  [<ffffffff812f91f7>] ? acpi_ns_evaluate+0xd3/0x19a
> [   52.810032]  [<ffffffff812fb93e>] ? acpi_evaluate_object+0xf3/0x1f4
> [   52.810032]  [<ffffffff812e1104>] ? acpi_os_wait_events_complete+0x1b/0x1b
> [   52.810032]  [<ffffffff812e4782>] ? acpi_bus_hot_remove_device+0xeb/0x123
> [   52.810032]  [<ffffffff812e1121>] ? acpi_os_execute_deferred+0x1d/0x29
> [   52.810032]  [<ffffffff81058ec5>] ? process_one_work+0x125/0x560
> [   52.810032]  [<ffffffff81059e7a>] ? worker_thread+0x16a/0x4e0
> [   52.810032]  [<ffffffff81059d10>] ? manage_workers+0x310/0x310
> [   52.810032]  [<ffffffff8105e6c5>] ? kthread+0x85/0x90
> [   52.810032]  [<ffffffff814eb2c4>] ? kernel_thread_helper+0x4/0x10
> [   52.810032]  [<ffffffff8105e640>] ? flush_kthread_worker+0xa0/0xa0
> [   52.810032]  [<ffffffff814eb2c0>] ? gs_change+0x13/0x13
> [   52.810032] Code: 89 ea 49 89 38 8b 73 14 8b 7b 0c e8 18 f6 ff ff 49 b8 5b e3 74 9d 02 11 f9 09 4c 89 00 44 8b 7b 14 44 89 f8 e9 fa fe ff ff 0f 0b <0f> 0b 48 8b 40 30 e9 d9 fe ff ff e8 c6 43 3b 00 0f 0b 48 8b 40 
> [   52.810032] RIP  [<ffffffff81128733>] cache_free_debugcheck+0x1d3/0x260
> [   52.810032]  RSP <ffff88003eaf3bc0>
> [   52.810032] ---[ end trace c699c8cecd5870a3 ]---
> 
> 
> And other times, I see a filesystem related slab corruption when doing the eject.
> Here I have also seen a bad rss-counter state message. 
> 
> [  232.114232] BUG: Bad rss-counter state mm:ffff88007d9c1f80 idx:0 val:1
> [  232.115214] BUG: unable to handle kernel NULL pointer dereference at           (null)
> [  232.115807] IP: [<ffffffffa00cfce3>] do_get_write_access+0x43/0x480 [jbd]
> [  232.116186] PGD 7cdec067 PUD 7c946067 PMD 0 
> [  232.116627] Oops: 0000 [#3] SMP 
> [  232.116990] Modules linked in: netconsole acpiphp pci_hotplug acpi_memhotplug loop kvm_amd kvm microcode tpm_tis tpm tpm_bios evdev psmouse serio_raw i2c_piix4 i2c_core parport_pc parport processor thermal_sys button ext3 jbd mbcache virtio_net sg sr_mod cdrom virtio_blk ata_generic virtio_pci virtio_ring virtio ata_piix libata scsi_mod
> [  232.120013] CPU 2 
> [  232.120013] Pid: 880, comm: dhclient Tainted: G      D      3.6.0-rc7-guest #1 Bochs Bochs
> [  232.120013] RIP: 0010:[<ffffffffa00cfce3>]  [<ffffffffa00cfce3>] do_get_write_access+0x43/0x480 [jbd]
> [  232.120013] RSP: 0018:ffff88007cd6fab8  EFLAGS: 00010246
> [  232.120013] RAX: ffff88003e513f50 RBX: ffff88003e513f50 RCX: 0000000000000000
> [  232.120013] RDX: 0000000000000000 RSI: ffff88003e513f50 RDI: ffff880097800000
> [  232.120013] RBP: ffff88003e513f50 R08: 000000003e513f01 R09: 0000000180240024
> [  232.120013] R10: ffff88003e513f50 R11: 00000000000198e0 R12: 0000000000000000
> [  232.120013] R13: ffffffffa00eb437 R14: ffff880097800000 R15: 000000000000027a
> [  232.120013] FS:  00007f082638d700(0000) GS:ffff88003ec80000(0000) knlGS:0000000000000000
> [  232.120013] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  232.120013] CR2: 0000000000000000 CR3: 000000007c94c000 CR4: 00000000000006e0
> [  232.120013] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  232.120013] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  232.120013] Process dhclient (pid: 880, threadinfo ffff88007cd6e000, task ffff88007ca46800)
> [  232.120013] Stack:
> [  232.120013]  ffff88007dc205b0 ffffffff8116645f ffff88007dc205b0 ffff88007dc205b0
> [  232.120013]  ffff88007cf58800 0000000000000000 000000000000000e 0000000000000000
> [  232.120013]  000000000000027a ffffffff8112b934 0000005000000003 0000000000000fff
> [  232.120013] Call Trace:
> [  232.120013]  [<ffffffff8116645f>] ? __find_get_block+0x7f/0x200
> [  232.120013]  [<ffffffff8112b934>] ? kmem_cache_alloc+0xe4/0x140
> [  232.120013]  [<ffffffffa00eb437>] ? ext3_dirty_inode+0x57/0xb0 [ext3]
> [  232.120013]  [<ffffffffa00d0279>] ? journal_get_write_access+0x29/0x50 [jbd]
> [  232.120013]  [<ffffffffa00eaeef>] ? __ext3_get_inode_loc+0xcf/0x360 [ext3]
> [  232.120013]  [<ffffffffa0101317>] ? __ext3_journal_get_write_access+0x27/0x60 [ext3]
> [  232.120013]  [<ffffffffa00eb213>] ? ext3_reserve_inode_write+0x73/0xa0 [ext3]
> [  232.120013]  [<ffffffffa00eb27b>] ? ext3_mark_inode_dirty+0x3b/0xa0 [ext3]
> [  232.120013]  [<ffffffffa00eb437>] ? ext3_dirty_inode+0x57/0xb0 [ext3]
> [  232.120013]  [<ffffffff8115ded6>] ? __mark_inode_dirty+0x36/0x230
> [  232.120013]  [<ffffffff811504a1>] ? update_time+0x71/0xb0
> [  232.120013]  [<ffffffff811536c9>] ? mnt_clone_write+0x9/0x20
> [  232.120013]  [<ffffffff81150581>] ? file_update_time+0xa1/0xf0
> [  232.120013]  [<ffffffff8103385c>] ? ptep_set_access_flags+0x6c/0x70
> [  232.120013]  [<ffffffff810e3f30>] ? __generic_file_aio_write+0x1a0/0x3c0
> [  232.120013]  [<ffffffff811396fb>] ? __sb_start_write+0x6b/0x130
> [  232.120013]  [<ffffffff810e41ce>] ? generic_file_aio_write+0x7e/0x100
> [  232.120013]  [<ffffffff81137484>] ? do_sync_write+0x94/0xd0
> [  232.120013]  [<ffffffff81137caa>] ? vfs_write+0xaa/0x160
> [  232.120013]  [<ffffffff81137f87>] ? sys_write+0x47/0x90
> [  232.120013]  [<ffffffff814e5765>] ? async_page_fault+0x25/0x30
> [  232.120013]  [<ffffffff814eca79>] ? system_call_fastpath+0x16/0x1b
> [  232.120013] Code: 54 24 2c f6 47 14 04 74 1f 41 bc e2 ff ff ff 48 81 c4 98 00 00 00 44 89 e0 5b 5d 41 5c 41 5d 41 5e 41 5f c3 0f 1f 40 00 4c 8b 27 <4d> 8b 3c 24 41 f6 07 02 75 d4 65 48 8b 04 25 80 b9 00 00 48 89 
> 
> Is this a known issue? If yes, can you point me to any relevant patches?
> 
> When I do an SCI(hardware) eject, I have not seen corruptions. The acpi driver is
> evaluating fewer objects in this path I think, but I don't see why corruption can't
> happen here as well.
> 
> I have seen similar problems with CONFIG_SLUB (I did not have debug_options
> there but I can also provide those if helpful)

Thanks for testing it.
It is not a know issue. I will start to investigate it.

Wen Congyang

> 
> [1] https://lkml.org/lkml/2012/9/6/635
> [2] https://lkml.org/lkml/2012/9/11/542
> [3] https://lkml.org/lkml/2012/9/20/37
> [4] http://permalink.gmane.org/gmane.comp.emulators.kvm.devel/98691
> 
> thanks,
> 
> - Vasilis
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
