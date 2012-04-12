Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1088F6B0109
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 08:39:46 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Thu, 12 Apr 2012 14:38:40 +0200
Subject: Re: [PATCH] ARM: Exynos4: integrate SYSMMU driver with DMA-mapping
 interface
Message-ID: <20120412.153840.505876550992316983.hdoyu@nvidia.com>
References: <026301cd188d$32613860$9723a920$%szyprowski@samsung.com><201204121109.28753.arnd@arndb.de><028f01cd18a5$b0721770$11564650$%szyprowski@samsung.com>
In-Reply-To: <028f01cd18a5$b0721770$11564650$%szyprowski@samsung.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "arnd@arndb.de" <arnd@arndb.de>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
Cc: "subashrp@gmail.com" <subashrp@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "joro@8bytes.org" <joro@8bytes.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "andrzej.p@samsung.com" <andrzej.p@samsung.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>

From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH] ARM: Exynos4: integrate SYSMMU driver with DMA-mapping=
 interface
Date: Thu, 12 Apr 2012 14:13:37 +0200
Message-ID: <028f01cd18a5$b0721770$11564650$%szyprowski@samsung.com>

>
>
>
>
> > -----Original Message-----
> > From: Arnd Bergmann [mailto:arnd@arndb.de]
> > Sent: Thursday, April 12, 2012 1:09 PM
> > To: Marek Szyprowski
> > Cc: 'Subash Patel'; linux-arm-kernel@lists.infradead.org; linaro-mm-sig=
@lists.linaro.org;
> > linux-mm@kvack.org; linux-arch@vger.kernel.org; iommu@lists.linux-found=
ation.org; 'Kyungmin
> > Park'; 'Joerg Roedel'; 'Russell King - ARM Linux'; 'Chunsang Jeong'; 'K=
rishna Reddy'; 'KyongHo
> > Cho'; Andrzej Pietrasiewicz; 'Benjamin Herrenschmidt'; 'Konrad Rzeszute=
k Wilk'; 'Hiroshi Doyu'
> > Subject: Re: [PATCH] ARM: Exynos4: integrate SYSMMU driver with DMA-map=
ping interface
> >
> > On Thursday 12 April 2012, Marek Szyprowski wrote:
> > > +
> > > > > +/*
> > > > > + * s5p_sysmmu_late_init
> > > > > + * Create DMA-mapping IOMMU context for specified devices. This =
function must
> > > > > + * be called later, once SYSMMU driver gets registered and probe=
d.
> > > > > + */
> > > > > +static int __init s5p_sysmmu_late_init(void)
> > > > > +{
> > > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(fimc0).dev,&s5p_device_fi=
mc0.dev);
> > > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(fimc1).dev,&s5p_device_fi=
mc1.dev);
> > > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(fimc2).dev,&s5p_device_fi=
mc2.dev);
> > > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(fimc3).dev,&s5p_device_fi=
mc3.dev);
> > > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(mfc_l).dev,&s5p_device_mf=
c_l.dev);
> > > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(mfc_r).dev,&s5p_device_mf=
c_r.dev);
> > > > > +
> > > > > +   s5p_create_iommu_mapping(&s5p_device_fimc0.dev, 0x20000000, S=
Z_128M, 4);
> > > > > +   s5p_create_iommu_mapping(&s5p_device_fimc1.dev, 0x20000000, S=
Z_128M, 4);
> > > > > +   s5p_create_iommu_mapping(&s5p_device_fimc2.dev, 0x20000000, S=
Z_128M, 4);
> > > > > +   s5p_create_iommu_mapping(&s5p_device_fimc3.dev, 0x20000000, S=
Z_128M, 4);
> > > > > +   s5p_create_iommu_mapping(&s5p_device_mfc_l.dev, 0x20000000, S=
Z_128M, 4);
> > > > > +   s5p_create_iommu_mapping(&s5p_device_mfc_r.dev, 0x40000000, S=
Z_128M, 4);
> > > > > +
> > > > > +   return 0;
> > > > > +}
> > > > > +device_initcall(s5p_sysmmu_late_init);
> > > >
> > > > Shouldn't these things be specific to a SoC? With this RFC, it happ=
ens
> > > > that you will predefine the IOMMU attachment and mapping informatio=
n for
> > > > devices in common location (dev-sysmmu.c)? This may lead to problem=
s
> > > > because there are some IP's with SYSMMU support in exynos5, but not
> > > > available in exynos4 (eg: GSC, FIMC-LITE, FIMC-ISP) Previously we u=
sed
> > > > to do above declaration in individual machine file, which I think w=
as
> > > > more meaningful.
> > >
> > > Right, I simplified the code too much. Keeping these definitions insi=
de machine
> > > files was a better idea. I completely forgot that Exynos sub-platform=
 now covers
> > > both Exynos4 and Exynos5 SoC families.
> >
> > Ideally the information about iommu attachment should come from the
> > device tree. We have the "dma-ranges" properties that define how a dma
> > address space is mapped. I am not entirely sure how that works when you
> > have multiple IOMMUs and if that requires defining addititional propert=
ies,
> > but I think we should make it so that we don't have to hardcode specifi=
c
> > devices in the source.
>
> Right, until that time machine/board files are imho ok.

In Tegra30, there are quite many IOMMU attachable (platform)devices,
and it's quite nice for us to configure them (un)attached with address
range and IOMMU device ID(ASID) in DT in advance rather than inserting
the code to attach those devices here and there.

Experimentally I added some hook in platform_device_add() as below,
but apparently this won't be accepted.
