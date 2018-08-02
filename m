Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D923A6B000C
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 03:06:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g24-v6so852258plq.2
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 00:06:25 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f17-v6si1117344pge.494.2018.08.02.00.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 00:06:24 -0700 (PDT)
Message-ID: <1533193580.23760.1.camel@intel.com>
Subject: Re: [PATCH 2/3] nios2: use generic early_init_dt_add_memory_arch
From: Ley Foon Tan <ley.foon.tan@intel.com>
Date: Thu, 02 Aug 2018 15:06:20 +0800
In-Reply-To: <1530710295-10774-3-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
	 <1530710295-10774-3-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Ley Foon Tan <lftan@altera.com>
Cc: Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Michal Hocko <mhocko@kernel.org>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2018-07-04 at 16:18 +0300, Mike Rapoport wrote:
> All we have to do is to enable memblock, the generic FDT code will
> take
> care of the rest.
>=20
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
> =C2=A0arch/nios2/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=
=C2=A0=C2=A01 +
> =C2=A0arch/nios2/kernel/prom.c=C2=A0=C2=A0| 10 ----------
> =C2=A0arch/nios2/kernel/setup.c |=C2=A0=C2=A02 ++
> =C2=A03 files changed, 3 insertions(+), 10 deletions(-)
>=20
> diff --git a/arch/nios2/Kconfig b/arch/nios2/Kconfig
> index 3d4ec88..5db8fa1 100644
> --- a/arch/nios2/Kconfig
> +++ b/arch/nios2/Kconfig
> @@ -19,6 +19,7 @@ config NIOS2
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0select SPARSE_IRQ
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0select USB_ARCH_HAS_HCD i=
f USB_SUPPORT
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0select CPU_NO_EFFICIENT_F=
FS
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0select HAVE_MEMBLOCK
>=20
> =C2=A0config GENERIC_CSUM
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0def_bool y
> diff --git a/arch/nios2/kernel/prom.c b/arch/nios2/kernel/prom.c
> index 8d7446a..ba96a49 100644
> --- a/arch/nios2/kernel/prom.c
> +++ b/arch/nios2/kernel/prom.c
> @@ -32,16 +32,6 @@
>=20
> =C2=A0#include <asm/sections.h>
>=20
> -void __init early_init_dt_add_memory_arch(u64 base, u64 size)
> -{
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u64 kernel_start =3D (u64)virt=
_to_phys(_text);
> -
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!memory_size &&
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(kerne=
l_start >=3D base) && (kernel_start < (base + size)))
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0memory_size =3D size;
> -
> -}
> -
> =C2=A0int __init early_init_dt_reserve_memory_arch(phys_addr_t base,
> phys_addr_t size,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool nomap)
> =C2=A0{
> diff --git a/arch/nios2/kernel/setup.c b/arch/nios2/kernel/setup.c
> index 926a02b..0946840 100644
> --- a/arch/nios2/kernel/setup.c
> +++ b/arch/nios2/kernel/setup.c
> @@ -17,6 +17,7 @@
> =C2=A0#include <linux/sched/task.h>
> =C2=A0#include <linux/console.h>
> =C2=A0#include <linux/bootmem.h>
> +#include <linux/memblock.h>
> =C2=A0#include <linux/initrd.h>
> =C2=A0#include <linux/of_fdt.h>
> =C2=A0#include <linux/screen_info.h>
> @@ -147,6 +148,7 @@ void __init setup_arch(char **cmdline_p)
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0console_verbose();
>=20
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0memory_size =3D memblock_phys_=
mem_size();
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0memory_start =3D PAGE_ALI=
GN((unsigned long)__pa(_end));
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0memory_end =3D (unsigned =
long) CONFIG_NIOS2_MEM_BASE +
> memory_size;
>=20
> --
Acked-by: Ley Foon Tan <ley.foon.tan@intel.com>
