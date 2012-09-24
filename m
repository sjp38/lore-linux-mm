Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 2327F6B005A
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 05:04:49 -0400 (EDT)
Date: Mon, 24 Sep 2012 12:04:15 +0300
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: How to specify IOMMU'able devices in DT (was: [RFC 0/5] ARM:
 dma-mapping: New dma_map_ops to control IOVA more precisely)
Message-ID: <20120924120415.8e6929a34c422185a98d3f82@nvidia.com>
In-Reply-To: <401E54CE964CD94BAE1EB4A729C7087E379FDC2372@HQMAIL04.nvidia.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
	<20120918124918.GK2505@amd.com>
	<20120919095843.d1db155e0f085f4fcf64ea32@nvidia.com>
	<201209190759.46174.arnd@arndb.de>
	<20120919125020.GQ2505@amd.com>
	<401E54CE964CD94BAE1EB4A729C7087E379FDC1EEB@HQMAIL04.nvidia.com>
	<505A7DB4.4090902@wwwdotorg.org>
	<401E54CE964CD94BAE1EB4A729C7087E379FDC1F2D@HQMAIL04.nvidia.com>
	<505B35F7.2080201@wwwdotorg.org>
	<401E54CE964CD94BAE1EB4A729C7087E379FDC2372@HQMAIL04.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Warren <swarren@wwwdotorg.org>, Joerg Roedel <joerg.roedel@amd.com>, Arnd Bergmann <arnd@arndb.de>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, Krishna Reddy <vdumpa@nvidia.com>
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, 21 Sep 2012 20:16:00 +0200
Krishna Reddy <vdumpa@nvidia.com> wrote:

> > > The device(H/W controller) need to access few special memory
> > > blocks(IOVA==PA) and DRAM as well.
> >
> > OK, so only /some/ of the VA space is VA==PA, and some is remapped; that's a
> > little different that what you originally implied above.
> >
> > BTW, which HW module is this; AVP/COP or something else. This sounds like an
> > odd requirement.
>
> This is not specific to ARM7. There are protected memory regions on Tegra that
> can be accessed by some controllers like display, 2D, 3D, VDE, HDA. These are
> DRAM regions configured as protected by BootRom. These memory regions
> are not exposed to and not managed by OS page allocator. The H/W controller
>  accesses to these regions still to go through IOMMU.
> The IOMMU view for all the H/W controllers is not uniform on Tegra.
> Some Controllers see entire 4GB IOVA space. i.e all accesses go though IOMMU.
> Some controllers see the IOVA Space that don't overlap with MMIO space.  i.e
> The MMIO address access bypass IOMMU and directly go to MMIO space.
> Tegra IOMMU can support multiple address spaces as well. To hide controller
> Specific behavior, the drivers should take care of one to one mapping and
> remove inaccessible iova spaces in their address space's based platform device info.

The above is also related to another issue,
    how to specify IOMMU'able devices in DT.

As mentioned above, some IOVA mapping may be unique to some devices,
and the number of IOMMU'able device are quite many nowadays, a few
dozen in Tegra30 now. Basically they are seen as just normal platform
devices from CPU even if they belong to different busses in H/W. IOW, their
IOMMU'ability just depend on a platfrom bus from _S/W_ POV. Doing each
registration(create a map & attach device) in board files isn't so
nice. Currently we register them at "platform_device_add()" at once
with just a HACK(*1), but this could/should be done based on the info
passed from DT. For tegra, those parameter could be, "ASID" and
"address range"(start, size, alignment). For example in DT:

deviceA {
                      "start"     "size"   "align"
          iommu = <0x12340000 0x00400000 0x0000000>;   # exclusively specify "start" or "align"
          iommu = <0x00000000 0x00400000 0x0010000>;
          iommu = <0x12340000 0x00040000 0x12380000 0x00040000>; # "start", "size" could be repeated...
	  asid = 3; # if needed

or
          dma_range = <0x12340000 0x00400000 0x0000000>; # if iommu is considered as one implementation of dma.....
};

Is there any way to specify each IOMMU'able _platform device_ and
specify its map in DT?

The above ASID may be specific to Tegra, though. If we can specify the
above info in DT and the info is passed to kernel, some platform
common code would register them as IOMMU'able device automatically. It
would be really covenient if this is done in platform_device/IOMMU
common code. If the above attribute is implemented specific to
Tegra/platform, we have to call attach_device quite many times
somewhere in device initializations.

Any comment would be really appreciated.

*1:
