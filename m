Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 445116B005A
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 10:23:12 -0400 (EDT)
Date: Mon, 24 Sep 2012 16:23:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-ID: <20120924142305.GD12264@quack.suse.cz>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Content-Disposition: inline
In-Reply-To: <20120924102324.GA22303@aftab.osrc.amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Conny Seidel <conny.seidel@amd.com>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

  Hello,

On Mon 24-09-12 12:23:24, Borislav Petkov wrote:
> we're able to trigger the oops below when doing CPU hotplug tests.
  Thanks for detailed report.

> Disassembling the code section of the oops gives
> 
>    0:   1a 00                   sbb    (%rax),%al
>    2:   b8 64 00 00 00          mov    $0x64,%eax
>    7:   2b 05 5c a4 28 01       sub    0x128a45c(%rip),%eax        # 0x128a469
>    d:   be 64 00 00 00          mov    $0x64,%esi
>   12:   31 d2                   xor    %edx,%edx
>   14:   8b 7d e0                mov    -0x20(%rbp),%edi
>   17:   48 0f af c3             imul   %rbx,%rax
>   1b:   48 f7 f6                div    %rsi
>   1e:   31 d2                   xor    %edx,%edx
>   20:   48 89 c1                mov    %rax,%rcx
>   23:   48 0f af 4d e8          imul   -0x18(%rbp),%rcx
>   28:   48 89 c8                mov    %rcx,%rax
>   2b:*  48 f7 f7                div    %rdi     <-- trapping instruction
>   2e:   31 d2                   xor    %edx,%edx
>   30:   48 89 c1                mov    %rax,%rcx
>   33:   41 8b 84 24 4c 01 00    mov    0x14c(%r12),%eax
>   3a:   00 
>   3b:   48 0f af c3             imul   %rbx,%rax
>   3f:   48                      rex.W
> 
> in bdi_dirty_limit. The .s file contains then (annotations mine):
> 
> .globl bdi_dirty_limit
>         .type   bdi_dirty_limit, @function
> bdi_dirty_limit:
>         pushq   %rbp    #
>         movq    %rsp, %rbp      #,
>         pushq   %r12    #
>         pushq   %rbx    #
>         subq    $48, %rsp       #,
>         call    mcount
>         movq    %rsi, %rbx      # dirty, dirty
>         leaq    -32(%rbp), %rcx #, tmp65
>         leaq    -24(%rbp), %rdx #, tmp66
>         leaq    280(%rdi), %rsi #, tmp67
>         movq    %rdi, %r12      # bdi, bdi
>         movq    $writeout_completions, %rdi     #,
>         call    fprop_fraction_percpu   #
>         movl    $100, %eax      #, tmp69
>         subl    bdi_min_ratio(%rip), %eax       # bdi_min_ratio, tmp70
>         movl    $100, %esi      #, tmp75
>         xorl    %edx, %edx      #
>         mov     -32(%rbp), %edi # denominator, denominator
>         imulq   %rbx, %rax      # dirty, tmp71
>         divq    %rsi    # tmp75
>         xorl    %edx, %edx      #			# most-significant part of bdi_dirty is already zeroed here
>         movq    %rax, %rcx      # tmp71, tmp73
>         imulq   -24(%rbp), %rcx # numerator, tmp73	# bdi_dirty *= numerator
>         movq    %rcx, %rax      # tmp73,		# move bdi_dirty in place for next insn
>         divq    %rdi		# denominator		<--- TRAP
>         xorl    %edx, %edx      #
>         movq    %rax, %rcx      #, tmp78
> 	...
> 
> and from looking at the register dump below, the dividend, which should
> be in %rdx:%rax is 0 and the divisor (denominator) we've got from
> bdi_writeout_fraction and is in %rdi is also 0. Which is strange because
> fprop_fraction_percpu guards for division by zero by setting denominator
> to 1 if it were zero but what about the case where den > num? Can that
> even happen?
> 
> And also, what happens if num is 0? Which it kinda is by looking at %rcx
> where there's copy of it.
  fprop_fraction_percpu() does:
        do {
                seq = read_seqcount_begin(&p->sequence);
                fprop_reflect_period_percpu(p, pl);
                num = percpu_counter_read_positive(&pl->events);
                den = percpu_counter_read_positive(&p->events);
        } while (read_seqcount_retry(&p->sequence, seq));

        /*
         * Make fraction <= 1 and denominator > 0 even in presence of
         * percpu
         * counter errors
         */
        if (den <= num) {
                if (num)
                        den = num;
                else
                        den = 1;
        }
        *denominator = den;
        *numerator = num;

  So after initial loop, num and den are >= 0 because
percpu_counter_read_positive() asserts that. If den == 0, then the
condition is true and thus we always set den to value >= 1. So at least in
the theoretical model of computation what you observe cannot happen :).

  Because of use of percpu_counter_read_positive() it also doesn't seem like
some catch with sign extension (we always deal with non-negative numbers)
and because you are on a 64-bit machine, s64 fits into long without.
However, do_div() assumes divisor is 32-bit and we can indeed observe that
in the disassembly where we prepare the divisor as:
         mov     -32(%rbp), %edi # denominator, denominator
(32-bit move insn used). I'm not quite sure if I read the stack in the dump
correctly but -32(%rbp) seems to be 0x2000000000000000 which would fit what
we see.

But I'm currently at a loss how (1 << 61) got to
writeout_completions->events->counter. Either it could be some memory
corruption (unlikely since more people see this) or there's a bug lurking
somewhere. Hum, maybe it could be a sign issue after all. Can you try
running with attached patch? Does it report anything?

> Sep 23 17:41:08 lemure kernel: [ 381.245776] divide error: 0000 [#1] SMP
> Sep 23 17:41:08 lemure kernel: [ 381.249725] Modules linked in: cpufreq_conservative cpufreq_userspace cpufreq_powersave i2c_piix4 tpm_tis rtc_cmos powernow_k8 tpm fam15
> h_power k10temp tpm_bios mperf serio_raw crc32c_intel ghash_clmulni_intel
> Sep 23 17:41:08 lemure kernel: [ 381.268531] CPU 0
> Sep 23 17:41:08 lemure kernel: [ 381.270377] Pid: 6644, comm: flush-8:0 Not tainted 3.6.0-rc6-e5e77cf9-linus+ #1 AMD
> Sep 23 17:41:08 lemure kernel: [ 381.279067] RIP: 0010:[<ffffffff810e8bc2>] [<ffffffff810e8bc2>] bdi_dirty_limit+0x5a/0x9e
> Sep 23 17:41:08 lemure kernel: [ 381.287330] RSP: 0018:ffff88041ad03d40 EFLAGS: 00010246
> Sep 23 17:41:08 lemure kernel: [ 381.292631] RAX: 0000000000000000 RBX: 00000000000621c3 RCX: 0000000000000000
> Sep 23 17:41:08 lemure kernel: [ 381.299751] RDX: 0000000000000000 RSI: 0000000000000064 RDI: 0000000000000000
> Sep 23 17:41:08 lemure kernel: [ 381.306870] RBP: ffff88041ad03d80 R08: 0000000000000008 R09: ffffffff8211e520
> Sep 23 17:41:08 lemure kernel: [ 381.313989] R10: ffff88041ad03d10 R11: ffff88041ad03d10 R12: ffff88041a2d0158
> Sep 23 17:41:08 lemure kernel: [ 381.321109] R13: ffff88041a2d0158 R14: ffff88041a2d02b0 R15: 0000000000000000
> Sep 23 17:41:08 lemure kernel: [ 381.328228] FS: 00007f3db8ea7700(0000) GS:ffff88042ec00000(0000) knlGS:0000000000000000
> Sep 23 17:41:08 lemure kernel: [ 381.336298] CS: 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Sep 23 17:41:08 lemure kernel: [ 381.342034] CR2: 0000000000d84270 CR3: 0000000418ce4000 CR4: 00000000000407f0
> Sep 23 17:41:08 lemure kernel: [ 381.349151] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Sep 23 17:41:08 lemure kernel: [ 381.356263] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Sep 23 17:41:08 lemure kernel: [ 381.363384] Process flush-8:0 (pid: 6644, threadinfo ffff88041ad02000, task ffff8804198826c0)
> Sep 23 17:41:08 lemure kernel: [ 381.371884] Stack:
> Sep 23 17:41:08 lemure kernel: [ 381.373890] ffff88041ad03d80 ffffffff810e8e7a 0000000100013eb3 0000000000000000
> Sep 23 17:41:08 lemure kernel: [ 381.381330] 2000000000000000 0000000000000000 fffffffffffffff7 0000000000000000
> Sep 23 17:41:08 lemure kernel: [ 381.388769] ffff88041ad03dc0 ffffffff8114f9bd 000000010000c983 00000000000c4386
> Sep 23 17:41:08 lemure kernel: [ 381.396208] Call Trace:
> Sep 23 17:41:09 lemure kernel: [ 381.398654] [<ffffffff810e8e7a>] ? global_dirty_limits+0x3c/0x130
> Sep 23 17:41:09 lemure kernel: [ 381.404823] [<ffffffff8114f9bd>] over_bground_thresh+0x5c/0x76
> Sep 23 17:41:09 lemure kernel: [ 381.410729] [<ffffffff811503aa>] wb_do_writeback+0x193/0x1e9
> Sep 23 17:41:09 lemure kernel: [ 381.416464] [<ffffffff811504ca>] bdi_writeback_thread+0xca/0x1ec
> Sep 23 17:41:09 lemure kernel: [ 381.422545] [<ffffffff81150400>] ? wb_do_writeback+0x1e9/0x1e9
> Sep 23 17:41:09 lemure kernel: [ 381.428455] [<ffffffff8105e75b>] kthread+0x8d/0x95
> Sep 23 17:41:09 lemure kernel: [ 381.433323] [<ffffffff81940474>] kernel_thread_helper+0x4/0x10
> Sep 23 17:41:09 lemure kernel: [ 381.439231] [<ffffffff8105e6ce>] ? kthread_freezable_should_stop+0x62/0x62
> Sep 23 17:41:09 lemure kernel: [ 381.446178] [<ffffffff81940470>] ? gs_change+0xb/0xb
> Sep 23 17:41:09 lemure kernel: [ 381.451217] Code: 1a 00 b8 64 00 00 00 2b 05 5c a4 28 01 be 64 00 00 00 31 d2 8b 7d e0 48 0f af c3 48 f7 f6 31 d2 48 89 c1 48 0f af 4d e8 48 89 c8 <48> f7 f7 31 d2 48 89 c1 41 8b 84 24 4c 01 00 00 48 0f af c3 48
> Sep 23 17:41:10 lemure kernel: [ 381.471131] RIP [<ffffffff810e8bc2>] bdi_dirty_limit+0x5a/0x9e
> Sep 23 17:41:10 lemure kernel: [ 381.477057] RSP <ffff88041ad03d40>
> Sep 23 17:41:10 lemure kernel: [ 381.480604] ---[ end trace 703f173ed75f76a9 ]---
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--9jxsPFA5p3P2qPhR
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-lib-Debug-flex-proportions-code.patch"


--9jxsPFA5p3P2qPhR--
