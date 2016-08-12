Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1715C6B0263
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:57:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so39817337pfd.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:57:47 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ba3si8232357pab.87.2016.08.12.02.57.43
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 02:57:43 -0700 (PDT)
Date: Fri, 12 Aug 2016 17:57:35 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mm, kasan] 80a9201a59:  RIP: 0010:[<ffffffff9890f590>]
 [<ffffffff9890f590>] __kernel_text_address
Message-ID: <20160812095735.GA3191@wfg-t540p.sh.intel.com>
References: <20160811133503.f0896f6781a41570f9eebb42@linux-foundation.org>
 <20160812074808.GA26590@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160812074808.GA26590@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, Neil Horman <nhorman@redhat.com>, Andy Lutomirski <luto@kernel.org>

On Fri, Aug 12, 2016 at 03:48:08PM +0800, Fengguang Wu wrote:
>On Thu, Aug 11, 2016 at 01:35:03PM -0700, Andrew Morton wrote:
>>On Thu, 11 Aug 2016 12:52:27 +0800 kernel test robot <fengguang.wu@intel.com> wrote:
>>
>>> Greetings,
>>>
>>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>>
>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>>>
>>> commit 80a9201a5965f4715d5c09790862e0df84ce0614
>>> Author:     Alexander Potapenko <glider@google.com>
>>> AuthorDate: Thu Jul 28 15:49:07 2016 -0700
>>> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
>>> CommitDate: Thu Jul 28 16:07:41 2016 -0700
>>>
>>>     mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
>>>
>>>     For KASAN builds:
>>>      - switch SLUB allocator to using stackdepot instead of storing the
>>>        allocation/deallocation stacks in the objects;
>>>      - change the freelist hook so that parts of the freelist can be put
>>>        into the quarantine.
>>>
>>> ...
>>>
>>> [   64.298576] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper/0:1]
>>> [   64.300827] irq event stamp: 5606950
>>> [   64.301377] hardirqs last  enabled at (5606949): [<ffffffff98a4ef09>] T.2097+0x9a/0xbe
>>> [   64.302586] hardirqs last disabled at (5606950): [<ffffffff997347a9>] apic_timer_interrupt+0x89/0xa0
>>> [   64.303991] softirqs last  enabled at (5605564): [<ffffffff99735abe>] __do_softirq+0x23e/0x2bb
>>> [   64.305308] softirqs last disabled at (5605557): [<ffffffff988ee34f>] irq_exit+0x73/0x108
>>> [   64.306598] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.7.0-05999-g80a9201 #1
>>> [   64.307678] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
>>> [   64.326233] task: ffff88000ea19ec0 task.stack: ffff88000ea20000
>>> [   64.327137] RIP: 0010:[<ffffffff9890f590>]  [<ffffffff9890f590>] __kernel_text_address+0xb/0xa1
>>> [   64.328504] RSP: 0000:ffff88000ea27348  EFLAGS: 00000207
>>> [   64.329320] RAX: 0000000000000001 RBX: ffff88000ea275c0 RCX: 0000000000000001
>>> [   64.330426] RDX: ffff88000ea27ff8 RSI: 024080c099733d8f RDI: 024080c099733d8f
>>> [   64.331496] RBP: ffff88000ea27348 R08: ffff88000ea27678 R09: 0000000000000000
>>> [   64.332567] R10: 0000000000021298 R11: ffffffff990f235c R12: ffff88000ea276c8
>>> [   64.333635] R13: ffffffff99805e20 R14: ffff88000ea19ec0 R15: 0000000000000000
>>> [   64.334706] FS:  0000000000000000(0000) GS:ffff88000ee00000(0000) knlGS:0000000000000000
>>> [   64.335916] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> [   64.336782] CR2: 0000000000000000 CR3: 000000000aa0a000 CR4: 00000000000406b0
>>> [   64.337846] Stack:
>>> [   64.338206]  ffff88000ea273a8 ffffffff9881f3dd 024080c099733d8f ffffffffffff8000
>>> [   64.339410]  ffff88000ea27678 ffff88000ea276c8 000000020e81a4d8 ffff88000ea273f8
>>> [   64.340602]  ffffffff99805e20 ffff88000ea19ec0 ffff88000ea27438 ffff88000ee07fc0
>>> [   64.348993] Call Trace:
>>> [   64.349380]  [<ffffffff9881f3dd>] print_context_stack+0x68/0x13e
>>> [   64.350295]  [<ffffffff9881e4af>] dump_trace+0x3ab/0x3d6
>>> [   64.351102]  [<ffffffff9882f6e4>] save_stack_trace+0x31/0x5c
>>> [   64.351964]  [<ffffffff98a521db>] kasan_kmalloc+0x126/0x1f6
>>> [   64.365727]  [<ffffffff9882f6e4>] ? save_stack_trace+0x31/0x5c
>>> [   64.366675]  [<ffffffff98a521db>] ? kasan_kmalloc+0x126/0x1f6
>>> [   64.367560]  [<ffffffff9904a8eb>] ? acpi_ut_create_generic_state+0x43/0x5c
>>>
>>
>>At a guess I'd say that
>>arch/x86/kernel/dumpstack.c:print_context_stack() failed to terminate,
>>or took a super long time.  Is that a thing that is known to be possible?
>
>Andrew, note that this kernel is compiled with gcc-4.4.
>
>This commit caused the below problems, too, with gcc-4.4. However they
>no longer show up in mainline HEAD, so not reported before.

The gcc-6 results are roughly the same:

                                                                                    parent       first-bad     mainline
+----------------------------------------------------------------------------------+------------+------------+------------+
|                                                                                  | c146a2b98e | 80a9201a59 | 4b9eaf33d8 |
+----------------------------------------------------------------------------------+------------+------------+------------+
| boot_successes                                                                   | 110        | 30         | 102        |
| boot_failures                                                                    | 2          | 80         | 10         |
| IP-Config:Auto-configuration_of_network_failed                                   | 2          | 1          |            |
| Mem-Info                                                                         | 0          | 4          | 7          |
| BUG_anon_vma_chain(Not_tainted):Poison_overwritten                               | 0          | 17         |            |
| INFO:#-#.First_byte#instead_of                                                   | 0          | 53         |            |
| INFO:Allocated_in_anon_vma_clone_age=#cpu=#pid=                                  | 0          | 15         |            |
| INFO:Freed_in_qlist_free_all_age=#cpu=#pid=                                      | 0          | 52         |            |
| INFO:Slab#objects=#used=#fp=0x(null)flags=                                       | 0          | 51         |            |
| INFO:Object#@offset=#fp=                                                         | 0          | 45         |            |
| backtrace:SyS_clone                                                              | 0          | 50         |            |
| BUG_kmalloc-#(Not_tainted):Poison_overwritten                                    | 0          | 11         |            |
| INFO:Allocated_in_kernfs_fop_open_age=#cpu=#pid=                                 | 0          | 3          |            |
| backtrace:SyS_open                                                               | 0          | 9          |            |
| invoked_oom-killer:gfp_mask=0x                                                   | 0          | 1          | 3          |
| Out_of_memory:Kill_process                                                       | 0          | 1          | 3          |
| backtrace:SyS_mlockall                                                           | 0          | 2          | 5          |
| INFO:Allocated_in_anon_vma_prepare_age=#cpu=#pid=                                | 0          | 7          |            |
| backtrace:do_execve                                                              | 0          | 29         |            |
| backtrace:SyS_execve                                                             | 0          | 30         |            |
| BUG_vm_area_struct(Not_tainted):Poison_overwritten                               | 0          | 11         |            |
| INFO:Allocated_in_copy_process_age=#cpu=#pid=                                    | 0          | 10         |            |
| backtrace:mmap_region                                                            | 0          | 6          |            |
| backtrace:SyS_mmap_pgoff                                                         | 0          | 5          |            |
| backtrace:SyS_mmap                                                               | 0          | 5          |            |
| INFO:Allocated_in_mmap_region_age=#cpu=#pid=                                     | 0          | 5          |            |
| backtrace:mprotect_fixup                                                         | 0          | 7          |            |
| backtrace:SyS_mprotect                                                           | 0          | 7          |            |
| BUG_skbuff_head_cache(Not_tainted):Poison_overwritten                            | 0          | 2          |            |
| INFO:Allocated_in__alloc_skb_age=#cpu=#pid=                                      | 0          | 5          |            |
| backtrace:vfs_write                                                              | 0          | 5          |            |
| backtrace:SyS_write                                                              | 0          | 5          |            |
| BUG_names_cache(Not_tainted):Poison_overwritten                                  | 0          | 6          |            |
| INFO:Allocated_in_getname_flags_age=#cpu=#pid=                                   | 0          | 8          |            |
| INFO:Allocated_in_do_execveat_common_age=#cpu=#pid=                              | 0          | 4          |            |
| BUG_files_cache(Tainted:G_B):Poison_overwritten                                  | 0          | 1          |            |
| Oops                                                                             | 0          | 10         |            |
| Kernel_panic-not_syncing:Fatal_exception                                         | 0          | 28         | 1          |
| BUG:unable_to_handle_kernel                                                      | 0          | 10         |            |
| RIP:vt_console_print                                                             | 0          | 10         |            |
| BUG:KASAN:use-after-free_in_vma_interval_tree_compute_subtree_last_at_addr       | 0          | 5          |            |
| BUG:KASAN:use-after-free_in_vma_compute_subtree_gap_at_addr                      | 0          | 2          |            |
| backtrace:load_script                                                            | 0          | 11         |            |
| backtrace:_do_fork                                                               | 0          | 25         |            |
| BUG:KASAN:use-after-free_in_put_pid_at_addr                                      | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_handle_mm_fault_at_addr                              | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_native_set_pte_at_at_addr                            | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_unmap_page_range_at_addr                             | 0          | 3          |            |
| BUG:Bad_page_map_in_process                                                      | 0          | 2          |            |
| backtrace:smpboot_thread_fn                                                      | 0          | 1          |            |
| backtrace:ret_from_fork                                                          | 0          | 2          | 1          |
| backtrace:do_group_exit                                                          | 0          | 13         |            |
| backtrace:SyS_exit_group                                                         | 0          | 13         |            |
| INFO:Object#@offset=#fp=0x(null)                                                 | 0          | 16         |            |
| general_protection_fault:#[##]PREEMPT_KASAN                                      | 0          | 18         | 1          |
| RIP:remove_full                                                                  | 0          | 3          |            |
| backtrace:SyS_newstat                                                            | 0          | 3          |            |
| BUG_anon_vma_chain(Tainted:G_B):Poison_overwritten                               | 0          | 16         |            |
| backtrace:getname                                                                | 0          | 1          |            |
| backtrace:kernfs_fop_read                                                        | 0          | 5          |            |
| backtrace:vfs_read                                                               | 0          | 5          |            |
| backtrace:SyS_read                                                               | 0          | 5          |            |
| BUG:KASAN:use-after-free_in__rb_insert_augmented_at_addr                         | 0          | 8          |            |
| BUG:KASAN:use-after-free_in_find_vma_at_addr                                     | 0          | 4          |            |
| BUG:KASAN:use-after-free_in_vmacache_update_at_addr                              | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_vma_interval_tree_remove_at_addr                     | 0          | 3          |            |
| BUG:KASAN:use-after-free_in__do_page_fault_at_addr                               | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_arch_vma_access_permitted_at_addr                    | 0          | 1          |            |
| BUG:KASAN:use-after-free_in__rb_erase_color_at_addr                              | 0          | 6          |            |
| BUG:KASAN:use-after-free_in_wp_page_copy_at_addr                                 | 0          | 1          |            |
| BUG_vm_area_struct(Tainted:G_B):Poison_overwritten                               | 0          | 7          |            |
| BUG:KASAN:use-after-free_in_get_page_from_freelist_at_addr                       | 0          | 1          |            |
| BUG_dentry(Tainted:G_B):Poison_overwritten                                       | 0          | 1          |            |
| INFO:Allocated_in__d_alloc_age=#cpu=#pid=                                        | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_unlink_anon_vmas_at_addr                             | 0          | 15         |            |
| RIP:unlink_anon_vmas                                                             | 0          | 12         |            |
| backtrace:SyS_readlink                                                           | 0          | 3          |            |
| INFO:Allocated_in_kzalloc_age=#cpu=#pid=                                         | 0          | 6          |            |
| BUG_kmalloc-#(Tainted:G_B):Poison_overwritten                                    | 0          | 10         |            |
| INFO:Allocated_in_load_elf_phdrs_age=#cpu=#pid=                                  | 0          | 3          |            |
| INFO:Allocated_in_do_brk_age=#cpu=#pid=                                          | 0          | 1          |            |
| INFO:Allocated_in_anon_vma_fork_age=#cpu=#pid=                                   | 0          | 9          |            |
| BUG:KASAN:use-after-free_in__anon_vma_interval_tree_compute_subtree_last_at_addr | 0          | 6          |            |
| BUG:KASAN:use-after-free_in__anon_vma_interval_tree_augment_rotate_at_addr       | 0          | 4          |            |
| BUG:KASAN:use-after-free_in__rb_rotate_set_parents_at_addr                       | 0          | 7          |            |
| BUG:KASAN:use-after-free_in_anon_vma_interval_tree_remove_at_addr                | 0          | 2          |            |
| BUG:KASAN:use-after-free_in__anon_vma_interval_tree_augment_propagate_at_addr    | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_anon_vma_interval_tree_insert_at_addr                | 0          | 4          |            |
| INFO:Slab#objects=#used=#fp=#flags=                                              | 0          | 3          |            |
| BUG_names_cache(Tainted:G_B):Poison_overwritten                                  | 0          | 4          |            |
| backtrace:SyS_mount                                                              | 0          | 1          |            |
| backtrace:SyS_symlink                                                            | 0          | 3          |            |
| BUG_skbuff_head_cache(Tainted:G_B):Poison_overwritten                            | 0          | 2          |            |
| backtrace:SyS_sendto                                                             | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_vma_interval_tree_augment_rotate_at_addr             | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_vma_last_pgoff_at_addr                               | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_vma_interval_tree_augment_propagate_at_addr          | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_vma_interval_tree_insert_at_addr                     | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_unmap_vmas_at_addr                                   | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_print_bad_pte_at_addr                                | 0          | 1          |            |
| backtrace:vm_mmap_pgoff                                                          | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_copy_process_at_addr                                 | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_anon_vma_fork_at_addr                                | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_copy_page_range_at_addr                              | 0          | 1          |            |
| backtrace:___slab_alloc                                                          | 0          | 3          |            |
| RIP:__wake_up_common                                                             | 0          | 1          | 1          |
| backtrace:fd_timer_workfn                                                        | 0          | 1          | 1          |
| INFO:Allocated_in__install_special_mapping_age=#cpu=#pid=                        | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_locks_remove_posix_at_addr                           | 0          | 1          |            |
| BUG:KASAN:use-after-free_in___sys_sendmsg_at_addr                                | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_sock_sendmsg_nosec_at_addr                           | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_netlink_sendmsg_at_addr                              | 0          | 1          |            |
| BUG:KASAN:use-after-free_in__sys_sendmsg_at_addr                                 | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_sock_poll_at_addr                                    | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_datagram_poll_at_addr                                | 0          | 1          |            |
| backtrace:SyS_pipe                                                               | 0          | 1          |            |
| backtrace:__close_fd                                                             | 0          | 1          |            |
| backtrace:SyS_close                                                              | 0          | 1          |            |
| backtrace:SYSC_socket                                                            | 0          | 1          |            |
| backtrace:SyS_socket                                                             | 0          | 2          |            |
| backtrace:SyS_sendmsg                                                            | 0          | 3          |            |
| backtrace:__sys_sendmsg                                                          | 0          | 1          |            |
| backtrace:SyS_ppoll                                                              | 0          | 1          |            |
| BUG_files_cache(Not_tainted):Poison_overwritten                                  | 0          | 1          |            |
| INFO:Allocated_in_dup_fd_age=#cpu=#pid=                                          | 0          | 1          |            |
| INFO:Allocated_in_uevent_show_age=#cpu=#pid=                                     | 0          | 1          |            |
| backtrace:SyS_munmap                                                             | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_anon_vma_clone_at_addr                               | 0          | 2          |            |
| RIP:anon_vma_clone                                                               | 0          | 2          |            |
| INFO:Allocated_in_getname_kernel_age=#cpu=#pid=                                  | 0          | 2          |            |
| INFO:Allocated_in__split_vma_age=#cpu=#pid=                                      | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_rcu_process_callbacks_at_addr                        | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_unlink_file_vma_at_addr                              | 0          | 2          |            |
| BUG:KASAN:use-after-free_in_remove_vma_at_addr                                   | 0          | 2          |            |
| backtrace:SYSC_newstat                                                           | 0          | 1          |            |
| BUG_fs_cache(Tainted:G_B):Poison_overwritten                                     | 0          | 1          |            |
| INFO:Allocated_in_copy_fs_struct_age=#cpu=#pid=                                  | 0          | 1          |            |
| backtrace:handle_mm_fault                                                        | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_unmapped_area_topdown_at_addr                        | 0          | 1          |            |
| INFO:Allocated_in__list_lru_init_age=#cpu=#pid=                                  | 0          | 1          |            |
| BUG:KASAN:use-after-free_in__vma_link_rb_at_addr                                 | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_vma_gap_callbacks_propagate_at_addr                  | 0          | 1          |            |
| backtrace:SyS_mknod                                                              | 0          | 1          |            |
| INFO:Allocated_in_kobject_uevent_env_age=#cpu=#pid=                              | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_free_pgtables_at_addr                                | 0          | 1          |            |
| BUG:KASAN:use-after-free_in_exit_mmap_at_addr                                    | 0          | 1          |            |
| BUG:kernel_test_oversize                                                         | 0          | 0          | 2          |
+----------------------------------------------------------------------------------+------------+------------+------------+


Here are the detailed Oops listing on this commit, with the trinity OOMs removed.

dmesg-quantal-ivb41-10:20160812160230:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  101.754306] init: Failed to create pty - disabling logging for job
[  101.860052] init: Temporary process spawn error: No such file or directory
[  101.939827] =============================================================================
[  101.943713] BUG anon_vma_chain (Not tainted): Poison overwritten
[  101.946151] -----------------------------------------------------------------------------
[  101.946151] 
[  101.956210] Disabling lock debugging due to kernel taint
[  101.961535] INFO: 0xffff88000922e9d5-0xffff88000922e9d7. First byte 0x1 instead of 0x6b
[  101.968051] INFO: Allocated in anon_vma_clone+0x9f/0x375 age=536 cpu=0 pid=253
[  102.012093] INFO: Freed in qlist_free_all+0x33/0xac age=59 cpu=0 pid=255
[  102.073932] INFO: Slab 0xffffea0000248b80 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  102.084787] INFO: Object 0xffff88000922e9c8 @offset=2504 fp=0xffff88000922f388
[  102.084787] 
[  102.095451] Redzone ffff88000922e9c0: bb bb bb bb bb bb bb bb                          ........
[  102.103305] Object ffff88000922e9c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 40 82  kkkkkkkkkkkkk.@.
[  102.111187] Object ffff88000922e9d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  102.119169] Object ffff88000922e9e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  102.127071] Object ffff88000922e9f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  102.138649] Redzone ffff88000922ea08: bb bb bb bb bb bb bb bb                          ........
[  102.142155] Padding ffff88000922eb54: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  102.145703] CPU: 0 PID: 255 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  102.149473] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  102.154920]  0000000000000000 ffff88000a2a79d8 ffffffff81c91ab5 ffff88000a2a7a08
[  102.158925]  ffffffff81330f07 ffff88000922e9d5 000000000000006b ffff8800110131c0
[  102.162965]  ffff88000922e9d7 ffff88000a2a7a58 ffffffff81330fac ffffffff83592f26
[  102.166534] Call Trace:
[  102.167926]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  102.169917]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  102.172282]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  102.174549]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  102.176815]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  102.180023]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  102.182520]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  102.184919]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  102.187331]  [<ffffffff81334818>] ? kasan_unpoison_shadow+0x14/0x35
[  102.189613]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  102.191936]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  102.194468]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  102.197302]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  102.200729]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  102.203125]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  102.205249]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  102.207331]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  102.209633]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  102.212180]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  102.214374]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  102.216708]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  102.219151]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  102.221418]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  102.223830]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  102.225997]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  102.228515]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  102.230565]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  102.232791]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  102.235308]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  102.237796] FIX anon_vma_chain: Restoring 0xffff88000922e9d5-0xffff88000922e9d7=0x6b

dmesg-quantal-ivb41-129:20160812160254:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  111.625693] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[  111.625717] power_supply test_usb: prop ONLINE=1
[  113.494934] =============================================================================
[  113.494939] BUG kmalloc-64 (Not tainted): Poison overwritten
[  113.494940] -----------------------------------------------------------------------------
[  113.494940] 
[  113.494941] Disabling lock debugging due to kernel taint
[  113.494944] INFO: 0xffff88000a70b535-0xffff88000a70b537. First byte 0x1 instead of 0x6b
[  113.494953] INFO: Allocated in kernfs_fop_open+0x6fb/0x840 age=153 cpu=0 pid=246
[  113.494993] INFO: Freed in qlist_free_all+0x33/0xac age=86 cpu=0 pid=238
[  113.495036] INFO: Slab 0xffffea000029c280 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  113.495039] INFO: Object 0xffff88000a70b528 @offset=5416 fp=0xffff88000a70a828
[  113.495039] 
[  113.495043] Redzone ffff88000a70b520: bb bb bb bb bb bb bb bb                          ........
[  113.495046] Object ffff88000a70b528: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 a0 c9  kkkkkkkkkkkkk...
[  113.495049] Object ffff88000a70b538: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  113.495052] Object ffff88000a70b548: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  113.495054] Object ffff88000a70b558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  113.495057] Redzone ffff88000a70b568: bb bb bb bb bb bb bb bb                          ........
[  113.495060] Padding ffff88000a70b6b4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  113.495064] CPU: 0 PID: 238 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  113.495066] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  113.495071]  0000000000000000 ffff88000adc77d8 ffffffff81c91ab5 ffff88000adc7808
[  113.495075]  ffffffff81330f07 ffff88000a70b535 000000000000006b ffff8800110036c0
[  113.495079]  ffff88000a70b537 ffff88000adc7858 ffffffff81330fac ffffffff83592f26
[  113.495079] Call Trace:
[  113.495084]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  113.495088]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  113.495091]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  113.495094]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  113.495098]  [<ffffffff81425fc3>] ? kernfs_fop_open+0x6fb/0x840
[  113.495101]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  113.495104]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  113.495108]  [<ffffffff81334595>] ? kasan_poison_shadow+0x2f/0x31
[  113.495111]  [<ffffffff81425fc3>] ? kernfs_fop_open+0x6fb/0x840
[  113.495116]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  113.495119]  [<ffffffff81425fc3>] ? kernfs_fop_open+0x6fb/0x840
[  113.495123]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  113.495126]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  113.495129]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  113.495133]  [<ffffffff81425fc3>] kernfs_fop_open+0x6fb/0x840
[  113.495136]  [<ffffffff81342aed>] do_dentry_open+0x361/0x6fe
[  113.495140]  [<ffffffff814258c8>] ? kernfs_fop_read+0x3ab/0x3ab
[  113.495143]  [<ffffffff813442fd>] vfs_open+0x179/0x186
[  113.495156]  [<ffffffff81363618>] path_openat+0x198c/0x1c58
[  113.495161]  [<ffffffff81d05cc7>] ? depot_save_stack+0x13c/0x390
[  113.495164]  [<ffffffff813347b1>] ? save_stack+0xc4/0xce
[  113.495167]  [<ffffffff81361c8c>] ? filename_mountpoint+0x17e/0x17e

dmesg-quantal-ivb41-16:20160812160241:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  105.110247] init: Failed to create pty - disabling logging for job
[  105.110381] init: Temporary process spawn error: No such file or directory
[  106.640168] =============================================================================
[  106.640172] BUG anon_vma_chain (Not tainted): Poison overwritten
[  106.640174] -----------------------------------------------------------------------------
[  106.640174] 
[  106.640174] Disabling lock debugging due to kernel taint
[  106.640178] INFO: 0xffff880008d8eb75-0xffff880008d8eb77. First byte 0x1 instead of 0x6b
[  106.640187] INFO: Allocated in anon_vma_prepare+0x6b/0x2db age=138 cpu=0 pid=415
[  106.640223] INFO: Freed in qlist_free_all+0x33/0xac age=26 cpu=0 pid=239
[  106.640269] INFO: Slab 0xffffea0000236380 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  106.640271] INFO: Object 0xffff880008d8eb68 @offset=2920 fp=0xffff880008d8f528
[  106.640271] 
[  106.640275] Redzone ffff880008d8eb60: bb bb bb bb bb bb bb bb                          ........
[  106.640278] Object ffff880008d8eb68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 c0 90  kkkkkkkkkkkkk...
[  106.640281] Object ffff880008d8eb78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  106.640284] Object ffff880008d8eb88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  106.640287] Object ffff880008d8eb98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  106.640289] Redzone ffff880008d8eba8: bb bb bb bb bb bb bb bb                          ........
[  106.640292] Padding ffff880008d8ecf4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  106.640296] CPU: 0 PID: 398 Comm: ifup Tainted: G    B           4.7.0-05999-g80a9201 #1
[  106.640298] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  106.640304]  0000000000000000 ffff8800088bf6d8 ffffffff81c91ab5 ffff8800088bf708
[  106.640308]  ffffffff81330f07 ffff880008d8eb75 000000000000006b ffff8800110131c0
[  106.640311]  ffff880008d8eb77 ffff8800088bf758 ffffffff81330fac ffffffff83592f26
[  106.640312] Call Trace:
[  106.640317]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  106.640321]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  106.640324]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  106.640327]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  106.640330]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  106.640334]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  106.640338]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  106.640340]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  106.640343]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  106.640347]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  106.640350]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  106.640353]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  106.640356]  [<ffffffff813153ea>] anon_vma_prepare+0x6b/0x2db
[  106.640360]  [<ffffffff81304113>] handle_mm_fault+0xcf6/0x11bb
[  106.640363]  [<ffffffff8130341d>] ? apply_to_page_range+0x2fb/0x2fb
[  106.640367]  [<ffffffff8130e21e>] ? SyS_munmap+0x81/0x81
[  106.640372]  [<ffffffff810e82be>] ? arch_get_unmapped_area+0x39c/0x39c

dmesg-quantal-ivb41-26:20160812160257:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  111.995978] init: Failed to create pty - disabling logging for job
[  111.996117] init: Temporary process spawn error: No such file or directory
[  114.698502] =============================================================================
[  114.698515] BUG vm_area_struct (Not tainted): Poison overwritten
[  114.698516] -----------------------------------------------------------------------------
[  114.698516] 
[  114.698517] Disabling lock debugging due to kernel taint
[  114.698521] INFO: 0xffff880008488a8c-0xffff880008488a8f. First byte 0x6a instead of 0x6b
[  114.698579] INFO: Allocated in copy_process+0x2323/0x424c age=107 cpu=0 pid=419
[  114.698676] INFO: Freed in qlist_free_all+0x33/0xac age=11 cpu=0 pid=263
[  114.698730] INFO: Slab 0xffffea0000212200 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  114.698733] INFO: Object 0xffff880008488a80 @offset=2688 fp=0xffff880008488220
[  114.698733] 
[  114.698742] Redzone ffff880008488a78: bb bb bb bb bb bb bb bb                          ........
[  114.698747] Object ffff880008488a80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6a 01 80 e4  kkkkkkkkkkkkj...
[  114.698749] Object ffff880008488a90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  114.698752] Object ffff880008488aa0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-quantal-ivb41-42:20160812160302:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  106.294052] init: Failed to create pty - disabling logging for job
[  106.294199] init: Temporary process spawn error: No such file or directory
[  107.451301] =============================================================================
[  107.451306] BUG vm_area_struct (Not tainted): Poison overwritten
[  107.451307] -----------------------------------------------------------------------------
[  107.451307] 
[  107.451308] Disabling lock debugging due to kernel taint
[  107.451312] INFO: 0xffff88000914665c-0xffff88000914665f. First byte 0x6a instead of 0x6b
[  107.451321] INFO: Allocated in copy_process+0x2323/0x424c age=140 cpu=0 pid=1
[  107.451353] INFO: Freed in qlist_free_all+0x33/0xac age=67 cpu=0 pid=261
[  107.451397] INFO: Slab 0xffffea0000245180 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  107.451399] INFO: Object 0xffff880009146650 @offset=1616 fp=0xffff880009147d58
[  107.451399] 
[  107.451403] Redzone ffff880009146648: bb bb bb bb bb bb bb bb                          ........
[  107.451406] Object ffff880009146650: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6a 01 e0 e5  kkkkkkkkkkkkj...
[  107.451409] Object ffff880009146660: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  107.451411] Object ffff880009146670: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-quantal-ivb41-52:20160812160241:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  106.678891] irda_setsockopt: not allowed to set MAXSDUSIZE for this socket type!
[  106.749546] power_supply test_ac: prop ONLINE=1
[  107.430823] =============================================================================
[  107.434407] BUG vm_area_struct (Not tainted): Poison overwritten
[  107.436760] -----------------------------------------------------------------------------
[  107.436760] 
[  107.449972] Disabling lock debugging due to kernel taint
[  107.452404] INFO: 0xffff880009bd2874-0xffff880009bd2877. First byte 0x6a instead of 0x6b
[  107.456114] INFO: Allocated in mmap_region+0x33a/0xa41 age=359 cpu=0 pid=440
[  107.500267] INFO: Freed in qlist_free_all+0x33/0xac age=58 cpu=0 pid=264
[  107.547459] INFO: Slab 0xffffea000026f480 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  107.551406] INFO: Object 0xffff880009bd2868 @offset=2152 fp=0xffff880009bd3928
[  107.551406] 
[  107.562146] Redzone ffff880009bd2860: bb bb bb bb bb bb bb bb                          ........
[  107.565909] Object ffff880009bd2868: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6a 01 80 fc  kkkkkkkkkkkkj...
[  107.573610] Object ffff880009bd2878: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  107.576946] Object ffff880009bd2888: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-quantal-ivb41-71:20160812160239:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  103.201437] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[  103.201462] power_supply test_usb: prop ONLINE=1
[  104.201388] =============================================================================
[  104.201393] BUG skbuff_head_cache (Not tainted): Poison overwritten
[  104.201394] -----------------------------------------------------------------------------
[  104.201394] 
[  104.201395] Disabling lock debugging due to kernel taint
[  104.201397] INFO: 0xffff88000a459b8c-0xffff88000a459b8f. First byte 0x6d instead of 0x6b
[  104.201406] INFO: Allocated in __alloc_skb+0xad/0x498 age=169 cpu=0 pid=1
[  104.201451] INFO: Freed in qlist_free_all+0x33/0xac age=13 cpu=0 pid=254
[  104.201493] INFO: Slab 0xffffea0000291600 objects=10 used=10 fp=0x          (null) flags=0x4000000000004080
[  104.201495] INFO: Object 0xffff88000a459b80 @offset=7040 fp=0xffff88000a458980
[  104.201495] 
[  104.201500] Redzone ffff88000a459b00: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.201503] Redzone ffff88000a459b10: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.201506] Redzone ffff88000a459b20: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.201508] Redzone ffff88000a459b30: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.201511] Redzone ffff88000a459b40: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.201513] Redzone ffff88000a459b50: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.201516] Redzone ffff88000a459b60: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.201519] Redzone ffff88000a459b70: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.201521] Object ffff88000a459b80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6d 01 e0 af  kkkkkkkkkkkkm...
[  104.201524] Object ffff88000a459b90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  104.201527] Object ffff88000a459ba0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-quantal-ivb41-96:20160812160242:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

udevd[310]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:v00001234d00001111sv00001AF4sd00001100bc03sc00i00': No such file or directory
udevd[358]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv dmi:bvnSeaBIOS:bvrDebian-1.8.2-1:bd04/01/2014:svnQEMU:pnStandardPC(i440FX+PIIX,1996):pvrpc-i440fx-2.4:cvnQEMU:ct1:cvrpc-i440fx-2.4:': No such file or directory
[  110.688412] =============================================================================
[  110.692354] BUG names_cache (Not tainted): Poison overwritten
[  110.694901] -----------------------------------------------------------------------------
[  110.694901] 
[  110.699914] Disabling lock debugging due to kernel taint
[  110.702057] INFO: 0xffff880009a4b58c-0xffff880009a4b58f. First byte 0x69 instead of 0x6b
[  110.705346] INFO: Allocated in getname_flags+0x5a/0x35c age=85 cpu=0 pid=253
[  110.727505] INFO: Freed in qlist_free_all+0x33/0xac age=8 cpu=0 pid=1
[  110.766664] INFO: Slab 0xffffea0000269200 objects=7 used=7 fp=0x          (null) flags=0x4000000000004080
[  110.770745] INFO: Object 0xffff880009a4b580 @offset=13696 fp=0xffff880009a4c740
[  110.770745] 
[  110.777537] Redzone ffff880009a4b540: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  110.789632] Redzone ffff880009a4b550: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  110.805843] Redzone ffff880009a4b560: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  110.809851] Redzone ffff880009a4b570: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  110.813955] Object ffff880009a4b580: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 69 01 00 a7  kkkkkkkkkkkki...
[  110.818081] Object ffff880009a4b590: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  110.825439] Object ffff880009a4b5a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-vm-ivb41-quantal-x86_64-14:20160812160512:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

udevd[350]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv input:b0011v0001p0001eAB41-e0,1,4,11,14,k71,72,73,74,75,76,77,79,7A,7B,7C,7D,7E,7F,80,8C,8E,8F,9B,9C,9D,9E,9F,A3,A4,A5,A6,AC,AD,B7,B8,B9,D9,E2,ram4,l0,1,2,sfw': No such file or directory
udevd[349]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:PNP0F13:': No such file or directory
[   72.009404] =============================================================================
[   72.012878] BUG kmalloc-512 (Not tainted): Poison overwritten
[   72.015063] -----------------------------------------------------------------------------
[   72.015063] 
[   72.019443] Disabling lock debugging due to kernel taint
[   72.021499] INFO: 0xffff880017642a35-0xffff880017642a37. First byte 0x1 instead of 0x6b
[   72.037465] INFO: Allocated in load_elf_phdrs+0x9a/0xf4 age=169 cpu=0 pid=356
[   72.065799] INFO: Freed in qlist_free_all+0x33/0xac age=67 cpu=0 pid=265
[   72.121094] INFO: Slab 0xffffea00005d9080 objects=9 used=9 fp=0x          (null) flags=0x4000000000004080
[   72.125452] INFO: Object 0xffff880017642a28 @offset=2600 fp=0x          (null)
[   72.125452] 
[   72.130200] Redzone ffff880017642a20: bb bb bb bb bb bb bb bb                          ........
[   72.134294] Object ffff880017642a28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 80 b1  kkkkkkkkkkkkk...
[   72.138544] Object ffff880017642a38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   72.142802] Object ffff880017642a48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-vm-ivb41-quantal-x86_64-1:20160812160325:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[   75.545932] ipconfig: ipddp0: socket(AF_INET): Address family not supported by protocol
[   75.551674] ipconfig: no devices to configure
[   75.558551] /usr/share/initramfs-tools/scripts/functions: line 491: /run/net-eth0.conf: No such file or directory
!!! IP-Config: Auto-configuration of network failed !!!
[   75.860942] !!! IP-Config: Auto-configuration of network failed !!!
error: 'rc.local' exited outside the expected code flow.
[   75.931858] init: Failed to create pty - disabling logging for job
[   75.933512] init: Temporary process spawn error: No such file or directory

dmesg-yocto-ivb41-105:20160812160231:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  106.928062] blk_update_request: I/O error, dev fd0, sector 0
[  106.929740] floppy: error -5 while reading block 0
[  107.012218] =============================================================================
[  107.019136] BUG kmalloc-256 (Not tainted): Poison overwritten
[  107.020787] -----------------------------------------------------------------------------
[  107.020787] 
[  107.024336] Disabling lock debugging due to kernel taint
[  107.025926] INFO: 0xffff880008ca2e54-0xffff880008ca2e57. First byte 0x6c instead of 0x6b
[  107.028595] INFO: Allocated in do_execveat_common+0x268/0x11d2 age=281 cpu=0 pid=352
[  107.076371] INFO: Freed in qlist_free_all+0x33/0xac age=227 cpu=0 pid=291
[  107.149193] INFO: Slab 0xffffea0000232880 objects=13 used=13 fp=0x          (null) flags=0x4000000000004080
[  107.167264] INFO: Object 0xffff880008ca2e48 @offset=3656 fp=0xffff880008ca3c88
[  107.167264] 
[  107.170622] Redzone ffff880008ca2e40: bb bb bb bb bb bb bb bb                          ........
[  107.173376] Object ffff880008ca2e48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 00 ae  kkkkkkkkkkkkl...
[  107.195350] Object ffff880008ca2e58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  107.198226] Object ffff880008ca2e68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-108:20160812160251:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  110.935770] ==================================================================
[  110.938593] BUG: KASAN: use-after-free in vma_interval_tree_compute_subtree_last+0x5f/0xcc at addr ffff8800087f4f20
[  110.941666] Read of size 8 by task udevd/440
[  110.956256] CPU: 0 PID: 440 Comm: udevd Not tainted 4.7.0-05999-g80a9201 #1
[  110.958363] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  110.961354]  0000000000000000 ffff880008bbf680 ffffffff81c91ab5 ffff880008bbf6f8
[  110.964325]  ffffffff8133576b ffffffff812f6c1b 0000000000000246 000000010013000b
[  110.967282]  0000000000000246 0000000000000000 ffff880008bbf7e0 ffffffff812ff9dc
[  110.970325] Call Trace:
[  110.971562]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  110.973253]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  110.975079]  [<ffffffff812f6c1b>] ? vma_interval_tree_compute_subtree_last+0x5f/0xcc
[  110.977922]  [<ffffffff812ff9dc>] ? unmap_page_range+0x4f5/0x949
[  110.979838]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  110.981848]  [<ffffffff812f6c1b>] vma_interval_tree_compute_subtree_last+0x5f/0xcc
[  110.984734]  [<ffffffff812f6cb1>] vma_interval_tree_augment_propagate+0x29/0x75
[  110.987552]  [<ffffffff812f78b3>] vma_interval_tree_remove+0x5e2/0x608
[  110.989359]  [<ffffffff81307c85>] __remove_shared_vm_struct+0x7b/0x82
[  110.991151]  [<ffffffff81309084>] unlink_file_vma+0x82/0x93
[  110.992789]  [<ffffffff812fe80c>] free_pgtables+0xf0/0x13e
[  110.994416]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  110.995989]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  110.997715]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  110.999554]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  111.001251]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  111.002907]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[  111.004747]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[  111.006622]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  111.008547]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  111.010493]  [<ffffffff813e11b4>] load_script+0x4b8/0x506
[  111.012285]  [<ffffffff813e0cfc>] ? compat_SyS_ioctl+0x184d/0x184d
[  111.043190]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  111.044879]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  111.046565]  [<ffffffff81351535>] ? copy_strings+0x467/0x52d
[  111.061417]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  111.063414]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  111.065464]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  111.067347]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  111.069035]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  111.070721]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  111.072417]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  111.073977]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  111.088763]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  111.090635]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  111.092428]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  111.094213] Object at ffff8800087f4eb0, in cache vm_area_struct
[  111.095899] Object allocated with size 184 bytes.
[  111.097396] Allocation:
[  111.098505] PID = 307
[  111.099587]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  111.108858]  [<ffffffff81334733>] save_stack+0x46/0xce
[  111.110727]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  111.112645]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  111.114589]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  111.116633]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  111.118546]  [<ffffffff811a9b50>] copy_process+0x2323/0x424c
[  111.134489]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  111.136389]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  111.138219]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  111.140170]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  111.142225] Memory state around the buggy address:
[  111.143913]  ffff8800087f4e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-111:20160812160248:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

Starting udev
[  112.488293] power_supply test_ac: uevent
** 127 printk messages dropped ** 
[  112.617229]  [<ffffffff811aa2f2>] copy_process+0x2ac5/0x424c
[  112.617233]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  112.617236]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  112.617239]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
** 222 printk messages dropped ** 
[  112.617893]  [<ffffffff811ade96>] ? task_stopped_code+0xcb/0xcb
** 1244 printk messages dropped ** 

dmesg-yocto-ivb41-115:20160812160246:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  112.596067] =============================================================================
[  112.598922] BUG names_cache (Not tainted): Poison overwritten
[  112.600657] -----------------------------------------------------------------------------
[  112.600657] 
[  112.618436] Disabling lock debugging due to kernel taint
[  112.620090] INFO: 0xffff880009bea3cc-0xffff880009bea3cf. First byte 0x6e instead of 0x6b
[  112.622909] INFO: Allocated in getname_flags+0x5a/0x35c age=71 cpu=0 pid=285
[  112.657427] INFO: Freed in qlist_free_all+0x33/0xac age=1 cpu=0 pid=452
[  112.705095] INFO: Slab 0xffffea000026fa00 objects=7 used=7 fp=0x          (null) flags=0x4000000000004080
[  112.708087] INFO: Object 0xffff880009bea3c0 @offset=9152 fp=0x          (null)
[  112.708087] 
[  112.724701] Redzone ffff880009bea380: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  112.756566] Redzone ffff880009bea390: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  112.759561] Redzone ffff880009bea3a0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  112.775649] Redzone ffff880009bea3b0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  112.778746] Object ffff880009bea3c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6e 01 40 d5  kkkkkkkkkkkkn.@.
[  112.781743] Object ffff880009bea3d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  112.784844] Object ffff880009bea3e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-122:20160812160234:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  103.749230] power_supply test_battery: prop MANUFACTURER=Linux
[  104.141979] power_supply test_battery: prop SERIAL_NUMBER=4.7.0-05999-g80a9201
[  104.484013] =============================================================================
[  104.484018] BUG names_cache (Not tainted): Poison overwritten
[  104.484019] -----------------------------------------------------------------------------
[  104.484019] 
[  104.484020] Disabling lock debugging due to kernel taint
[  104.484023] INFO: 0xffff880007f3474d-0xffff880007f3474f. First byte 0x1 instead of 0x6b
[  104.484032] INFO: Allocated in getname_flags+0x5a/0x35c age=155 cpu=0 pid=529
[  104.484064] INFO: Freed in qlist_free_all+0x33/0xac age=16 cpu=0 pid=592
[  104.484104] INFO: Slab 0xffffea00001fcc00 objects=7 used=7 fp=0x          (null) flags=0x4000000000004080
[  104.484106] INFO: Object 0xffff880007f34740 @offset=18240 fp=0x          (null)
[  104.484106] 
[  104.484111] Redzone ffff880007f34700: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.484114] Redzone ffff880007f34710: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.484117] Redzone ffff880007f34720: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.484120] Redzone ffff880007f34730: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  104.484122] Object ffff880007f34740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 60 f7  kkkkkkkkkkkkk.`.
[  104.484125] Object ffff880007f34750: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  104.484128] Object ffff880007f34760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-132:20160812160253:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  112.029713] ==================================================================
[  112.032515] BUG: KASAN: use-after-free in __rb_insert_augmented+0x343/0x59f at addr ffff8800090af768
[  112.035635] Read of size 8 by task mount.sh/466
[  112.037302] CPU: 0 PID: 466 Comm: mount.sh Not tainted 4.7.0-05999-g80a9201 #1
[  112.039950] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  112.043015]  0000000000000000 ffff88000806fb58 ffffffff81c91ab5 ffff88000806fbd0
[  112.046337]  ffffffff8133576b ffffffff81c9eeac 0000000000000246 ffff8800081d5b88
[  112.049624]  ffff88000806fbc0 ffffffff81334d14 024000c0081d44e8 0000000000000001
[  112.055593] Call Trace:
[  112.056850]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  112.061900]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  112.063705]  [<ffffffff81c9eeac>] ? __rb_insert_augmented+0x343/0x59f
[  112.065686]  [<ffffffff81334d14>] ? kasan_kmalloc+0xb7/0xc6
[  112.072750]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  112.074793]  [<ffffffff81c9eeac>] __rb_insert_augmented+0x343/0x59f
[  112.076784]  [<ffffffff812f6cfd>] ? vma_interval_tree_augment_propagate+0x75/0x75
[  112.079403]  [<ffffffff812f7c25>] vma_interval_tree_insert_after+0x1b6/0x1c3
[  112.081516]  [<ffffffff811a9e51>] copy_process+0x2624/0x424c
[  112.083461]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  112.085280]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  112.087025]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  112.088807]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  112.090562]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  112.092348]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  112.094270]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  112.096169]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  112.098134]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  112.099854]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  112.101750]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  112.103686]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  112.105501] Object at ffff8800090af710, in cache vm_area_struct
[  112.107338] Object allocated with size 184 bytes.
[  112.110479] Allocation:
[  112.111710] PID = 458
[  112.112890]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  112.114854]  [<ffffffff81334733>] save_stack+0x46/0xce
[  112.116744]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  112.118671]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  112.122769]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  112.124716]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  112.143510]  [<ffffffff811a9b50>] copy_process+0x2323/0x424c
[  112.145784]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  112.147724]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  112.149579]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  112.151508]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  112.153543] Memory state around the buggy address:
[  112.155232]  ffff8800090af600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-133:20160812160230:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  106.248948] ==================================================================
[  106.251786] BUG: KASAN: use-after-free in get_page_from_freelist+0x49/0xb73 at addr ffff88000840fa40
[  106.272766] Read of size 8 by task expr/528
[  106.274336] page:ffffea00002103c0 count:0 mapcount:0 mapping:          (null) index:0x0
[  106.277274] flags: 0x4000000000000000()
[  106.278619] page dumped because: kasan: bad access detected
[  106.280250] CPU: 0 PID: 528 Comm: expr Not tainted 4.7.0-05999-g80a9201 #1
[  106.282090] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  106.284933]  0000000000000000 ffff88000840f778 ffffffff81c91ab5 ffff88000840f7f0
[  106.301199]  ffffffff8133585b ffffffff812c89be 0000000000000246 0000000000000001
[  106.304352]  ffffffff83e63818 0000000000000000 ffffea00000fbc60 0000000000000000
[  106.307318] Call Trace:
[  106.308442]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  106.310001]  [<ffffffff8133585b>] kasan_report+0x409/0x553
[  106.324707]  [<ffffffff812c89be>] ? get_page_from_freelist+0x49/0xb73
[  106.326679]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  106.328639]  [<ffffffff812c89be>] get_page_from_freelist+0x49/0xb73
[  106.330529]  [<ffffffff812c7e42>] ? __rmqueue+0x7f/0x32f
[  106.332117]  [<ffffffff812ca07d>] __alloc_pages_nodemask+0x2b8/0x1199
[  106.333907]  [<ffffffff812c91dd>] ? get_page_from_freelist+0x868/0xb73
[  106.335699]  [<ffffffff812c9dc5>] ? gfp_pfmemalloc_allowed+0x11/0x11
[  106.350531]  [<ffffffff8133499c>] ? kasan_alloc_pages+0x39/0x3b

dmesg-yocto-ivb41-135:20160812160229:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  105.892255] =============================================================================
[  105.901019] BUG kmalloc-128 (Not tainted): Poison overwritten
[  105.902922] -----------------------------------------------------------------------------
[  105.902922] 
[  105.906433] Disabling lock debugging due to kernel taint
[  105.914324] INFO: 0xffff88000845f5b4-0xffff88000845f5b7. First byte 0x6d instead of 0x6b
[  105.919465] INFO: Allocated in kzalloc+0xe/0x10 age=148 cpu=0 pid=268
[  105.962987] INFO: Freed in qlist_free_all+0x33/0xac age=97 cpu=0 pid=470
[  106.001540] INFO: Slab 0xffffea00002117c0 objects=8 used=8 fp=0x          (null) flags=0x4000000000000080
[  106.012655] INFO: Object 0xffff88000845f5a8 @offset=1448 fp=0xffff88000845f008
[  106.012655] 
[  106.016241] Redzone ffff88000845f5a0: bb bb bb bb bb bb bb bb                          ........
[  106.055850] Object ffff88000845f5a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6d 01 60 e2  kkkkkkkkkkkkm.`.
[  106.058718] Object ffff88000845f5b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  106.070047] Object ffff88000845f5c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-13:20160812160250:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  107.789093] power_supply test_ac: uevent
[  107.879899] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  108.143440] =============================================================================
[  108.143454] BUG anon_vma_chain (Not tainted): Poison overwritten
[  108.143456] -----------------------------------------------------------------------------
[  108.143456] 
[  108.143460] Disabling lock debugging due to kernel taint
[  108.143465] INFO: 0xffff8800081d5054-0xffff8800081d5057. First byte 0x6c instead of 0x6b
[  108.143524] INFO: Allocated in anon_vma_clone+0x9f/0x375 age=80 cpu=0 pid=297
[  108.143620] INFO: Freed in qlist_free_all+0x33/0xac age=23 cpu=0 pid=394
[  108.143673] INFO: Slab 0xffffea0000207500 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  108.143675] INFO: Object 0xffff8800081d5048 @offset=4168 fp=0xffff8800081d56c8
[  108.143675] 
[  108.143680] Redzone ffff8800081d5040: bb bb bb bb bb bb bb bb                          ........
[  108.143683] Object ffff8800081d5048: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 a0 88  kkkkkkkkkkkkl...
[  108.143685] Object ffff8800081d5058: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  108.143688] Object ffff8800081d5068: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  108.143691] Object ffff8800081d5078: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  108.143693] Redzone ffff8800081d5088: bb bb bb bb bb bb bb bb                          ........
[  108.143696] Padding ffff8800081d51d4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  108.143712] CPU: 0 PID: 385 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  108.143714] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  108.143734]  0000000000000000 ffff880009b2f9d8 ffffffff81c91ab5 ffff880009b2fa08
[  108.143738]  ffffffff81330f07 ffff8800081d5054 000000000000006b ffff88000c4131c0
[  108.143742]  ffff8800081d5057 ffff880009b2fa58 ffffffff81330fac ffffffff83592f26
[  108.143743] Call Trace:
[  108.143771]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  108.143775]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  108.143779]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  108.143782]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  108.143785]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  108.143789]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  108.143793]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  108.143802]  [<ffffffff812f6e90>] ? __anon_vma_interval_tree_compute_subtree_last+0x31/0xec
[  108.143805]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  108.143809]  [<ffffffff812f7027>] ? __anon_vma_interval_tree_augment_rotate+0x67/0x74
[  108.143817]  [<ffffffff81c9f0f9>] ? __rb_insert_augmented+0x590/0x59f
[  108.143820]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  108.143824]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  108.143828]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  108.143831]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  108.143834]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  108.143837]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  108.143846]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  108.143850]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  108.143859]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  108.143870]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  108.143874]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  108.143878]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  108.143882]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  108.143897]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  108.143901]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  108.143904]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  108.143907]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  108.143918]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  108.143922]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  108.143925] FIX anon_vma_chain: Restoring 0xffff8800081d5054-0xffff8800081d5057=0x6b
[  108.143925] 
[  108.143927] FIX anon_vma_chain: Marking all objects used
[  109.387815] =============================================================================
[  109.387821] BUG anon_vma_chain (Tainted: G    B          ): Poison overwritten
[  109.387822] -----------------------------------------------------------------------------
[  109.387822] 
[  109.387825] INFO: 0xffff8800083a1534-0xffff8800083a1537. First byte 0x6c instead of 0x6b
[  109.387834] INFO: Allocated in anon_vma_fork+0xfa/0x3f9 age=225 cpu=0 pid=475
[  109.387869] INFO: Freed in qlist_free_all+0x33/0xac age=76 cpu=0 pid=499
[  109.400946] INFO: Slab 0xffffea000020e800 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  109.400949] INFO: Object 0xffff8800083a1528 @offset=5416 fp=0xffff8800083a0008
[  109.400949] 
[  109.400953] Redzone ffff8800083a1520: bb bb bb bb bb bb bb bb                          ........
[  109.400956] Object ffff8800083a1528: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 00 8a  kkkkkkkkkkkkl...
[  109.400958] Object ffff8800083a1538: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  109.400961] Object ffff8800083a1548: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  109.400964] Object ffff8800083a1558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  109.400966] Redzone ffff8800083a1568: bb bb bb bb bb bb bb bb                          ........
[  109.400969] Padding ffff8800083a16b4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  109.400975] CPU: 0 PID: 377 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  109.400977] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  109.400984]  0000000000000000 ffff8800082bf9d8 ffffffff81c91ab5 ffff8800082bfa08
[  109.400987]  ffffffff81330f07 ffff8800083a1534 000000000000006b ffff88000c4131c0
[  109.400990]  ffff8800083a1537 ffff8800082bfa58 ffffffff81330fac ffffffff83592f26
[  109.400991] Call Trace:
[  109.401001]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  109.401020]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  109.401025]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  109.401029]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  109.401033]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  109.401036]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  109.401041]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  109.401044]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  109.401055]  [<ffffffff81ccf700>] ? debug_smp_processor_id+0x17/0x19
[  109.401059]  [<ffffffff8133006c>] ? set_track+0xad/0xef
[  109.401062]  [<ffffffff81330693>] ? init_object+0x6f/0x76
[  109.401065]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  109.401070]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  109.401073]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  109.401076]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  109.401078]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  109.401080]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  109.401085]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  109.401088]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  109.401091]  [<ffffffff813345bf>] ? kasan_poison_slab_free+0x28/0x2a
[  109.401095]  [<ffffffff81334c54>] ? kasan_slab_free+0xa4/0xad
[  109.401099]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  109.401102]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  109.401108]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  109.401113]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  109.401116]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  109.401119]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  109.401122]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  109.401125]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  109.401129] FIX anon_vma_chain: Restoring 0xffff8800083a1534-0xffff8800083a1537=0x6b
[  109.401129] 
[  109.401131] FIX anon_vma_chain: Marking all objects used
[  109.696571] =============================================================================
[  109.696585] BUG kmalloc-128 (Tainted: G    B          ): Poison overwritten
[  109.696586] -----------------------------------------------------------------------------
[  109.696586] 
[  109.696589] INFO: 0xffff880007a353d4-0xffff880007a353d7. First byte 0x6d instead of 0x6b
[  109.696616] INFO: Allocated in kernfs_fop_open+0x24e/0x840 age=114 cpu=0 pid=268
[  109.696659] INFO: Freed in qlist_free_all+0x33/0xac age=9 cpu=0 pid=556
[  109.696712] INFO: Slab 0xffffea00001e8d40 objects=8 used=8 fp=0x          (null) flags=0x4000000000000080
[  109.696714] INFO: Object 0xffff880007a353c8 @offset=968 fp=0xffff880007a35968
[  109.696714] 
[  109.696719] Redzone ffff880007a353c0: bb bb bb bb bb bb bb bb                          ........
[  109.696726] Object ffff880007a353c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6d 01 60 e2  kkkkkkkkkkkkm.`.
[  109.696730] Object ffff880007a353d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  109.696732] Object ffff880007a353e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-140:20160812160234:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[   99.025341] ==================================================================
[   99.029234] BUG: KASAN: use-after-free in __rb_erase_color+0x39c/0x750 at addr ffff880008503548
[   99.032221] Read of size 8 by task udevd/441
[   99.033747] CPU: 0 PID: 441 Comm: udevd Not tainted 4.7.0-05999-g80a9201 #1
[   99.035882] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[   99.039123]  0000000000000000 ffff8800098a7680 ffffffff81c91ab5 ffff8800098a76f8
[   99.042648]  ffffffff8133576b ffffffff81c9d5e0 0000000000000246 ffff8800087fb6c8
[   99.046157]  ffff8800087fb6c8 ffff8800098a76d8 ffffffff812f6e90 ffff8800087fb6e8
[   99.049462] Call Trace:
[   99.050651]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[   99.052412]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[   99.054182]  [<ffffffff81c9d5e0>] ? __rb_erase_color+0x39c/0x750
[   99.056060]  [<ffffffff812f6e90>] ? __anon_vma_interval_tree_compute_subtree_last+0x31/0xec
[   99.059638]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[   99.062541]  [<ffffffff81c9d5e0>] __rb_erase_color+0x39c/0x750
[   99.064497]  [<ffffffff812f6fc0>] ? __anon_vma_interval_tree_augment_propagate+0x75/0x75
[   99.067659]  [<ffffffff812f8400>] anon_vma_interval_tree_remove+0x5f9/0x608
[   99.084915]  [<ffffffff81332d11>] ? kmem_cache_free+0x4b/0xbc
[   99.088206]  [<ffffffff8131573e>] unlink_anon_vmas+0xe4/0x3cd
[   99.092209]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[   99.096645]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[   99.101090]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[   99.103404]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[   99.107695]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[   99.111594]  [<ffffffff811a730e>] mmput+0x28/0x2b
[   99.114877]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[   99.119251]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[   99.121693]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[   99.126625]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[   99.130151]  [<ffffffff813e11b4>] load_script+0x4b8/0x506
[   99.134540]  [<ffffffff813e0cfc>] ? compat_SyS_ioctl+0x184d/0x184d
[   99.138134]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[   99.178921]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[   99.181706]  [<ffffffff81351535>] ? copy_strings+0x467/0x52d
[   99.185112]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[   99.187117]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[   99.189272]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[   99.191293]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[   99.193225]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[   99.195226]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[   99.197383]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[   99.199357]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[   99.201253]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[   99.203163]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[   99.205052]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[   99.207171] Object at ffff880008503528, in cache anon_vma_chain
[   99.209207] Object allocated with size 64 bytes.
[   99.210957] Allocation:
[   99.212242] PID = 346
[   99.213542]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[   99.215575]  [<ffffffff81334733>] save_stack+0x46/0xce
[   99.217407]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[   99.219304]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[   99.221219]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[   99.223271]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[   99.225461]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[   99.231484]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[   99.233584]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[   99.235765]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[   99.239723]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[   99.243423]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[   99.245166]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[   99.247008] Memory state around the buggy address:
[   99.248530]  ffff880008503400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-141:20160812160252:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  112.521858] power_supply test_battery: prop CHARGE_FULL=100
[  112.523800] power_supply test_battery: prop CHARGE_NOW=50
** 417 printk messages dropped ** 
[  112.555457]  [<ffffffff811a71bd>] __mmput+0x58/0x181
** 1037 printk messages dropped ** 
[  112.560606]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  112.560609]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  112.560612]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  112.560616]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  112.560620]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  112.560623]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  112.560626]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  112.560630]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  112.560634]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  112.560636] Object at ffff880008284b68, in cache anon_vma_chain
[  112.560637] Object allocated with size 64 bytes.
[  112.560637] Allocation:
[  112.560638] PID = 324
[  112.560643]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  112.560647]  [<ffffffff81334733>] save_stack+0x46/0xce
[  112.560650]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  112.560654]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  112.560658]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  112.560662]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  112.560665]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  112.560674]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  112.560679]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  112.560683]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  112.560687]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  112.560690]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  112.560694]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  112.560695] Memory state around the buggy address:
[  112.560698]  ffff880008284a80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-25:20160812160245:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  112.333339] blk_update_request: I/O error, dev fd0, sector 0
[  112.333343] floppy: error -5 while reading block 0
[  112.335668] =============================================================================
[  112.335673] BUG anon_vma_chain (Not tainted): Poison overwritten
[  112.335674] -----------------------------------------------------------------------------
[  112.335674] 
[  112.335675] Disabling lock debugging due to kernel taint
[  112.335678] INFO: 0xffff880007ba3a14-0xffff880007ba3a17. First byte 0x6c instead of 0x6b
[  112.335686] INFO: Allocated in anon_vma_fork+0xfa/0x3f9 age=254 cpu=0 pid=621
[  112.335720] INFO: Freed in qlist_free_all+0x33/0xac age=78 cpu=0 pid=681
[  112.335764] INFO: Slab 0xffffea00001ee880 objects=19 used=0 fp=0xffff880007ba3388 flags=0x4000000000004080
[  112.335767] INFO: Object 0xffff880007ba3a08 @offset=6664 fp=0xffff880007ba2348
[  112.335767] 
[  112.335771] Redzone ffff880007ba3a00: bb bb bb bb bb bb bb bb                          ........
[  112.335774] Object ffff880007ba3a08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 20 87  kkkkkkkkkkkkl. .
[  112.335777] Object ffff880007ba3a18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  112.335780] Object ffff880007ba3a28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  112.335782] Object ffff880007ba3a38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  112.335785] Redzone ffff880007ba3a48: bb bb bb bb bb bb bb bb                          ........
[  112.335788] Padding ffff880007ba3b94: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  112.335793] CPU: 0 PID: 268 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  112.335794] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  112.335800]  0000000000000000 ffff880008f87508 ffffffff81c91ab5 ffff880008f87538
[  112.335804]  ffffffff81330f07 ffff880007ba3a14 000000000000006b ffff88000c4131c0
[  112.335808]  ffff880007ba3a17 ffff880008f87588 ffffffff81330fac ffffffff83592f26
[  112.335809] Call Trace:
[  112.335814]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  112.335817]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  112.335821]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  112.335824]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  112.335827]  [<ffffffff81331b46>] __free_slab+0x12d/0x14d
[  112.335831]  [<ffffffff81331ba1>] discard_slab+0x3b/0x3d
[  112.335834]  [<ffffffff81332a9c>] __slab_free+0x268/0x27d
[  112.335837]  [<ffffffff81332cc3>] ___cache_free+0x69/0x6c
[  112.335840]  [<ffffffff81332cc3>] ? ___cache_free+0x69/0x6c
[  112.335844]  [<ffffffff81335bf5>] qlist_free_all+0x75/0xac
[  112.335847]  [<ffffffff81335f69>] quarantine_reduce+0x136/0x13d
[  112.335851]  [<ffffffff81334c85>] kasan_kmalloc+0x28/0xc6
[  112.335854]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  112.335857]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  112.335860]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  112.335863]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  112.335866]  [<ffffffff813153ea>] anon_vma_prepare+0x6b/0x2db
[  112.335870]  [<ffffffff81303aa0>] handle_mm_fault+0x683/0x11bb
[  112.335873]  [<ffffffff8133495c>] ? memcpy+0x45/0x4c
[  112.335876]  [<ffffffff8130341d>] ? apply_to_page_range+0x2fb/0x2fb
[  112.335880]  [<ffffffff81ca8d58>] ? num_to_str+0x198/0x198
[  112.335884]  [<ffffffff81332213>] ? ___slab_alloc+0x284/0x31e
[  112.335887]  [<ffffffff813348c4>] ? memset+0x31/0x38
[  112.335890]  [<ffffffff8130b86e>] ? find_vma+0xe1/0xef
[  112.335894]  [<ffffffff8111cf2b>] __do_page_fault+0x33e/0x624
[  112.335898]  [<ffffffff8111d254>] do_page_fault+0x22/0x27
[  112.335901]  [<ffffffff8111718c>] do_async_page_fault+0x2c/0x5e
[  112.335905]  [<ffffffff82c81918>] async_page_fault+0x28/0x30
[  112.335909]  [<ffffffff81cac165>] ? copy_user_enhanced_fast_string+0x5/0x10
[  112.335912]  [<ffffffff8138d32a>] ? seq_read+0xb1b/0xced
[  112.335916]  [<ffffffff8138c80f>] ? seq_open+0x162/0x162
[  112.335919]  [<ffffffff8130ac2e>] ? vma_set_page_prot+0x7d/0xcd
[  112.335923]  [<ffffffff8130ea36>] ? mmap_region+0x818/0xa41
[  112.335928]  [<ffffffff814255e9>] kernfs_fop_read+0xcc/0x3ab
[  112.335931]  [<ffffffff8130e21e>] ? SyS_munmap+0x81/0x81
[  112.335935]  [<ffffffff8134702f>] __vfs_read+0xf6/0x279
[  112.335939]  [<ffffffff81346f39>] ? do_sendfile+0x57d/0x57d
[  112.335942]  [<ffffffff8130b76b>] ? get_unmapped_area+0x24b/0x26d
[  112.335946]  [<ffffffff8130f24e>] ? do_mmap+0x5ef/0x66a
[  112.335949]  [<ffffffff8137fb67>] ? __fget_light+0x80/0xe3
[  112.335953]  [<ffffffff813472a3>] vfs_read+0xf1/0x177
[  112.335956]  [<ffffffff8134799c>] SyS_read+0xce/0x138
[  112.335960]  [<ffffffff813478ce>] ? vfs_write+0x187/0x187
[  112.335963]  [<ffffffff8130a8ff>] ? SyS_mmap_pgoff+0xee/0x119

dmesg-yocto-ivb41-27:20160812160241:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  112.251266] (mount,616,0):ocfs2_fill_super:1218 ERROR: status = -22
[  112.251726] gfs2: gfs2 mount does not exist
[  112.361473] ==================================================================
[  112.361484] BUG: KASAN: use-after-free in unlink_anon_vmas+0x63/0x3cd at addr ffff880008fe3a18
[  112.361487] Read of size 8 by task network.sh/644
[  112.361492] CPU: 0 PID: 644 Comm: network.sh Not tainted 4.7.0-05999-g80a9201 #1
[  112.361494] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  112.361500]  0000000000000000 ffff8800075c7b70 ffffffff81c91ab5 ffff8800075c7be8
[  112.361504]  ffffffff8133576b ffffffff813156bd 0000000000000246 ffff880007f5ddb0
[  112.361507]  ffff880007f5ddb0 ffff88000c0e15e0 ffff8800075c7bf8 ffffffff812f78b3
[  112.361508] Call Trace:
[  112.361514]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  112.361520]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  112.361523]  [<ffffffff813156bd>] ? unlink_anon_vmas+0x63/0x3cd
[  112.361528]  [<ffffffff812f78b3>] ? vma_interval_tree_remove+0x5e2/0x608
[  112.361532]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  112.361535]  [<ffffffff813156bd>] unlink_anon_vmas+0x63/0x3cd
[  112.361538]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[  112.361542]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  112.361545]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  112.361550]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  112.361554]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  112.361557]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  112.361561]  [<ffffffff811b1a0f>] do_exit+0x94f/0x19e0
[  112.361565]  [<ffffffff811b10c0>] ? is_current_pgrp_orphaned+0x96/0x96
[  112.361570]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  112.361574]  [<ffffffff811b2bc7>] do_group_exit+0xe8/0x227
[  112.361578]  [<ffffffff811b2d1e>] SyS_exit_group+0x18/0x18
[  112.361582]  [<ffffffff82c80673>] entry_SYSCALL_64_fastpath+0x1e/0xa8
[  112.361584] Object at ffff880008fe3a08, in cache anon_vma_chain
[  112.361585] Object allocated with size 64 bytes.
[  112.361586] Allocation:
[  112.361587] PID = 631
[  112.361593]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  112.361597]  [<ffffffff81334733>] save_stack+0x46/0xce
[  112.361601]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  112.361604]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  112.361608]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  112.361612]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  112.361615]  [<ffffffff81315e96>] anon_vma_fork+0xfa/0x3f9
[  112.361627]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  112.361631]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  112.361635]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  112.361639]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  112.361642]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  112.361643] Memory state around the buggy address:
[  112.361647]  ffff880008fe3900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-39:20160812160255:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  110.770817] =============================================================================
[  110.774948] BUG vm_area_struct (Not tainted): Poison overwritten
[  110.776817] -----------------------------------------------------------------------------
[  110.776817] 
[  110.780810] Disabling lock debugging due to kernel taint
[  110.782629] INFO: 0xffff880009b1fd64-0xffff880009b1fd67. First byte 0x6c instead of 0x6b
[  110.785756] INFO: Allocated in copy_process+0x2323/0x424c age=32 cpu=0 pid=298
[  110.805227] INFO: Freed in qlist_free_all+0x33/0xac age=2 cpu=0 pid=275
[  110.826923] INFO: Slab 0xffffea000026c780 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  110.830290] INFO: Object 0xffff880009b1fd58 @offset=7512 fp=0xffff880009b1eeb0
[  110.830290] 
[  110.834146] Redzone ffff880009b1fd50: bb bb bb bb bb bb bb bb                          ........
[  110.838695] Object ffff880009b1fd58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 40 8b  kkkkkkkkkkkkl.@.
[  110.841959] Object ffff880009b1fd68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  110.852019] Object ffff880009b1fd78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-40:20160812160237:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

** 125 printk messages dropped ** 
[  104.030368]  0000000000000000 ffff8800082e7a78 ffffffff81c91ab5 ffff8800082e7af0
** 261 printk messages dropped ** 
[  104.031083]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  104.031086]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  104.031089]  [<ffffffff811b1a0f>] do_exit+0x94f/0x19e0
[  104.031093]  [<ffffffff811b10c0>] ? is_current_pgrp_orphaned+0x96/0x96
[  104.031096]  [<ffffffff813450ad>] ? fdput_pos+0x22/0x26
[  104.031100]  [<ffffffff81347b11>] ? SyS_write+0x10b/0x138
[  104.031103]  [<ffffffff811b2bc7>] do_group_exit+0xe8/0x227
[  104.031107]  [<ffffffff811b2d1e>] SyS_exit_group+0x18/0x18
[  104.031110]  [<ffffffff82c80673>] entry_SYSCALL_64_fastpath+0x1e/0xa8
[  104.031111] Memory state around the buggy address:

dmesg-yocto-ivb41-41:20160812160252:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  110.992029] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  110.992055] power_supply test_ac: prop ONLINE=1
[  111.045537] =============================================================================
[  111.045548] BUG vm_area_struct (Not tainted): Poison overwritten
[  111.045550] -----------------------------------------------------------------------------
[  111.045550] 
[  111.045551] Disabling lock debugging due to kernel taint
[  111.045555] INFO: 0xffff880008b66ca4-0xffff880008b66ca7. First byte 0x6c instead of 0x6b
[  111.045628] INFO: Allocated in copy_process+0x2323/0x424c age=170 cpu=0 pid=511
[  111.045723] INFO: Freed in qlist_free_all+0x33/0xac age=44 cpu=0 pid=644
[  111.045784] INFO: Slab 0xffffea000022d980 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  111.045786] INFO: Object 0xffff880008b66c98 @offset=3224 fp=0xffff880008b66438
[  111.045786] 
[  111.045791] Redzone ffff880008b66c90: bb bb bb bb bb bb bb bb                          ........
[  111.045793] Object ffff880008b66c98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 40 8b  kkkkkkkkkkkkl.@.
[  111.045796] Object ffff880008b66ca8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  111.045799] Object ffff880008b66cb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-46:20160812160250:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  112.503276] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[  112.505277] power_supply test_battery: prop MODEL_NAME=Test battery
[  112.673774] =============================================================================
[  112.673787] BUG anon_vma_chain (Not tainted): Poison overwritten
[  112.673788] -----------------------------------------------------------------------------
[  112.673788] 
[  112.673789] Disabling lock debugging due to kernel taint
[  112.673793] INFO: 0xffff880009a27bb5-0xffff880009a27bb7. First byte 0x1 instead of 0x6b
[  112.673850] INFO: Allocated in anon_vma_clone+0x9f/0x375 age=155 cpu=0 pid=462
[  112.673944] INFO: Freed in qlist_free_all+0x33/0xac age=83 cpu=0 pid=581
[  112.674006] INFO: Slab 0xffffea0000268980 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  112.674008] INFO: Object 0xffff880009a27ba8 @offset=7080 fp=0x          (null)
[  112.674008] 
[  112.674013] Redzone ffff880009a27ba0: bb bb bb bb bb bb bb bb                          ........
[  112.674016] Object ffff880009a27ba8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 20 db  kkkkkkkkkkkkk. .
[  112.674019] Object ffff880009a27bb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  112.674022] Object ffff880009a27bc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  112.674024] Object ffff880009a27bd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  112.674027] Redzone ffff880009a27be8: bb bb bb bb bb bb bb bb                          ........
[  112.674034] Padding ffff880009a27d34: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  112.674048] CPU: 0 PID: 509 Comm: network.sh Tainted: G    B           4.7.0-05999-g80a9201 #1
[  112.674050] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  112.674069]  0000000000000000 ffff880007857af8 ffffffff81c91ab5 ffff880007857b28
[  112.674073]  ffffffff81330f07 ffff880009a27bb5 000000000000006b ffff88000c4131c0
[  112.674077]  ffff880009a27bb7 ffff880007857b78 ffffffff81330fac ffffffff83592f26
[  112.674078] Call Trace:
[  112.674105]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  112.674110]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  112.674113]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  112.674117]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  112.674120]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  112.674124]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  112.674128]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  112.674131]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  112.674134]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  112.674138]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  112.674141]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  112.674144]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  112.674147]  [<ffffffff813153ea>] anon_vma_prepare+0x6b/0x2db
[  112.674151]  [<ffffffff81303aa0>] handle_mm_fault+0x683/0x11bb
[  112.674155]  [<ffffffff8130341d>] ? apply_to_page_range+0x2fb/0x2fb
[  112.674158]  [<ffffffff8130f24e>] ? do_mmap+0x5ef/0x66a
[  112.674162]  [<ffffffff8130b86e>] ? find_vma+0xe1/0xef
[  112.674174]  [<ffffffff8111cf2b>] __do_page_fault+0x33e/0x624
[  112.674178]  [<ffffffff8111d254>] do_page_fault+0x22/0x27
[  112.674187]  [<ffffffff8111718c>] do_async_page_fault+0x2c/0x5e
[  112.674191]  [<ffffffff82c81918>] async_page_fault+0x28/0x30
[  112.674194] FIX anon_vma_chain: Restoring 0xffff880009a27bb5-0xffff880009a27bb7=0x6b
[  112.674194] 
[  112.674196] FIX anon_vma_chain: Marking all objects used
[  112.811791] ==================================================================
[  112.811809] BUG: KASAN: use-after-free in __rb_insert_augmented+0xaf/0x59f at addr ffff880007ab5988
[  112.811812] Read of size 8 by task udevd/617
[  112.811817] CPU: 0 PID: 617 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  112.811819] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  112.811825]  0000000000000000 ffff880007287b58 ffffffff81c91ab5 ffff880007287bd0
[  112.811829]  ffffffff8133576b ffffffff81c9ec18 0000000000000246 ffffffff81332213
[  112.811833]  ffff880007287c20 ffffffff81332213 ffffffff812f6bcd ffffffff81334595
[  112.811833] Call Trace:
[  112.811839]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  112.811845]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  112.811849]  [<ffffffff81c9ec18>] ? __rb_insert_augmented+0xaf/0x59f
[  112.811853]  [<ffffffff81332213>] ? ___slab_alloc+0x284/0x31e
[  112.811857]  [<ffffffff81332213>] ? ___slab_alloc+0x284/0x31e
[  112.811861]  [<ffffffff812f6bcd>] ? vma_interval_tree_compute_subtree_last+0x11/0xcc
[  112.811865]  [<ffffffff81334595>] ? kasan_poison_shadow+0x2f/0x31
[  112.811869]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  112.811871]  [<ffffffff81c9ec18>] __rb_insert_augmented+0xaf/0x59f
[  112.811875]  [<ffffffff812f6cfd>] ? vma_interval_tree_augment_propagate+0x75/0x75
[  112.811879]  [<ffffffff812f7c25>] vma_interval_tree_insert_after+0x1b6/0x1c3
[  112.811884]  [<ffffffff811a9e51>] copy_process+0x2624/0x424c
[  112.811888]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  112.811903]  [<ffffffff81350326>] ? vfs_fstatat+0xa1/0xfd
[  112.811906]  [<ffffffff81350285>] ? SYSC_newfstat+0xa6/0xa6
[  112.811910]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  112.811921]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  112.811927]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  112.811932]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  112.811935]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  112.811938]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  112.811942]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  112.811945]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  112.811948] Object at ffff880007ab5928, in cache vm_area_struct
[  112.811949] Object allocated with size 184 bytes.
[  112.811950] Allocation:
[  112.811951] PID = 269
[  112.811958]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  112.811961]  [<ffffffff81334733>] save_stack+0x46/0xce
[  112.811965]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  112.811968]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  112.811972]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  112.811975]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  112.811980]  [<ffffffff811a9b50>] copy_process+0x2323/0x424c
[  112.811983]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  112.811987]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  112.811990]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  112.811993]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  112.811994] Memory state around the buggy address:
[  112.811998]  ffff880007ab5880: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-52:20160812160310:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  106.196555] ==================================================================
[  106.199340] BUG: KASAN: use-after-free in find_vma+0x72/0xef at addr ffff880007c0cca0
[  106.202126] Read of size 8 by task mount.sh/568
[  106.203669] CPU: 0 PID: 568 Comm: mount.sh Not tainted 4.7.0-05999-g80a9201 #1
[  106.206351] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  106.209296]  0000000000000000 ffff88000805fde0 ffffffff81c91ab5 ffff88000805fe58
[  106.212413]  ffffffff8133576b ffffffff8130b7ff 0000000000000246 ffff880008150d40
[  106.215519]  0000000800000000 0000000000000003 ffff880008ec3b40 0000000000000246
[  106.218638] Call Trace:
[  106.219821]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  106.221477]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  106.223167]  [<ffffffff8130b7ff>] ? find_vma+0x72/0xef
[  106.224995]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  106.226891]  [<ffffffff8130b7ff>] find_vma+0x72/0xef
[  106.228546]  [<ffffffff8111ce9d>] __do_page_fault+0x2b0/0x624
[  106.230290]  [<ffffffff8111d254>] do_page_fault+0x22/0x27
[  106.231979]  [<ffffffff8111718c>] do_async_page_fault+0x2c/0x5e
[  106.233762]  [<ffffffff82c81918>] async_page_fault+0x28/0x30
[  106.235502] Object at ffff880007c0cc98, in cache vm_area_struct
[  106.237272] Object allocated with size 184 bytes.
[  106.238841] Allocation:
[  106.240007] PID = 451
[  106.241147]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  106.242997]  [<ffffffff81334733>] save_stack+0x46/0xce
[  106.244750]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  106.246537]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  106.248403]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  106.250302]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  106.252138]  [<ffffffff811a9b50>] copy_process+0x2323/0x424c
[  106.254113]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  106.255858]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  106.257584]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  106.269620]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  106.270857] Memory state around the buggy address:
[  106.271833]  ffff880007c0cb80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-53:20160812160248:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  109.853372] ==================================================================
[  109.857137] BUG: KASAN: use-after-free in copy_process+0x21b8/0x424c at addr ffff880008820270
[  109.860224] Read of size 8 by task mount.sh/385
[  109.861852] CPU: 0 PID: 385 Comm: mount.sh Not tainted 4.7.0-05999-g80a9201 #1
[  109.864512] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  109.881612]  0000000000000000 ffff8800089f7bf8 ffffffff81c91ab5 ffff8800089f7c70
[  109.884787]  ffffffff8133576b ffffffff811a99e5 0000000000000246 0000000000000000
[  109.887916]  0000000000000000 ffff880008b6ad40 ffff88000ae9d730 ffff88000ae9d520
[  109.891113] Call Trace:
[  109.908384]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  109.910142]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  109.911918]  [<ffffffff811a99e5>] ? copy_process+0x21b8/0x424c
[  109.913940]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  109.915858]  [<ffffffff811a99e5>] copy_process+0x21b8/0x424c
[  109.917723]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  109.919516]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  109.921249]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  109.936095]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  109.937767]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  109.939571]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  109.941440]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  109.943324]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  109.945290]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  109.946990]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  109.961891]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  109.963636]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  109.965518] Object at ffff880008820220, in cache vm_area_struct
[  109.967300] Object allocated with size 184 bytes.
[  109.968873] Allocation:
[  109.970107] PID = 385
[  109.971315]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  109.973262]  [<ffffffff81334733>] save_stack+0x46/0xce
[  109.988168]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  110.019502]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  110.034516]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  110.036541]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  110.038499]  [<ffffffff8130f85c>] __install_special_mapping+0x61/0x2a3
[  110.040607]  [<ffffffff8130faae>] _install_special_mapping+0x10/0x12
[  110.042686]  [<ffffffff81002d22>] map_vdso+0x105/0x16f
[  110.044633]  [<ffffffff81002e7b>] arch_setup_additional_pages+0x19/0x1e
[  110.046659]  [<ffffffff813e679d>] load_elf_binary+0x1b53/0x357c
[  110.061624]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  110.063608]  [<ffffffff813e11b4>] load_script+0x4b8/0x506
[  110.065412]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  110.067489]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  110.069620]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  110.071452]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  110.073280]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  110.088200]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  110.090197] Memory state around the buggy address:
[  110.091865]  ffff880008820100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-61:20160812160220:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[   96.984949] power_supply test_battery: prop TECHNOLOGY=Li-ion
[   97.060941] =============================================================================
** 1583 printk messages dropped ** 
[   97.599815]  [<ffffffff812f7d0e>] anon_vma_interval_tree_insert+0xdc/0x1d5
[   97.599817]  [<ffffffff81315c32>] anon_vma_clone+0x20b/0x375
[   97.599820]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[   97.599824]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[   97.599828]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[   97.599832]  [<ffffffff813345bf>] ? kasan_poison_slab_free+0x28/0x2a
[   97.599835]  [<ffffffff81334c54>] ? kasan_slab_free+0xa4/0xad
[   97.599839]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[   97.599842]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[   97.599846]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[   97.599849]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[   97.599853]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[   97.599855]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[   97.599859]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[   97.599862]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[   97.599864] Object at ffff880007e036c8, in cache anon_vma_chain
[   97.599865] Object allocated with size 64 bytes.
[   97.599866] Allocation:
[   97.599867] PID = 349
[   97.599875]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[   97.599879]  [<ffffffff81334733>] save_stack+0x46/0xce
[   97.599883]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[   97.599886]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[   97.599890]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[   97.599893]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[   97.599897]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[   97.599900]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[   97.599903]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[   97.599907]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[   97.599910]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[   97.599914]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[   97.599917]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[   97.599918] Memory state around the buggy address:
[   97.599921]  ffff880007e03580: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-ivb41-74:20160812160249:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  113.319464] =============================================================================
[  113.326763] BUG vm_area_struct (Not tainted): Poison overwritten
[  113.328648] -----------------------------------------------------------------------------
[  113.328648] 
[  113.340859] Disabling lock debugging due to kernel taint
[  113.342639] INFO: 0xffff88000823822c-0xffff88000823822f. First byte 0x6c instead of 0x6b
[  113.345668] INFO: Allocated in copy_process+0x2323/0x424c age=92 cpu=0 pid=513
[  113.377733] INFO: Freed in qlist_free_all+0x33/0xac age=28 cpu=0 pid=395
[  113.426982] INFO: Slab 0xffffea0000208e00 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  113.438537] INFO: Object 0xffff880008238220 @offset=544 fp=0xffff8800082394f8
[  113.438537] 
[  113.441619] Redzone ffff880008238218: bb bb bb bb bb bb bb bb                          ........
[  113.452999] Object ffff880008238220: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 20 8c  kkkkkkkkkkkkl. .
[  113.489973] Object ffff880008238230: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  113.501486] Object ffff880008238240: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-78:20160812160240:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  114.438452] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  114.438477] power_supply test_ac: prop ONLINE=1
[  114.452787] =============================================================================
[  114.452791] BUG names_cache (Not tainted): Poison overwritten
[  114.452792] -----------------------------------------------------------------------------
[  114.452792] 
[  114.452794] Disabling lock debugging due to kernel taint
[  114.452797] INFO: 0xffff880008ea358c-0xffff880008ea358f. First byte 0x7e instead of 0x6b
[  114.452806] INFO: Allocated in getname_flags+0x5a/0x35c age=74 cpu=0 pid=503
[  114.452842] INFO: Freed in qlist_free_all+0x33/0xac age=7 cpu=0 pid=382
[  114.452881] INFO: Slab 0xffffea000023a800 objects=7 used=7 fp=0x          (null) flags=0x4000000000004080
[  114.452883] INFO: Object 0xffff880008ea3580 @offset=13696 fp=0xffff880008ea23c0
[  114.452883] 
[  114.452887] Redzone ffff880008ea3540: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  114.452890] Redzone ffff880008ea3550: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  114.452893] Redzone ffff880008ea3560: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  114.452896] Redzone ffff880008ea3570: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  114.452899] Object ffff880008ea3580: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 80 88  kkkkkkkkkkkk~...
[  114.452902] Object ffff880008ea3590: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  114.452905] Object ffff880008ea35a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-7:20160812160302:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  115.327567] floppy: error -5 while reading block 0
[  115.599208] power_supply test_ac: uevent
[  115.625389] =============================================================================
[  115.625405] BUG anon_vma_chain (Not tainted): Poison overwritten
[  115.625411] -----------------------------------------------------------------------------
[  115.625411] 
[  115.625413] Disabling lock debugging due to kernel taint
[  115.625416] INFO: 0xffff880008ac31f4-0xffff880008ac31f7. First byte 0x7e instead of 0x6b
[  115.625483] INFO: Allocated in anon_vma_prepare+0x6b/0x2db age=94 cpu=0 pid=517
[  115.625597] INFO: Freed in qlist_free_all+0x33/0xac age=9 cpu=0 pid=306
[  115.625649] INFO: Slab 0xffffea000022b080 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  115.625651] INFO: Object 0xffff880008ac31e8 @offset=4584 fp=0x          (null)
[  115.625651] 
[  115.625656] Redzone ffff880008ac31e0: bb bb bb bb bb bb bb bb                          ........
[  115.625659] Object ffff880008ac31e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 80 bb  kkkkkkkkkkkk~...
[  115.625662] Object ffff880008ac31f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  115.625664] Object ffff880008ac3208: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  115.625667] Object ffff880008ac3218: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  115.625669] Redzone ffff880008ac3228: bb bb bb bb bb bb bb bb                          ........
[  115.625672] Padding ffff880008ac3374: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  115.625688] CPU: 0 PID: 305 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  115.625690] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  115.625712]  0000000000000000 ffff880008dc79d8 ffffffff81c91ab5 ffff880008dc7a08
[  115.625715]  ffffffff81330f07 ffff880008ac31f4 000000000000006b ffff88000c4131c0
[  115.625719]  ffff880008ac31f7 ffff880008dc7a58 ffffffff81330fac ffffffff83592f26
[  115.625720] Call Trace:
[  115.625753]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  115.625758]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  115.625762]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  115.625765]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  115.625768]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  115.625772]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  115.625775]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  115.625778]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  115.625787]  [<ffffffff81ccf700>] ? debug_smp_processor_id+0x17/0x19
[  115.625791]  [<ffffffff8133006c>] ? set_track+0xad/0xef
[  115.625794]  [<ffffffff81330693>] ? init_object+0x6f/0x76
[  115.625797]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  115.625801]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  115.625804]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  115.625808]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  115.625811]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  115.625814]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  115.625830]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  115.625835]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  115.625843]  [<ffffffff81350326>] ? vfs_fstatat+0xa1/0xfd
[  115.625848]  [<ffffffff81350285>] ? SYSC_newfstat+0xa6/0xa6
[  115.625851]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  115.625855]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  115.625858]  [<ffffffff8134f46b>] ? cp_old_stat+0x40b/0x40b
[  115.625862]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  115.625865]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  115.625878]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  115.625883]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  115.625886] FIX anon_vma_chain: Restoring 0xffff880008ac31f4-0xffff880008ac31f7=0x6b
[  115.625886] 

dmesg-yocto-ivb41-81:20160812160254:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  111.964236] =============================================================================
[  111.967640] BUG kmalloc-512 (Not tainted): Poison overwritten
[  111.969620] -----------------------------------------------------------------------------
[  111.969620] 
[  111.977896] Disabling lock debugging due to kernel taint
[  111.983861] INFO: 0xffff880008ee9454-0xffff880008ee9457. First byte 0x6c instead of 0x6b
[  111.987140] INFO: Allocated in load_elf_phdrs+0x9a/0xf4 age=104 cpu=0 pid=522
[  112.030330] INFO: Freed in qlist_free_all+0x33/0xac age=36 cpu=0 pid=540
[  112.128426] INFO: Slab 0xffffea000023ba00 objects=9 used=9 fp=0x          (null) flags=0x4000000000004080
[  112.131995] INFO: Object 0xffff880008ee9448 @offset=5192 fp=0x          (null)
[  112.131995] 
[  112.135841] Redzone ffff880008ee9440: bb bb bb bb bb bb bb bb                          ........
[  112.138987] Object ffff880008ee9448: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 00 a3  kkkkkkkkkkkkl...
[  112.155009] Object ffff880008ee9458: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  112.158297] Object ffff880008ee9468: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-ivb41-94:20160812160301:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  113.979327] power_supply test_battery: prop CHARGE_FULL=100
[  113.981097] power_supply test_battery: prop CHARGE_NOW=50
** 94972 printk messages dropped ** 
[  115.011238]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
** 90 printk messages dropped ** 
[  115.011513]  [<ffffffff8133576b>] kasan_report+0x319/0x553
** 112 printk messages dropped ** 
[  115.011876]  ffff8800080a9080: fc fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb
** 129 printk messages dropped ** 
[  115.012311]  ffff8800080a9080: fc fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb
** 144 printk messages dropped ** 
[  115.012751]  [<ffffffff8133576b>] kasan_report+0x319/0x553
** 168 printk messages dropped ** 
[  115.013289]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
** 183 printk messages dropped ** 
[  115.013878]  [<ffffffff82c80fe2>] retint_user+0x8/0x10
** 205 printk messages dropped ** 
[  115.014522]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
** 219 printk messages dropped ** 
[  115.025745]  [<ffffffff812ff949>] unmap_page_range+0x462/0x949
** 243 printk messages dropped ** 
[  115.026525] ==================================================================
** 259 printk messages dropped ** 

dmesg-yocto-ivb41-95:20160812160231:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  105.566563] power_supply test_battery: prop CHARGE_NOW=50
[  105.623433] power_supply test_battery: prop CAPACITY=50
[  105.628181] =============================================================================
[  105.628184] BUG vm_area_struct (Not tainted): Poison overwritten
[  105.628185] -----------------------------------------------------------------------------
[  105.628185] 
[  105.628186] Disabling lock debugging due to kernel taint
[  105.628190] INFO: 0xffff88000805fd64-0xffff88000805fd67. First byte 0x7e instead of 0x6b
[  105.628199] INFO: Allocated in copy_process+0x2323/0x424c age=139 cpu=0 pid=278
** 650 printk messages dropped ** 
[  106.440612]  ffffffff8133576b ffffffff8130763f 0000000000000246 fcfcfcfc0840a808
[  106.440616]  fcfcfcfcfcfcfcfc 66666620fcfcfcfc 3038303030383866 00203a3030613765
** 92236 printk messages dropped ** 
[  107.342524]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
** 88 printk messages dropped ** 
[  107.342776]  [<ffffffff813001ac>] unmap_vmas+0xa7/0xc4
** 108 printk messages dropped ** 
[  107.343092] Read of size 8 by task udevd/507
** 125 printk messages dropped ** 

dmesg-yocto-kbuild-10:20160812160326:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  151.982550] power_supply test_ac: uevent
[  152.341030] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  152.414342] =============================================================================
[  152.414347] BUG vm_area_struct (Not tainted): Poison overwritten
[  152.414348] -----------------------------------------------------------------------------
[  152.414348] 
[  152.414350] Disabling lock debugging due to kernel taint
[  152.414353] INFO: 0xffff88000b45d0d4-0xffff88000b45d0d7. First byte 0x7e instead of 0x6b
[  152.414362] INFO: Allocated in copy_process+0x2323/0x424c age=115 cpu=0 pid=279
[  152.414569] INFO: Freed in qlist_free_all+0x33/0xac age=24 cpu=0 pid=285
[  152.414615] INFO: Slab 0xffffea00002d1700 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  152.414617] INFO: Object 0xffff88000b45d0c8 @offset=4296 fp=0xffff88000b45db40
[  152.414617] 
[  152.414621] Redzone ffff88000b45d0c0: bb bb bb bb bb bb bb bb                          ........
[  152.414624] Object ffff88000b45d0c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 60 b1  kkkkkkkkkkkk~.`.
[  152.414627] Object ffff88000b45d0d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.414630] Object ffff88000b45d0e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-11:20160812160327:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  152.387725] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[  152.427546] ==================================================================
** 3609 printk messages dropped ** 
[  152.463783]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  152.463787]  [<ffffffff812f6bf1>] vma_interval_tree_compute_subtree_last+0x35/0xcc
[  152.463791]  [<ffffffff812f6cb1>] vma_interval_tree_augment_propagate+0x29/0x75
[  152.463795]  [<ffffffff812f78b3>] vma_interval_tree_remove+0x5e2/0x608
[  152.463798]  [<ffffffff81309a25>] vma_adjust+0x71e/0xaae
[  152.463802]  [<ffffffff81ccf700>] ? debug_smp_processor_id+0x17/0x19
[  152.463805]  [<ffffffff81309307>] ? vma_link+0xf7/0xf7
[  152.463809]  [<ffffffff81334595>] ? kasan_poison_shadow+0x2f/0x31

dmesg-yocto-kbuild-13:20160812160326:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  144.681428] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[  144.683430] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[  144.905297] =============================================================================
[  144.905306] BUG vm_area_struct (Not tainted): Poison overwritten
[  144.905307] -----------------------------------------------------------------------------
[  144.905307] 
[  144.905308] Disabling lock debugging due to kernel taint
[  144.905311] INFO: 0xffff88000986a22c-0xffff88000986a22f. First byte 0x7e instead of 0x6b
[  144.905364] INFO: Allocated in __install_special_mapping+0x61/0x2a3 age=99 cpu=0 pid=505
[  144.905476] INFO: Freed in qlist_free_all+0x33/0xac age=14 cpu=0 pid=538
[  144.905514] INFO: Slab 0xffffea0000261a80 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  144.905517] INFO: Object 0xffff88000986a220 @offset=544 fp=0x          (null)
[  144.905517] 
[  144.905521] Redzone ffff88000986a218: bb bb bb bb bb bb bb bb                          ........
[  144.905523] Object ffff88000986a220: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 60 a7  kkkkkkkkkkkk~.`.
[  144.905526] Object ffff88000986a230: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  144.905529] Object ffff88000986a240: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-14:20160812160322:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

** 76213 printk messages dropped ** 
[  145.858424]  [<ffffffff812ff4e7>] ? do_wp_page+0x9b4/0x9b4
** 92 printk messages dropped ** 
[  145.858679] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
** 109 printk messages dropped ** 
[  145.859010]  [<ffffffff8133576b>] kasan_report+0x319/0x553
** 130 printk messages dropped ** 
[  145.859391]  [<ffffffff811a9b50>] copy_process+0x2323/0x424c
** 144 printk messages dropped ** 
[  145.859796] Object at ffff88000b193b40, in cache vm_area_struct
** 167 printk messages dropped ** 

dmesg-yocto-kbuild-15:20160812160328:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  150.868081] power_supply test_battery: prop CHARGE_NOW=50
[  150.924163] power_supply test_battery: prop CAPACITY=50
[  151.508936] =============================================================================
[  151.508941] BUG kmalloc-1024 (Not tainted): Poison overwritten
[  151.508942] -----------------------------------------------------------------------------
[  151.508942] 
[  151.508943] Disabling lock debugging due to kernel taint
[  151.508945] INFO: 0xffff88000c824b54-0xffff88000c824b57. First byte 0x6e instead of 0x6b
[  151.508953] INFO: Allocated in __alloc_skb+0xdb/0x498 age=274 cpu=0 pid=342
[  151.508990] INFO: Freed in qlist_free_all+0x33/0xac age=177 cpu=0 pid=466
[  151.509026] INFO: Slab 0xffffea0000320800 objects=23 used=23 fp=0x          (null) flags=0x4000000000004080
[  151.509028] INFO: Object 0xffff88000c824b48 @offset=19272 fp=0xffff88000c822b08
[  151.509028] 
[  151.509032] Redzone ffff88000c824b40: bb bb bb bb bb bb bb bb                          ........
[  151.509034] Object ffff88000c824b48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6e 01 e0 ad  kkkkkkkkkkkkn...
[  151.509037] Object ffff88000c824b58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  151.509039] Object ffff88000c824b68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-16:20160812160324:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  146.795611] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[  146.795639] power_supply test_usb: prop ONLINE=1
[  146.872838] =============================================================================
[  146.872843] BUG anon_vma_chain (Not tainted): Poison overwritten
[  146.872844] -----------------------------------------------------------------------------
[  146.872844] 
[  146.872846] Disabling lock debugging due to kernel taint
[  146.872849] INFO: 0xffff88000a3adbb4-0xffff88000a3adbb7. First byte 0x6c instead of 0x6b
[  146.872857] INFO: Allocated in anon_vma_fork+0xfa/0x3f9 age=177 cpu=0 pid=461
[  146.872891] INFO: Freed in qlist_free_all+0x33/0xac age=11 cpu=0 pid=543
[  146.872928] INFO: Slab 0xffffea000028eb00 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  146.872930] INFO: Object 0xffff88000a3adba8 @offset=7080 fp=0xffff88000a3ac828
[  146.872930] 
[  146.872934] Redzone ffff88000a3adba0: bb bb bb bb bb bb bb bb                          ........
[  146.872938] Object ffff88000a3adba8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 00 8a  kkkkkkkkkkkkl...
[  146.872940] Object ffff88000a3adbb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  146.872943] Object ffff88000a3adbc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  146.872946] Object ffff88000a3adbd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  146.872949] Redzone ffff88000a3adbe8: bb bb bb bb bb bb bb bb                          ........
[  146.872951] Padding ffff88000a3add34: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  146.872956] CPU: 0 PID: 268 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  146.872958] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  146.872964]  0000000000000000 ffff88000b86f9d8 ffffffff81c91ab5 ffff88000b86fa08
[  146.872967]  ffffffff81330f07 ffff88000a3adbb4 000000000000006b ffff88000e8131c0
[  146.872971]  ffff88000a3adbb7 ffff88000b86fa58 ffffffff81330fac ffffffff83592f26
[  146.872972] Call Trace:
[  146.872978]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  146.872981]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  146.872985]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  146.872988]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  146.872991]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  146.872995]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  146.872999]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  146.873002]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  146.873006]  [<ffffffff81ccf700>] ? debug_smp_processor_id+0x17/0x19
[  146.873009]  [<ffffffff8133006c>] ? set_track+0xad/0xef
[  146.873012]  [<ffffffff81330693>] ? init_object+0x6f/0x76
[  146.873015]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  146.873019]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  146.873022]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  146.873026]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  146.873028]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  146.873031]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  146.873035]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  146.873039]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  146.873043]  [<ffffffff8137fb67>] ? __fget_light+0x80/0xe3
[  146.873046]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  146.873050]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  146.873054]  [<ffffffff829a0101>] ? SYSC_recvfrom+0x27e/0x27e
[  146.873057]  [<ffffffff829a3896>] ? SYSC_socket+0xbd/0x102
[  146.873060]  [<ffffffff829a37d9>] ? sock_create+0x8e/0x8e
[  146.873063]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  146.873067]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  146.873069]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  146.873073]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  146.873076] FIX anon_vma_chain: Restoring 0xffff88000a3adbb4-0xffff88000a3adbb7=0x6b
[  146.873076] 

dmesg-yocto-kbuild-17:20160812160326:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  154.213657] gfs2: gfs2 mount does not exist
[  154.236652] floppy: error -5 while reading block 0
[  154.259065] =============================================================================
[  154.259071] BUG files_cache (Not tainted): Poison overwritten
[  154.259072] -----------------------------------------------------------------------------
[  154.259072] 
[  154.259073] Disabling lock debugging due to kernel taint
[  154.259076] INFO: 0xffff88000ba7114c-0xffff88000ba7114f. First byte 0x7e instead of 0x6b
[  154.259086] INFO: Allocated in dup_fd+0x88/0x5b0 age=424 cpu=0 pid=275
[  154.259122] INFO: Freed in qlist_free_all+0x33/0xac age=56 cpu=0 pid=648
[  154.259171] INFO: Slab 0xffffea00002e9c00 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  154.259174] INFO: Object 0xffff88000ba71140 @offset=4416 fp=0x          (null)
[  154.259174] 
[  154.259178] Redzone ffff88000ba71100: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  154.259181] Redzone ffff88000ba71110: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  154.259183] Redzone ffff88000ba71120: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  154.259186] Redzone ffff88000ba71130: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  154.259189] Object ffff88000ba71140: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 60 ab  kkkkkkkkkkkk~.`.
[  154.259191] Object ffff88000ba71150: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  154.259194] Object ffff88000ba71160: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-1:20160812160328:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  149.752961] power_supply test_ac: prop ONLINE=1
[  149.888829] power_supply test_battery: uevent
[  149.892978] =============================================================================
[  149.892982] BUG kmalloc-4096 (Not tainted): Poison overwritten
[  149.892983] -----------------------------------------------------------------------------
[  149.892983] 
[  149.892984] Disabling lock debugging due to kernel taint
[  149.892987] INFO: 0xffff880009f54594-0xffff880009f54597. First byte 0x6e instead of 0x6b
[  149.892996] INFO: Allocated in uevent_show+0x11c/0x25a age=116 cpu=0 pid=281
[  149.893039] INFO: Freed in qlist_free_all+0x33/0xac age=17 cpu=0 pid=347
[  149.893082] INFO: Slab 0xffffea000027d400 objects=7 used=7 fp=0x          (null) flags=0x4000000000004080
[  149.893084] INFO: Object 0xffff880009f54588 @offset=17800 fp=0x          (null)
[  149.893084] 
[  149.893088] Redzone ffff880009f54580: bb bb bb bb bb bb bb bb                          ........
[  149.893091] Object ffff880009f54588: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6e 01 60 ae  kkkkkkkkkkkkn.`.
[  149.893094] Object ffff880009f54598: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.893096] Object ffff880009f545a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-21:20160812160316:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  143.977111] =============================================================================
[  143.986656] BUG anon_vma_chain (Not tainted): Poison overwritten
[  143.988717] -----------------------------------------------------------------------------
[  143.988717] 
[  144.011421] Disabling lock debugging due to kernel taint
[  144.012983] INFO: 0xffff88000a2bd874-0xffff88000a2bd877. First byte 0x6c instead of 0x6b
[  144.015577] INFO: Allocated in anon_vma_clone+0x9f/0x375 age=175 cpu=0 pid=454
[  144.043674] INFO: Freed in qlist_free_all+0x33/0xac age=48 cpu=0 pid=511
[  144.064238] INFO: Slab 0xffffea000028af00 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  144.085285] INFO: Object 0xffff88000a2bd868 @offset=6248 fp=0xffff88000a2bd6c8
[  144.085285] 
[  144.088822] Redzone ffff88000a2bd860: bb bb bb bb bb bb bb bb                          ........
[  144.092079] Object ffff88000a2bd868: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 c0 85  kkkkkkkkkkkkl...
[  144.094964] Object ffff88000a2bd878: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  144.097816] Object ffff88000a2bd888: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  144.100622] Object ffff88000a2bd898: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  144.104041] Redzone ffff88000a2bd8a8: bb bb bb bb bb bb bb bb                          ........
[  144.114182] Padding ffff88000a2bd9f4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  144.119997] CPU: 0 PID: 462 Comm: mount.sh Tainted: G    B           4.7.0-05999-g80a9201 #1
[  144.127309] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  144.132809]  0000000000000000 ffff880009dc7a48 ffffffff81c91ab5 ffff880009dc7a78
[  144.136036]  ffffffff81330f07 ffff88000a2bd874 000000000000006b ffff88000e8131c0
[  144.142830]  ffff88000a2bd877 ffff880009dc7ac8 ffffffff81330fac ffffffff83592f26
[  144.145765] Call Trace:
[  144.146865]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  144.148398]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  144.152768]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  144.154710]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  144.157211]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  144.158952]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  144.160735]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  144.162894]  [<ffffffff81334818>] ? kasan_unpoison_shadow+0x14/0x35
[  144.171589]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  144.179279]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  144.180914]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  144.182697]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  144.184558]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  144.187115]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  144.188737]  [<ffffffff81315e96>] anon_vma_fork+0xfa/0x3f9
[  144.191092]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  144.192825]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  144.194558]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  144.204038]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  144.205888]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  144.207479]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  144.209173]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  144.211032]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  144.213616]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  144.215440]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  144.216949]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  144.218663]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  144.220382]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  144.222214] FIX anon_vma_chain: Restoring 0xffff88000a2bd874-0xffff88000a2bd877=0x6b

dmesg-yocto-kbuild-24:20160812160323:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  146.525186] power_supply test_battery: prop HEALTH=Good
[  146.527021] power_supply test_battery: prop PRESENT=1
[  146.729387] ==================================================================
[  146.729398] BUG: KASAN: use-after-free in unlink_anon_vmas+0x63/0x3cd at addr ffff88000c3acb78
[  146.729401] Read of size 8 by task udevd/486
[  146.729406] CPU: 0 PID: 486 Comm: udevd Not tainted 4.7.0-05999-g80a9201 #1
[  146.729407] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  146.729414]  0000000000000000 ffff88000c0d7728 ffffffff81c91ab5 ffff88000c0d77a0
[  146.729418]  ffffffff8133576b ffffffff813156bd 0000000000000246 ffff88000c036ad8
[  146.729421]  ffff88000e4e4170 ffff88000c036a01 ffff88000c0d77b0 ffffffff812f78ca
[  146.729422] Call Trace:
[  146.729428]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  146.729433]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  146.729436]  [<ffffffff813156bd>] ? unlink_anon_vmas+0x63/0x3cd
[  146.729441]  [<ffffffff812f78ca>] ? vma_interval_tree_remove+0x5f9/0x608
[  146.729445]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  146.729448]  [<ffffffff813156bd>] unlink_anon_vmas+0x63/0x3cd
[  146.729452]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[  146.729455]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  146.729459]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  146.729463]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  146.729468]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  146.729471]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  146.729475]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[  146.729480]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[  146.729483]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  146.729487]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  146.729490]  [<ffffffff813e11b4>] load_script+0x4b8/0x506
[  146.729493]  [<ffffffff813e0cfc>] ? compat_SyS_ioctl+0x184d/0x184d
[  146.729497]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  146.729500]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  146.729504]  [<ffffffff81351535>] ? copy_strings+0x467/0x52d
[  146.729507]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  146.729511]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  146.729515]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  146.729518]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  146.729521]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  146.729525]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  146.729529]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  146.729532]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  146.729536]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  146.729540]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  146.729543]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  146.729545] Object at ffff88000c3acb68, in cache anon_vma_chain
[  146.729547] Object allocated with size 64 bytes.
[  146.729547] Allocation:
[  146.729548] PID = 416
[  146.729553]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  146.729557]  [<ffffffff81334733>] save_stack+0x46/0xce
[  146.729561]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  146.729564]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  146.729568]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  146.729571]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  146.729574]  [<ffffffff81315e96>] anon_vma_fork+0xfa/0x3f9
[  146.729578]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  146.729582]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  146.729585]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  146.729588]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  146.729592]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  146.729593] Memory state around the buggy address:
[  146.729596]  ffff88000c3aca00: fb fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-27:20160812160323:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  138.649303] ==================================================================
[  138.652465] BUG: KASAN: use-after-free in unlink_anon_vmas+0x205/0x3cd at addr ffff88000a87a4f8
[  138.655767] Read of size 8 by task mount.sh/508
[  138.657376] CPU: 0 PID: 508 Comm: mount.sh Not tainted 4.7.0-05999-g80a9201 #1
[  138.660158] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  138.676644]  0000000000000000 ffff88000bb97918 ffffffff81c91ab5 ffff88000bb97990
[  138.680279]  ffffffff8133576b ffffffff8131585f 0000000000000246 0000000000000000
[  138.683701]  0000000000000000 ffff88000aadf0c8 ffff88000bb979a0 ffffffff812f83e9
[  138.699900] Call Trace:
[  138.700987]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  138.702852]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  138.704845]  [<ffffffff8131585f>] ? unlink_anon_vmas+0x205/0x3cd
[  138.706945]  [<ffffffff812f83e9>] ? anon_vma_interval_tree_remove+0x5e2/0x608
[  138.709281]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  138.724386]  [<ffffffff8131585f>] unlink_anon_vmas+0x205/0x3cd
[  138.726323]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[  138.728157]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  138.730089]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  138.732029]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  138.734070]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  138.735955]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  138.750858]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[  138.752989]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[  138.755066]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  138.756933]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  138.758800]  [<ffffffff81350002>] ? vfs_getattr_nosec+0xc/0xef
[  138.778543]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  138.780170]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  138.781852]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  138.783615]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  138.785324]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  138.801094]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  138.802715]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  138.804327]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  138.805803]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  138.807301]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  138.808862]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  138.861681]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  138.881504] Object at ffff88000a87a4e8, in cache anon_vma_chain
[  138.883603] Object allocated with size 64 bytes.
[  138.885414] Allocation:
[  138.886787] PID = 451
[  138.888124]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  138.890285]  [<ffffffff81334733>] save_stack+0x46/0xce
[  138.892330]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  138.907384]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  138.909325]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  138.911342]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  138.913504]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  138.915637]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  138.917758]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  138.920046]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  138.934948]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  138.936859]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  138.938995]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  138.941237] Memory state around the buggy address:
[  138.943082]  ffff88000a87a380: 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-2:20160812160317:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  143.707755] =============================================================================
[  143.710507] BUG vm_area_struct (Not tainted): Poison overwritten
[  143.712229] -----------------------------------------------------------------------------
[  143.712229] 
[  143.733816] Disabling lock debugging due to kernel taint
[  143.735429] INFO: 0xffff88000c24e014-0xffff88000c24e017. First byte 0x7e instead of 0x6b
[  143.738114] INFO: Allocated in mmap_region+0x33a/0xa41 age=173 cpu=0 pid=306
[  143.805767] INFO: Freed in qlist_free_all+0x33/0xac age=7 cpu=0 pid=277
[  143.869482] INFO: Slab 0xffffea0000309380 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  143.885467] INFO: Object 0xffff88000c24e008 @offset=8 fp=0x          (null)
[  143.885467] 
[  143.888216] Redzone ffff88000c24e000: bb bb bb bb bb bb bb bb                          ........
[  143.890996] Object ffff88000c24e008: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 60 af  kkkkkkkkkkkk~.`.
[  143.893893] Object ffff88000c24e018: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  143.896765] Object ffff88000c24e028: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-32:20160812160319:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  156.499540] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[  156.518958] power_supply test_usb: prop ONLINE=1
[  157.183231] =============================================================================
[  157.188521] BUG anon_vma_chain (Not tainted): Poison overwritten
[  157.190512] -----------------------------------------------------------------------------
[  157.190512] 
[  157.195775] Disabling lock debugging due to kernel taint
[  157.197875] INFO: 0xffff88000bd59054-0xffff88000bd59057. First byte 0x6c instead of 0x6b
[  157.201365] INFO: Allocated in anon_vma_clone+0x9f/0x375 age=174 cpu=0 pid=313
[  157.237422] INFO: Freed in qlist_free_all+0x33/0xac age=13 cpu=0 pid=328
[  157.280019] INFO: Slab 0xffffea00002f5600 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  157.283175] INFO: Object 0xffff88000bd59048 @offset=4168 fp=0xffff88000bd59d48
[  157.283175] 
[  157.286534] Redzone ffff88000bd59040: bb bb bb bb bb bb bb bb                          ........
[  157.302668] Object ffff88000bd59048: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 a0 86  kkkkkkkkkkkkl...
[  157.305906] Object ffff88000bd59058: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  157.327316] Object ffff88000bd59068: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  157.330613] Object ffff88000bd59078: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  157.333824] Redzone ffff88000bd59088: bb bb bb bb bb bb bb bb                          ........
[  157.354987] Padding ffff88000bd591d4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  157.358162] CPU: 0 PID: 349 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  157.361127] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  157.382340]  0000000000000000 ffff88000a44f9d8 ffffffff81c91ab5 ffff88000a44fa08
[  157.385619]  ffffffff81330f07 ffff88000bd59054 000000000000006b ffff88000e8131c0
[  157.388936]  ffff88000bd59057 ffff88000a44fa58 ffffffff81330fac ffffffff83592f26
[  157.410400] Call Trace:
[  157.411652]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  157.413329]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  157.415094]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  157.439008]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  157.440642]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  157.442309]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  157.444056]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  157.445868]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  157.447518]  [<ffffffff81ccf700>] ? debug_smp_processor_id+0x17/0x19
[  157.449434]  [<ffffffff8133006c>] ? set_track+0xad/0xef
[  157.451207]  [<ffffffff81330693>] ? init_object+0x6f/0x76
[  157.465940]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  157.467587]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  157.469470]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  157.471996]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  157.473634]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  157.475624]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  157.477460]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  157.492327]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  157.494104]  [<ffffffff813345bf>] ? kasan_poison_slab_free+0x28/0x2a
[  157.495862]  [<ffffffff81334c54>] ? kasan_slab_free+0xa4/0xad
[  157.497694]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  157.499482]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  157.501238]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  157.503129]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  157.505140]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  157.507071]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  157.509097]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  157.511120]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  157.513249] FIX anon_vma_chain: Restoring 0xffff88000bd59054-0xffff88000bd59057=0x6b

dmesg-yocto-kbuild-33:20160812160331:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  149.771714] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  149.771741] power_supply test_ac: prop ONLINE=1
[  150.360016] ==================================================================
[  150.360026] BUG: KASAN: use-after-free in anon_vma_clone+0xfb/0x375 at addr ffff880009be8b70
[  150.360029] Read of size 8 by task network.sh/574
[  150.360034] CPU: 0 PID: 574 Comm: network.sh Not tainted 4.7.0-05999-g80a9201 #1
[  150.360037] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  150.360043]  0000000000000000 ffff88000a0bfb50 ffffffff81c91ab5 ffff88000a0bfbc8
[  150.360047]  ffffffff8133576b ffffffff81315b22 0000000000000246 ffffffff81330102
[  150.360051]  ffff8800098c0d40 0000000002000200 ffffffff81315ac6 ffff88000e8131c0
[  150.360052] Call Trace:
[  150.360057]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  150.360063]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  150.360066]  [<ffffffff81315b22>] ? anon_vma_clone+0xfb/0x375
[  150.360077]  [<ffffffff81330102>] ? slab_post_alloc_hook+0x38/0x45
[  150.360080]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  150.360085]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  150.360088]  [<ffffffff81315b22>] anon_vma_clone+0xfb/0x375
[  150.360091]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  150.360096]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  150.360099]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  150.360104]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  150.360109]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  150.360112]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  150.360116]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  150.360121]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  150.360125]  [<ffffffff813479d9>] ? SyS_read+0x10b/0x138
[  150.360129]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  150.360133]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  150.360136]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  150.360140]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  150.360143] Object at ffff880009be8b68, in cache anon_vma_chain
[  150.360145] Object allocated with size 64 bytes.
[  150.360145] Allocation:
[  150.360146] PID = 574
[  150.360153]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  150.360157]  [<ffffffff81334733>] save_stack+0x46/0xce
[  150.360161]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  150.360166]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  150.360169]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  150.360173]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  150.360176]  [<ffffffff813153ea>] anon_vma_prepare+0x6b/0x2db
[  150.360180]  [<ffffffff81303aa0>] handle_mm_fault+0x683/0x11bb
[  150.360187]  [<ffffffff8111cf2b>] __do_page_fault+0x33e/0x624
[  150.360191]  [<ffffffff8111d254>] do_page_fault+0x22/0x27
[  150.360196]  [<ffffffff8111718c>] do_async_page_fault+0x2c/0x5e
[  150.360200]  [<ffffffff82c81918>] async_page_fault+0x28/0x30
[  150.360202] Memory state around the buggy address:
[  150.360205]  ffff880009be8a00: fb fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  150.360208]  ffff880009be8a80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-34:20160812160326:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  151.940151] (mount,555,0):ocfs2_fill_super:1218 ERROR: status = -22
[  151.940611] gfs2: gfs2 mount does not exist
[  151.982214] =============================================================================
[  151.982220] BUG anon_vma_chain (Not tainted): Poison overwritten
[  151.982221] -----------------------------------------------------------------------------
[  151.982221] 
[  151.982222] Disabling lock debugging due to kernel taint
[  151.982226] INFO: 0xffff88000aab0694-0xffff88000aab0697. First byte 0x6c instead of 0x6b
[  151.982235] INFO: Allocated in anon_vma_fork+0xfa/0x3f9 age=416 cpu=0 pid=458
[  151.982270] INFO: Freed in qlist_free_all+0x33/0xac age=35 cpu=0 pid=644
[  151.982322] INFO: Slab 0xffffea00002aac00 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  151.982325] INFO: Object 0xffff88000aab0688 @offset=1672 fp=0x          (null)
[  151.982325] 
[  151.982329] Redzone ffff88000aab0680: bb bb bb bb bb bb bb bb                          ........
[  151.982332] Object ffff88000aab0688: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 00 8a  kkkkkkkkkkkkl...
[  151.982335] Object ffff88000aab0698: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  151.982337] Object ffff88000aab06a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  151.982340] Object ffff88000aab06b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  151.982342] Redzone ffff88000aab06c8: bb bb bb bb bb bb bb bb                          ........
[  151.982345] Padding ffff88000aab0814: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  151.982350] CPU: 0 PID: 688 Comm: network.sh Tainted: G    B           4.7.0-05999-g80a9201 #1
[  151.982351] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  151.982357]  0000000000000000 ffff88000a307978 ffffffff81c91ab5 ffff88000a3079a8
[  151.982361]  ffffffff81330f07 ffff88000aab0694 000000000000006b ffff88000e8131c0
[  151.982364]  ffff88000aab0697 ffff88000a3079f8 ffffffff81330fac ffffffff83592f26
[  151.982365] Call Trace:
[  151.982370]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  151.982373]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  151.982377]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  151.982380]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  151.982383]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  151.982386]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  151.982390]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  151.982393]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  151.982397]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  151.982400]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  151.982403]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  151.982407]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  151.982410]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  151.982412]  [<ffffffff813153ea>] anon_vma_prepare+0x6b/0x2db
[  151.982415]  [<ffffffff812fd786>] wp_page_copy+0xa1/0x644
[  151.982417]  [<ffffffff812ff4aa>] do_wp_page+0x977/0x9b4
[  151.982420]  [<ffffffff812feb33>] ? vm_normal_page+0x128/0x128
[  151.982424]  [<ffffffff812bd1f4>] ? unlock_page+0x28/0x28
[  151.982426]  [<ffffffff81301862>] ? __pmd_alloc+0x115/0x12f
[  151.982429]  [<ffffffff81304537>] handle_mm_fault+0x111a/0x11bb
[  151.982432]  [<ffffffff811eb8bc>] ? preempt_count_add+0xc0/0xc3
[  151.982435]  [<ffffffff8130341d>] ? apply_to_page_range+0x2fb/0x2fb
[  151.982438]  [<ffffffff811eb8bc>] ? preempt_count_add+0xc0/0xc3
[  151.982441]  [<ffffffff81387556>] ? mntput+0x5f/0x64
[  151.982443]  [<ffffffff8134a18c>] ? __fput+0x488/0x4ac
[  151.982446]  [<ffffffff8130b7a5>] ? find_vma+0x18/0xef
[  151.982452]  [<ffffffff8111cf2b>] __do_page_fault+0x33e/0x624
[  151.982455]  [<ffffffff8111d254>] do_page_fault+0x22/0x27
[  151.982460]  [<ffffffff8111718c>] do_async_page_fault+0x2c/0x5e
[  151.982471]  [<ffffffff82c81918>] async_page_fault+0x28/0x30
[  151.982475] FIX anon_vma_chain: Restoring 0xffff88000aab0694-0xffff88000aab0697=0x6b
[  151.982475] 
[  151.982477] FIX anon_vma_chain: Marking all objects used

dmesg-yocto-kbuild-35:20160812160323:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  138.702116] power_supply test_battery: prop SERIAL_NUMBER=4.7.0-05999-g80a9201
[  138.792659] power_supply test_battery: prop TEMP=26
[  138.973078] ==================================================================
[  138.973116] BUG: KASAN: use-after-free in __rb_insert_augmented+0x343/0x59f at addr ffff88000b12aec8
[  138.973118] Read of size 8 by task udevd/271
[  138.973123] CPU: 0 PID: 271 Comm: udevd Not tainted 4.7.0-05999-g80a9201 #1
[  138.973125] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  138.973131]  0000000000000000 ffff88000c5bfaa8 ffffffff81c91ab5 ffff88000c5bfb20
[  138.973135]  ffffffff8133576b ffffffff81c9eeac 0000000000000246 ffffffff81332213
[  138.973139]  ffff88000c5bfb70 ffffffff81332213 0000000f00000001 ffff88000e843e48
[  138.973140] Call Trace:
[  138.973145]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  138.973156]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  138.973160]  [<ffffffff81c9eeac>] ? __rb_insert_augmented+0x343/0x59f
[  138.973164]  [<ffffffff81332213>] ? ___slab_alloc+0x284/0x31e
[  138.973167]  [<ffffffff81332213>] ? ___slab_alloc+0x284/0x31e
[  138.973171]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  138.973174]  [<ffffffff81c9eeac>] __rb_insert_augmented+0x343/0x59f
[  138.973179]  [<ffffffff812f6fc0>] ? __anon_vma_interval_tree_augment_propagate+0x75/0x75
[  138.973183]  [<ffffffff812f7df8>] anon_vma_interval_tree_insert+0x1c6/0x1d5
[  138.973187]  [<ffffffff81315c32>] anon_vma_clone+0x20b/0x375
[  138.973190]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  138.973198]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  138.973202]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  138.973205]  [<ffffffff811b0dd3>] ? do_wait+0x4c4/0x4d6
[  138.973208]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  138.973212]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  138.973217]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  138.973228]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  138.973232]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  138.973235]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  138.973239]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  138.973242]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  138.973244] Object at ffff88000b12aea8, in cache anon_vma_chain
[  138.973246] Object allocated with size 64 bytes.
[  138.973246] Allocation:
[  138.973247] PID = 318
[  138.973256]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  138.973260]  [<ffffffff81334733>] save_stack+0x46/0xce
[  138.973264]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  138.973268]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  138.973271]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  138.973275]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  138.973278]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  138.973281]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  138.973285]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  138.973288]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  138.973292]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  138.973295]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  138.973299]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  138.973300] Memory state around the buggy address:
[  138.973304]  ffff88000b12ad80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-37:20160812160328:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  150.392689] ufs: ufs was compiled with read-only support, can't be mounted as read-write
[  150.394683] UDF-fs: warning (device nullb1): udf_fill_super: No partition found (2)
[  150.601160] =============================================================================
[  150.601164] BUG names_cache (Not tainted): Poison overwritten
[  150.601165] -----------------------------------------------------------------------------
[  150.601165] 
[  150.601166] Disabling lock debugging due to kernel taint
[  150.601169] INFO: 0xffff88000963eacc-0xffff88000963eacf. First byte 0x70 instead of 0x6b
[  150.601178] INFO: Allocated in getname_kernel+0x51/0x253 age=62 cpu=0 pid=737
[  150.601225] INFO: Freed in qlist_free_all+0x33/0xac age=25 cpu=0 pid=290
[  150.601272] INFO: Slab 0xffffea0000258e00 objects=7 used=7 fp=0x          (null) flags=0x4000000000004080
[  150.601274] INFO: Object 0xffff88000963eac0 @offset=27328 fp=0xffff880009638040
[  150.601274] 
[  150.601279] Redzone ffff88000963ea80: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  150.601282] Redzone ffff88000963ea90: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  150.601284] Redzone ffff88000963eaa0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  150.601287] Redzone ffff88000963eab0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  150.601290] Object ffff88000963eac0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 70 01 e0 c0  kkkkkkkkkkkkp...
[  150.601293] Object ffff88000963ead0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  150.601295] Object ffff88000963eae0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-38:20160812160316:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  149.396812] =============================================================================
[  149.399771] BUG anon_vma_chain (Not tainted): Poison overwritten
[  149.401496] -----------------------------------------------------------------------------
[  149.401496] 
[  149.405307] Disabling lock debugging due to kernel taint
[  149.406960] INFO: 0xffff88000be1a4f5-0xffff88000be1a4f7. First byte 0x1 instead of 0x6b
[  149.409925] INFO: Allocated in anon_vma_fork+0xfa/0x3f9 age=201 cpu=0 pid=305
[  149.424986] INFO: Freed in qlist_free_all+0x33/0xac age=27 cpu=0 pid=485
[  149.445337] INFO: Slab 0xffffea00002f8680 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  149.448362] INFO: Object 0xffff88000be1a4e8 @offset=1256 fp=0xffff88000be1a828
[  149.448362] 
[  149.452019] Redzone ffff88000be1a4e0: bb bb bb bb bb bb bb bb                          ........
[  149.454912] Object ffff88000be1a4e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 a0 dc  kkkkkkkkkkkkk...
[  149.474607] Object ffff88000be1a4f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.477749] Object ffff88000be1a508: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.480855] Object ffff88000be1a518: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  149.483825] Redzone ffff88000be1a528: bb bb bb bb bb bb bb bb                          ........
[  149.486720] Padding ffff88000be1a674: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  149.489633] CPU: 0 PID: 469 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  149.492360] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  149.495379]  0000000000000000 ffff88000a78f9d8 ffffffff81c91ab5 ffff88000a78fa08
[  149.498414]  ffffffff81330f07 ffff88000be1a4f5 000000000000006b ffff88000e8131c0
[  149.501575]  ffff88000be1a4f7 ffff88000a78fa58 ffffffff81330fac ffffffff83592f26
[  149.504577] Call Trace:
[  149.505800]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  149.507531]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  149.509255]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  149.511107]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  149.512793]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  149.514481]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  149.516453]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  149.518454]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  149.520140]  [<ffffffff81334818>] ? kasan_unpoison_shadow+0x14/0x35
[  149.522062]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  149.523856]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  149.525536]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  149.527496]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  149.530189]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  149.531859]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  149.533564]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  149.535326]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  149.537149]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  149.538877]  [<ffffffff813345bf>] ? kasan_poison_slab_free+0x28/0x2a
[  149.540837]  [<ffffffff81334c54>] ? kasan_slab_free+0xa4/0xad
[  149.542632]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  149.544224]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  149.545962]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  149.547845]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  149.549648]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  149.551239]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  149.553013]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  149.554867]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  149.556665] FIX anon_vma_chain: Restoring 0xffff88000be1a4f5-0xffff88000be1a4f7=0x6b
[  149.556665] 
[  149.560164] FIX anon_vma_chain: Marking all objects used
[  149.728404] =============================================================================
[  149.731308] BUG kmalloc-128 (Tainted: G    B          ): Poison overwritten
[  149.733199] -----------------------------------------------------------------------------
[  149.733199] 
[  149.736785] INFO: 0xffff88000c30dd34-0xffff88000c30dd37. First byte 0x6d instead of 0x6b
[  149.739487] INFO: Allocated in kzalloc+0xe/0x10 age=148 cpu=0 pid=271
[  149.760918] INFO: Freed in qlist_free_all+0x33/0xac age=12 cpu=0 pid=276
[  149.784054] INFO: Slab 0xffffea000030c340 objects=8 used=8 fp=0x          (null) flags=0x4000000000000080
[  149.787183] INFO: Object 0xffff88000c30dd28 @offset=3368 fp=0xffff88000c30d5a8
[  149.787183] 
[  149.790608] Redzone ffff88000c30dd20: bb bb bb bb bb bb bb bb                          ........
[  149.793409] Object ffff88000c30dd28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6d 01 40 e0  kkkkkkkkkkkkm.@.
[  149.796318] Object ffff88000c30dd38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.799219] Object ffff88000c30dd48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-40:20160812160327:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  153.410984] power_supply test_battery: prop MODEL_NAME=Test battery
[  153.413162] power_supply test_battery: prop MANUFACTURER=Linux
[  153.563927] ==================================================================
[  153.563939] BUG: KASAN: use-after-free in unlink_anon_vmas+0x63/0x3cd at addr ffff88000a6d5bb8
[  153.563942] Read of size 8 by task mount.sh/487
[  153.563947] CPU: 0 PID: 487 Comm: mount.sh Not tainted 4.7.0-05999-g80a9201 #1
[  153.563948] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  153.563955]  0000000000000000 ffff88000a4bf918 ffffffff81c91ab5 ffff88000a4bf990
[  153.563959]  ffffffff8133576b ffffffff813156bd 0000000000000246 ffff88000b6ca6a8
[  153.563962]  ffff88000b6ca6a8 ffff88000e4fa4d8 ffff88000a4bf9a0 ffffffff812f78b3
[  153.563963] Call Trace:
[  153.563970]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  153.563975]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  153.563979]  [<ffffffff813156bd>] ? unlink_anon_vmas+0x63/0x3cd
[  153.563984]  [<ffffffff812f78b3>] ? vma_interval_tree_remove+0x5e2/0x608
[  153.563988]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  153.563991]  [<ffffffff813156bd>] unlink_anon_vmas+0x63/0x3cd
[  153.563995]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[  153.563999]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  153.564003]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  153.564008]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  153.564012]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  153.564016]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  153.564021]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[  153.564025]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[  153.564029]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  153.564033]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  153.564036]  [<ffffffff81350002>] ? vfs_getattr_nosec+0xc/0xef
[  153.564039]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  153.564044]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  153.564048]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  153.564051]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  153.564055]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  153.564058]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  153.564063]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  153.564066]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  153.564069]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  153.564073]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  153.564078]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  153.564082]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  153.564085] Object at ffff88000a6d5ba8, in cache anon_vma_chain
[  153.564086] Object allocated with size 64 bytes.
[  153.564087] Allocation:
[  153.564088] PID = 454
[  153.564095]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  153.564099]  [<ffffffff81334733>] save_stack+0x46/0xce
[  153.564102]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  153.564107]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  153.564110]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  153.564114]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  153.564117]  [<ffffffff81315e96>] anon_vma_fork+0xfa/0x3f9
[  153.564121]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  153.564124]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  153.564128]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  153.564132]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  153.564136]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  153.564136] Memory state around the buggy address:
[  153.564140]  ffff88000a6d5a80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-41:20160812160327:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  150.583689] power_supply test_ac: uevent
[  150.698497] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  150.839580] =============================================================================
[  150.839587] BUG anon_vma_chain (Not tainted): Poison overwritten
[  150.839588] -----------------------------------------------------------------------------
[  150.839588] 
[  150.839589] Disabling lock debugging due to kernel taint
[  150.839593] INFO: 0xffff88000a522695-0xffff88000a522697. First byte 0x1 instead of 0x6b
[  150.839602] INFO: Allocated in anon_vma_clone+0x9f/0x375 age=116 cpu=0 pid=366
[  150.839640] INFO: Freed in qlist_free_all+0x33/0xac age=15 cpu=0 pid=566
[  150.839687] INFO: Slab 0xffffea0000294880 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  150.839689] INFO: Object 0xffff88000a522688 @offset=1672 fp=0xffff88000a522d08
[  150.839689] 
[  150.839693] Redzone ffff88000a522680: bb bb bb bb bb bb bb bb                          ........
[  150.839697] Object ffff88000a522688: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 40 d9  kkkkkkkkkkkkk.@.
[  150.839700] Object ffff88000a522698: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  150.839703] Object ffff88000a5226a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  150.839706] Object ffff88000a5226b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  150.839708] Redzone ffff88000a5226c8: bb bb bb bb bb bb bb bb                          ........
[  150.839711] Padding ffff88000a522814: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  150.839716] CPU: 0 PID: 374 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  150.839718] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  150.839724]  0000000000000000 ffff88000af479d8 ffffffff81c91ab5 ffff88000af47a08
[  150.839728]  ffffffff81330f07 ffff88000a522695 000000000000006b ffff88000e8131c0
[  150.839733]  ffff88000a522697 ffff88000af47a58 ffffffff81330fac ffffffff83592f26
[  150.839734] Call Trace:
[  150.839739]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  150.839743]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  150.839747]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  150.839750]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  150.839753]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  150.839757]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  150.839761]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  150.839764]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  150.839769]  [<ffffffff81ccf700>] ? debug_smp_processor_id+0x17/0x19
[  150.839772]  [<ffffffff8133006c>] ? set_track+0xad/0xef
[  150.839775]  [<ffffffff81330693>] ? init_object+0x6f/0x76
[  150.839778]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  150.839782]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  150.839786]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  150.839789]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  150.839792]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  150.839796]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  150.839800]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  150.839804]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  150.839807]  [<ffffffff81350326>] ? vfs_fstatat+0xa1/0xfd
[  150.839811]  [<ffffffff81350285>] ? SYSC_newfstat+0xa6/0xa6
[  150.839814]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  150.839818]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  150.839821]  [<ffffffff8134f46b>] ? cp_old_stat+0x40b/0x40b
[  150.839825]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  150.839828]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  150.839831]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  150.839835]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  150.839839] FIX anon_vma_chain: Restoring 0xffff88000a522695-0xffff88000a522697=0x6b
[  150.839839] 

dmesg-yocto-kbuild-43:20160812160324:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  145.868056] =============================================================================
[  145.870789] BUG kmalloc-256 (Not tainted): Poison overwritten
[  145.872451] -----------------------------------------------------------------------------
[  145.872451] 
[  145.875960] Disabling lock debugging due to kernel taint
[  145.877559] INFO: 0xffff88000ad83314-0xffff88000ad83317. First byte 0x6c instead of 0x6b
[  145.880219] INFO: Allocated in do_execveat_common+0x268/0x11d2 age=171 cpu=0 pid=327
[  145.920333] INFO: Freed in qlist_free_all+0x33/0xac age=65 cpu=0 pid=271
[  145.952457] INFO: Slab 0xffffea00002b6080 objects=13 used=13 fp=0x          (null) flags=0x4000000000004080
[  145.955401] INFO: Object 0xffff88000ad83308 @offset=4872 fp=0xffff88000ad83c88
[  145.955401] 
[  146.000400] Redzone ffff88000ad83300: bb bb bb bb bb bb bb bb                          ........
[  146.003176] Object ffff88000ad83308: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 00 ae  kkkkkkkkkkkkl...
[  146.006036] Object ffff88000ad83318: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  146.008916] Object ffff88000ad83328: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-44:20160812160326:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  146.197098] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[  146.355165] power_supply test_usb: prop ONLINE=1
[  146.609170] =============================================================================
[  146.612154] BUG anon_vma_chain (Not tainted): Poison overwritten
[  146.614120] -----------------------------------------------------------------------------
[  146.614120] 
[  146.618076] Disabling lock debugging due to kernel taint
[  146.632911] INFO: 0xffff88000a3ab055-0xffff88000a3ab057. First byte 0x1 instead of 0x6b
[  146.636033] INFO: Allocated in anon_vma_clone+0x9f/0x375 age=227 cpu=0 pid=344
[  146.701951] INFO: Freed in qlist_free_all+0x33/0xac age=24 cpu=0 pid=532
[  146.749173] INFO: Slab 0xffffea000028ea80 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  146.752414] INFO: Object 0xffff88000a3ab048 @offset=4168 fp=0xffff88000a3aab68
[  146.752414] 
[  146.756153] Redzone ffff88000a3ab040: bb bb bb bb bb bb bb bb                          ........
[  146.772205] Object ffff88000a3ab048: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 20 db  kkkkkkkkkkkkk. .
[  146.775379] Object ffff88000a3ab058: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  146.778565] Object ffff88000a3ab068: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  146.781749] Object ffff88000a3ab078: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  146.797983] Redzone ffff88000a3ab088: bb bb bb bb bb bb bb bb                          ........
[  146.801127] Padding ffff88000a3ab1d4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  146.804209] CPU: 0 PID: 490 Comm: mount.sh Tainted: G    B           4.7.0-05999-g80a9201 #1
[  146.807101] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  146.810263]  0000000000000000 ffff88000ba4f4e8 ffffffff81c91ab5 ffff88000ba4f518
[  146.813604]  ffffffff81330f07 ffff88000a3ab055 000000000000006b ffff88000e8131c0
[  146.816960]  ffff88000a3ab057 ffff88000ba4f568 ffffffff81330fac ffffffff83592f26
[  146.820301] Call Trace:
[  146.821528]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  146.823260]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  146.824988]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  146.826934]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  146.828726]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  146.830503]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  146.832370]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  146.834372]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  146.836288]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  146.838214]  [<ffffffff813e5e8e>] ? load_elf_binary+0x1244/0x357c
[  146.840183]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  146.842117]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  146.844273]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  146.847121]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  146.848886]  [<ffffffff813153ea>] anon_vma_prepare+0x6b/0x2db
[  146.850652]  [<ffffffff81304113>] handle_mm_fault+0xcf6/0x11bb
[  146.852431]  [<ffffffff81330693>] ? init_object+0x6f/0x76
[  146.854215]  [<ffffffff8130341d>] ? apply_to_page_range+0x2fb/0x2fb
[  146.856132]  [<ffffffff812b1ba3>] ? perf_event_comm+0x15a/0x15a
[  146.857960]  [<ffffffff81334595>] ? kasan_poison_shadow+0x2f/0x31
[  146.859829]  [<ffffffff8130779a>] ? vma_gap_callbacks_propagate+0x75/0x75
[  146.861937]  [<ffffffff8130b86e>] ? find_vma+0xe1/0xef
[  146.863708]  [<ffffffff8111cf2b>] __do_page_fault+0x33e/0x624
[  146.865604]  [<ffffffff8111d254>] do_page_fault+0x22/0x27
[  146.867446]  [<ffffffff8111718c>] do_async_page_fault+0x2c/0x5e
[  146.869365]  [<ffffffff82c81918>] async_page_fault+0x28/0x30
[  146.871254]  [<ffffffff81cb01da>] ? __clear_user+0x3d/0x62
[  146.873063]  [<ffffffff81cb025a>] clear_user+0x5b/0x68
[  146.874765]  [<ffffffff813e138b>] padzero+0x1b/0x30
[  146.876436]  [<ffffffff813e5ebf>] load_elf_binary+0x1275/0x357c
[  146.878331]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  146.880199]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  146.882157]  [<ffffffff813e11b4>] load_script+0x4b8/0x506
[  146.883941]  [<ffffffff813e0cfc>] ? compat_SyS_ioctl+0x184d/0x184d
[  146.885819]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  146.887717]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  146.889615]  [<ffffffff81351535>] ? copy_strings+0x467/0x52d
[  146.891638]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  146.893638]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  146.895733]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  146.897771]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  146.899576]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  146.901342]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  146.903125]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  146.904840]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  146.906576]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  146.908406]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  146.910162]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  146.912145] FIX anon_vma_chain: Restoring 0xffff88000a3ab055-0xffff88000a3ab057=0x6b
[  146.912145] 
[  146.916061] FIX anon_vma_chain: Marking all objects used
[  147.008226] =============================================================================
[  147.011248] BUG kmalloc-256 (Tainted: G    B          ): Poison overwritten
[  147.013423] -----------------------------------------------------------------------------
[  147.013423] 
[  147.017336] INFO: 0xffff88000a27c015-0xffff88000a27c017. First byte 0x1 instead of 0x6b
[  147.020266] INFO: Allocated in do_execveat_common+0x268/0x11d2 age=287 cpu=0 pid=488
[  147.035728] INFO: Freed in qlist_free_all+0x33/0xac age=169 cpu=0 pid=544
[  147.071802] INFO: Slab 0xffffea0000289f00 objects=13 used=13 fp=0x          (null) flags=0x4000000000004080
[  147.075039] INFO: Object 0xffff88000a27c008 @offset=8 fp=0xffff88000a27c268
[  147.075039] 
[  147.078067] Redzone ffff88000a27c000: bb bb bb bb bb bb bb bb                          ........
[  147.094157] Object ffff88000a27c008: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 40 f9  kkkkkkkkkkkkk.@.
[  147.097355] Object ffff88000a27c018: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  147.100531] Object ffff88000a27c028: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-45:20160812160323:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  150.912791] (mount,482,0):ocfs2_fill_super:1218 ERROR: status = -22
[  150.913222] gfs2: gfs2 mount does not exist
[  151.305620] ==================================================================
[  151.305630] BUG: KASAN: use-after-free in anon_vma_clone+0xfb/0x375 at addr ffff880009d6aeb0
[  151.305633] Read of size 8 by task network.sh/672
[  151.305637] CPU: 0 PID: 672 Comm: network.sh Not tainted 4.7.0-05999-g80a9201 #1
[  151.305639] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  151.305645]  0000000000000000 ffff88000bdafb50 ffffffff81c91ab5 ffff88000bdafbc8
[  151.305649]  ffffffff8133576b ffffffff81315b22 0000000000000246 ffffffff81330102
[  151.305653]  ffff88000baec140 0000000002000200 ffffffff81315ac6 ffff88000e8131c0
[  151.305653] Call Trace:
[  151.305659]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  151.323691]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  151.323699]  [<ffffffff81315b22>] ? anon_vma_clone+0xfb/0x375
[  151.323703]  [<ffffffff81330102>] ? slab_post_alloc_hook+0x38/0x45
[  151.323706]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  151.323711]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  151.323714]  [<ffffffff81315b22>] anon_vma_clone+0xfb/0x375
[  151.323716]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  151.323721]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  151.323726]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  151.323730]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  151.323734]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  151.323738]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  151.323741]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  151.323746]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  151.323751]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  151.323755]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  151.323759]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  151.323763]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  151.323766]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  151.323769]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  151.323773] Object at ffff880009d6aea8, in cache anon_vma_chain
[  151.323775] Object allocated with size 64 bytes.
[  151.323776] Allocation:
[  151.323777] PID = 672
[  151.323783]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  151.323787]  [<ffffffff81334733>] save_stack+0x46/0xce
[  151.323791]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  151.323794]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  151.323798]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  151.323801]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  151.323805]  [<ffffffff813153ea>] anon_vma_prepare+0x6b/0x2db
[  151.323809]  [<ffffffff812fd786>] wp_page_copy+0xa1/0x644
[  151.323812]  [<ffffffff812ff4aa>] do_wp_page+0x977/0x9b4
[  151.323816]  [<ffffffff81304537>] handle_mm_fault+0x111a/0x11bb
[  151.323819]  [<ffffffff8111cf2b>] __do_page_fault+0x33e/0x624
[  151.323823]  [<ffffffff8111d254>] do_page_fault+0x22/0x27
[  151.323828]  [<ffffffff8111718c>] do_async_page_fault+0x2c/0x5e
[  151.323831]  [<ffffffff82c81918>] async_page_fault+0x28/0x30
[  151.323832] Memory state around the buggy address:
[  151.323836]  ffff880009d6ad80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  151.323839]  ffff880009d6ae00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-46:20160812160324:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  153.755290] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[  153.827240] power_supply test_usb: prop ONLINE=1
[  154.032733] ==================================================================
[  154.035803] BUG: KASAN: use-after-free in unlink_anon_vmas+0x205/0x3cd at addr ffff88000a3531f8
[  154.039047] Read of size 8 by task udevd/567
[  154.040709] CPU: 0 PID: 567 Comm: udevd Not tainted 4.7.0-05999-g80a9201 #1
[  154.055980] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  154.059274]  0000000000000000 ffff880009827728 ffffffff81c91ab5 ffff8800098277a0
[  154.062734]  ffffffff8133576b ffffffff8131585f 0000000000000246 0000000000000000
[  154.066238]  0000000000000000 ffff880009f38a28 ffff8800098277b0 ffffffff812f83e9
[  154.105075] Call Trace:
[  154.106445]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  154.108206]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  154.110110]  [<ffffffff8131585f>] ? unlink_anon_vmas+0x205/0x3cd
[  154.125230]  [<ffffffff812f83e9>] ? anon_vma_interval_tree_remove+0x5e2/0x608
[  154.133569]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  154.135719]  [<ffffffff8131585f>] unlink_anon_vmas+0x205/0x3cd
[  154.140746]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[  154.142767]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  154.150654]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  154.158597]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  154.172574]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  154.174378]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  154.176150]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[  154.178175]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[  154.180164]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  154.200218]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  154.202298]  [<ffffffff813e11b4>] load_script+0x4b8/0x506
[  154.204167]  [<ffffffff813e0cfc>] ? compat_SyS_ioctl+0x184d/0x184d
[  154.206221]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  154.226238]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  154.228228]  [<ffffffff81351535>] ? copy_strings+0x467/0x52d
[  154.230159]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  154.231888]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  154.233713]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  154.235476]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  154.237142]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  154.238785]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  154.253735]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  154.255582]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  154.257444]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  154.259189]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  154.260811]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  154.262572] Object at ffff88000a3531e8, in cache anon_vma_chain
[  154.264245] Object allocated with size 64 bytes.
[  154.278853] Allocation:
[  154.280203] PID = 456
[  154.281488]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  154.283529]  [<ffffffff81334733>] save_stack+0x46/0xce
[  154.285501]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  154.287210]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  154.288932]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  154.290719]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  154.305750]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  154.307822]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  154.309846]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  154.312065]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  154.313914]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  154.315549]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  154.330331]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  154.332514] Memory state around the buggy address:
[  154.334306]  ffff88000a353080: 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-48:20160812160324:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  159.942048] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[  159.944028] power_supply test_battery: prop MODEL_NAME=Test battery
[  159.947815] =============================================================================
[  159.947820] BUG skbuff_head_cache (Not tainted): Poison overwritten
[  159.947821] -----------------------------------------------------------------------------
[  159.947821] 
[  159.947822] Disabling lock debugging due to kernel taint
[  159.947825] INFO: 0xffff88000bc3accc-0xffff88000bc3accf. First byte 0x6e instead of 0x6b
[  159.947834] INFO: Allocated in __alloc_skb+0xad/0x498 age=64 cpu=0 pid=282
[  159.947874] INFO: Freed in qlist_free_all+0x33/0xac age=18 cpu=0 pid=293
[  159.947917] INFO: Slab 0xffffea00002f0e80 objects=12 used=0 fp=0xffff88000bc3b440 flags=0x4000000000004080
[  159.947920] INFO: Object 0xffff88000bc3acc0 @offset=3264 fp=0xffff88000bc3aa40
[  159.947920] 
[  159.947924] Redzone ffff88000bc3ac80: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  159.947927] Redzone ffff88000bc3ac90: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  159.947929] Redzone ffff88000bc3aca0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  159.947932] Redzone ffff88000bc3acb0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  159.947935] Object ffff88000bc3acc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6e 01 40 ad  kkkkkkkkkkkkn.@.
[  159.947938] Object ffff88000bc3acd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  159.947940] Object ffff88000bc3ace0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-4:20160812160333:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  148.893414] gfs2: gfs2 mount does not exist
[  148.918637] floppy: error -5 while reading block 0
[  148.992652] =============================================================================
[  148.992658] BUG kmalloc-32 (Not tainted): Poison overwritten
[  148.992659] -----------------------------------------------------------------------------
[  148.992659] 
[  148.992661] Disabling lock debugging due to kernel taint
[  148.992664] INFO: 0xffff88000ac5a314-0xffff88000ac5a317. First byte 0x75 instead of 0x6b
[  148.992676] INFO: Allocated in __list_lru_init+0x43/0xff age=216 cpu=0 pid=551
[  148.992725] INFO: Freed in qlist_free_all+0x33/0xac age=74 cpu=0 pid=665
[  148.992773] INFO: Slab 0xffffea00002b1680 objects=10 used=10 fp=0x          (null) flags=0x4000000000000080
[  148.992776] INFO: Object 0xffff88000ac5a308 @offset=776 fp=0xffff88000ac5ad88
[  148.992776] 
[  148.992781] Redzone ffff88000ac5a300: bb bb bb bb bb bb bb bb                          ........
[  148.992784] Object ffff88000ac5a308: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 75 01 a0 c9  kkkkkkkkkkkku...
[  148.992787] Object ffff88000ac5a318: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  148.992789] Redzone ffff88000ac5a328: bb bb bb bb bb bb bb bb                          ........
[  148.992791] Padding ffff88000ac5a474: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  148.992797] CPU: 0 PID: 289 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  148.992799] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  148.992806]  0000000000000000 ffff88000b0dfb78 ffffffff81c91ab5 ffff88000b0dfba8
[  148.992810]  ffffffff81330f07 ffff88000ac5a314 000000000000006b ffff88000e802540
[  148.992814]  ffff88000ac5a317 ffff88000b0dfbf8 ffffffff81330fac ffffffff83592f26
[  148.992815] Call Trace:
[  148.992821]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  148.992825]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  148.992828]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  148.992831]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  148.992834]  [<ffffffff812e617c>] ? shmem_symlink+0x122/0x378
[  148.992838]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  148.992841]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  148.992844]  [<ffffffff812e617c>] ? shmem_symlink+0x122/0x378
[  148.992850]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  148.992853]  [<ffffffff812e617c>] ? shmem_symlink+0x122/0x378
[  148.992857]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  148.992860]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  148.992864]  [<ffffffff813343df>] __kmalloc_track_caller+0x84/0xea
[  148.992867]  [<ffffffff812e94c7>] kmemdup+0x1b/0x3c
[  148.992870]  [<ffffffff812e617c>] shmem_symlink+0x122/0x378
[  148.992873]  [<ffffffff812e605a>] ? shmem_file_read_iter+0x4d6/0x4d6
[  148.992877]  [<ffffffff8135c6b7>] ? __inode_permission+0x148/0x1d3
[  148.992880]  [<ffffffff8135c7ff>] ? inode_permission+0xbd/0xc4
[  148.992884]  [<ffffffff8136632b>] vfs_symlink+0x79/0x98
[  148.992888]  [<ffffffff81366453>] SYSC_symlinkat+0x109/0x16f
[  148.992891]  [<ffffffff8136634a>] ? vfs_symlink+0x98/0x98
[  148.992895]  [<ffffffff813664d5>] SyS_symlink+0x11/0x13

dmesg-yocto-kbuild-50:20160812160327:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[  145.360617] =============================================================================
[  145.363600] BUG kmalloc-64 (Not tainted): Poison overwritten
[  145.365347] -----------------------------------------------------------------------------
[  145.365347] 
[  145.369153] Disabling lock debugging due to kernel taint
[  145.370952] INFO: 0xffff88000b7a5d54-0xffff88000b7a5d57. First byte 0x6d instead of 0x6b
[  145.373899] INFO: Allocated in kernfs_fop_open+0x6fb/0x840 age=250 cpu=0 pid=271
[  145.393698] INFO: Freed in qlist_free_all+0x33/0xac age=132 cpu=0 pid=321
[  145.419234] INFO: Slab 0xffffea00002de900 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  145.441005] INFO: Object 0xffff88000b7a5d48 @offset=7496 fp=0xffff88000b7a4b68
[  145.441005] 
[  145.444790] Redzone ffff88000b7a5d40: bb bb bb bb bb bb bb bb                          ........
[  145.447896] Object ffff88000b7a5d48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6d 01 20 db  kkkkkkkkkkkkm. .
[  145.451037] Object ffff88000b7a5d58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  145.454072] Object ffff88000b7a5d68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  145.457184] Object ffff88000b7a5d78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  145.460342] Redzone ffff88000b7a5d88: bb bb bb bb bb bb bb bb                          ........
[  145.463352] Padding ffff88000b7a5ed4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  145.466504] CPU: 0 PID: 534 Comm: logger Tainted: G    B           4.7.0-05999-g80a9201 #1
[  145.469520] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  145.472651]  0000000000000000 ffff880009d67b98 ffffffff81c91ab5 ffff880009d67bc8
[  145.475977]  ffffffff81330f07 ffff88000b7a5d54 000000000000006b ffff88000e8036c0
[  145.479161]  ffff88000b7a5d57 ffff880009d67c18 ffffffff81330fac ffffffff83592f26
[  145.482460] Call Trace:
[  145.483718]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  145.485474]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  145.487310]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  145.489299]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  145.491090]  [<ffffffff8299f639>] ? sock_alloc_inode+0x5f/0x1f5
[  145.492975]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  145.494898]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  145.496938]  [<ffffffff81330156>] ? slab_free_freelist_hook+0x47/0x50
[  145.498827]  [<ffffffff8299f639>] ? sock_alloc_inode+0x5f/0x1f5
[  145.500618]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  145.502369]  [<ffffffff8299f639>] ? sock_alloc_inode+0x5f/0x1f5
[  145.504167]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  145.506196]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  145.509023]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  145.510892]  [<ffffffff8299f639>] sock_alloc_inode+0x5f/0x1f5
[  145.512747]  [<ffffffff81379312>] alloc_inode+0x5b/0x122
[  145.514469]  [<ffffffff8137aefc>] new_inode_pseudo+0xc/0xc8
[  145.516208]  [<ffffffff829a22fd>] sock_alloc+0x3c/0x1f1
[  145.517876]  [<ffffffff829a3607>] __sock_create+0x85/0x1c9
[  145.519671]  [<ffffffff829a37ce>] sock_create+0x83/0x8e
[  145.521409]  [<ffffffff829a3853>] SYSC_socket+0x7a/0x102
[  145.536221]  [<ffffffff829a37d9>] ? sock_create+0x8e/0x8e
[  145.538043]  [<ffffffff810027d4>] ? prepare_exit_to_usermode+0x139/0x16d

dmesg-yocto-kbuild-52:20160812160315:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  150.636351]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  150.636354]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  150.636359]  [<ffffffff81351535>] ? copy_strings+0x467/0x52d
[  150.636363]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  150.636367]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  150.636371]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  150.636375]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  150.636378]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  150.636382]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  150.636385]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  150.636389]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  150.636392]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  150.636395]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  150.636399]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  150.636401] Object at ffff88000b397b40, in cache vm_area_struct
[  150.636402] Object allocated with size 184 bytes.
[  150.636403] Allocation:
[  150.636404] PID = 486
[  150.636408]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  150.636412]  [<ffffffff81334733>] save_stack+0x46/0xce
[  150.636416]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  150.636420]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  150.636424]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  150.636428]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  150.636432]  [<ffffffff8130e558>] mmap_region+0x33a/0xa41
[  150.636435]  [<ffffffff8130f24e>] do_mmap+0x5ef/0x66a
[  150.636439]  [<ffffffff812e992d>] vm_mmap_pgoff+0x122/0x174
[  150.636442]  [<ffffffff812e99af>] vm_mmap+0x30/0x32
[  150.636446]  [<ffffffff813e1b67>] elf_map+0x179/0x18c
[  150.636449]  [<ffffffff813e5a54>] load_elf_binary+0xe0a/0x357c
[  150.636453]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  150.636456]  [<ffffffff813e11b4>] load_script+0x4b8/0x506
[  150.636460]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  150.636465]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  150.636468]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  150.636472]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  150.636476]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  150.636479]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  150.636480] Memory state around the buggy address:
[  150.636483]  ffff88000b397a00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-53:20160812160332:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  147.829833] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[  147.829858] power_supply test_usb: prop ONLINE=1
[  149.112220] =============================================================================
[  149.112225] BUG anon_vma_chain (Not tainted): Poison overwritten
[  149.112226] -----------------------------------------------------------------------------
[  149.112226] 
[  149.112227] Disabling lock debugging due to kernel taint
[  149.112230] INFO: 0xffff88000a4efa14-0xffff88000a4efa17. First byte 0x7e instead of 0x6b
[  149.112238] INFO: Allocated in anon_vma_prepare+0x6b/0x2db age=155 cpu=0 pid=687
[  149.112297] INFO: Freed in qlist_free_all+0x33/0xac age=90 cpu=0 pid=498
[  149.112342] INFO: Slab 0xffffea0000293b80 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  149.112344] INFO: Object 0xffff88000a4efa08 @offset=6664 fp=0xffff88000a4ef868
[  149.112344] 
[  149.112348] Redzone ffff88000a4efa00: bb bb bb bb bb bb bb bb                          ........
[  149.112351] Object ffff88000a4efa08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 a0 bd  kkkkkkkkkkkk~...
[  149.112354] Object ffff88000a4efa18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.112357] Object ffff88000a4efa28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.112360] Object ffff88000a4efa38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  149.112363] Redzone ffff88000a4efa48: bb bb bb bb bb bb bb bb                          ........
[  149.112366] Padding ffff88000a4efb94: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  149.112371] CPU: 0 PID: 597 Comm: mount.sh Tainted: G    B           4.7.0-05999-g80a9201 #1
[  149.112373] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  149.112379]  0000000000000000 ffff88000bdbfa48 ffffffff81c91ab5 ffff88000bdbfa78
[  149.112383]  ffffffff81330f07 ffff88000a4efa14 000000000000006b ffff88000e8131c0
[  149.112387]  ffff88000a4efa17 ffff88000bdbfac8 ffffffff81330fac ffffffff83592f26
[  149.112388] Call Trace:
[  149.112393]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  149.112396]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  149.112400]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  149.112403]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  149.112407]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  149.112410]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  149.112414]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  149.112417]  [<ffffffff81334818>] ? kasan_unpoison_shadow+0x14/0x35
[  149.112420]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  149.112425]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  149.112428]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  149.112431]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  149.112435]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  149.112438]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  149.112441]  [<ffffffff81315e96>] anon_vma_fork+0xfa/0x3f9
[  149.112446]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  149.112449]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  149.112453]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  149.112456]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  149.112460]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  149.112463]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  149.112467]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  149.112470]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  149.112474]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  149.112478] FIX anon_vma_chain: Restoring 0xffff88000a4efa14-0xffff88000a4efa17=0x6b

dmesg-yocto-kbuild-54:20160812160325:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  144.320302] blk_update_request: I/O error, dev fd0, sector 0
[  144.320306] floppy: error -5 while reading block 0
[  144.342545] =============================================================================
[  144.342551] BUG vm_area_struct (Not tainted): Poison overwritten
[  144.342552] -----------------------------------------------------------------------------
[  144.342552] 
[  144.342553] Disabling lock debugging due to kernel taint
[  144.342557] INFO: 0xffff8800098f2444-0xffff8800098f2447. First byte 0x7e instead of 0x6b
[  144.342566] INFO: Allocated in __split_vma+0x5b/0x48f age=220 cpu=0 pid=640
[  144.342597] INFO: Freed in qlist_free_all+0x33/0xac age=138 cpu=0 pid=681
[  144.342635] INFO: Slab 0xffffea0000263c80 objects=15 used=15 fp=0x          (null) flags=0x4000000000004080
[  144.342637] INFO: Object 0xffff8800098f2438 @offset=1080 fp=0xffff8800098f2c98
[  144.342637] 
[  144.342641] Redzone ffff8800098f2430: bb bb bb bb bb bb bb bb                          ........
[  144.342644] Object ffff8800098f2438: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 a0 95  kkkkkkkkkkkk~...
[  144.342647] Object ffff8800098f2448: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  144.342649] Object ffff8800098f2458: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-55:20160812160312:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  147.996187] power_supply test_ac: uevent
[  147.997594] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  148.018547] =============================================================================
[  148.018551] BUG kmalloc-256 (Not tainted): Poison overwritten
[  148.018552] -----------------------------------------------------------------------------
[  148.018552] 
[  148.018553] Disabling lock debugging due to kernel taint
[  148.018557] INFO: 0xffff880009cdf7d5-0xffff880009cdf7d7. First byte 0x1 instead of 0x6b
[  148.018568] INFO: Allocated in do_execveat_common+0x268/0x11d2 age=167 cpu=0 pid=454
[  148.018598] INFO: Freed in qlist_free_all+0x33/0xac age=72 cpu=0 pid=268
[  148.018648] INFO: Slab 0xffffea0000273780 objects=13 used=13 fp=0x          (null) flags=0x4000000000004080
[  148.018651] INFO: Object 0xffff880009cdf7c8 @offset=6088 fp=0xffff880009cdebe8
[  148.018651] 
[  148.018655] Redzone ffff880009cdf7c0: bb bb bb bb bb bb bb bb                          ........
[  148.018665] Object ffff880009cdf7c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 80 f6  kkkkkkkkkkkkk...
[  148.018668] Object ffff880009cdf7d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  148.018671] Object ffff880009cdf7e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-57:20160812160319:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  134.994218] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[  134.996365] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[  135.050884] =============================================================================
[  135.050898] BUG anon_vma_chain (Not tainted): Poison overwritten
[  135.050899] -----------------------------------------------------------------------------
[  135.050899] 
[  135.050901] Disabling lock debugging due to kernel taint
[  135.050904] INFO: 0xffff880009d001b5-0xffff880009d001b7. First byte 0x1 instead of 0x6b
[  135.050963] INFO: Allocated in anon_vma_clone+0x9f/0x375 age=287 cpu=0 pid=363
[  135.051063] INFO: Freed in qlist_free_all+0x33/0xac age=15 cpu=0 pid=479
[  135.051115] INFO: Slab 0xffffea0000274000 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  135.051117] INFO: Object 0xffff880009d001a8 @offset=424 fp=0xffff880009d01ba8
[  135.051117] 
[  135.051122] Redzone ffff880009d001a0: bb bb bb bb bb bb bb bb                          ........
[  135.051125] Object ffff880009d001a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 01 c0 ca  kkkkkkkkkkkkk...
[  135.051128] Object ffff880009d001b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.051130] Object ffff880009d001c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.051133] Object ffff880009d001d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  135.051135] Redzone ffff880009d001e8: bb bb bb bb bb bb bb bb                          ........
[  135.051138] Padding ffff880009d00334: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  135.051153] CPU: 0 PID: 350 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  135.051159] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  135.051179]  0000000000000000 ffff88000ba0f9d8 ffffffff81c91ab5 ffff88000ba0fa08
[  135.051183]  ffffffff81330f07 ffff880009d001b5 000000000000006b ffff88000e8131c0
[  135.051187]  ffff880009d001b7 ffff88000ba0fa58 ffffffff81330fac ffffffff83592f26
[  135.051188] Call Trace:
[  135.051215]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  135.051219]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  135.051222]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  135.051226]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  135.051229]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  135.051233]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  135.051236]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  135.051245]  [<ffffffff812f6e90>] ? __anon_vma_interval_tree_compute_subtree_last+0x31/0xec
[  135.051248]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  135.051252]  [<ffffffff812f7027>] ? __anon_vma_interval_tree_augment_rotate+0x67/0x74
[  135.051261]  [<ffffffff81c9f0f9>] ? __rb_insert_augmented+0x590/0x59f
[  135.051265]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  135.051269]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  135.051273]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  135.051276]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  135.051279]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  135.051282]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  135.051286]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  135.051290]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  135.051294]  [<ffffffff811b0dd3>] ? do_wait+0x4c4/0x4d6
[  135.051298]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  135.051307]  [<ffffffff811b0eee>] ? SYSC_wait4+0x109/0x140
[  135.051311]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  135.051315]  [<ffffffff811b0de5>] ? do_wait+0x4d6/0x4d6
[  135.051319]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  135.051323]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  135.051326]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  135.051330]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  135.051335] FIX anon_vma_chain: Restoring 0xffff880009d001b5-0xffff880009d001b7=0x6b
[  135.051335] 
[  135.051337] FIX anon_vma_chain: Marking all objects used
[  135.930883] ==================================================================
[  135.930894] BUG: KASAN: use-after-free in __rb_erase_color+0x4d8/0x750 at addr ffff88000a824d28
[  135.930896] Read of size 8 by task udevd/566
[  135.930901] CPU: 0 PID: 566 Comm: udevd Tainted: G    B           4.7.0-05999-g80a9201 #1
[  135.930903] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  135.930909]  0000000000000000 ffff880009547870 ffffffff81c91ab5 ffff8800095478e8
[  135.930912]  ffffffff8133576b ffffffff81c9d71c 0000000000000246 0000000100130012
[  135.930916]  ffff88000b353ba8 ffff8800095478c8 ffffffff812f6e90 ffff88000b353bc8
[  135.930917] Call Trace:
[  135.930922]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  135.930927]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  135.930930]  [<ffffffff81c9d71c>] ? __rb_erase_color+0x4d8/0x750
[  135.930935]  [<ffffffff812f6e90>] ? __anon_vma_interval_tree_compute_subtree_last+0x31/0xec
[  135.930939]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  135.930942]  [<ffffffff81c9d71c>] __rb_erase_color+0x4d8/0x750
[  135.930946]  [<ffffffff812f6fc0>] ? __anon_vma_interval_tree_augment_propagate+0x75/0x75
[  135.930949]  [<ffffffff812f8400>] anon_vma_interval_tree_remove+0x5f9/0x608
[  135.930953]  [<ffffffff8131573e>] unlink_anon_vmas+0xe4/0x3cd
[  135.930956]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[  135.930959]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  135.930962]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  135.930975]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  135.930993]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  135.930997]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  135.931002]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[  135.931012]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[  135.931016]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  135.931019]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  135.931023]  [<ffffffff81350002>] ? vfs_getattr_nosec+0xc/0xef
[  135.931026]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  135.931029]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  135.931033]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  135.931036]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  135.931040]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  135.931043]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  135.931047]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  135.931050]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  135.931053]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  135.931057]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  135.931069]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  135.931073]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  135.931075] Object at ffff88000a824d08, in cache anon_vma_chain
[  135.931076] Object allocated with size 64 bytes.
[  135.931077] Allocation:
[  135.931078] PID = 268
[  135.931090]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  135.931094]  [<ffffffff81334733>] save_stack+0x46/0xce
[  135.931098]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  135.931101]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  135.931105]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  135.931108]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  135.931111]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  135.931114]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  135.931118]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  135.931121]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  135.931124]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  135.931127]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  135.931131]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  135.931132] Memory state around the buggy address:
[  135.931135]  ffff88000a824c00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-58:20160812160314:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  152.431919] gfs2: gfs2 mount does not exist
[  152.459680] floppy: error -5 while reading block 0
[  152.606162] =============================================================================
[  152.606166] BUG names_cache (Not tainted): Poison overwritten
[  152.606167] -----------------------------------------------------------------------------
[  152.606167] 
[  152.606168] Disabling lock debugging due to kernel taint
[  152.606171] INFO: 0xffff880009ce590c-0xffff880009ce590f. First byte 0x6e instead of 0x6b
[  152.606180] INFO: Allocated in getname_flags+0x5a/0x35c age=44 cpu=0 pid=283
[  152.606210] INFO: Freed in qlist_free_all+0x33/0xac age=1 cpu=0 pid=268
[  152.606247] INFO: Slab 0xffffea0000273800 objects=7 used=7 fp=0x          (null) flags=0x4000000000004080
[  152.606249] INFO: Object 0xffff880009ce5900 @offset=22784 fp=0x          (null)
[  152.606249] 
[  152.606254] Redzone ffff880009ce58c0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  152.606256] Redzone ffff880009ce58d0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  152.606259] Redzone ffff880009ce58e0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  152.606262] Redzone ffff880009ce58f0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
[  152.606264] Object ffff880009ce5900: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6e 01 a0 87  kkkkkkkkkkkkn...
[  152.606267] Object ffff880009ce5910: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.606270] Object ffff880009ce5920: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-59:20160812160317:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  148.755267] power_supply test_battery: prop CHARGE_TYPE=Fast
[  149.008506] power_supply test_battery: prop HEALTH=Good
** 77806 printk messages dropped ** 
[  149.468068]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
** 89 printk messages dropped ** 
[  149.468329]  [<ffffffff811a71bd>] __mmput+0x58/0x181
** 109 printk messages dropped ** 
[  149.468646]  [<ffffffff811b10c0>] ? is_current_pgrp_orphaned+0x96/0x96
** 130 printk messages dropped ** 

dmesg-yocto-kbuild-5:20160812160332:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  144.711527] power_supply test_battery: prop SERIAL_NUMBER=4.7.0-05999-g80a9201
[  144.713298] floppy: error -5 while reading block 0
[  144.713953] =============================================================================
[  144.713955] BUG kmalloc-4096 (Not tainted): Poison overwritten
[  144.713956] -----------------------------------------------------------------------------
[  144.713956] 
[  144.713957] Disabling lock debugging due to kernel taint
[  144.713959] INFO: 0xffff88000a1fe854-0xffff88000a1fe857. First byte 0x6e instead of 0x6b
[  144.713967] INFO: Allocated in kobject_uevent_env+0x1b1/0x8d4 age=19 cpu=0 pid=271
[  144.713998] INFO: Freed in qlist_free_all+0x33/0xac age=5 cpu=0 pid=292
[  144.714021] INFO: Slab 0xffffea0000287e00 objects=7 used=7 fp=0x          (null) flags=0x4000000000004080
[  144.714022] INFO: Object 0xffff88000a1fe848 @offset=26696 fp=0xffff88000a1f8008
[  144.714022] 
[  144.714025] Redzone ffff88000a1fe840: bb bb bb bb bb bb bb bb                          ........
[  144.714027] Object ffff88000a1fe848: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6e 01 00 98  kkkkkkkkkkkkn...
[  144.714028] Object ffff88000a1fe858: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  144.714030] Object ffff88000a1fe868: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

dmesg-yocto-kbuild-60:20160812160329:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  150.802074] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  150.802100] power_supply test_ac: prop ONLINE=1
[  151.086177] =============================================================================
[  151.086182] BUG anon_vma_chain (Not tainted): Poison overwritten
[  151.086183] -----------------------------------------------------------------------------
[  151.086183] 
[  151.086184] Disabling lock debugging due to kernel taint
[  151.086187] INFO: 0xffff88000adafa14-0xffff88000adafa17. First byte 0x6c instead of 0x6b
[  151.086196] INFO: Allocated in anon_vma_fork+0xfa/0x3f9 age=139 cpu=0 pid=477
[  151.086229] INFO: Freed in qlist_free_all+0x33/0xac age=14 cpu=0 pid=638
[  151.086268] INFO: Slab 0xffffea00002b6b80 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  151.086270] INFO: Object 0xffff88000adafa08 @offset=6664 fp=0xffff88000adaed08
[  151.086270] 
[  151.086274] Redzone ffff88000adafa00: bb bb bb bb bb bb bb bb                          ........
[  151.086277] Object ffff88000adafa08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 01 20 87  kkkkkkkkkkkkl. .
[  151.086280] Object ffff88000adafa18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  151.086283] Object ffff88000adafa28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  151.086285] Object ffff88000adafa38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  151.086288] Redzone ffff88000adafa48: bb bb bb bb bb bb bb bb                          ........
[  151.086291] Padding ffff88000adafb94: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  151.086295] CPU: 0 PID: 608 Comm: network.sh Tainted: G    B           4.7.0-05999-g80a9201 #1
[  151.086297] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  151.086303]  0000000000000000 ffff88000b3ff9d8 ffffffff81c91ab5 ffff88000b3ffa08
[  151.086307]  ffffffff81330f07 ffff88000adafa14 000000000000006b ffff88000e8131c0
[  151.086311]  ffff88000adafa17 ffff88000b3ffa58 ffffffff81330fac ffffffff83592f26
[  151.086312] Call Trace:
[  151.086317]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  151.086321]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  151.086324]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  151.086328]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  151.086331]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  151.086334]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  151.086338]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  151.086341]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  151.086345]  [<ffffffff81ccf700>] ? debug_smp_processor_id+0x17/0x19
[  151.086348]  [<ffffffff8133006c>] ? set_track+0xad/0xef
[  151.086351]  [<ffffffff81330693>] ? init_object+0x6f/0x76
[  151.086354]  [<ffffffff81315ac6>] ? anon_vma_clone+0x9f/0x375
[  151.086358]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  151.086361]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  151.086365]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  151.086367]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  151.086370]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  151.086374]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  151.086378]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  151.086381]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  151.086386]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  151.086390]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  151.086393]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  151.086398]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  151.086403]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  151.086407]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  151.086409]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  151.086413]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  151.086416]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  151.086420]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  151.086423] FIX anon_vma_chain: Restoring 0xffff88000adafa14-0xffff88000adafa17=0x6b

dmesg-yocto-kbuild-61:20160812160317:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  148.176815] (mount,609,0):ocfs2_fill_super:1218 ERROR: status = -22
[  148.177281] gfs2: gfs2 mount does not exist
[  148.198474] ==================================================================
[  148.198485] BUG: KASAN: use-after-free in free_pgtables+0x9a/0x13e at addr ffff880009a9f710
[  148.198488] Read of size 8 by task network.sh/668
[  148.198493] CPU: 0 PID: 668 Comm: network.sh Not tainted 4.7.0-05999-g80a9201 #1
[  148.198495] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  148.198501]  0000000000000000 ffff88000a73f970 ffffffff81c91ab5 ffff88000a73f9e8
[  148.198505]  ffffffff8133576b ffffffff812fe7b6 0000000000000246 ffffffff81313438
[  148.198509]  ffff88000a73f700 1ffff1000136ccd7 ffff88000e446ba8 ffff88000e446bb0
[  148.198510] Call Trace:
[  148.198516]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  148.198521]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  148.198525]  [<ffffffff812fe7b6>] ? free_pgtables+0x9a/0x13e
[  148.198529]  [<ffffffff81313438>] ? anon_vma_chain_free+0x13/0x15
[  148.198533]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  148.198537]  [<ffffffff812fe7b6>] free_pgtables+0x9a/0x13e
[  148.198541]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  148.198544]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  148.198549]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  148.198553]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  148.198556]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  148.198561]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[  148.198565]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[  148.198568]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  148.198572]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  148.198576]  [<ffffffff81350002>] ? vfs_getattr_nosec+0xc/0xef
[  148.198579]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  148.198583]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  148.198587]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  148.198591]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  148.198595]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  148.198598]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  148.198601]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  148.198605]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  148.198608]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  148.198620]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  148.198625]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  148.198629]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  148.198631] Object at ffff880009a9f710, in cache vm_area_struct
[  148.198632] Object allocated with size 184 bytes.
[  148.198632] Allocation:
[  148.198634] PID = 622
[  148.198639]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  148.198642]  [<ffffffff81334733>] save_stack+0x46/0xce
[  148.198645]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  148.198649]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  148.198652]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  148.198655]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  148.198659]  [<ffffffff811a9b50>] copy_process+0x2323/0x424c
[  148.198662]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  148.198665]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  148.198668]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  148.198671]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  148.198672] Memory state around the buggy address:
[  148.198675]  ffff880009a9f600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-63:20160812160323:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  143.103669] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[  143.216075] power_supply test_ac: prop ONLINE=1
[  143.428482] ==================================================================
[  143.428514] BUG: KASAN: use-after-free in unlink_anon_vmas+0x205/0x3cd at addr ffff88000b63c1b8
[  143.428517] Read of size 8 by task mount.sh/564
[  143.428522] CPU: 0 PID: 564 Comm: mount.sh Not tainted 4.7.0-05999-g80a9201 #1
[  143.428524] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  143.428530]  0000000000000000 ffff88000a39f918 ffffffff81c91ab5 ffff88000a39f990
[  143.428534]  ffffffff8133576b ffffffff8131585f 0000000000000246 0000000000000000
[  143.428538]  0000000000000000 ffff88000aae9e08 ffff88000a39f9a0 ffffffff812f83e9
[  143.428539] Call Trace:
[  143.428551]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  143.428556]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  143.428560]  [<ffffffff8131585f>] ? unlink_anon_vmas+0x205/0x3cd
[  143.428565]  [<ffffffff812f83e9>] ? anon_vma_interval_tree_remove+0x5e2/0x608
[  143.428569]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  143.428572]  [<ffffffff8131585f>] unlink_anon_vmas+0x205/0x3cd
[  143.428575]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[  143.428579]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  143.428582]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  143.428591]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  143.428599]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  143.428602]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  143.428607]  [<ffffffff81353b6c>] flush_old_exec+0x1102/0x124a
[  143.428616]  [<ffffffff813e53c0>] load_elf_binary+0x776/0x357c
[  143.428619]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  143.428623]  [<ffffffff811f144c>] ? __might_sleep+0x156/0x162
[  143.428627]  [<ffffffff81350002>] ? vfs_getattr_nosec+0xc/0xef
[  143.428630]  [<ffffffff813e4c4a>] ? elf_core_dump+0x30d0/0x30d0
[  143.428634]  [<ffffffff813549eb>] search_binary_handler+0x100/0x1fb
[  143.428638]  [<ffffffff81355912>] do_execveat_common+0xe2c/0x11d2
[  143.428641]  [<ffffffff81354ae6>] ? search_binary_handler+0x1fb/0x1fb
[  143.428645]  [<ffffffff81332bab>] ? kmem_cache_alloc+0xa8/0xb6
[  143.428648]  [<ffffffff8135c29a>] ? getname_flags+0x337/0x35c
[  143.428662]  [<ffffffff82c80830>] ? ptregs_sys_vfork+0x10/0x10
[  143.428666]  [<ffffffff81355cd6>] do_execve+0x1e/0x20
[  143.428669]  [<ffffffff813564b5>] SyS_execve+0x25/0x29
[  143.428673]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  143.428678]  [<ffffffff8111d254>] ? do_page_fault+0x22/0x27
[  143.428681]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  143.428683] Object at ffff88000b63c1a8, in cache anon_vma_chain
[  143.428685] Object allocated with size 64 bytes.
[  143.428686] Allocation:
[  143.428687] PID = 444
[  143.428698]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  143.428702]  [<ffffffff81334733>] save_stack+0x46/0xce
[  143.428706]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  143.428710]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  143.428714]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  143.428717]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  143.428720]  [<ffffffff81315ac6>] anon_vma_clone+0x9f/0x375
[  143.428723]  [<ffffffff81315e34>] anon_vma_fork+0x98/0x3f9
[  143.428728]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  143.428731]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  143.428734]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  143.428738]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  143.428741]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  143.428742] Memory state around the buggy address:
[  143.428746]  ffff88000b63c080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-64:20160812160322:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  143.636301] power_supply test_ac: prop ONLINE=1
[  143.968996] ufs: ufs was compiled with read-only support, can't be mounted as read-write
[  144.029482] ==================================================================
[  144.029493] BUG: KASAN: use-after-free in unlink_anon_vmas+0x63/0x3cd at addr ffff88000b224d18
[  144.029496] Read of size 8 by task network.sh/696
[  144.029501] CPU: 0 PID: 696 Comm: network.sh Not tainted 4.7.0-05999-g80a9201 #1
[  144.029503] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  144.029509]  0000000000000000 ffff88000ade7b70 ffffffff81c91ab5 ffff88000ade7be8
[  144.029514]  ffffffff8133576b ffffffff813156bd 0000000000000246 ffff88000ad468c0
[  144.029517]  ffff88000a826490 ffff88000e446ba8 ffff88000ade7bf8 ffffffff812f78b3
[  144.029518] Call Trace:
[  144.029524]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  144.029530]  [<ffffffff8133576b>] kasan_report+0x319/0x553
[  144.029533]  [<ffffffff813156bd>] ? unlink_anon_vmas+0x63/0x3cd
[  144.029538]  [<ffffffff812f78b3>] ? vma_interval_tree_remove+0x5e2/0x608
[  144.029542]  [<ffffffff813359fb>] __asan_report_load8_noabort+0x14/0x16
[  144.029545]  [<ffffffff813156bd>] unlink_anon_vmas+0x63/0x3cd
[  144.029549]  [<ffffffff812fe804>] free_pgtables+0xe8/0x13e
[  144.029553]  [<ffffffff8130bb3a>] exit_mmap+0x13e/0x2b2
[  144.029556]  [<ffffffff8130b9fc>] ? split_vma+0x96/0x96
[  144.029561]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  144.029565]  [<ffffffff811a71bd>] __mmput+0x58/0x181
[  144.029569]  [<ffffffff811a730e>] mmput+0x28/0x2b
[  144.029572]  [<ffffffff811b1a0f>] do_exit+0x94f/0x19e0
[  144.029576]  [<ffffffff811b10c0>] ? is_current_pgrp_orphaned+0x96/0x96
[  144.029581]  [<ffffffff8111d106>] ? __do_page_fault+0x519/0x624
[  144.029584]  [<ffffffff811b2bc7>] do_group_exit+0xe8/0x227
[  144.029588]  [<ffffffff811b2d1e>] SyS_exit_group+0x18/0x18
[  144.029592]  [<ffffffff82c80673>] entry_SYSCALL_64_fastpath+0x1e/0xa8
[  144.029594] Object at ffff88000b224d08, in cache anon_vma_chain
[  144.029596] Object allocated with size 64 bytes.
[  144.029597] Allocation:
[  144.029598] PID = 694
[  144.029604]  [<ffffffff810f473d>] save_stack_trace+0x25/0x40
[  144.029608]  [<ffffffff81334733>] save_stack+0x46/0xce
[  144.029611]  [<ffffffff81334d14>] kasan_kmalloc+0xb7/0xc6
[  144.029615]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
[  144.029619]  [<ffffffff81330102>] slab_post_alloc_hook+0x38/0x45
[  144.029623]  [<ffffffff81332bab>] kmem_cache_alloc+0xa8/0xb6
[  144.029626]  [<ffffffff81315e96>] anon_vma_fork+0xfa/0x3f9
[  144.029630]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  144.029634]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  144.029637]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  144.029641]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  144.029645]  [<ffffffff82c80722>] return_from_SYSCALL_64+0x0/0x6a
[  144.029646] Memory state around the buggy address:
[  144.029650]  ffff88000b224c00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

dmesg-yocto-kbuild-7:20160812160334:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  149.605230] (mount,662,0):ocfs2_fill_super:1218 ERROR: status = -22
[  149.605667] gfs2: gfs2 mount does not exist
[  149.630718] =============================================================================
[  149.630723] BUG anon_vma_chain (Not tainted): Poison overwritten
[  149.630724] -----------------------------------------------------------------------------
[  149.630724] 
[  149.630725] Disabling lock debugging due to kernel taint
[  149.630729] INFO: 0xffff88000ab98694-0xffff88000ab98697. First byte 0x7e instead of 0x6b
[  149.630738] INFO: Allocated in anon_vma_prepare+0x6b/0x2db age=177 cpu=0 pid=648
[  149.630773] INFO: Freed in qlist_free_all+0x33/0xac age=63 cpu=0 pid=518
[  149.630824] INFO: Slab 0xffffea00002ae600 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  149.630827] INFO: Object 0xffff88000ab98688 @offset=1672 fp=0xffff88000ab98d08
[  149.630827] 
[  149.630831] Redzone ffff88000ab98680: bb bb bb bb bb bb bb bb                          ........
[  149.630834] Object ffff88000ab98688: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 80 c5  kkkkkkkkkkkk~...
[  149.630837] Object ffff88000ab98698: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.630839] Object ffff88000ab986a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.630842] Object ffff88000ab986b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  149.630844] Redzone ffff88000ab986c8: bb bb bb bb bb bb bb bb                          ........
[  149.630847] Padding ffff88000ab98814: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  149.630852] CPU: 0 PID: 678 Comm: cat Tainted: G    B           4.7.0-05999-g80a9201 #1
[  149.630854] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  149.630859]  0000000000000000 ffff880009a0f978 ffffffff81c91ab5 ffff880009a0f9a8
[  149.630863]  ffffffff81330f07 ffff88000ab98694 000000000000006b ffff88000e8131c0
[  149.630867]  ffff88000ab98697 ffff880009a0f9f8 ffffffff81330fac ffffffff83592f26
[  149.630868] Call Trace:
[  149.630873]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  149.630876]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  149.630880]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  149.630883]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  149.630886]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  149.630890]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  149.630893]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  149.630896]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  149.630901]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  149.630904]  [<ffffffff813153ea>] ? anon_vma_prepare+0x6b/0x2db
[  149.630908]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  149.630911]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  149.630914]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  149.630917]  [<ffffffff813153ea>] anon_vma_prepare+0x6b/0x2db
[  149.630920]  [<ffffffff812fd786>] wp_page_copy+0xa1/0x644
[  149.630923]  [<ffffffff812ff4aa>] do_wp_page+0x977/0x9b4
[  149.630927]  [<ffffffff812feb33>] ? vm_normal_page+0x128/0x128
[  149.630931]  [<ffffffff812bd1f4>] ? unlock_page+0x28/0x28
[  149.630935]  [<ffffffff812d5f0b>] ? lru_cache_add_active_or_unevictable+0x52/0xb0
[  149.630938]  [<ffffffff813015fe>] ? alloc_set_pte+0x5e4/0x5f7
[  149.630942]  [<ffffffff81304537>] handle_mm_fault+0x111a/0x11bb
[  149.630945]  [<ffffffff8130341d>] ? apply_to_page_range+0x2fb/0x2fb
[  149.630948]  [<ffffffff8130f24e>] ? do_mmap+0x5ef/0x66a
[  149.630952]  [<ffffffff8130b7a5>] ? find_vma+0x18/0xef
[  149.630955]  [<ffffffff8111cf2b>] __do_page_fault+0x33e/0x624
[  149.630959]  [<ffffffff8111d254>] do_page_fault+0x22/0x27
[  149.630963]  [<ffffffff8111718c>] do_async_page_fault+0x2c/0x5e
[  149.630966]  [<ffffffff82c81918>] async_page_fault+0x28/0x30
[  149.630969] FIX anon_vma_chain: Restoring 0xffff88000ab98694-0xffff88000ab98697=0x6b
[  149.630969] 
[  149.630971] FIX anon_vma_chain: Marking all objects used
[  149.658122] =============================================================================
[  149.658127] BUG anon_vma_chain (Tainted: G    B          ): Poison overwritten
[  149.658128] -----------------------------------------------------------------------------
[  149.658128] 
[  149.658131] INFO: 0xffff88000aa61a14-0xffff88000aa61a17. First byte 0x7e instead of 0x6b
[  149.671160] INFO: Allocated in anon_vma_prepare+0x6b/0x2db age=181 cpu=0 pid=628
[  149.671201] INFO: Freed in qlist_free_all+0x33/0xac age=71 cpu=0 pid=518
[  149.671248] INFO: Slab 0xffffea00002a9800 objects=19 used=19 fp=0x          (null) flags=0x4000000000004080
[  149.671251] INFO: Object 0xffff88000aa61a08 @offset=6664 fp=0xffff88000aa61868
[  149.671251] 
[  149.671255] Redzone ffff88000aa61a00: bb bb bb bb bb bb bb bb                          ........
[  149.671257] Object ffff88000aa61a08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 7e 00 80 c5  kkkkkkkkkkkk~...
[  149.671260] Object ffff88000aa61a18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.671263] Object ffff88000aa61a28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  149.671266] Object ffff88000aa61a38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  149.671268] Redzone ffff88000aa61a48: bb bb bb bb bb bb bb bb                          ........
[  149.671271] Padding ffff88000aa61b94: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ
[  149.671276] CPU: 0 PID: 647 Comm: network.sh Tainted: G    B           4.7.0-05999-g80a9201 #1
[  149.671277] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  149.671283]  0000000000000000 ffff88000a257a48 ffffffff81c91ab5 ffff88000a257a78
[  149.671287]  ffffffff81330f07 ffff88000aa61a14 000000000000006b ffff88000e8131c0
[  149.671291]  ffff88000aa61a17 ffff88000a257ac8 ffffffff81330fac ffffffff83592f26
[  149.671292] Call Trace:
[  149.671298]  [<ffffffff81c91ab5>] dump_stack+0x19/0x1b
[  149.671301]  [<ffffffff81330f07>] print_trailer+0x15b/0x164
[  149.671305]  [<ffffffff81330fac>] check_bytes_and_report+0x9c/0xef
[  149.671308]  [<ffffffff8133194d>] check_object+0x12f/0x1fb
[  149.671311]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  149.671314]  [<ffffffff81331f00>] alloc_debug_processing+0x7e/0x10d
[  149.671318]  [<ffffffff8133211b>] ___slab_alloc+0x18c/0x31e
[  149.671321]  [<ffffffff81334818>] ? kasan_unpoison_shadow+0x14/0x35
[  149.671324]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  149.671329]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  149.671331]  [<ffffffff81315e96>] ? anon_vma_fork+0xfa/0x3f9
[  149.671335]  [<ffffffff813322c3>] __slab_alloc+0x16/0x2a
[  149.671338]  [<ffffffff813322c3>] ? __slab_alloc+0x16/0x2a
[  149.671342]  [<ffffffff81332b53>] kmem_cache_alloc+0x50/0xb6
[  149.671344]  [<ffffffff81315e96>] anon_vma_fork+0xfa/0x3f9
[  149.671349]  [<ffffffff811a9c9a>] copy_process+0x246d/0x424c
[  149.671353]  [<ffffffff811a782d>] ? __cleanup_sighand+0x23/0x23
[  149.671357]  [<ffffffff81380da8>] ? put_unused_fd+0x6f/0x6f
[  149.671361]  [<ffffffff811f1079>] ? ___might_sleep+0xa4/0x321
[  149.671364]  [<ffffffff811abe13>] _do_fork+0x159/0x3d9
[  149.671367]  [<ffffffff811abcba>] ? fork_idle+0x1ed/0x1ed
[  149.671372]  [<ffffffff813596a7>] ? __do_pipe_flags+0x1aa/0x1aa
[  149.671375]  [<ffffffff813479d9>] ? SyS_read+0x10b/0x138
[  149.671378]  [<ffffffff82c80800>] ? ptregs_sys_rt_sigreturn+0x10/0x10
[  149.671382]  [<ffffffff811ac105>] SyS_clone+0x14/0x16
[  149.671385]  [<ffffffff81002ab8>] do_syscall_64+0x1be/0x1fa
[  149.671389]  [<ffffffff82c80722>] entry_SYSCALL64_slow_path+0x25/0x25
[  149.671392] FIX anon_vma_chain: Restoring 0xffff88000aa61a14-0xffff88000aa61a17=0x6b
[  149.671392] 

dmesg-yocto-kbuild-9:20160812160304:x86_64-randconfig-s0-08040601:4.7.0-05999-g80a9201:1

[  139.260618] befs: (nullb1): invalid magic header
[  139.261355] (mount,579,0):ocfs2_fill_super:1024 ERROR: superblock probe failed!
** 2687 printk messages dropped ** 
[  139.999781]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
** 3147 printk messages dropped ** 
[  140.221781]  [<ffffffff8111b37c>] ? force_sig_info_fault+0x189/0x1b5
[  140.235843]  [<ffffffff8111b1f3>] ? is_prefetch+0x264/0x264
[  140.235851]  [<ffffffff810e0f92>] ? setup_sigcontext+0x4d2/0x4d2
** 91563 printk messages dropped ** 
[  141.023269]  [<ffffffff81334d35>] kasan_slab_alloc+0x12/0x14
** 88 printk messages dropped ** 
[  141.023521]  [<ffffffff812ffbec>] ? unmap_page_range+0x705/0x949
** 110 printk messages dropped ** 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
