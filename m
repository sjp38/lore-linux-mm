Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 035076B0070
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 05:17:50 -0500 (EST)
Date: Thu, 29 Nov 2012 11:17:29 +0100
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: [PATCH 1/1] ARM: tegra: bus_notifier registers IOMMU
 devices(was: How to specify IOMMU'able devices in DT)
Message-ID: <20121129101729.GA6150@avionic-0098.adnet.avionic-design.de>
References: <20120924124452.41070ed2ee9944d930cffffc@nvidia.com>
 <054901cd9a45$db1a7ea0$914f7be0$%szyprowski@samsung.com>
 <20120924.145014.1452596970914043018.hdoyu@nvidia.com>
 <20121128.154832.539666140149950229.hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
In-Reply-To: <20121128.154832.539666140149950229.hdoyu@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "swarren@wwwdotorg.org" <swarren@wwwdotorg.org>, "joro@8bytes.org" <joro@8bytes.org>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "arnd@arndb.de" <arnd@arndb.de>, Krishna Reddy <vdumpa@nvidia.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 28, 2012 at 02:48:32PM +0100, Hiroshi Doyu wrote:
[...]
> From: Hiroshi Doyu <hdoyu@nvidia.com>
> Date: Wed, 28 Nov 2012 14:47:04 +0200
> Subject: [PATCH 1/1] ARM: tegra: bus_notifier registers IOMMU devices
>=20
> platform_bus notifier registers IOMMU devices if dma-window is
> specified.
>=20
> Its format is:
>   dma-window =3D <"start" "size">;
> ex)
>   dma-window =3D <0x12345000 0x8000>;
>=20
> Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> ---
>  arch/arm/mach-tegra/board-dt-tegra30.c |   40 ++++++++++++++++++++++++++=
++++++
>  1 file changed, 40 insertions(+)
>=20
> diff --git a/arch/arm/mach-tegra/board-dt-tegra30.c b/arch/arm/mach-tegra=
/board-dt-tegra30.c
> index a2b6cf1..570d718 100644
> --- a/arch/arm/mach-tegra/board-dt-tegra30.c
> +++ b/arch/arm/mach-tegra/board-dt-tegra30.c
> @@ -30,9 +30,11 @@
>  #include <linux/of_fdt.h>
>  #include <linux/of_irq.h>
>  #include <linux/of_platform.h>
> +#include <linux/of_iommu.h>
> =20
>  #include <asm/mach/arch.h>
>  #include <asm/hardware/gic.h>
> +#include <asm/dma-iommu.h>
> =20
>  #include "board.h"
>  #include "clock.h"
> @@ -86,10 +88,48 @@ static __initdata struct tegra_clk_init_table tegra_d=
t_clk_init_table[] =3D {
>  	{ NULL,		NULL,		0,		0},
>  };
> =20
> +#ifdef CONFIG_ARM_DMA_USE_IOMMU
> +static int tegra_iommu_device_notifier(struct notifier_block *nb,
> +				       unsigned long event, void *_dev)
> +{
> +	struct dma_iommu_mapping *map =3D NULL;
> +	struct device *dev =3D _dev;
> +	dma_addr_t base;
> +	size_t size;
> +	int err;
> +
> +	switch (event) {
> +	case BUS_NOTIFY_ADD_DEVICE:
> +		err =3D of_get_dma_window(dev->of_node, NULL, 0, NULL, &base,
> +					&size);
> +		if (!err)
> +			map =3D arm_iommu_create_mapping(&platform_bus_type,
> +						       base, size, 0);
> +		if (IS_ERR_OR_NULL(map))
> +			break;
> +		if (arm_iommu_attach_device(dev, map))
> +			dev_err(dev, "Failed to attach %s\n", dev_name(dev));
> +		dev_dbg(dev, "Attached %s to map %p\n", dev_name(dev), map);
> +		break;
> +	}
> +	return NOTIFY_DONE;
> +}
> +#else
> +#define tegra_iommu_device_notifier NULL
> +#endif
> +
> +static struct notifier_block tegra_iommu_device_nb =3D {
> +	.notifier_call =3D tegra_iommu_device_notifier,
> +};

You don't need this extra protection since you use IS_ENABLED below and
these are all static variables. The whole point of IS_ENABLED is to
allow full compile coverage while leaving it up to the compiler to
eliminate dead code.

Thierry

--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQtzY5AAoJEN0jrNd/PrOhuzMP/iJ18BF54Mt6oyjkj7L4SDsE
BHtFAOgoS6H6ZE4gDkJcmXotmEb1qSP4dhM6kox7XtEwfQ2QQ19btFNfsvyZrrZF
S7oRehteLuY9f9UeattSzMW7p/vLp4ca15krNuS2zMLonsvfARY3+zKshvp95i4w
u13XLVCCz8qFqMI+hTC1mG6J38yUX3OE8MatP213sO23gR+M+k2W2hGdShoIkLca
FjaeWw8XqapGQNAM7M95IkdWalIZGGQ7VUcWU7J+dYnb1yNS0fIiDPyc+PMXlcDc
rRseaEPAjeRKcx+gu7mTf0tZOo+oiwQFy7eRVtj1o/9KteIvL7BE5ePd7pnNQM5v
U9zBJ3mTt4suST5xFK0tTnJElbZFMtNA75ZC6mrHfyVFo1HcQd3gx2CN5qxWL709
Sgr8Gr0hrWyodLxiDE+a3q+k4deB5BxYccp1swZMrrlkH4MYVESCrgJ6TyZPjihr
OtpJyH4myC+GqBBdyxQ5phNLq13UdgmtiurnXDaKIgqq46yNR5TaUuo4B/bTDK6s
2PmMFziZYyCmnWiMb8JU42J/VHSQrQkv7EC3V9w6BKhkynPvh6CLMcsD7A2Ub+Ta
rZKyuy89z0wuGKhyJgpIGXRpjyROIorlHcsWpP9MPGb3V8Hec6hmBbVGFsSrxPqw
Io+pFSTddkjReGRA/agl
=uArM
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
