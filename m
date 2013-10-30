Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC326B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 01:33:54 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so877112pbc.8
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 22:33:54 -0700 (PDT)
Received: from psmtp.com ([74.125.245.102])
        by mx.google.com with SMTP id cj2si16727013pbc.207.2013.10.29.22.33.52
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 22:33:53 -0700 (PDT)
From: Bhushan Bharat-R65777 <R65777@freescale.com>
Subject: RE: [PATCH v9 01/13] KVM: PPC: POWERNV: move iommu_add_device
 earlier
Date: Wed, 30 Oct 2013 05:33:46 +0000
Message-ID: <6A3DF150A5B70D4F9B66A25E3F7C888D071D7891@039-SN2MPN1-013.039d.mgd.msft.net>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
 <1377679070-3515-2-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1377679070-3515-2-git-send-email-aik@ozlabs.ru>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, Gleb Natapov <gleb@redhat.com>, "kvm-ppc@vger.kernel.org" <kvm-ppc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Paolo Bonzini <pbonzini@redhat.com>, David Gibson <david@gibson.dropbear.id.au>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Alexey Kardashevskiy <aik@ozlabs.ru>

Hi Alex,

Looks like this patch is not picked by anyone, Are you going to pick this p=
atch?
My vfio/iommu patches have dependency on this patch (this is already tested=
 by me).

Thanks
-Bharat

> -----Original Message-----
> From: Linuxppc-dev [mailto:linuxppc-dev-
> bounces+bharat.bhushan=3Dfreescale.com@lists.ozlabs.org] On Behalf Of Ale=
xey
> Kardashevskiy
> Sent: Wednesday, August 28, 2013 2:08 PM
> To: linuxppc-dev@lists.ozlabs.org
> Cc: kvm@vger.kernel.org; Gleb Natapov; Alexey Kardashevskiy; Alexander Gr=
af;
> kvm-ppc@vger.kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org=
; Paul
> Mackerras; Paolo Bonzini; David Gibson
> Subject: [PATCH v9 01/13] KVM: PPC: POWERNV: move iommu_add_device earlie=
r
>=20
> The current implementation of IOMMU on sPAPR does not use iommu_ops and
> therefore does not call IOMMU API's bus_set_iommu() which
> 1) sets iommu_ops for a bus
> 2) registers a bus notifier
> Instead, PCI devices are added to IOMMU groups from
> subsys_initcall_sync(tce_iommu_init) which does basically the same thing =
without
> using iommu_ops callbacks.
>=20
> However Freescale PAMU driver (https://lkml.org/lkml/2013/7/1/158)
> implements iommu_ops and when tce_iommu_init is called, every PCI device =
is
> already added to some group so there is a conflict.
>=20
> This patch does 2 things:
> 1. removes the loop in which PCI devices were added to groups and adds ex=
plicit
> iommu_add_device() calls to add devices as soon as they get the iommu_tab=
le
> pointer assigned to them.
> 2. moves a bus notifier to powernv code in order to avoid conflict with t=
he
> notifier from Freescale driver.
>=20
> iommu_add_device() and iommu_del_device() are public now.
>=20
> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
> ---
> Changes:
> v8:
> * added the check for iommu_group!=3DNULL before removing device from a g=
roup as
> suggested by Wei Yang <weiyang@linux.vnet.ibm.com>
>=20
> v2:
> * added a helper - set_iommu_table_base_and_group - which does
> set_iommu_table_base() and iommu_add_device()
> ---
>  arch/powerpc/include/asm/iommu.h            |  9 +++++++
>  arch/powerpc/kernel/iommu.c                 | 41 +++--------------------=
------
>  arch/powerpc/platforms/powernv/pci-ioda.c   |  8 +++---
>  arch/powerpc/platforms/powernv/pci-p5ioc2.c |  2 +-
>  arch/powerpc/platforms/powernv/pci.c        | 33 ++++++++++++++++++++++-
>  arch/powerpc/platforms/pseries/iommu.c      |  8 +++---
>  6 files changed, 55 insertions(+), 46 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/iommu.h b/arch/powerpc/include/asm/=
iommu.h
> index c34656a..19ad77f 100644
> --- a/arch/powerpc/include/asm/iommu.h
> +++ b/arch/powerpc/include/asm/iommu.h
> @@ -103,6 +103,15 @@ extern struct iommu_table *iommu_init_table(struct
> iommu_table * tbl,
>  					    int nid);
>  extern void iommu_register_group(struct iommu_table *tbl,
>  				 int pci_domain_number, unsigned long pe_num);
> +extern int iommu_add_device(struct device *dev); extern void
> +iommu_del_device(struct device *dev);
> +
> +static inline void set_iommu_table_base_and_group(struct device *dev,
> +						  void *base)
> +{
> +	set_iommu_table_base(dev, base);
> +	iommu_add_device(dev);
> +}
>=20
>  extern int iommu_map_sg(struct device *dev, struct iommu_table *tbl,
>  			struct scatterlist *sglist, int nelems, diff --git
> a/arch/powerpc/kernel/iommu.c b/arch/powerpc/kernel/iommu.c index
> b20ff17..15f8ca8 100644
> --- a/arch/powerpc/kernel/iommu.c
> +++ b/arch/powerpc/kernel/iommu.c
> @@ -1105,7 +1105,7 @@ void iommu_release_ownership(struct iommu_table *tb=
l)  }
> EXPORT_SYMBOL_GPL(iommu_release_ownership);
>=20
> -static int iommu_add_device(struct device *dev)
> +int iommu_add_device(struct device *dev)
>  {
>  	struct iommu_table *tbl;
>  	int ret =3D 0;
> @@ -1134,46 +1134,13 @@ static int iommu_add_device(struct device *dev)
>=20
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(iommu_add_device);
>=20
> -static void iommu_del_device(struct device *dev)
> +void iommu_del_device(struct device *dev)
>  {
>  	iommu_group_remove_device(dev);
>  }
> -
> -static int iommu_bus_notifier(struct notifier_block *nb,
> -			      unsigned long action, void *data)
> -{
> -	struct device *dev =3D data;
> -
> -	switch (action) {
> -	case BUS_NOTIFY_ADD_DEVICE:
> -		return iommu_add_device(dev);
> -	case BUS_NOTIFY_DEL_DEVICE:
> -		iommu_del_device(dev);
> -		return 0;
> -	default:
> -		return 0;
> -	}
> -}
> -
> -static struct notifier_block tce_iommu_bus_nb =3D {
> -	.notifier_call =3D iommu_bus_notifier,
> -};
> -
> -static int __init tce_iommu_init(void)
> -{
> -	struct pci_dev *pdev =3D NULL;
> -
> -	BUILD_BUG_ON(PAGE_SIZE < IOMMU_PAGE_SIZE);
> -
> -	for_each_pci_dev(pdev)
> -		iommu_add_device(&pdev->dev);
> -
> -	bus_register_notifier(&pci_bus_type, &tce_iommu_bus_nb);
> -	return 0;
> -}
> -
> -subsys_initcall_sync(tce_iommu_init);
> +EXPORT_SYMBOL_GPL(iommu_del_device);
>=20
>  #else
>=20
> diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c
> b/arch/powerpc/platforms/powernv/pci-ioda.c
> index d8140b1..756bb58 100644
> --- a/arch/powerpc/platforms/powernv/pci-ioda.c
> +++ b/arch/powerpc/platforms/powernv/pci-ioda.c
> @@ -440,7 +440,7 @@ static void pnv_pci_ioda_dma_dev_setup(struct pnv_phb=
 *phb,
> struct pci_dev *pdev
>  		return;
>=20
>  	pe =3D &phb->ioda.pe_array[pdn->pe_number];
> -	set_iommu_table_base(&pdev->dev, &pe->tce32_table);
> +	set_iommu_table_base_and_group(&pdev->dev, &pe->tce32_table);
>  }
>=20
>  static void pnv_ioda_setup_bus_dma(struct pnv_ioda_pe *pe, struct pci_bu=
s *bus)
> @@ -448,7 +448,7 @@ static void pnv_ioda_setup_bus_dma(struct pnv_ioda_pe=
 *pe,
> struct pci_bus *bus)
>  	struct pci_dev *dev;
>=20
>  	list_for_each_entry(dev, &bus->devices, bus_list) {
> -		set_iommu_table_base(&dev->dev, &pe->tce32_table);
> +		set_iommu_table_base_and_group(&dev->dev, &pe->tce32_table);
>  		if (dev->subordinate)
>  			pnv_ioda_setup_bus_dma(pe, dev->subordinate);
>  	}
> @@ -611,7 +611,7 @@ static void pnv_pci_ioda_setup_dma_pe(struct pnv_phb =
*phb,
>  	iommu_register_group(tbl, pci_domain_nr(pe->pbus), pe->pe_number);
>=20
>  	if (pe->pdev)
> -		set_iommu_table_base(&pe->pdev->dev, tbl);
> +		set_iommu_table_base_and_group(&pe->pdev->dev, tbl);
>  	else
>  		pnv_ioda_setup_bus_dma(pe, pe->pbus);
>=20
> @@ -687,7 +687,7 @@ static void pnv_pci_ioda2_setup_dma_pe(struct pnv_phb=
 *phb,
>  	iommu_init_table(tbl, phb->hose->node);
>=20
>  	if (pe->pdev)
> -		set_iommu_table_base(&pe->pdev->dev, tbl);
> +		set_iommu_table_base_and_group(&pe->pdev->dev, tbl);
>  	else
>  		pnv_ioda_setup_bus_dma(pe, pe->pbus);
>=20
> diff --git a/arch/powerpc/platforms/powernv/pci-p5ioc2.c
> b/arch/powerpc/platforms/powernv/pci-p5ioc2.c
> index b68db63..ede341b 100644
> --- a/arch/powerpc/platforms/powernv/pci-p5ioc2.c
> +++ b/arch/powerpc/platforms/powernv/pci-p5ioc2.c
> @@ -92,7 +92,7 @@ static void pnv_pci_p5ioc2_dma_dev_setup(struct pnv_phb=
 *phb,
>  				pci_domain_nr(phb->hose->bus), phb->opal_id);
>  	}
>=20
> -	set_iommu_table_base(&pdev->dev, &phb->p5ioc2.iommu_table);
> +	set_iommu_table_base_and_group(&pdev->dev, &phb->p5ioc2.iommu_table);
>  }
>=20
>  static void __init pnv_pci_init_p5ioc2_phb(struct device_node *np, u64 h=
ub_id,
> diff --git a/arch/powerpc/platforms/powernv/pci.c
> b/arch/powerpc/platforms/powernv/pci.c
> index a28d3b5..c005011 100644
> --- a/arch/powerpc/platforms/powernv/pci.c
> +++ b/arch/powerpc/platforms/powernv/pci.c
> @@ -504,7 +504,7 @@ static void pnv_pci_dma_fallback_setup(struct pci_con=
troller
> *hose,
>  		pdn->iommu_table =3D pnv_pci_setup_bml_iommu(hose);
>  	if (!pdn->iommu_table)
>  		return;
> -	set_iommu_table_base(&pdev->dev, pdn->iommu_table);
> +	set_iommu_table_base_and_group(&pdev->dev, pdn->iommu_table);
>  }
>=20
>  static void pnv_pci_dma_dev_setup(struct pci_dev *pdev) @@ -623,3 +623,3=
4 @@
> void __init pnv_pci_init(void)
>  	ppc_md.teardown_msi_irqs =3D pnv_teardown_msi_irqs;  #endif  }
> +
> +static int tce_iommu_bus_notifier(struct notifier_block *nb,
> +		unsigned long action, void *data)
> +{
> +	struct device *dev =3D data;
> +
> +	switch (action) {
> +	case BUS_NOTIFY_ADD_DEVICE:
> +		return iommu_add_device(dev);
> +	case BUS_NOTIFY_DEL_DEVICE:
> +		if (dev->iommu_group)
> +			iommu_del_device(dev);
> +		return 0;
> +	default:
> +		return 0;
> +	}
> +}
> +
> +static struct notifier_block tce_iommu_bus_nb =3D {
> +	.notifier_call =3D tce_iommu_bus_notifier, };
> +
> +static int __init tce_iommu_bus_notifier_init(void) {
> +	BUILD_BUG_ON(PAGE_SIZE < IOMMU_PAGE_SIZE);
> +
> +	bus_register_notifier(&pci_bus_type, &tce_iommu_bus_nb);
> +	return 0;
> +}
> +
> +subsys_initcall_sync(tce_iommu_bus_notifier_init);
> diff --git a/arch/powerpc/platforms/pseries/iommu.c
> b/arch/powerpc/platforms/pseries/iommu.c
> index 23fc1dc..884ae71 100644
> --- a/arch/powerpc/platforms/pseries/iommu.c
> +++ b/arch/powerpc/platforms/pseries/iommu.c
> @@ -687,7 +687,8 @@ static void pci_dma_dev_setup_pSeries(struct pci_dev =
*dev)
>  		iommu_table_setparms(phb, dn, tbl);
>  		PCI_DN(dn)->iommu_table =3D iommu_init_table(tbl, phb->node);
>  		iommu_register_group(tbl, pci_domain_nr(phb->bus), 0);
> -		set_iommu_table_base(&dev->dev, PCI_DN(dn)->iommu_table);
> +		set_iommu_table_base_and_group(&dev->dev,
> +					       PCI_DN(dn)->iommu_table);
>  		return;
>  	}
>=20
> @@ -699,7 +700,8 @@ static void pci_dma_dev_setup_pSeries(struct pci_dev =
*dev)
>  		dn =3D dn->parent;
>=20
>  	if (dn && PCI_DN(dn))
> -		set_iommu_table_base(&dev->dev, PCI_DN(dn)->iommu_table);
> +		set_iommu_table_base_and_group(&dev->dev,
> +					       PCI_DN(dn)->iommu_table);
>  	else
>  		printk(KERN_WARNING "iommu: Device %s has no iommu table\n",
>  		       pci_name(dev));
> @@ -1193,7 +1195,7 @@ static void pci_dma_dev_setup_pSeriesLP(struct pci_=
dev
> *dev)
>  		pr_debug("  found DMA window, table: %p\n", pci->iommu_table);
>  	}
>=20
> -	set_iommu_table_base(&dev->dev, pci->iommu_table);
> +	set_iommu_table_base_and_group(&dev->dev, pci->iommu_table);
>  }
>=20
>  static int dma_set_mask_pSeriesLP(struct device *dev, u64 dma_mask)
> --
> 1.8.4.rc4
>=20
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
