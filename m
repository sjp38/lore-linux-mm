Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 746666B038E
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 21:52:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v127so57270166qkb.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:52:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a123si5308049qke.43.2017.03.16.18.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 18:52:24 -0700 (PDT)
Date: Thu, 16 Mar 2017 21:52:23 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <2057035918.7910419.1489715543920.JavaMail.zimbra@redhat.com>
In-Reply-To: <94e0d115-7deb-c748-3dc2-60d6289e6551@nvidia.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com> <1489680335-6594-8-git-send-email-jglisse@redhat.com> <20170316160520.d03ac02474cad6d2c8eba9bc@linux-foundation.org> <d4e8433d-4680-dced-4f11-2f3cc8ebc613@nvidia.com> <CAKTCnzmYob5uq11zkJE781BX9rDH9EYM7zxHH+ZMtTs4D5kkiQ@mail.gmail.com> <94e0d115-7deb-c748-3dc2-60d6289e6551@nvidia.com>
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use
 with device memory v4
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

> On 03/16/2017 05:45 PM, Balbir Singh wrote:
> > On Fri, Mar 17, 2017 at 11:22 AM, John Hubbard <jhubbard@nvidia.com> wr=
ote:
> >> On 03/16/2017 04:05 PM, Andrew Morton wrote:
> >>>
> >>> On Thu, 16 Mar 2017 12:05:26 -0400 J=C3=A9r=C3=B4me Glisse <jglisse@r=
edhat.com>
> >>> wrote:
> >>>
> >>>> +static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
> >>>> +{
> >>>> +       if (!(mpfn & MIGRATE_PFN_VALID))
> >>>> +               return NULL;
> >>>> +       return pfn_to_page(mpfn & MIGRATE_PFN_MASK);
> >>>> +}
> >>>
> >>>
> >>> i386 allnoconfig:
> >>>
> >>> In file included from mm/page_alloc.c:61:
> >>> ./include/linux/migrate.h: In function 'migrate_pfn_to_page':
> >>> ./include/linux/migrate.h:139: warning: left shift count >=3D width o=
f type
> >>> ./include/linux/migrate.h:141: warning: left shift count >=3D width o=
f type
> >>> ./include/linux/migrate.h: In function 'migrate_pfn_size':
> >>> ./include/linux/migrate.h:146: warning: left shift count >=3D width o=
f type
> >>>
> >>
> >> It seems clear that this was never meant to work with < 64-bit pfns:
> >>
> >> // migrate.h excerpt:
> >> #define MIGRATE_PFN_VALID       (1UL << (BITS_PER_LONG_LONG - 1))
> >> #define MIGRATE_PFN_MIGRATE     (1UL << (BITS_PER_LONG_LONG - 2))
> >> #define MIGRATE_PFN_HUGE        (1UL << (BITS_PER_LONG_LONG - 3))
> >> #define MIGRATE_PFN_LOCKED      (1UL << (BITS_PER_LONG_LONG - 4))
> >> #define MIGRATE_PFN_WRITE       (1UL << (BITS_PER_LONG_LONG - 5))
> >> #define MIGRATE_PFN_DEVICE      (1UL << (BITS_PER_LONG_LONG - 6))
> >> #define MIGRATE_PFN_ERROR       (1UL << (BITS_PER_LONG_LONG - 7))
> >> #define MIGRATE_PFN_MASK        ((1UL << (BITS_PER_LONG_LONG -
> >> PAGE_SHIFT))
> >> - 1)
> >>
> >> ...obviously, there is not enough room for these flags, in a 32-bit pf=
n.
> >>
> >> So, given the current HMM design, I think we are going to have to prov=
ide
> >> a
> >> 32-bit version of these routines (migrate_pfn_to_page, and related) th=
at
> >> is
> >> a no-op, right?
> >
> > Or make the HMM Kconfig feature 64BIT only by making it depend on 64BIT=
?
> >
>=20
> Yes, that was my first reaction too, but these particular routines are
> aspiring to be generic
> routines--in fact, you have had an influence there, because these might
> possibly help with NUMA
> migrations. :)
>=20
> So it would look odd to see this:
>=20
> #ifdef CONFIG_HMM
> int migrate_vma(const struct migrate_vma_ops *ops,
> =09=09struct vm_area_struct *vma,
> =09=09unsigned long mentries,
> =09=09unsigned long start,
> =09=09unsigned long end,
> =09=09unsigned long *src,
> =09=09unsigned long *dst,
> =09=09void *private)
> {
>     //...implementation
> #endif
>=20
> ...because migrate_vma() does not sound HMM-specific, and it is, after al=
l,
> in migrate.h and
> migrate.c. We probably want this a more generic approach (not sure if I'v=
e
> picked exactly the right
> token to #ifdef on, but it's close):
>=20
> #ifdef CONFIG_64BIT
> int migrate_vma(const struct migrate_vma_ops *ops,
> =09=09struct vm_area_struct *vma,
> =09=09unsigned long mentries,
> =09=09unsigned long start,
> =09=09unsigned long end,
> =09=09unsigned long *src,
> =09=09unsigned long *dst,
> =09=09void *private)
> {
>     /* ... full implementation */
> }
>=20
> #else
> int migrate_vma(const struct migrate_vma_ops *ops,
> =09=09struct vm_area_struct *vma,
> =09=09unsigned long mentries,
> =09=09unsigned long start,
> =09=09unsigned long end,
> =09=09unsigned long *src,
> =09=09unsigned long *dst,
> =09=09void *private)
> {
>     return -EINVAL; /* or something more appropriate */
> }
> #endif
>=20
> thanks
> John Hubbard
> NVIDIA

The original intention was for it to be 64bit only, 32bit is a dying
species and before splitting out hmm_ prefix from this code and moving
it to be generic it was behind a 64bit flag.

If latter one someone really care about 32bit we can only move to u64

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
