Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id A7F5A82F90
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 14:51:34 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id o62so123743610oif.3
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 11:51:34 -0800 (PST)
Received: from muru.com (muru.com. [72.249.23.125])
        by mx.google.com with ESMTP id kj1si626215oeb.30.2015.12.23.11.51.33
        for <linux-mm@kvack.org>;
        Wed, 23 Dec 2015 11:51:33 -0800 (PST)
Date: Wed, 23 Dec 2015 11:51:29 -0800
From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
Message-ID: <20151223195129.GP2793@atomide.com>
References: <20151202202725.GA794@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151202202725.GA794@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Nicolas Pitre <nico@linaro.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com, linux-arm-kernel@lists.infradead.org, Laura Abbott <labbott@fedoraproject.org>

* Kees Cook <keescook@chromium.org> [151202 12:31]:
> The use of CONFIG_DEBUG_RODATA is generally seen as an essential part of
> kernel self-protection:
> http://www.openwall.com/lists/kernel-hardening/2015/11/30/13
> Additionally, its name has grown to mean things beyond just rodata. To
> get ARM closer to this, we ought to rearrange the names of the configs
> that control how the kernel protects its memory. What was called
> CONFIG_ARM_KERNMEM_PERMS is really doing the work that other architectures
> call CONFIG_DEBUG_RODATA.
> 
> This redefines CONFIG_DEBUG_RODATA to actually do the bulk of the
> ROing (and NXing). In the place of the old CONFIG_DEBUG_RODATA, use
> CONFIG_DEBUG_ALIGN_RODATA, since that's what the option does: adds
> section alignment for making rodata explicitly NX, as arm does not split
> the page tables like arm64 does without _ALIGN_RODATA.

Also all omap3 boards are now oopsing in Linux next if PM is enabled:

[   18.549865] Unable to handle kernel paging request at virtual address c01237dc
[   18.557830] pgd = cf704000
[   18.560974] [c01237dc] *pgd=8000041e(bad)
[   18.565765] Internal error: Oops: 80d [#1] SMP ARM
[   18.571105] Modules linked in: ledtrig_default_on leds_gpio led_class rtc_twl twl4030_wdt
[   18.581024] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.0-rc6-00003-g1bb2057 #2973
[   18.589508] Hardware name: Generic OMAP36xx (Flattened Device Tree)
[   18.596466] task: c0c06638 ti: c0c00000 task.ti: c0c00000
[   18.602539] PC is at wait_dll_lock_timed+0x8/0x14
[   18.607849] LR is at save_context_wfi+0x24/0x28
[   18.612976] pc : [<c0123750>]    lr : [<c01236b0>]    psr: 600e0093
[   18.612976] sp : c0c01ea0  ip : c0c028d4  fp : 00000002
[   18.625549] r10: 00000000  r9 : ffffffff  r8 : 00000000
[   18.631378] r7 : c01237d8  r6 : 00000003  r5 : 0000000a  r4 : 00000001
[   18.638610] r3 : 00000004  r2 : 00000006  r1 : f03fe03a  r0 : 0a000023
[   18.645843] Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
[   18.653839] Control: 10c53879  Table: 8f704019  DAC: 00000051
[   18.660217] Process swapper/0 (pid: 0, stack limit = 0xc0c00218)
[   18.666900] Stack: (0xc0c01ea0 to 0xc0c02000)
[   18.671936] 1ea0: 00000030 c0c01efc 00000003 00000001 00000000 c0c0a0a0 c0c028d4 00000000
[   18.681060] 1ec0: c0122ef8 00000000 c010d210 8f0b0000 c0c01efc 80119dc0 00000000 00000000
[   18.690185] 1ee0: 00000000 00000051 80004019 10c5387d 000000e2 00f00000 00000000 c0c06638
[   18.699279] 1f00: cf6a4e00 00000003 00000001 00000000 c0c0a0a0 00000000 00000000 c010d3bc
[   18.708404] 1f20: c0cbd460 c0cbdd14 00000003 c012308c 00000003 c0c09f90 c0cbdd54 00000000
[   18.717529] 1f40: 00000001 c0124584 51b8dc60 00000004 c0cb8a9c c0c09fa0 cfb3ba58 c05a8e14
[   18.726654] 1f60: 008a43a0 00000000 51b8dc60 00000004 51b8dc60 00000004 c0c029ec c0c00000
[   18.735778] 1f80: c0c029ec 00000000 c0cb8a9c cfb3ba58 c0c09fa0 c0c0298c c0b6ea50 c017bbb4
[   18.744934] 1fa0: c0740760 c0b6a4e4 c0cbd000 ffffffff cfb473c0 c0b00c34 ffffffff ffffffff
[   18.754058] 1fc0: 00000000 c0b0066c 00000000 c0b4fa48 00000000 c0cbd214 c0c0296c c0b4fa44
[   18.763183] 1fe0: c0c08208 80004059 413fc082 00000000 00000000 8000807c 00000000 00000000
[   18.772308] [<c0123750>] (wait_dll_lock_timed) from [<c0c0a0a0>] (omap3_idle_driver+0x100/0x33c)
[   18.782043] Code: 1a000019 e28f708c e59f408c e2844001 (e5874004)

Reverting the $subject patch fixes the issue.

Regards,

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
