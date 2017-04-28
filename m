Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCA556B02F2
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 13:34:38 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k46so14831791qtf.21
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 10:34:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q62si6387212qtd.4.2017.04.28.10.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 10:34:37 -0700 (PDT)
Date: Fri, 28 Apr 2017 13:34:35 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com>
In-Reply-To: <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com> <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

> Kirill points out that the calls to {get,put}_dev_pagemap() can be
> removed from the mm fast path if we take a single get_dev_pagemap()
> reference to signify that the page is alive and use the final put of the
> page to drop that reference.
>=20
> This does require some care to make sure that any waits for the
> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
> since it now maintains its own elevated reference.

This is NAK from HMM point of view as i need those call. So if you remove
them now i will need to add them back as part of HMM.

Cheers,
J=C3=A9r=C3=B4me

>=20
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> Suggested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> Changes in v2:
> * Rebased to tip/master
> * Clarified comment in __put_page
> * Clarified devm_memremap_pages() kernel doc about ordering of
>   devm_memremap_pages_release() vs percpu_ref_kill() vs wait for
>   percpu_ref to drop to zero.
>=20
> Ingo, I retested this with a revert of commit 6dd29b3df975 "Revert
> 'x86/mm/gup: Switch GUP to the generic get_user_page_fast()
> implementation'". It should be good to go through x86/mm.
>=20
>  drivers/dax/pmem.c    |    2 +-
>  drivers/nvdimm/pmem.c |   13 +++++++++++--
>  include/linux/mm.h    |   14 --------------
>  kernel/memremap.c     |   22 +++++++++-------------
>  mm/swap.c             |   10 ++++++++++
>  5 files changed, 31 insertions(+), 30 deletions(-)
>=20
> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
> index 033f49b31fdc..cb0d742fa23f 100644
> --- a/drivers/dax/pmem.c
> +++ b/drivers/dax/pmem.c
> @@ -43,6 +43,7 @@ static void dax_pmem_percpu_exit(void *data)
>  =09struct dax_pmem *dax_pmem =3D to_dax_pmem(ref);
> =20
>  =09dev_dbg(dax_pmem->dev, "%s\n", __func__);
> +=09wait_for_completion(&dax_pmem->cmp);
>  =09percpu_ref_exit(ref);
>  }
> =20
> @@ -53,7 +54,6 @@ static void dax_pmem_percpu_kill(void *data)
> =20
>  =09dev_dbg(dax_pmem->dev, "%s\n", __func__);
>  =09percpu_ref_kill(ref);
> -=09wait_for_completion(&dax_pmem->cmp);
>  }
> =20
>  static int dax_pmem_probe(struct device *dev)
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 5b536be5a12e..fb7bbc79ac26 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -25,6 +25,7 @@
>  #include <linux/badblocks.h>
>  #include <linux/memremap.h>
>  #include <linux/vmalloc.h>
> +#include <linux/blk-mq.h>
>  #include <linux/pfn_t.h>
>  #include <linux/slab.h>
>  #include <linux/pmem.h>
> @@ -231,6 +232,11 @@ static void pmem_release_queue(void *q)
>  =09blk_cleanup_queue(q);
>  }
> =20
> +static void pmem_freeze_queue(void *q)
> +{
> +=09blk_mq_freeze_queue_start(q);
> +}
> +
>  static void pmem_release_disk(void *disk)
>  {
>  =09del_gendisk(disk);
> @@ -284,6 +290,9 @@ static int pmem_attach_disk(struct device *dev,
>  =09if (!q)
>  =09=09return -ENOMEM;
> =20
> +=09if (devm_add_action_or_reset(dev, pmem_release_queue, q))
> +=09=09return -ENOMEM;
> +
>  =09pmem->pfn_flags =3D PFN_DEV;
>  =09if (is_nd_pfn(dev)) {
>  =09=09addr =3D devm_memremap_pages(dev, &pfn_res, &q->q_usage_counter,
> @@ -303,10 +312,10 @@ static int pmem_attach_disk(struct device *dev,
>  =09=09=09=09pmem->size, ARCH_MEMREMAP_PMEM);
> =20
>  =09/*
> -=09 * At release time the queue must be dead before
> +=09 * At release time the queue must be frozen before
>  =09 * devm_memremap_pages is unwound
>  =09 */
> -=09if (devm_add_action_or_reset(dev, pmem_release_queue, q))
> +=09if (devm_add_action_or_reset(dev, pmem_freeze_queue, q))
>  =09=09return -ENOMEM;
> =20
>  =09if (IS_ERR(addr))
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a835edd2db34..695da2a19b4c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -762,19 +762,11 @@ static inline enum zone_type page_zonenum(const str=
uct
> page *page)
>  }
> =20
>  #ifdef CONFIG_ZONE_DEVICE
> -void get_zone_device_page(struct page *page);
> -void put_zone_device_page(struct page *page);
>  static inline bool is_zone_device_page(const struct page *page)
>  {
>  =09return page_zonenum(page) =3D=3D ZONE_DEVICE;
>  }
>  #else
> -static inline void get_zone_device_page(struct page *page)
> -{
> -}
> -static inline void put_zone_device_page(struct page *page)
> -{
> -}
>  static inline bool is_zone_device_page(const struct page *page)
>  {
>  =09return false;
> @@ -790,9 +782,6 @@ static inline void get_page(struct page *page)
>  =09 */
>  =09VM_BUG_ON_PAGE(page_ref_count(page) <=3D 0, page);
>  =09page_ref_inc(page);
> -
> -=09if (unlikely(is_zone_device_page(page)))
> -=09=09get_zone_device_page(page);
>  }
> =20
>  static inline void put_page(struct page *page)
> @@ -801,9 +790,6 @@ static inline void put_page(struct page *page)
> =20
>  =09if (put_page_testzero(page))
>  =09=09__put_page(page);
> -
> -=09if (unlikely(is_zone_device_page(page)))
> -=09=09put_zone_device_page(page);
>  }
> =20
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 07e85e5229da..23a6483c3666 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -182,18 +182,6 @@ struct page_map {
>  =09struct vmem_altmap altmap;
>  };
> =20
> -void get_zone_device_page(struct page *page)
> -{
> -=09percpu_ref_get(page->pgmap->ref);
> -}
> -EXPORT_SYMBOL(get_zone_device_page);
> -
> -void put_zone_device_page(struct page *page)
> -{
> -=09put_dev_pagemap(page->pgmap);
> -}
> -EXPORT_SYMBOL(put_zone_device_page);
> -
>  static void pgmap_radix_release(struct resource *res)
>  {
>  =09resource_size_t key, align_start, align_size, align_end;
> @@ -237,6 +225,10 @@ static void devm_memremap_pages_release(struct devic=
e
> *dev, void *data)
>  =09struct resource *res =3D &page_map->res;
>  =09resource_size_t align_start, align_size;
>  =09struct dev_pagemap *pgmap =3D &page_map->pgmap;
> +=09unsigned long pfn;
> +
> +=09for_each_device_pfn(pfn, page_map)
> +=09=09put_page(pfn_to_page(pfn));
> =20
>  =09if (percpu_ref_tryget_live(pgmap->ref)) {
>  =09=09dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
> @@ -277,7 +269,10 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t
> phys)
>   *
>   * Notes:
>   * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages=
()
>   time
> - *    (or devm release event).
> + *    (or devm release event). The expected order of events is that @ref=
 has
> + *    been through percpu_ref_kill() before devm_memremap_pages_release(=
).
> The
> + *    wait for the completion of all references being dropped and
> + *    percpu_ref_exit() must occur after devm_memremap_pages_release().
>   *
>   * 2/ @res is expected to be a host memory range that could feasibly be
>   *    treated as a "System RAM" range, i.e. not a device mmio range, but
> @@ -379,6 +374,7 @@ void *devm_memremap_pages(struct device *dev, struct
> resource *res,
>  =09=09 */
>  =09=09list_del(&page->lru);
>  =09=09page->pgmap =3D pgmap;
> +=09=09percpu_ref_get(ref);
>  =09}
>  =09devres_add(dev, page_map);
>  =09return __va(res->start);
> diff --git a/mm/swap.c b/mm/swap.c
> index 5dabf444d724..d8d9ee9e311a 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -97,6 +97,16 @@ static void __put_compound_page(struct page *page)
> =20
>  void __put_page(struct page *page)
>  {
> +=09if (is_zone_device_page(page)) {
> +=09=09put_dev_pagemap(page->pgmap);
> +
> +=09=09/*
> +=09=09 * The page belongs to the device that created pgmap. Do
> +=09=09 * not return it to page allocator.
> +=09=09 */
> +=09=09return;
> +=09}
> +
>  =09if (unlikely(PageCompound(page)))
>  =09=09__put_compound_page(page);
>  =09else
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
