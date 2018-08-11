Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 788EC6B0008
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 07:30:47 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 2-v6so7448374plc.11
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 04:30:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p81-v6si12858867pfi.345.2018.08.11.04.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 11 Aug 2018 04:30:41 -0700 (PDT)
Date: Sat, 11 Aug 2018 04:30:39 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [4.18.0 rc8 BUG] possible irq lock inversion dependency detected
Message-ID: <20180811113039.GA10397@bombadil.infradead.org>
References: <CABXGCsOni6VZTVq6+kfgniX+SO5vc5SSRrn93xa=SMEpw-NNCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsOni6VZTVq6+kfgniX+SO5vc5SSRrn93xa=SMEpw-NNCQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Sat, Aug 11, 2018 at 12:28:24PM +0500, Mikhail Gavrilov wrote:
> Hi guys.
> I am catched new bug. It occured when I start virtual machine.
> Can anyone look?

I'd suggest that st->lock should be taken with irqsave.  Like this;
please test.


diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 30ca2d1a9231..c982c574aebb 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -345,6 +345,7 @@ static __always_inline void amd_set_core_ssb_state(unsigned long tifn)
 {
 	struct ssb_state *st = this_cpu_ptr(&ssb_state);
 	u64 msr = x86_amd_ls_cfg_base;
+	unsigned long flags;
 
 	if (!static_cpu_has(X86_FEATURE_ZEN)) {
 		msr |= ssbd_tif_to_amd_ls_cfg(tifn);
@@ -362,21 +363,21 @@ static __always_inline void amd_set_core_ssb_state(unsigned long tifn)
 
 		msr |= x86_amd_ls_cfg_ssbd_mask;
 
-		raw_spin_lock(&st->shared_state->lock);
+		raw_spin_lock_irqsave(&st->shared_state->lock, flags);
 		/* First sibling enables SSBD: */
 		if (!st->shared_state->disable_state)
 			wrmsrl(MSR_AMD64_LS_CFG, msr);
 		st->shared_state->disable_state++;
-		raw_spin_unlock(&st->shared_state->lock);
+		raw_spin_unlock_irqrestore(&st->shared_state->lock, flags);
 	} else {
 		if (!__test_and_clear_bit(LSTATE_SSB, &st->local_state))
 			return;
 
-		raw_spin_lock(&st->shared_state->lock);
+		raw_spin_lock_irqsave(&st->shared_state->lock, flags);
 		st->shared_state->disable_state--;
 		if (!st->shared_state->disable_state)
 			wrmsrl(MSR_AMD64_LS_CFG, msr);
-		raw_spin_unlock(&st->shared_state->lock);
+		raw_spin_unlock_irqrestore(&st->shared_state->lock, flags);
 	}
 }
 #else

> [  476.307476] ========================================================
> [  476.307479] WARNING: possible irq lock inversion dependency detected
> [  476.307482] 4.18.0-0.rc8.git1.1.fc29.x86_64 #1 Tainted: G         C
> [  476.307485] --------------------------------------------------------
> [  476.307488] CPU 0/KVM/10284 just changed the state of lock:
> [  476.307491] 000000000d538a88 (&st->lock){+...}, at:
> speculative_store_bypass_update+0x10b/0x170
> [  476.307502] but this lock was taken by another, HARDIRQ-safe lock
> in the past:
> [  476.307504]  (&(&sighand->siglock)->rlock){-.-.}
> [  476.307507]
> 
>                and interrupts could create inverse lock ordering between them.
> 
> [  476.307513]
>                other info that might help us debug this:
> [  476.307516]  Possible interrupt unsafe locking scenario:
> 
> [  476.307519]        CPU0                    CPU1
> [  476.307521]        ----                    ----
> [  476.307523]   lock(&st->lock);
> [  476.307527]                                local_irq_disable();
> [  476.307529]                                lock(&(&sighand->siglock)->rlock);
> [  476.307533]                                lock(&st->lock);
> [  476.307537]   <Interrupt>
> [  476.307539]     lock(&(&sighand->siglock)->rlock);
> [  476.307543]
>                 *** DEADLOCK ***
> 
> [  476.307547] 1 lock held by CPU 0/KVM/10284:
> [  476.307549]  #0: 000000009792d366 (&vcpu->mutex){+.+.}, at:
> kvm_vcpu_ioctl+0x78/0x6c0 [kvm]
> [  476.307583]
>                the shortest dependencies between 2nd lock and 1st lock:
> [  476.307589]  -> (&(&sighand->siglock)->rlock){-.-.} ops: 2505028 {
> [  476.307596]     IN-HARDIRQ-W at:
> [  476.307602]                       _raw_spin_lock_irqsave+0x48/0x81
> [  476.307608]                       __lock_task_sighand+0x9a/0x1a0
> [  476.307612]                       do_send_sig_info+0x35/0x90
> [  476.307616]                       kill_pid_info+0x93/0x150
> [  476.307621]                       it_real_fn+0x3e/0x140
> [  476.307625]                       __hrtimer_run_queues+0x11e/0x520
> [  476.307629]                       hrtimer_interrupt+0x100/0x220
> [  476.307633]                       smp_apic_timer_interrupt+0x79/0x2c0
> [  476.307637]                       apic_timer_interrupt+0xf/0x20
> [  476.307640]     IN-SOFTIRQ-W at:
> [  476.307644]                       _raw_spin_lock_irqsave+0x48/0x81
> [  476.307648]                       __lock_task_sighand+0x9a/0x1a0
> [  476.307652]                       do_send_sig_info+0x35/0x90
> [  476.307655]                       kill_pid_info+0x93/0x150
> [  476.307659]                       it_real_fn+0x3e/0x140
> [  476.307663]                       __hrtimer_run_queues+0x11e/0x520
> [  476.307667]                       hrtimer_interrupt+0x100/0x220
> [  476.307671]                       smp_apic_timer_interrupt+0x79/0x2c0
> [  476.307675]                       apic_timer_interrupt+0xf/0x20
> [  476.307678]                       _raw_spin_unlock_irqrestore+0x50/0x60
> [  476.307683]                       scsi_end_request+0x112/0x1f0
> [  476.307686]                       scsi_io_completion+0x3e3/0x710
> [  476.307690]                       blk_done_softirq+0xaa/0xe0
> [  476.307694]                       __do_softirq+0xd9/0x4f7
> [  476.307699]                       irq_exit+0x10e/0x120
> [  476.307703]                       call_function_single_interrupt+0xf/0x20
> [  476.307707]                       cpuidle_enter_state+0xbc/0x350
> [  476.307711]                       do_idle+0x231/0x270
> [  476.307715]                       cpu_startup_entry+0x6f/0x80
> [  476.307720]                       start_secondary+0x1b3/0x200
> [  476.307724]                       secondary_startup_64+0xa5/0xb0
> [  476.307726]     INITIAL USE at:
> [  476.307730]                      _raw_spin_lock_irqsave+0x48/0x81
> [  476.307734]                      flush_signals+0x1d/0x60
> [  476.307738]                      kthreadd+0x35/0x390
> [  476.307742]                      ret_from_fork+0x27/0x50
> [  476.307744]   }
> [  476.307748]   ... key      at: [<ffffffffa52ac1a8>] __key.67772+0x0/0x8
> [  476.307751]   ... acquired at:
> [  476.307754]    speculative_store_bypass_update+0x81/0x170
> [  476.307758]    ssb_prctl_set+0x96/0xb0
> [  476.307762]    do_seccomp+0x6d0/0x720
> [  476.307765]    do_syscall_64+0x60/0x1f0
> [  476.307769]    entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> [  476.307773] -> (&st->lock){+...} ops: 3228332 {
> [  476.307780]    HARDIRQ-ON-W at:
> [  476.307784]                     _raw_spin_lock+0x30/0x70
> [  476.307788]                     speculative_store_bypass_update+0x10b/0x170
> [  476.307795]                     svm_vcpu_run+0x187/0x6e0 [kvm_amd]
> [  476.307797]    INITIAL USE at:
> [  476.307801]                    _raw_spin_lock+0x30/0x70
> [  476.307805]                    speculative_store_bypass_update+0x81/0x170
> [  476.307808]                    ssb_prctl_set+0x96/0xb0
> [  476.307811]                    do_seccomp+0x6d0/0x720
> [  476.307815]                    do_syscall_64+0x60/0x1f0
> [  476.307818]                    entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [  476.307820]  }
> [  476.307824]  ... key      at: [<ffffffffa524c998>] __key.54335+0x0/0x8
> [  476.307826]  ... acquired at:
> [  476.307830]    __lock_acquire+0x578/0x16c0
> [  476.307833]    lock_acquire+0x9e/0x1b0
> [  476.307836]    _raw_spin_lock+0x30/0x70
> [  476.307839]    speculative_store_bypass_update+0x10b/0x170
> [  476.307846]    svm_vcpu_run+0x187/0x6e0 [kvm_amd]
> 
> [  476.307850]
>                stack backtrace:
> [  476.307856] CPU: 0 PID: 10284 Comm: CPU 0/KVM Tainted: G         C
>       4.18.0-0.rc8.git1.1.fc29.x86_64 #1
> [  476.307859] Hardware name: System manufacturer System Product
> Name/ROG STRIX X470-I GAMING, BIOS 0901 07/23/2018
> [  476.307861] Call Trace:
> [  476.307868]  dump_stack+0x85/0xc0
> [  476.307873]  check_usage_backwards.cold.59+0x1d/0x26
> [  476.307880]  mark_lock+0x2c8/0x620
> [  476.307884]  ? print_shortest_lock_dependencies+0x40/0x40
> [  476.307889]  __lock_acquire+0x578/0x16c0
> [  476.307892]  ? __lock_acquire+0x29a/0x16c0
> [  476.307897]  ? __lock_acquire+0x29a/0x16c0
> [  476.307902]  ? native_sched_clock+0x3e/0xa0
> [  476.307906]  lock_acquire+0x9e/0x1b0
> [  476.307910]  ? speculative_store_bypass_update+0x10b/0x170
> [  476.307915]  _raw_spin_lock+0x30/0x70
> [  476.307919]  ? speculative_store_bypass_update+0x10b/0x170
> [  476.307923]  speculative_store_bypass_update+0x10b/0x170
> [  476.307931]  svm_vcpu_run+0x187/0x6e0 [kvm_amd]
> [  476.307972]  ? kvm_arch_vcpu_ioctl_run+0x492/0x1ed0 [kvm]
> [  476.308008]  ? kvm_vcpu_ioctl+0x2c0/0x6c0 [kvm]
> [  476.308039]  ? kvm_vcpu_ioctl+0x2c0/0x6c0 [kvm]
> [  476.308044]  ? __seccomp_filter+0x44/0x4a0
> [  476.308049]  ? native_sched_clock+0x3e/0xa0
> [  476.308056]  ? do_vfs_ioctl+0xa5/0x6e0
> [  476.308063]  ? ksys_ioctl+0x60/0x90
> [  476.308067]  ? __x64_sys_ioctl+0x16/0x20
> [  476.308072]  ? do_syscall_64+0x60/0x1f0
> [  476.308077]  ? entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> 
> 
> --
> Best Regards,
> Mike Gavrilov.

> [    0.000000] Linux version 4.18.0-0.rc8.git1.1.fc29.x86_64 (mockbuild@bkernel02.phx2.fedoraproject.org) (gcc version 8.2.1 20180801 (Red Hat 8.2.1-2) (GCC)) #1 SMP Wed Aug 8 10:26:42 UTC 2018
> [    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.18.0-0.rc8.git1.1.fc29.x86_64 root=UUID=f495bc27-2073-4454-a85f-f2cf941b4cf1 ro resume=UUID=f129f65c-36c0-41bd-a173-34cfcd7ae3fc rhgb quiet LANG=en_US.UTF-8
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
> [    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
> [    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'compacted' format.
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009ffff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000000a0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000003ffffff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000004000000-0x0000000004009fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x000000000400a000-0x0000000009cfffff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000009d00000-0x0000000009ffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x000000000a000000-0x000000000affffff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000b000000-0x000000000b01ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x000000000b020000-0x00000000da307fff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000da308000-0x00000000db804fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000db805000-0x00000000db82cfff] ACPI data
> [    0.000000] BIOS-e820: [mem 0x00000000db82d000-0x00000000dbcddfff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x00000000dbcde000-0x00000000dc7f5fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000dc7f6000-0x00000000deffffff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000df000000-0x00000000dfffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fd800000-0x00000000fdffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fea00000-0x00000000fea0ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000feb80000-0x00000000fec01fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec10000-0x00000000fec10fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec30000-0x00000000fec30fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed00fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed40000-0x00000000fed44fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed8ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fedc2000-0x00000000fedcffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fedd4000-0x00000000fedd5fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000feefffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000081f37ffff] usable
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] e820: update [mem 0x99bc9018-0x99bda057] usable ==> usable
> [    0.000000] e820: update [mem 0x99bc9018-0x99bda057] usable ==> usable
> [    0.000000] e820: update [mem 0x99baf018-0x99bc8457] usable ==> usable
> [    0.000000] e820: update [mem 0x99baf018-0x99bc8457] usable ==> usable
> [    0.000000] extended physical RAM map:
> [    0.000000] reserve setup_data: [mem 0x0000000000000000-0x000000000009ffff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000000a0000-0x00000000000fffff] reserved
> [    0.000000] reserve setup_data: [mem 0x0000000000100000-0x0000000003ffffff] usable
> [    0.000000] reserve setup_data: [mem 0x0000000004000000-0x0000000004009fff] ACPI NVS
> [    0.000000] reserve setup_data: [mem 0x000000000400a000-0x0000000009cfffff] usable
> [    0.000000] reserve setup_data: [mem 0x0000000009d00000-0x0000000009ffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x000000000a000000-0x000000000affffff] usable
> [    0.000000] reserve setup_data: [mem 0x000000000b000000-0x000000000b01ffff] reserved
> [    0.000000] reserve setup_data: [mem 0x000000000b020000-0x0000000099baf017] usable
> [    0.000000] reserve setup_data: [mem 0x0000000099baf018-0x0000000099bc8457] usable
> [    0.000000] reserve setup_data: [mem 0x0000000099bc8458-0x0000000099bc9017] usable
> [    0.000000] reserve setup_data: [mem 0x0000000099bc9018-0x0000000099bda057] usable
> [    0.000000] reserve setup_data: [mem 0x0000000099bda058-0x00000000da307fff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000da308000-0x00000000db804fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000db805000-0x00000000db82cfff] ACPI data
> [    0.000000] reserve setup_data: [mem 0x00000000db82d000-0x00000000dbcddfff] ACPI NVS
> [    0.000000] reserve setup_data: [mem 0x00000000dbcde000-0x00000000dc7f5fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000dc7f6000-0x00000000deffffff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000df000000-0x00000000dfffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fd800000-0x00000000fdffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fea00000-0x00000000fea0ffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000feb80000-0x00000000fec01fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fec10000-0x00000000fec10fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fec30000-0x00000000fec30fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fed00000-0x00000000fed00fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fed40000-0x00000000fed44fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fed80000-0x00000000fed8ffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fedc2000-0x00000000fedcffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fedd4000-0x00000000fedd5fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fee00000-0x00000000feefffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x0000000100000000-0x000000081f37ffff] usable
> [    0.000000] efi: EFI v2.60 by American Megatrends
> [    0.000000] efi:  ACPI 2.0=0xdb80d000  ACPI=0xdb80d000  SMBIOS=0xdc6b9000  SMBIOS 3.0=0xdc6b8000  ESRT=0xd7a91b98  MEMATTR=0xd7af3018 
> [    0.000000] secureboot: Secure boot disabled
> [    0.000000] SMBIOS 3.1.1 present.
> [    0.000000] DMI: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 0901 07/23/2018
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] last_pfn = 0x81f380 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF write-through
> [    0.000000]   C0000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 000000000000 mask FFFF80000000 write-back
> [    0.000000]   1 base 000080000000 mask FFFFC0000000 write-back
> [    0.000000]   2 base 0000C0000000 mask FFFFE0000000 write-back
> [    0.000000]   3 disabled
> [    0.000000]   4 disabled
> [    0.000000]   5 disabled
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000] TOM2: 0000000820000000 aka 33280M
> [    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
> [    0.000000] e820: update [mem 0xe0000000-0xffffffff] usable ==> reserved
> [    0.000000] last_pfn = 0xdf000 max_arch_pfn = 0x400000000
> [    0.000000] esrt: Reserving ESRT space from 0x00000000d7a91b98 to 0x00000000d7a91bd0.
> [    0.000000] Scanning 1 areas for low memory corruption
> [    0.000000] Base memory trampoline at [(____ptrval____)] 98000 size 24576
> [    0.000000] Using GB pages for direct mapping
> [    0.000000] BRK [0x6e3244000, 0x6e3244fff] PGTABLE
> [    0.000000] BRK [0x6e3245000, 0x6e3245fff] PGTABLE
> [    0.000000] BRK [0x6e3246000, 0x6e3246fff] PGTABLE
> [    0.000000] BRK [0x6e3247000, 0x6e3247fff] PGTABLE
> [    0.000000] BRK [0x6e3248000, 0x6e3248fff] PGTABLE
> [    0.000000] BRK [0x6e3249000, 0x6e3249fff] PGTABLE
> [    0.000000] BRK [0x6e324a000, 0x6e324afff] PGTABLE
> [    0.000000] BRK [0x6e324b000, 0x6e324bfff] PGTABLE
> [    0.000000] BRK [0x6e324c000, 0x6e324cfff] PGTABLE
> [    0.000000] BRK [0x6e324d000, 0x6e324dfff] PGTABLE
> [    0.000000] BRK [0x6e324e000, 0x6e324efff] PGTABLE
> [    0.000000] BRK [0x6e324f000, 0x6e324ffff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x3b24b000-0x3cd8efff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000DB80D000 000024 (v02 ALASKA)
> [    0.000000] ACPI: XSDT 0x00000000DB80D098 0000AC (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FACP 0x00000000DB81B628 000114 (v06 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI BIOS Warning (bug): Optional FADT field Pm2ControlBlock has valid Length but zero Address: 0x0000000000000000/0x1 (20180531/tbfadt-624)
> [    0.000000] ACPI: DSDT 0x00000000DB80D1E0 00E442 (v02 ALASKA A M I    01072009 INTL 20120913)
> [    0.000000] ACPI: FACS 0x00000000DBCC6E00 000040
> [    0.000000] ACPI: APIC 0x00000000DB81B740 0000DE (v03 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FPDT 0x00000000DB81B820 000044 (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FIDT 0x00000000DB81B868 00009C (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: SSDT 0x00000000DB81B908 008C98 (v02 AMD    AMD ALIB 00000002 MSFT 04000000)
> [    0.000000] ACPI: SSDT 0x00000000DB8245A0 002314 (v01 AMD    AMD CPU  00000001 AMD  00000001)
> [    0.000000] ACPI: CRAT 0x00000000DB8268B8 000F50 (v01 AMD    AMD CRAT 00000001 AMD  00000001)
> [    0.000000] ACPI: CDIT 0x00000000DB827808 000029 (v01 AMD    AMD CDIT 00000001 AMD  00000001)
> [    0.000000] ACPI: SSDT 0x00000000DB827838 002DA8 (v01 AMD    AMD AOD  00000001 INTL 20120913)
> [    0.000000] ACPI: MCFG 0x00000000DB82A5E0 00003C (v01 ALASKA A M I    01072009 MSFT 00010013)
> [    0.000000] ACPI: SSDT 0x00000000DB82C270 0000F8 (v01 AMD    AMD PT   00001000 INTL 20120913)
> [    0.000000] ACPI: HPET 0x00000000DB82A678 000038 (v01 ALASKA A M I    01072009 AMI  00000005)
> [    0.000000] ACPI: SSDT 0x00000000DB82A6B0 000024 (v01 AMDFCH FCHZP    00001000 INTL 20120913)
> [    0.000000] ACPI: UEFI 0x00000000DB82A6D8 000042 (v01                 00000000      00000000)
> [    0.000000] ACPI: BGRT 0x00000000DB82A720 000038 (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: IVRS 0x00000000DB82A758 0000D0 (v02 AMD    AMD IVRS 00000001 AMD  00000000)
> [    0.000000] ACPI: SSDT 0x00000000DB82A828 001A41 (v01 AMD    AmdTable 00000001 INTL 20120913)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at [mem 0x0000000000000000-0x000000081f37ffff]
> [    0.000000] NODE_DATA(0) allocated [mem 0x81f355000-0x81f37ffff]
> [    0.000000] tsc: Fast TSC calibration failed
> [    0.000000] tsc: Using PIT calibration value
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
> [    0.000000]   Normal   [mem 0x0000000100000000-0x000000081f37ffff]
> [    0.000000]   Device   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009ffff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x0000000003ffffff]
> [    0.000000]   node   0: [mem 0x000000000400a000-0x0000000009cfffff]
> [    0.000000]   node   0: [mem 0x000000000a000000-0x000000000affffff]
> [    0.000000]   node   0: [mem 0x000000000b020000-0x00000000da307fff]
> [    0.000000]   node   0: [mem 0x00000000dc7f6000-0x00000000deffffff]
> [    0.000000]   node   0: [mem 0x0000000100000000-0x000000081f37ffff]
> [    0.000000] Reserved but unavailable: 14457 pages
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000081f37ffff]
> [    0.000000] On node 0 totalpages: 8370951
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 24 pages reserved
> [    0.000000]   DMA zone: 3999 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 14048 pages used for memmap
> [    0.000000]   DMA32 zone: 899048 pages, LIFO batch:31
> [    0.000000]   Normal zone: 116686 pages used for memmap
> [    0.000000]   Normal zone: 7467904 pages, LIFO batch:31
> [    0.000000] ACPI: PM-Timer IO Port: 0x808
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
> [    0.000000] IOAPIC[0]: apic_id 17, version 33, address 0xfec00000, GSI 0-23
> [    0.000000] IOAPIC[1]: apic_id 18, version 33, address 0xfec01000, GSI 24-55
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x10228201 base: 0xfed00000
> [    0.000000] smpboot: Allowing 16 CPUs, 0 hotplug CPUs
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x04000000-0x04009fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x09d00000-0x09ffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0b000000-0x0b01ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x99baf000-0x99baffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x99bc8000-0x99bc8fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x99bc9000-0x99bc9fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x99bda000-0x99bdafff]
> [    0.000000] PM: Registered nosave memory: [mem 0xda308000-0xdb804fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdb805000-0xdb82cfff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdb82d000-0xdbcddfff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdbcde000-0xdc7f5fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdf000000-0xdfffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xf7ffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfbffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfd7fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfd800000-0xfdffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfe000000-0xfe9fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfea00000-0xfea0ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfea10000-0xfeb7ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfeb80000-0xfec01fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec02000-0xfec0ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec10000-0xfec10fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec11000-0xfec2ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec30000-0xfec30fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec31000-0xfecfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed00fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed01000-0xfed3ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed40000-0xfed44fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed45000-0xfed7ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed80000-0xfed8ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed90000-0xfedc1fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfedc2000-0xfedcffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfedd0000-0xfedd3fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfedd4000-0xfedd5fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfedd6000-0xfedfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfeefffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfef00000-0xfeffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
> [    0.000000] [mem 0xe0000000-0xf7ffffff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
> [    0.000000] random: get_random_bytes called from start_kernel+0x9d/0x587 with crng_init=0
> [    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:16 nr_cpu_ids:16 nr_node_ids:1
> [    0.000000] percpu: Embedded 494 pages/cpu @(____ptrval____) s1986560 r8192 d28672 u2097152
> [    0.000000] pcpu-alloc: s1986560 r8192 d28672 u2097152 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 00 [0] 01 [0] 02 [0] 03 [0] 04 [0] 05 [0] 06 [0] 07 
> [    0.000000] pcpu-alloc: [0] 08 [0] 09 [0] 10 [0] 11 [0] 12 [0] 13 [0] 14 [0] 15 
> [    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 8240129
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.18.0-0.rc8.git1.1.fc29.x86_64 root=UUID=f495bc27-2073-4454-a85f-f2cf941b4cf1 ro resume=UUID=f129f65c-36c0-41bd-a173-34cfcd7ae3fc rhgb quiet LANG=en_US.UTF-8
> [    0.000000] Memory: 32557216K/33483804K available (14348K kernel code, 3811K rwdata, 4420K rodata, 4824K init, 16396K bss, 926588K reserved, 0K cma-reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=16, Nodes=1
> [    0.000000] ftrace: allocating 38395 entries in 150 pages
> [    0.000000] Running RCU self tests
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	RCU lockdep checking is enabled.
> [    0.000000] 	RCU restricting CPUs from NR_CPUS=8192 to nr_cpu_ids=16.
> [    0.000000] 	RCU callback double-/use-after-free debug enabled.
> [    0.000000] 	Tasks RCU enabled.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=16
> [    0.000000] NR_IRQS: 524544, nr_irqs: 1096, preallocated irqs: 16
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
> [    0.000000] ... CHAINHASH_SIZE:          32768
> [    0.000000]  memory used by lock dependency info: 7903 kB
> [    0.000000]  per task-struct memory footprint: 2688 bytes
> [    0.000000] kmemleak: Kernel memory leak detector disabled
> [    0.000000] ACPI: Core revision 20180531
> [    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484873504 ns
> [    0.000000] hpet clockevent registered
> [    0.000000] APIC: Switch to symmetric I/O mode setup
> [    0.001000] Switched APIC routing to physical flat.
> [    0.002000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.007000] tsc: Fast TSC calibration failed
> [    0.009000] tsc: PIT calibration matches HPET. 1 loops
> [    0.009000] tsc: Detected 3692.719 MHz processor
> [    0.009000] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x6a74ef90411, max_idle_ns: 881591048502 ns
> [    0.009000] Calibrating delay loop (skipped), value calculated using timer frequency.. 7385.43 BogoMIPS (lpj=3692719)
> [    0.009000] pid_max: default: 32768 minimum: 301
> [    0.011009] ---[ User Space ]---
> [    0.011010] 0x0000000000000000-0x0000000000008000          32K     RW                     x  pte
> [    0.011020] 0x0000000000008000-0x000000000003f000         220K                               pte
> [    0.011025] 0x000000000003f000-0x00000000000a0000         388K     RW                     x  pte
> [    0.011036] 0x00000000000a0000-0x0000000000200000        1408K                               pte
> [    0.011040] 0x0000000000200000-0x0000000001000000          14M                               pmd
> [    0.011044] 0x0000000001000000-0x0000000001020000         128K     RW                     x  pte
> [    0.011056] 0x0000000001020000-0x0000000001200000        1920K                               pte
> [    0.011061] 0x0000000001200000-0x0000000040000000        1006M                               pmd
> [    0.011065] 0x0000000040000000-0x00000000c0000000           2G                               pud
> [    0.011069] 0x00000000c0000000-0x00000000cd200000         210M                               pmd
> [    0.011075] 0x00000000cd200000-0x00000000cd3c1000        1796K                               pte
> [    0.011079] 0x00000000cd3c1000-0x00000000cd400000         252K     RW                     x  pte
> [    0.011089] 0x00000000cd400000-0x00000000d6400000         144M     RW         PSE         x  pmd
> [    0.011104] 0x00000000d6400000-0x00000000d6800000           4M     RW                     x  pte
> [    0.011113] 0x00000000d6800000-0x00000000d7a00000          18M     RW         PSE         x  pmd
> [    0.011125] 0x00000000d7a00000-0x00000000d7c00000           2M     RW                     x  pte
> [    0.011134] 0x00000000d7c00000-0x00000000d9200000          22M     RW         PSE         x  pmd
> [    0.011145] 0x00000000d9200000-0x00000000d9363000        1420K     RW                     x  pte
> [    0.011155] 0x00000000d9363000-0x00000000d9400000         628K                               pte
> [    0.011159] 0x00000000d9400000-0x00000000d9600000           2M                               pmd
> [    0.011163] 0x00000000d9600000-0x00000000d9684000         528K                               pte
> [    0.011169] 0x00000000d9684000-0x00000000d9800000        1520K     RW                     x  pte
> [    0.011178] 0x00000000d9800000-0x00000000da200000          10M     RW         PSE         x  pmd
> [    0.011188] 0x00000000da200000-0x00000000da308000        1056K     RW                     x  pte
> [    0.011199] 0x00000000da308000-0x00000000da400000         992K                               pte
> [    0.011202] 0x00000000da400000-0x00000000dbc00000          24M                               pmd
> [    0.011207] 0x00000000dbc00000-0x00000000dbcde000         888K                               pte
> [    0.011212] 0x00000000dbcde000-0x00000000dbe00000        1160K     RW                     NX pte
> [    0.011221] 0x00000000dbe00000-0x00000000dc600000           8M     RW         PSE         NX pmd
> [    0.011232] 0x00000000dc600000-0x00000000dc76f000        1468K     RW                     NX pte
> [    0.011241] 0x00000000dc76f000-0x00000000dc772000          12K     ro                     x  pte
> [    0.011251] 0x00000000dc772000-0x00000000dc777000          20K     RW                     NX pte
> [    0.011260] 0x00000000dc777000-0x00000000dc778000           4K     ro                     x  pte
> [    0.011269] 0x00000000dc778000-0x00000000dc77c000          16K     RW                     NX pte
> [    0.011278] 0x00000000dc77c000-0x00000000dc780000          16K     ro                     x  pte
> [    0.011287] 0x00000000dc780000-0x00000000dc785000          20K     RW                     NX pte
> [    0.011296] 0x00000000dc785000-0x00000000dc786000           4K     ro                     x  pte
> [    0.011305] 0x00000000dc786000-0x00000000dc78a000          16K     RW                     NX pte
> [    0.011316] 0x00000000dc78a000-0x00000000dc78b000           4K     ro                     x  pte
> [    0.011327] 0x00000000dc78b000-0x00000000dc790000          20K     RW                     NX pte
> [    0.011337] 0x00000000dc790000-0x00000000dc79d000          52K     ro                     x  pte
> [    0.011347] 0x00000000dc79d000-0x00000000dc7a4000          28K     RW                     NX pte
> [    0.011356] 0x00000000dc7a4000-0x00000000dc7a7000          12K     ro                     x  pte
> [    0.011366] 0x00000000dc7a7000-0x00000000dc7ad000          24K     RW                     NX pte
> [    0.011375] 0x00000000dc7ad000-0x00000000dc7ae000           4K     ro                     x  pte
> [    0.011384] 0x00000000dc7ae000-0x00000000dc7b3000          20K     RW                     NX pte
> [    0.011394] 0x00000000dc7b3000-0x00000000dc7b4000           4K     ro                     x  pte
> [    0.011403] 0x00000000dc7b4000-0x00000000dc7b9000          20K     RW                     NX pte
> [    0.011413] 0x00000000dc7b9000-0x00000000dc7ba000           4K     ro                     x  pte
> [    0.011422] 0x00000000dc7ba000-0x00000000dc7bf000          20K     RW                     NX pte
> [    0.011431] 0x00000000dc7bf000-0x00000000dc7c0000           4K     ro                     x  pte
> [    0.011441] 0x00000000dc7c0000-0x00000000dc7c5000          20K     RW                     NX pte
> [    0.011450] 0x00000000dc7c5000-0x00000000dc7c6000           4K     ro                     x  pte
> [    0.011459] 0x00000000dc7c6000-0x00000000dc7cb000          20K     RW                     NX pte
> [    0.011469] 0x00000000dc7cb000-0x00000000dc7cc000           4K     ro                     x  pte
> [    0.011478] 0x00000000dc7cc000-0x00000000dc7d0000          16K     RW                     NX pte
> [    0.011488] 0x00000000dc7d0000-0x00000000dc7da000          40K     ro                     x  pte
> [    0.011497] 0x00000000dc7da000-0x00000000dc7e3000          36K     RW                     NX pte
> [    0.011507] 0x00000000dc7e3000-0x00000000dc7e8000          20K     ro                     x  pte
> [    0.011516] 0x00000000dc7e8000-0x00000000dc7ed000          20K     RW                     NX pte
> [    0.011525] 0x00000000dc7ed000-0x00000000dc7f1000          16K     ro                     x  pte
> [    0.011535] 0x00000000dc7f1000-0x00000000dc7f6000          20K     RW                     NX pte
> [    0.011544] 0x00000000dc7f6000-0x00000000dc800000          40K     RW                     x  pte
> [    0.011554] 0x00000000dc800000-0x00000000df000000          40M     RW         PSE         x  pmd
> [    0.011564] 0x00000000df000000-0x00000000f8000000         400M                               pmd
> [    0.011568] 0x00000000f8000000-0x00000000fc000000          64M     RW         PSE         x  pmd
> [    0.011577] 0x00000000fc000000-0x00000000fd800000          24M                               pmd
> [    0.011581] 0x00000000fd800000-0x00000000fe000000           8M     RW         PSE         x  pmd
> [    0.011590] 0x00000000fe000000-0x00000000fea00000          10M                               pmd
> [    0.011594] 0x00000000fea00000-0x00000000fea10000          64K     RW                     x  pte
> [    0.011605] 0x00000000fea10000-0x00000000feb80000        1472K                               pte
> [    0.011610] 0x00000000feb80000-0x00000000fec02000         520K     RW                     x  pte
> [    0.011619] 0x00000000fec02000-0x00000000fec10000          56K                               pte
> [    0.011623] 0x00000000fec10000-0x00000000fec11000           4K     RW                     x  pte
> [    0.011633] 0x00000000fec11000-0x00000000fec30000         124K                               pte
> [    0.011636] 0x00000000fec30000-0x00000000fec31000           4K     RW                     x  pte
> [    0.011647] 0x00000000fec31000-0x00000000fed00000         828K                               pte
> [    0.011651] 0x00000000fed00000-0x00000000fed01000           4K     RW                     x  pte
> [    0.011660] 0x00000000fed01000-0x00000000fed40000         252K                               pte
> [    0.011664] 0x00000000fed40000-0x00000000fed45000          20K     RW                     x  pte
> [    0.011674] 0x00000000fed45000-0x00000000fed80000         236K                               pte
> [    0.011678] 0x00000000fed80000-0x00000000fed90000          64K     RW                     x  pte
> [    0.011687] 0x00000000fed90000-0x00000000fedc2000         200K                               pte
> [    0.011691] 0x00000000fedc2000-0x00000000fedd0000          56K     RW                     x  pte
> [    0.011701] 0x00000000fedd0000-0x00000000fedd4000          16K                               pte
> [    0.011704] 0x00000000fedd4000-0x00000000fedd6000           8K     RW                     x  pte
> [    0.011714] 0x00000000fedd6000-0x00000000fee00000         168K                               pte
> [    0.011719] 0x00000000fee00000-0x00000000fef00000           1M     RW                     x  pte
> [    0.011730] 0x00000000fef00000-0x00000000ff000000           1M                               pte
> [    0.011734] 0x00000000ff000000-0x0000000100000000          16M     RW         PSE         x  pmd
> [    0.011743] 0x0000000100000000-0x00000007c0000000          27G                               pud
> [    0.011749] 0x00000007c0000000-0x00000007fc400000         964M                               pmd
> [    0.011755] 0x00000007fc400000-0x00000007fc574000        1488K                               pte
> [    0.011759] 0x00000007fc574000-0x00000007fc576000           8K     RW                     NX pte
> [    0.011769] 0x00000007fc576000-0x00000007fc600000         552K                               pte
> [    0.011773] 0x00000007fc600000-0x0000000800000000          58M                               pmd
> [    0.011779] 0x0000000800000000-0x0000008000000000         480G                               pud
> [    0.011786] 0x0000008000000000-0xffff800000000000   17179737600G                               pgd
> [    0.011790] ---[ Kernel Space ]---
> [    0.011791] 0xffff800000000000-0xffff808000000000         512G                               pgd
> [    0.011795] ---[ Low Kernel Mapping ]---
> [    0.011796] 0xffff808000000000-0xffff810000000000         512G                               pgd
> [    0.011799] ---[ vmalloc() Area ]---
> [    0.011801] 0xffff810000000000-0xffff818000000000         512G                               pgd
> [    0.011804] ---[ Vmemmap ]---
> [    0.011806] 0xffff818000000000-0xffff938000000000          18T                               pgd
> [    0.011811] 0xffff938000000000-0xffff93d6c0000000         347G                               pud
> [    0.011818] 0xffff93d6c0000000-0xffff93d6c0200000           2M     RW                 GLB NX pte
> [    0.011828] 0xffff93d6c0200000-0xffff93d6c4000000          62M     RW         PSE     GLB NX pmd
> [    0.011837] 0xffff93d6c4000000-0xffff93d6c400a000          40K                               pte
> [    0.011844] 0xffff93d6c400a000-0xffff93d6c4200000        2008K     RW                 GLB NX pte
> [    0.011853] 0xffff93d6c4200000-0xffff93d6c9c00000          90M     RW         PSE     GLB NX pmd
> [    0.011864] 0xffff93d6c9c00000-0xffff93d6c9d00000           1M     RW                 GLB NX pte
> [    0.011875] 0xffff93d6c9d00000-0xffff93d6c9e00000           1M                               pte
> [    0.011879] 0xffff93d6c9e00000-0xffff93d6ca000000           2M                               pmd
> [    0.012001] 0xffff93d6ca000000-0xffff93d6cb000000          16M     RW         PSE     GLB NX pmd
> [    0.012011] 0xffff93d6cb000000-0xffff93d6cb020000         128K                               pte
> [    0.012017] 0xffff93d6cb020000-0xffff93d6cb200000        1920K     RW                 GLB NX pte
> [    0.012029] 0xffff93d6cb200000-0xffff93d700000000         846M     RW         PSE     GLB NX pmd
> [    0.012038] 0xffff93d700000000-0xffff93d780000000           2G     RW         PSE     GLB NX pud
> [    0.012049] 0xffff93d780000000-0xffff93d79a200000         418M     RW         PSE     GLB NX pmd
> [    0.012060] 0xffff93d79a200000-0xffff93d79a308000        1056K     RW                 GLB NX pte
> [    0.012071] 0xffff93d79a308000-0xffff93d79a400000         992K                               pte
> [    0.012074] 0xffff93d79a400000-0xffff93d79c600000          34M                               pmd
> [    0.012081] 0xffff93d79c600000-0xffff93d79c7f6000        2008K                               pte
> [    0.012085] 0xffff93d79c7f6000-0xffff93d79c800000          40K     RW                 GLB NX pte
> [    0.012094] 0xffff93d79c800000-0xffff93d79f000000          40M     RW         PSE     GLB NX pmd
> [    0.012105] 0xffff93d79f000000-0xffff93d7c0000000         528M                               pmd
> [    0.012109] 0xffff93d7c0000000-0xffff93dec0000000          28G     RW         PSE     GLB NX pud
> [    0.012119] 0xffff93dec0000000-0xffff93dedf200000         498M     RW         PSE     GLB NX pmd
> [    0.012131] 0xffff93dedf200000-0xffff93dedf380000        1536K     RW                 GLB NX pte
> [    0.012141] 0xffff93dedf380000-0xffff93dedf400000         512K                               pte
> [    0.012146] 0xffff93dedf400000-0xffff93df00000000         524M                               pmd
> [    0.012150] 0xffff93df00000000-0xffff940000000000         132G                               pud
> [    0.012155] 0xffff940000000000-0xffffba8000000000       39424G                               pgd
> [    0.012160] 0xffffba8000000000-0xffffbaafc0000000         191G                               pud
> [    0.012164] 0xffffbaafc0000000-0xffffbaafc0001000           4K     RW                 GLB NX pte
> [    0.012173] 0xffffbaafc0001000-0xffffbaafc0002000           4K                               pte
> [    0.012177] 0xffffbaafc0002000-0xffffbaafc0003000           4K     RW                 GLB NX pte
> [    0.012186] 0xffffbaafc0003000-0xffffbaafc0004000           4K                               pte
> [    0.012190] 0xffffbaafc0004000-0xffffbaafc0007000          12K     RW                 GLB NX pte
> [    0.012199] 0xffffbaafc0007000-0xffffbaafc0008000           4K                               pte
> [    0.012203] 0xffffbaafc0008000-0xffffbaafc000a000           8K     RW                 GLB NX pte
> [    0.012212] 0xffffbaafc000a000-0xffffbaafc000b000           4K                               pte
> [    0.012216] 0xffffbaafc000b000-0xffffbaafc000c000           4K     RW                 GLB NX pte
> [    0.012225] 0xffffbaafc000c000-0xffffbaafc000d000           4K                               pte
> [    0.012229] 0xffffbaafc000d000-0xffffbaafc000e000           4K     RW     PCD         GLB NX pte
> [    0.012239] 0xffffbaafc000e000-0xffffbaafc0010000           8K                               pte
> [    0.012242] 0xffffbaafc0010000-0xffffbaafc001f000          60K     RW                 GLB NX pte
> [    0.012252] 0xffffbaafc001f000-0xffffbaafc0020000           4K                               pte
> [    0.012256] 0xffffbaafc0020000-0xffffbaafc002a000          40K     RW                 GLB NX pte
> [    0.012265] 0xffffbaafc002a000-0xffffbaafc002c000           8K                               pte
> [    0.012269] 0xffffbaafc002c000-0xffffbaafc0030000          16K     RW                 GLB NX pte
> [    0.012278] 0xffffbaafc0030000-0xffffbaafc0034000          16K                               pte
> [    0.012282] 0xffffbaafc0034000-0xffffbaafc0037000          12K     RW                 GLB NX pte
> [    0.012292] 0xffffbaafc0037000-0xffffbaafc0080000         292K                               pte
> [    0.012296] 0xffffbaafc0080000-0xffffbaafc0100000         512K     RW     PCD         GLB NX pte
> [    0.012307] 0xffffbaafc0100000-0xffffbaafc0200000           1M                               pte
> [    0.012313] 0xffffbaafc0200000-0xffffbab000000000        1022M                               pmd
> [    0.012318] 0xffffbab000000000-0xffffbb0000000000         320G                               pud
> [    0.012323] 0xffffbb0000000000-0xfffff48000000000       58880G                               pgd
> [    0.012329] 0xfffff48000000000-0xfffff4f0c0000000         451G                               pud
> [    0.012333] 0xfffff4f0c0000000-0xfffff4f0c3800000          56M     RW         PSE     GLB NX pmd
> [    0.012342] 0xfffff4f0c3800000-0xfffff4f0c4000000           8M                               pmd
> [    0.012347] 0xfffff4f0c4000000-0xfffff4f0e0800000         456M     RW         PSE     GLB NX pmd
> [    0.012358] 0xfffff4f0e0800000-0xfffff4f100000000         504M                               pmd
> [    0.012362] 0xfffff4f100000000-0xfffff50000000000          60G                               pud
> [    0.012366] 0xfffff50000000000-0xfffffe0000000000           9T                               pgd
> [    0.012370] ---[ CPU entry Area ]---
> [    0.012371] 0xfffffe0000000000-0xfffffe0000001000           4K     ro                 GLB NX pte
> [    0.012380] ---[ LDT remap ]---
> [    0.012381] 0xfffffe0000001000-0xfffffe0000002000           4K     ro                 GLB NX pte
> [    0.012391] 0xfffffe0000002000-0xfffffe0000003000           4K     RW                 GLB NX pte
> [    0.012400] 0xfffffe0000003000-0xfffffe0000006000          12K     ro                 GLB NX pte
> [    0.012410] 0xfffffe0000006000-0xfffffe0000007000           4K     ro                 GLB x  pte
> [    0.012419] 0xfffffe0000007000-0xfffffe000000c000          20K     RW                 GLB NX pte
> [    0.012429] 0xfffffe000000c000-0xfffffe000002d000         132K                               pte
> [    0.012432] 0xfffffe000002d000-0xfffffe000002e000           4K     ro                 GLB NX pte
> [    0.012442] 0xfffffe000002e000-0xfffffe000002f000           4K     RW                 GLB NX pte
> [    0.012451] 0xfffffe000002f000-0xfffffe0000032000          12K     ro                 GLB NX pte
> [    0.012461] 0xfffffe0000032000-0xfffffe0000033000           4K     ro                 GLB x  pte
> [    0.012470] 0xfffffe0000033000-0xfffffe0000038000          20K     RW                 GLB NX pte
> [    0.012480] 0xfffffe0000038000-0xfffffe0000059000         132K                               pte
> [    0.012483] 0xfffffe0000059000-0xfffffe000005a000           4K     ro                 GLB NX pte
> [    0.012493] 0xfffffe000005a000-0xfffffe000005b000           4K     RW                 GLB NX pte
> [    0.012502] 0xfffffe000005b000-0xfffffe000005e000          12K     ro                 GLB NX pte
> [    0.012512] 0xfffffe000005e000-0xfffffe000005f000           4K     ro                 GLB x  pte
> [    0.012521] 0xfffffe000005f000-0xfffffe0000064000          20K     RW                 GLB NX pte
> [    0.012531] 0xfffffe0000064000-0xfffffe0000085000         132K                               pte
> [    0.012534] 0xfffffe0000085000-0xfffffe0000086000           4K     ro                 GLB NX pte
> [    0.012544] 0xfffffe0000086000-0xfffffe0000087000           4K     RW                 GLB NX pte
> [    0.012553] 0xfffffe0000087000-0xfffffe000008a000          12K     ro                 GLB NX pte
> [    0.012562] 0xfffffe000008a000-0xfffffe000008b000           4K     ro                 GLB x  pte
> [    0.012572] 0xfffffe000008b000-0xfffffe0000090000          20K     RW                 GLB NX pte
> [    0.012581] 0xfffffe0000090000-0xfffffe00000b1000         132K                               pte
> [    0.012585] 0xfffffe00000b1000-0xfffffe00000b2000           4K     ro                 GLB NX pte
> [    0.012595] 0xfffffe00000b2000-0xfffffe00000b3000           4K     RW                 GLB NX pte
> [    0.012604] 0xfffffe00000b3000-0xfffffe00000b6000          12K     ro                 GLB NX pte
> [    0.012613] 0xfffffe00000b6000-0xfffffe00000b7000           4K     ro                 GLB x  pte
> [    0.012623] 0xfffffe00000b7000-0xfffffe00000bc000          20K     RW                 GLB NX pte
> [    0.012632] 0xfffffe00000bc000-0xfffffe00000dd000         132K                               pte
> [    0.012636] 0xfffffe00000dd000-0xfffffe00000de000           4K     ro                 GLB NX pte
> [    0.012646] 0xfffffe00000de000-0xfffffe00000df000           4K     RW                 GLB NX pte
> [    0.012655] 0xfffffe00000df000-0xfffffe00000e2000          12K     ro                 GLB NX pte
> [    0.012664] 0xfffffe00000e2000-0xfffffe00000e3000           4K     ro                 GLB x  pte
> [    0.012674] 0xfffffe00000e3000-0xfffffe00000e8000          20K     RW                 GLB NX pte
> [    0.012683] 0xfffffe00000e8000-0xfffffe0000109000         132K                               pte
> [    0.012687] 0xfffffe0000109000-0xfffffe000010a000           4K     ro                 GLB NX pte
> [    0.012697] 0xfffffe000010a000-0xfffffe000010b000           4K     RW                 GLB NX pte
> [    0.012706] 0xfffffe000010b000-0xfffffe000010e000          12K     ro                 GLB NX pte
> [    0.012715] 0xfffffe000010e000-0xfffffe000010f000           4K     ro                 GLB x  pte
> [    0.012725] 0xfffffe000010f000-0xfffffe0000114000          20K     RW                 GLB NX pte
> [    0.012734] 0xfffffe0000114000-0xfffffe0000135000         132K                               pte
> [    0.012738] 0xfffffe0000135000-0xfffffe0000136000           4K     ro                 GLB NX pte
> [    0.012748] 0xfffffe0000136000-0xfffffe0000137000           4K     RW                 GLB NX pte
> [    0.012757] 0xfffffe0000137000-0xfffffe000013a000          12K     ro                 GLB NX pte
> [    0.012766] 0xfffffe000013a000-0xfffffe000013b000           4K     ro                 GLB x  pte
> [    0.012776] 0xfffffe000013b000-0xfffffe0000140000          20K     RW                 GLB NX pte
> [    0.012785] 0xfffffe0000140000-0xfffffe0000161000         132K                               pte
> [    0.012789] 0xfffffe0000161000-0xfffffe0000162000           4K     ro                 GLB NX pte
> [    0.012799] 0xfffffe0000162000-0xfffffe0000163000           4K     RW                 GLB NX pte
> [    0.012808] 0xfffffe0000163000-0xfffffe0000166000          12K     ro                 GLB NX pte
> [    0.012817] 0xfffffe0000166000-0xfffffe0000167000           4K     ro                 GLB x  pte
> [    0.012827] 0xfffffe0000167000-0xfffffe000016c000          20K     RW                 GLB NX pte
> [    0.012836] 0xfffffe000016c000-0xfffffe000018d000         132K                               pte
> [    0.012840] 0xfffffe000018d000-0xfffffe000018e000           4K     ro                 GLB NX pte
> [    0.012850] 0xfffffe000018e000-0xfffffe000018f000           4K     RW                 GLB NX pte
> [    0.012859] 0xfffffe000018f000-0xfffffe0000192000          12K     ro                 GLB NX pte
> [    0.012868] 0xfffffe0000192000-0xfffffe0000193000           4K     ro                 GLB x  pte
> [    0.012878] 0xfffffe0000193000-0xfffffe0000198000          20K     RW                 GLB NX pte
> [    0.012887] 0xfffffe0000198000-0xfffffe00001b9000         132K                               pte
> [    0.012891] 0xfffffe00001b9000-0xfffffe00001ba000           4K     ro                 GLB NX pte
> [    0.012900] 0xfffffe00001ba000-0xfffffe00001bb000           4K     RW                 GLB NX pte
> [    0.012910] 0xfffffe00001bb000-0xfffffe00001be000          12K     ro                 GLB NX pte
> [    0.012919] 0xfffffe00001be000-0xfffffe00001bf000           4K     ro                 GLB x  pte
> [    0.012929] 0xfffffe00001bf000-0xfffffe00001c4000          20K     RW                 GLB NX pte
> [    0.012938] 0xfffffe00001c4000-0xfffffe00001e5000         132K                               pte
> [    0.012942] 0xfffffe00001e5000-0xfffffe00001e6000           4K     ro                 GLB NX pte
> [    0.012951] 0xfffffe00001e6000-0xfffffe00001e7000           4K     RW                 GLB NX pte
> [    0.012961] 0xfffffe00001e7000-0xfffffe00001ea000          12K     ro                 GLB NX pte
> [    0.012970] 0xfffffe00001ea000-0xfffffe00001eb000           4K     ro                 GLB x  pte
> [    0.012980] 0xfffffe00001eb000-0xfffffe00001f0000          20K     RW                 GLB NX pte
> [    0.012989] 0xfffffe00001f0000-0xfffffe0000211000         132K                               pte
> [    0.012993] 0xfffffe0000211000-0xfffffe0000212000           4K     ro                 GLB NX pte
> [    0.013005] 0xfffffe0000212000-0xfffffe0000213000           4K     RW                 GLB NX pte
> [    0.013015] 0xfffffe0000213000-0xfffffe0000216000          12K     ro                 GLB NX pte
> [    0.013024] 0xfffffe0000216000-0xfffffe0000217000           4K     ro                 GLB x  pte
> [    0.013033] 0xfffffe0000217000-0xfffffe000021c000          20K     RW                 GLB NX pte
> [    0.013043] 0xfffffe000021c000-0xfffffe000023d000         132K                               pte
> [    0.013047] 0xfffffe000023d000-0xfffffe000023e000           4K     ro                 GLB NX pte
> [    0.013056] 0xfffffe000023e000-0xfffffe000023f000           4K     RW                 GLB NX pte
> [    0.013066] 0xfffffe000023f000-0xfffffe0000242000          12K     ro                 GLB NX pte
> [    0.013075] 0xfffffe0000242000-0xfffffe0000243000           4K     ro                 GLB x  pte
> [    0.013085] 0xfffffe0000243000-0xfffffe0000248000          20K     RW                 GLB NX pte
> [    0.013094] 0xfffffe0000248000-0xfffffe0000269000         132K                               pte
> [    0.013098] 0xfffffe0000269000-0xfffffe000026a000           4K     ro                 GLB NX pte
> [    0.013107] 0xfffffe000026a000-0xfffffe000026b000           4K     RW                 GLB NX pte
> [    0.013117] 0xfffffe000026b000-0xfffffe000026e000          12K     ro                 GLB NX pte
> [    0.013126] 0xfffffe000026e000-0xfffffe000026f000           4K     ro                 GLB x  pte
> [    0.013136] 0xfffffe000026f000-0xfffffe0000274000          20K     RW                 GLB NX pte
> [    0.013145] 0xfffffe0000274000-0xfffffe0000295000         132K                               pte
> [    0.013149] 0xfffffe0000295000-0xfffffe0000296000           4K     ro                 GLB NX pte
> [    0.013158] 0xfffffe0000296000-0xfffffe0000297000           4K     RW                 GLB NX pte
> [    0.013168] 0xfffffe0000297000-0xfffffe000029a000          12K     ro                 GLB NX pte
> [    0.013177] 0xfffffe000029a000-0xfffffe000029b000           4K     ro                 GLB x  pte
> [    0.013187] 0xfffffe000029b000-0xfffffe00002a0000          20K     RW                 GLB NX pte
> [    0.013198] 0xfffffe00002a0000-0xfffffe0000400000        1408K                               pte
> [    0.013204] 0xfffffe0000400000-0xfffffe0040000000        1020M                               pmd
> [    0.013210] 0xfffffe0040000000-0xfffffe8000000000         511G                               pud
> [    0.013214] 0xfffffe8000000000-0xffffff0000000000         512G                               pgd
> [    0.013217] ---[ ESPfix Area ]---
> [    0.013219] 0xffffff0000000000-0xffffff0f00000000          60G                               pud
> [    0.013222] 0xffffff0f00000000-0xffffff0f00003000          12K                               pte
> [    0.013226] 0xffffff0f00003000-0xffffff0f00004000           4K     ro                 GLB NX pte
> [    0.013236] 0xffffff0f00004000-0xffffff0f00013000          60K                               pte
> [    0.013239] 0xffffff0f00013000-0xffffff0f00014000           4K     ro                 GLB NX pte
> [    0.013249] 0xffffff0f00014000-0xffffff0f00023000          60K                               pte
> [    0.013253] 0xffffff0f00023000-0xffffff0f00024000           4K     ro                 GLB NX pte
> [    0.013262] 0xffffff0f00024000-0xffffff0f00033000          60K                               pte
> [    0.013266] 0xffffff0f00033000-0xffffff0f00034000           4K     ro                 GLB NX pte
> [    0.013275] 0xffffff0f00034000-0xffffff0f00043000          60K                               pte
> [    0.013279] 0xffffff0f00043000-0xffffff0f00044000           4K     ro                 GLB NX pte
> [    0.013288] 0xffffff0f00044000-0xffffff0f00053000          60K                               pte
> [    0.013292] 0xffffff0f00053000-0xffffff0f00054000           4K     ro                 GLB NX pte
> [    0.013302] 0xffffff0f00054000-0xffffff0f00063000          60K                               pte
> [    0.013305] 0xffffff0f00063000-0xffffff0f00064000           4K     ro                 GLB NX pte
> [    0.013315] 0xffffff0f00064000-0xffffff0f00073000          60K                               pte
> [    0.020669] ... 131059 entries skipped ... 
> [    0.020670] ---[ EFI Runtime Services ]---
> [    0.020671] 0xffffffef00000000-0xfffffffec0000000          63G                               pud
> [    0.020676] 0xfffffffec0000000-0xfffffffee9c00000         668M                               pmd
> [    0.020680] 0xfffffffee9c00000-0xfffffffee9c08000          32K     RW                     x  pte
> [    0.020689] 0xfffffffee9c08000-0xfffffffee9c3f000         220K                               pte
> [    0.020693] 0xfffffffee9c3f000-0xfffffffee9ca0000         388K     RW                     x  pte
> [    0.020704] 0xfffffffee9ca0000-0xfffffffee9e00000        1408K                               pte
> [    0.020708] 0xfffffffee9e00000-0xfffffffee9e20000         128K     RW                     x  pte
> [    0.020719] 0xfffffffee9e20000-0xfffffffee9fc1000        1668K                               pte
> [    0.020723] 0xfffffffee9fc1000-0xfffffffeea000000         252K     RW                     x  pte
> [    0.020732] 0xfffffffeea000000-0xfffffffef3000000         144M     RW         PSE         x  pmd
> [    0.020746] 0xfffffffef3000000-0xfffffffef3400000           4M     RW                     x  pte
> [    0.020755] 0xfffffffef3400000-0xfffffffef4600000          18M     RW         PSE         x  pmd
> [    0.020767] 0xfffffffef4600000-0xfffffffef4800000           2M     RW                     x  pte
> [    0.020776] 0xfffffffef4800000-0xfffffffef5e00000          22M     RW         PSE         x  pmd
> [    0.020787] 0xfffffffef5e00000-0xfffffffef5f63000        1420K     RW                     x  pte
> [    0.020797] 0xfffffffef5f63000-0xfffffffef6084000        1156K                               pte
> [    0.020803] 0xfffffffef6084000-0xfffffffef6200000        1520K     RW                     x  pte
> [    0.020812] 0xfffffffef6200000-0xfffffffef6c00000          10M     RW         PSE         x  pmd
> [    0.020822] 0xfffffffef6c00000-0xfffffffef6d08000        1056K     RW                     x  pte
> [    0.020834] 0xfffffffef6d08000-0xfffffffef6ede000        1880K                               pte
> [    0.020839] 0xfffffffef6ede000-0xfffffffef7000000        1160K     RW                     NX pte
> [    0.020848] 0xfffffffef7000000-0xfffffffef7800000           8M     RW         PSE         NX pmd
> [    0.020859] 0xfffffffef7800000-0xfffffffef796f000        1468K     RW                     NX pte
> [    0.020868] 0xfffffffef796f000-0xfffffffef7972000          12K     ro                     x  pte
> [    0.020877] 0xfffffffef7972000-0xfffffffef7977000          20K     RW                     NX pte
> [    0.020886] 0xfffffffef7977000-0xfffffffef7978000           4K     ro                     x  pte
> [    0.020895] 0xfffffffef7978000-0xfffffffef797c000          16K     RW                     NX pte
> [    0.020903] 0xfffffffef797c000-0xfffffffef7980000          16K     ro                     x  pte
> [    0.020912] 0xfffffffef7980000-0xfffffffef7985000          20K     RW                     NX pte
> [    0.020921] 0xfffffffef7985000-0xfffffffef7986000           4K     ro                     x  pte
> [    0.020930] 0xfffffffef7986000-0xfffffffef798a000          16K     RW                     NX pte
> [    0.020939] 0xfffffffef798a000-0xfffffffef798b000           4K     ro                     x  pte
> [    0.020948] 0xfffffffef798b000-0xfffffffef7990000          20K     RW                     NX pte
> [    0.020957] 0xfffffffef7990000-0xfffffffef799d000          52K     ro                     x  pte
> [    0.020966] 0xfffffffef799d000-0xfffffffef79a4000          28K     RW                     NX pte
> [    0.020975] 0xfffffffef79a4000-0xfffffffef79a7000          12K     ro                     x  pte
> [    0.020984] 0xfffffffef79a7000-0xfffffffef79ad000          24K     RW                     NX pte
> [    0.020993] 0xfffffffef79ad000-0xfffffffef79ae000           4K     ro                     x  pte
> [    0.021004] 0xfffffffef79ae000-0xfffffffef79b3000          20K     RW                     NX pte
> [    0.021013] 0xfffffffef79b3000-0xfffffffef79b4000           4K     ro                     x  pte
> [    0.021022] 0xfffffffef79b4000-0xfffffffef79b9000          20K     RW                     NX pte
> [    0.021031] 0xfffffffef79b9000-0xfffffffef79ba000           4K     ro                     x  pte
> [    0.021039] 0xfffffffef79ba000-0xfffffffef79bf000          20K     RW                     NX pte
> [    0.021048] 0xfffffffef79bf000-0xfffffffef79c0000           4K     ro                     x  pte
> [    0.021057] 0xfffffffef79c0000-0xfffffffef79c5000          20K     RW                     NX pte
> [    0.021066] 0xfffffffef79c5000-0xfffffffef79c6000           4K     ro                     x  pte
> [    0.021075] 0xfffffffef79c6000-0xfffffffef79cb000          20K     RW                     NX pte
> [    0.021084] 0xfffffffef79cb000-0xfffffffef79cc000           4K     ro                     x  pte
> [    0.021093] 0xfffffffef79cc000-0xfffffffef79d0000          16K     RW                     NX pte
> [    0.021102] 0xfffffffef79d0000-0xfffffffef79da000          40K     ro                     x  pte
> [    0.021111] 0xfffffffef79da000-0xfffffffef79e3000          36K     RW                     NX pte
> [    0.021120] 0xfffffffef79e3000-0xfffffffef79e8000          20K     ro                     x  pte
> [    0.021129] 0xfffffffef79e8000-0xfffffffef79ed000          20K     RW                     NX pte
> [    0.021138] 0xfffffffef79ed000-0xfffffffef79f1000          16K     ro                     x  pte
> [    0.021147] 0xfffffffef79f1000-0xfffffffef79f6000          20K     RW                     NX pte
> [    0.021155] 0xfffffffef79f6000-0xfffffffef7a00000          40K     RW                     x  pte
> [    0.021165] 0xfffffffef7a00000-0xfffffffefea00000         112M     RW         PSE         x  pmd
> [    0.021174] 0xfffffffefea00000-0xfffffffefea10000          64K     RW                     x  pte
> [    0.021184] 0xfffffffefea10000-0xfffffffefeb80000        1472K                               pte
> [    0.021189] 0xfffffffefeb80000-0xfffffffefec02000         520K     RW                     x  pte
> [    0.021198] 0xfffffffefec02000-0xfffffffefec10000          56K                               pte
> [    0.021201] 0xfffffffefec10000-0xfffffffefec11000           4K     RW                     x  pte
> [    0.021210] 0xfffffffefec11000-0xfffffffefec30000         124K                               pte
> [    0.021214] 0xfffffffefec30000-0xfffffffefec31000           4K     RW                     x  pte
> [    0.021224] 0xfffffffefec31000-0xfffffffefed00000         828K                               pte
> [    0.021228] 0xfffffffefed00000-0xfffffffefed01000           4K     RW                     x  pte
> [    0.021237] 0xfffffffefed01000-0xfffffffefed40000         252K                               pte
> [    0.021240] 0xfffffffefed40000-0xfffffffefed45000          20K     RW                     x  pte
> [    0.021250] 0xfffffffefed45000-0xfffffffefed80000         236K                               pte
> [    0.021253] 0xfffffffefed80000-0xfffffffefed90000          64K     RW                     x  pte
> [    0.021262] 0xfffffffefed90000-0xfffffffefedc2000         200K                               pte
> [    0.021266] 0xfffffffefedc2000-0xfffffffefedd0000          56K     RW                     x  pte
> [    0.021275] 0xfffffffefedd0000-0xfffffffefedd4000          16K                               pte
> [    0.021278] 0xfffffffefedd4000-0xfffffffefedd6000           8K     RW                     x  pte
> [    0.021287] 0xfffffffefedd6000-0xfffffffefee00000         168K                               pte
> [    0.021292] 0xfffffffefee00000-0xfffffffefef00000           1M     RW                     x  pte
> [    0.021303] 0xfffffffefef00000-0xfffffffeff000000           1M                               pte
> [    0.021306] 0xfffffffeff000000-0xffffffff00000000          16M     RW         PSE         x  pmd
> [    0.021315] 0xffffffff00000000-0xffffffff80000000           2G                               pud
> [    0.021319] ---[ High Kernel Mapping ]---
> [    0.021321] 0xffffffff80000000-0xffffffffa3000000         560M                               pmd
> [    0.021325] 0xffffffffa3000000-0xffffffffa6400000          52M     RW         PSE     GLB x  pmd
> [    0.021335] 0xffffffffa6400000-0xffffffffc0000000         412M                               pmd
> [    0.021338] ---[ Modules ]---
> [    0.021341] 0xffffffffc0000000-0xffffffffff000000        1008M                               pmd
> [    0.021345] ---[ End Modules ]---
> [    0.021346] 0xffffffffff000000-0xffffffffff200000           2M                               pmd
> [    0.021354] 0xffffffffff200000-0xffffffffff576000        3544K                               pte
> [    0.021357] ---[ Fixmap Area ]---
> [    0.021359] 0xffffffffff576000-0xffffffffff5fa000         528K                               pte
> [    0.021363] 0xffffffffff5fa000-0xffffffffff5fd000          12K     RW PWT PCD         GLB NX pte
> [    0.021372] 0xffffffffff5fd000-0xffffffffff600000          12K                               pte
> [    0.021375] 0xffffffffff600000-0xffffffffff601000           4K USR ro                 GLB NX pte
> [    0.021387] 0xffffffffff601000-0xffffffffff800000        2044K                               pte
> [    0.021391] 0xffffffffff800000-0x0000000000000000           8M                               pmd
> [    0.021442] Security Framework initialized
> [    0.021443] Yama: becoming mindful.
> [    0.021451] SELinux:  Initializing.
> [    0.021487] SELinux:  Starting in permissive mode
> [    0.026501] Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
> [    0.029067] Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
> [    0.029170] Mount-cache hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.029248] Mountpoint-cache hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.029692] CPU: Physical Processor ID: 0
> [    0.029693] CPU: Processor Core ID: 0
> [    0.029699] mce: CPU supports 23 MCE banks
> [    0.029723] LVT offset 1 assigned for vector 0xf9
> [    0.029786] LVT offset 2 assigned for vector 0xf4
> [    0.029797] Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 512
> [    0.029798] Last level dTLB entries: 4KB 1536, 2MB 1536, 4MB 768, 1GB 0
> [    0.029800] Spectre V2 : Mitigation: Full AMD retpoline
> [    0.029801] Spectre V2 : Spectre v2 mitigation: Enabling Indirect Branch Prediction Barrier
> [    0.029803] Speculative Store Bypass: Mitigation: Speculative Store Bypass disabled via prctl and seccomp
> [    0.034160] Freeing SMP alternatives memory: 28K
> [    0.053000] smpboot: CPU0: AMD Ryzen 7 2700X Eight-Core Processor (family: 0x17, model: 0x8, stepping: 0x2)
> [    0.053000] Performance Events: Fam17h core perfctr, AMD PMU driver.
> [    0.053000] ... version:                0
> [    0.053000] ... bit width:              48
> [    0.053000] ... generic registers:      6
> [    0.053000] ... value mask:             0000ffffffffffff
> [    0.053000] ... max period:             00007fffffffffff
> [    0.053000] ... fixed-purpose events:   0
> [    0.053000] ... event mask:             000000000000003f
> [    0.053000] Hierarchical SRCU implementation.
> [    0.053226] NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
> [    0.053266] smp: Bringing up secondary CPUs ...
> [    0.053542] x86: Booting SMP configuration:
> [    0.053546] .... node  #0, CPUs:        #1  #2  #3  #4  #5  #6  #7  #8  #9 #10 #11 #12 #13 #14 #15
> [    0.074071] smp: Brought up 1 node, 16 CPUs
> [    0.074071] smpboot: Max logical packages: 1
> [    0.074071] smpboot: Total of 16 processors activated (118167.00 BogoMIPS)
> [    0.077166] devtmpfs: initialized
> [    0.077166] x86/mm: Memory block size: 128MB
> [    0.083448] PM: Registering ACPI NVS region [mem 0x04000000-0x04009fff] (40960 bytes)
> [    0.083448] PM: Registering ACPI NVS region [mem 0xdb82d000-0xdbcddfff] (4919296 bytes)
> [    0.098537] DMA-API: preallocated 65536 debug entries
> [    0.098540] DMA-API: debugging enabled by kernel config
> [    0.098542] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
> [    0.098597] futex hash table entries: 4096 (order: 7, 524288 bytes)
> [    0.098961] pinctrl core: initialized pinctrl subsystem
> [    0.099265] RTC time: 20:39:22, date: 08/10/18
> [    0.100089] NET: Registered protocol family 16
> [    0.100298] audit: initializing netlink subsys (disabled)
> [    0.100356] audit: type=2000 audit(1533933561.100:1): state=initialized audit_enabled=0 res=1
> [    0.100356] cpuidle: using governor menu
> [    0.100632] ACPI: bus type PCI registered
> [    0.100632] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
> [    0.101017] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
> [    0.101021] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
> [    0.101028] PCI: Using configuration type 1 for base access
> [    0.106137] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
> [    0.106137] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
> [    0.106333] cryptd: max_cpu_qlen set to 1000
> [    0.106333] ACPI: Added _OSI(Module Device)
> [    0.106333] ACPI: Added _OSI(Processor Device)
> [    0.106333] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.106333] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.106333] ACPI: Added _OSI(Linux-Dell-Video)
> [    0.139325] ACPI: 7 ACPI AML tables successfully acquired and loaded
> [    0.151743] ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
> [    0.159106] ACPI: EC: EC started
> [    0.159109] ACPI: EC: interrupt blocked
> [    0.159443] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as first EC
> [    0.159446] ACPI: \_SB_.PCI0.SBRG.EC0_: GPE=0x2, EC_CMD/EC_SC=0x66, EC_DATA=0x62
> [    0.159448] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as boot DSDT EC to handle transactions
> [    0.159449] ACPI: Interpreter enabled
> [    0.159478] ACPI: (supports S0 S3 S4 S5)
> [    0.159480] ACPI: Using IOAPIC for interrupt routing
> [    0.160702] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.161418] ACPI: Enabled 3 GPEs in block 00 to 1F
> [    0.187564] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    0.187571] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    0.188047] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug SHPCHotplug PME LTR]
> [    0.188481] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeCapability]
> [    0.188514] acpi PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
> [    0.189448] PCI host bridge to bus 0000:00
> [    0.189451] pci_bus 0000:00: root bus resource [io  0x0000-0x03af window]
> [    0.189453] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7 window]
> [    0.189454] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df window]
> [    0.189456] pci_bus 0000:00: root bus resource [io  0x0d00-0xefff window]
> [    0.189458] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
> [    0.189460] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dffff window]
> [    0.189461] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfec2ffff window]
> [    0.189463] pci_bus 0000:00: root bus resource [mem 0xfee00000-0xffffffff window]
> [    0.189465] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    0.189484] pci 0000:00:00.0: [1022:1450] type 00 class 0x060000
> [    0.189736] pci 0000:00:00.2: [1022:1451] type 00 class 0x080600
> [    0.189942] pci 0000:00:01.0: [1022:1452] type 00 class 0x060000
> [    0.190115] pci 0000:00:01.1: [1022:1453] type 01 class 0x060400
> [    0.190925] pci 0000:00:01.1: PME# supported from D0 D3hot D3cold
> [    0.192040] pci 0000:00:01.3: [1022:1453] type 01 class 0x060400
> [    0.192927] pci 0000:00:01.3: PME# supported from D0 D3hot D3cold
> [    0.194037] pci 0000:00:02.0: [1022:1452] type 00 class 0x060000
> [    0.194215] pci 0000:00:03.0: [1022:1452] type 00 class 0x060000
> [    0.194377] pci 0000:00:03.1: [1022:1453] type 01 class 0x060400
> [    0.194931] pci 0000:00:03.1: PME# supported from D0 D3hot D3cold
> [    0.196037] pci 0000:00:04.0: [1022:1452] type 00 class 0x060000
> [    0.196219] pci 0000:00:07.0: [1022:1452] type 00 class 0x060000
> [    0.196381] pci 0000:00:07.1: [1022:1454] type 01 class 0x060400
> [    0.196848] pci 0000:00:07.1: enabling Extended Tags
> [    0.196932] pci 0000:00:07.1: PME# supported from D0 D3hot D3cold
> [    0.198046] pci 0000:00:08.0: [1022:1452] type 00 class 0x060000
> [    0.198209] pci 0000:00:08.1: [1022:1454] type 01 class 0x060400
> [    0.198851] pci 0000:00:08.1: enabling Extended Tags
> [    0.198937] pci 0000:00:08.1: PME# supported from D0 D3hot D3cold
> [    0.200077] pci 0000:00:14.0: [1022:790b] type 00 class 0x0c0500
> [    0.200394] pci 0000:00:14.3: [1022:790e] type 00 class 0x060100
> [    0.200715] pci 0000:00:18.0: [1022:1460] type 00 class 0x060000
> [    0.200868] pci 0000:00:18.1: [1022:1461] type 00 class 0x060000
> [    0.201023] pci 0000:00:18.2: [1022:1462] type 00 class 0x060000
> [    0.201174] pci 0000:00:18.3: [1022:1463] type 00 class 0x060000
> [    0.201325] pci 0000:00:18.4: [1022:1464] type 00 class 0x060000
> [    0.201475] pci 0000:00:18.5: [1022:1465] type 00 class 0x060000
> [    0.201625] pci 0000:00:18.6: [1022:1466] type 00 class 0x060000
> [    0.201774] pci 0000:00:18.7: [1022:1467] type 00 class 0x060000
> [    0.202086] pci 0000:01:00.0: [8086:2700] type 00 class 0x010802
> [    0.202106] pci 0000:01:00.0: reg 0x10: [mem 0xfe910000-0xfe913fff 64bit]
> [    0.202133] pci 0000:01:00.0: reg 0x30: [mem 0xfe900000-0xfe90ffff pref]
> [    0.203160] pci 0000:00:01.1: PCI bridge to [bus 01]
> [    0.203165] pci 0000:00:01.1:   bridge window [mem 0xfe900000-0xfe9fffff]
> [    0.203971] pci 0000:02:00.0: [1022:43d0] type 00 class 0x0c0330
> [    0.203995] pci 0000:02:00.0: reg 0x10: [mem 0xfe5a0000-0xfe5a7fff 64bit]
> [    0.204090] pci 0000:02:00.0: PME# supported from D3hot D3cold
> [    0.204212] pci 0000:02:00.1: [1022:43c8] type 00 class 0x010601
> [    0.204250] pci 0000:02:00.1: reg 0x24: [mem 0xfe580000-0xfe59ffff]
> [    0.204256] pci 0000:02:00.1: reg 0x30: [mem 0xfe500000-0xfe57ffff pref]
> [    0.204303] pci 0000:02:00.1: PME# supported from D3hot D3cold
> [    0.204409] pci 0000:02:00.2: [1022:43c6] type 01 class 0x060400
> [    0.204492] pci 0000:02:00.2: PME# supported from D3hot D3cold
> [    0.204630] pci 0000:00:01.3: PCI bridge to [bus 02-08]
> [    0.204634] pci 0000:00:01.3:   bridge window [io  0xc000-0xdfff]
> [    0.204637] pci 0000:00:01.3:   bridge window [mem 0xfe300000-0xfe5fffff]
> [    0.204874] pci 0000:03:00.0: [1022:43c7] type 01 class 0x060400
> [    0.204972] pci 0000:03:00.0: PME# supported from D3hot D3cold
> [    0.205118] pci 0000:03:01.0: [1022:43c7] type 01 class 0x060400
> [    0.205216] pci 0000:03:01.0: PME# supported from D3hot D3cold
> [    0.205357] pci 0000:03:02.0: [1022:43c7] type 01 class 0x060400
> [    0.205455] pci 0000:03:02.0: PME# supported from D3hot D3cold
> [    0.205596] pci 0000:03:03.0: [1022:43c7] type 01 class 0x060400
> [    0.205693] pci 0000:03:03.0: PME# supported from D3hot D3cold
> [    0.205837] pci 0000:03:04.0: [1022:43c7] type 01 class 0x060400
> [    0.205935] pci 0000:03:04.0: PME# supported from D3hot D3cold
> [    0.206100] pci 0000:02:00.2: PCI bridge to [bus 03-08]
> [    0.206106] pci 0000:02:00.2:   bridge window [io  0xc000-0xdfff]
> [    0.206109] pci 0000:02:00.2:   bridge window [mem 0xfe300000-0xfe4fffff]
> [    0.206232] pci 0000:04:00.0: [8086:1539] type 00 class 0x020000
> [    0.206278] pci 0000:04:00.0: reg 0x10: [mem 0xfe400000-0xfe41ffff]
> [    0.206312] pci 0000:04:00.0: reg 0x18: [io  0xd000-0xd01f]
> [    0.206330] pci 0000:04:00.0: reg 0x1c: [mem 0xfe420000-0xfe423fff]
> [    0.206510] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
> [    0.206696] pci 0000:03:00.0: PCI bridge to [bus 04]
> [    0.206702] pci 0000:03:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.206705] pci 0000:03:00.0:   bridge window [mem 0xfe400000-0xfe4fffff]
> [    0.206788] pci 0000:05:00.0: [10ec:b822] type 00 class 0x028000
> [    0.206833] pci 0000:05:00.0: reg 0x10: [io  0xc000-0xc0ff]
> [    0.206868] pci 0000:05:00.0: reg 0x18: [mem 0xfe300000-0xfe30ffff 64bit]
> [    0.207035] pci 0000:05:00.0: supports D1 D2
> [    0.207037] pci 0000:05:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.207235] pci 0000:03:01.0: PCI bridge to [bus 05]
> [    0.207241] pci 0000:03:01.0:   bridge window [io  0xc000-0xcfff]
> [    0.207244] pci 0000:03:01.0:   bridge window [mem 0xfe300000-0xfe3fffff]
> [    0.207303] pci 0000:03:02.0: PCI bridge to [bus 06]
> [    0.207387] pci 0000:03:03.0: PCI bridge to [bus 07]
> [    0.207470] pci 0000:03:04.0: PCI bridge to [bus 08]
> [    0.207944] pci 0000:09:00.0: [1022:1470] type 01 class 0x060400
> [    0.207965] pci 0000:09:00.0: reg 0x10: [mem 0xfe700000-0xfe703fff]
> [    0.208046] pci 0000:09:00.0: PME# supported from D0 D3hot D3cold
> [    0.208186] pci 0000:00:03.1: PCI bridge to [bus 09-0b]
> [    0.208190] pci 0000:00:03.1:   bridge window [io  0xe000-0xefff]
> [    0.208192] pci 0000:00:03.1:   bridge window [mem 0xfe600000-0xfe7fffff]
> [    0.208196] pci 0000:00:03.1:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.208255] pci 0000:0a:00.0: [1022:1471] type 01 class 0x060400
> [    0.208345] pci 0000:0a:00.0: PME# supported from D0 D3hot D3cold
> [    0.208457] pci 0000:09:00.0: PCI bridge to [bus 0a-0b]
> [    0.208462] pci 0000:09:00.0:   bridge window [io  0xe000-0xefff]
> [    0.208465] pci 0000:09:00.0:   bridge window [mem 0xfe600000-0xfe6fffff]
> [    0.208470] pci 0000:09:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.208524] pci 0000:0b:00.0: [1002:687f] type 00 class 0x030000
> [    0.208550] pci 0000:0b:00.0: reg 0x10: [mem 0xe0000000-0xefffffff 64bit pref]
> [    0.208561] pci 0000:0b:00.0: reg 0x18: [mem 0xf0000000-0xf01fffff 64bit pref]
> [    0.208568] pci 0000:0b:00.0: reg 0x20: [io  0xe000-0xe0ff]
> [    0.208576] pci 0000:0b:00.0: reg 0x24: [mem 0xfe600000-0xfe67ffff]
> [    0.208583] pci 0000:0b:00.0: reg 0x30: [mem 0xfe680000-0xfe69ffff pref]
> [    0.208604] pci 0000:0b:00.0: BAR 0: assigned to efifb
> [    0.208655] pci 0000:0b:00.0: PME# supported from D1 D2 D3hot D3cold
> [    0.208758] pci 0000:0b:00.1: [1002:aaf8] type 00 class 0x040300
> [    0.208776] pci 0000:0b:00.1: reg 0x10: [mem 0xfe6a0000-0xfe6a3fff]
> [    0.208867] pci 0000:0b:00.1: PME# supported from D1 D2 D3hot D3cold
> [    0.208988] pci 0000:0a:00.0: PCI bridge to [bus 0b]
> [    0.208993] pci 0000:0a:00.0:   bridge window [io  0xe000-0xefff]
> [    0.208996] pci 0000:0a:00.0:   bridge window [mem 0xfe600000-0xfe6fffff]
> [    0.209006] pci 0000:0a:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.209959] pci 0000:0c:00.0: [1022:145a] type 00 class 0x130000
> [    0.209989] pci 0000:0c:00.0: enabling Extended Tags
> [    0.210103] pci 0000:0c:00.2: [1022:1456] type 00 class 0x108000
> [    0.210120] pci 0000:0c:00.2: reg 0x18: [mem 0xfe100000-0xfe1fffff]
> [    0.210129] pci 0000:0c:00.2: reg 0x24: [mem 0xfe200000-0xfe201fff]
> [    0.210136] pci 0000:0c:00.2: enabling Extended Tags
> [    0.210260] pci 0000:0c:00.3: [1022:145f] type 00 class 0x0c0330
> [    0.210275] pci 0000:0c:00.3: reg 0x10: [mem 0xfe000000-0xfe0fffff 64bit]
> [    0.210298] pci 0000:0c:00.3: enabling Extended Tags
> [    0.210336] pci 0000:0c:00.3: PME# supported from D0 D3hot D3cold
> [    0.210445] pci 0000:00:07.1: PCI bridge to [bus 0c]
> [    0.210449] pci 0000:00:07.1:   bridge window [mem 0xfe000000-0xfe2fffff]
> [    0.210978] pci 0000:0d:00.0: [1022:1455] type 00 class 0x130000
> [    0.211014] pci 0000:0d:00.0: enabling Extended Tags
> [    0.211130] pci 0000:0d:00.2: [1022:7901] type 00 class 0x010601
> [    0.211156] pci 0000:0d:00.2: reg 0x24: [mem 0xfe808000-0xfe808fff]
> [    0.211164] pci 0000:0d:00.2: enabling Extended Tags
> [    0.211202] pci 0000:0d:00.2: PME# supported from D3hot D3cold
> [    0.211309] pci 0000:0d:00.3: [1022:1457] type 00 class 0x040300
> [    0.211321] pci 0000:0d:00.3: reg 0x10: [mem 0xfe800000-0xfe807fff]
> [    0.211343] pci 0000:0d:00.3: enabling Extended Tags
> [    0.211380] pci 0000:0d:00.3: PME# supported from D0 D3hot D3cold
> [    0.211494] pci 0000:00:08.1: PCI bridge to [bus 0d]
> [    0.211499] pci 0000:00:08.1:   bridge window [mem 0xfe800000-0xfe8fffff]
> [    0.212315] ACPI: PCI Interrupt Link [LNKA] (IRQs 4 5 7 10 11 14 15) *0
> [    0.212446] ACPI: PCI Interrupt Link [LNKB] (IRQs 4 5 7 10 11 14 15) *0
> [    0.212564] ACPI: PCI Interrupt Link [LNKC] (IRQs 4 5 7 10 11 14 15) *0
> [    0.212700] ACPI: PCI Interrupt Link [LNKD] (IRQs 4 5 7 10 11 14 15) *0
> [    0.212830] ACPI: PCI Interrupt Link [LNKE] (IRQs 4 5 7 10 11 14 15) *0
> [    0.212938] ACPI: PCI Interrupt Link [LNKF] (IRQs 4 5 7 10 11 14 15) *0
> [    0.213052] ACPI: PCI Interrupt Link [LNKG] (IRQs 4 5 7 10 11 14 15) *0
> [    0.213160] ACPI: PCI Interrupt Link [LNKH] (IRQs 4 5 7 10 11 14 15) *0
> [    0.214350] ACPI: EC: interrupt unblocked
> [    0.214366] ACPI: EC: event unblocked
> [    0.214377] ACPI: \_SB_.PCI0.SBRG.EC0_: GPE=0x2, EC_CMD/EC_SC=0x66, EC_DATA=0x62
> [    0.214379] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as boot DSDT EC to handle transactions and events
> [    0.214588] pci 0000:0b:00.0: vgaarb: setting as boot VGA device
> [    0.214588] pci 0000:0b:00.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
> [    0.214588] pci 0000:0b:00.0: vgaarb: bridge control possible
> [    0.214588] vgaarb: loaded
> [    0.214588] SCSI subsystem initialized
> [    0.214600] libata version 3.00 loaded.
> [    0.214600] ACPI: bus type USB registered
> [    0.214600] usbcore: registered new interface driver usbfs
> [    0.215009] usbcore: registered new interface driver hub
> [    0.215221] usbcore: registered new device driver usb
> [    0.215255] pps_core: LinuxPPS API ver. 1 registered
> [    0.215257] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [    0.215261] PTP clock support registered
> [    0.215333] EDAC MC: Ver: 3.0.0
> [    0.215333] Registered efivars operations
> [    0.231607] PCI: Using ACPI for IRQ routing
> [    0.235725] PCI: pci_cache_line_size set to 64 bytes
> [    0.235806] e820: reserve RAM buffer [mem 0x09d00000-0x0bffffff]
> [    0.235813] e820: reserve RAM buffer [mem 0x0b000000-0x0bffffff]
> [    0.235815] e820: reserve RAM buffer [mem 0x99baf018-0x9bffffff]
> [    0.235817] e820: reserve RAM buffer [mem 0x99bc9018-0x9bffffff]
> [    0.235818] e820: reserve RAM buffer [mem 0xda308000-0xdbffffff]
> [    0.235820] e820: reserve RAM buffer [mem 0xdf000000-0xdfffffff]
> [    0.235822] e820: reserve RAM buffer [mem 0x81f380000-0x81fffffff]
> [    0.236117] NetLabel: Initializing
> [    0.236118] NetLabel:  domain hash size = 128
> [    0.236119] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
> [    0.236147] NetLabel:  unlabeled traffic allowed by default
> [    0.236173] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
> [    0.236173] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
> [    0.238087] clocksource: Switched to clocksource tsc-early
> [    0.274438] VFS: Disk quotas dquot_6.6.0
> [    0.274470] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> [    0.274629] pnp: PnP ACPI init
> [    0.274851] system 00:00: [mem 0xf8000000-0xfbffffff] has been reserved
> [    0.274867] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
> [    0.275021] system 00:01: [mem 0xfeb80000-0xfebfffff] could not be reserved
> [    0.275027] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.275229] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    0.275550] system 00:03: [io  0x02a0-0x02af] has been reserved
> [    0.275552] system 00:03: [io  0x0230-0x023f] has been reserved
> [    0.275555] system 00:03: [io  0x0290-0x029f] has been reserved
> [    0.275561] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.276061] system 00:04: [io  0x04d0-0x04d1] has been reserved
> [    0.276064] system 00:04: [io  0x040b] has been reserved
> [    0.276066] system 00:04: [io  0x04d6] has been reserved
> [    0.276068] system 00:04: [io  0x0c00-0x0c01] has been reserved
> [    0.276070] system 00:04: [io  0x0c14] has been reserved
> [    0.276072] system 00:04: [io  0x0c50-0x0c51] has been reserved
> [    0.276074] system 00:04: [io  0x0c52] has been reserved
> [    0.276076] system 00:04: [io  0x0c6c] has been reserved
> [    0.276078] system 00:04: [io  0x0c6f] has been reserved
> [    0.276080] system 00:04: [io  0x0cd0-0x0cd1] has been reserved
> [    0.276082] system 00:04: [io  0x0cd2-0x0cd3] has been reserved
> [    0.276085] system 00:04: [io  0x0cd4-0x0cd5] has been reserved
> [    0.276087] system 00:04: [io  0x0cd6-0x0cd7] has been reserved
> [    0.276089] system 00:04: [io  0x0cd8-0x0cdf] has been reserved
> [    0.276091] system 00:04: [io  0x0800-0x089f] has been reserved
> [    0.276093] system 00:04: [io  0x0b00-0x0b0f] has been reserved
> [    0.276095] system 00:04: [io  0x0b20-0x0b3f] has been reserved
> [    0.276097] system 00:04: [io  0x0900-0x090f] has been reserved
> [    0.276099] system 00:04: [io  0x0910-0x091f] has been reserved
> [    0.276102] system 00:04: [mem 0xfec00000-0xfec00fff] could not be reserved
> [    0.276105] system 00:04: [mem 0xfec01000-0xfec01fff] could not be reserved
> [    0.276107] system 00:04: [mem 0xfedc0000-0xfedc0fff] has been reserved
> [    0.276110] system 00:04: [mem 0xfee00000-0xfee00fff] has been reserved
> [    0.276112] system 00:04: [mem 0xfed80000-0xfed8ffff] could not be reserved
> [    0.276115] system 00:04: [mem 0xfec10000-0xfec10fff] has been reserved
> [    0.276117] system 00:04: [mem 0xff000000-0xffffffff] has been reserved
> [    0.276123] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.277130] pnp: PnP ACPI: found 5 devices
> [    0.284513] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
> [    0.284678] pci 0000:00:01.1: PCI bridge to [bus 01]
> [    0.284682] pci 0000:00:01.1:   bridge window [mem 0xfe900000-0xfe9fffff]
> [    0.284687] pci 0000:03:00.0: PCI bridge to [bus 04]
> [    0.284690] pci 0000:03:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.284694] pci 0000:03:00.0:   bridge window [mem 0xfe400000-0xfe4fffff]
> [    0.284702] pci 0000:03:01.0: PCI bridge to [bus 05]
> [    0.284704] pci 0000:03:01.0:   bridge window [io  0xc000-0xcfff]
> [    0.284708] pci 0000:03:01.0:   bridge window [mem 0xfe300000-0xfe3fffff]
> [    0.284715] pci 0000:03:02.0: PCI bridge to [bus 06]
> [    0.284725] pci 0000:03:03.0: PCI bridge to [bus 07]
> [    0.284735] pci 0000:03:04.0: PCI bridge to [bus 08]
> [    0.284745] pci 0000:02:00.2: PCI bridge to [bus 03-08]
> [    0.284748] pci 0000:02:00.2:   bridge window [io  0xc000-0xdfff]
> [    0.284752] pci 0000:02:00.2:   bridge window [mem 0xfe300000-0xfe4fffff]
> [    0.284759] pci 0000:00:01.3: PCI bridge to [bus 02-08]
> [    0.284761] pci 0000:00:01.3:   bridge window [io  0xc000-0xdfff]
> [    0.284763] pci 0000:00:01.3:   bridge window [mem 0xfe300000-0xfe5fffff]
> [    0.284769] pci 0000:0a:00.0: PCI bridge to [bus 0b]
> [    0.284771] pci 0000:0a:00.0:   bridge window [io  0xe000-0xefff]
> [    0.284775] pci 0000:0a:00.0:   bridge window [mem 0xfe600000-0xfe6fffff]
> [    0.284778] pci 0000:0a:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.284783] pci 0000:09:00.0: PCI bridge to [bus 0a-0b]
> [    0.284785] pci 0000:09:00.0:   bridge window [io  0xe000-0xefff]
> [    0.284789] pci 0000:09:00.0:   bridge window [mem 0xfe600000-0xfe6fffff]
> [    0.284792] pci 0000:09:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.284796] pci 0000:00:03.1: PCI bridge to [bus 09-0b]
> [    0.284798] pci 0000:00:03.1:   bridge window [io  0xe000-0xefff]
> [    0.284801] pci 0000:00:03.1:   bridge window [mem 0xfe600000-0xfe7fffff]
> [    0.284804] pci 0000:00:03.1:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.284807] pci 0000:00:07.1: PCI bridge to [bus 0c]
> [    0.284810] pci 0000:00:07.1:   bridge window [mem 0xfe000000-0xfe2fffff]
> [    0.284815] pci 0000:00:08.1: PCI bridge to [bus 0d]
> [    0.284818] pci 0000:00:08.1:   bridge window [mem 0xfe800000-0xfe8fffff]
> [    0.284823] pci_bus 0000:00: resource 4 [io  0x0000-0x03af window]
> [    0.284825] pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7 window]
> [    0.284826] pci_bus 0000:00: resource 6 [io  0x03b0-0x03df window]
> [    0.284828] pci_bus 0000:00: resource 7 [io  0x0d00-0xefff window]
> [    0.284829] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff window]
> [    0.284831] pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff window]
> [    0.284832] pci_bus 0000:00: resource 10 [mem 0xe0000000-0xfec2ffff window]
> [    0.284834] pci_bus 0000:00: resource 11 [mem 0xfee00000-0xffffffff window]
> [    0.284835] pci_bus 0000:01: resource 1 [mem 0xfe900000-0xfe9fffff]
> [    0.284837] pci_bus 0000:02: resource 0 [io  0xc000-0xdfff]
> [    0.284838] pci_bus 0000:02: resource 1 [mem 0xfe300000-0xfe5fffff]
> [    0.284840] pci_bus 0000:03: resource 0 [io  0xc000-0xdfff]
> [    0.284841] pci_bus 0000:03: resource 1 [mem 0xfe300000-0xfe4fffff]
> [    0.284843] pci_bus 0000:04: resource 0 [io  0xd000-0xdfff]
> [    0.284844] pci_bus 0000:04: resource 1 [mem 0xfe400000-0xfe4fffff]
> [    0.284846] pci_bus 0000:05: resource 0 [io  0xc000-0xcfff]
> [    0.284847] pci_bus 0000:05: resource 1 [mem 0xfe300000-0xfe3fffff]
> [    0.284849] pci_bus 0000:09: resource 0 [io  0xe000-0xefff]
> [    0.284850] pci_bus 0000:09: resource 1 [mem 0xfe600000-0xfe7fffff]
> [    0.284852] pci_bus 0000:09: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.284853] pci_bus 0000:0a: resource 0 [io  0xe000-0xefff]
> [    0.284855] pci_bus 0000:0a: resource 1 [mem 0xfe600000-0xfe6fffff]
> [    0.284856] pci_bus 0000:0a: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.284857] pci_bus 0000:0b: resource 0 [io  0xe000-0xefff]
> [    0.284859] pci_bus 0000:0b: resource 1 [mem 0xfe600000-0xfe6fffff]
> [    0.284860] pci_bus 0000:0b: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.284862] pci_bus 0000:0c: resource 1 [mem 0xfe000000-0xfe2fffff]
> [    0.284863] pci_bus 0000:0d: resource 1 [mem 0xfe800000-0xfe8fffff]
> [    0.285083] NET: Registered protocol family 2
> [    0.289159] tcp_listen_portaddr_hash hash table entries: 16384 (order: 8, 1441792 bytes)
> [    0.289534] TCP established hash table entries: 262144 (order: 9, 2097152 bytes)
> [    0.290197] TCP bind hash table entries: 65536 (order: 10, 5242880 bytes)
> [    0.291001] TCP: Hash tables configured (established 262144 bind 65536)
> [    0.291370] UDP hash table entries: 16384 (order: 9, 3145728 bytes)
> [    0.292059] UDP-Lite hash table entries: 16384 (order: 9, 3145728 bytes)
> [    0.292598] NET: Registered protocol family 1
> [    0.292997] pci 0000:0b:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
> [    0.293023] pci 0000:0b:00.1: Linked as a consumer to 0000:0b:00.0
> [    0.293365] PCI: CLS 64 bytes, default 64
> [    0.293510] Unpacking initramfs...
> [    0.619506] Freeing initrd memory: 27920K
> [    0.619550] AMD-Vi: IOMMU performance counters supported
> [    0.620045] iommu: Adding device 0000:00:01.0 to group 0
> [    0.620179] iommu: Adding device 0000:00:01.1 to group 1
> [    0.620353] iommu: Adding device 0000:00:01.3 to group 2
> [    0.620540] iommu: Adding device 0000:00:02.0 to group 3
> [    0.620703] iommu: Adding device 0000:00:03.0 to group 4
> [    0.620905] iommu: Adding device 0000:00:03.1 to group 5
> [    0.621085] iommu: Adding device 0000:00:04.0 to group 6
> [    0.621248] iommu: Adding device 0000:00:07.0 to group 7
> [    0.621416] iommu: Adding device 0000:00:07.1 to group 8
> [    0.621584] iommu: Adding device 0000:00:08.0 to group 9
> [    0.621746] iommu: Adding device 0000:00:08.1 to group 10
> [    0.621917] iommu: Adding device 0000:00:14.0 to group 11
> [    0.621947] iommu: Adding device 0000:00:14.3 to group 11
> [    0.622183] iommu: Adding device 0000:00:18.0 to group 12
> [    0.622213] iommu: Adding device 0000:00:18.1 to group 12
> [    0.622243] iommu: Adding device 0000:00:18.2 to group 12
> [    0.622272] iommu: Adding device 0000:00:18.3 to group 12
> [    0.622301] iommu: Adding device 0000:00:18.4 to group 12
> [    0.622332] iommu: Adding device 0000:00:18.5 to group 12
> [    0.622361] iommu: Adding device 0000:00:18.6 to group 12
> [    0.622390] iommu: Adding device 0000:00:18.7 to group 12
> [    0.622561] iommu: Adding device 0000:01:00.0 to group 13
> [    0.622765] iommu: Adding device 0000:02:00.0 to group 14
> [    0.622806] iommu: Adding device 0000:02:00.1 to group 14
> [    0.622844] iommu: Adding device 0000:02:00.2 to group 14
> [    0.622862] iommu: Adding device 0000:03:00.0 to group 14
> [    0.622880] iommu: Adding device 0000:03:01.0 to group 14
> [    0.622897] iommu: Adding device 0000:03:02.0 to group 14
> [    0.622917] iommu: Adding device 0000:03:03.0 to group 14
> [    0.622935] iommu: Adding device 0000:03:04.0 to group 14
> [    0.622958] iommu: Adding device 0000:04:00.0 to group 14
> [    0.622984] iommu: Adding device 0000:05:00.0 to group 14
> [    0.623137] iommu: Adding device 0000:09:00.0 to group 15
> [    0.623295] iommu: Adding device 0000:0a:00.0 to group 16
> [    0.623502] iommu: Adding device 0000:0b:00.0 to group 17
> [    0.623658] iommu: Using direct mapping for device 0000:0b:00.0
> [    0.623768] iommu: Adding device 0000:0b:00.1 to group 18
> [    0.623928] iommu: Adding device 0000:0c:00.0 to group 19
> [    0.624086] iommu: Adding device 0000:0c:00.2 to group 20
> [    0.624242] iommu: Adding device 0000:0c:00.3 to group 21
> [    0.624400] iommu: Adding device 0000:0d:00.0 to group 22
> [    0.624560] iommu: Adding device 0000:0d:00.2 to group 23
> [    0.624727] iommu: Adding device 0000:0d:00.3 to group 24
> [    0.624915] AMD-Vi: Found IOMMU at 0000:00:00.2 cap 0x40
> [    0.624916] AMD-Vi: Extended features (0xf77ef22294ada):
> [    0.624917]  PPR NX GT IA GA PC GA_vAPIC
> [    0.624924] AMD-Vi: Interrupt remapping enabled
> [    0.624925] AMD-Vi: virtual APIC enabled
> [    0.625162] AMD-Vi: Lazy IO/TLB flushing enabled
> [    0.631256] amd_uncore: AMD NB counters detected
> [    0.631269] amd_uncore: AMD LLC counters detected
> [    0.631611] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
> [    0.634027] Scanning for low memory corruption every 60 seconds
> [    0.634307] cryptomgr_test (128) used greatest stack depth: 14472 bytes left
> [    0.635369] Initialise system trusted keyrings
> [    0.635439] Key type blacklist registered
> [    0.635505] workingset: timestamp_bits=36 max_order=23 bucket_order=0
> [    0.638955] zbud: loaded
> [    0.640033] pstore: using deflate compression
> [    0.640159] SELinux:  Registering netfilter hooks
> [    0.705096] cryptomgr_test (131) used greatest stack depth: 13928 bytes left
> [    0.724702] cryptomgr_test (132) used greatest stack depth: 13816 bytes left
> [    0.728436] cryptomgr_test (145) used greatest stack depth: 13800 bytes left
> [    0.729846] alg: No test for 842 (842-generic)
> [    0.729886] alg: No test for 842 (842-scomp)
> [    0.731434] modprobe (155) used greatest stack depth: 13720 bytes left
> [    0.732957] cryptomgr_test (153) used greatest stack depth: 13024 bytes left
> [    0.736995] NET: Registered protocol family 38
> [    0.737008] Key type asymmetric registered
> [    0.737016] Asymmetric key parser 'x509' registered
> [    0.737097] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 244)
> [    0.737192] io scheduler noop registered
> [    0.737193] io scheduler deadline registered
> [    0.737249] io scheduler cfq registered (default)
> [    0.737251] io scheduler mq-deadline registered
> [    0.737792] atomic64_test: passed for x86-64 platform with CX8 and with SSE
> [    0.748233] pcieport 0000:00:01.1: AER enabled with IRQ 26
> [    0.748277] pcieport 0000:00:01.3: AER enabled with IRQ 27
> [    0.748309] pcieport 0000:00:03.1: AER enabled with IRQ 28
> [    0.748337] pcieport 0000:00:07.1: AER enabled with IRQ 29
> [    0.748368] pcieport 0000:00:08.1: AER enabled with IRQ 31
> [    0.748428] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> [    0.748468] efifb: probing for efifb
> [    0.748481] efifb: showing boot graphics
> [    0.750595] efifb: framebuffer at 0xe0000000, using 14400k, total 14400k
> [    0.750596] efifb: mode is 2560x1440x32, linelength=10240, pages=1
> [    0.750597] efifb: scrolling: redraw
> [    0.750599] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
> [    0.750761] fbcon: Deferring console take-over
> [    0.750768] fb0: EFI VGA frame buffer device
> [    0.750971] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
> [    0.750995] ACPI: Power Button [PWRB]
> [    0.751060] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> [    0.751185] ACPI: Power Button [PWRF]
> [    0.751280] Monitor-Mwait will be used to enter C-1 state
> [    0.754393] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
> [    0.775407] serial8250: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> [    0.779359] Non-volatile memory driver v1.3
> [    0.779409] Linux agpgart interface v0.103
> [    0.782435] ahci 0000:02:00.1: version 3.0
> [    0.782440] ahci 0000:02:00.1: enabling device (0000 -> 0002)
> [    0.782624] ahci 0000:02:00.1: SSS flag set, parallel bus scan disabled
> [    0.782675] ahci 0000:02:00.1: AHCI 0001.0301 32 slots 8 ports 6 Gbps 0xff impl SATA mode
> [    0.782677] ahci 0000:02:00.1: flags: 64bit ncq sntf stag pm led clo only pmp pio slum part sxs deso sadm sds apst 
> [    0.784093] scsi host0: ahci
> [    0.784361] scsi host1: ahci
> [    0.784502] scsi host2: ahci
> [    0.784649] scsi host3: ahci
> [    0.784781] scsi host4: ahci
> [    0.784930] scsi host5: ahci
> [    0.785063] scsi host6: ahci
> [    0.785210] scsi host7: ahci
> [    0.785272] ata1: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580100 irq 44
> [    0.785274] ata2: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580180 irq 44
> [    0.785276] ata3: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580200 irq 44
> [    0.785278] ata4: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580280 irq 44
> [    0.785279] ata5: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580300 irq 44
> [    0.785281] ata6: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580380 irq 44
> [    0.785283] ata7: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580400 irq 44
> [    0.785285] ata8: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580480 irq 44
> [    0.785343] ahci 0000:0d:00.2: enabling device (0000 -> 0002)
> [    0.785506] ahci 0000:0d:00.2: AHCI 0001.0301 32 slots 1 ports 6 Gbps 0x1 impl SATA mode
> [    0.785509] ahci 0000:0d:00.2: flags: 64bit ncq sntf ilck pm led clo only pmp fbs pio slum part 
> [    0.785776] scsi host8: ahci
> [    0.785847] ata9: SATA max UDMA/133 abar m4096@0xfe808000 port 0xfe808100 irq 46
> [    0.786020] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    0.786025] ehci-pci: EHCI PCI platform driver
> [    0.786047] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [    0.786052] ohci-pci: OHCI PCI platform driver
> [    0.786072] uhci_hcd: USB Universal Host Controller Interface driver
> [    0.786230] xhci_hcd 0000:02:00.0: xHCI Host Controller
> [    0.786434] xhci_hcd 0000:02:00.0: new USB bus registered, assigned bus number 1
> [    0.841808] xhci_hcd 0000:02:00.0: hcc params 0x0200ef81 hci version 0x110 quirks 0x0000000000000410
> [    0.842715] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 4.18
> [    0.842719] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.842721] usb usb1: Product: xHCI Host Controller
> [    0.842722] usb usb1: Manufacturer: Linux 4.18.0-0.rc8.git1.1.fc29.x86_64 xhci-hcd
> [    0.842724] usb usb1: SerialNumber: 0000:02:00.0
> [    0.843072] hub 1-0:1.0: USB hub found
> [    0.843125] hub 1-0:1.0: 14 ports detected
> [    0.878722] xhci_hcd 0000:02:00.0: xHCI Host Controller
> [    0.878830] xhci_hcd 0000:02:00.0: new USB bus registered, assigned bus number 2
> [    0.878835] xhci_hcd 0000:02:00.0: Host supports USB 3.10 Enhanced SuperSpeed
> [    0.878906] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
> [    0.878958] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 4.18
> [    0.878960] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.878962] usb usb2: Product: xHCI Host Controller
> [    0.878963] usb usb2: Manufacturer: Linux 4.18.0-0.rc8.git1.1.fc29.x86_64 xhci-hcd
> [    0.878965] usb usb2: SerialNumber: 0000:02:00.0
> [    0.879209] hub 2-0:1.0: USB hub found
> [    0.879252] hub 2-0:1.0: 8 ports detected
> [    0.899096] xhci_hcd 0000:0c:00.3: xHCI Host Controller
> [    0.899171] xhci_hcd 0000:0c:00.3: new USB bus registered, assigned bus number 3
> [    0.899288] xhci_hcd 0000:0c:00.3: hcc params 0x0270f665 hci version 0x100 quirks 0x0000000000000410
> [    0.899859] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 4.18
> [    0.899861] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.899863] usb usb3: Product: xHCI Host Controller
> [    0.899864] usb usb3: Manufacturer: Linux 4.18.0-0.rc8.git1.1.fc29.x86_64 xhci-hcd
> [    0.899866] usb usb3: SerialNumber: 0000:0c:00.3
> [    0.900049] hub 3-0:1.0: USB hub found
> [    0.900064] hub 3-0:1.0: 4 ports detected
> [    0.900413] xhci_hcd 0000:0c:00.3: xHCI Host Controller
> [    0.900474] xhci_hcd 0000:0c:00.3: new USB bus registered, assigned bus number 4
> [    0.900479] xhci_hcd 0000:0c:00.3: Host supports USB 3.0  SuperSpeed
> [    0.900506] usb usb4: We don't know the algorithms for LPM for this host, disabling LPM.
> [    0.900552] usb usb4: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 4.18
> [    0.900553] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.900555] usb usb4: Product: xHCI Host Controller
> [    0.900556] usb usb4: Manufacturer: Linux 4.18.0-0.rc8.git1.1.fc29.x86_64 xhci-hcd
> [    0.900558] usb usb4: SerialNumber: 0000:0c:00.3
> [    0.900744] hub 4-0:1.0: USB hub found
> [    0.900759] hub 4-0:1.0: 4 ports detected
> [    0.901130] usbcore: registered new interface driver usbserial_generic
> [    0.901156] usbserial: USB Serial support registered for generic
> [    0.901190] i8042: PNP: No PS/2 controller found.
> [    0.901258] mousedev: PS/2 mouse device common for all mice
> [    0.901534] rtc_cmos 00:02: RTC can wake from S4
> [    0.901867] rtc_cmos 00:02: registered as rtc0
> [    0.901869] rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
> [    0.901968] device-mapper: uevent: version 1.0.3
> [    0.902086] device-mapper: ioctl: 4.39.0-ioctl (2018-04-03) initialised: dm-devel@redhat.com
> [    0.902587] hidraw: raw HID events driver (C) Jiri Kosina
> [    0.902648] usbcore: registered new interface driver usbhid
> [    0.902649] usbhid: USB HID core driver
> [    0.902810] drop_monitor: Initializing network drop monitor service
> [    0.903092] Initializing XFRM netlink socket
> [    0.903328] NET: Registered protocol family 10
> [    0.906392] Segment Routing with IPv6
> [    0.906409] mip6: Mobile IPv6
> [    0.906418] NET: Registered protocol family 17
> [    0.906487] start plist test
> [    0.907490] end plist test
> [    0.908784] RAS: Correctable Errors collector initialized.
> [    0.910325] microcode: CPU0: patch_level=0x08008206
> [    0.910335] microcode: CPU1: patch_level=0x08008206
> [    0.910341] microcode: CPU2: patch_level=0x08008206
> [    0.910349] microcode: CPU3: patch_level=0x08008206
> [    0.910357] microcode: CPU4: patch_level=0x08008206
> [    0.910365] microcode: CPU5: patch_level=0x08008206
> [    0.910372] microcode: CPU6: patch_level=0x08008206
> [    0.910384] microcode: CPU7: patch_level=0x08008206
> [    0.910394] microcode: CPU8: patch_level=0x08008206
> [    0.910401] microcode: CPU9: patch_level=0x08008206
> [    0.910410] microcode: CPU10: patch_level=0x08008206
> [    0.910418] microcode: CPU11: patch_level=0x08008206
> [    0.910425] microcode: CPU12: patch_level=0x08008206
> [    0.910437] microcode: CPU13: patch_level=0x08008206
> [    0.910445] microcode: CPU14: patch_level=0x08008206
> [    0.910453] microcode: CPU15: patch_level=0x08008206
> [    0.910500] microcode: Microcode Update Driver: v2.2.
> [    0.910516] AVX2 version of gcm_enc/dec engaged.
> [    0.910517] AES CTR mode by8 optimization enabled
> [    0.925692] sched_clock: Marking stable (925685350, 0)->(1461327836, -535642486)
> [    0.926269] registered taskstats version 1
> [    0.926289] Loading compiled-in X.509 certificates
> [    0.949016] Loaded X.509 cert 'Fedora kernel signing key: 2144d26b5d8b3c4260adfcb8bdabc6bc99818b4f'
> [    0.950139] zswap: loaded using pool lzo/zbud
> [    0.955286] Key type big_key registered
> [    0.957502] Key type encrypted registered
> [    0.957526] ima: No TPM chip found, activating TPM-bypass! (rc=-19)
> [    0.957533] ima: Allocated hash algorithm: sha1
> [    0.958206]   Magic number: 14:19:700
> [    0.958266] acpi LNXCPU:0e: hash matches
> [    0.958385] rtc_cmos 00:02: setting system clock to 2018-08-10 20:39:23 UTC (1533933563)
> [    1.092043] ata1: SATA link down (SStatus 0 SControl 300)
> [    1.092337] ata9: SATA link down (SStatus 0 SControl 300)
> [    1.201051] usb 1-10: new full-speed USB device number 2 using xhci_hcd
> [    1.267199] usb 4-1: new SuperSpeed Gen 1 USB device number 2 using xhci_hcd
> [    1.365425] usb 4-1: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    1.365431] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.365433] usb 4-1: Product: USB3.0 Hub
> [    1.365434] usb 4-1: Manufacturer: VIA Labs, Inc.
> [    1.396951] hub 4-1:1.0: USB hub found
> [    1.397184] hub 4-1:1.0: 4 ports detected
> [    1.398284] ata2: SATA link down (SStatus 0 SControl 300)
> [    1.477056] usb 3-1: new high-speed USB device number 2 using xhci_hcd
> [    1.510874] usb 1-10: New USB device found, idVendor=0b05, idProduct=1872, bcdDevice= 2.00
> [    1.510878] usb 1-10: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [    1.510881] usb 1-10: Product: AURA LED Controller
> [    1.510883] usb 1-10: Manufacturer: AsusTek Computer Inc.
> [    1.510885] usb 1-10: SerialNumber: 00000000001A
> [    1.528879] hid-generic 0003:0B05:1872.0001: hiddev96,hidraw0: USB HID v1.11 Device [AsusTek Computer Inc. AURA LED Controller] on usb-0000:02:00.0-10/input0
> [    1.611215] usb 3-1: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    1.611218] usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.611220] usb 3-1: Product: USB2.0 Hub
> [    1.611221] usb 3-1: Manufacturer: VIA Labs, Inc.
> [    1.631112] tsc: Refined TSC clocksource calibration: 3693.062 MHz
> [    1.631128] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x6a7777116fa, max_idle_ns: 881590883556 ns
> [    1.631325] clocksource: Switched to clocksource tsc
> [    1.643022] usb 1-12: new full-speed USB device number 3 using xhci_hcd
> [    1.669296] hub 3-1:1.0: USB hub found
> [    1.670588] hub 3-1:1.0: 4 ports detected
> [    1.711257] ata3: SATA link down (SStatus 0 SControl 300)
> [    1.819038] usb 4-1.1: new SuperSpeed Gen 1 USB device number 3 using xhci_hcd
> [    1.874912] usb 1-12: New USB device found, idVendor=0b05, idProduct=185c, bcdDevice= 1.10
> [    1.874915] usb 1-12: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [    1.874917] usb 1-12: Product: Bluetooth Radio 
> [    1.874919] usb 1-12: Manufacturer: Realtek 
> [    1.874920] usb 1-12: SerialNumber: 00e04c000001
> [    1.878137] random: fast init done
> [    1.917942] usb 4-1.1: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    1.917945] usb 4-1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.917946] usb 4-1.1: Product: USB3.0 Hub
> [    1.917948] usb 4-1.1: Manufacturer: VIA Labs, Inc.
> [    1.940923] hub 4-1.1:1.0: USB hub found
> [    1.941200] hub 4-1.1:1.0: 4 ports detected
> [    2.004604] usb 3-1.1: new high-speed USB device number 3 using xhci_hcd
> [    2.023372] ata4: SATA link down (SStatus 0 SControl 300)
> [    2.103967] usb 3-1.1: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    2.103970] usb 3-1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.103972] usb 3-1.1: Product: USB2.0 Hub
> [    2.103974] usb 3-1.1: Manufacturer: VIA Labs, Inc.
> [    2.149293] hub 3-1.1:1.0: USB hub found
> [    2.150327] hub 3-1.1:1.0: 4 ports detected
> [    2.206824] usb 4-1.3: new SuperSpeed Gen 1 USB device number 4 using xhci_hcd
> [    2.305198] usb 4-1.3: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    2.305201] usb 4-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.305203] usb 4-1.3: Product: USB3.0 Hub
> [    2.305204] usb 4-1.3: Manufacturer: VIA Labs, Inc.
> [    2.324802] hub 4-1.3:1.0: USB hub found
> [    2.325077] hub 4-1.3:1.0: 4 ports detected
> [    2.383439] usb 3-1.3: new high-speed USB device number 4 using xhci_hcd
> [    2.482587] usb 3-1.3: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    2.482590] usb 3-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.482592] usb 3-1.3: Product: USB2.0 Hub
> [    2.482593] usb 3-1.3: Manufacturer: VIA Labs, Inc.
> [    2.487058] ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
> [    2.503697] ata5.00: ATA-9: HGST HUH721212ALE604, LEGNW3D0, max UDMA/133
> [    2.503699] ata5.00: 23437770752 sectors, multi 0: LBA48 NCQ (depth 32), AA
> [    2.515617] ata5.00: configured for UDMA/133
> [    2.516136] scsi 4:0:0:0: Direct-Access     ATA      HGST HUH721212AL W3D0 PQ: 0 ANSI: 5
> [    2.516652] sd 4:0:0:0: [sda] 23437770752 512-byte logical blocks: (12.0 TB/10.9 TiB)
> [    2.516662] sd 4:0:0:0: [sda] 4096-byte physical blocks
> [    2.516674] sd 4:0:0:0: [sda] Write Protect is off
> [    2.516676] sd 4:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [    2.516697] sd 4:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [    2.516763] sd 4:0:0:0: Attached scsi generic sg0 type 0
> [    2.532894] hub 3-1.3:1.0: USB hub found
> [    2.533966] hub 3-1.3:1.0: 4 ports detected
> [    2.536748] sd 4:0:0:0: [sda] Attached SCSI disk
> [    2.586754] usb 4-1.4: new SuperSpeed Gen 1 USB device number 5 using xhci_hcd
> [    2.684945] usb 4-1.4: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    2.684948] usb 4-1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.684949] usb 4-1.4: Product: USB3.0 Hub
> [    2.684951] usb 4-1.4: Manufacturer: VIA Labs, Inc.
> [    2.709285] hub 4-1.4:1.0: USB hub found
> [    2.709579] hub 4-1.4:1.0: 4 ports detected
> [    2.762374] usb 3-1.1.3: new full-speed USB device number 5 using xhci_hcd
> [    2.828272] ata6: SATA link down (SStatus 0 SControl 300)
> [    2.861712] usb 3-1.1.3: New USB device found, idVendor=054c, idProduct=09cc, bcdDevice= 1.00
> [    2.861715] usb 3-1.1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.861717] usb 3-1.1.3: Product: Wireless Controller
> [    2.861719] usb 3-1.1.3: Manufacturer: Sony Interactive Entertainment
> [    2.935056] usb 3-1.4: new high-speed USB device number 6 using xhci_hcd
> [    3.048464] usb 3-1.4: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    3.048467] usb 3-1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.048469] usb 3-1.4: Product: USB2.0 Hub
> [    3.048470] usb 3-1.4: Manufacturer: VIA Labs, Inc.
> [    3.108888] hub 3-1.4:1.0: USB hub found
> [    3.110481] hub 3-1.4:1.0: 4 ports detected
> [    3.143654] ata7: SATA link down (SStatus 0 SControl 300)
> [    3.163393] usb 3-1.3.3: new low-speed USB device number 7 using xhci_hcd
> [    3.308732] usb 3-1.3.3: New USB device found, idVendor=046d, idProduct=c326, bcdDevice=79.00
> [    3.308735] usb 3-1.3.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.308737] usb 3-1.3.3: Product: USB Keyboard
> [    3.308738] usb 3-1.3.3: Manufacturer: Logitech
> [    3.402884] input: Logitech USB Keyboard as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.3/3-1.3.3/3-1.3.3:1.0/0003:046D:C326.0003/input/input2
> [    3.445439] usb 3-1.4.4: new full-speed USB device number 8 using xhci_hcd
> [    3.452615] ata8: SATA link down (SStatus 0 SControl 300)
> [    3.454483] hid-generic 0003:046D:C326.0003: input,hidraw1: USB HID v1.10 Keyboard [Logitech USB Keyboard] on usb-0000:0c:00.3-1.3.3/input0
> [    3.459711] input: Logitech USB Keyboard Consumer Control as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.3/3-1.3.3/3-1.3.3:1.1/0003:046D:C326.0004/input/input3
> [    3.512101] input: Logitech USB Keyboard System Control as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.3/3-1.3.3/3-1.3.3:1.1/0003:046D:C326.0004/input/input4
> [    3.512317] hid-generic 0003:046D:C326.0004: input,hiddev97,hidraw2: USB HID v1.10 Device [Logitech USB Keyboard] on usb-0000:0c:00.3-1.3.3/input1
> [    3.550417] Freeing unused kernel memory: 4824K
> [    3.550589] usb 3-1.4.4: New USB device found, idVendor=046d, idProduct=c52b, bcdDevice=12.07
> [    3.550591] usb 3-1.4.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.550593] usb 3-1.4.4: Product: USB Receiver
> [    3.550595] usb 3-1.4.4: Manufacturer: Logitech
> [    3.560046] Write protecting the kernel read-only data: 22528k
> [    3.562288] Freeing unused kernel memory: 2028K
> [    3.565010] Freeing unused kernel memory: 1724K
> [    3.571445] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [    3.571449] rodata_test: all tests were successful
> [    3.628336] systemd[1]: systemd 239 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
> [    3.640373] systemd[1]: Detected architecture x86-64.
> [    3.640376] systemd[1]: Running in initial RAM disk.
> [    3.652166] systemd[1]: Set hostname to <localhost.localdomain>.
> [    3.715549] random: systemd: uninitialized urandom read (16 bytes read)
> [    3.715662] systemd[1]: Listening on Journal Audit Socket.
> [    3.715718] random: systemd: uninitialized urandom read (16 bytes read)
> [    3.720126] systemd[1]: Created slice system-systemd\x2dhibernate\x2dresume.slice.
> [    3.720140] random: systemd: uninitialized urandom read (16 bytes read)
> [    3.720150] systemd[1]: Reached target Swap.
> [    3.720371] systemd[1]: Listening on udev Control Socket.
> [    3.720392] systemd[1]: Reached target Slices.
> [    3.720562] systemd[1]: Listening on Journal Socket (/dev/log).
> [    3.747504] audit: type=1130 audit(1533933566.287:2): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.753014] audit: type=1130 audit(1533933566.292:3): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup-dev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.790656] audit: type=1130 audit(1533933566.330:4): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.790664] audit: type=1131 audit(1533933566.330:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.819784] audit: type=1130 audit(1533933566.359:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-cmdline comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.852334] audit: type=1130 audit(1533933566.392:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.855104] audit: type=1130 audit(1533933566.395:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-udev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.874012] audit: type=1130 audit(1533933566.413:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    4.135785] audit: type=1130 audit(1533933566.675:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udev-trigger comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    4.168128] nvme nvme0: pci function 0000:01:00.0
> [    4.168537] dca service started, version 1.12.1
> [    4.179283] input: Sony Interactive Entertainment Wireless Controller Touchpad as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.3/3-1.1.3:1.3/0003:054C:09CC.0002/input/input6
> [    4.179827] input: Sony Interactive Entertainment Wireless Controller Motion Sensors as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.3/3-1.1.3:1.3/0003:054C:09CC.0002/input/input7
> [    4.182968] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
> [    4.182971] igb: Copyright (c) 2007-2014 Intel Corporation.
> [    4.186569] logitech-djreceiver 0003:046D:C52B.0007: hiddev98,hidraw3: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:0c:00.3-1.4.4/input2
> [    4.232130] input: Sony Interactive Entertainment Wireless Controller as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.3/3-1.1.3:1.3/0003:054C:09CC.0002/input/input5
> [    4.232314] sony 0003:054C:09CC.0002: input,hidraw4: USB HID v81.11 Gamepad [Sony Interactive Entertainment Wireless Controller] on usb-0000:0c:00.3-1.1.3/input3
> [    4.293828] input: Logitech Unifying Device. Wireless PID:4026 Keyboard as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.4/3-1.4.4/3-1.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input8
> [    4.294151] input: Logitech Unifying Device. Wireless PID:4026 Mouse as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.4/3-1.4.4/3-1.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input9
> [    4.294346] input: Logitech Unifying Device. Wireless PID:4026 Consumer Control as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.4/3-1.4.4/3-1.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input10
> [    4.294469] input: Logitech Unifying Device. Wireless PID:4026 Keyboard as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.4/3-1.4.4/3-1.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input15
> [    4.295355] hid-generic 0003:046D:4026.0008: input,hidraw5: USB HID v1.11 Keyboard [Logitech Unifying Device. Wireless PID:4026] on usb-0000:0c:00.3-1.4.4:1
> [    4.369589] [drm] amdgpu kernel modesetting enabled.
> [    4.372485] AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
> [    4.383592] Parsing CRAT table with 1 nodes
> [    4.383604] Ignoring ACPI CRAT on non-APU system
> [    4.383613] Virtual CRAT table created for CPU
> [    4.383614] Parsing CRAT table with 1 nodes
> [    4.383615]  nvme0n1: p1 p2 p3
> [    4.383638] Creating topology SYSFS entries
> [    4.383741] Topology: Add CPU node
> [    4.383742] Finished initializing topology
> [    4.383859] kfd kfd: Initialized module
> [    4.384401] checking generic (e0000000 e10000) vs hw (e0000000 10000000)
> [    4.384404] fb: switching to amdgpudrmfb from EFI VGA
> [    4.386338] [drm] initializing kernel modesetting (VEGA10 0x1002:0x687F 0x1002:0x0B36 0xC3).
> [    4.386425] [drm] register mmio base: 0xFE600000
> [    4.386427] [drm] register mmio size: 524288
> [    4.386441] [drm] probing gen 2 caps for device 1022:1471 = 700d03/e
> [    4.386443] [drm] probing mlw for device 1022:1471 = 700d03
> [    4.386446] [drm] add ip block number 0 <soc15_common>
> [    4.386447] [drm] add ip block number 1 <gmc_v9_0>
> [    4.386449] [drm] add ip block number 2 <vega10_ih>
> [    4.386450] [drm] add ip block number 3 <psp>
> [    4.386451] [drm] add ip block number 4 <powerplay>
> [    4.386452] [drm] add ip block number 5 <dm>
> [    4.386453] [drm] add ip block number 6 <gfx_v9_0>
> [    4.386454] [drm] add ip block number 7 <sdma_v4_0>
> [    4.386455] [drm] add ip block number 8 <uvd_v7_0>
> [    4.386456] [drm] add ip block number 9 <vce_v4_0>
> [    4.386635] [drm] UVD(0) is enabled in VM mode
> [    4.386636] [drm] UVD(0) ENC is enabled in VM mode
> [    4.386637] [drm] VCE enabled in VM mode
> [    4.386687] amdgpu 0000:0b:00.0: Invalid PCI ROM header signature: expecting 0xaa55, got 0xffff
> [    4.386701] ATOM BIOS: 113-D0500300-102
> [    4.386773] [drm] vm size is 262144 GB, 4 levels, block size is 9-bit, fragment size is 9-bit
> [    4.386781] amdgpu 0000:0b:00.0: VRAM: 8176M 0x000000F400000000 - 0x000000F5FEFFFFFF (8176M used)
> [    4.386782] amdgpu 0000:0b:00.0: GTT: 512M 0x000000F600000000 - 0x000000F61FFFFFFF
> [    4.386787] [drm] Detected VRAM RAM=8176M, BAR=256M
> [    4.386788] [drm] RAM width 2048bits HBM
> [    4.387138] [TTM] Zone  kernel: Available graphics memory: 16441362 kiB
> [    4.387144] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
> [    4.387146] [TTM] Initializing pool allocator
> [    4.387163] [TTM] Initializing DMA pool allocator
> [    4.387435] [drm] amdgpu: 8176M of VRAM memory ready
> [    4.387440] [drm] amdgpu: 8176M of GTT memory ready.
> [    4.387502] [drm] GART: num cpu pages 131072, num gpu pages 131072
> [    4.387675] [drm] PCIE GART of 512M enabled (table at 0x000000F400900000).
> [    4.391597] [drm] use_doorbell being set to: [true]
> [    4.391685] [drm] use_doorbell being set to: [true]
> [    4.391921] [drm] Found UVD firmware Version: 1.87 Family ID: 17
> [    4.391928] [drm] PSP loading UVD firmware
> [    4.392556] [drm] Found VCE firmware Version: 53.45 Binary ID: 4
> [    4.392568] [drm] PSP loading VCE firmware
> [    4.412306] pps pps0: new PPS source ptp0
> [    4.412309] igb 0000:04:00.0: added PHC on eth0
> [    4.412311] igb 0000:04:00.0: Intel(R) Gigabit Ethernet Network Connection
> [    4.412312] igb 0000:04:00.0: eth0: (PCIe:2.5Gb/s:Width x1) 4c:ed:fb:75:5b:ab
> [    4.412314] igb 0000:04:00.0: eth0: PBA No: FFFFFF-0FF
> [    4.412315] igb 0000:04:00.0: Using MSI-X interrupts. 2 rx queue(s), 2 tx queue(s)
> [    4.415507] igb 0000:04:00.0 enp4s0: renamed from eth0
> [    4.449053] random: crng init done
> [    4.449065] random: 7 urandom warning(s) missed due to ratelimiting
> [    4.469826] PM: Image not found (code -22)
> [    4.618937] input: Logitech T400 as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.4/3-1.4.4/3-1.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input20
> [    4.619624] logitech-hidpp-device 0003:046D:4026.0008: input,hidraw5: USB HID v1.11 Keyboard [Logitech T400] on usb-0000:0c:00.3-1.4.4:1
> [    4.761874] [drm] Display Core initialized with v3.1.44!
> [    4.818252] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
> [    4.818254] [drm] Driver supports precise vblank timestamp query.
> [    4.841600] [drm] UVD and UVD ENC initialized successfully.
> [    4.942283] [drm] VCE initialized successfully.
> [    4.945657] kfd kfd: Allocated 3969056 bytes on gart
> [    4.945693] Virtual CRAT table created for GPU
> [    4.945694] Parsing CRAT table with 1 nodes
> [    4.945720] Creating topology SYSFS entries
> [    4.946180] Topology: Add dGPU node [0x687f:0x1002]
> [    4.946487] kfd kfd: added device 1002:687f
> [    4.950966] [drm] fb mappable at 0xE1000000
> [    4.950987] [drm] vram apper at 0xE0000000
> [    4.950988] [drm] size 33177600
> [    4.950989] [drm] fb depth is 24
> [    4.950990] [drm]    pitch is 15360
> [    4.951547] fbcon: amdgpudrmfb (fb0) is primary device
> [    4.951551] fbcon: Deferring console take-over
> [    4.951557] amdgpu 0000:0b:00.0: fb0: amdgpudrmfb frame buffer device
> [    4.960191] amdgpu 0000:0b:00.0: ring 0(gfx) uses VM inv eng 4 on hub 0
> [    4.960193] amdgpu 0000:0b:00.0: ring 1(comp_1.0.0) uses VM inv eng 5 on hub 0
> [    4.960195] amdgpu 0000:0b:00.0: ring 2(comp_1.1.0) uses VM inv eng 6 on hub 0
> [    4.960196] amdgpu 0000:0b:00.0: ring 3(comp_1.2.0) uses VM inv eng 7 on hub 0
> [    4.960198] amdgpu 0000:0b:00.0: ring 4(comp_1.3.0) uses VM inv eng 8 on hub 0
> [    4.960199] amdgpu 0000:0b:00.0: ring 5(comp_1.0.1) uses VM inv eng 9 on hub 0
> [    4.960200] amdgpu 0000:0b:00.0: ring 6(comp_1.1.1) uses VM inv eng 10 on hub 0
> [    4.960202] amdgpu 0000:0b:00.0: ring 7(comp_1.2.1) uses VM inv eng 11 on hub 0
> [    4.960203] amdgpu 0000:0b:00.0: ring 8(comp_1.3.1) uses VM inv eng 12 on hub 0
> [    4.960205] amdgpu 0000:0b:00.0: ring 9(kiq_2.1.0) uses VM inv eng 13 on hub 0
> [    4.960206] amdgpu 0000:0b:00.0: ring 10(sdma0) uses VM inv eng 4 on hub 1
> [    4.960208] amdgpu 0000:0b:00.0: ring 11(sdma1) uses VM inv eng 5 on hub 1
> [    4.960209] amdgpu 0000:0b:00.0: ring 12(uvd<0>) uses VM inv eng 6 on hub 1
> [    4.960211] amdgpu 0000:0b:00.0: ring 13(uvd_enc0<0>) uses VM inv eng 7 on hub 1
> [    4.960212] amdgpu 0000:0b:00.0: ring 14(uvd_enc1<0>) uses VM inv eng 8 on hub 1
> [    4.960214] amdgpu 0000:0b:00.0: ring 15(vce0) uses VM inv eng 9 on hub 1
> [    4.960215] amdgpu 0000:0b:00.0: ring 16(vce1) uses VM inv eng 10 on hub 1
> [    4.960216] amdgpu 0000:0b:00.0: ring 17(vce2) uses VM inv eng 11 on hub 1
> [    4.960287] [drm] ECC is not present.
> [    4.961199] [drm] Initialized amdgpu 3.26.0 20150101 for 0000:0b:00.0 on minor 0
> [    4.986824] systemd-udevd (452) used greatest stack depth: 12224 bytes left
> [    4.988611] systemd-udevd (466) used greatest stack depth: 11872 bytes left
> [    5.118703] SGI XFS with ACLs, security attributes, scrub, no debug enabled
> [    5.124429] XFS (nvme0n1p2): Mounting V5 Filesystem
> [    5.131723] XFS (nvme0n1p2): Ending clean mount
> [    5.268508] kauditd_printk_skb: 6 callbacks suppressed
> [    5.268509] audit: type=1130 audit(1533933567.808:17): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.268515] audit: type=1131 audit(1533933567.808:18): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.419155] audit: type=1130 audit(1533933567.959:19): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.431835] audit: type=1131 audit(1533933567.971:20): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.436449] audit: type=1130 audit(1533933567.976:21): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.436469] audit: type=1131 audit(1533933567.976:22): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.438197] audit: type=1130 audit(1533933567.978:23): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-initqueue comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.438211] audit: type=1131 audit(1533933567.978:24): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-initqueue comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.439923] audit: type=1130 audit(1533933567.979:25): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udev-trigger comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.439937] audit: type=1131 audit(1533933567.979:26): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udev-trigger comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.537915] systemd-journald[325]: Received SIGTERM from PID 1 (systemd).
> [    5.586898] systemd: 17 output lines suppressed due to ratelimiting
> [    5.640779] SELinux: 32768 avtab hash slots, 115177 rules.
> [    5.669820] SELinux: 32768 avtab hash slots, 115177 rules.
> [    6.014094] SELinux:  8 users, 14 roles, 5134 types, 322 bools, 1 sens, 1024 cats
> [    6.014099] SELinux:  130 classes, 115177 rules
> [    6.022993] SELinux:  Class xdp_socket not defined in policy.
> [    6.022994] SELinux: the above unknown classes and permissions will be allowed
> [    6.022998] SELinux:  policy capability network_peer_controls=1
> [    6.022999] SELinux:  policy capability open_perms=1
> [    6.023005] SELinux:  policy capability extended_socket_class=1
> [    6.023006] SELinux:  policy capability always_check_network=0
> [    6.023007] SELinux:  policy capability cgroup_seclabel=1
> [    6.023008] SELinux:  policy capability nnp_nosuid_transition=1
> [    6.023009] SELinux:  Completing initialization.
> [    6.023010] SELinux:  Setting up existing superblocks.
> [    6.083177] systemd[1]: Successfully loaded SELinux policy in 464.327ms.
> [    6.129171] systemd[1]: Relabelled /dev, /run and /sys/fs/cgroup in 31.012ms.
> [    6.130848] systemd[1]: systemd 239 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
> [    6.144262] systemd[1]: Detected architecture x86-64.
> [    6.145870] systemd[1]: Set hostname to <localhost.localdomain>.
> [    6.177778] kdump-dep-gener (609) used greatest stack depth: 11864 bytes left
> [    6.271750] systemd[1]: Stopped Switch Root.
> [    6.272215] systemd[1]: systemd-journald.service: Service has no hold-off time (RestartSec=0), scheduling restart.
> [    6.272269] systemd[1]: systemd-journald.service: Scheduled restart job, restart counter is at 1.
> [    6.272291] systemd[1]: Stopped Journal Service.
> [    6.274839] systemd[1]: Starting Journal Service...
> [    6.277631] systemd[1]: Starting Create list of required static device nodes for the current kernel...
> [    6.281166] systemd[1]: Listening on LVM2 metadata daemon socket.
> [    6.323788] Adding 67108860k swap on /dev/nvme0n1p3.  Priority:-2 extents:1 across:67108860k SSFS
> [    6.372979] systemd-journald[629]: Received request to flush runtime journal from PID 1
> [    6.622172] acpi_cpufreq: overriding BIOS provided _PSD data
> [    6.750890] acpi PNP0C14:01: duplicate WMI GUID 05901221-D566-11D1-B2F0-00A0C9062910 (first instance was on PNP0C14:00)
> [    6.754899] piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00, revision 0
> [    6.754903] piix4_smbus 0000:00:14.0: Using register 0x02 for SMBus port selection
> [    6.757362] ccp 0000:0c:00.2: enabling device (0000 -> 0002)
> [    6.757841] ccp 0000:0c:00.2: psp initialization failed
> [    6.757843] ccp 0000:0c:00.2: enabled
> [    6.772282] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver
> [    6.772668] sp5100-tco sp5100-tco: Using 0xfed80b00 for watchdog MMIO address
> [    6.772679] sp5100-tco sp5100-tco: Watchdog hardware is disabled
> [    6.818526] cfg80211: Loading compiled-in X.509 certificates for regulatory database
> [    6.819377] cfg80211: Loaded X.509 cert 'sforshee: 00b28ddf47aef9cea7'
> [    6.834941] Bluetooth: Core ver 2.22
> [    6.835027] NET: Registered protocol family 31
> [    6.835029] Bluetooth: HCI device and connection manager initialized
> [    6.835101] Bluetooth: HCI socket layer initialized
> [    6.835105] Bluetooth: L2CAP socket layer initialized
> [    6.835259] Bluetooth: SCO socket layer initialized
> [    6.850611] usbcore: registered new interface driver btusb
> [    6.854826] Bluetooth: hci0: rtl: examining hci_ver=07 hci_rev=000b lmp_ver=07 lmp_subver=8822
> [    6.854841] Bluetooth: hci0: rtl: loading rtl_bt/rtl8822b_config.bin
> [    6.856057] Bluetooth: hci0: rtl: loading rtl_bt/rtl8822b_fw.bin
> [    6.858188] Bluetooth: hci0: rom_version status=0 version=2
> [    6.858273] Bluetooth: hci0: cfg_sz 14, total size 20270
> [    6.871227] snd_hda_intel 0000:0b:00.1: Handle vga_switcheroo audio client
> [    6.877645] snd_hda_intel 0000:0d:00.3: enabling device (0000 -> 0002)
> [    6.920892] input: HD-Audio Generic HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input21
> [    6.921662] input: HD-Audio Generic HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input22
> [    6.921911] input: HD-Audio Generic HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input23
> [    6.922175] input: HD-Audio Generic HDMI/DP,pcm=9 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input24
> [    6.922347] input: HD-Audio Generic HDMI/DP,pcm=10 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input25
> [    6.922769] input: HD-Audio Generic HDMI/DP,pcm=11 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input26
> [    6.929497] snd_hda_codec_realtek hdaudioC1D0: autoconfig for ALC1220: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:line
> [    6.929501] snd_hda_codec_realtek hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
> [    6.929504] snd_hda_codec_realtek hdaudioC1D0:    hp_outs=1 (0x1b/0x0/0x0/0x0/0x0)
> [    6.929506] snd_hda_codec_realtek hdaudioC1D0:    mono: mono_out=0x0
> [    6.929507] snd_hda_codec_realtek hdaudioC1D0:    inputs:
> [    6.929511] snd_hda_codec_realtek hdaudioC1D0:      Front Mic=0x19
> [    6.929514] snd_hda_codec_realtek hdaudioC1D0:      Rear Mic=0x18
> [    6.929516] snd_hda_codec_realtek hdaudioC1D0:      Line=0x1a
> [    6.938439] kvm: Nested Virtualization enabled
> [    6.938457] kvm: Nested Paging enabled
> [    6.938459] SVM: Virtual VMLOAD VMSAVE supported
> [    6.938460] SVM: Virtual GIF supported
> [    6.946472] input: HD-Audio Generic Front Mic as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input27
> [    6.946935] input: HD-Audio Generic Rear Mic as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input28
> [    6.947259] input: HD-Audio Generic Line as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input29
> [    6.947652] input: HD-Audio Generic Line Out as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input30
> [    6.947899] input: HD-Audio Generic Front Headphone as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input31
> [    6.948406] MCE: In-kernel MCE decoding enabled.
> [    6.953032] EDAC amd64: Node 0: DRAM ECC disabled.
> [    6.953035] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
>                 Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
>                 (Note that use of the override may cause unknown side effects.)
> [    6.964858] r8822be: module is from the staging directory, the quality is unknown, you have been warned.
> [    6.972687] r8822be 0000:05:00.0: enabling device (0000 -> 0003)
> [    6.989842] r8822be: Using firmware rtlwifi/rtl8822befw.bin
> [    6.992517] EDAC amd64: Node 0: DRAM ECC disabled.
> [    6.992521] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
>                 Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
>                 (Note that use of the override may cause unknown side effects.)
> [    7.010171] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
> [    7.012018] r8822be: rtlwifi: wireless switch is on
> [    7.098267] usbcore: registered new interface driver snd-usb-audio
> [    7.305681] asus_wmi: ASUS WMI generic driver loaded
> [    7.308441] r8822be 0000:05:00.0 wlp5s0: renamed from wlan0
> [    7.310966] asus_wmi: Initialization: 0x0
> [    7.311161] asus_wmi: BIOS WMI version: 0.9
> [    7.311496] asus_wmi: SFUN value: 0x0
> [    7.314485] input: Eee PC WMI hotkeys as /devices/platform/eeepc-wmi/input/input32
> [    7.315419] asus_wmi: Number of fans: 1
> [    7.354748] systemd-udevd (706) used greatest stack depth: 11840 bytes left
> [    7.449951] XFS (sda): Mounting V5 Filesystem
> [    7.572021] XFS (sda): Ending clean mount
> [    7.923055] RPC: Registered named UNIX socket transport module.
> [    7.923063] RPC: Registered udp transport module.
> [    7.923064] RPC: Registered tcp transport module.
> [    7.923065] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [    8.109198] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
> [    8.109200] Bluetooth: BNEP filters: protocol multicast
> [    8.109206] Bluetooth: BNEP socket layer initialized
> [    8.566446] IPv6: ADDRCONF(NETDEV_UP): enp4s0: link is not ready
> [    8.598247] IPv6: ADDRCONF(NETDEV_UP): enp4s0: link is not ready
> [    8.606598] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [    9.172147] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [    9.173181] bridge: filtering via arp/ip/ip6tables is no longer available by default. Update your scripts to load br_netfilter if you need this.
> [    9.611270] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [    9.667644] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [   11.665554] igb 0000:04:00.0 enp4s0: igb: enp4s0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> [   11.767245] IPv6: ADDRCONF(NETDEV_CHANGE): enp4s0: link becomes ready
> [   12.753313] plymouthd (468) used greatest stack depth: 11648 bytes left
> [   63.491176] fuse init (API version 7.27)
> [   64.380981] Bluetooth: RFCOMM TTY layer initialized
> [   64.380988] Bluetooth: RFCOMM socket layer initialized
> [   64.381039] Bluetooth: RFCOMM ver 1.11
> [   70.866866] logitech-hidpp-device 0003:046D:4026.0008: HID++ 2.0 device connected.
> [   71.146743] rfkill: input handler disabled
> [  333.640366] kworker/dying (37) used greatest stack depth: 11632 bytes left
> [  337.385050] TaskSchedulerFo (2859) used greatest stack depth: 11160 bytes left
> [  355.753303] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [  383.329671] TaskSchedulerFo (5381) used greatest stack depth: 11096 bytes left
> 
> [  476.307476] ========================================================
> [  476.307479] WARNING: possible irq lock inversion dependency detected
> [  476.307482] 4.18.0-0.rc8.git1.1.fc29.x86_64 #1 Tainted: G         C       
> [  476.307485] --------------------------------------------------------
> [  476.307488] CPU 0/KVM/10284 just changed the state of lock:
> [  476.307491] 000000000d538a88 (&st->lock){+...}, at: speculative_store_bypass_update+0x10b/0x170
> [  476.307502] but this lock was taken by another, HARDIRQ-safe lock in the past:
> [  476.307504]  (&(&sighand->siglock)->rlock){-.-.}
> [  476.307507] 
>                
>                and interrupts could create inverse lock ordering between them.
> 
> [  476.307513] 
>                other info that might help us debug this:
> [  476.307516]  Possible interrupt unsafe locking scenario:
> 
> [  476.307519]        CPU0                    CPU1
> [  476.307521]        ----                    ----
> [  476.307523]   lock(&st->lock);
> [  476.307527]                                local_irq_disable();
> [  476.307529]                                lock(&(&sighand->siglock)->rlock);
> [  476.307533]                                lock(&st->lock);
> [  476.307537]   <Interrupt>
> [  476.307539]     lock(&(&sighand->siglock)->rlock);
> [  476.307543] 
>                 *** DEADLOCK ***
> 
> [  476.307547] 1 lock held by CPU 0/KVM/10284:
> [  476.307549]  #0: 000000009792d366 (&vcpu->mutex){+.+.}, at: kvm_vcpu_ioctl+0x78/0x6c0 [kvm]
> [  476.307583] 
>                the shortest dependencies between 2nd lock and 1st lock:
> [  476.307589]  -> (&(&sighand->siglock)->rlock){-.-.} ops: 2505028 {
> [  476.307596]     IN-HARDIRQ-W at:
> [  476.307602]                       _raw_spin_lock_irqsave+0x48/0x81
> [  476.307608]                       __lock_task_sighand+0x9a/0x1a0
> [  476.307612]                       do_send_sig_info+0x35/0x90
> [  476.307616]                       kill_pid_info+0x93/0x150
> [  476.307621]                       it_real_fn+0x3e/0x140
> [  476.307625]                       __hrtimer_run_queues+0x11e/0x520
> [  476.307629]                       hrtimer_interrupt+0x100/0x220
> [  476.307633]                       smp_apic_timer_interrupt+0x79/0x2c0
> [  476.307637]                       apic_timer_interrupt+0xf/0x20
> [  476.307640]     IN-SOFTIRQ-W at:
> [  476.307644]                       _raw_spin_lock_irqsave+0x48/0x81
> [  476.307648]                       __lock_task_sighand+0x9a/0x1a0
> [  476.307652]                       do_send_sig_info+0x35/0x90
> [  476.307655]                       kill_pid_info+0x93/0x150
> [  476.307659]                       it_real_fn+0x3e/0x140
> [  476.307663]                       __hrtimer_run_queues+0x11e/0x520
> [  476.307667]                       hrtimer_interrupt+0x100/0x220
> [  476.307671]                       smp_apic_timer_interrupt+0x79/0x2c0
> [  476.307675]                       apic_timer_interrupt+0xf/0x20
> [  476.307678]                       _raw_spin_unlock_irqrestore+0x50/0x60
> [  476.307683]                       scsi_end_request+0x112/0x1f0
> [  476.307686]                       scsi_io_completion+0x3e3/0x710
> [  476.307690]                       blk_done_softirq+0xaa/0xe0
> [  476.307694]                       __do_softirq+0xd9/0x4f7
> [  476.307699]                       irq_exit+0x10e/0x120
> [  476.307703]                       call_function_single_interrupt+0xf/0x20
> [  476.307707]                       cpuidle_enter_state+0xbc/0x350
> [  476.307711]                       do_idle+0x231/0x270
> [  476.307715]                       cpu_startup_entry+0x6f/0x80
> [  476.307720]                       start_secondary+0x1b3/0x200
> [  476.307724]                       secondary_startup_64+0xa5/0xb0
> [  476.307726]     INITIAL USE at:
> [  476.307730]                      _raw_spin_lock_irqsave+0x48/0x81
> [  476.307734]                      flush_signals+0x1d/0x60
> [  476.307738]                      kthreadd+0x35/0x390
> [  476.307742]                      ret_from_fork+0x27/0x50
> [  476.307744]   }
> [  476.307748]   ... key      at: [<ffffffffa52ac1a8>] __key.67772+0x0/0x8
> [  476.307751]   ... acquired at:
> [  476.307754]    speculative_store_bypass_update+0x81/0x170
> [  476.307758]    ssb_prctl_set+0x96/0xb0
> [  476.307762]    do_seccomp+0x6d0/0x720
> [  476.307765]    do_syscall_64+0x60/0x1f0
> [  476.307769]    entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> [  476.307773] -> (&st->lock){+...} ops: 3228332 {
> [  476.307780]    HARDIRQ-ON-W at:
> [  476.307784]                     _raw_spin_lock+0x30/0x70
> [  476.307788]                     speculative_store_bypass_update+0x10b/0x170
> [  476.307795]                     svm_vcpu_run+0x187/0x6e0 [kvm_amd]
> [  476.307797]    INITIAL USE at:
> [  476.307801]                    _raw_spin_lock+0x30/0x70
> [  476.307805]                    speculative_store_bypass_update+0x81/0x170
> [  476.307808]                    ssb_prctl_set+0x96/0xb0
> [  476.307811]                    do_seccomp+0x6d0/0x720
> [  476.307815]                    do_syscall_64+0x60/0x1f0
> [  476.307818]                    entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [  476.307820]  }
> [  476.307824]  ... key      at: [<ffffffffa524c998>] __key.54335+0x0/0x8
> [  476.307826]  ... acquired at:
> [  476.307830]    __lock_acquire+0x578/0x16c0
> [  476.307833]    lock_acquire+0x9e/0x1b0
> [  476.307836]    _raw_spin_lock+0x30/0x70
> [  476.307839]    speculative_store_bypass_update+0x10b/0x170
> [  476.307846]    svm_vcpu_run+0x187/0x6e0 [kvm_amd]
> 
> [  476.307850] 
>                stack backtrace:
> [  476.307856] CPU: 0 PID: 10284 Comm: CPU 0/KVM Tainted: G         C        4.18.0-0.rc8.git1.1.fc29.x86_64 #1
> [  476.307859] Hardware name: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 0901 07/23/2018
> [  476.307861] Call Trace:
> [  476.307868]  dump_stack+0x85/0xc0
> [  476.307873]  check_usage_backwards.cold.59+0x1d/0x26
> [  476.307880]  mark_lock+0x2c8/0x620
> [  476.307884]  ? print_shortest_lock_dependencies+0x40/0x40
> [  476.307889]  __lock_acquire+0x578/0x16c0
> [  476.307892]  ? __lock_acquire+0x29a/0x16c0
> [  476.307897]  ? __lock_acquire+0x29a/0x16c0
> [  476.307902]  ? native_sched_clock+0x3e/0xa0
> [  476.307906]  lock_acquire+0x9e/0x1b0
> [  476.307910]  ? speculative_store_bypass_update+0x10b/0x170
> [  476.307915]  _raw_spin_lock+0x30/0x70
> [  476.307919]  ? speculative_store_bypass_update+0x10b/0x170
> [  476.307923]  speculative_store_bypass_update+0x10b/0x170
> [  476.307931]  svm_vcpu_run+0x187/0x6e0 [kvm_amd]
> [  476.307972]  ? kvm_arch_vcpu_ioctl_run+0x492/0x1ed0 [kvm]
> [  476.308008]  ? kvm_vcpu_ioctl+0x2c0/0x6c0 [kvm]
> [  476.308039]  ? kvm_vcpu_ioctl+0x2c0/0x6c0 [kvm]
> [  476.308044]  ? __seccomp_filter+0x44/0x4a0
> [  476.308049]  ? native_sched_clock+0x3e/0xa0
> [  476.308056]  ? do_vfs_ioctl+0xa5/0x6e0
> [  476.308063]  ? ksys_ioctl+0x60/0x90
> [  476.308067]  ? __x64_sys_ioctl+0x16/0x20
> [  476.308072]  ? do_syscall_64+0x60/0x1f0
> [  476.308077]  ? entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [  671.741420] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [  987.743807] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 1292.089268] kworker/dying (220) used greatest stack depth: 10888 bytes left
> [ 1303.735226] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 1619.726714] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 1935.727006] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 2251.719279] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 2480.748957] DMA-API: debugging out of memory - disabling
> [ 2567.735758] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 2883.724064] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 2954.133872] kworker/dying (218) used greatest stack depth: 10608 bytes left
> [ 3199.723409] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 3515.709860] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 3831.698153] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 4147.687609] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 4463.685007] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 4779.680243] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 5095.687794] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 5411.669209] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 5727.678673] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 6043.660395] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 6359.655093] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 6675.665600] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 6991.654199] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 7307.641845] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 7623.638620] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 7939.652194] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 8255.648755] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 8571.645250] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 8887.634999] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 9203.636537] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 9519.646179] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [ 9835.617789] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [10151.607470] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [10467.613965] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [10783.597629] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [11099.606108] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [11415.588668] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [11731.599328] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [12047.579950] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [12363.580403] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [12679.578117] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [12995.578720] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [13311.562282] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [13627.562888] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [13943.583490] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [14259.560127] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [14575.542760] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [14891.566375] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [15207.549010] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [15523.528711] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [15839.536317] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [16155.529752] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [16471.538561] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [16787.513223] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [17103.526893] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [17419.512371] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [17735.519062] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [18051.494667] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [18367.490195] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [18683.514877] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [18999.492385] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [19315.477101] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [19631.480708] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [19947.483277] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [20263.470818] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [20579.464500] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [20895.455084] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [21211.451583] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [21527.450143] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [21843.457770] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [22159.441367] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [22475.432935] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [22791.434394] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [23107.440072] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [23423.425631] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [23739.423137] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [24055.416837] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [24371.422417] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [24687.402906] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [25003.411439] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [25319.394117] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [25635.397549] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [25951.395176] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [26267.398775] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [26583.375241] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [26899.374890] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [27215.387350] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [27531.366070] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [27847.356601] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [28163.353184] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [28479.355688] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [28795.354206] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [29111.339814] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [29427.346461] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [29743.331988] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [30059.326689] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [30375.325998] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [30691.323533] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [31007.329225] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [31323.323716] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [31639.310263] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [31955.305909] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [32271.297398] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [32587.299025] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [32903.302709] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [33219.313223] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [33535.286806] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [33851.279324] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [34167.290218] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [34483.284935] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [34799.271677] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [35115.257130] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [35431.265924] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [35747.277481] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [36063.244019] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [36379.249524] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [36695.234214] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [37011.251663] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [37327.234325] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [37643.221821] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [37959.272357] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [37984.348563] kauditd_printk_skb: 57 callbacks suppressed
> [37984.348565] audit: type=1305 audit(1533971546.543:270): audit_pid=0 old=893 auid=4294967295 ses=4294967295 subj=system_u:system_r:auditd_t:s0 res=1
> [37984.368004] audit: type=1130 audit(1533971546.563:271): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=auditd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [37984.368041] audit: type=1131 audit(1533971546.563:272): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=auditd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [37985.374484] audit: type=1305 audit(1533971547.569:273): audit_enabled=1 old=1 auid=4294967295 ses=4294967295 subj=system_u:system_r:auditd_t:s0 res=1
> [37985.374503] audit: type=1305 audit(1533971547.569:274): audit_pid=14804 old=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:auditd_t:s0 res=1
> [38275.217881] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [38591.219426] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
