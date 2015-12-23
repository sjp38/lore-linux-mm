Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id D251382F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 19:36:14 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id o11so67095926qge.2
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 16:36:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 88si18431560qgz.40.2015.12.22.16.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 16:36:14 -0800 (PST)
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
References: <20151202202725.GA794@www.outflux.net>
 <CAMuHMdWiVv6fZjKo1ZjJdunnq+qDapUBCt24E+BtwEzgduMDFQ@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <5679EC79.1080003@redhat.com>
Date: Tue, 22 Dec 2015 16:36:09 -0800
MIME-Version: 1.0
In-Reply-To: <CAMuHMdWiVv6fZjKo1ZjJdunnq+qDapUBCt24E+BtwEzgduMDFQ@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Kees Cook <keescook@chromium.org>, Russell King <linux@arm.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux-sh list <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Nicolas Pitre <nico@linaro.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Laura Abbott <labbott@fedoraproject.org>

On 12/22/2015 02:37 AM, Geert Uytterhoeven wrote:
> Hi Kees, Russell,
>
> On Wed, Dec 2, 2015 at 9:27 PM, Kees Cook <keescook@chromium.org> wrote:
>> The use of CONFIG_DEBUG_RODATA is generally seen as an essential part of
>> kernel self-protection:
>> http://www.openwall.com/lists/kernel-hardening/2015/11/30/13
>> Additionally, its name has grown to mean things beyond just rodata. To
>> get ARM closer to this, we ought to rearrange the names of the configs
>> that control how the kernel protects its memory. What was called
>> CONFIG_ARM_KERNMEM_PERMS is really doing the work that other architectures
>> call CONFIG_DEBUG_RODATA.
>
> [...]
>
> This broke s2ram with shmobile_defconfig on r8a7791/koelsch:
>
>      Freezing user space processes ... (elapsed 0.002 seconds) done.
>      Freezing remaining freezable tasks ... (elapsed 0.003 seconds) done.
>      PM: suspend of devices complete after 112.157 msecs
>      PM: late suspend of devices complete after 1.605 msecs
>      PM: noirq suspend of devices complete after 13.098 msecs
>      Disabling non-boot CPUs ...
>      s---[ end Kernel panic - not syncing: Attempted to kill the idle task!
>      CPU0: stopping
>      CPU: 0 PID: 2412 Comm: s2ram Tainted: G      D
> 4.4.0-rc6-00003-g1bb20571dcf0edfc #470
>      Hardware name: Generic R8A7791 (Flattened Device Tree)
>      Backtrace:
>      [<c010a92c>] (dump_backtrace) from [<c010aad4>] (show_stack+0x18/0x1c)
>       r6:00000000 r5:00000000 r4:00000000 r3:80404000
>      [<c010aabc>] (show_stack) from [<c02b9ff4>] (dump_stack+0x78/0x94)
>      [<c02b9f7c>] (dump_stack) from [<c010d4b4>] (handle_IPI+0xf4/0x19c)
>       r4:c09313f0 r3:c09091ec
>      [<c010d3c0>] (handle_IPI) from [<c0101430>] (gic_handle_irq+0x7c/0x98)
>       r7:c0910b80 r6:ee1d5c30 r5:c0902754 r4:f0802000
>      [<c01013b4>] (gic_handle_irq) from [<c010b654>] (__irq_svc+0x54/0x70)
>      Exception stack(0xee1d5c30 to 0xee1d5c78)
>      5c20:                                     c0955484 00000002
> 00000000 60070013
>      5c40: c0942718 c093916c 00000005 0000000f 00000000 00000000
> c0943088 ee1d5cd4
>      5c60: ee1d5c08 ee1d5c80 c033fc20 c0158120 60070013 ffffffff
>       r8:00000000 r7:ee1d5c64 r6:ffffffff r5:60070013 r4:c0158120 r3:c033fc20
>      [<c0157ecc>] (console_unlock) from [<c0158724>] (vprintk_emit+0x448/0x4a4)
>       r10:c09450a6 r9:00000000 r8:0000000e r7:00000005 r6:00000006 r5:c0932758
>       r4:00000001
>      [<c01582dc>] (vprintk_emit) from [<c01588e0>] (vprintk_default+0x28/0x30)
>       r10:c09055e0 r9:00000001 r8:c09055e0 r7:00000010 r6:00000000 r5:00000000
>       r4:00000001
>      [<c01588b8>] (vprintk_default) from [<c018e538>] (printk+0x34/0x40)
>      [<c018e508>] (printk) from [<c010cfb8>] (__cpu_die+0x34/0x78)
>       r3:00000003 r2:c0906808 r1:00000001 r0:c0710af6
>      [<c010cf84>] (__cpu_die) from [<c011d7d0>] (_cpu_down+0x168/0x290)
>       r4:00000001 r3:00000005
>      [<c011d668>] (_cpu_down) from [<c011dd90>] (disable_nonboot_cpus+0x70/0xf0)
>       r10:00000051 r9:c0932734 r8:c0902528 r7:00000000 r6:c090245c r5:c0931b40
>       r4:00000001
>      [<c011dd20>] (disable_nonboot_cpus) from [<c0155fd8>]
> (suspend_devices_and_enter+0x290/0x3f8)
>       r8:c0714bb5 r7:eebac300 r6:00000003 r5:c0932734 r4:00000000 r3:00000000
>      [<c0155d48>] (suspend_devices_and_enter) from [<c01561f4>]
> (pm_suspend+0xb4/0x1c8)
>       r9:c093273c r8:c0714bb5 r7:eebac300 r6:00000003 r5:c09576fc r4:00000000
>      [<c0156140>] (pm_suspend) from [<c0155148>] (state_store+0xb0/0xc4)
>       r6:00000004 r5:00000003 r4:00000003 r3:0000006d
>      [<c0155098>] (state_store) from [<c02bbce8>] (kobj_attr_store+0x1c/0x28)
>       r9:000cdc08 r8:ee1d5f80 r7:eebacb0c r6:eebacb00 r5:eebac300 r4:eebac300
>      [<c02bbccc>] (kobj_attr_store) from [<c0222438>] (sysfs_kf_write+0x44/0x50)
>      [<c02223f4>] (sysfs_kf_write) from [<c0221ae0>]
> (kernfs_fop_write+0x13c/0x1a0)
>       r4:00000004 r3:c02223f4
>      [<c02219a4>] (kernfs_fop_write) from [<c01ca1b4>] (__vfs_write+0x34/0xdc)
>       r10:00000000 r9:ee1d4000 r8:c0106fa4 r7:00000004 r6:ee1d5f80 r5:c02219a4
>       r4:edf85d00
>      [<c01ca180>] (__vfs_write) from [<c01ca3dc>] (vfs_write+0xb8/0x140)
>       r7:ee1d5f80 r6:000cdc08 r5:edf85d00 r4:00000004
>      [<c01ca324>] (vfs_write) from [<c01ca544>] (SyS_write+0x50/0x90)
>       r9:ee1d4000 r8:c0106fa4 r7:000cdc08 r6:00000004 r5:edf85d00 r4:edf85d00
>      [<c01ca4f4>] (SyS_write) from [<c0106de0>] (ret_fast_syscall+0x0/0x3c)
>
> Before commit 1bb20571dcf0edfc ("ARM: 8470/1: mm: flip priority of
> CONFIG_DEBUG_RODATA"):
>
>      # CONFIG_ARM_KERNMEM_PERMS is not set
>
>      Freezing user space processes ... (elapsed 0.001 seconds) done.
>      Freezing remaining freezable tasks ... (elapsed 0.003 seconds) done.
>      PM: suspend of devices complete after 112.163 msecs
>      PM: late suspend of devices complete after 1.610 msecs
>      PM: noirq suspend of devices complete after 13.109 msecs
>      Disabling non-boot CPUs ...
>      CPU1: shutdown
>
> After the offending commit:
>
>      CONFIG_DEBUG_RODATA=y
>      CONFIG_DEBUG_ALIGN_RODATA=y
>
> The "problem" is that DEBUG_RODATA now defaults to y on CPU_V7, so it gets
> enabled for shmobile_defconfig. If I manually disable DEBUG_RODATA again,
> s2ram does work.
>
> The real problem is something else, though. I can trigger the same panic
> without the offending commit by enabling:
>
>      CONFIG_ARM_KERNMEM_PERMS=y
>      CONFIG_DEBUG_RODATA=y
>
> I never enabled those options before, so I have no idea if this is a recent
> regression. I've just tried a few older versions: on v4.4-rc1 I see the same
> panic, on v4.3 (and v4.3.3) I don't see the panic, and the "CPU1: shutdown"
> line, but the system doesn't wake up.
>
> Thanks for your suggestions!
>
> Gr{oetje,eeting}s,
>
>                          Geert
>

At a thought I think the RO/NX persmission are working as expected and
something in the suspend code is writing or executing from where it
shouldn't. I hit similar problems when working on RO/NX support for
arm64.

Looking in arch/arm/mach-shmobile/headsmp.S, it looks like
shmobile_boot_fn, shmobile_boot_arg, shmobile_smp_mpdir, shmobile_smp_fn,
and shmobile_smp_arg are ending up in the the text section which is going
to be read_only. Assuming I understand the code flow, it looks like those
are modified at suspend time which isn't going to work. I would say just
throw those objects in the .data section but I notice shmobile_boot_size
is there as well which seems to be calculated based off of the boot
vector so you might need to do some re-working there.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
