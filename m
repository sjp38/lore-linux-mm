Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 902456B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 22:55:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so5072795wme.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 19:55:52 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id t138si4384710wmd.116.2016.06.27.19.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 19:55:51 -0700 (PDT)
Date: Tue, 28 Jun 2016 10:55:41 +0800
From: Dennis Chen <dennis.chen@arm.com>
Subject: Re: [PATCH v3 1/2] mm: memblock Add some new functions to address
 the mem limit issue
Message-ID: <20160628025539.GB9594@arm.com>
References: <1466994431-6214-1-git-send-email-dennis.chen@arm.com>
 <20160627142818.GI1113@leverpostej>
MIME-Version: 1.0
In-Reply-To: <20160627142818.GI1113@leverpostej>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Ard
 Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

On Mon, Jun 27, 2016 at 03:28:19PM +0100, Mark Rutland wrote:
> On Mon, Jun 27, 2016 at 10:27:10AM +0800, Dennis Chen wrote:
> > In some cases, memblock is queried to determine whether a physical
> > address corresponds to memory present in a system even if unused by
> > the OS for the linear mapping, highmem, etc. For example, the ACPI
> > core needs this information to determine which attributes to use when
> > mapping ACPI regions. Use of incorrect memory types can result in
> > faults, data corruption, or other issues.
> >=20
> > Removing memory with memblock_enforce_memory_limit throws away this
> > information, and so a kernel booted with 'mem=3D' may suffers from the
> > issues described above. To avoid this, we need to keep those NOMAP
> > regions instead of removing all above limit, which preserves the
> > information we need while preventing other use of the regions.
> >=20
> > This patch adds new insfrastructure to retain all NOMAP memblock region=
s
> > while removing others, to cater for this.
> >=20
> > At last, we add 'size' and 'flag' debug output in the memblock debugfs
> > for ease of the memblock debug.
> > The '/sys/kernel/debug/memblock/memory' output looks like before:
> >    0: 0x0000008000000000..0x0000008001e7ffff
> >    1: 0x0000008001e80000..0x00000083ff184fff
> >    2: 0x00000083ff185000..0x00000083ff1c2fff
> >    3: 0x00000083ff1c3000..0x00000083ff222fff
> >    4: 0x00000083ff223000..0x00000083ffe42fff
> >    5: 0x00000083ffe43000..0x00000083ffffffff
> >=20
> > After applied:
> >    0: 0x0000008000000000..0x0000008001e7ffff  0x0000000001e80000  0x4
> >    1: 0x0000008001e80000..0x00000083ff184fff  0x00000003fd305000  0x0
> >    2: 0x00000083ff185000..0x00000083ff1c2fff  0x000000000003e000  0x4
> >    3: 0x00000083ff1c3000..0x00000083ff222fff  0x0000000000060000  0x0
> >    4: 0x00000083ff223000..0x00000083ffe42fff  0x0000000000c20000  0x4
> >    5: 0x00000083ffe43000..0x00000083ffffffff  0x00000000001bd000  0x0
>=20
> The debugfs changes should be a separate patch. Even if they're useful
> for debugging this patch, they're logically independent.
>
Indeed. Will isolate it as an individual patch for this set.
>=20
> > Signed-off-by: Dennis Chen <dennis.chen@arm.com>
> > Cc: Catalin Marinas <catalin.marinas@arm.com>
> > Cc: Steve Capper <steve.capper@arm.com>
> > Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > Cc: Will Deacon <will.deacon@arm.com>
> > Cc: Mark Rutland <mark.rutland@arm.com>
> > Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > Cc: Matt Fleming <matt@codeblueprint.co.uk>
> > Cc: linux-mm@kvack.org
> > Cc: linux-acpi@vger.kernel.org
> > Cc: linux-efi@vger.kernel.org
> > ---
> >  include/linux/memblock.h |  1 +
> >  mm/memblock.c            | 55 ++++++++++++++++++++++++++++++++++++++++=
+-------
> >  2 files changed, 48 insertions(+), 8 deletions(-)
> >=20
> > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > index 6c14b61..2925da2 100644
> > --- a/include/linux/memblock.h
> > +++ b/include/linux/memblock.h
> > @@ -332,6 +332,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_p=
fn);
> >  phys_addr_t memblock_start_of_DRAM(void);
> >  phys_addr_t memblock_end_of_DRAM(void);
> >  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> > +void memblock_mem_limit_remove_map(phys_addr_t limit);
> >  bool memblock_is_memory(phys_addr_t addr);
> >  int memblock_is_map_memory(phys_addr_t addr);
> >  int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index ca09915..8099f1a 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -1465,14 +1465,11 @@ phys_addr_t __init_memblock memblock_end_of_DRA=
M(void)
> >  =09return (memblock.memory.regions[idx].base + memblock.memory.regions=
[idx].size);
> >  }
> > =20
> > -void __init memblock_enforce_memory_limit(phys_addr_t limit)
> > +static phys_addr_t __init_memblock __find_max_addr(phys_addr_t limit)
> >  {
> >  =09phys_addr_t max_addr =3D (phys_addr_t)ULLONG_MAX;
> >  =09struct memblock_region *r;
> > =20
> > -=09if (!limit)
> > -=09=09return;
> > -
> >  =09/* find out max address */
> >  =09for_each_memblock(memory, r) {
> >  =09=09if (limit <=3D r->size) {
> > @@ -1482,6 +1479,20 @@ void __init memblock_enforce_memory_limit(phys_a=
ddr_t limit)
> >  =09=09limit -=3D r->size;
> >  =09}
> > =20
> > +=09return max_addr;
> > +}
> > +
> > +void __init memblock_enforce_memory_limit(phys_addr_t limit)
> > +{
> > +=09phys_addr_t max_addr;
> > +
> > +=09if (!limit)
> > +=09=09return;
> > +
> > +=09max_addr =3D __find_max_addr(limit);
> > +=09if (max_addr =3D=3D (phys_addr_t)ULLONG_MAX)
> > +=09=09return;
>=20
> We didn't previously return early, so do we actually need this check?
>
If we assign a mem limit count exceeds the actual physical RAM size in the =
system,
then we will fall into this case, return directly here will avoid a functio=
n call
followed though it will step out quickly.=20
>=20
> > +
> >  =09/* truncate both memory and reserved regions */
> >  =09memblock_remove_range(&memblock.memory, max_addr,
> >  =09=09=09      (phys_addr_t)ULLONG_MAX);
> > @@ -1489,6 +1500,32 @@ void __init memblock_enforce_memory_limit(phys_a=
ddr_t limit)
> >  =09=09=09      (phys_addr_t)ULLONG_MAX);
> >  }
> > =20
> > +void __init memblock_mem_limit_remove_map(phys_addr_t limit)
> > +{
> > +=09struct memblock_type *type =3D &memblock.memory;
> > +=09phys_addr_t max_addr;
> > +=09int i, ret, start_rgn, end_rgn;
> > +
> > +=09if (!limit)
> > +=09=09return;
> > +
> > +=09max_addr =3D __find_max_addr(limit);
> > +=09if (max_addr =3D=3D (phys_addr_t)ULLONG_MAX)
> > +=09=09return;
>=20
> Likewise?
>
ditto
>=20
> > +
> > +=09ret =3D memblock_isolate_range(type, max_addr, (phys_addr_t)ULLONG_=
MAX,
> > +=09=09=09=09=09&start_rgn, &end_rgn);
> > +=09if (ret) {
> > +=09=09WARN_ONCE(1, "Mem limit failed, will not be applied!\n");
> > +=09=09return;
> > +=09}
>=20
> We don't have a similar warning in memblock_enforce_memory_limit, where
> memblock_remove_range() might return an error code from an internal call
> to memblock_isolate_range.
>
Somehow cosmetic here for the warning, given it's extremely rare case to re=
turn
an error value, it doesn't hurt significantly to ignore the return value. B=
ut
WARN_ONCE at least makes me comfortable though :)
>=20
> The two should be consistent, either both with a message or both
> without.
>=20
> > +
> > +=09for (i =3D end_rgn - 1; i >=3D start_rgn; i--) {
> > +=09=09if (!memblock_is_nomap(&type->regions[i]))
> > +=09=09=09memblock_remove_region(type, i);
> > +=09}
> > +}
>=20
> This will preserve nomap regions, but it does mean that we may preserve
> less memory that the user asked for, since __find_max_addr counted nomap
> (and reserved) regions. Given we've always counted the latter, maybe
> that's ok.
>
As far as the user here, I think we have two: the firmware and the kernel.
All the memory reserved by firmware will be NOMAP marked, so it doesn't mat=
ter here.
For kernel user, we need to avoid allocate memory(e.g, memblock_alloc) befo=
re
the limit is applied, otherwise probably we may discard the user's allocate=
d
memory once limit is applied. Fortunately, I don't find that kind of use be=
fore
using the limit. Technically, as a hack method to fake the less memory avai=
lable
to the kernel than it actually is, mem limit should be applied as early as =
possible.=20
But given some limitation there, for instance, the early parameter parsing =
and the
possible effort, maybe a little bit fussy to do that.

>=20
> We should clarify what __find_max_addr is intended to determine, with a
> comment, so as to avoid future ambiguity there.
>
__find_max_addr is used to translate the limit(size) into the final limited=
 address
within one of the memblocks, for example, in our juno board, we have two se=
parate
physical memory block: 2G- (0x8000_0000, ...) and 6G- (0x8_8000_0000, ...),=
 mem=3D4G
will hit the limited memory address as 0x8_8000_0000 + 2G in the 2nd block.=
=20
I will add some comments to clarify.=20
>=20
> > +
> >  static int __init_memblock memblock_search(struct memblock_type *type,=
 phys_addr_t addr)
> >  {
> >  =09unsigned int left =3D 0, right =3D type->cnt;
> > @@ -1677,13 +1714,15 @@ static int memblock_debug_show(struct seq_file =
*m, void *private)
> >  =09=09reg =3D &type->regions[i];
> >  =09=09seq_printf(m, "%4d: ", i);
> >  =09=09if (sizeof(phys_addr_t) =3D=3D 4)
> > -=09=09=09seq_printf(m, "0x%08lx..0x%08lx\n",
> > +=09=09=09seq_printf(m, "0x%08lx..0x%08lx  0x%08lx  0x%lx\n",
> >  =09=09=09=09   (unsigned long)reg->base,
> > -=09=09=09=09   (unsigned long)(reg->base + reg->size - 1));
> > +=09=09=09=09   (unsigned long)(reg->base + reg->size - 1),
> > +=09=09=09=09   (unsigned long)reg->size, reg->flags);
> >  =09=09else
> > -=09=09=09seq_printf(m, "0x%016llx..0x%016llx\n",
> > +=09=09=09seq_printf(m, "0x%016llx..0x%016llx  0x%016llx  0x%lx\n",
> >  =09=09=09=09   (unsigned long long)reg->base,
> > -=09=09=09=09   (unsigned long long)(reg->base + reg->size - 1));
> > +=09=09=09=09   (unsigned long long)(reg->base + reg->size - 1),
> > +=09=09=09=09   (unsigned long long)reg->size, reg->flags);
>=20
> As mentioned above, this should be a separate patch. I have no strong
> feelings either way about the logic itself.
>
Hi Mark, thanks for the review!I plan to post updated version later on...

Thanks,
Dennis
>=20
> Thanks,
> Mark.
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
