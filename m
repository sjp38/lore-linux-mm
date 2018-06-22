Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 015E76B0005
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 02:56:22 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e39-v6so3198979plb.10
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 23:56:22 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id e7-v6si5524158pgp.386.2018.06.21.23.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 23:56:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: initialize struct page for reserved pages in
 ZONE_DEVICE
Date: Fri, 22 Jun 2018 06:55:11 +0000
Message-ID: <20180622065510.GA13556@hori1.linux.bs1.fc.nec.co.jp>
References: <1529647683-14531-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CAPcyv4hpdvGRi+=psT47ePB6QigJW2JEq-zhbVXsTHb14pWfUQ@mail.gmail.com>
In-Reply-To: <CAPcyv4hpdvGRi+=psT47ePB6QigJW2JEq-zhbVXsTHb14pWfUQ@mail.gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3065B67A7F2BDE49ABD9AFB3204317DD@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>

On Thu, Jun 21, 2018 at 11:12:01PM -0700, Dan Williams wrote:
> On Thu, Jun 21, 2018 at 11:08 PM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > Reading /proc/kpageflags for pfns allocated by pmem namespace triggers
> > kernel panic with a message like "BUG: unable to handle kernel paging
> > request at fffffffffffffffe".
> >
> > The first few pages (controlled by altmap passed to memmap_init_zone())
> > in the ZONE_DEVICE can skip struct page initialization, which causes
> > the reported issue.
> >
> > This patch simply adds some initialization code for them.
> >
> > Fixes: 4b94ffdc4163 ("x86, mm: introduce vmem_altmap to augment vmemmap=
_populate()")
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/page_alloc.c | 10 +++++++++-
> >  1 file changed, 9 insertions(+), 1 deletion(-)
> >
> > diff --git v4.17-mmotm-2018-06-07-16-59/mm/page_alloc.c v4.17-mmotm-201=
8-06-07-16-59_patched/mm/page_alloc.c
> > index 1772513..0b36afe 100644
> > --- v4.17-mmotm-2018-06-07-16-59/mm/page_alloc.c
> > +++ v4.17-mmotm-2018-06-07-16-59_patched/mm/page_alloc.c
> > @@ -5574,8 +5574,16 @@ void __meminit memmap_init_zone(unsigned long si=
ze, int nid, unsigned long zone,
> >          * Honor reservation requested by the driver for this ZONE_DEVI=
CE
> >          * memory
> >          */
> > -       if (altmap && start_pfn =3D=3D altmap->base_pfn)
> > +       if (altmap && start_pfn =3D=3D altmap->base_pfn) {
> > +               unsigned long i;
> > +
> > +               for (i =3D 0; i < altmap->reserve; i++) {
> > +                       page =3D pfn_to_page(start_pfn + i);
> > +                       __init_single_page(page, start_pfn + i, zone, n=
id);
> > +                       SetPageReserved(page);
> > +               }
> >                 start_pfn +=3D altmap->reserve;
> > +       }
>=20
> No, unfortunately this will clobber metadata that lives in that
> reserved area, see __nvdimm_setup_pfn().

Hi Dan,

This patch doesn't touch the reserved region itself, but only
struct pages on the region. I'm still not sure why it's necessary
to leave these struct pages uninitialized for pmem operation?

My another related concern is about memory_failure_dev_pagemap().
If a memory error happens on the reserved pfn range, this function
seems to try to access to the uninitialized struct page and maybe
trigger oops. So do we need something to prevent this?

Thanks,
Naoya Horiguchi=
