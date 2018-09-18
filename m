Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDF6D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 19:00:36 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t3-v6so3537098oif.20
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 16:00:36 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l66-v6si8685624oib.164.2018.09.18.16.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 16:00:34 -0700 (PDT)
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
 <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <5efc291c-b0ed-577e-02d1-285d080c293d@oracle.com>
 <ciirm8va743105.fsf@u54ee758033e858cfa736.ant.amazon.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <7221975d-6b67-effa-2747-06c22c041e78@oracle.com>
Date: Tue, 18 Sep 2018 17:00:12 -0600
MIME-Version: 1.0
In-Reply-To: <ciirm8va743105.fsf@u54ee758033e858cfa736.ant.amazon.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Stecklina <jsteckli@amazon.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On 09/17/2018 03:51 AM, Julian Stecklina wrote:
> Khalid Aziz <khalid.aziz@oracle.com> writes:
> 
>> I ran tests with your updated code and gathered lock statistics. Change in
>> system time for "make -j60" was in the noise margin (It actually went up by
>> about 2%). There is some contention on xpfo_lock. Average wait time does not
>> look high compared to other locks. Max hold time looks a little long. From
>> /proc/lock_stat:
>>
>>                &(&page->xpfo_lock)->rlock:         29698          29897           0.06         134.39       15345.58           0.51      422474670      960222532           0.05       30362.05   195807002.62           0.20
>>
>> Nevertheless even a smaller average wait time can add up.
> 
> Thanks for doing this!
> 
> I've spent some time optimizing spinlock usage in the code. See the two
> last commits in my xpfo-master branch[1]. The optimization in
> xpfo_kunmap is pretty safe. The last commit that optimizes locking in
> xpfo_kmap is tricky, though, and I'm not sure this is the right
> approach. FWIW, I've modeled this locking strategy in Spin and it
> doesn't find any problems with it.
> 
> I've tested the result on a box with 72 hardware threads and I didn't
> see a meaningful difference in kernel compile performance. It's still
> hovering around 2%. So the question is, whether it's actually useful to
> do these optimizations.
> 
> Khalid, you mentioned 5% overhead. Can you give the new code a spin and
> see whether anything changes?

Hi Julian,

I tested the kernel with this new code. When booted without "xpfotlbflush", 
there is no meaningful change in system time with kernel compile. Kernel 
locks up during bootup when booted with xpfotlbflush:

[   52.967060] RIP: 0010:queued_spin_lock_slowpath+0xf6/0x1e0
[   52.967061] Code: 48 03 34 c5 80 97 12 82 48 89 16 8b 42 08 85 c0 75 09 f3 90 8b 42 08 85 c0 74 f7 48 8b 32 48 85 f6 74 07 0f 0d 0e eb 02 f3 90 <8b> 07 66 85 c0 75 f7 41 89 c0 66 45 31 c0 41 39 c8 0f 84 93 00 00
[   52.967061] RSP: 0018:ffffc9001cc83a00 EFLAGS: 00000002
[   52.967062] RAX: 0000000000340101 RBX: ffffea06c16292e8 RCX: 0000000000580000
[   52.967062] RDX: ffff88603c9e3980 RSI: 0000000000000000 RDI: ffffea06c16292e8
[   52.967063] RBP: ffffea06c1629300 R08: 0000000000000001 R09: 0000000000000000
[   52.967063] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88c02765a000
[   52.967063] R13: 0000000000000000 R14: ffff8860152a0d00 R15: 0000000000000000
[   52.967064] FS:  00007f41ad1658c0(0000) GS:ffff88603c800000(0000) knlGS:0000000000000000
[   52.967064] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   52.967064] CR2: ffff88c02765a000 CR3: 00000060252e4003 CR4: 00000000007606e0
[   52.967065] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   52.967065] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   52.967065] PKRU: 55555554
[   52.967066] Call Trace:
[   52.967066]  do_raw_spin_lock+0x6d/0xa0
[   52.967066]  _raw_spin_lock+0x53/0x70
[   52.967067]  ? xpfo_do_map+0x1b/0x52
[   52.967067]  xpfo_do_map+0x1b/0x52
[   52.967067]  xpfo_spurious_fault+0xac/0xae
[   52.967068]  __do_page_fault+0x3cc/0x4e0
[   52.967068]  ? __lock_acquire.isra.31+0x165/0x710
[   52.967068]  do_page_fault+0x32/0x180
[   52.967068]  page_fault+0x1e/0x30
[   52.967069] RIP: 0010:memcpy_erms+0x6/0x10
[   52.967069] Code: 90 90 90 90 eb 1e 0f 1f 00 48 89 f8 48 89 d1 48 c1 e9 03 83 e2 07 f3 48 a5 89 d1 f3 a4 c3 66 0f 1f 44 00 00 48 89 f8 48 89 d1 <f3> a4 c3 0f 1f 80 00 00 00 00 48 89 f8 48 83 fa 20 72 7e 40 38 fe
[   52.967070] RSP: 0018:ffffc9001cc83bb8 EFLAGS: 00010246
[   52.967070] RAX: ffff8860299d0f00 RBX: ffffc9001cc83dc8 RCX: 0000000000000080
[   52.967071] RDX: 0000000000000080 RSI: ffff88c02765a000 RDI: ffff8860299d0f00
[   52.967071] RBP: 0000000000000080 R08: ffffc9001cc83d90 R09: 0000000000000001
[   52.967071] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000080
[   52.967072] R13: 0000000000000080 R14: 0000000000000000 R15: ffff88c02765a080
[   52.967072]  _copy_to_iter+0x3b6/0x430
[   52.967072]  copy_page_to_iter+0x1cf/0x390
[   52.967073]  ? pagecache_get_page+0x26/0x200
[   52.967073]  generic_file_read_iter+0x620/0xaf0
[   52.967073]  ? avc_has_perm+0x12e/0x200
[   52.967074]  ? avc_has_perm+0x34/0x200
[   52.967074]  ? sched_clock+0x5/0x10
[   52.967074]  __vfs_read+0x112/0x190
[   52.967074]  vfs_read+0x8c/0x140
[   52.967075]  kernel_read+0x2c/0x40
[   52.967075]  prepare_binprm+0x121/0x230
[   52.967075]  __do_execve_file.isra.32+0x56f/0x930
[   52.967076]  ? __do_execve_file.isra.32+0x140/0x930
[   52.967076]  __x64_sys_execve+0x44/0x50
[   52.967076]  do_syscall_64+0x5b/0x190
[   52.967077]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[   52.967077] RIP: 0033:0x7f41abd898c7
[   52.967078] Code: ff ff 76 df 89 c6 f7 de 64 41 89 32 eb d5 89 c6 f7 de 64 41 89 32 eb db 66 2e 0f 1f 84 00 00 00 00 00 90 b8 3b 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 02 f3 c3 48 8b 15 98 05 30 00 f7 d8 64 89 02
[   52.967078] RSP: 002b:00007ffc34b18f48 EFLAGS: 00000207 ORIG_RAX: 000000000000003b
[   52.967078] RAX: ffffffffffffffda RBX: 00007ffc34b190a0 RCX: 00007f41abd898c7
[   52.967079] RDX: 00005573e1da99d0 RSI: 00007ffc34b190a0 RDI: 00007ffc34b194a0
[   52.967079] RBP: 00005573e0895140 R08: 0000000000000008 R09: 0000000000000383
[   52.967080] R10: 0000000000000008 R11: 0000000000000207 R12: 00005573e1da99d0
[   52.967080] R13: 0000000000000007 R14: 000000000000000c R15: 00007ffc34b1ad10
[   52.967080] Kernel panic - not syncing: Hard LOCKUP
[   52.967081] CPU: 21 PID: 1127 Comm: systemd-udevd Not tainted 4.19.0-rc3-xpfo+ #3
[   52.967081] Hardware name: Oracle Corporation ORACLE SERVER X7-2/ASM, MB, X7-2, BIOS 41017600 10/06/2017
[   52.967081] Call Trace:
[   52.967082]  <NMI>
[   52.967082]  dump_stack+0x5a/0x73
[   52.967082]  panic+0xe8/0x25c
[   52.967082]  nmi_panic+0x37/0x40
[   52.967083]  watchdog_overflow_callback+0xef/0x110
[   52.967083]  __perf_event_overflow+0x51/0xe0
[   52.967083]  intel_pmu_handle_irq+0x222/0x4c0
[   52.967084]  ? _raw_spin_unlock+0x24/0x30
[   52.967084]  ? ghes_copy_tofrom_phys+0xf2/0x1a0
[   52.967084]  ? ghes_read_estatus+0x91/0x160
[   52.967085]  perf_event_nmi_handler+0x2e/0x50
[   52.967085]  nmi_handle+0x9a/0x180
[   52.967085]  ? nmi_handle+0x5/0x180
[   52.967086]  default_do_nmi+0xca/0x120
[   52.967086]  do_nmi+0x100/0x160
[   52.967086]  end_repeat_nmi+0x16/0x50
[   52.967086] RIP: 0010:queued_spin_lock_slowpath+0xf6/0x1e0
[   52.967087] Code: 48 03 34 c5 80 97 12 82 48 89 16 8b 42 08 85 c0 75 09 f3 90 8b 42 08 85 c0 74 f7 48 8b 32 48 85 f6 74 07 0f 0d 0e eb 02 f3 90 <8b> 07 66 85 c0 75 f7 41 89 c0 66 45 31 c0 41 39 c8 0f 84 93 00 00
[   52.967087] RSP: 0018:ffffc9001cc83a00 EFLAGS: 00000002
[   52.967088] RAX: 0000000000340101 RBX: ffffea06c16292e8 RCX: 0000000000580000
[   52.967088] RDX: ffff88603c9e3980 RSI: 0000000000000000 RDI: ffffea06c16292e8
[   52.967089] RBP: ffffea06c1629300 R08: 0000000000000001 R09: 0000000000000000
[   52.967089] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88c02765a000
[   52.967089] R13: 0000000000000000 R14: ffff8860152a0d00 R15: 0000000000000000
[   52.967090]  ? queued_spin_lock_slowpath+0xf6/0x1e0
[   52.967090]  ? queued_spin_lock_slowpath+0xf6/0x1e0
[   52.967090]  </NMI>
[   52.967091]  do_raw_spin_lock+0x6d/0xa0
[   52.967091]  _raw_spin_lock+0x53/0x70
[   52.967091]  ? xpfo_do_map+0x1b/0x52
[   52.967092]  xpfo_do_map+0x1b/0x52
[   52.967092]  xpfo_spurious_fault+0xac/0xae
[   52.967092]  __do_page_fault+0x3cc/0x4e0
[   52.967092]  ? __lock_acquire.isra.31+0x165/0x710
[   52.967093]  do_page_fault+0x32/0x180
[   52.967093]  page_fault+0x1e/0x30
[   52.967093] RIP: 0010:memcpy_erms+0x6/0x10
[   52.967094] Code: 90 90 90 90 eb 1e 0f 1f 00 48 89 f8 48 89 d1 48 c1 e9 03 83 e2 07 f3 48 a5 89 d1 f3 a4 c3 66 0f 1f 44 00 00 48 89 f8 48 89 d1 <f3> a4 c3 0f 1f 80 00 00 00 00 48 89 f8 48 83 fa 20 72 7e 40 38 fe
[   52.967094] RSP: 0018:ffffc9001cc83bb8 EFLAGS: 00010246
[   52.967095] RAX: ffff8860299d0f00 RBX: ffffc9001cc83dc8 RCX: 0000000000000080
[   52.967095] RDX: 0000000000000080 RSI: ffff88c02765a000 RDI: ffff8860299d0f00
[   52.967096] RBP: 0000000000000080 R08: ffffc9001cc83d90 R09: 0000000000000001
[   52.967096] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000080
[   52.967096] R13: 0000000000000080 R14: 0000000000000000 R15: ffff88c02765a080
[   52.967097]  _copy_to_iter+0x3b6/0x430
[   52.967097]  copy_page_to_iter+0x1cf/0x390
[   52.967097]  ? pagecache_get_page+0x26/0x200
[   52.967098]  generic_file_read_iter+0x620/0xaf0
[   52.967098]  ? avc_has_perm+0x12e/0x200
[   52.967098]  ? avc_has_perm+0x34/0x200
[   52.967098]  ? sched_clock+0x5/0x10
[   52.967099]  __vfs_read+0x112/0x190
[   52.967099]  vfs_read+0x8c/0x140
[   52.967099]  kernel_read+0x2c/0x40
[   52.967100]  prepare_binprm+0x121/0x230
[   52.967100]  __do_execve_file.isra.32+0x56f/0x930
[   52.967100]  ? __do_execve_file.isra.32+0x140/0x930
[   52.967101]  __x64_sys_execve+0x44/0x50
[   52.967101]  do_syscall_64+0x5b/0x190
[   52.967101]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[   52.967102] RIP: 0033:0x7f41abd898c7
[   52.967102] Code: ff ff 76 df 89 c6 f7 de 64 41 89 32 eb d5 89 c6 f7 de 64 41 89 32 eb db 66 2e 0f 1f 84 00 00 00 00 00 90 b8 3b 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 02 f3 c3 48 8b 15 98 05 30 00 f7 d8 64 89 02
[   52.967102] RSP: 002b:00007ffc34b18f48 EFLAGS: 00000207 ORIG_RAX: 000000000000003b
[   52.967103] RAX: ffffffffffffffda RBX: 00007ffc34b190a0 RCX: 00007f41abd898c7
[   52.967103] RDX: 00005573e1da99d0 RSI: 00007ffc34b190a0 RDI: 00007ffc34b194a0
[   52.967104] RBP: 00005573e0895140 R08: 0000000000000008 R09: 0000000000000383
[   52.967104] R10: 0000000000000008 R11: 0000000000000207 R12: 00005573e1da99d0
[   52.967104] R13: 0000000000000007 R14: 000000000000000c R15: 00007ffc34b1ad10
[   54.001888] Shutting down cpus with NMI
[   54.001889] Kernel Offset: disabled
[   54.860701] ---[ end Kernel panic - not syncing: Hard LOCKUP ]---
[   54.867733] ------------[ cut here ]------------
[   54.867734] unchecked MSR access error: WRMSR to 0x83f (tried to write 0x00000000000000f6) at rIP: 0xffffffff81055864 (native_write_msr+0x4/0x20)
[   54.867734] Call Trace:
[   54.867734]  <IRQ>
[   54.867735]  native_apic_msr_write+0x2e/0x40
[   54.867735]  arch_irq_work_raise+0x28/0x40
[   54.867735]  irq_work_queue+0x69/0x70
[   54.867736]  printk_safe_log_store+0xd0/0xf0
[   54.867736]  printk+0x58/0x6f
[   54.867736]  __warn_printk+0x46/0x90
[   54.867737]  ? enqueue_task_fair+0x8e/0x760
[   54.867737]  native_smp_send_reschedule+0x39/0x40
[   54.867737]  check_preempt_curr+0x75/0xb0
[   54.867738]  ttwu_do_wakeup+0x19/0x190
[   54.867738]  try_to_wake_up+0x21e/0x4f0
[   54.867738]  __wake_up_common+0x9d/0x190
[   54.867738]  ep_poll_callback+0xd5/0x370
[   54.867739]  ? ep_poll_callback+0x2b5/0x370
[   54.867739]  __wake_up_common+0x9d/0x190
[   54.867739]  __wake_up_common_lock+0x7a/0xc0
[   54.867740]  irq_work_run_list+0x4c/0x70
[   54.867740]  smp_call_function_interrupt+0x59/0x110
[   54.867740]  call_function_interrupt+0xf/0x20
[   54.867741]  </IRQ>
[   54.867741]  <NMI>
[   54.867741] RIP: 0010:panic+0x206/0x25c
[   54.867742] Code: 83 3d 11 83 c9 01 00 74 05 e8 d2 87 02 00 48 c7 c6 80 15 d1 82 48 c7 c7 80 fe 06 82 31 c0 e8 71 ed 06 00 fb 66 0f 1f 44 00 00 <45> 31 e4 e8 de 11 0e 00 4d 39 ec 7c 1e 41 83 f6 01 48 8b 05 ce 82
[   54.867742] RSP: 0018:fffffe00003a4b58 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff03
[   54.867743] RAX: 0000000000000038 RBX: fffffe00003a4e00 RCX: 0000000000000000
[   54.867743] RDX: 0000000000000000 RSI: 0000000000000038 RDI: ffff88603c9d5d08
[   54.867744] RBP: fffffe00003a4bc8 R08: 0000000000000000 R09: ffff88603c9d5d47
[   54.867744] R10: 000000000000000b R11: 0000000000000000 R12: ffffffff8207b979
[   54.867744] R13: 0000000000000000 R14: 0000000000000000 R15: ffff88603c80f560
[   54.867745]  ? panic+0x1ff/0x25c
[   54.867745]  nmi_panic+0x37/0x40
[   54.867745]  watchdog_overflow_callback+0xef/0x110
[   54.867746]  __perf_event_overflow+0x51/0xe0
[   54.867746]  intel_pmu_handle_irq+0x222/0x4c0
[   54.867746]  ? _raw_spin_unlock+0x24/0x30
[   54.867747]  ? ghes_copy_tofrom_phys+0xf2/0x1a0
[   54.867747]  ? ghes_read_estatus+0x91/0x160
[   54.867747]  perf_event_nmi_handler+0x2e/0x50
[   54.867748]  nmi_handle+0x9a/0x180
[   54.867748]  ? nmi_handle+0x5/0x180
[   54.867748]  default_do_nmi+0xca/0x120
[   54.867748]  do_nmi+0x100/0x160
[   54.867749]  end_repeat_nmi+0x16/0x50
[   54.867749] RIP: 0010:queued_spin_lock_slowpath+0xf6/0x1e0
[   54.867750] Code: 48 03 34 c5 80 97 12 82 48 89 16 8b 42 08 85 c0 75 09 f3 90 8b 42 08 85 c0 74 f7 48 8b 32 48 85 f6 74 07 0f 0d 0e eb 02 f3 90 <8b> 07 66 85 c0 75 f7 41 89 c0 66 45 31 c0 41 39 c8 0f 84 93 00 00
[   54.867750] RSP: 0018:ffffc9001cc83a00 EFLAGS: 00000002
[   54.867751] RAX: 0000000000340101 RBX: ffffea06c16292e8 RCX: 0000000000580000
[   54.867751] RDX: ffff88603c9e3980 RSI: 0000000000000000 RDI: ffffea06c16292e8
[   54.867751] RBP: ffffea06c1629300 R08: 0000000000000001 R09: 0000000000000000
[   54.867752] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88c02765a000
[   54.867752] R13: 0000000000000000 R14: ffff8860152a0d00 R15: 0000000000000000
[   54.867752]  ? queued_spin_lock_slowpath+0xf6/0x1e0
[   54.867753]  ? queued_spin_lock_slowpath+0xf6/0x1e0
[   54.867753]  </NMI>
[   54.867753]  do_raw_spin_lock+0x6d/0xa0
[   54.867754]  _raw_spin_lock+0x53/0x70
[   54.867754]  ? xpfo_do_map+0x1b/0x52
[   54.867754]  xpfo_do_map+0x1b/0x52
[   54.867754]  xpfo_spurious_fault+0xac/0xae
[   54.867755]  __do_page_fault+0x3cc/0x4e0
[   54.867755]  ? __lock_acquire.isra.31+0x165/0x710
[   54.867755]  do_page_fault+0x32/0x180
[   54.867756]  page_fault+0x1e/0x30
[   54.867756] RIP: 0010:memcpy_erms+0x6/0x10
[   54.867757] Code: 90 90 90 90 eb 1e 0f 1f 00 48 89 f8 48 89 d1 48 c1 e9 03 83 e2 07 f3 48 a5 89 d1 f3 a4 c3 66 0f 1f 44 00 00 48 89 f8 48 89 d1 <f3> a4 c3 0f 1f 80 00 00 00 00 48 89 f8 48 83 fa 20 72 7e 40 38 fe
[   54.867757] RSP: 0018:ffffc9001cc83bb8 EFLAGS: 00010246
[   54.867758] RAX: ffff8860299d0f00 RBX: ffffc9001cc83dc8 RCX: 0000000000000080
[   54.867758] RDX: 0000000000000080 RSI: ffff88c02765a000 RDI: ffff8860299d0f00
[   54.867758] RBP: 0000000000000080 R08: ffffc9001cc83d90 R09: 0000000000000001
[   54.867759] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000080
[   54.867759] R13: 0000000000000080 R14: 0000000000000000 R15: ffff88c02765a080
[   54.867759]  _copy_to_iter+0x3b6/0x430
[   54.867760]  copy_page_to_iter+0x1cf/0x390
[   54.867760]  ? pagecache_get_page+0x26/0x200
[   54.867760]  generic_file_read_iter+0x620/0xaf0
[   54.867761]  ? avc_has_perm+0x12e/0x200
[   54.867761]  ? avc_has_perm+0x34/0x200
[   54.867761]  ? sched_clock+0x5/0x10
[   54.867761]  __vfs_read+0x112/0x190
[   54.867762]  vfs_read+0x8c/0x140
[   54.867762]  kernel_read+0x2c/0x40
[   54.867762]  prepare_binprm+0x121/0x230
[   54.867763]  __do_execve_file.isra.32+0x56f/0x930
[   54.867763]  ? __do_execve_file.isra.32+0x140/0x930
[   54.867763]  __x64_sys_execve+0x44/0x50
[   54.867764]  do_syscall_64+0x5b/0x190
[   54.867764]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[   54.867764] RIP: 0033:0x7f41abd898c7
[   54.867765] Code: ff ff 76 df 89 c6 f7 de 64 41 89 32 eb d5 89 c6 f7 de 64 41 89 32 eb db 66 2e 0f 1f 84 00 00 00 00 00 90 b8 3b 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 02 f3 c3 48 8b 15 98 05 30 00 f7 d8 64 89 02
[   54.867765] RSP: 002b:00007ffc34b18f48 EFLAGS: 00000207 ORIG_RAX: 000000000000003b
[   54.867766] RAX: ffffffffffffffda RBX: 00007ffc34b190a0 RCX: 00007f41abd898c7
[   54.867766] RDX: 00005573e1da99d0 RSI: 00007ffc34b190a0 RDI: 00007ffc34b194a0
[   54.867767] RBP: 00005573e0895140 R08: 0000000000000008 R09: 0000000000000383
[   54.867767] R10: 0000000000000008 R11: 0000000000000207 R12: 00005573e1da99d0
[   54.867767] R13: 0000000000000007 R14: 000000000000000c R15: 00007ffc34b1ad10
[   54.867768] sched: Unexpected reschedule of offline CPU#4!
[   54.867768] WARNING: CPU: 21 PID: 1127 at arch/x86/kernel/smp.c:128 native_smp_send_reschedule+0x39/0x40
[   54.867768] Modules linked in: crc32c_intel nvme nvme_core igb megaraid_sas ahci i2c_algo_bit bnxt_en libahci i2c_core libata dca dm_mirror dm_region_hash dm_log dm_mod
[   54.867773] CPU: 21 PID: 1127 Comm: systemd-udevd Not tainted 4.19.0-rc3-xpfo+ #3
[   54.867773] Hardware name: Oracle Corporation ORACLE SERVER X7-2/ASM, MB, X7-2, BIOS 41017600 10/06/2017
[   54.867773] RIP: 0010:native_smp_send_reschedule+0x39/0x40
[   54.867774] Code: 0f 92 c0 84 c0 74 15 48 8b 05 13 84 0f 01 be fd 00 00 00 48 8b 40 30 e9 e5 16 bc 00 89 fe 48 c7 c7 d8 48 06 82 e8 67 71 03 00 <0f> 0b c3 0f 1f 40 00 0f 1f 44 00 00 53 be 20 00 48 00 48 89 fb 48
[   54.867774] RSP: 0018:ffff88603c803db8 EFLAGS: 00010086
[   54.867775] RAX: 0000000000000000 RBX: ffff88603a7e2c80 RCX: 0000000000000000
[   54.867775] RDX: 0000000000000000 RSI: 0000000000001277 RDI: ffff88603c9d5d08
[   54.867776] RBP: ffff88603a7e2c80 R08: 0000000000000000 R09: 0000000000000000
[   54.867776] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8860250a8000
[   54.867776] R13: ffff88603c803e00 R14: 0000000000000000 R15: ffff88603a7e2c98
[   54.867777] FS:  00007f41ad1658c0(0000) GS:ffff88603c800000(0000) knlGS:0000000000000000
[   54.867777] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   54.867778] CR2: ffff88c02765a000 CR3: 00000060252e4003 CR4: 00000000007606e0
[   54.867778] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   54.867778] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   54.867779] PKRU: 55555554
[   54.867779] Call Trace:
[   54.867779]  <IRQ>
[   54.867779]  check_preempt_curr+0x75/0xb0
[   54.867780]  ttwu_do_wakeup+0x19/0x190
[   54.867780]  try_to_wake_up+0x21e/0x4f0
[   54.867780]  __wake_up_common+0x9d/0x190
[   54.867781]  ep_poll_callback+0xd5/0x370
[   54.867781]  ? ep_poll_callback+0x2b5/0x370
[   54.867781]  __wake_up_common+0x9d/0x190
[   54.867782]  __wake_up_common_lock+0x7a/0xc0
[   54.867782]  irq_work_run_list+0x4c/0x70
[   54.867782]  smp_call_function_interrupt+0x59/0x110
[   54.867782]  call_function_interrupt+0xf/0x20
[   54.867783]  </IRQ>
[   54.867783]  <NMI>
[   54.867783] RIP: 0010:panic+0x206/0x25c
[   54.867784] Code: 83 3d 11 83 c9 01 00 74 05 e8 d2 87 02 00 48 c7 c6 80 15 d1 82 48 c7 c7 80 fe 06 82 31 c0 e8 71 ed 06 00 fb 66 0f 1f 44 00 00 <45> 31 e4 e8 de 11 0e 00 4d 39 ec 7c 1e 41 83 f6 01 48 8b 05 ce 82
[   54.867784] RSP: 0018:fffffe00003a4b58 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff03
[   54.867785] RAX: 0000000000000038 RBX: fffffe00003a4e00 RCX: 0000000000000000
[   54.867785] RDX: 0000000000000000 RSI: 0000000000000038 RDI: ffff88603c9d5d08
[   54.867786] RBP: fffffe00003a4bc8 R08: 0000000000000000 R09: ffff88603c9d5d47
[   54.867786] R10: 000000000000000b R11: 0000000000000000 R12: ffffffff8207b979
[   54.867786] R13: 0000000000000000 R14: 0000000000000000 R15: ffff88603c80f560
[   54.867787]  ? panic+0x1ff/0x25c
[   54.867787]  nmi_panic+0x37/0x40
[   54.867787]  watchdog_overflow_callback+0xef/0x110
[   54.867787]  __perf_event_overflow+0x51/0xe0
[   54.867788]  intel_pmu_handle_irq+0x222/0x4c0
[   54.867788]  ? _raw_spin_unlock+0x24/0x30
[   54.867788]  ? ghes_copy_tofrom_phys+0xf2/0x1a0
[   54.867789]  ? ghes_read_estatus+0x91/0x160
[   54.867789]  perf_event_nmi_handler+0x2e/0x50
[   54.867789]  nmi_handle+0x9a/0x180
[   54.867790]  ? nmi_handle+0x5/0x180
[   54.867790]  default_do_nmi+0xca/0x120
[   54.867790]  do_nmi+0x100/0x160
[   54.867791]  end_repeat_nmi+0x16/0x50
[   54.867791] RIP: 0010:queued_spin_lock_slowpath+0xf6/0x1e0
[   54.867791] Code: 48 03 34 c5 80 97 12 82 48 89 16 8b 42 08 85 c0 75 09 f3 90 8b 42 08 85 c0 74 f7 48 8b 32 48 85 f6 74 07 0f 0d 0e eb 02 f3 90 <8b> 07 66 85 c0 75 f7 41 89 c0 66 45 31 c0 41 39 c8 0f 84 93 00 00
[   54.867792] RSP: 0018:ffffc9001cc83a00 EFLAGS: 00000002
[   54.867792] RAX: 0000000000340101 RBX: ffffea06c16292e8 RCX: 0000000000580000
[   54.867793] RDX: ffff88603c9e3980 RSI: 0000000000000000 RDI: ffffea06c16292e8
[   54.867793] RBP: ffffea06c1629300 R08: 0000000000000001 R09: 0000000000000000
[   54.867793] R1
[   54.867794] Lost 48 message(s)!

--
Khalid
