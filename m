Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 754FB6B050C
	for <linux-mm@kvack.org>; Thu, 17 May 2018 12:43:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x2-v6so2109223wmc.3
        for <linux-mm@kvack.org>; Thu, 17 May 2018 09:43:45 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id u9-v6si4885637wrb.232.2018.05.17.09.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 09:43:43 -0700 (PDT)
Date: Thu, 17 May 2018 15:25:07 +0100
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
Message-ID: <20180517150516.000067ca@huawei.com>
In-Reply-To: <20180511190641.23008-4-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-4-jean-philippe.brucker@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

On Fri, 11 May 2018 20:06:04 +0100
Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:

> Allocate IOMMU mm structures and binding them to devices. Four operations
> are added to IOMMU drivers:
>=20
> * mm_alloc(): to create an io_mm structure and perform architecture-
>   specific operations required to grab the process (for instance on ARM,
>   pin down the CPU ASID so that the process doesn't get assigned a new
>   ASID on rollover).
>=20
>   There is a single valid io_mm structure per Linux mm. Future extensions
>   may also use io_mm for kernel-managed address spaces, populated with
>   map()/unmap() calls instead of bound to process address spaces. This
>   patch focuses on "shared" io_mm.
>=20
> * mm_attach(): attach an mm to a device. The IOMMU driver checks that the
>   device is capable of sharing an address space, and writes the PASID
>   table entry to install the pgd.
>=20
>   Some IOMMU drivers will have a single PASID table per domain, for
>   convenience. Other can implement it differently but to help these
>   drivers, mm_attach and mm_detach take 'attach_domain' and
>   'detach_domain' parameters, that tell whether they need to set and clear
>   the PASID entry or only send the required TLB invalidations.
>=20
> * mm_detach(): detach an mm from a device. The IOMMU driver removes the
>   PASID table entry and invalidates the IOTLBs.
>=20
> * mm_free(): free a structure allocated by mm_alloc(), and let arch
>   release the process.
>=20
> mm_attach and mm_detach operations are serialized with a spinlock. When
> trying to optimize this code, we should at least prevent concurrent
> attach()/detach() on the same domain (so multi-level PASID table code can
> allocate tables lazily). mm_alloc() can sleep, but mm_free must not
> (because we'll have to call it from call_srcu later on).
>=20
> At the moment we use an IDR for allocating PASIDs and retrieving contexts.
> We also use a single spinlock. These can be refined and optimized later (a
> custom allocator will be needed for top-down PASID allocation).
>=20
> Keeping track of address spaces requires the use of MMU notifiers.
> Handling process exit with regard to unbind() is tricky, so it is left for
> another patch and we explicitly fail mm_alloc() for the moment.
>=20
> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

A few minor bits and bobs inline.  Looks good in general + nice diags!

Thanks,

Jonathan

>=20
> ---
> v1->v2: sanity-check of flags
> ---
>  drivers/iommu/iommu-sva.c | 380 +++++++++++++++++++++++++++++++++++++-
>  drivers/iommu/iommu.c     |   1 +
>  include/linux/iommu.h     |  28 +++
>  3 files changed, 406 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/iommu/iommu-sva.c b/drivers/iommu/iommu-sva.c
> index 8d98f9c09864..6ac679c48f3c 100644
> --- a/drivers/iommu/iommu-sva.c
> +++ b/drivers/iommu/iommu-sva.c
> @@ -5,8 +5,298 @@
>   * Copyright (C) 2018 ARM Ltd.
>   */
> =20
> +#include <linux/idr.h>
>  #include <linux/iommu.h>
> +#include <linux/sched/mm.h>
>  #include <linux/slab.h>
> +#include <linux/spinlock.h>
> +
> +/**
> + * DOC: io_mm model
> + *
> + * The io_mm keeps track of process address spaces shared between CPU an=
d IOMMU.
> + * The following example illustrates the relation between structures
> + * iommu_domain, io_mm and iommu_bond. An iommu_bond is a link between i=
o_mm and
> + * device. A device can have multiple io_mm and an io_mm may be bound to
> + * multiple devices.
> + *              ___________________________
> + *             |  IOMMU domain A           |
> + *             |  ________________         |
> + *             | |  IOMMU group   |        +------- io_pgtables
> + *             | |                |        |
> + *             | |   dev 00:00.0 ----+------- bond --- io_mm X
> + *             | |________________|   \    |
> + *             |                       '----- bond ---.
> + *             |___________________________|           \
> + *              ___________________________             \
> + *             |  IOMMU domain B           |           io_mm Y
> + *             |  ________________         |           / /
> + *             | |  IOMMU group   |        |          / /
> + *             | |                |        |         / /
> + *             | |   dev 00:01.0 ------------ bond -' /
> + *             | |   dev 00:01.1 ------------ bond --'
> + *             | |________________|        |
> + *             |                           +------- io_pgtables
> + *             |___________________________|
> + *
> + * In this example, device 00:00.0 is in domain A, devices 00:01.* are i=
n domain
> + * B. All devices within the same domain access the same address spaces.=
 Device
> + * 00:00.0 accesses address spaces X and Y, each corresponding to an mm_=
struct.
> + * Devices 00:01.* only access address space Y. In addition each
> + * IOMMU_DOMAIN_DMA domain has a private address space, io_pgtable, that=
 is
> + * managed with iommu_map()/iommu_unmap(), and isn't shared with the CPU=
 MMU.
> + *
> + * To obtain the above configuration, users would for instance issue the
> + * following calls:
> + *
> + *     iommu_sva_bind_device(dev 00:00.0, mm X, ...) -> PASID 1
> + *     iommu_sva_bind_device(dev 00:00.0, mm Y, ...) -> PASID 2
> + *     iommu_sva_bind_device(dev 00:01.0, mm Y, ...) -> PASID 2
> + *     iommu_sva_bind_device(dev 00:01.1, mm Y, ...) -> PASID 2
> + *
> + * A single Process Address Space ID (PASID) is allocated for each mm. I=
n the
> + * example, devices use PASID 1 to read/write into address space X and P=
ASID 2
> + * to read/write into address space Y.
> + *
> + * Hardware tables describing this configuration in the IOMMU would typi=
cally
> + * look like this:
> + *
> + *                                PASID tables
> + *                                 of domain A
> + *                              .->+--------+
> + *                             / 0 |        |-------> io_pgtable
> + *                            /    +--------+
> + *            Device tables  /   1 |        |-------> pgd X
> + *              +--------+  /      +--------+
> + *      00:00.0 |      A |-'     2 |        |--.
> + *              +--------+         +--------+   \
> + *              :        :       3 |        |    \
> + *              +--------+         +--------+     --> pgd Y
> + *      00:01.0 |      B |--.                    /
> + *              +--------+   \                  |
> + *      00:01.1 |      B |----+   PASID tables  |
> + *              +--------+     \   of domain B  |
> + *                              '->+--------+   |
> + *                               0 |        |-- | --> io_pgtable
> + *                                 +--------+   |
> + *                               1 |        |   |
> + *                                 +--------+   |
> + *                               2 |        |---'
> + *                                 +--------+
> + *                               3 |        |
> + *                                 +--------+
> + *
> + * With this model, a single call binds all devices in a given domain to=
 an
> + * address space. Other devices in the domain will get the same bond imp=
licitly.
> + * However, users must issue one bind() for each device, because IOMMUs =
may
> + * implement SVA differently. Furthermore, mandating one bind() per devi=
ce
> + * allows the driver to perform sanity-checks on device capabilities.
> + *
> + * On Arm and AMD IOMMUs, entry 0 of the PASID table can be used to hold
> + * non-PASID translations. In this case PASID 0 is reserved and entry 0 =
points
> + * to the io_pgtable base. On Intel IOMMU, the io_pgtable base would be =
held in
> + * the device table and PASID 0 would be available to the allocator.
> + */
> +
> +struct iommu_bond {
> +	struct io_mm		*io_mm;
> +	struct device		*dev;
> +	struct iommu_domain	*domain;
> +
> +	struct list_head	mm_head;
> +	struct list_head	dev_head;
> +	struct list_head	domain_head;
> +
> +	void			*drvdata;
> +};
> +
> +/*
> + * Because we're using an IDR, PASIDs are limited to 31 bits (the sign b=
it is
> + * used for returning errors). In practice implementations will use at m=
ost 20
> + * bits, which is the PCI limit.
> + */
> +static DEFINE_IDR(iommu_pasid_idr);
> +
> +/*
> + * For the moment this is an all-purpose lock. It serializes
> + * access/modifications to bonds, access/modifications to the PASID IDR,=
 and
> + * changes to io_mm refcount as well.
> + */
> +static DEFINE_SPINLOCK(iommu_sva_lock);
> +
> +static struct io_mm *
> +io_mm_alloc(struct iommu_domain *domain, struct device *dev,
> +	    struct mm_struct *mm, unsigned long flags)
> +{
> +	int ret;
> +	int pasid;
> +	struct io_mm *io_mm;
> +	struct iommu_sva_param *param =3D dev->iommu_param->sva_param;
> +
> +	if (!domain->ops->mm_alloc || !domain->ops->mm_free)
> +		return ERR_PTR(-ENODEV);
> +
> +	io_mm =3D domain->ops->mm_alloc(domain, mm, flags);
> +	if (IS_ERR(io_mm))
> +		return io_mm;
> +	if (!io_mm)
> +		return ERR_PTR(-ENOMEM);
> +
> +	/*
> +	 * The mm must not be freed until after the driver frees the io_mm
> +	 * (which may involve unpinning the CPU ASID for instance, requiring a
> +	 * valid mm struct.)
> +	 */
> +	mmgrab(mm);
> +
> +	io_mm->flags		=3D flags;
> +	io_mm->mm		=3D mm;
> +	io_mm->release		=3D domain->ops->mm_free;
> +	INIT_LIST_HEAD(&io_mm->devices);
> +
> +	idr_preload(GFP_KERNEL);
> +	spin_lock(&iommu_sva_lock);
> +	pasid =3D idr_alloc(&iommu_pasid_idr, io_mm, param->min_pasid,
> +			  param->max_pasid + 1, GFP_ATOMIC);

I'd expect the IDR cleanup to be in io_mm_free as that would 'match'
against io_mm_alloc but it's in io_mm_release just before the io_mm_free
call, perhaps move it or am I missing something?

Hmm. This is reworked in patch 5 to use call rcu to do the free.  I suppose
we may be burning an idr entry if we take a while to get round to the
free..  If so a comment to explain this would be great.

> +	io_mm->pasid =3D pasid;
> +	spin_unlock(&iommu_sva_lock);
> +	idr_preload_end();
> +
> +	if (pasid < 0) {
> +		ret =3D pasid;
> +		goto err_free_mm;
> +	}
> +
> +	/* TODO: keep track of mm. For the moment, abort. */

=46rom later patches, I can now see why we didn't init the kref
here, but perhaps a comment would make that clear rather than
people checking it is correctly used throughout?  Actually just grab
the comment from patch 5 and put it in this one and that will
do the job nicely.

> +	ret =3D -ENOSYS;
> +	spin_lock(&iommu_sva_lock);
> +	idr_remove(&iommu_pasid_idr, io_mm->pasid);
> +	spin_unlock(&iommu_sva_lock);
> +
> +err_free_mm:
> +	domain->ops->mm_free(io_mm);

Really minor, but you now have io_mm->release set so to keep
this obviously the same as the io_mm_free path, perhaps call
that rather than mm_free directly.

> +	mmdrop(mm);
> +
> +	return ERR_PTR(ret);
> +}
> +
> +static void io_mm_free(struct io_mm *io_mm)
> +{
> +	struct mm_struct *mm =3D io_mm->mm;
> +
> +	io_mm->release(io_mm);
> +	mmdrop(mm);
> +}
> +
> +static void io_mm_release(struct kref *kref)
> +{
> +	struct io_mm *io_mm;
> +
> +	io_mm =3D container_of(kref, struct io_mm, kref);
> +	WARN_ON(!list_empty(&io_mm->devices));
> +
> +	idr_remove(&iommu_pasid_idr, io_mm->pasid);
> +
> +	io_mm_free(io_mm);
> +}
> +
> +/*
> + * Returns non-zero if a reference to the io_mm was successfully taken.
> + * Returns zero if the io_mm is being freed and should not be used.
> + */
> +static int io_mm_get_locked(struct io_mm *io_mm)
> +{
> +	if (io_mm)
> +		return kref_get_unless_zero(&io_mm->kref);
> +
> +	return 0;
> +}
> +
> +static void io_mm_put_locked(struct io_mm *io_mm)
> +{
> +	kref_put(&io_mm->kref, io_mm_release);
> +}
> +
> +static void io_mm_put(struct io_mm *io_mm)
> +{
> +	spin_lock(&iommu_sva_lock);
> +	io_mm_put_locked(io_mm);
> +	spin_unlock(&iommu_sva_lock);
> +}
> +
> +static int io_mm_attach(struct iommu_domain *domain, struct device *dev,
> +			struct io_mm *io_mm, void *drvdata)
> +{
> +	int ret;
> +	bool attach_domain =3D true;
> +	int pasid =3D io_mm->pasid;
> +	struct iommu_bond *bond, *tmp;
> +	struct iommu_sva_param *param =3D dev->iommu_param->sva_param;
> +
> +	if (!domain->ops->mm_attach || !domain->ops->mm_detach)
> +		return -ENODEV;
> +
> +	if (pasid > param->max_pasid || pasid < param->min_pasid)
> +		return -ERANGE;
> +
> +	bond =3D kzalloc(sizeof(*bond), GFP_KERNEL);
> +	if (!bond)
> +		return -ENOMEM;
> +
> +	bond->domain		=3D domain;
> +	bond->io_mm		=3D io_mm;
> +	bond->dev		=3D dev;
> +	bond->drvdata		=3D drvdata;
> +
> +	spin_lock(&iommu_sva_lock);
> +	/*
> +	 * Check if this io_mm is already bound to the domain. In which case the
> +	 * IOMMU driver doesn't have to install the PASID table entry.
> +	 */
> +	list_for_each_entry(tmp, &domain->mm_list, domain_head) {
> +		if (tmp->io_mm =3D=3D io_mm) {
> +			attach_domain =3D false;
> +			break;
> +		}
> +	}
> +
> +	ret =3D domain->ops->mm_attach(domain, dev, io_mm, attach_domain);
> +	if (ret) {
> +		kfree(bond);
> +		spin_unlock(&iommu_sva_lock);
> +		return ret;
> +	}
> +
> +	list_add(&bond->mm_head, &io_mm->devices);
> +	list_add(&bond->domain_head, &domain->mm_list);
> +	list_add(&bond->dev_head, &param->mm_list);
> +	spin_unlock(&iommu_sva_lock);
> +
> +	return 0;
> +}
> +
> +static void io_mm_detach_locked(struct iommu_bond *bond)
> +{
> +	struct iommu_bond *tmp;
> +	bool detach_domain =3D true;
> +	struct iommu_domain *domain =3D bond->domain;
> +
> +	list_for_each_entry(tmp, &domain->mm_list, domain_head) {
> +		if (tmp->io_mm =3D=3D bond->io_mm && tmp->dev !=3D bond->dev) {
> +			detach_domain =3D false;
> +			break;
> +		}
> +	}
> +
> +	domain->ops->mm_detach(domain, bond->dev, bond->io_mm, detach_domain);
> +

I can't see an immediate reason to have a different order in her to the rev=
erse of
the attach above.   So I think you should be detaching after the list_del c=
alls.
If there is a reason, can we have a comment so I don't ask on v10.

> +	list_del(&bond->mm_head);
> +	list_del(&bond->domain_head);
> +	list_del(&bond->dev_head);
> +	io_mm_put_locked(bond->io_mm);
> +
> +	kfree(bond);
> +}
> =20
>  /**
>   * iommu_sva_device_init() - Initialize Shared Virtual Addressing for a =
device
> @@ -47,6 +337,7 @@ int iommu_sva_device_init(struct device *dev, unsigned=
 long features,
> =20
>  	param->features		=3D features;
>  	param->max_pasid	=3D max_pasid;
> +	INIT_LIST_HEAD(&param->mm_list);
> =20
>  	/*
>  	 * IOMMU driver updates the limits depending on the IOMMU and device
> @@ -114,13 +405,87 @@ EXPORT_SYMBOL_GPL(iommu_sva_device_shutdown);
>  int __iommu_sva_bind_device(struct device *dev, struct mm_struct *mm,
>  			    int *pasid, unsigned long flags, void *drvdata)
>  {
> -	return -ENOSYS; /* TODO */
> +	int i, ret =3D 0;
> +	struct io_mm *io_mm =3D NULL;
> +	struct iommu_domain *domain;
> +	struct iommu_bond *bond =3D NULL, *tmp;
> +	struct iommu_sva_param *param =3D dev->iommu_param->sva_param;
> +
> +	domain =3D iommu_get_domain_for_dev(dev);
> +	if (!domain)
> +		return -EINVAL;
> +
> +	/*
> +	 * The device driver does not call sva_device_init/shutdown and
> +	 * bind/unbind concurrently, so no need to take the param lock.
> +	 */
> +	if (WARN_ON_ONCE(!param) || (flags & ~param->features))
> +		return -EINVAL;
> +
> +	/* If an io_mm already exists, use it */
> +	spin_lock(&iommu_sva_lock);
> +	idr_for_each_entry(&iommu_pasid_idr, io_mm, i) {
> +		if (io_mm->mm =3D=3D mm && io_mm_get_locked(io_mm)) {
> +			/* ... Unless it's already bound to this device */
> +			list_for_each_entry(tmp, &io_mm->devices, mm_head) {
> +				if (tmp->dev =3D=3D dev) {
> +					bond =3D tmp;

Using bond for this is clear in a sense, but can we not just use ret
so it is obvious here that we are going to return -EEXIST?
At first glance I thought you were going to carry on with this bond
and couldn't work out why it would ever make sense to have two bonds
between a device an an io_mm (which it doesn't!)

> +					io_mm_put_locked(io_mm);
> +					break;
> +				}
> +			}
> +			break;
> +		}
> +	}
> +	spin_unlock(&iommu_sva_lock);
> +
> +	if (bond)
> +		return -EEXIST;
> +
> +	/* Require identical features within an io_mm for now */
> +	if (io_mm && (flags !=3D io_mm->flags)) {
> +		io_mm_put(io_mm);
> +		return -EDOM;
> +	}
> +
> +	if (!io_mm) {
> +		io_mm =3D io_mm_alloc(domain, dev, mm, flags);
> +		if (IS_ERR(io_mm))
> +			return PTR_ERR(io_mm);
> +	}
> +
> +	ret =3D io_mm_attach(domain, dev, io_mm, drvdata);
> +	if (ret)
> +		io_mm_put(io_mm);
> +	else
> +		*pasid =3D io_mm->pasid;
> +
> +	return ret;
>  }
>  EXPORT_SYMBOL_GPL(__iommu_sva_bind_device);
> =20
>  int __iommu_sva_unbind_device(struct device *dev, int pasid)
>  {
> -	return -ENOSYS; /* TODO */
> +	int ret =3D -ESRCH;
> +	struct iommu_domain *domain;
> +	struct iommu_bond *bond =3D NULL;
> +	struct iommu_sva_param *param =3D dev->iommu_param->sva_param;
> +
> +	domain =3D iommu_get_domain_for_dev(dev);
> +	if (!param || WARN_ON(!domain))
> +		return -EINVAL;
> +
> +	spin_lock(&iommu_sva_lock);
> +	list_for_each_entry(bond, &param->mm_list, dev_head) {
> +		if (bond->io_mm->pasid =3D=3D pasid) {
> +			io_mm_detach_locked(bond);
> +			ret =3D 0;
> +			break;
> +		}
> +	}
> +	spin_unlock(&iommu_sva_lock);
> +
> +	return ret;
>  }
>  EXPORT_SYMBOL_GPL(__iommu_sva_unbind_device);
> =20
> @@ -132,6 +497,15 @@ EXPORT_SYMBOL_GPL(__iommu_sva_unbind_device);
>   */
>  void __iommu_sva_unbind_dev_all(struct device *dev)
>  {
> -	/* TODO */
> +	struct iommu_sva_param *param;
> +	struct iommu_bond *bond, *next;
> +
> +	param =3D dev->iommu_param->sva_param;
> +	if (param) {
> +		spin_lock(&iommu_sva_lock);
> +		list_for_each_entry_safe(bond, next, &param->mm_list, dev_head)
> +			io_mm_detach_locked(bond);
> +		spin_unlock(&iommu_sva_lock);
> +	}
>  }
>  EXPORT_SYMBOL_GPL(__iommu_sva_unbind_dev_all);
> diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
> index bd2819deae5b..333801e1519c 100644
> --- a/drivers/iommu/iommu.c
> +++ b/drivers/iommu/iommu.c
> @@ -1463,6 +1463,7 @@ static struct iommu_domain *__iommu_domain_alloc(st=
ruct bus_type *bus,
>  	domain->type =3D type;
>  	/* Assume all sizes by default; the driver may override this later */
>  	domain->pgsize_bitmap  =3D bus->iommu_ops->pgsize_bitmap;
> +	INIT_LIST_HEAD(&domain->mm_list);
> =20
>  	return domain;
>  }
> diff --git a/include/linux/iommu.h b/include/linux/iommu.h
> index da59c20c4f12..d5f21719a5a0 100644
> --- a/include/linux/iommu.h
> +++ b/include/linux/iommu.h
> @@ -100,6 +100,20 @@ struct iommu_domain {
>  	void *handler_token;
>  	struct iommu_domain_geometry geometry;
>  	void *iova_cookie;
> +
> +	struct list_head mm_list;
> +};
> +
> +struct io_mm {
> +	int			pasid;
> +	/* IOMMU_SVA_FEAT_* */
> +	unsigned long		flags;
> +	struct list_head	devices;
> +	struct kref		kref;
> +	struct mm_struct	*mm;
> +
> +	/* Release callback for this mm */
> +	void (*release)(struct io_mm *io_mm);
>  };
> =20
>  enum iommu_cap {
> @@ -216,6 +230,7 @@ struct iommu_sva_param {
>  	unsigned long features;
>  	unsigned int min_pasid;
>  	unsigned int max_pasid;
> +	struct list_head mm_list;
>  };
> =20
>  /**
> @@ -227,6 +242,11 @@ struct iommu_sva_param {
>   * @detach_dev: detach device from an iommu domain
>   * @sva_device_init: initialize Shared Virtual Adressing for a device
>   * @sva_device_shutdown: shutdown Shared Virtual Adressing for a device
> + * @mm_alloc: allocate io_mm
> + * @mm_free: free io_mm
> + * @mm_attach: attach io_mm to a device. Install PASID entry if necessary
> + * @mm_detach: detach io_mm from a device. Remove PASID entry and
> + *             flush associated TLB entries.
>   * @map: map a physically contiguous memory region to an iommu domain
>   * @unmap: unmap a physically contiguous memory region from an iommu dom=
ain
>   * @map_sg: map a scatter-gather list of physically contiguous memory ch=
unks
> @@ -268,6 +288,14 @@ struct iommu_ops {
>  			       struct iommu_sva_param *param);
>  	void (*sva_device_shutdown)(struct device *dev,
>  				    struct iommu_sva_param *param);
> +	struct io_mm *(*mm_alloc)(struct iommu_domain *domain,
> +				  struct mm_struct *mm,
> +				  unsigned long flags);
> +	void (*mm_free)(struct io_mm *io_mm);
> +	int (*mm_attach)(struct iommu_domain *domain, struct device *dev,
> +			 struct io_mm *io_mm, bool attach_domain);
> +	void (*mm_detach)(struct iommu_domain *domain, struct device *dev,
> +			  struct io_mm *io_mm, bool detach_domain);
>  	int (*map)(struct iommu_domain *domain, unsigned long iova,
>  		   phys_addr_t paddr, size_t size, int prot);
>  	size_t (*unmap)(struct iommu_domain *domain, unsigned long iova,
