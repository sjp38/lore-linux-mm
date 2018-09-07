Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 538D78E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 17:23:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 186-v6so7676224pgc.12
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 14:23:22 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id h4-v6si9413384pgc.429.2018.09.07.14.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 14:23:20 -0700 (PDT)
Date: Fri, 7 Sep 2018 14:25:04 -0700
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
Message-ID: <20180907142504.5034351e@jacob-builder>
In-Reply-To: <5bbc0332-b94b-75cc-ca42-a9b196811daf@amd.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-2-jean-philippe.brucker@arm.com>
	<bf42affd-e9d0-e4fc-6d28-f3c3f7795348@redhat.com>
	<03d31ba5-1eda-ea86-8c0c-91d14c86fe83@arm.com>
	<ed39159c-087e-7e56-7d29-d1de9fa1677f@amd.com>
	<f0b317d5-e2e9-5478-952c-05e8b97bd68b@arm.com>
	<2fd4a0a1-1a35-bf82-df84-b995cce011d9@amd.com>
	<65e7accd-4446-19f5-c667-c6407e89cfa6@arm.com>
	<5bbc0332-b94b-75cc-ca42-a9b196811daf@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?UTF-8?B?S8O2bmln?= <christian.koenig@amd.com>
Cc: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, Auger Eric <eric.auger@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "tn@semihalf.com" <tn@semihalf.com>, "joro@8bytes.org" <joro@8bytes.org>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, Robin Murphy <Robin.Murphy@arm.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, jacob.jun.pan@linux.intel.com

On Fri, 7 Sep 2018 20:02:54 +0200
Christian K=C3=B6nig <christian.koenig@amd.com> wrote:

> Am 07.09.2018 um 17:45 schrieb Jean-Philippe Brucker:
> > On 07/09/2018 09:55, Christian K=C3=B6nig wrote: =20
> >> I will take this as an opportunity to summarize some of the
> >> requirements we have for PASID management from the amdgpu driver
> >> point of view: =20
> > That's incredibly useful, thanks :)
> > =20
> >> 1. We need to be able to allocate PASID between 1 and some
> >> maximum. Zero is reserved as far as I know, but we don't necessary
> >> need a minimum. =20
>  [...] =20
> >> 2. We need to be able to allocate PASIDs without a process address
> >> space backing it. E.g. our hardware uses PASIDs even without
> >> Shared Virtual Addressing enabled to distinct clients from each
> >> other. Would be a pity if we need to still have a separate PASID
> >> handling because the system wide is only available when IOMMU is
> >> turned on. =20
>  [...] =20
>=20
> I agree on that.
>=20
> > iommu-sva expects everywhere that the device has an iommu_domain,
> > it's the first thing we check on entry. Bypassing all of this would
> > call idr_alloc() directly, and wouldn't have any code in common
> > with the current iommu-sva. So it seems like you need a layer on
> > top of iommu-sva calling idr_alloc() when an IOMMU isn't present,
> > but I don't think it should be in drivers/iommu/ =20
>=20
> In this case I question if the PASID handling should be under=20
> drivers/iommu at all.
>=20
> See I can have a mix of VM context which are bound to processes (some=20
> few) and VM contexts which are standalone and doesn't care for a
> process address space. But for each VM context I need a distinct
> PASID for the hardware to work.
>=20
> I can live if we say if IOMMU is completely disabled we use a simple
> ida to allocate them, but when IOMMU is enabled I certainly need a
> way to reserve a PASID without an associated process.
>=20
VT-d would also have such requirement. There is a virtual command
register for allocate and free PASID for VM use. When that PASID
allocation request gets propagated to the host IOMMU driver, we need to
allocate PASID w/o mm.

If the PASID allocation is done via VFIO, can we have FD to track PASID
life cycle instead of mm_exit()? i.e. all FDs get closed before
mm_exit, I assume?

> >> 3. Even after destruction of a process address space we need some
> >> grace period before a PASID is reused because it can be that the
> >> specific PASID is still in some hardware queues etc...
> >>   =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 At bare minimum all device dri=
vers using process binding
> >> need to explicitly note to the core when they are done with a
> >> PASID. =20
> > Right, much of the horribleness in iommu-sva deals with this:
> >
> > The process dies, iommu-sva is notified and calls the mm_exit()
> > function passed by the device driver to iommu_sva_device_init(). In
> > mm_exit() the device driver needs to clear any reference to the
> > PASID in hardware and in its own structures. When the device driver
> > returns from mm_exit(), it effectively tells the core that it has
> > finished using the PASID, and iommu-sva can reuse the PASID for
> > another process. mm_exit() is allowed to block, so the device
> > driver has time to clean up and flush the queues.
> >
> > If the device driver finishes using the PASID before the process
> > exits, it just calls unbind(). =20
>=20
> Exactly that's what Michal Hocko is probably going to not like at all.
>=20
> Can we have a different approach where each driver is informed by the=20
> mm_exit(), but needs to explicitly call unbind() before a PASID is
> reused?
>=20
> During that teardown transition it would be ideal if that PASID only=20
> points to a dummy root page directory with only invalid entries.
>=20
I guess this can be vendor specific, In VT-d I plan to mark PASID
entry not present and disable fault reporting while draining remaining
activities.

> > =20
> >> 4. It would be nice to have to be able to set a "void *" for each
> >> PASID/device combination while binding to a process which then can
> >> be queried later on based on the PASID.
> >>   =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 E.g. when you have a per PASID=
/device structure around
> >> anyway, just add an extra field. =20
> > iommu_sva_bind_device() takes a "drvdata" pointer that is stored
> > internally for the PASID/device combination (iommu_bond). It is
> > passed to mm_exit(), but I haven't added anything for the device
> > driver to query it back. =20
>=20
> Nice! Looks like all we need additionally is a function to retrieve
> that based on the PASID.
>=20
> >> 5. It would be nice to have to allocate multiple PASIDs for the
> >> same process address space.
> >>   =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 E.g. some teams at AMD want to=
 use a separate GPU
> >> address space for their userspace client library. I'm still trying
> >> to avoid that, but it is perfectly possible that we are going to
> >> need that. =20
> > Two PASIDs pointing to the same process pgd? At first glance it
> > seems feasible, maybe with a flag passed to bind() and a few
> > changes to internal structures. It will duplicate ATC invalidation
> > commands for each process address space change (munmap etc) so you
> > might take a performance hit.
> >
> > Intel's SVM code has the SVM_FLAG_PRIVATE_PASID which seems similar
> > to what you describe, but I don't plan to support it in this series
> > (the io_mm model is already pretty complicated). I think it can be
> > added without too much effort in a future series, though with a
> > different flag name since we'd like to use "private PASID" for
> > something else
> > (https://www.spinics.net/lists/dri-devel/msg177007.html). =20
>=20
> To be honest I hoped that you would say: No never! So that I have a
> good argument to pushback on such requirements :)
>=20
> But if it's doable it would be at least nice to have for debugging.
>=20
> Thanks a lot for working on that,
> Christian.
>=20
> >
> > Thanks,
> > Jean
> > =20
> >>   =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 Additional to that it is somet=
imes quite useful for
> >> debugging to isolate where exactly an incorrect access (segfault)
> >> is coming from.
> >>
> >> Let me know if there are some problems with that, especially I
> >> want to know if there is pushback on #5 so that I can forward
> >> that :)
> >>
> >> Thanks,
> >> Christian.
> >> =20
> >>> Thanks,
> >>> Jean =20
>=20

[Jacob Pan]
