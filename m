Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5166B0003
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 16:18:41 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id f4so74567plo.11
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 13:18:41 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id n3-v6si5979494plp.487.2018.02.20.13.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 13:18:39 -0800 (PST)
Subject: Re: [PATCH 06/11] ACPI / APEI: Make the fixmap_idx per-ghes to allow
 multiple in_nmi() users
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-7-james.morse@arm.com>
From: Tyler Baicar <tbaicar@codeaurora.org>
Message-ID: <879ab426-c6a9-b881-e3d5-a605cfad5f97@codeaurora.org>
Date: Tue, 20 Feb 2018 16:18:35 -0500
MIME-Version: 1.0
In-Reply-To: <20180215185606.26736-7-james.morse@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>

Hey James,


On 2/15/2018 1:56 PM, James Morse wrote:
> Arm64 has multiple NMI-like notifications, but GHES only has one
> in_nmi() path. The interactions between these multiple NMI-like
> notifications is, unclear.
>
> Split this single path up by moving the fixmap idx and lock into
> the struct ghes. Each notification's init function can consider
> which other notifications it masks and can share a fixmap_idx with.
> This lets us merge the two ghes_ioremap_pfn_* flavours.
>
> Two lock pointers are provided, but only one will be used by
> ghes_copy_tofrom_phys(), depending on in_nmi(). This means any
> notification that might arrive as an NMI must always be wrapped in
> nmi_enter()/nmi_exit().
>
> The double-underscore version of fix_to_virt() is used because
> the index to be mapped can't be tested against the end of the
> enum at compile time.
>
> Signed-off-by: James Morse <james.morse@arm.com>
> ---

> @@ -303,13 +278,11 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
>   
>   	while (len > 0) {
>   		offset = paddr - (paddr & PAGE_MASK);
> -		if (in_nmi) {
> -			raw_spin_lock(&ghes_ioremap_lock_nmi);
> -			vaddr = ghes_ioremap_pfn_nmi(paddr >> PAGE_SHIFT);
> -		} else {
> -			spin_lock_irqsave(&ghes_ioremap_lock_irq, flags);
> -			vaddr = ghes_ioremap_pfn_irq(paddr >> PAGE_SHIFT);
> -		}
> +		if (in_nmi)
> +			raw_spin_lock(ghes->nmi_fixmap_lock);
> +		else
> +			spin_lock_irqsave(ghes->fixmap_lock, flags);
This locking is resulting in a NULL pointer dereference for me during boot time. 
I removed the ghes_proc() call
from ghes_probe() and then when triggering errors and going through ghes_proc() 
the NULL pointer dereference
no longer happens. That makes me think that this is dependent on something that 
is not setup before
ghes_probe() is happening. Any ideas?

[A A  10.747323] Unable to handle kernel NULL pointer dereference at virtual 
address 00000000
[A A  10.755121] Mem abort info:
[A A  10.757898]A A  ESR = 0x96000005
[A A  10.760937]A A  Exception class = DABT (current EL), IL = 32 bits
[A A  10.766839]A A  SET = 0, FnV = 0
[A A  10.769877]A A  EA = 0, S1PTW = 0
[A A  10.773002] Data abort info:
[A A  10.775867]A A  ISV = 0, ISS = 0x00000005
[A A  10.779686]A A  CM = 0, WnR = 0
[A A  10.782638] [0000000000000000] user address but active_mm is swapper
[A A  10.788976] Internal error: Oops: 96000005 [#1] SMP
[A A  10.793839] CPU: 8 PID: 1 Comm: swapper/0 Not tainted 4.16.0-rc2 #37
[A A  10.800173] Hardware name: Qualcomm Qualcomm Centriq(TM) 2400 Development 
Platform
[A A  10.813975] pstate: 60400085 (nZCv daIf +PAN -UAO)
[A A  10.818756] pc : _raw_spin_lock_irqsave+0x24/0x60
[A A  10.823441] lr : ghes_copy_tofrom_phys+0x170/0x178
[A A  10.828211] sp : ffff8017c6b03aa0
[A A  10.831509] x29: ffff8017c6b03aa0 x28: 0000000000010000
[A A  10.836804] x27: ffff000009a14cb8 x26: 0000000000000001
[A A  10.842099] x25: 0000000000000000 x24: 0000000000001000
[A A  10.847395] x23: ffff8017cab91000 x22: ffff80178be70c80
[A A  10.852690] x21: 0000000000811000 x20: 0000000000000014
[A A  10.857985] x19: 0000000000000000 x18: ffffffffffffffff
[A A  10.863280] x17: 0000000000000005 x16: 0000000000000000
[A A  10.868575] x15: ffff000009a85b08 x14: ffff8017cab8f91c
[A A  10.873870] x13: ffff8017cab8f18a x12: 0000000000000030
[A A  10.879165] x11: 0101010101010101 x10: ffff8017effb19d8
[A A  10.884461] x9 : 0000000000000000 x8 : ffff80178be33800
[A A  10.889756] x7 : 0000000000000040 x6 : 0000000000000040
[A A  10.895051] x5 : 0000000000810008 x4 : 0000000000000001
[A A  10.900346] x3 : 0000000000000014 x2 : 0000000000811000
[A A  10.905641] x1 : ffff8017cab91000 x0 : 0000000000000000
[A A  10.910937] Process swapper/0 (pid: 1, stack limit = 0x00000000ab1500d0)
[A A  10.917621] Call trace:
[A A  10.920052]A  _raw_spin_lock_irqsave+0x24/0x60
[A A  10.924392]A  ghes_copy_tofrom_phys+0x170/0x178
[A A  10.928819]A  ghes_read_estatus+0xa4/0x188
[A A  10.932813]A  ghes_proc+0x3c/0x190
[A A  10.936111]A  ghes_probe+0x294/0x4c8
[A A  10.939585]A  platform_drv_probe+0x60/0xc8
[A A  10.943576]A  driver_probe_device+0x22c/0x310
[A A  10.947829]A  __driver_attach+0xbc/0xc0
[A A  10.951564]A  bus_for_each_dev+0x78/0xe0
[A A  10.955381]A  driver_attach+0x30/0x40
[A A  10.958941]A  bus_add_driver+0x110/0x228
[A A  10.962760]A  driver_register+0x68/0x100
[A A  10.966579]A  __platform_driver_register+0x54/0x60
[A A  10.971269]A  ghes_init+0xbc/0x158
[A A  10.974566]A  do_one_initcall+0xa8/0x14c
[A A  10.978385]A  kernel_init_freeable+0x190/0x230
[A A  10.982725]A  kernel_init+0x18/0x110
[A A  10.986199]A  ret_from_fork+0x10/0x1c
[A A  10.989757] Code: d503201f d53b4220 d50342df f9800271 (885ffe61)
[A A  10.995856] ---[ end trace 6546810a8d401c9a ]---
[A A  11.000463] Kernel panic - not syncing: Attempted to kill init! 
exitcode=0x0000000b

Thanks,
Tyler

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
