Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 8E3356B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 11:40:17 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <fcde09be-ae34-4f09-a324-825fb2d4fac2@default>
Date: Wed, 25 Apr 2012 08:40:02 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 6/6] zsmalloc: make zsmalloc portable
References: <1335334994-22138-1-git-send-email-minchan@kernel.org>
 <1335334994-22138-7-git-send-email-minchan@kernel.org>
 <4F980AFE.60901@vflare.org>
In-Reply-To: <4F980AFE.60901@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> From: Nitin Gupta [mailto:ngupta@vflare.org]
> Subject: Re: [PATCH 6/6] zsmalloc: make zsmalloc portable
>=20
> On 04/25/2012 02:23 AM, Minchan Kim wrote:
>=20
> > The zsmalloc uses __flush_tlb_one and set_pte.
> > It's very lower functions so that it makes arhcitecture dependency
> > so currently zsmalloc is used by only x86.
> > This patch changes them with map_vm_area and unmap_kernel_range so
> > it should work all architecture.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/staging/zsmalloc/Kconfig         |    4 ----
> >  drivers/staging/zsmalloc/zsmalloc-main.c |   27 +++++++++++++++++-----=
-----
> >  drivers/staging/zsmalloc/zsmalloc_int.h  |    1 -
> >  3 files changed, 17 insertions(+), 15 deletions(-)
> >
> > diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmallo=
c/Kconfig
> > index a5ab720..9084565 100644
> > --- a/drivers/staging/zsmalloc/Kconfig
> > +++ b/drivers/staging/zsmalloc/Kconfig
> > @@ -1,9 +1,5 @@
> >  config ZSMALLOC
> >  =09tristate "Memory allocator for compressed pages"
> > -=09# X86 dependency is because of the use of __flush_tlb_one and set_p=
te
> > -=09# in zsmalloc-main.c.
> > -=09# TODO: convert these to portable functions
> > -=09depends on X86
> >  =09default n
> >  =09help
> >  =09  zsmalloc is a slab-based memory allocator designed to store
> > diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging=
/zsmalloc/zsmalloc-main.c
> > index ff089f8..cc017b1 100644
> > --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> > +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> > @@ -442,7 +442,7 @@ static int zs_cpu_notifier(struct notifier_block *n=
b, unsigned long action,
> >  =09=09area =3D &per_cpu(zs_map_area, cpu);
> >  =09=09if (area->vm)
> >  =09=09=09break;
> > -=09=09area->vm =3D alloc_vm_area(2 * PAGE_SIZE, area->vm_ptes);
> > +=09=09area->vm =3D alloc_vm_area(2 * PAGE_SIZE, NULL);
> >  =09=09if (!area->vm)
> >  =09=09=09return notifier_from_errno(-ENOMEM);
> >  =09=09break;
> > @@ -696,13 +696,22 @@ void *zs_map_object(struct zs_pool *pool, void *h=
andle)
> >  =09} else {
> >  =09=09/* this object spans two pages */
> >  =09=09struct page *nextp;
> > +=09=09struct page *pages[2];
> > +=09=09struct page **page_array =3D &pages[0];
> > +=09=09int err;
> >
> >  =09=09nextp =3D get_next_page(page);
> >  =09=09BUG_ON(!nextp);
> >
> > +=09=09page_array[0] =3D page;
> > +=09=09page_array[1] =3D nextp;
> >
> > -=09=09set_pte(area->vm_ptes[0], mk_pte(page, PAGE_KERNEL));
> > -=09=09set_pte(area->vm_ptes[1], mk_pte(nextp, PAGE_KERNEL));
> > +=09=09/*
> > +=09=09 * map_vm_area never fail because we already allocated
> > +=09=09 * pages for page table in alloc_vm_area.
> > +=09=09 */
> > +=09=09err =3D map_vm_area(area->vm, PAGE_KERNEL, &page_array);
> > +=09=09BUG_ON(err);
> >
> >  =09=09/* We pre-allocated VM area so mapping can never fail */
> >  =09=09area->vm_addr =3D area->vm->addr;
> > @@ -730,14 +739,12 @@ void zs_unmap_object(struct zs_pool *pool, void *=
handle)
> >  =09off =3D obj_idx_to_offset(page, obj_idx, class->size);
> >
> >  =09area =3D &__get_cpu_var(zs_map_area);
> > -=09if (off + class->size <=3D PAGE_SIZE) {
> > +=09if (off + class->size <=3D PAGE_SIZE)
> >  =09=09kunmap_atomic(area->vm_addr);
> > -=09} else {
> > -=09=09set_pte(area->vm_ptes[0], __pte(0));
> > -=09=09set_pte(area->vm_ptes[1], __pte(0));
> > -=09=09__flush_tlb_one((unsigned long)area->vm_addr);
> > -=09=09__flush_tlb_one((unsigned long)area->vm_addr + PAGE_SIZE);
> > -=09}
> > +=09else
> > +=09=09unmap_kernel_range((unsigned long)area->vm->addr,
> > +=09=09=09=09=09PAGE_SIZE * 2);
> > +
>=20
>=20
>=20
> This would certainly work but would incur unncessary cost. All we need
> to do is to flush the local TLB entry correpsonding to these two pages.
> However, unmap_kernel_range --> flush_tlb_kernel_range woule cause TLB
> flush on all CPUs. Additionally, implementation of this function
> (flush_tlb_kernel_range) on architecutures like x86 seems naive since it
> flushes the entire TLB on all the CPUs.
>=20
> Even with all this penalty, I'm inclined on keeping this change to
> remove x86 only dependency, keeping improvements as future work.
>=20
> I think Seth was working on this improvement but not sure about the
> current status. Seth?

I wouldn't normally advocate an architecture-specific ifdef, but the
penalty for portability here seems high enough that it could make
sense here, perhaps hidden away in zsmalloc.h?  Perhaps eventually
in a mm header file as "unmap_kernel_page_pair_local()"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
