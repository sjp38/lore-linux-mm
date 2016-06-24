Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFDA6B0005
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 22:32:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so5263869wme.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 19:32:04 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id la7si3956528wjc.175.2016.06.23.19.32.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 19:32:03 -0700 (PDT)
Date: Fri, 24 Jun 2016 10:31:48 +0800
From: Dennis Chen <dennis.chen@arm.com>
Subject: Re: [PATCH 2/2] arm64:acpi Fix the acpi alignment exeception when
 'mem=' specified
Message-ID: <20160624023147.GB12969@arm.com>
References: <1466681415-8058-1-git-send-email-dennis.chen@arm.com>
 <1466681415-8058-2-git-send-email-dennis.chen@arm.com>
 <20160623124229.GD8836@leverpostej>
MIME-Version: 1.0
In-Reply-To: <20160623124229.GD8836@leverpostej>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Ard
 Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

On Thu, Jun 23, 2016 at 01:42:30PM +0100, Mark Rutland wrote:
> On Thu, Jun 23, 2016 at 07:30:15PM +0800, Dennis Chen wrote:
> > This is a rework patch based on [1]. According to the proposal from
> > Mark Rutland, when applying the system memory limit through 'mem=3Dx'
> > kernel command line, don't remove the rest memory regions above the
> > limit from the memblock, instead marking them as MEMBLOCK_NOMAP region,
> > which will preserve the ability to identify regions as normal memory
> > while not using them for allocation and the linear map.
> >=20
> > Without this patch, the ACPI core will map those acpi data regions(if
> > they are above the limit) as device type memory, which will result in
> > the alignment exception when ACPI core parses the AML data stream=20
> > since the parsing will produce some non-alignment accesses.
> >
> > [1]:http://lists.infradead.org/pipermail/linux-arm-kernel/2016-June/438=
443.html
>=20
> Please rewrite the message to be standalone (i.e. so peopel can read
> this without having to folow the link).
>=20
> Explain why using mem=3D makes ACPI think regions should be mapped as
> Device memory, the problems this causes for ACPICA, then cover why we
> want to nomap the region.
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
> >  arch/arm64/mm/init.c | 10 ++++++----
> >  1 file changed, 6 insertions(+), 4 deletions(-)
> >=20
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > index d45f862..e509e24 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -222,12 +222,14 @@ void __init arm64_memblock_init(void)
> > =20
> >  =09/*
> >  =09 * Apply the memory limit if it was set. Since the kernel may be lo=
aded
> > -=09 * high up in memory, add back the kernel region that must be acces=
sible
> > -=09 * via the linear mapping.
> > +=09 * in the memory regions above the limit, so we need to clear the
> > +=09 * MEMBLOCK_NOMAP flag of this region to make it can be accessible =
via
> > +=09 * the linear mapping.
> >  =09 */
> >  =09if (memory_limit !=3D (phys_addr_t)ULLONG_MAX) {
> > -=09=09memblock_enforce_memory_limit(memory_limit);
> > -=09=09memblock_add(__pa(_text), (u64)(_end - _text));
> > +=09=09memblock_mem_limit_mark_nomap(memory_limit);
> > +=09=09if (!memblock_is_map_memory(__pa(_text)))
> > +=09=09=09memblock_clear_nomap(__pa(_text), (u64)(_end - _text));
>=20
> I think that the memblock_is_map_memory() check should go. Just because
> a page of the kernel image is mapped doesn't mean that the rest is. That
> will make this a 1-1 change.
>
Good catch! Will be applied, thanks!
>=20
> Other than that, this looks right to me.
>=20
> Thanks,
> Mark.
>=20
> >  =09}
> > =20
> >  =09if (IS_ENABLED(CONFIG_BLK_DEV_INITRD) && initrd_start) {
> > --=20
> > 1.8.3.1
> >=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
