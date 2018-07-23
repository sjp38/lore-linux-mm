Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF766B0003
	for <linux-mm@kvack.org>; Sun, 22 Jul 2018 23:49:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id l8-v6so15361899ita.4
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 20:49:04 -0700 (PDT)
Received: from mtlfep02.bell.net (belmont80srvr.owm.bell.net. [184.150.200.80])
        by mx.google.com with ESMTPS id y19-v6si4747610ioj.12.2018.07.22.20.49.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Jul 2018 20:49:02 -0700 (PDT)
Received: from bell.net mtlfep02 184.150.200.30 by mtlfep02.bell.net
          with ESMTP
          id <20180723034901.IGYT26486.mtlfep02.bell.net@mtlspm01.bell.net>
          for <linux-mm@kvack.org>; Sun, 22 Jul 2018 23:49:01 -0400
Message-ID: <14206a19d597881b2490eb3fea47ee97be17ca93.camel@sympatico.ca>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
From: "David H. Gutteridge" <dhgutteridge@sympatico.ca>
Date: Sun, 22 Jul 2018 23:49:00 -0400
In-Reply-To: <1532103744-31902-1-git-send-email-joro@8bytes.org>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Fri, 2018-07-20 at 18:22 +0200, Joerg Roedel wrote:
> Hi,
> 
> here are 3 patches which update the PTI-x86-32 patches recently merged
> into the tip-tree. The patches are ordered by importance:
> 
> 	Patch 1: Very important, it fixes a vmalloc-fault in NMI context
> 		 when PTI is enabled. This is pretty unlikely to hit
> 		 when starting perf on an idle machine, which is why I
> 		 didn't find it earlier in my testing. I always started
> 		 'perf top' first :/ But when I start 'perf top' last
> 		 when the kernel-compile already runs, it hits almost
> 		 immediatly.
> 
> 	Patch 2: Fix the 'from-kernel-check' in SWITCH_TO_KERNEL_STACK
> 	         to also take VM86 into account. This is not strictly
> 		 necessary because the slow-path also works for VM86
> 		 mode but it is not how the code was intended to work.
> 		 And it breaks when Patch 3 is applied on-top.
> 
> 	Patch 3: Implement the reduced copying in the paranoid
> 		 entry/exit path as suggested by Andy Lutomirski while
> 		 reviewing version 7 of the original patches.
> 
> I have the x86/tip branch with these patches on-top running my test
> for
> 6h now, with no issues so far. So for now it looks like there are no
> scheduling points or irq-enabled sections reached from the paranoid
> entry/exit paths and we always return to the entry-stack we came from.
> 
> I keep the test running over the weekend at least.
> 
> Please review.
> 
> [ If Patch 1 looks good to the maintainers I suggest applying it soon,
>   before too many linux-next testers run into this issue. It is
> actually
>   the reason why I send out the patches _now_ and didn't wait until
> next
>   week when the other two patches got more testing from my side. ]
> 
> Thanks,
> 
> 	Joerg
> 
> Joerg Roedel (3):
>   perf/core: Make sure the ring-buffer is mapped in all page-tables
>   x86/entry/32: Check for VM86 mode in slow-path check
>   x86/entry/32: Copy only ptregs on paranoid entry/exit path
> 
>  arch/x86/entry/entry_32.S   | 82 ++++++++++++++++++++++++++--------
> -----------
>  kernel/events/ring_buffer.c | 10 ++++++
>  2 files changed, 58 insertions(+), 34 deletions(-)

Hi Joerg,

I tested again using the tip "x86/pti" branch (with two of the three
patches in your change set already applied), and manually applied
your third patch on top of it (I see there was some debate about it,
but I thought I'd include it), plus I had to manually apply the patch
to fix booting (d1b47a7c9efcf3c3384b70f6e3c8f1423b44d8c7: "mm: don't
do zero_resv_unavail if memmap is not allocated"), since "x86/pti"
doesn't include it yet.

Unfortunately, I can trigger a bug in KVM+QEMU with the Bochs VGA
driver. (This is the same VM definition I shared with you in a PM
back on Feb. 20th, except note that 4.18 kernels won't successfully
boot with QEMU's IDE device, so I'm using SATA instead. That's a
regression totally unrelated to your change sets, or to the general
booting issue with 4.18 RC5, since it occurs in vanilla RC4 as well.)

[drm] Found bochs VGA, ID 0xb0c0.
[drm] Framebuffer size 16384 kB @ 0xfd000000, mmio @ 0xfebd4000.
[TTM] Zone  kernel: Available graphics memory: 390536 kiB
[TTM] Zone highmem: Available graphics memory: 4659530 kiB
[TTM] Initializing pool allocator
[TTM] Initializing DMA pool allocator
------------[ cut here ]------------
kernel BUG at arch/x86/mm/fault.c:269!
invalid opcode: 0000 [#1] SMP PTI
CPU: 0 PID: 349 Comm: systemd-udevd Tainted: G        W         4.18.0-
rc4+ #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1
04/01/2014
EIP: vmalloc_fault+0x1d7/0x200
Code: 00 f0 1f 00 81 ea 00 00 20 00 21 d0 8b 55 e8 89 c6 81 e2 ff 0f 00
00 0f ac d6 0c 8d 04 b6 c1 e0 03 39 45 ec 0f 84 37 ff ff ff <0f> 0b 8d
b4 26 00 00 00 00 83 c4 0c b8 ff ff ff ff 5b 5e 5f 5d c3 
EAX: 02788000 EBX: c85b6de8 ECX: 00000080 EDX: 00000000
ESI: 000fd000 EDI: fd0000f3 EBP: f4743994 ESP: f474397c
DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010083
CR0: 80050033 CR2: f7a00000 CR3: 347f6000 CR4: 000006f0
Call Trace:
 __do_page_fault+0x340/0x4c0
 do_page_fault+0x25/0xf0
 ? ttm_mem_reg_ioremap+0xe5/0x100 [ttm]
 ? kvm_async_pf_task_wait+0x1b0/0x1b0
 do_async_page_fault+0x55/0x80
 common_exception+0x13f/0x146
EIP: memset+0xb/0x20
Code: f9 01 72 0b 8a 0e 88 0f 8d b4 26 00 00 00 00 8b 45 f0 83 c4 04 5b
5e 5f 5d c3 90 8d 74 26 00 55 89 e5 57 89 c7 53 89 c3 89 d0 <f3> aa 89
d8 5b 5f 5d c3 90 90 90 90 90 90 90 90 90 90 90 90 90 66 
EAX: 00000000 EBX: f7a00000 ECX: 00300000 EDX: 00000000
ESI: f4743b9c EDI: f7a00000 EBP: f4743a4c ESP: f4743a44
DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010206
 ttm_bo_move_memcpy+0x49a/0x4c0 [ttm]
 ? _cond_resched+0x17/0x40
 ttm_bo_handle_move_mem+0x554/0x570 [ttm]
 ? ttm_bo_mem_space+0x211/0x440 [ttm]
 ttm_bo_validate+0xf5/0x110 [ttm]
 bochs_bo_pin+0xde/0x1c0 [bochs_drm]
 bochsfb_create+0xce/0x310 [bochs_drm]
 __drm_fb_helper_initial_config_and_unlock+0x1cc/0x470 [drm_kms_helper]
 drm_fb_helper_initial_config+0x35/0x40 [drm_kms_helper]
 bochs_fbdev_init+0x74/0x80 [bochs_drm]
 bochs_load+0x7a/0x90 [bochs_drm]
 drm_dev_register+0x103/0x180 [drm]
 drm_get_pci_dev+0x80/0x160 [drm]
 bochs_pci_probe+0xcb/0x100 [bochs_drm]
 ? bochs_load+0x90/0x90 [bochs_drm]
 pci_device_probe+0xc7/0x160
 driver_probe_device+0x2dc/0x470
 __driver_attach+0xe1/0x110
 ? driver_probe_device+0x470/0x470
 bus_for_each_dev+0x5a/0x90
 driver_attach+0x19/0x20
 ? driver_probe_device+0x470/0x470
 bus_add_driver+0x12f/0x230
 ? pci_bus_num_vf+0x20/0x20
 driver_register+0x56/0xf0
 ? 0xf789c000
 __pci_register_driver+0x3d/0x40
 bochs_init+0x41/0x1000 [bochs_drm]
 do_one_initcall+0x42/0x1a9
 ? free_unref_page_commit+0x6f/0xe0
 ? _cond_resched+0x17/0x40
 ? kmem_cache_alloc_trace+0x3b/0x1f0
 ? do_init_module+0x21/0x1dc
 ? do_init_module+0x21/0x1dc
 do_init_module+0x50/0x1dc
 load_module+0x22ae/0x2940
 sys_finit_module+0x8a/0xe0
 do_fast_syscall_32+0x7f/0x1b0
 entry_SYSENTER_32+0x79/0xda
EIP: 0xb7eecd09
Code: 08 8b 80 64 cd ff ff 85 d2 74 02 89 02 5d c3 8b 04 24 c3 8b 0c 24
c3 8b 1c 24 c3 8b 3c 24 c3 90 90 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59
c3 90 90 90 90 8d 76 00 58 b8 77 00 00 00 cd 80 90 8d 76 
EAX: ffffffda EBX: 00000010 ECX: b7afee75 EDX: 00000000
ESI: 019a91e0 EDI: 0199a6d0 EBP: 0199a760 ESP: bfba3d8c
DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000246
Modules linked in: bochs_drm(+) drm_kms_helper ttm virtio_console drm
8139too virtio_pci serio_raw crc32c_intel virtio_ring 8139cp ata_generic
qemu_fw_cfg virtio mii floppy pata_acpi
---[ end trace 9fc4a94c280952eb ]---
EIP: vmalloc_fault+0x1d7/0x200
Code: 00 f0 1f 00 81 ea 00 00 20 00 21 d0 8b 55 e8 89 c6 81 e2 ff 0f 00
00 0f ac d6 0c 8d 04 b6 c1 e0 03 39 45 ec 0f 84 37 ff ff ff <0f> 0b 8d
b4 26 00 00 00 00 83 c4 0c b8 ff ff ff ff 5b 5e 5f 5d c3 
EAX: 02788000 EBX: c85b6de8 ECX: 00000080 EDX: 00000000
ESI: 000fd000 EDI: fd0000f3 EBP: f4743994 ESP: c85c1ddc
DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010083
CR0: 80050033 CR2: f7a00000 CR3: 347f6000 CR4: 000006f0

Regards,

Dave
