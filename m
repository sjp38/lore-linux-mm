Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C91E76B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 05:47:14 -0500 (EST)
Received: by wmww144 with SMTP id w144so17078923wmw.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 02:47:14 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id 77si2657661wme.95.2015.11.26.02.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 02:47:13 -0800 (PST)
Received: by wmec201 with SMTP id c201so17024467wme.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 02:47:13 -0800 (PST)
Date: Thu, 26 Nov 2015 10:47:11 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v3 13/13] ARM: add UEFI stub support
Message-ID: <20151126104711.GH2765@codeblueprint.co.uk>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
 <1448269593-20758-14-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448269593-20758-14-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com

On Mon, 23 Nov, at 10:06:33AM, Ard Biesheuvel wrote:
> From: Roy Franz <roy.franz@linaro.org>
> 
> This patch adds EFI stub support for the ARM Linux kernel.
> 
> The EFI stub operates similarly to the x86 and arm64 stubs: it is a
> shim between the EFI firmware and the normal zImage entry point, and
> sets up the environment that the zImage is expecting. This includes
> optionally loading the initrd and device tree from the system partition
> based on the kernel command line.
> 
> Signed-off-by: Roy Franz <roy.franz@linaro.org>
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  arch/arm/Kconfig                          |  19 +++
>  arch/arm/boot/compressed/Makefile         |   4 +-
>  arch/arm/boot/compressed/efi-header.S     | 130 ++++++++++++++++++++
>  arch/arm/boot/compressed/head.S           |  54 +++++++-
>  arch/arm/boot/compressed/vmlinux.lds.S    |   7 ++
>  arch/arm/include/asm/efi.h                |  23 ++++
>  drivers/firmware/efi/libstub/Makefile     |   9 ++
>  drivers/firmware/efi/libstub/arm-stub.c   |   4 +-
>  drivers/firmware/efi/libstub/arm32-stub.c |  85 +++++++++++++
>  9 files changed, 331 insertions(+), 4 deletions(-)

[...]

> +
> +	/*
> +	 * Relocate the zImage, if required. ARM doesn't have a
> +	 * preferred address, so we set it to 0, as we want to allocate
> +	 * as low in memory as possible.
> +	 */
> +	*image_size = image->image_size;
> +	status = efi_relocate_kernel(sys_table, image_addr, *image_size,
> +				     *image_size, 0, 0);
> +	if (status != EFI_SUCCESS) {
> +		pr_efi_err(sys_table, "Failed to relocate kernel.\n");
> +		efi_free(sys_table, *reserve_size, *reserve_addr);
> +		*reserve_size = 0;
> +		return status;
> +	}

If efi_relocate_kernel() successfully allocates memory at address 0x0,
is that going to cause issues with NULL pointer checking?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
