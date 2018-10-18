Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85C996B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:47:11 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id y22so21940381oty.3
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 03:47:11 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0063.outbound.protection.outlook.com. [104.47.1.63])
        by mx.google.com with ESMTPS id u19si10161591ota.0.2018.10.18.03.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 03:47:10 -0700 (PDT)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V2 2/4] arm64: mm: Introduce DEFAULT_MAP_WINDOW
Date: Thu, 18 Oct 2018 10:47:06 +0000
Message-ID: <20181018104644.k5uhtf2dwc3mr2xr@capper-debian.cambridge.arm.com>
References: <20181017163459.20175-1-steve.capper@arm.com>
 <20181017163459.20175-3-steve.capper@arm.com>
In-Reply-To: <20181017163459.20175-3-steve.capper@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <ECE138087D0C534692B36B4261C175E3@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "jcm@redhat.com" <jcm@redhat.com>, nd <nd@arm.com>

On Wed, Oct 17, 2018 at 05:34:57PM +0100, Steve Capper wrote:
> We wish to introduce a 52-bit virtual address space for userspace but
> maintain compatibility with software that assumes the maximum VA space
> size is 48 bit.
>=20
> In order to achieve this, on 52-bit VA systems, we make mmap behave as
> if it were running on a 48-bit VA system (unless userspace explicitly
> requests a VA where addr[51:48] !=3D 0).
>=20
> On a system running a 52-bit userspace we need TASK_SIZE to represent
> the 52-bit limit as it is used in various places to distinguish between
> kernelspace and userspace addresses.
>=20
> Thus we need a new limit for mmap, stack, ELF loader and EFI (which uses
> TTBR0) to represent the non-extended VA space.
>=20
> This patch introduces DEFAULT_MAP_WINDOW and DEFAULT_MAP_WINDOW_64 and
> switches the appropriate logic to use that instead of TASK_SIZE.
>=20
> Signed-off-by: Steve Capper <steve.capper@arm.com>

Whilst testing this series I inadvertantly dropped CONFIG_COMPAT which
has led to some kbuild errors with defconfig.

I will make the following changes to this patch.

[...]
> diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/=
processor.h
> index 79657ad91397..46c9d9ff028c 100644
> --- a/arch/arm64/include/asm/processor.h
> +++ b/arch/arm64/include/asm/processor.h
> @@ -26,6 +26,8 @@
> =20
>  #ifndef __ASSEMBLY__
> =20
> +#define DEFAULT_MAP_WINDOW_64	(UL(1) << VA_BITS)
> +
>  /*
>   * Default implementation of macro that returns current
>   * instruction pointer ("program counter").
> @@ -58,13 +60,16 @@
>  				TASK_SIZE_32 : TASK_SIZE_64)
>  #define TASK_SIZE_OF(tsk)	(test_tsk_thread_flag(tsk, TIF_32BIT) ? \
>  				TASK_SIZE_32 : TASK_SIZE_64)
> +#define DEFAULT_MAP_WINDOW	(test_tsk_thread_flag(tsk, TIF_32BIT) ? \
> +				TASK_SIZE_32 : DEFAULT_MAP_WINDOW_64)

Instead of test_tsk_thread_flag I will use test_thread_flag for
DEFAULT_MAP_WINDOW.

>  #else
>  #define TASK_SIZE		TASK_SIZE_64
> +#define DEFAULT_MAP_WINDOW	DEFAULT_MAP_WINDOW_64
>  #endif /* CONFIG_COMPAT */
> =20
> -#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 4))
> +#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(DEFAULT_MAP_WINDOW / 4))
> +#define STACK_TOP_MAX		DEFAULT_MAP_WINDOW_64
> =20
> -#define STACK_TOP_MAX		TASK_SIZE_64
>  #ifdef CONFIG_COMPAT
>  #define AARCH32_VECTORS_BASE	0xffff0000
>  #define STACK_TOP		(test_thread_flag(TIF_32BIT) ? \
> diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/ar=
m-runtime.c
> index 922cfb813109..952cec5b611a 100644
> --- a/drivers/firmware/efi/arm-runtime.c
> +++ b/drivers/firmware/efi/arm-runtime.c
> @@ -38,7 +38,7 @@ static struct ptdump_info efi_ptdump_info =3D {
>  	.mm		=3D &efi_mm,
>  	.markers	=3D (struct addr_marker[]){
>  		{ 0,		"UEFI runtime start" },
> -		{ TASK_SIZE_64,	"UEFI runtime end" }
> +		{ DEFAULT_MAP_WINDOW_64, "UEFI runtime end" }
>  	},
>  	.base_addr	=3D 0,
>  };
[...]

Also I will modify arch/arm64/mm/init.c:615 to be:
BUILD_BUG_ON(TASK_SIZE_32 > DEFAULT_MAP_WINDOW_64);

The above give me a working kernel with defconig. I will perform more tests
on COMPAT before sending a revised series out.

Cheers,
--=20
Steve
