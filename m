Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C877A6B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 03:48:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so35400817pfg.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 00:48:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id d10si7659021pag.94.2016.08.12.00.48.34
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 00:48:34 -0700 (PDT)
Date: Fri, 12 Aug 2016 15:48:08 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mm, kasan] 80a9201a59:  RIP: 0010:[<ffffffff9890f590>]
 [<ffffffff9890f590>] __kernel_text_address
Message-ID: <20160812074808.GA26590@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Content-Disposition: inline
In-Reply-To: <20160811133503.f0896f6781a41570f9eebb42@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, Neil Horman <nhorman@redhat.com>, Andy Lutomirski <luto@kernel.org>


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Aug 11, 2016 at 01:35:03PM -0700, Andrew Morton wrote:
>On Thu, 11 Aug 2016 12:52:27 +0800 kernel test robot <fengguang.wu@intel.com> wrote:
>
>> Greetings,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>>
>> commit 80a9201a5965f4715d5c09790862e0df84ce0614
>> Author:     Alexander Potapenko <glider@google.com>
>> AuthorDate: Thu Jul 28 15:49:07 2016 -0700
>> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
>> CommitDate: Thu Jul 28 16:07:41 2016 -0700
>>
>>     mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
>>
>>     For KASAN builds:
>>      - switch SLUB allocator to using stackdepot instead of storing the
>>        allocation/deallocation stacks in the objects;
>>      - change the freelist hook so that parts of the freelist can be put
>>        into the quarantine.
>>
>> ...
>>
>> [   64.298576] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper/0:1]
>> [   64.300827] irq event stamp: 5606950
>> [   64.301377] hardirqs last  enabled at (5606949): [<ffffffff98a4ef09>] T.2097+0x9a/0xbe
>> [   64.302586] hardirqs last disabled at (5606950): [<ffffffff997347a9>] apic_timer_interrupt+0x89/0xa0
>> [   64.303991] softirqs last  enabled at (5605564): [<ffffffff99735abe>] __do_softirq+0x23e/0x2bb
>> [   64.305308] softirqs last disabled at (5605557): [<ffffffff988ee34f>] irq_exit+0x73/0x108
>> [   64.306598] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.7.0-05999-g80a9201 #1
>> [   64.307678] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
>> [   64.326233] task: ffff88000ea19ec0 task.stack: ffff88000ea20000
>> [   64.327137] RIP: 0010:[<ffffffff9890f590>]  [<ffffffff9890f590>] __kernel_text_address+0xb/0xa1
>> [   64.328504] RSP: 0000:ffff88000ea27348  EFLAGS: 00000207
>> [   64.329320] RAX: 0000000000000001 RBX: ffff88000ea275c0 RCX: 0000000000000001
>> [   64.330426] RDX: ffff88000ea27ff8 RSI: 024080c099733d8f RDI: 024080c099733d8f
>> [   64.331496] RBP: ffff88000ea27348 R08: ffff88000ea27678 R09: 0000000000000000
>> [   64.332567] R10: 0000000000021298 R11: ffffffff990f235c R12: ffff88000ea276c8
>> [   64.333635] R13: ffffffff99805e20 R14: ffff88000ea19ec0 R15: 0000000000000000
>> [   64.334706] FS:  0000000000000000(0000) GS:ffff88000ee00000(0000) knlGS:0000000000000000
>> [   64.335916] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   64.336782] CR2: 0000000000000000 CR3: 000000000aa0a000 CR4: 00000000000406b0
>> [   64.337846] Stack:
>> [   64.338206]  ffff88000ea273a8 ffffffff9881f3dd 024080c099733d8f ffffffffffff8000
>> [   64.339410]  ffff88000ea27678 ffff88000ea276c8 000000020e81a4d8 ffff88000ea273f8
>> [   64.340602]  ffffffff99805e20 ffff88000ea19ec0 ffff88000ea27438 ffff88000ee07fc0
>> [   64.348993] Call Trace:
>> [   64.349380]  [<ffffffff9881f3dd>] print_context_stack+0x68/0x13e
>> [   64.350295]  [<ffffffff9881e4af>] dump_trace+0x3ab/0x3d6
>> [   64.351102]  [<ffffffff9882f6e4>] save_stack_trace+0x31/0x5c
>> [   64.351964]  [<ffffffff98a521db>] kasan_kmalloc+0x126/0x1f6
>> [   64.365727]  [<ffffffff9882f6e4>] ? save_stack_trace+0x31/0x5c
>> [   64.366675]  [<ffffffff98a521db>] ? kasan_kmalloc+0x126/0x1f6
>> [   64.367560]  [<ffffffff9904a8eb>] ? acpi_ut_create_generic_state+0x43/0x5c
>>
>
>At a guess I'd say that
>arch/x86/kernel/dumpstack.c:print_context_stack() failed to terminate,
>or took a super long time.  Is that a thing that is known to be possible?

Andrew, note that this kernel is compiled with gcc-4.4.

This commit caused the below problems, too, with gcc-4.4. However they
no longer show up in mainline HEAD, so not reported before.

Thanks,
Fengguang

+------------------------------------------------------------------+------------+------------+------------+
|                                                                  | c146a2b98e | 80a9201a59 | 8403fd82f1 |
+------------------------------------------------------------------+------------+------------+------------+
| boot_successes                                                   | 138        | 5          | 12         |
| boot_failures                                                    | 2          | 33         | 29         |
| BUG:kernel_test_oversize                                         | 2          | 0          | 16         |
| Mem-Info                                                         | 0          | 4          | 2          |
| Out_of_memory:Kill_process                                       | 0          | 4          |            |
| backtrace:SYSC_newfstatat                                        | 0          | 3          |            |
| backtrace:SyS_newfstatat                                         | 0          | 4          |            |
| BUG_anon_vma_chain(Not_tainted):Poison_overwritten               | 0          | 9          |            |
| INFO:#-#.First_byte#instead_of                                   | 0          | 24         | 6          |
| INFO:Allocated_in_anon_vma_fork_age=#cpu=#pid=                   | 0          | 5          |            |
| INFO:Freed_in_qlist_free_all_age=#cpu=#pid=                      | 0          | 22         | 5          |
| INFO:Slab#objects=#used=#fp=#flags=                              | 0          | 1          |            |
| INFO:Object#@offset=#fp=                                         | 0          | 22         | 6          |
| backtrace:SyS_open                                               | 0          | 2          | 3          |
| INFO:Allocated_in_anon_vma_clone_age=#cpu=#pid=                  | 0          | 5          |            |
| INFO:Slab#objects=#used=#fp=0x(null)flags=                       | 0          | 21         | 6          |
| BUG_anon_vma_chain(Tainted:G_B):Poison_overwritten               | 0          | 4          |            |
| INFO:Allocated_in_anon_vma_prepare_age=#cpu=#pid=                | 0          | 4          |            |
| BUG_vm_area_struct(Tainted:G_B):Poison_overwritten               | 0          | 8          |            |
| INFO:Allocated_in_copy_process_age=#cpu=#pid=                    | 0          | 11         |            |
| backtrace:SyS_read                                               | 0          | 2          |            |
| backtrace:SyS_clone                                              | 0          | 16         | 1          |
| Kernel_panic-not_syncing:Fatal_exception                         | 0          | 9          | 2          |
| Oops                                                             | 0          | 4          |            |
| RIP:vt_console_print                                             | 0          | 5          |            |
| BUG_vm_area_struct(Not_tainted):Poison_overwritten               | 0          | 10         | 1          |
| backtrace:do_execve                                              | 0          | 7          | 1          |
| backtrace:SyS_execve                                             | 0          | 9          | 1          |
| INFO:Object#@offset=#fp=0x(null)                                 | 0          | 7          | 1          |
| INFO:Allocated_in__split_vma_age=#cpu=#pid=                      | 0          | 2          |            |
| BUG_buffer_head(Not_tainted):Poison_overwritten                  | 0          | 1          |            |
| INFO:Allocated_in_alloc_buffer_head_age=#cpu=#pid=               | 0          | 2          |            |
| BUG_names_cache(Tainted:G_B):Poison_overwritten                  | 0          | 2          |            |
| INFO:Allocated_in_getname_flags_age=#cpu=#pid=                   | 0          | 3          | 1          |
| BUG_kmalloc-#(Tainted:G_B):Poison_overwritten                    | 0          | 3          | 1          |
| INFO:Allocated_in__alloc_skb_age=#cpu=#pid=                      | 0          | 3          |            |
| backtrace:SyS_mount                                              | 0          | 2          |            |
| backtrace:SYSC_newstat                                           | 0          | 1          |            |
| backtrace:SyS_newstat                                            | 0          | 2          |            |
| backtrace:__sys_sendmsg                                          | 0          | 2          | 1          |
| backtrace:SyS_sendmsg                                            | 0          | 2          | 1          |
| backtrace:mprotect_fixup                                         | 0          | 2          | 1          |
| backtrace:SyS_mprotect                                           | 0          | 2          | 1          |
| backtrace:_do_fork                                               | 0          | 8          | 1          |
| general_protection_fault:#[##]PREEMPT_KASAN                      | 0          | 5          | 2          |
| RIP:lock_anon_vma_root                                           | 0          | 4          | 1          |
| backtrace:SyS_exit_group                                         | 0          | 1          |            |
| BUG_skbuff_head_cache(Not_tainted):Poison_overwritten            | 0          | 1          |            |
| backtrace:SyS_connect                                            | 0          | 1          |            |
| INFO:Allocated_in_mmap_region_age=#cpu=#pid=                     | 0          | 2          | 1          |
| backtrace:vm_mmap_pgoff                                          | 0          | 2          |            |
| backtrace:SyS_mmap_pgoff                                         | 0          | 2          |            |
| backtrace:SyS_mmap                                               | 0          | 2          |            |
| INFO:Allocated_in_load_elf_phdrs_age=#cpu=#pid=                  | 0          | 1          |            |
| BUG_fs_cache(Tainted:G_B):Poison_overwritten                     | 0          | 1          |            |
| INFO:Allocated_in_copy_fs_struct_age=#cpu=#pid=                  | 0          | 1          |            |
| INFO:Allocated_in_seq_buf_alloc_age=#cpu=#pid=                   | 0          | 1          |            |
| RIP:__slab_free                                                  | 0          | 1          | 1          |
| backtrace:user_path_at_empty                                     | 0          | 1          |            |
| backtrace:SyS_readlinkat                                         | 0          | 1          |            |
| backtrace:SyS_readlink                                           | 0          | 1          |            |
| BUG_kmalloc-#(Not_tainted):Poison_overwritten                    | 0          | 2          | 3          |
| INFO:Allocated_in__install_special_mapping_age=#cpu=#pid=        | 0          | 1          |            |
| BUG:Bad_page_map_in_process                                      | 0          | 2          |            |
| BUG:unable_to_handle_kernel                                      | 0          | 2          |            |
| BUG:kernel_boot_crashed                                          | 0          | 1          |            |
| BUG_names_cache(Not_tainted):Poison_overwritten                  | 0          | 1          | 1          |
| BUG_buffer_head(Tainted:G_B):Poison_overwritten                  | 0          | 1          |            |
| backtrace:do_sys_open                                            | 0          | 1          | 3          |
| backtrace:alloc_debug_processing                                 | 0          | 1          |            |
| BUG:KASAN:use-after-free_in__probe_kernel_read_at_addr           | 0          | 1          |            |
| backtrace:cpuset_init_smp                                        | 0          | 1          |            |
| backtrace:kernel_init_freeable                                   | 0          | 1          |            |
| INFO:Allocated_in_load_elf_binary_age=#cpu=#pid=                 | 0          | 1          |            |
| IP-Config:Auto-configuration_of_network_failed                   | 0          | 0          | 4          |
| invoked_oom-killer:gfp_mask=0x                                   | 0          | 0          | 2          |
| Kernel_panic-not_syncing:Out_of_memory_and_no_killable_processes | 0          | 0          | 2          |
| BUG_dentry(Tainted:G_B):Poison_overwritten                       | 0          | 0          | 1          |
| INFO:Allocated_in__d_alloc_age=#cpu=#pid=                        | 0          | 0          | 1          |
| INFO:Allocated_in_kernfs_fop_open_age=#cpu=#pid=                 | 0          | 0          | 3          |
| backtrace:user_path_create                                       | 0          | 0          | 1          |
| backtrace:SyS_symlinkat                                          | 0          | 0          | 1          |
| backtrace:SyS_symlink                                            | 0          | 0          | 1          |
| BUG_task_struct(Not_tainted):Poison_overwritten                  | 0          | 0          | 1          |
| INFO:Allocated_in_kzalloc_age=#cpu=#pid=                         | 0          | 0          | 1          |
| backtrace:vfs_write                                              | 0          | 0          | 1          |
| backtrace:SyS_write                                              | 0          | 0          | 1          |
+------------------------------------------------------------------+------------+------------+------------+

[  105.829566] blk_update_request: I/O error, dev fd0, sector 0
[  105.829567] floppy: error -5 while reading block 0
[  105.944521] =============================================================================
[  105.944524] BUG vm_area_struct (Not tainted): Poison overwritten
[  105.944524] -----------------------------------------------------------------------------
[  105.944524] 
[  105.944525] Disabling lock debugging due to kernel taint
[  105.944527] INFO: 0xffff880009318ca5-0xffff880009318ca7. First byte 0x1 instead of 0x6b
[  105.944532] INFO: Allocated in copy_process+0xc65/0x1797 age=114 cpu=0 pid=518
[  105.944550] INFO: Freed in qlist_free_all+0x7a/0x100 age=29 cpu=0 pid=596
[  105.944582] INFO: Slab 0xffffea000024c600 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  105.944583] INFO: Object 0xffff880009318c98 @offset=3224 fp=0xffff8800093192e0
[  105.944583] 
[  105.944585] Redzone ffff880009318c90: bb bb bb bb bb bb bb bb                          ........
[  105.944586] Object ffff880009318c98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 80 dd  kkkkkkkkkkkkk...
[  105.944587] Object ffff880009318ca8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  105.944588] Object ffff880009318cb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

git bisect start 8403fd82f1c6320dfbe7cfa5f35362ddb3966e30 523d939ef98fd712632d93a5a2b588e477a7565e --
git bisect  bad faaab93209a0298c605bbfa0489867ae031da494  # 09:48      4-     11  Merge 'mips-sjhill/linux-4.7-stable' into devel-spot-201608040312
git bisect  bad c5f0c3e1c933cb4982ef6d58813b495c154fe07a  # 10:06      0-      1  Merge 'linux-review/Johannes-Thumshirn/mpt3sas-Don-t-spam-logs-if-logging-level-is-0/20160803-212128' into devel-spot-201608040312
git bisect  bad a26d7f6d37364e54715c6cff79b9f1b854713440  # 10:17      1-      9  Merge 'gfs2/master' into devel-spot-201608040312
git bisect  bad 4db40b95edbc23164ed76301bef5f67a77f87edc  # 11:01      1-      2  Merge 'linux-review/Bimmy-Pujari/i40e-i40evf-updates/20160804-025159' into devel-spot-201608040312
git bisect good e3ba205b84679c6d01e3c921b3b6665f31227a95  # 11:07     32+      4  Merge 'linux-review/Steve-Longerbeam/adv7180-subdev-fixes-v4/20160804-030449' into devel-spot-201608040312
git bisect  bad bc489156b44eb2b68d937d28b750149c507e0bac  # 11:16      0-      5  Merge 'kees/for-next/lkdtm' into devel-spot-201608040312
git bisect  bad 1056c9bd2702ea1bb79abf9bd1e78c578589d247  # 11:22      1-     13  Merge tag 'clk-for-linus-4.8' of git://git.kernel.org/pub/scm/linux/kernel/git/clk/linux
git bisect  bad c624c86615fb8aa61fa76ed8c935446d06c80e77  # 11:30      7-     13  Merge tag 'trace-v4.8' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-trace
git bisect  bad 1c88e19b0f6a8471ee50d5062721ba30b8fd4ba9  # 11:37      0-      1  Merge branch 'akpm' (patches from Andrew)
git bisect  bad c3486f5376696034d0fcbef8ba70c70cfcb26f51  # 11:40      1-     12  mm, compaction: simplify contended compaction handling
git bisect good 1e6b10857f91685c60c341703ece4ae9bb775cf3  # 11:45     33+      0  mm, workingset: make working set detection node-aware
git bisect good b4fd07a0864a06d7a8b20a624d851736330d6fd8  # 11:53     34+      1  mm/zsmalloc: use class->objs_per_zspage to get num of max objects
git bisect good 7c7fd82556c61113b6327c9696b347a82b215072  # 11:58     34+      0  mm: hwpoison: remove incorrect comments
git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 12:09     34+      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
git bisect  bad 23771235bb569c4999ff077d2c38eaee5763193a  # 12:13      2-     19  mm, page_alloc: don't retry initial attempt in slowpath
git bisect  bad 87cc271d5e4320d705cfdf59f68d4d037b3511b2  # 12:18      5-     10  lib/stackdepot.c: use __GFP_NOWARN for stack allocations
git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 12:24      0-      3  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# first bad commit: [80a9201a5965f4715d5c09790862e0df84ce0614] mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 12:29    101+      2  mm, kasan: account for object redzone in SLUB's nearest_obj()
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 12:37      4-     11  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# extra tests on HEAD of linux-devel/devel-spot-201608040312
git bisect  bad 8403fd82f1c6320dfbe7cfa5f35362ddb3966e30  # 12:37      0-     29  0day head guard for 'devel-spot-201608040312'
# extra tests on tree/branch linus/master
git bisect good 96b585267f552d4b6a28ea8bd75e5ed03deb6e71  # 12:46     99+      2  Revert "ACPI / hotplug / PCI: Runtime resume bridge before rescan"
# extra tests on tree/branch linus/master
git bisect good 96b585267f552d4b6a28ea8bd75e5ed03deb6e71  # 12:50    101+      5  Revert "ACPI / hotplug / PCI: Runtime resume bridge before rescan"
# extra tests on tree/branch linux-next/master
git bisect good 7a4be45ba2ccc2dc5a15d0b0c5bfba05ad672ff8  # 13:03    102+     77  Add linux-next specific files for 20160803


---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--4Ckj6UjgE2iN1+kY
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-vm-intel12-yocto-x86_64-9:20160804122713:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1.gz"
Content-Transfer-Encoding: base64

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
OJBjBDx8A0h+1ihdDgEA

--4Ckj6UjgE2iN1+kY
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-vm-kbuild-1G-5:20160804120921:x86_64-randconfig-s0-08040601:4.7.0-05998-gc146a2b:1.gz"
Content-Transfer-Encoding: base64

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
f1szYztm/vvnn5WHEq/v1D/dFYO9/58uvv/9l988vG/mw/YlG7a6/PXm6c9PnqlU9BP1yn//
7Kdn2kvrn1Vp8cFKSS19bmPlfVKcukXfPru+EZPfvBGH7OVqgBZ+PtYN1n999vLxKwkf/pX8
V9H+5+/lhD/+wx+0tcjN0+rC4NoEdMilvHc5x0evn7/98YVc7+/1Rr/fzdQY5pt/vL9Vt0mc
78fbELXC7+mTp49VyWL5D203IvP/bQ7iG90Puvppqem6+AfdnblzZH9z/65HFb545C8/5Gyy
ltbK8/v52VMJoj5ZIql//vL39/0b7s5E19L+27ObZxf/8koC1vfZNXy3Z3715ucX1y8KNbn6
E86qrvGzBMhvPrn40EjiuQRgr15/WDf5v1Yj/PsRD1Ig3+eg3ly//fSR5d9+GBPyopvV1YJJ
qxEMlOrnByOCAY5h44MRy3ZHb0R4OCAB+iofjiBvRADO6cNlZ7e40N2LsA9GEKIQ7R8O0B23
Zbn8yYdvd9mkuw+gdC1Hn+NftLOMM9HRxdXjZxf84b3M3iP3zvFqRLo7rr7G73+6Os76CPnu
949vhP9PtPbgXp1nNzqZZPPF29V4ez/+vsD9J/HA/3r16/tB3libf7ukYfysTc8e3Na7Fh43
n3/zhz88ONrvr37SjZa3Yu/DocQNvnu9g3zxX3wuh1v8mEX76pOLP1+6S/m06c39ovciXOXv
hLXufv/tzSvtf3Xxx+urD/O1hJy6NHT7k080ieS2LGgrgKONtlUT5Lb6/c3vLuhfVtusrMsb
GXiv3IMRpKlw/Ho58pe3aep6cP52WbFfqRro7zkZ4IP1H951NlknhRfPnty8UjW1TzTp1+j6
7aJon57Y3128/lH+u/znfacj/bcPBgJpWtEDA3+4/68Xf1p64t0R9lakzF78P2+f6aLFf716
9per//3s6uXlj2/k6sRDunz3y3/53cW3S2bTNzfvHl89PEZYJPcv7zuhfnKx/HO/VXnxG/Pb
1a/pwa///MV333/5zdefXBhrojEfdpK1QYBfkmLn/nloT7dyzrQXT7an6a2rf1dlq2U7X9/f
P3x7m0W8LHqp6EK8XP04P/zxfW+g/9u893lUBCPshry9K6TTJRpxcnTQZfmfhyNpaf1ycXeI
8t8XkfX361X/ty4Yli5a49O7I+j/+MmHNkmL9aXT7XpA3gwQD+LZosP+x19faxvc5o+/+uP3
F+//2f6Y9mdt9fBWd2tt6ad3di80Df4/Zdyt2o26Kh9aHubVQN4O/FYe6vtSdo1PVuekCZPr
39/f9/fiEeszux/w8CJc+dZrufba9tXNY9WUuS0DKP/4VorvwYUugP1k9dP37WouzIM/xEVR
VfttaO3NfRb87y6uVc3xd0uD9t9d/Pk3xvxW8+W/+43+5/fL/3//Svzu4ve3f/7DiinR6LLj
Ytj+7n0brZ1hb8cNK+EXw65l+MAZa6ewxbA/+VYsvVLUcDjZsMZpi+F4smFNT1wMp9Y9TuOG
Nel3MZxbhvO4Yb5/j+ncW2G1nGQxzA/PeFnteXDGPG74/QdydfIZu/v3+PHJhv39e/yk9fA+
Hzcc79/jpyefsa5ALIavTzb8/gP58WTDdPce25N5bPnuPbb2XMOLTNNi2J1s2N6B3p7MY3f/
gdiTeezuPxB7Mo/d/Qdi08mG0917bPPfwLC6Jdpk89nL+yz9N5+sfhOW39x24PvErf6Ulj/d
NtD7xK7+RMufbnvUfeJXf+LlT7ct5j4JD/+kyYLyp9sOcZ/E1Z9uT/W24+InafWn2zO8bZn4
SV79KS5/uu15+Amt/nR78rdNCz/h1Z9uT/6u6+An1qz+eHv69v6qV5dNtxdw1/fvE7u6XXR7
CXeN+z6xq7tCtxdx13nvE7u6L3R7GXet8z6xqzvzIBBo/nPx9NXL6wfRRlzWWT7787+9XxGX
+OenJy9+uH755OOn19qn9aernx6ktL0f8sX3F5//8bv71E1acn5fPPvfV3f++4MiTdL6/6X3
68P0nas3v2gK6psPS/GrX2vxyN1q/23Z7vXTR/J2/tulOBAXT65v3j77Ud7q94sQpKX3Tsn5
D29vfnxzt6L/u4snN0+8e/Lp7X880tVc+RBUbeDm7aevXv5uWd/9STXqHi3Vd9c3n943dr6z
KPf1H/74naoDv7l+/uOtwsBdTc1t2rWqAC8aAx/+fWUgDxogy25lgAYNLM2LpywsXaJXFnjQ
wtJZ/oMFYt3leq9OJ+/Wza+vdR14u6VAl94TKW3uNTjfvdQswXsdvvdSnEvf+N/cV0uraq52
A7kT4rz9n0JUcc7fvjccPC9NGvBdvh8+CKzfjS+mCezHv1uWh7T47Qd5b998eLX9UrAF7aDf
/njZAD+2g35roLFfrzv/F998/dWXX3/x6eoMc/GgzR3N3a3KA7uid7dL/nh7u9xDQ1TMISim
ZtwNKG6oDqVm3Bri4tvy4RL09mn1zp++//T3z97IjdCy3J8+WFDN4L6Fz//5s+/+6Ysf/vjv
337xqba1X40v7kqvx//zF5999cd//vSfXr16+nCobSeoLEO//e6L77/4+o8PH35YgvbewD9+
8fk/f/3NV9/8079/+tWzR88+IFMNeMDA3UX/45+++uqH33/x/Zf/9PWn79tm3VpZauNxK9vh
sf0SPBz+9Tf/+mlcDU6dd3cZ/Nm3n33+5R//fTM0A+/M/dAfvvriz1989enXmvb5fGUEeOza
o/WHP37zwxd/+FYsffbnf/rUp/UtIOANuLeyPAi9EVsj3E6MWoz84Zvff/HV7ae0aA7tPqWw
hOZdM599/ad//OzzP/7puy+++3TZvHhowbYxcPsxfvHdl5/JmfzpD/8gJsJlvjSPTGSmRz89
sSFduccPLfbyNm5f9D98+6lLD4d54An/+Zuv/vjZ3avl/eqOLjWKeL7HhqvBlr+L3fDGDBRs
LD7Ubcbe3W+LXzOQsXc7PNWvtjT7CH6W8sB/XZSYdHdH10nvVtjvfAAtsXz06qXYerqITUgg
7t0vHywE8tzzH3IID3S8jX0cklnpeBu7yJF/cB/0fVHNwo5fkoN5aNiZ8HRj2LkHhr259FnF
lv+H9vn9+MWLTy4+X/zQpxf/+vf/9iEWu1PI+p3KBOgfbisRH5ScqSESt1lLnJZ0gFt5ve/+
+Pn7PrrXms1wocmEzzULWNxgfSC3hXjPtT71x4tA5uKFfHlvb8Wv7vWz5dcfjsK0aDTeXL18
+kpO9+5oWu76UKD43e3fl4d18Zv7uszlX3/70R9UR3Hx7H+6efXutR7qY7Hz8Y9vPr79Xz5+
8vqdNqBR3UN1GO9+t6Tt3tUWXtz+5BIz1rOEmHn8/Jdnr5qGll8gpu4FZFrG7n6DmPtR3sn/
fbt1VTV39xvE3Ovrmx9/uBVZaln88DPsklX2u33B8ovLj+5eqAsnge7NnZ6w1szevosabl5e
/Obvv/3sDxd//9mffv/lHy/+/vsvBCJ/+reLv//yD5/Jv/3793/+8mv937/68h8+/+7fv/3j
91/88U/fXvz9Py3/IqM+/+ri7//t/3Px6PsvPv/8mz98e/Hos2+//ey7P3zz3W8/+v1dWunF
X25rCu/j2b/75S8v/u7yw59VQvmZ/velEOi2Rbf8/aOP/v2DhpR+X0tSrZDq+dWTX+T9ePfs
+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
/8970dPfL6MXncjvb6/s8vKjzx7LHLRsZ4k7+e7t9ScXOg9/fDtRPnp5K3f645uL/Wk8env/
x4/+UYI0lbr7MHJZ1TMflU+uvAmnT/T9Dfj9/YbS16/efvHitdzP/3eZNO/WkJ8+9A/K68uX
bWOqD3easXdvbj5eosMld+Jcs2caPGwM9gNrlh46aOXfDHplzU0F3BVbOaC3i/ebK9qu6pe+
rG+/+f7Lf7v4g0TRVz9dX/z3xcrgd3Z3bNVcvj8P+cBu/1vt+7IfbU8O+LIeXvyACO5fFkXb
B+9MdV1//bCrPxt83r1thHEw/+Gb3//pqy8q7299E+jB839/nZ8vqQf673J6wtnl+r7Ws9SQ
Vp9p4xXYHvLikYZpPz77z091oPzbbWLD6iXYjVneB/dR//R3b8hy+z7cqH9ZaP35qxcvJF7/
SiL1T//fm6eXD7dCSuAobZVcNo1OWqzND6thZxnWuWJjuPzWHLC9njr+Jqd/P438TYyfYnj0
6yyb23+Xuv50cfvyCaxvUVb+EPc5j+ujvP/6ej+8/RLDR61T7X2Dg777drOwdCcW4bnPXz1/
+vq5uG5Xz5/fUap2PxQyOkYT4O/MC4lUFP/TN+8e3x5dSXW7cPfp1dOnKz7dD11uBn3UOlvk
ZhRc4RcvPn6/JfjwjSvsFa4npMIPBqei+nZkK9x4uKTdDzoKC+Bl4/tH/d9uI6GL7+/eBvyF
v4+hmi/7/Y+WZ5tNIWyrPNe7LgmVqA2YzHsB4vvA8OHR9vfnu9tUo1t9a12UvgPEA4dt+Sr2
bt4//un7L+QjWoLxrX+3//XnqzTI2s/fn9ZnS9+Zu3P589XNM21N+Kb82+Vrvvvpnbfxh7uM
vbse7cFe5kQxPChWuL9t/yFPTeW9r5d7LtY4RnPfylz9lZ+v3vx82/H7g6182164YuvPV0/e
vXuhH8iDw5NJDyt0a0MW+e3fLY0/nl6Y2wYsH2z4ZF3Vxj9qxoyaWLzmX168WR2fPT/UkNyM
FWdEvCztVrP057l49fh/ytx2wW7pv3nfXkrskPEm1i+9ZsfHWzvhvZ0YXLlV26aj0fLbZMv9
9/odjZbh5LnY063c0UiHJJNNtQnS5uySi7762/7ZkeFQvRHlsyPvOr25NqdIqlw622BvMZQT
Iz29yg32FgvMSIO8YoM9Hc/OImewbbAnQ9nkWO4l2WqwtwzkhHQyKzfYUwPWUvkNhBvsLVbC
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
d4WRKTOSy99mZDZYo6oOI1V4b0KrVy1EPndfO2aZhsf9yKgd2w43z9bxt1n5pzJSa9mHGMmW
O4oEICM5QB3IG4zkPCLvsGckY65AgZHJOKjj2Y6RyWhrmAlGJpMhrYA2I5M16XC/Kx3uLbKp
W2RkkvjhYC2iIDJ21AX6jExOQv3pPRuV2plsnq1GEtQUqsNI3VNAYos6I5PX7PwzGZl8hPLa
N4yU22GRJYwaI5P6Te5cRqo2Q8dNXzNSJuGeIgDGyKQxF7JMXGVkippedpyRSbwppEFLiZER
I9WekUJXqCtplZHJYR312oxUQf7jdTYpUa+DeoOR2aSRxg2roR4SXGwzMkfIE+8wMstjmPUj
5TZa5GH2GEmeIVn0OiMpQb79ACPZQC1ht4wUdxZZ6a4ykqM7V89cbXZXltaMzDLfdD5yjJHZ
hEVR4v5q3snpy6VI6PHJxfNnL3/5QYX2nv30ycWTV++eP714+eqt/LeXL6+fvL14++ri+u3P
b1+9ev7JxWdPn97IlV38ePXimZyJ/kxP6tXN2+unF49/1Tv69tWTV88fHJYeNs64O6xEjn/j
w8Zlk2R7WP83P+ySqL89rPubH3ZJjtse1v7ND5ut3x/W/M0Py25/WOK/9WHFnd/fZIp/88P6
h5Us94elv/lhYyrc5Pw3Piz5jKyG1D05GV5pM4l5cpmI4zFPLkvEj2z57Dy5zD5jSQkVTy4z
tvXW9uQys0HWtCueHBkLFdQVPTkymJhHwZMjg2X0NT05MuyQXZu2J0davT2nTqZGAtYuoe3J
kc0BWT+oe3JkGVJZxz05cj5jbcxXnhy5ZJAQqebJkeAynuzJUXS2vLBx9WTrxFEMleRE/W3F
f7t68mF4SuXVah2+XPm6760OYeNP1mOTKDWUczILVyxBYXlPCbviRKa8Fl2/YvE0/an9jdVm
qCzOFK44S+BTfUj9K84c6ocqXzHd9iI59YpJnJzqVWyuWFsBF79K7IrZ5PJEW79iVcg9edVK
F/bLwXfhiplD/ZS7V6xhbHmCrF6xChvzyfu9bIjK88v+itkaKk+L2BVbX9Gpql+xjeRO3r1h
VfV7QMMnP928evf6zSP55cu34tRqnPS9/Nf74Rdvf319/embZz/JgS/eXL98en3z6cuPry6e
ypk/e3n1Vjyv5d9fPf6f4vB++vGrm58+/vHm+lr+/svbV68/vjuO/Xg5wMWzlzJH/Xj15PpT
+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
Yb2t+h3mvKuyE8YKDWzeMVJzgTqEhozUhi2nGDNSQ8DklJFqUP//jJGGFSsHjIwz89EKSzNL
2GjDGyPJk36kx7nHSErttXn6SUaSA29ylfHOSH+16iTdwRhJkeUfTA6GB0nQy9ZhJGWD2lxv
GEmlZCQIvjCSSkgCHzCSYivB2szfDSNjV+liv8+7eVGkn+KWkeRpKhSEXhlJVRTR7xgykpof
jccVFvJgAVq5O2IkNYbG6yaMpNCVO8q1Q332ye0x4ZEE2vX4wUhSSCu5y0gODaWHGck0WyPy
wUgWm3RxgYyUBN3ODhgplReimSsjhaFdsXeM9FgIec+ujNToYDthpPqreahAEV5YD2o20ci3
XbMhK5Be9h0jY6boNNcmk3qqaFtD1DcjLSVDRnomRUjj/YSRnPzwOJgcrC+VX2TWCmck+78i
NyofjAxFWiS36zGS/7Hp5UlGcq00+XjfGRlCtBOwYIzk6pg52NRaQ5F2ZYfJhZEhlYzcD98w
khsL0m1yYSR7XoT8zC4jOaLf4ziSY43yPiP9YK0Lqfo7Iz12NwiwV0Yyl3Zc1/ZX91iBIrwo
NvUxZKQkfWAqhqViC1/7jBSG9hgsMFITJML1yUgt0P1Zl5FKXB6eimGLMcgVRsbdxxNxpIeA
Dfpa+ow0Lcg1TI+Rkakj9ZMbRkqqdWPDVhjGPoYDRkqudUHqvMNIyR5C799HSlZDcsRbRkrJ
2F3olZFSGlRaGDJSCivSzjBmpBSDGjqHjJQa/Xz/8Ub/3V9hf51V/HX+y48//dv//OHnn/70
45//5csPP//9L3/88tPPv/o//fTTtx9+/fLrz1++/fr//Przz3/5ly//9Y9//MXf7i9/+sO/
/+i/Rfxn8Qv9/Muv3/745V//d/wiv/78w89/+e7HcrLrj9X//B/bbn4s/ef/2Fjo/Plj7T/9
x0q5/lhL//k/9nu5y3/+2Pyf/mP1e3Wkf/7Y8p//Y1u6/tj6n/9j5ea7bf/pP9by9btV/s//
sfrdRqYf/vzLz3//69/+i0cTP/36P2qOJ/q/+z/+M8T48uv//uu33//txz97cPLlb99++uO3
X37/0+/+8OWPTscff/rDr36avf7953/9X/6r/f53P//y59/96Zdv3/z//99+/fmvv/vHz8m/
e/2ALz/+5Dj90x9++PZ7/w+/fvcffv3nf/j1v/75tx//7//qP+q/ffvLtz/8zf+UH37++d9+
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
TWn2Gcn+ZBzcJiq3trVUkF8SiFvdjcrKyFxEn5Gx6uq4Kh1aiAt7vS+MFNrvblTx/+3FkRG9
HmfKIXiIqLtMGOkvwuFy6nASQrfnjLQEPY0DRlqBPtgFRhoXbOvROyPNz1/gT+kx0lKS9uii
g/Dp2MUlHMOA6ZGRaQvlmwN5Mg45xLqwg/TCSMuVN2UlLBNUOLkwMrbNYvsoO4y0kvJCmtth
ZOz+OLhNtNKg8+2WkZ4YppXNgG+mtrRH5paR5vk6tFp+yEh7je8dMtIqpqQ5YaRVhXQP+4y0
luzJpYLh0fOl9Q5wi/3jB9PWHru+iuGPMpKKTCKCD0ZSm+mZgYwkgdaiDBhJRpA+QY+RoYi5
17kTFYetSUKPATNSdeszkkOI/piRkmZf+5CRUhNScLpnpFBBmgHuGCme45+tSwgnJtAc8JiR
WjLSGjtmpLb2QOeORW5yJL3j4XlGUtwFRlohZOjzk5HWCBlp7DIydF0f7QD3PzFN16p8z8gw
YJ60FCKMDEcGbWXrMdI9hP7K9koZt6+JkYuxCyPDtAiyguODkWEYB902I8OB5FMp8PBi++sS
3DxWc+/VbOQlqQrtgvxkZJhyPpRwDCcKDemPGOleKOnKiusbRoaTCg01DhkZbojpoCodHgQa
n0cZ6f93zmW5ZhNmte4rUoS950ePdu6ET9NJNPfBSJk2/4KMFA/GD+4jwwMzIgLZZaQotCj6
jpGhNbseR4ZhzdCQbpeRStCuzgkjoyq7O0koIRAMLf64Z2ToVu8oUoRpgxQcxoz0UBy5D50w
0gMlpLNhyMicMiNZxYSROTVIp6/PSH+a65PKZuHRc611RuacGUn6e4zMuWV7mJGxAWlS231n
ZC5ppqKEMTLUhydLESeMzIVWxuEujMwhf7wXR+aYUV/vbpSQKmZI7KXHyBz3YIe5dnjhsnir
+W6uUOvTLSNz8+Nxp2YTpkVXNnbdMjI3euke/fM1+uHPv/z897/+7b/4y/HTr/8jLtH+5ct/
93/85xvz5df//ddvv//bj3/2d+3L37799Mdvv/z+p9/94csf/ef++NMffvUv5/XvP//r//r2
w6+//93Pv/z5d3/65ds3////t19//uvv/vFz8u9eP+DLjz/5L/qnP/zw7ff+H3797j/8+s//
8Ot//fNvP/7f/9V/1H/79pdvf/jbtz9++eHnn//tx2+/z19++eZ/9v/8x7+mL/6S//z6jb77
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
iHrTkZElYXKBVUYWckinR4eRpF/iGGlvzTXTnBuRMWMbs5pjJDH2gmgykq1ausxIjpDMU5uR
nCMSvvUYyQQFXw1GMrbYaICRouQabf82swTVMauMNLGWS9u/44vgfE/A+JaRwXfXrmCMDKH7
kzuM1GggdLosm4wMgRLysJwwMhgiZxgZos8Lkj3mIJbBYvIJI0PMMjhoc2ve3alRZ6Rpjk+N
yJipfuerubZtZ4CywCYjTTR+sW3HnGDCaB1Ghuwj0lBfZ2TIEWrJxxkZcsH2Pd4yMthGq4Vc
OxTvrpXsMZ+p91XvGFlKuUDV1hzZtqMlRtq063TbjtlHKO89YyRZx+0MI4kS0nJeZyQHD+2o
ajOSU5pu2zFzvQlmazbBGiPnajZBTEZjlZG2fHO5ZqMvyby4HcGcsEO68DuMjM5DE7l1RsZt
k/SVjNQoGzpR2TEyOoZ2BNUYGb2P126QMZ/dM7lbRipVQifXwxgZTRh1QfpRPYQQBtagHBgZ
gwnrTjEyhkLIKfmBkTGwYClIhZHW2TioR3vCyGiH/POMVOuR4aRbRsbImDDbkZFRQ9CRNP2U
kZrd9tQFAEbacWTnXL7PyJgIEiHvMTIJFG40GJkDVAwbYGTOhMxW7BmZBSqFVRlZNMe5+Dxy
24SCt3+bAff2OoKMJCfIrdpgJEVIJbjKSMoFkbM4YyQRVF0+MtJaf+blKNQBB0y1ps1ITjy9
HcHM9cub27JlxljZ6oyR4jG0NxkpegMPVKQrjBQF7WquHYUJSUg7jLQ1HyuSPeZBL+vCjdbm
kRxyYr9jZHLiVhiZvM9X90cmn3Pnhr1lZPKUOjkGxkhNOQWpKtcZaYdTA03IB0YmE4CZY6RN
CyNjHgdGpqD3wMp5pBVLkCbbNiOTBXPzNZukTxQyJn/KyKSYhyabjoxMySVoZ1CLkSmF5REZ
85LjiKjFKSNTIqjq2GNkdmFljDBu2z6glXc4I3OGCqJ7RmaGZP2rjDRt1Uu3I5jP7vLVHSNL
t7sMZGQRBy2tqDOSfBpYpnJkJGlUN1ez0RxJkDT9yEiwMbHOSE1Uka6jDiNt4nu+P1JB5Qc6
CnaMZIojoLsxlYzowLQZaRswV7u/NbvlC6otCjeoQaBOt+wSVMPD6ZadphjjWXK2Ysn0kLTZ
p00q70q6Zc/ciaJu6ZaD4w6iO3T70399fvj4+fHt3Zend4/f3/ng/vS3//J339/98vjp/ePz
5mu79M9P//74p399fPf1/tsvfP9vXF6XdHf/+P7hh+fH+19+fXd3/+bj17u/f/j858fn5+/+
0+d3jx/tvx8+3t3/7u3lx19+evlst8PLb+b3nx7ev33z4f2PTz/df9YvWGHhivMvf3rz5j69
SC9//6qFH3/IbP/tfnz4weeHGEPI9JC8C49vHh7l5a/vzO2/35/dKHf3Dx8/Pr5/e/c3Tx9f
fa//+fXd/S8/fH16fnvv/+4+f//925/ffLz79OHDl1fbt/bp4Z27+/r58dOr518+3v3fDz+8
eql/eKk8f3z79fnx7ctb+5c/qOW9v3/7+MPTw/vfP5cXb37693v06u+D88V+93trbfXu/pOk
X768v3cvfnt493z3n//pv/z9q98/7l++fVivmh/f3Q/6929+frV90npdvz4+v9z++/7zR73U
v/w0F324e/Ph3bunL6/QS73723/8x39+/d/+hz4Rr/4/fZvvHv7t9dePdru+UsDd6RvrX/7h
n1//k17Xq5efHj9/ff6yfSMv/c339PLm67HPIN+7cO/Ivqmrr9/d/cN//5+vFWH/W9n19P79
nf7wrz/dPXx8evPq2x/1Ifr0r68fnv/88Nvn198eobd3n958/fj24cvjC/3Da32WXn/+8vD8
/Np+1Q9fv9gL7e7jw3v1ce+VIj9+ef7w5pevH19/+zt/9/7d0+s/P3x58/PbDz+92v7y7sOH
j59//+Pzh4e3r/XWfvv0+ZdXwdj27uOXv/6F+wvHXjx/+On1s90sr5RXd08/vf/w6fG1/uX2
d3ePD5+ef/v46en9l19effny2/9y31lHsl6YfmyfPzw/Vv/S3f3608Or99ub7e7Tn//m7u7+
6f3Tl09v717++Pnl57c/+Zff/vn+9um6u393p5+rgubzu4934c5u56c3j3eP+mm4794/ftF/
fqX/4+7uv/3D9uR+9/R2+8vvfla8/vjnt6++vPn4/ffBWpfuvw/qxe6Quw+f3upD/v6Nmn64
//S4/d39Xz7Bu6ei//rj5x/+46/uH9580dDm92/z/tOXN/p+/Pz4Sr+Hh2f7lv56db8+fdJ/
8/7zm89P9x/fPNnl2J/1It9+evr18e7HJ/1U/vqL2zfgdr/3d08/6qf1/tFMf37rvnv3+Pbp
4ZX9m989PH149f7hi/r57s2DQmn79/76o7ef+fPb7374+vnbz3zhvtt+6OZm+3/Vpf/u+ev7
V43r8c3r8ddcj99dj69fT2heT7jmesLuekL9emLzeuI11xN31xPr15Oa15OuuZ60ux59Kj8+
vbWL+RbvfP753ctfNvjqXx8eZH0un/Tht3/9+92//u3/Oli8fXh89+G9Rh76x6fPH58ffrv7
dq32t18+fLp7//X5+e5P/w8MJWutOHUSAA==

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.7.0-05999-g80a9201"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.7.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
# CONFIG_TASKS_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
CONFIG_BLK_CGROUP=y
CONFIG_DEBUG_BLK_CGROUP=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
CONFIG_USER_NS=y
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
# CONFIG_EXPERT is not set
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_USERFAULTFD=y
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
# CONFIG_PROFILING is not set
CONFIG_KEXEC_CORE=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
# CONFIG_CPU_NO_EFFICIENT_FFS is not set

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
# CONFIG_GCOV_FORMAT_3_4 is not set
CONFIG_GCOV_FORMAT_4_7=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
# CONFIG_BLK_DEV_BSGLIB is not set
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
# CONFIG_DEFAULT_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_X2APIC=y
# CONFIG_X86_MPPARSE is not set
# CONFIG_GOLDFISH is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
# CONFIG_ZBUD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_X86_INTEL_MPX is not set
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_KEXEC_FILE=y
# CONFIG_KEXEC_VERIFY_SIG is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_HIBERNATION is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_NFIT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
# CONFIG_NETFILTER_ADVANCED is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
CONFIG_DECNET=y
CONFIG_DECNET_ROUTER=y
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
# CONFIG_IPDDP_ENCAP is not set
# CONFIG_X25 is not set
CONFIG_LAPB=y
# CONFIG_PHONET is not set
CONFIG_IEEE802154=y
CONFIG_IEEE802154_NL802154_EXPERIMENTAL=y
CONFIG_IEEE802154_SOCKET=y
CONFIG_MAC802154=y
# CONFIG_NET_SCHED is not set
CONFIG_DCB=y
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
CONFIG_VSOCKETS=y
# CONFIG_NETLINK_DIAG is not set
CONFIG_MPLS=y
# CONFIG_NET_MPLS_GSO is not set
CONFIG_MPLS_ROUTING=y
# CONFIG_HSR is not set
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
CONFIG_AX25_DAMA_SLAVE=y
CONFIG_NETROM=y
CONFIG_ROSE=y

#
# AX.25 network device drivers
#
# CONFIG_MKISS is not set
# CONFIG_6PACK is not set
CONFIG_BPQETHER=y
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
# CONFIG_BAYCOM_PAR is not set
CONFIG_YAM=y
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
CONFIG_CAN_C_CAN=y
# CONFIG_CAN_C_CAN_PLATFORM is not set
# CONFIG_CAN_C_CAN_PCI is not set
# CONFIG_CAN_CC770 is not set
CONFIG_CAN_IFI_CANFD=y
CONFIG_CAN_M_CAN=y
# CONFIG_CAN_SJA1000 is not set
CONFIG_CAN_SOFTING=y
CONFIG_CAN_SOFTING_CS=y

#
# CAN SPI interfaces
#
# CONFIG_CAN_MCP251X is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRCOMM=y
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
# CONFIG_IRDA_CACHE_LAST_LSAP is not set
# CONFIG_IRDA_FAST_RR is not set
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
# CONFIG_DONGLE is not set

#
# FIR device drivers
#
# CONFIG_NSC_FIR is not set
# CONFIG_WINBOND_FIR is not set
# CONFIG_SMC_IRCC_FIR is not set
CONFIG_ALI_FIR=y
# CONFIG_VLSI_FIR is not set
CONFIG_VIA_FIR=y
CONFIG_BT=y
# CONFIG_BT_BREDR is not set
CONFIG_BT_LE=y
CONFIG_BT_LEDS=y
# CONFIG_BT_SELFTEST is not set
CONFIG_BT_DEBUGFS=y

#
# Bluetooth device drivers
#
CONFIG_BT_QCA=y
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
# CONFIG_BT_HCIUART_ATH3K is not set
# CONFIG_BT_HCIUART_LL is not set
CONFIG_BT_HCIUART_3WIRE=y
# CONFIG_BT_HCIUART_INTEL is not set
# CONFIG_BT_HCIUART_BCM is not set
CONFIG_BT_HCIUART_QCA=y
# CONFIG_BT_HCIUART_AG6XX is not set
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
# CONFIG_BT_HCIBLUECARD is not set
# CONFIG_BT_HCIBTUART is not set
# CONFIG_BT_HCIVHCI is not set
CONFIG_BT_MRVL=y
# CONFIG_BT_MRVL_SDIO is not set
CONFIG_BT_WILINK=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_RFKILL_GPIO=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
CONFIG_NFC_NCI=y
CONFIG_NFC_NCI_SPI=y
# CONFIG_NFC_NCI_UART is not set
CONFIG_NFC_HCI=y
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
# CONFIG_NFC_WILINK is not set
# CONFIG_NFC_TRF7970A is not set
CONFIG_NFC_SIM=y
CONFIG_NFC_FDP=y
CONFIG_NFC_FDP_I2C=y
CONFIG_NFC_PN544=y
CONFIG_NFC_PN544_I2C=y
# CONFIG_NFC_PN533_I2C is not set
# CONFIG_NFC_MICROREAD_I2C is not set
CONFIG_NFC_ST21NFCA=y
CONFIG_NFC_ST21NFCA_I2C=y
CONFIG_NFC_ST_NCI=y
CONFIG_NFC_ST_NCI_I2C=y
CONFIG_NFC_ST_NCI_SPI=y
CONFIG_NFC_NXP_NCI=y
CONFIG_NFC_NXP_NCI_I2C=y
CONFIG_NFC_S3FWRN5=y
CONFIG_NFC_S3FWRN5_I2C=y
# CONFIG_NFC_ST95HF is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
CONFIG_NET_DEVLINK=y
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_FENCE_TRACE=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
CONFIG_CMA_SIZE_SEL_MIN=y
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
# CONFIG_SSFDC is not set
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=y
CONFIG_MTD_SWAP=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_CFI_INTELEXT is not set
# CONFIG_MTD_CFI_AMDSTD is not set
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_DATAFLASH=y
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=y
CONFIG_MTD_DATAFLASH_OTP=y
CONFIG_MTD_M25P80=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_GPIO is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_DISKONCHIP is not set
# CONFIG_MTD_NAND_DOCG4 is not set
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_NAND_HISI504=y
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
CONFIG_MTD_MT81xx_NOR=y
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
# CONFIG_PARPORT_PC_FIFO is not set
CONFIG_PARPORT_PC_SUPERIO=y
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=y
CONFIG_BLK_DEV_FD=y
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_OSD is not set
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
CONFIG_BLK_DEV_RAM_DAX=y
# CONFIG_CDROM_PKTCDVD is not set
CONFIG_ATA_OVER_ETH=y
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
# CONFIG_AD525X_DPOT_SPI is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_BMP085_SPI=y
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
# CONFIG_PANEL is not set
CONFIG_C2PORT=y
# CONFIG_C2PORT_DURAMAR_2150 is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
CONFIG_IDE_GD_ATAPI=y
CONFIG_BLK_DEV_IDECS=y
# CONFIG_BLK_DEV_DELKIN is not set
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
CONFIG_BLK_DEV_CMD640_ENHANCED=y
# CONFIG_BLK_DEV_IDEPNP is not set

#
# PCI IDE chipsets support
#
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
# CONFIG_BLK_DEV_IDEDMA is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_MQ_DEFAULT=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
# CONFIG_SCSI_DH_HP_SW is not set
# CONFIG_SCSI_DH_EMC is not set
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
# CONFIG_ATA is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
CONFIG_BCACHE_DEBUG=y
CONFIG_BCACHE_CLOSURES_DEBUG=y
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=y
CONFIG_DM_MQ_DEFAULT=y
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=y
CONFIG_DM_DEBUG_BLOCK_STACK_TRACING=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
# CONFIG_DM_CRYPT is not set
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_CACHE=y
# CONFIG_DM_CACHE_SMQ is not set
CONFIG_DM_CACHE_CLEANER=y
# CONFIG_DM_ERA is not set
CONFIG_DM_MIRROR=y
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_RAID=y
# CONFIG_DM_ZERO is not set
# CONFIG_DM_MULTIPATH is not set
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
CONFIG_DM_VERITY=y
CONFIG_DM_VERITY_FEC=y
# CONFIG_DM_SWITCH is not set
# CONFIG_DM_LOG_WRITES is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
CONFIG_LOOPBACK_TARGET=y
CONFIG_ISCSI_TARGET=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
# CONFIG_NETDEVICES is not set
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=y
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_PEGASUS is not set
CONFIG_TABLET_SERIAL_WACOM4=y
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
# CONFIG_INPUT_AD714X is not set
CONFIG_INPUT_BMA150=y
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_PCSPKR=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
CONFIG_INPUT_MPU3050=y
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_GP2A is not set
CONFIG_INPUT_GPIO_BEEPER=y
CONFIG_INPUT_GPIO_TILT_POLLED=y
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_REGULATOR_HAPTIC is not set
# CONFIG_INPUT_RETU_PWRBUTTON is not set
CONFIG_INPUT_TPS65218_PWRBUTTON=y
CONFIG_INPUT_TWL6040_VIBRA=y
# CONFIG_INPUT_UINPUT is not set
CONFIG_INPUT_PCF8574=y
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
# CONFIG_INPUT_DA9052_ONKEY is not set
# CONFIG_INPUT_DA9055_ONKEY is not set
CONFIG_INPUT_DA9063_ONKEY=y
CONFIG_INPUT_WM831X_ON=y
# CONFIG_INPUT_PCAP is not set
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
# CONFIG_INPUT_ADXL34X_SPI is not set
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
CONFIG_INPUT_DRV2667_HAPTICS=y
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
# CONFIG_RMI4_SPI is not set
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
CONFIG_SERIAL_UARTLITE=y
CONFIG_SERIAL_UARTLITE_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
CONFIG_SERIAL_SC16IS7XX_SPI=y
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
CONFIG_SERIAL_IFX6X60=y
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_SERIAL_MCTRL_GPIO=y
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
CONFIG_IPMI_PANIC_STRING=y
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=y
CONFIG_IPMI_SSIF=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
CONFIG_R3964=y
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_TIS_ST33ZP24 is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_CADENCE is not set
# CONFIG_SPI_DESIGNWARE is not set
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_ROCKCHIP=y
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_SPMI=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MENZ127=y
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_ZX=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_IT87=y
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_SX150X=y
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=y
# CONFIG_GPIO_CRYSTAL_COVE is not set
CONFIG_GPIO_DA9052=y
# CONFIG_GPIO_DA9055 is not set
# CONFIG_GPIO_LP3943 is not set
CONFIG_GPIO_RC5T583=y
CONFIG_GPIO_TPS65218=y
# CONFIG_GPIO_TPS6586X is not set
# CONFIG_GPIO_TPS65910 is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL6040=y
# CONFIG_GPIO_WM831X is not set
# CONFIG_GPIO_WM8994 is not set

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=y
# CONFIG_GPIO_PISOSR is not set

#
# SPI or I2C GPIO expanders
#
CONFIG_GPIO_MCP23S08=y
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2406=y
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_WM831X_BACKUP=y
# CONFIG_WM831X_POWER is not set
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_SBS is not set
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_CHARGER_DA9150 is not set
CONFIG_BATTERY_DA9150=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
# CONFIG_CHARGER_88PM860X is not set
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_LP8788=y
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX14577=y
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=y
# CONFIG_CHARGER_SMB347 is not set
CONFIG_CHARGER_TPS65217=y
CONFIG_BATTERY_GAUGE_LTC2941=y
# CONFIG_CHARGER_RT9455 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GPIO_FAN=y
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX31722 is not set
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_MAX31790=y
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM70 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_NCT6683 is not set
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_INA3221 is not set
# CONFIG_SENSORS_TC74 is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR=y
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_EMULATION=y
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
# CONFIG_GENERIC_ADC_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_SFLASH=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
CONFIG_BCMA_DRIVER_GPIO=y
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9062 is not set
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
# CONFIG_MFD_MENF21BMC is not set
CONFIG_EZX_PCAP=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RT5033 is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=y
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
# CONFIG_AB3100_OTP is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
# CONFIG_MFD_TPS65912_I2C is not set
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_CS47L24=y
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AAT2870=y
# CONFIG_REGULATOR_AB3100 is not set
CONFIG_REGULATOR_AS3711=y
# CONFIG_REGULATOR_DA9052 is not set
CONFIG_REGULATOR_DA9055=y
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_GPIO=y
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=y
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
# CONFIG_REGULATOR_MT6323 is not set
CONFIG_REGULATOR_MT6397=y
CONFIG_REGULATOR_PCAP=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_QCOM_SPMI=y
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_SKY81452=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS6524X=y
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65910=y
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8400=y
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_MEDIA_CEC_EDID=y
CONFIG_MEDIA_CONTROLLER=y
# CONFIG_MEDIA_CONTROLLER_DVB is not set
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=y
CONFIG_VIDEO_VIVID_MAX_DEVS=64
# CONFIG_VIDEO_VIM2M is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_SI470X=y
CONFIG_I2C_SI470X=y
# CONFIG_RADIO_SI4713 is not set
# CONFIG_RADIO_MAXIRADIO is not set
CONFIG_RADIO_TEA5764=y
# CONFIG_RADIO_TEA5764_XTAL is not set
CONFIG_RADIO_SAA7706H=y
# CONFIG_RADIO_TEF6862 is not set
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_RADIO_WL128X=y
CONFIG_VIDEO_V4L2_TPG=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_FBDEV_EMULATION is not set
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_ADV7511=y
CONFIG_DRM_I2C_CH7006=y
# CONFIG_DRM_I2C_SIL164 is not set
CONFIG_DRM_I2C_NXP_TDA998X=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
CONFIG_DRM_VGEM=y
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_VIRTIO_GPU=y
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=y

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
CONFIG_FB_BIG_ENDIAN=y
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_IBM_GXT4500=y
# CONFIG_FB_VIRTUAL is not set
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_DA9052 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_88PM860X is not set
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_SKY81452 is not set
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_AS3711=y
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_ASUS=y
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CMEDIA is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_ELECOM=y
# CONFIG_HID_EZKEY is not set
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
CONFIG_HID_KEYTOUCH=y
# CONFIG_HID_KYE is not set
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LENOVO=y
CONFIG_HID_LOGITECH=y
# CONFIG_HID_LOGITECH_DJ is not set
CONFIG_HID_LOGITECH_HIDPP=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MONTEREY is not set
CONFIG_HID_MULTITOUCH=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
# CONFIG_HID_GREENASIA is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
CONFIG_UWB=y
# CONFIG_UWB_WHCI is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
CONFIG_MMC_SPI=y
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_USDHI6ROL0 is not set
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=y
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_LP8860=y
CONFIG_LEDS_CLEVO_MAIL=y
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_LM355x=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
# CONFIG_LEDS_TRIGGER_CAMERA is not set
CONFIG_LEDS_TRIGGER_PANIC=y
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABX80X is not set
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1307_HWMON=y
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_LP8788 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_ISL12057 is not set
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF85063=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_TPS6586X=y
# CONFIG_RTC_DRV_TPS65910 is not set
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8010 is not set
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV8803=y
CONFIG_RTC_DRV_S5M=y

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1302 is not set
CONFIG_RTC_DRV_DS1305=y
CONFIG_RTC_DRV_DS1343=y
# CONFIG_RTC_DRV_DS1347 is not set
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_R9701=y
# CONFIG_RTC_DRV_RX4581 is not set
# CONFIG_RTC_DRV_RX6110 is not set
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_MCP795=y
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_PCF2127=y
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
# CONFIG_RTC_DRV_DS1685 is not set
CONFIG_RTC_DRV_DS1689=y
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
CONFIG_RTC_DS1685_PROC_REGS=y
CONFIG_RTC_DS1685_SYSFS_REGS=y
CONFIG_RTC_DRV_DS1742=y
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_DA9052=y
# CONFIG_RTC_DRV_DA9055 is not set
CONFIG_RTC_DRV_DA9063=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
# CONFIG_RTC_DRV_MSM6242 is not set
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_WM831X=y
# CONFIG_RTC_DRV_AB3100 is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=y
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_MT6397=y

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_INTEL_IDMA64=y
# CONFIG_INTEL_IOATDMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_HSU_DMA=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
CONFIG_IRQ_BYPASS_MANAGER=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_INPUT=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
# CONFIG_RTS5208 is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16203=y
CONFIG_ADIS16209=y
CONFIG_ADIS16240=y
CONFIG_SCA3000=y

#
# Analog to digital converters
#
CONFIG_AD7606=y
# CONFIG_AD7606_IFACE_PARALLEL is not set
CONFIG_AD7606_IFACE_SPI=y
CONFIG_AD7780=y
CONFIG_AD7816=y
# CONFIG_AD7192 is not set
# CONFIG_AD7280 is not set

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
CONFIG_ADT7316_SPI=y
CONFIG_ADT7316_I2C=y

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
# CONFIG_AD7152 is not set
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#
CONFIG_AD9832=y
# CONFIG_AD9834 is not set

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16060 is not set

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
CONFIG_SENSORS_ISL29028=y
CONFIG_TSL2583=y
CONFIG_TSL2x7x=y

#
# Active energy metering IC
#
CONFIG_ADE7753=y
CONFIG_ADE7754=y
# CONFIG_ADE7758 is not set
# CONFIG_ADE7759 is not set
# CONFIG_ADE7854 is not set

#
# Resolver to digital converters
#
# CONFIG_AD2S90 is not set
CONFIG_AD2S1200=y
CONFIG_AD2S1210=y

#
# Triggers - standalone
#
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
CONFIG_STAGING_MEDIA=y
CONFIG_I2C_BCM2048=y
# CONFIG_MEDIA_CEC is not set
# CONFIG_VIDEO_TW686X_KH is not set

#
# Android
#
CONFIG_ASHMEM=y
# CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
CONFIG_ION=y
CONFIG_ION_TEST=y
# CONFIG_ION_DUMMY is not set
CONFIG_MTD_SPINAND_MT29F=y
# CONFIG_MTD_SPINAND_ONDIEECC is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
# CONFIG_CRYPTO_SKEIN is not set
# CONFIG_UNISYSSPAR is not set
CONFIG_FB_TFT=y
CONFIG_FB_TFT_AGM1264K_FL=y
CONFIG_FB_TFT_BD663474=y
# CONFIG_FB_TFT_HX8340BN is not set
CONFIG_FB_TFT_HX8347D=y
CONFIG_FB_TFT_HX8353D=y
CONFIG_FB_TFT_HX8357D=y
CONFIG_FB_TFT_ILI9163=y
CONFIG_FB_TFT_ILI9320=y
CONFIG_FB_TFT_ILI9325=y
CONFIG_FB_TFT_ILI9340=y
# CONFIG_FB_TFT_ILI9341 is not set
# CONFIG_FB_TFT_ILI9481 is not set
# CONFIG_FB_TFT_ILI9486 is not set
CONFIG_FB_TFT_PCD8544=y
# CONFIG_FB_TFT_RA8875 is not set
CONFIG_FB_TFT_S6D02A1=y
# CONFIG_FB_TFT_S6D1121 is not set
CONFIG_FB_TFT_SSD1289=y
# CONFIG_FB_TFT_SSD1305 is not set
CONFIG_FB_TFT_SSD1306=y
CONFIG_FB_TFT_SSD1325=y
CONFIG_FB_TFT_SSD1331=y
CONFIG_FB_TFT_SSD1351=y
# CONFIG_FB_TFT_ST7735R is not set
# CONFIG_FB_TFT_ST7789V is not set
CONFIG_FB_TFT_TINYLCD=y
# CONFIG_FB_TFT_TLS8204 is not set
CONFIG_FB_TFT_UC1611=y
# CONFIG_FB_TFT_UC1701 is not set
CONFIG_FB_TFT_UPD161704=y
CONFIG_FB_TFT_WATTEROTT=y
CONFIG_FB_FLEX=y
# CONFIG_FB_TFT_FBTFT_DEVICE is not set
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_SMBIOS=y
CONFIG_DELL_LAPTOP=y
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
CONFIG_AMILO_RFKILL=y
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_COMPAL_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ASUS_WIRELESS is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=y
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
# CONFIG_CHROMEOS_PSTORE is not set
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SUNXI_SRAM is not set
# CONFIG_SOC_TI is not set
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_DEVICE is not set
CONFIG_IIO_SW_TRIGGER=y
CONFIG_IIO_TRIGGERED_EVENT=y

#
# Accelerometers
#
# CONFIG_BMA180 is not set
# CONFIG_BMA220 is not set
CONFIG_BMC150_ACCEL=y
CONFIG_BMC150_ACCEL_I2C=y
CONFIG_BMC150_ACCEL_SPI=y
CONFIG_HID_SENSOR_ACCEL_3D=y
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=y
# CONFIG_KXSD9 is not set
CONFIG_KXCJK1013=y
# CONFIG_MMA7455_I2C is not set
# CONFIG_MMA7455_SPI is not set
# CONFIG_MMA7660 is not set
# CONFIG_MMA8452 is not set
CONFIG_MMA9551_CORE=y
# CONFIG_MMA9551 is not set
CONFIG_MMA9553=y
CONFIG_MXC4005=y
CONFIG_MXC6255=y
# CONFIG_STK8312 is not set
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7291=y
CONFIG_AD7298=y
# CONFIG_AD7476 is not set
CONFIG_AD7791=y
CONFIG_AD7793=y
# CONFIG_AD7887 is not set
# CONFIG_AD7923 is not set
CONFIG_AD799X=y
CONFIG_DA9150_GPADC=y
CONFIG_HI8435=y
CONFIG_INA2XX_ADC=y
CONFIG_LP8788_ADC=y
# CONFIG_MAX1027 is not set
CONFIG_MAX1363=y
# CONFIG_MCP320X is not set
# CONFIG_MCP3422 is not set
# CONFIG_MEN_Z188_ADC is not set
# CONFIG_NAU7802 is not set
CONFIG_QCOM_SPMI_IADC=y
# CONFIG_QCOM_SPMI_VADC is not set
# CONFIG_TI_ADC081C is not set
# CONFIG_TI_ADC0832 is not set
# CONFIG_TI_ADC128S052 is not set

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Chemical Sensors
#
# CONFIG_ATLAS_PH_SENSOR is not set
CONFIG_IAQCORE=y
CONFIG_VZ89X=y

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_SSP_SENSORS_COMMONS=y
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
# CONFIG_AD5360 is not set
CONFIG_AD5380=y
CONFIG_AD5421=y
CONFIG_AD5446=y
CONFIG_AD5449=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5592R=y
CONFIG_AD5593R=y
CONFIG_AD5504=y
# CONFIG_AD5624R_SPI is not set
CONFIG_AD5686=y
# CONFIG_AD5755 is not set
CONFIG_AD5761=y
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD7303=y
CONFIG_M62332=y
CONFIG_MAX517=y
CONFIG_MCP4725=y
# CONFIG_MCP4922 is not set

#
# IIO dummy driver
#

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
# CONFIG_ADIS16130 is not set
CONFIG_ADIS16136=y
CONFIG_ADIS16260=y
CONFIG_ADXRS450=y
# CONFIG_BMG160 is not set
CONFIG_HID_SENSOR_GYRO_3D=y
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_IIO_ST_GYRO_SPI_3AXIS=y
# CONFIG_ITG3200 is not set

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4403=y
CONFIG_AFE4404=y
# CONFIG_MAX30100 is not set

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
CONFIG_HDC100X=y
# CONFIG_HTU21 is not set
CONFIG_SI7005=y
CONFIG_SI7020=y

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
CONFIG_ADIS16480=y
# CONFIG_BMI160_I2C is not set
# CONFIG_BMI160_SPI is not set
# CONFIG_KMX61 is not set
CONFIG_INV_MPU6050_IIO=y
CONFIG_INV_MPU6050_I2C=y
CONFIG_INV_MPU6050_SPI=y
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=y
CONFIG_AL3320A=y
CONFIG_APDS9300=y
# CONFIG_APDS9960 is not set
# CONFIG_BH1750 is not set
CONFIG_BH1780=y
CONFIG_CM32181=y
CONFIG_CM3232=y
CONFIG_CM3323=y
CONFIG_CM36651=y
# CONFIG_GP2AP020A00F is not set
CONFIG_ISL29125=y
# CONFIG_HID_SENSOR_ALS is not set
CONFIG_HID_SENSOR_PROX=y
# CONFIG_JSA1212 is not set
CONFIG_RPR0521=y
CONFIG_SENSORS_LM3533=y
# CONFIG_LTR501 is not set
CONFIG_MAX44000=y
CONFIG_OPT3001=y
# CONFIG_PA12203001 is not set
# CONFIG_STK3310 is not set
# CONFIG_TCS3414 is not set
# CONFIG_TCS3472 is not set
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL4531=y
CONFIG_US5182D=y
# CONFIG_VCNL4000 is not set
CONFIG_VEML6070=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_AK09911=y
CONFIG_BMC150_MAGN=y
CONFIG_BMC150_MAGN_I2C=y
CONFIG_BMC150_MAGN_SPI=y
CONFIG_MAG3110=y
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
# CONFIG_MMC35240 is not set
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y
CONFIG_SENSORS_HMC5843_SPI=y

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=y
# CONFIG_HID_SENSOR_DEVICE_ROTATION is not set

#
# Triggers - standalone
#
CONFIG_IIO_HRTIMER_TRIGGER=y
CONFIG_IIO_INTERRUPT_TRIGGER=y
# CONFIG_IIO_TIGHTLOOP_TRIGGER is not set
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
# CONFIG_DS1803 is not set
# CONFIG_MAX5487 is not set
# CONFIG_MCP4131 is not set
CONFIG_MCP4531=y
# CONFIG_TPL0102 is not set

#
# Pressure sensors
#
# CONFIG_HID_SENSOR_PRESS is not set
CONFIG_HP03=y
CONFIG_MPL115=y
CONFIG_MPL115_I2C=y
# CONFIG_MPL115_SPI is not set
CONFIG_MPL3115=y
CONFIG_MS5611=y
# CONFIG_MS5611_I2C is not set
CONFIG_MS5611_SPI=y
CONFIG_MS5637=y
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_IIO_ST_PRESS_SPI=y
CONFIG_T5403=y
CONFIG_HP206C=y

#
# Lightning sensors
#
# CONFIG_AS3935 is not set

#
# Proximity sensors
#
# CONFIG_LIDAR_LITE_V2 is not set
CONFIG_SX9500=y

#
# Temperature sensors
#
CONFIG_MLX90614=y
CONFIG_TMP006=y
CONFIG_TSYS01=y
# CONFIG_TSYS02D is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=y
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
CONFIG_LIBNVDIMM=y
CONFIG_BLK_DEV_PMEM=y
# CONFIG_ND_BLK is not set
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=y
CONFIG_BTT=y
CONFIG_NVMEM=y
# CONFIG_STM is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
# CONFIG_INTEL_TH_GTH is not set
# CONFIG_INTEL_TH_MSU is not set
# CONFIG_INTEL_TH_PTI is not set
# CONFIG_INTEL_TH_DEBUG is not set

#
# FPGA Configuration Support
#
CONFIG_FPGA=y
# CONFIG_FPGA_MGR_ZYNQ_FPGA is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
# CONFIG_REISERFS_FS_SECURITY is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
CONFIG_XFS_DEBUG=y
CONFIG_GFS2_FS=y
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
CONFIG_OCFS2_FS_STATS=y
# CONFIG_OCFS2_DEBUG_MASKLOG is not set
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
CONFIG_BTRFS_ASSERT=y
CONFIG_NILFS2_FS=y
# CONFIG_F2FS_FS is not set
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
# CONFIG_FS_ENCRYPTION is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
CONFIG_FSCACHE_HISTOGRAM=y
CONFIG_FSCACHE_DEBUG=y
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_FAT_DEFAULT_UTF8 is not set
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
# CONFIG_HFS_FS is not set
CONFIG_HFSPLUS_FS=y
# CONFIG_HFSPLUS_FS_POSIX_ACL is not set
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
CONFIG_JFFS2_FS_WBUF_VERIFY=y
# CONFIG_JFFS2_SUMMARY is not set
CONFIG_JFFS2_FS_XATTR=y
# CONFIG_JFFS2_FS_POSIX_ACL is not set
# CONFIG_JFFS2_FS_SECURITY is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
# CONFIG_UBIFS_FS_LZO is not set
CONFIG_UBIFS_FS_ZLIB=y
CONFIG_UBIFS_ATIME_SUPPORT=y
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
# CONFIG_SQUASHFS is not set
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
CONFIG_QNX4FS_FS=y
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_BLOCK=y
# CONFIG_ROMFS_BACKED_BY_MTD is not set
# CONFIG_ROMFS_BACKED_BY_BOTH is not set
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_PSTORE=y
CONFIG_PSTORE_ZLIB_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
# CONFIG_PSTORE_CONSOLE is not set
CONFIG_PSTORE_PMSG=y
CONFIG_PSTORE_RAM=y
# CONFIG_SYSV_FS is not set
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=y
CONFIG_EXOFS_DEBUG=y
CONFIG_ORE=y
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=8192
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_STACK_VALIDATION is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_POISONING=y
CONFIG_PAGE_POISONING_NO_SANITY=y
# CONFIG_PAGE_POISONING_ZERO is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
# CONFIG_KASAN_OUTLINE is not set
CONFIG_KASAN_INLINE=y
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y
# CONFIG_TIMER_STATS is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_PERF_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
# CONFIG_TEST_PRINTF is not set
CONFIG_TEST_BITMAP=y
CONFIG_TEST_UUID=y
CONFIG_TEST_RHASHTABLE=y
CONFIG_TEST_HASH=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
CONFIG_TEST_UDELAY=y
CONFIG_MEMTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
# CONFIG_TRUSTED_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_RSA=y
# CONFIG_CRYPTO_DH is not set
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
# CONFIG_CRYPTO_ECHAINIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA1_MB=y
# CONFIG_CRYPTO_SHA256_MB is not set
# CONFIG_CRYPTO_SHA512_MB is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_SHA3 is not set
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_LZO is not set
# CONFIG_CRYPTO_842 is not set
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_USER_API_RNG=y
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQFD=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_KVM_COMPAT=y
CONFIG_HAVE_KVM_IRQ_BYPASS=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONTS=y
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_FONT_6x11=y
CONFIG_FONT_7x14=y
# CONFIG_FONT_PEARL_8x8 is not set
CONFIG_FONT_ACORN_8x8=y
CONFIG_FONT_MINI_4x6=y
CONFIG_FONT_6x10=y
CONFIG_FONT_SUN8x16=y
# CONFIG_FONT_SUN12x22 is not set
CONFIG_FONT_10x18=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y

--4Ckj6UjgE2iN1+kY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
