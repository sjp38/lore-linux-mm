Date: Thu, 14 Aug 2008 16:18:52 +0200
From: Jean Delvare <khali@linux-fr.org>
Subject: kernel BUG at arch/x86/mm/pat.c:233 in 2.6.27-rc3-git2
Message-ID: <20080814161852.2dce7c21@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org
Cc: Andi Kleen <ak@linux.intel.com>, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

Hi all,

I have hit this bug with kernel 2.6.27-rc3 and 2.6.27-rc3-git2 on one
of my test machines:

Aug 14 15:58:23 test kernel: ------------[ cut here ]------------
Aug 14 15:58:23 test kernel: kernel BUG at arch/x86/mm/pat.c:233!
Aug 14 15:58:23 test kernel: invalid opcode: 0000 [#1]
Aug 14 15:58:23 test kernel: Modules linked in: processor(+) ehci_hcd(+) i2c_i801 usbcore rng_core parport_pc parport
Aug 14 15:58:23 test kernel:
Aug 14 15:58:23 test kernel: Pid: 1627, comm: modprobe Not tainted (2.6.27-rc3-git2 #8)
Aug 14 15:58:23 test kernel: EIP: 0060:[<c0111262>] EFLAGS: 00010286 CPU: 0
Aug 14 15:58:23 test kernel: EIP is at reserve_memtype+0x392/0x3a0
Aug 14 15:58:23 test kernel: EAX: ffff0000 EBX: 00010000 ECX: 00000000 EDX: 00000000
Aug 14 15:58:23 test kernel: ESI: ffff0000 EDI: 00000000 EBP: 00000010 ESP: c5836cb0
Aug 14 15:58:23 test kernel:  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Aug 14 15:58:23 test kernel: Process modprobe (pid: 1627, ti=c5836000 task=c68537e0 task.ti=c5836000)
Aug 14 15:58:23 test kernel: Stack: 00000001 c01ffb1c c6818338 c01ffb7f c5836d1c 00000003 c681889c c5836d1c
Aug 14 15:58:23 test kernel:        00000000 00000009 00010000 ffff0000 00000000 00000010 c010f96d 00000000
Aug 14 15:58:23 test kernel:        00000000 00000010 c5836d10 00000000 00000003 c5836d1c 00000003 00000000
Aug 14 15:58:23 test kernel: Call Trace:
Aug 14 15:58:23 test kernel:  [<c01ffb1c>] acpi_ns_search_one_scope+0x14/0x37
Aug 14 15:58:23 test kernel:  [<c01ffb7f>] acpi_ns_search_parent_tree+0x40/0x5e
Aug 14 15:58:23 test kernel:  [<c010f96d>] __ioremap_caller+0xed/0x2a0
Aug 14 15:58:23 test kernel:  [<c010fb34>] ioremap_nocache+0x14/0x20
Aug 14 15:58:23 test kernel:  [<c0204b34>] acpi_tb_verify_table+0x20/0x4a
Aug 14 15:58:23 test kernel:  [<c0204b34>] acpi_tb_verify_table+0x20/0x4a
Aug 14 15:58:23 test kernel:  [<c0204b73>] acpi_tb_add_table+0x15/0xdc
Aug 14 15:58:23 test kernel:  [<c01f9039>] acpi_ex_load_op+0xe8/0x15a
Aug 14 15:58:23 test kernel:  [<c01faf82>] acpi_ex_opcode_1A_1T_0R+0x22/0x41
Aug 14 15:58:23 test kernel:  [<c01f3fc7>] acpi_ds_exec_end_op+0xc4/0x339
Aug 14 15:58:23 test kernel:  [<c0202cdc>] acpi_ps_parse_loop+0x27b/0x2b3
Aug 14 15:58:23 test kernel:  [<c02021cf>] acpi_ps_parse_aml+0x66/0x243
Aug 14 15:58:23 test kernel:  [<c0203252>] acpi_ps_execute_method+0x9e/0xd1
Aug 14 15:58:23 test kernel:  [<c0200528>] acpi_ns_evaluate+0x124/0x174
Aug 14 15:58:23 test kernel:  [<c01ffe02>] acpi_evaluate_object+0x13a/0x1dd
Aug 14 15:58:23 test kernel:  [<c790a162>] acpi_processor_set_pdc+0x33/0x36 [processor]
Aug 14 15:58:23 test kernel:  [<c790d23c>] acpi_processor_start+0xbc/0x1ac [processor]
Aug 14 15:58:23 test kernel:  [<c02095ad>] acpi_start_single_object+0x21/0x3d
Aug 14 15:58:23 test kernel:  [<c0209209>] acpi_device_probe+0x34/0x41
Aug 14 15:58:23 test kernel:  [<c023d5f9>] really_probe+0x99/0x130
Aug 14 15:58:23 test kernel:  [<c02090c1>] acpi_match_device_ids+0x1f/0x65
Aug 14 15:58:23 test kernel:  [<c023d6df>] driver_probe_device+0x3f/0x60
Aug 14 15:58:23 test kernel:  [<c023d849>] __driver_attach+0x89/0xc0
Aug 14 15:58:23 test kernel:  [<c023c63a>] bus_for_each_dev+0x3a/0x60
Aug 14 15:58:23 test kernel:  [<c023d896>] driver_attach+0x16/0x20
Aug 14 15:58:23 test kernel:  [<c023d7c0>] __driver_attach+0x0/0xc0
Aug 14 15:58:23 test kernel:  [<c023ce49>] bus_add_driver+0x109/0x1a0
Aug 14 15:58:23 test kernel:  [<c0209274>] acpi_device_shutdown+0x0/0x1c
Aug 14 15:58:23 test kernel:  [<c786a000>] acpi_processor_init+0x0/0x7b [processor]
Aug 14 15:58:23 test kernel:  [<c023dcff>] driver_register+0x3f/0xd0
Aug 14 15:58:23 test kernel:  [<c025ebbc>] dmi_check_system+0x4c/0x70
Aug 14 15:58:23 test kernel:  [<c786a04b>] acpi_processor_init+0x4b/0x7b [processor]
Aug 14 15:58:23 test kernel:  [<c0101033>] _stext+0x33/0x190
Aug 14 15:58:23 test kernel:  [<c01368f6>] sys_init_module+0xe6/0x1a0
Aug 14 15:58:23 test kernel:  [<c015b901>] sys_read+0x41/0x70
Aug 14 15:58:23 test kernel:  [<c0102fb6>] syscall_call+0x7/0xb
Aug 14 15:58:23 test kernel:  =======================
Aug 14 15:58:23 test kernel: Code: 8b 53 04 c7 04 24 ff bb 30 c0 89 44 24 04 89 54 24 08 e8 e2 72 00 00 8d 4b 14 e9 e6 fd ff ff 77 0a 3b 44 24 3c 0f 82 83 fc ff ff <0f> 0b eb fe 8d 76 00 8d bc 27 00 00 00 00 83 ec 30 89 5c 24 20
Aug 14 15:58:23 test kernel: EIP: [<c0111262>] reserve_memtype+0x392/0x3a0 SS:ESP 0068:c5836cb0
Aug 14 15:58:23 test kernel: ---[ end trace e2df639a3eac4cc1 ]---

The boot then completes, but network doesn't work. Kernel 2.6.26.1
works fine on that machine, and I seem to recall that 2.6.27-rc2 did as
well (but I'm not 100% sure.)

The board is an Intel D865GSA. I can provide additional information on
request. I can also create an entry in bugzilla if needed.

Thanks,
-- 
Jean Delvare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
