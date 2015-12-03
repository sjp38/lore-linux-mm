Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id EA85B6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 19:05:11 -0500 (EST)
Received: by qkfo3 with SMTP id o3so23710443qkf.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:05:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x202si4371980qka.101.2015.12.02.16.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 16:05:11 -0800 (PST)
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
References: <20151202202725.GA794@www.outflux.net>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <565F8732.5050402@redhat.com>
Date: Wed, 2 Dec 2015 16:05:06 -0800
MIME-Version: 1.0
In-Reply-To: <20151202202725.GA794@www.outflux.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nico@linaro.org>, Arnd Bergmann <arnd@arndb.de>, kernel-hardening@lists.openwall.com

On 12/02/2015 12:27 PM, Kees Cook wrote:
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
>
> Also adds human readable names to the sections so I could more easily
> debug my typos, and makes CONFIG_DEBUG_RODATA default "y" for CPU_V7.
>
> Results in /sys/kernel/debug/kernel_page_tables for each config state:
>
>   # CONFIG_DEBUG_RODATA is not set
>   # CONFIG_DEBUG_ALIGN_RODATA is not set
>
> ---[ Kernel Mapping ]---
> 0x80000000-0x80900000           9M     RW x  SHD
> 0x80900000-0xa0000000         503M     RW NX SHD
>
>   CONFIG_DEBUG_RODATA=y
>   CONFIG_DEBUG_ALIGN_RODATA=y
>
> ---[ Kernel Mapping ]---
> 0x80000000-0x80100000           1M     RW NX SHD
> 0x80100000-0x80700000           6M     ro x  SHD
> 0x80700000-0x80a00000           3M     ro NX SHD
> 0x80a00000-0xa0000000         502M     RW NX SHD
>
>   CONFIG_DEBUG_RODATA=y
>   # CONFIG_DEBUG_ALIGN_RODATA is not set
>
> ---[ Kernel Mapping ]---
> 0x80000000-0x80100000           1M     RW NX SHD
> 0x80100000-0x80a00000           9M     ro x  SHD
> 0x80a00000-0xa0000000         502M     RW NX SHD
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---

Reviewed-by: Laura Abbott <labbott@fedoraproject.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
