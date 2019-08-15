Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BB0FC41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:43:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB2EC2084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:43:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB2EC2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8ADFE6B02FD; Thu, 15 Aug 2019 13:43:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85FDC6B02FE; Thu, 15 Aug 2019 13:43:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74DE96B02FF; Thu, 15 Aug 2019 13:43:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4F06B02FD
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:43:15 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 029908248AB4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:43:15 +0000 (UTC)
X-FDA: 75825383550.24.tax90_90ba4d3927724
X-HE-Tag: tax90_90ba4d3927724
X-Filterd-Recvd-Size: 13938
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:43:14 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A6AC33083363;
	Thu, 15 Aug 2019 17:43:13 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9B3F017CF8;
	Thu, 15 Aug 2019 17:43:12 +0000 (UTC)
Date: Thu, 15 Aug 2019 13:43:10 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: nouveau@lists.freedesktop.org, linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
	Jason Gunthorpe <jgg@mellanox.com>, amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@lst.de>, Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [Nouveau] [PATCH] nouveau/hmm: map pages after migration
Message-ID: <20190815174310.GI30916@redhat.com>
References: <20190807150214.3629-1-rcampbell@nvidia.com>
 <20190813215852.GA9823@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190813215852.GA9823@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 15 Aug 2019 17:43:13 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 05:58:52PM -0400, Jerome Glisse wrote:
> On Wed, Aug 07, 2019 at 08:02:14AM -0700, Ralph Campbell wrote:
> > When memory is migrated to the GPU it is likely to be accessed by GPU
> > code soon afterwards. Instead of waiting for a GPU fault, map the
> > migrated memory into the GPU page tables with the same access permiss=
ions
> > as the source CPU page table entries. This preserves copy on write
> > semantics.
> >=20
> > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> > Cc: Ben Skeggs <bskeggs@redhat.com>
>=20
> Sorry for delay i am swamp, couple issues:
>     - nouveau_pfns_map() is never call, it should be call after
>       the dma copy is done (iirc it is lacking proper fencing
>       so that would need to be implemented first)
>=20
>     - the migrate ioctl is disconnected from the svm part and
>       thus we would need first to implement svm reference counting
>       and take a reference at begining of migration process and
>       release it at the end ie struct nouveau_svmm needs refcounting
>       of some sort. I let Ben decides what he likes best for that.

Thinking more about that the svm lifetime is bound to the file
descriptor on the device driver file held by the process. So
when you call migrate ioctl the svm should not go away because
you are in an ioctl against the file descriptor. I need to double
check all that in respect of process that open the device file
multiple time with different file descriptor (or fork thing and
all).


>     - i rather not have an extra pfns array, i am pretty sure we
>       can directly feed what we get from the dma array to the svm
>       code to update the GPU page table
>=20
> Observation that can be delayed to latter patches:
>     - i do not think we want to map directly if the dma engine
>       is queue up and thus if the fence will take time to signal
>=20
>       This is why i did not implement this in the first place.
>       Maybe using a workqueue to schedule a pre-fill of the GPU
>       page table and wakeup the workqueue with the fence notify
>       event.
>=20
>=20
> > ---
> >=20
> > This patch is based on top of Christoph Hellwig's 9 patch series
> > https://lore.kernel.org/linux-mm/20190729234611.GC7171@redhat.com/T/#=
u
> > "turn the hmm migrate_vma upside down" but without patch 9
> > "mm: remove the unused MIGRATE_PFN_WRITE" and adds a use for the flag=
.
> >=20
> >=20
> >  drivers/gpu/drm/nouveau/nouveau_dmem.c | 45 +++++++++-----
> >  drivers/gpu/drm/nouveau/nouveau_svm.c  | 86 ++++++++++++++++++++++++=
++
> >  drivers/gpu/drm/nouveau/nouveau_svm.h  | 19 ++++++
> >  3 files changed, 133 insertions(+), 17 deletions(-)
> >=20
> > diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm=
/nouveau/nouveau_dmem.c
> > index ef9de82b0744..c83e6f118817 100644
> > --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> > +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> > @@ -25,11 +25,13 @@
> >  #include "nouveau_dma.h"
> >  #include "nouveau_mem.h"
> >  #include "nouveau_bo.h"
> > +#include "nouveau_svm.h"
> > =20
> >  #include <nvif/class.h>
> >  #include <nvif/object.h>
> >  #include <nvif/if500b.h>
> >  #include <nvif/if900b.h>
> > +#include <nvif/if000c.h>
> > =20
> >  #include <linux/sched/mm.h>
> >  #include <linux/hmm.h>
> > @@ -560,11 +562,12 @@ nouveau_dmem_init(struct nouveau_drm *drm)
> >  }
> > =20
> >  static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_dr=
m *drm,
> > -		struct vm_area_struct *vma, unsigned long addr,
> > -		unsigned long src, dma_addr_t *dma_addr)
> > +		struct vm_area_struct *vma, unsigned long src,
> > +		dma_addr_t *dma_addr, u64 *pfn)
> >  {
> >  	struct device *dev =3D drm->dev->dev;
> >  	struct page *dpage, *spage;
> > +	unsigned long paddr;
> > =20
> >  	spage =3D migrate_pfn_to_page(src);
> >  	if (!spage || !(src & MIGRATE_PFN_MIGRATE))
> > @@ -572,17 +575,21 @@ static unsigned long nouveau_dmem_migrate_copy_=
one(struct nouveau_drm *drm,
> > =20
> >  	dpage =3D nouveau_dmem_page_alloc_locked(drm);
> >  	if (!dpage)
> > -		return 0;
> > +		goto out;
> > =20
> >  	*dma_addr =3D dma_map_page(dev, spage, 0, PAGE_SIZE, DMA_BIDIRECTIO=
NAL);
> >  	if (dma_mapping_error(dev, *dma_addr))
> >  		goto out_free_page;
> > =20
> > +	paddr =3D nouveau_dmem_page_addr(dpage);
> >  	if (drm->dmem->migrate.copy_func(drm, 1, NOUVEAU_APER_VRAM,
> > -			nouveau_dmem_page_addr(dpage), NOUVEAU_APER_HOST,
> > -			*dma_addr))
> > +			paddr, NOUVEAU_APER_HOST, *dma_addr))
> >  		goto out_dma_unmap;
> > =20
> > +	*pfn =3D NVIF_VMM_PFNMAP_V0_V | NVIF_VMM_PFNMAP_V0_VRAM |
> > +		((paddr >> PAGE_SHIFT) << NVIF_VMM_PFNMAP_V0_ADDR_SHIFT);
> > +	if (src & MIGRATE_PFN_WRITE)
> > +		*pfn |=3D NVIF_VMM_PFNMAP_V0_W;
> >  	return migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
> > =20
> >  out_dma_unmap:
> > @@ -590,18 +597,19 @@ static unsigned long nouveau_dmem_migrate_copy_=
one(struct nouveau_drm *drm,
> >  out_free_page:
> >  	nouveau_dmem_page_free_locked(drm, dpage);
> >  out:
> > +	*pfn =3D NVIF_VMM_PFNMAP_V0_NONE;
> >  	return 0;
> >  }
> > =20
> >  static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
> > -		struct nouveau_drm *drm, dma_addr_t *dma_addrs)
> > +		struct nouveau_drm *drm, dma_addr_t *dma_addrs, u64 *pfns)
> >  {
> >  	struct nouveau_fence *fence;
> >  	unsigned long addr =3D args->start, nr_dma =3D 0, i;
> > =20
> >  	for (i =3D 0; addr < args->end; i++) {
> >  		args->dst[i] =3D nouveau_dmem_migrate_copy_one(drm, args->vma,
> > -				addr, args->src[i], &dma_addrs[nr_dma]);
> > +				args->src[i], &dma_addrs[nr_dma], &pfns[i]);
> >  		if (args->dst[i])
> >  			nr_dma++;
> >  		addr +=3D PAGE_SIZE;
> > @@ -615,10 +623,6 @@ static void nouveau_dmem_migrate_chunk(struct mi=
grate_vma *args,
> >  		dma_unmap_page(drm->dev->dev, dma_addrs[nr_dma], PAGE_SIZE,
> >  				DMA_BIDIRECTIONAL);
> >  	}
> > -	/*
> > -	 * FIXME optimization: update GPU page table to point to newly migr=
ated
> > -	 * memory.
> > -	 */
> >  	migrate_vma_finalize(args);
> >  }
> > =20
> > @@ -631,11 +635,12 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *dr=
m,
> >  	unsigned long npages =3D (end - start) >> PAGE_SHIFT;
> >  	unsigned long max =3D min(SG_MAX_SINGLE_ALLOC, npages);
> >  	dma_addr_t *dma_addrs;
> > +	u64 *pfns;
> >  	struct migrate_vma args =3D {
> >  		.vma		=3D vma,
> >  		.start		=3D start,
> >  	};
> > -	unsigned long c, i;
> > +	unsigned long i;
> >  	int ret =3D -ENOMEM;
> > =20
> >  	args.src =3D kcalloc(max, sizeof(args.src), GFP_KERNEL);
> > @@ -649,19 +654,25 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *dr=
m,
> >  	if (!dma_addrs)
> >  		goto out_free_dst;
> > =20
> > -	for (i =3D 0; i < npages; i +=3D c) {
> > -		c =3D min(SG_MAX_SINGLE_ALLOC, npages);
> > -		args.end =3D start + (c << PAGE_SHIFT);
> > +	pfns =3D nouveau_pfns_alloc(max);
> > +	if (!pfns)
> > +		goto out_free_dma;
> > +
> > +	for (i =3D 0; i < npages; i +=3D max) {
> > +		args.end =3D start + (max << PAGE_SHIFT);
> >  		ret =3D migrate_vma_setup(&args);
> >  		if (ret)
> > -			goto out_free_dma;
> > +			goto out_free_pfns;
> > =20
> >  		if (args.cpages)
> > -			nouveau_dmem_migrate_chunk(&args, drm, dma_addrs);
> > +			nouveau_dmem_migrate_chunk(&args, drm, dma_addrs,
> > +						   pfns);
> >  		args.start =3D args.end;
> >  	}
> > =20
> >  	ret =3D 0;
> > +out_free_pfns:
> > +	nouveau_pfns_free(pfns);
> >  out_free_dma:
> >  	kfree(dma_addrs);
> >  out_free_dst:
> > diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/=
nouveau/nouveau_svm.c
> > index a74530b5a523..3e6d7f226576 100644
> > --- a/drivers/gpu/drm/nouveau/nouveau_svm.c
> > +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> > @@ -70,6 +70,12 @@ struct nouveau_svm {
> >  #define SVM_DBG(s,f,a...) NV_DEBUG((s)->drm, "svm: "f"\n", ##a)
> >  #define SVM_ERR(s,f,a...) NV_WARN((s)->drm, "svm: "f"\n", ##a)
> > =20
> > +struct nouveau_pfnmap_args {
> > +	struct nvif_ioctl_v0 i;
> > +	struct nvif_ioctl_mthd_v0 m;
> > +	struct nvif_vmm_pfnmap_v0 p;
> > +};
> > +
> >  struct nouveau_ivmm {
> >  	struct nouveau_svmm *svmm;
> >  	u64 inst;
> > @@ -734,6 +740,86 @@ nouveau_svm_fault(struct nvif_notify *notify)
> >  	return NVIF_NOTIFY_KEEP;
> >  }
> > =20
> > +static inline struct nouveau_pfnmap_args *
> > +nouveau_pfns_to_args(void *pfns)
> > +{
> > +	struct nvif_vmm_pfnmap_v0 *p =3D
> > +		container_of(pfns, struct nvif_vmm_pfnmap_v0, phys);
> > +
> > +	return container_of(p, struct nouveau_pfnmap_args, p);
> > +}
> > +
> > +u64 *
> > +nouveau_pfns_alloc(unsigned long npages)
> > +{
> > +	struct nouveau_pfnmap_args *args;
> > +
> > +	args =3D kzalloc(sizeof(*args) + npages * sizeof(args->p.phys[0]),
> > +			GFP_KERNEL);
> > +	if (!args)
> > +		return NULL;
> > +
> > +	args->i.type =3D NVIF_IOCTL_V0_MTHD;
> > +	args->m.method =3D NVIF_VMM_V0_PFNMAP;
> > +	args->p.page =3D PAGE_SHIFT;
> > +
> > +	return args->p.phys;
> > +}
> > +
> > +void
> > +nouveau_pfns_free(u64 *pfns)
> > +{
> > +	struct nouveau_pfnmap_args *args =3D nouveau_pfns_to_args(pfns);
> > +
> > +	kfree(args);
> > +}
> > +
> > +static struct nouveau_svmm *
> > +nouveau_find_svmm(struct nouveau_svm *svm, struct mm_struct *mm)
> > +{
> > +	struct nouveau_ivmm *ivmm;
> > +
> > +	list_for_each_entry(ivmm, &svm->inst, head) {
> > +		if (ivmm->svmm->mm =3D=3D mm)
> > +			return ivmm->svmm;
> > +	}
> > +	return NULL;
> > +}
> > +
> > +void
> > +nouveau_pfns_map(struct nouveau_drm *drm, struct mm_struct *mm,
> > +		 unsigned long addr, u64 *pfns, unsigned long npages)
> > +{
> > +	struct nouveau_svm *svm =3D drm->svm;
> > +	struct nouveau_svmm *svmm;
> > +	struct nouveau_pfnmap_args *args;
> > +	int ret;
> > +
> > +	if (!svm)
> > +		return;
> > +
> > +	mutex_lock(&svm->mutex);
> > +	svmm =3D nouveau_find_svmm(svm, mm);
> > +	if (!svmm) {
> > +		mutex_unlock(&svm->mutex);
> > +		return;
> > +	}
> > +	mutex_unlock(&svm->mutex);
> > +
> > +	args =3D nouveau_pfns_to_args(pfns);
> > +	args->p.addr =3D addr;
> > +	args->p.size =3D npages << PAGE_SHIFT;
> > +
> > +	mutex_lock(&svmm->mutex);
> > +
> > +	svmm->vmm->vmm.object.client->super =3D true;
> > +	ret =3D nvif_object_ioctl(&svmm->vmm->vmm.object, args, sizeof(*arg=
s) +
> > +				npages * sizeof(args->p.phys[0]), NULL);
> > +	svmm->vmm->vmm.object.client->super =3D false;
> > +
> > +	mutex_unlock(&svmm->mutex);
> > +}
> > +
> >  static void
> >  nouveau_svm_fault_buffer_fini(struct nouveau_svm *svm, int id)
> >  {
> > diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.h b/drivers/gpu/drm/=
nouveau/nouveau_svm.h
> > index e839d8189461..c00c177e51ed 100644
> > --- a/drivers/gpu/drm/nouveau/nouveau_svm.h
> > +++ b/drivers/gpu/drm/nouveau/nouveau_svm.h
> > @@ -18,6 +18,11 @@ void nouveau_svmm_fini(struct nouveau_svmm **);
> >  int nouveau_svmm_join(struct nouveau_svmm *, u64 inst);
> >  void nouveau_svmm_part(struct nouveau_svmm *, u64 inst);
> >  int nouveau_svmm_bind(struct drm_device *, void *, struct drm_file *=
);
> > +
> > +u64 *nouveau_pfns_alloc(unsigned long npages);
> > +void nouveau_pfns_free(u64 *pfns);
> > +void nouveau_pfns_map(struct nouveau_drm *drm, struct mm_struct *mm,
> > +		      unsigned long addr, u64 *pfns, unsigned long npages);
> >  #else /* IS_ENABLED(CONFIG_DRM_NOUVEAU_SVM) */
> >  static inline void nouveau_svm_init(struct nouveau_drm *drm) {}
> >  static inline void nouveau_svm_fini(struct nouveau_drm *drm) {}
> > @@ -44,5 +49,19 @@ static inline int nouveau_svmm_bind(struct drm_dev=
ice *device, void *p,
> >  {
> >  	return -ENOSYS;
> >  }
> > +
> > +u64 *nouveau_pfns_alloc(unsigned long npages)
> > +{
> > +	return NULL;
> > +}
> > +
> > +void nouveau_pfns_free(u64 *pfns)
> > +{
> > +}
> > +
> > +void nouveau_pfns_map(struct nouveau_drm *drm, struct mm_struct *mm,
> > +		      unsigned long addr, u64 *pfns, unsigned long npages)
> > +{
> > +}
> >  #endif /* IS_ENABLED(CONFIG_DRM_NOUVEAU_SVM) */
> >  #endif
> > --=20
> > 2.20.1
> >=20
> _______________________________________________
> Nouveau mailing list
> Nouveau@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/nouveau

