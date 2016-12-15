Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4356B0253
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 10:39:46 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so114630849pgc.2
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 07:39:46 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0074.outbound.protection.outlook.com. [104.47.32.74])
        by mx.google.com with ESMTPS id s8si2993139pfd.186.2016.12.15.07.39.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 07:39:45 -0800 (PST)
Date: Thu, 15 Dec 2016 16:39:30 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Message-ID: <20161215153930.GA8111@rric.localdomain>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, catalin.marinas@arm.com, akpm@linux-foundation.org, hanjun.guo@linaro.org, xieyisheng1@huawei.com, james.morse@arm.com

I was going to do some measurements but my kernel crashes now with a
page fault in efi_rtc_probe():

[   21.663393] Unable to handle kernel paging request at virtual address 20251000
[   21.663396] pgd = ffff000009090000
[   21.663401] [20251000] *pgd=0000010ffff90003
[   21.663402] , *pud=0000010ffff90003
[   21.663404] , *pmd=0000000fdc030003
[   21.663405] , *pte=00e8832000250707

The sparsemem config requires the whole section to be initialized.
Your patches do not address this.

On 14.12.16 09:11:47, Ard Biesheuvel wrote:
> +config HOLES_IN_ZONE
> +	def_bool y
> +	depends on NUMA

This enables pfn_valid_within() for arm64 and causes the check for
each page of a section. The arm64 implementation of pfn_valid() is
already expensive (traversing memblock areas). Now, this is increased
by a factor of 2^18 for 4k page size (16384 for 64k). We need to
initialize the whole section to avoid that.

-Robert






[   21.663393] Unable to handle kernel paging request at virtual address 20251000
[   21.663396] pgd = ffff000009090000
[   21.663401] [20251000] *pgd=0000010ffff90003
[   21.663402] , *pud=0000010ffff90003
[   21.663404] , *pmd=0000000fdc030003
[   21.663405] , *pte=00e8832000250707
[   21.663405] 
[   21.663411] Internal error: Oops: 96000047 [#1] SMP
[   21.663416] Modules linked in:
[   21.663425] CPU: 49 PID: 1 Comm: swapper/0 Tainted: G        W       4.9.0.0.vanilla10-00002-g429605e9ab0a #1
[   21.663426] Hardware name: www.cavium.com ThunderX CRB-2S/ThunderX CRB-2S, BIOS 0.3 Sep 13 2016
[   21.663429] task: ffff800feee6bc00 task.stack: ffff800fec050000
[   21.663433] PC is at 0x201ff820
[   21.663434] LR is at 0x201fdfc0
[   21.663435] pc : [<00000000201ff820>] lr : [<00000000201fdfc0>] pstate: 20000045
[   21.663437] sp : ffff800fec053b70
[   21.663440] x29: ffff800fec053bc0 x28: 0000000000000000 
[   21.663443] x27: ffff000008ce3e08 x26: ffff000008c52568 
[   21.663445] x25: ffff000008bf045c x24: ffff000008bdb828 
[   21.663448] x23: 0000000000000000 x22: 0000000000000040 
[   21.663451] x21: ffff800fec053bb8 x20: 0000000020251000 
[   21.663453] x19: ffff800fec053c20 x18: 0000000000000000 
[   21.663456] x17: 0000000000000000 x16: 00000000bbb67a65 
[   21.663459] x15: ffffffffffffffff x14: ffff810016ea291c 
[   21.663461] x13: ffff810016ea2181 x12: 0000000000000030 
[   21.663464] x11: 0101010101010101 x10: 7f7f7f7f7f7f7f7f 
[   21.663467] x9 : feff716475687163 x8 : ffffffffffffffff 
[   21.663469] x7 : 83f0680000000000 x6 : 0000000000000000 
[   21.663472] x5 : ffff800fc187aab9 x4 : 0002000000000000 
[   21.663474] x3 : ffff800fec053bb8 x2 : 0000000000000000 
[   21.663477] x1 : 83f0680000000000 x0 : 0000000020251000 
[   21.663478] 
[   21.663479] Process swapper/0 (pid: 1, stack limit = 0xffff800fec050020)
...
[   21.663605] [<00000000201ff820>] 0x201ff820
[   21.663617] [<ffff000008c3eef4>] efi_rtc_probe+0x24/0x78
[   21.663625] [<ffff000008586c88>] platform_drv_probe+0x60/0xc8
[   21.663636] [<ffff0000085845d4>] driver_probe_device+0x26c/0x420
[   21.663639] [<ffff0000085848ac>] __driver_attach+0x124/0x128
[   21.663642] [<ffff000008581e08>] bus_for_each_dev+0x70/0xb0
[   21.663644] [<ffff000008583c30>] driver_attach+0x30/0x40
[   21.663647] [<ffff000008583668>] bus_add_driver+0x200/0x2b8
[   21.663650] [<ffff000008585430>] driver_register+0x68/0x100
[   21.663652] [<ffff000008586e3c>] __platform_driver_probe+0x84/0x128
[   21.663654] [<ffff000008c3eec8>] efi_rtc_driver_init+0x20/0x28
[   21.663658] [<ffff000008082d94>] do_one_initcall+0x44/0x138
[   21.663665] [<ffff000008bf0d0c>] kernel_init_freeable+0x1ac/0x24c
[   21.663673] [<ffff00000885e7a0>] kernel_init+0x18/0x110
[   21.663675] [<ffff000008082b30>] ret_from_fork+0x10/0x20
[   21.663679] Code: f9400000 d5033d9f d65f03c0 d5033e9f (f9000001) 
[   21.663688] ---[ end trace e420ef9636e3c9b2 ]---
[   21.663711] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
[   21.663711] 
[   21.663713] SMP: stopping secondary CPUs
[   21.670234] Kernel Offset: disabled
[   21.670235] Memory Limit: none
[   22.681333] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
