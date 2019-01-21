Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0D4A8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 12:27:47 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id o6so2647148wmf.0
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 09:27:47 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id t5si22192370wmb.51.2019.01.21.09.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 09:27:46 -0800 (PST)
Date: Mon, 21 Jan 2019 18:27:43 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 20/25] ACPI / APEI: Use separate fixmap pages for
 arm64 NMI-like notifications
Message-ID: <20190121172743.GN29166@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-21-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-21-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:06:08PM +0000, James Morse wrote:
> Now that ghes notification helpers provide the fixmap slots and
> take the lock themselves, multiple NMI-like notifications can
> be used on arm64.
> 
> These should be named after their notification method as they can't
> all be called 'NMI'. x86's NOTIFY_NMI already is, change the SEA
> fixmap entry to be called FIX_APEI_GHES_SEA.
> 
> Future patches can add support for FIX_APEI_GHES_SEI and
> FIX_APEI_GHES_SDEI_{NORMAL,CRITICAL}.
> 
> Because all of ghes.c builds on both architectures, provide a
> constant for each fixmap entry that the architecture will never
> use.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> 
> ---
> Changes since v6:
>  * Added #ifdef definitions of each missing fixmap entry.
> 
> Changes since v3:
>  * idx/lock are now in a separate struct.
>  * Add to the comment above ghes_fixmap_lock_irq so that it makes more
>    sense in isolation.
> 
> fixup for split fixmap
> ---
>  arch/arm64/include/asm/fixmap.h |  2 +-
>  drivers/acpi/apei/ghes.c        | 10 +++++++++-
>  2 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/fixmap.h b/arch/arm64/include/asm/fixmap.h
> index ec1e6d6fa14c..966dd4bb23f2 100644
> --- a/arch/arm64/include/asm/fixmap.h
> +++ b/arch/arm64/include/asm/fixmap.h
> @@ -55,7 +55,7 @@ enum fixed_addresses {
>  #ifdef CONFIG_ACPI_APEI_GHES
>  	/* Used for GHES mapping from assorted contexts */
>  	FIX_APEI_GHES_IRQ,
> -	FIX_APEI_GHES_NMI,
> +	FIX_APEI_GHES_SEA,
>  #endif /* CONFIG_ACPI_APEI_GHES */
>  
>  #ifdef CONFIG_UNMAP_KERNEL_AT_EL0
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index 849da0d43a21..6cbf9471b2a2 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -85,6 +85,14 @@
>  	((struct acpi_hest_generic_status *)				\
>  	 ((struct ghes_estatus_node *)(estatus_node) + 1))
>  
> +/* NMI-like notifications vary by architecture. Fill in the fixmap gaps */
> +#ifndef CONFIG_HAVE_ACPI_APEI_NMI
> +#define FIX_APEI_GHES_NMI	-1
> +#endif
> +#ifndef CONFIG_ACPI_APEI_SEA
> +#define FIX_APEI_GHES_SEA	-1

I'm guessing those -1 are going to cause __set_fixmap() to fail, right?

I'm wondering if we could catch that situation in ghes_map() already to
protect ourselves against future changes in the fixmap code...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
