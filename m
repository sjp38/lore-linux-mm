Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5686B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 06:02:15 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id y14-v6so7197993wmd.1
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 03:02:15 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id q2-v6si794707wmf.180.2018.10.12.03.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 03:02:13 -0700 (PDT)
Date: Fri, 12 Oct 2018 12:02:12 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 07/18] arm64: KVM/mm: Move SEA handling behind a
 single 'claim' interface
Message-ID: <20181012100212.GA580@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-8-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-8-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Sep 21, 2018 at 11:16:54PM +0100, James Morse wrote:
> To split up APEIs in_nmi() path, we need the nmi-like callers to always
> be in_nmi(). Add a helper to do the work and claim the notification.
> 
> When KVM or the arch code takes an exception that might be a RAS
> notification, it asks the APEI firmware-first code whether it wants
> to claim the exception. We can then go on to see if (a future)
> kernel-first mechanism wants to claim the notification, before
> falling through to the existing default behaviour.
> 
> The NOTIFY_SEA code was merged before we had multiple, possibly
> interacting, NMI-like notifications and the need to consider kernel
> first in the future. Make the 'claiming' behaviour explicit.
> 
> As we're restructuring the APEI code to allow multiple NMI-like
> notifications, any notification that might interrupt interrupts-masked
> code must always be wrapped in nmi_enter()/nmi_exit(). This allows APEI
> to use in_nmi() to use the right fixmap entries.
> 
> We mask SError over this window to prevent an asynchronous RAS error
> arriving and tripping 'nmi_enter()'s BUG_ON(in_nmi()).
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Acked-by: Marc Zyngier <marc.zyngier@arm.com>
> Tested-by: Tyler Baicar <tbaicar@codeaurora.org>

...

> diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
> index ed46dc188b22..a9b8bba014b5 100644
> --- a/arch/arm64/kernel/acpi.c
> +++ b/arch/arm64/kernel/acpi.c
> @@ -28,8 +28,10 @@
>  #include <linux/smp.h>
>  #include <linux/serial_core.h>
>  
> +#include <acpi/ghes.h>
>  #include <asm/cputype.h>
>  #include <asm/cpu_ops.h>
> +#include <asm/daifflags.h>
>  #include <asm/pgtable.h>
>  #include <asm/smp_plat.h>
>  
> @@ -257,3 +259,30 @@ pgprot_t __acpi_get_mem_attribute(phys_addr_t addr)
>  		return __pgprot(PROT_NORMAL_NC);
>  	return __pgprot(PROT_DEVICE_nGnRnE);
>  }
> +
> +/*
> + * Claim Synchronous External Aborts as a firmware first notification.
> + *
> + * Used by KVM and the arch do_sea handler.
> + * @regs may be NULL when called from process context.
> + */
> +int apei_claim_sea(struct pt_regs *regs)
> +{
> +	int err = -ENOENT;
> +	unsigned long current_flags = arch_local_save_flags();
> +
> +	if (!IS_ENABLED(CONFIG_ACPI_APEI_SEA))
> +		return err;

I don't know what side effects arch_local_save_flags() has on ARM but if
we return here, it looks to me like useless work.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
