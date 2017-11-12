Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 157B46B02D2
	for <linux-mm@kvack.org>; Sun, 12 Nov 2017 12:55:38 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 72so2961581oik.6
        for <linux-mm@kvack.org>; Sun, 12 Nov 2017 09:55:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 22si7046565otu.450.2017.11.12.09.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Nov 2017 09:55:36 -0800 (PST)
Date: Sun, 12 Nov 2017 12:55:32 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] arm64: mm: Set MAX_PHYSMEM_BITS based on ARM64_VA_BITS
Message-ID: <20171112175532.GA11262@redhat.com>
References: <1510268339-21989-1-git-send-email-vdumpa@nvidia.com>
 <9ff1d720-7137-4a9a-7934-1d01ea2ef208@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9ff1d720-7137-4a9a-7934-1d01ea2ef208@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Krishna Reddy <vdumpa@nvidia.com>, catalin.marinas@arm.com, will.deacon@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-tegra@vger.kernel.org

On Fri, Nov 10, 2017 at 03:11:15PM +0000, Robin Murphy wrote:
> On 09/11/17 22:58, Krishna Reddy wrote:
> > MAX_PHYSMEM_BITS greater than ARM64_VA_BITS is causing memory
> > access fault, when HMM_DMIRROR test is enabled.
> > In the failing case, ARM64_VA_BITS=39 and MAX_PHYSMEM_BITS=48.
> > HMM_DMIRROR test selects phys memory range from end based on
> > MAX_PHYSMEM_BITS and gets mapped into VA space linearly.
> > As VA space is 39-bit and phys space is 48-bit, this has caused
> > incorrect mapping and leads to memory access fault.
> > 
> > Limiting the MAX_PHYSMEM_BITS to ARM64_VA_BITS fixes the issue and is
> > the right thing instead of hard coding it as 48-bit always.
> > 
> > [    3.378655] Unable to handle kernel paging request at virtual address 3befd000000
> > [    3.378662] pgd = ffffff800a04b000
> > [    3.378900] [3befd000000] *pgd=0000000081fa3003, *pud=0000000081fa3003, *pmd=0060000268200711
> > [    3.378933] Internal error: Oops: 96000044 [#1] PREEMPT SMP
> > [    3.378938] Modules linked in:
> > [    3.378948] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.9.52-tegra-g91402fdc013b-dirty #51
> > [    3.378950] Hardware name: quill (DT)
> > [    3.378954] task: ffffffc1ebac0000 task.stack: ffffffc1eba64000
> > [    3.378967] PC is at __memset+0x1ac/0x1d0
> > [    3.378976] LR is at sparse_add_one_section+0xf8/0x174
> > [    3.378981] pc : [<ffffff80084c212c>] lr : [<ffffff8008eda17c>] pstate: 404000c5
> > [    3.378983] sp : ffffffc1eba67a40
> > [    3.378993] x29: ffffffc1eba67a40 x28: 0000000000000000
> > [    3.378999] x27: 000000000003ffff x26: 0000000000000040
> > [    3.379005] x25: 00000000000003ff x24: ffffffc1e9f6cf80
> > [    3.379010] x23: ffffff8009ecb2d4 x22: 000003befd000000
> > [    3.379015] x21: ffffffc1e9923ff0 x20: 000000000003ffff
> > [    3.379020] x19: 00000000ffffffef x18: ffffffffffffffff
> > [    3.379025] x17: 00000000000024d7 x16: 0000000000000000
> > [    3.379030] x15: ffffff8009cd8690 x14: ffffffc1e9f6c70c
> > [    3.379035] x13: ffffffc1e9f6c70b x12: 0000000000000030
> > [    3.379039] x11: 0000000000000040 x10: 0101010101010101
> > [    3.379044] x9 : 0000000000000000 x8 : 000003befd000000
> > [    3.379049] x7 : 0000000000000000 x6 : 000000000000003f
> > [    3.379053] x5 : 0000000000000040 x4 : 0000000000000000
> > [    3.379058] x3 : 0000000000000004 x2 : 0000000000ffffc0
> > [    3.379063] x1 : 0000000000000000 x0 : 000003befd000000
> > [    3.379064]
> > [    3.379069] Process swapper/0 (pid: 1, stack limit = 0xffffffc1eba64028)
> > [    3.379071] Call trace:
> > [    3.379079] [<ffffff80084c212c>] __memset+0x1ac/0x1d0
> 
> What's the deal with this memset? AFAICS we're in __add_pages() from
> hmm_devmem_pages_create() calling add_pages() for private memory which it
> does not expect to be in the linear map anyway :/
> 
> There appears to be a more fundamental problem being papered over here.
> 
> Robin.

Yes i think the dummy driver is use badly, if you want to test CDM memory
with dummy driver you need to steal regular memory to act as CDM memory.
You can take a look at following 2 patches:

https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-cdm-next&id=fcc1e94027dbee9525f75b2a9ad88b2e6279558a
https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-cdm-next&id=84204c5be742186236b371ea2f7ad39bf1770fe6

Note that this is only if your device have its own memory that is not
reported as regular ram to kernel resource and if that memory is
accessible by CPU in cache coherent way.

For tegra platform i don't think you have any such memory. Thus you
do not need to register any memory to use HMM. But we can talk about
your platform in private mail under NDA if it is not the case.

Note that no matter what i still think it make sense to properly define
MAX_PHYSMEM_BITS like on x86 or powerpc.

> 
> > [    3.379085] [<ffffff8008ed5100>] __add_pages+0x130/0x2e0
> > [    3.379093] [<ffffff8008211cf4>] hmm_devmem_pages_create+0x20c/0x310
> > [    3.379100] [<ffffff8008211fcc>] hmm_devmem_add+0x1d4/0x270
> > [    3.379128] [<ffffff80087111c8>] dmirror_probe+0x50/0x158
> > [    3.379137] [<ffffff8008732590>] platform_drv_probe+0x60/0xc8
> > [    3.379143] [<ffffff800872fbf4>] driver_probe_device+0x26c/0x420
> > [    3.379149] [<ffffff800872fecc>] __driver_attach+0x124/0x128
> > [    3.379155] [<ffffff800872d388>] bus_for_each_dev+0x88/0xe8
> > [    3.379166] [<ffffff800872f248>] driver_attach+0x30/0x40
> > [    3.379171] [<ffffff800872ec18>] bus_add_driver+0x1f8/0x2b0
> > [    3.379177] [<ffffff8008730e38>] driver_register+0x68/0x100
> > [    3.379183] [<ffffff80087324d4>] __platform_driver_register+0x5c/0x68
> > [    3.379192] [<ffffff800951f918>] hmm_dmirror_init+0x88/0xc4
> > [    3.379200] [<ffffff800808359c>] do_one_initcall+0x5c/0x170
> > [    3.379208] [<ffffff80094e0dd0>] kernel_init_freeable+0x1b8/0x258
> > [    3.379231] [<ffffff8008ed44f0>] kernel_init+0x18/0x108
> > [    3.379236] [<ffffff80080832d0>] ret_from_fork+0x10/0x40
> > [    3.379246] ---[ end trace 578db63bb139b8b8 ]---
> > 
> > Signed-off-by: Krishna Reddy <vdumpa@nvidia.com>
> > ---
> >   arch/arm64/include/asm/sparsemem.h | 6 ++++++
> >   1 file changed, 6 insertions(+)
> > 
> > diff --git a/arch/arm64/include/asm/sparsemem.h b/arch/arm64/include/asm/sparsemem.h
> > index 74a9d301819f..19ecd0b0f3a3 100644
> > --- a/arch/arm64/include/asm/sparsemem.h
> > +++ b/arch/arm64/include/asm/sparsemem.h
> > @@ -17,7 +17,13 @@
> >   #define __ASM_SPARSEMEM_H
> >   #ifdef CONFIG_SPARSEMEM
> > +
> > +#ifdef CONFIG_ARM64_VA_BITS
> > +#define MAX_PHYSMEM_BITS	CONFIG_ARM64_VA_BITS
> > +#else
> >   #define MAX_PHYSMEM_BITS	48
> > +#endif
> > +
> >   #define SECTION_SIZE_BITS	30
> >   #endif
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
