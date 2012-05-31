Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id E030D6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:41:38 -0400 (EDT)
From: Bhushan Bharat-R65777 <R65777@freescale.com>
Subject: RE: memblock_end_of_DRAM()  return end address + 1
Date: Thu, 31 May 2012 13:41:34 +0000
Message-ID: <6A3DF150A5B70D4F9B66A25E3F7C888D03D5B033@039-SN2MPN1-022.039d.mgd.msft.net>
References: <6A3DF150A5B70D4F9B66A25E3F7C888D03D5AAE2@039-SN2MPN1-022.039d.mgd.msft.net>
In-Reply-To: <6A3DF150A5B70D4F9B66A25E3F7C888D03D5AAE2@039-SN2MPN1-022.039d.mgd.msft.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bhushan Bharat-R65777 <R65777@freescale.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "yinghai@kernel.org" <yinghai@kernel.org>, Wood Scott-B07421 <B07421@freescale.com>
Cc: "agraf@suse.de" <agraf@suse.de>

Adding some more gentlemen's.=09


> -----Original Message-----
> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
> owner@vger.kernel.org] On Behalf Of Bhushan Bharat-R65777
> Sent: Thursday, May 31, 2012 4:34 PM
> To: linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Cc: agraf@suse.de
> Subject: memblock_end_of_DRAM() return end address + 1
>=20
> Hi All,
>=20
> memblock_end_of_DRAM() defined in mm/memblock.c returns base_address + si=
ze; So
> this is not returning the end_of_DRAM, it is basically returning the end_=
of_DRAM
> + 1. The name looks to suggest that this returns end address on DRAM.
>=20
> IIUC, it looks like that some code assumes this returns the end address w=
hile
> some assumes this returns end address + 1.
>=20
> Example:
> 1. arch/powerpc/platforms/85xx/mpc85xx_ds.c
>=20
>=20
> <cut>
>=20
> #ifdef CONFIG_SWIOTLB
>         if (memblock_end_of_DRAM() > max) {
>                 ppc_swiotlb_enable =3D 1;
>                 set_pci_dma_ops(&swiotlb_dma_ops);
>                 ppc_md.pci_dma_dev_setup =3D pci_dma_dev_setup_swiotlb;
>         }
> #endif
>=20
> <cut>
> <cut>
>=20
>=20
> Where  max =3D 0xffffffff; So we assumes that memblock_end_of_DRAM() actu=
ally
> returns end address.
>=20
> ------
> 2.
>=20
> In arch/powerpc/kernel/dma.c
>=20
>=20
> static int dma_direct_dma_supported(struct device *dev, u64 mask) { #ifde=
f
> CONFIG_PPC64
>         /* Could be improved so platforms can set the limit in case
>          * they have limited DMA windows
>          */
>         return mask >=3D get_dma_offset(dev) + (memblock_end_of_DRAM() - =
1);
>=20
>=20
> <cut>
>=20
> It looks to that here we assume base + addr + 1;
>=20
> -----------
>=20
>=20
> Thanks
> -Bharat
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
