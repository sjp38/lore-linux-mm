Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 6C7726B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 07:04:29 -0400 (EDT)
From: Bhushan Bharat-R65777 <R65777@freescale.com>
Subject: memblock_end_of_DRAM()  return end address + 1
Date: Thu, 31 May 2012 11:03:35 +0000
Message-ID: <6A3DF150A5B70D4F9B66A25E3F7C888D03D5AAE2@039-SN2MPN1-022.039d.mgd.msft.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "agraf@suse.de" <agraf@suse.de>

Hi All,

memblock_end_of_DRAM() defined in mm/memblock.c returns base_address + size=
;
So this is not returning the end_of_DRAM, it is basically returning the end=
_of_DRAM + 1. The name looks to suggest that this returns end address on DR=
AM.

IIUC, it looks like that some code assumes this returns the end address whi=
le some assumes this returns end address + 1.

Example:
1. arch/powerpc/platforms/85xx/mpc85xx_ds.c


<cut>

#ifdef CONFIG_SWIOTLB
        if (memblock_end_of_DRAM() > max) {
                ppc_swiotlb_enable =3D 1;
                set_pci_dma_ops(&swiotlb_dma_ops);
                ppc_md.pci_dma_dev_setup =3D pci_dma_dev_setup_swiotlb;
        }
#endif

<cut>
<cut>


Where  max =3D 0xffffffff; So we assumes that memblock_end_of_DRAM() actual=
ly returns end address.

------
2.

In arch/powerpc/kernel/dma.c


static int dma_direct_dma_supported(struct device *dev, u64 mask)
{
#ifdef CONFIG_PPC64
        /* Could be improved so platforms can set the limit in case
         * they have limited DMA windows
         */
        return mask >=3D get_dma_offset(dev) + (memblock_end_of_DRAM() - 1)=
;


<cut>

It looks to that here we assume base + addr + 1;

-----------


Thanks
-Bharat


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
