Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5576B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 07:05:18 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so346558768pfv.5
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 04:05:18 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u17si68920519pgo.250.2016.12.01.04.05.17
        for <linux-mm@kvack.org>;
        Thu, 01 Dec 2016 04:05:17 -0800 (PST)
Message-ID: <584011CB.3050505@arm.com>
Date: Thu, 01 Dec 2016 12:04:27 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 05/10] arm64: Use __pa_symbol for kernel symbols
References: <1480445729-27130-1-git-send-email-labbott@redhat.com> <1480445729-27130-6-git-send-email-labbott@redhat.com>
In-Reply-To: <1480445729-27130-6-git-send-email-labbott@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

Hi Laura,

On 29/11/16 18:55, Laura Abbott wrote:
> __pa_symbol is technically the marco that should be used for kernel

macro

> symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
> will do bounds checking. As part of this, introduce lm_alias, a
> macro which wraps the __va(__pa(...)) idiom used a few places to
> get the alias.

> diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
> index d55a7b0..4f0c77d 100644
> --- a/arch/arm64/kernel/hibernate.c
> +++ b/arch/arm64/kernel/hibernate.c
> @@ -484,7 +481,7 @@ int swsusp_arch_resume(void)
>  	 * Since we only copied the linear map, we need to find restore_pblist's
>  	 * linear map address.
>  	 */
> -	lm_restore_pblist = LMADDR(restore_pblist);
> +	lm_restore_pblist = lm_alias(restore_pblist);
>  
>  	/*
>  	 * We need a zero page that is zero before & after resume in order to

This change causes resume from hibernate to panic in:
> VIRTUAL_BUG_ON(x < (unsigned long) KERNEL_START ||
> 		x > (unsigned long) KERNEL_END);

It looks like kaslr's relocation code has already fixed restore_pblist, so your
debug virtual check catches this doing the wrong thing. My bug.

readelf -s vmlinux | grep ...
> 103495: ffff000008080000     0 NOTYPE  GLOBAL DEFAULT    1 _text
>  92104: ffff000008e43860     8 OBJECT  GLOBAL DEFAULT   24 restore_pblist
> 105442: ffff000008e85000     0 NOTYPE  GLOBAL DEFAULT   24 _end

But restore_pblist == 0xffff800971b7f998 when passed to __phys_addr_symbol().

This fixes the problem:
----------------%<----------------
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
index 4f0c77d2ff7a..8bed26a2d558 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -457,7 +457,6 @@ int swsusp_arch_resume(void)
        void *zero_page;
        size_t exit_size;
        pgd_t *tmp_pg_dir;
-       void *lm_restore_pblist;
        phys_addr_t phys_hibernate_exit;
        void __noreturn (*hibernate_exit)(phys_addr_t, phys_addr_t, void *,
                                          void *, phys_addr_t, phys_addr_t);
@@ -478,12 +477,6 @@ int swsusp_arch_resume(void)
                goto out;

        /*
-        * Since we only copied the linear map, we need to find restore_pblist's
-        * linear map address.
-        */
-       lm_restore_pblist = lm_alias(restore_pblist);
-
-       /*
         * We need a zero page that is zero before & after resume in order to
         * to break before make on the ttbr1 page tables.
         */
@@ -534,7 +527,7 @@ int swsusp_arch_resume(void)
        }

        hibernate_exit(virt_to_phys(tmp_pg_dir), resume_hdr.ttbr1_el1,
-                      resume_hdr.reenter_kernel, lm_restore_pblist,
+                      resume_hdr.reenter_kernel, restore_pblist,
                       resume_hdr.__hyp_stub_vectors, virt_to_phys(zero_page));

 out:
----------------%<----------------

I can post it as a separate fixes patch if you prefer.

I also tested kexec. FWIW:
Tested-by: James Morse <james.morse@arm.com>


Thanks,

James

[0] Trace
[    4.191607] Freezing user space processes ... (elapsed 0.000 seconds) done.
[    4.224251] random: fast init done
[    4.243825] PM: Using 3 thread(s) for decompression.
[    4.243825] PM: Loading and decompressing image data (90831 pages)...
[    4.255257] hibernate: Hibernated on CPU 0 [mpidr:0x100]
[    5.213469] PM: Image loading progress:   0%
[    5.579886] PM: Image loading progress:  10%
[    5.740234] ata2: SATA link down (SStatus 0 SControl 0)
[    5.760435] PM: Image loading progress:  20%
[    5.970647] PM: Image loading progress:  30%
[    6.563108] PM: Image loading progress:  40%
[    6.848389] PM: Image loading progress:  50%
[    7.526272] PM: Image loading progress:  60%
[    7.702727] PM: Image loading progress:  70%
[    7.899754] PM: Image loading progress:  80%
[    8.100703] PM: Image loading progress:  90%
[    8.300978] PM: Image loading progress: 100%
[    8.305441] PM: Image loading done.
[    8.308975] PM: Read 363324 kbytes in 4.05 seconds (89.70 MB/s)
[    8.344299] PM: quiesce of devices complete after 22.706 msecs
[    8.350762] PM: late quiesce of devices complete after 0.596 msecs
[    8.381334] PM: noirq quiesce of devices complete after 24.365 msecs
[    8.387729] Disabling non-boot CPUs ...
[    8.412500] CPU1: shutdown
[    8.415211] psci: CPU1 killed.
[    8.460465] CPU2: shutdown
[    8.463175] psci: CPU2 killed.
[    8.504447] CPU3: shutdown
[    8.507156] psci: CPU3 killed.
[    8.540375] CPU4: shutdown
[    8.543084] psci: CPU4 killed.
[    8.580333] CPU5: shutdown
[    8.583043] psci: CPU5 killed.
[    8.601206] ------------[ cut here ]------------
[    8.601206] kernel BUG at ../arch/arm64/mm/physaddr.c:25!
[    8.601206] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[    8.601206] Modules linked in:
[    8.601206] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.9.0-rc7-00010-g27c672
[    8.601206] Hardware name: ARM Juno development board (r1) (DT)
[    8.601206] task: ffff800976ca8000 task.stack: ffff800976c3c000
[    8.601206] PC is at __phys_addr_symbol+0x30/0x34
[    8.601206] LR is at swsusp_arch_resume+0x304/0x588
[    8.601206] pc : [<ffff0000080992d8>] lr : [<ffff0000080938b4>] pstate: 20005
[    8.601206] sp : ffff800976c3fca0
[    8.601206] x29: ffff800976c3fca0 x28: ffff000008bee000
[    8.601206] x27: 000000000e5ea000 x26: ffff000008e83000
[    8.601206] x25: 0000000000000801 x24: 0000000040000000
[    8.601206] x23: 0000000000000000 x22: 000000000e00d000
[    8.601206] x21: ffff808000000000 x20: ffff800080000000
[    8.601206] x19: 0000000000000000 x18: 4000000000000000
[    8.601206] x17: 0000000000000000 x16: 0000000000000694
[    8.601206] x15: ffff000008bee000 x14: 0000000000000008
[    8.601206] x13: 0000000000000000 x12: 003d090000000000
[    8.601206] x11: 0000000000000001 x10: fffffffff1a0f000
[    8.601206] x9 : 0000000000000001 x8 : ffff800971a0aff8
[    8.601206] x7 : 0000000000000001 x6 : 000000000000003f
[    8.601206] x5 : 0000000000000040 x4 : 0000000000000000
[    8.601206] x3 : ffff807fffffffff x2 : 0000000000000000
[    8.601206] x1 : ffff000008e85000 x0 : ffff80097152b578
[    8.601206]
[    8.601206] Process swapper/0 (pid: 1, stack limit = 0xffff800976c3c020)
[    8.601206] Stack: (0xffff800976c3fca0 to 0xffff800976c40000)

[    8.601206] Call trace:
[    8.601206] Exception stack(0xffff800976c3fad0 to 0xffff800976c3fc00)

[    8.601206] [<ffff0000080992d8>] __phys_addr_symbol+0x30/0x34
[    8.601206] [<ffff0000080fe340>] hibernation_restore+0xf8/0x130
[    8.601206] [<ffff0000080fe3e4>] load_image_and_restore+0x6c/0x70
[    8.601206] [<ffff0000080fe640>] software_resume+0x258/0x288
[    8.601206] [<ffff0000080830b8>] do_one_initcall+0x38/0x128
[    8.601206] [<ffff000008c60cf4>] kernel_init_freeable+0x1ac/0x250
[    8.601206] [<ffff0000088acd10>] kernel_init+0x10/0x100
[    8.601206] [<ffff000008082e80>] ret_from_fork+0x10/0x50
[    8.601206] Code: b0005aa1 f9475c21 cb010000 d65f03c0 (d4210000)
[    8.601206] ---[ end trace e15be9f4f989f0b5 ]---
[    8.601206] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0b
[    8.601206]
[    8.601206] Kernel Offset: disabled
[    8.601206] Memory Limit: none
[    8.601206] ---[ end Kernel panic - not syncing: Attempted to kill init! exib
[    8.601206]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
