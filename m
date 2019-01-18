Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 834EB8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 13:02:08 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id v3so4398041itf.4
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 10:02:08 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810105.outbound.protection.outlook.com. [40.107.81.105])
        by mx.google.com with ESMTPS id 70si2975858jal.88.2019.01.18.10.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Jan 2019 10:02:07 -0800 (PST)
From: Paul Burton <paul.burton@mips.com>
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of
 memblock_alloc*()
Date: Fri, 18 Jan 2019 18:02:03 +0000
Message-ID: <20190118180201.uva5nhf2g23uamkn@pburton-laptop>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8AB5FF9934BD5A4E822E85B3C315428B@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "uclinux-h8-devel@lists.sourceforge.jp" <uclinux-h8-devel@lists.sourceforge.jp>, "x86@kernel.org" <x86@kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>

Hi Mike,

On Wed, Jan 16, 2019 at 03:44:19PM +0200, Mike Rapoport wrote:
> Add check for the return value of memblock_alloc*() functions and call
> panic() in case of error.
> The panic message repeats the one used by panicing memblock allocators wi=
th
> adjustment of parameters to include only relevant ones.
>=20
> The replacement was mostly automated with semantic patches like the one
> below with manual massaging of format strings.
>=20
> @@
> expression ptr, size, align;
> @@
> ptr =3D memblock_alloc(size, align);
> + if (!ptr)
> + 	panic("%s: Failed to allocate %lu bytes align=3D0x%lx\n", __func__,
> size, align);
>=20
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>%
> diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octe=
on/dma-octeon.c
> index e8eb60e..db1deb2 100644
> --- a/arch/mips/cavium-octeon/dma-octeon.c
> +++ b/arch/mips/cavium-octeon/dma-octeon.c
> @@ -245,6 +245,9 @@ void __init plat_swiotlb_setup(void)
>  	swiotlbsize =3D swiotlb_nslabs << IO_TLB_SHIFT;
> =20
>  	octeon_swiotlb =3D memblock_alloc_low(swiotlbsize, PAGE_SIZE);
> +	if (!octeon_swiotlb)
> +		panic("%s: Failed to allocate %lu bytes align=3D%lx\n",
> +		      __func__, swiotlbsize, PAGE_SIZE);
> =20
>  	if (swiotlb_init_with_tbl(octeon_swiotlb, swiotlb_nslabs, 1) =3D=3D -EN=
OMEM)
>  		panic("Cannot allocate SWIOTLB buffer");

That one should be %zu rather than %lu. The rest looks good, so with
that one tweak:

    Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts

Thanks,
    Paul
