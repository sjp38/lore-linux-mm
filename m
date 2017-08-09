Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC226B0292
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 12:52:52 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w51so32357875qtc.12
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 09:52:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j97si3363020qte.527.2017.08.09.09.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 09:52:51 -0700 (PDT)
Date: Wed, 9 Aug 2017 12:52:46 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <88997080.69197246.1502297566486.JavaMail.zimbra@redhat.com>
In-Reply-To: <20170809163434.p356oyarqpqh52hu@node.shutemov.name>
References: <20170809161709.9278-1-jglisse@redhat.com> <20170809163434.p356oyarqpqh52hu@node.shutemov.name>
Subject: Re: [PATCH] mm/rmap: try_to_unmap_one() do not call mmu_notifier
 under ptl
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

> On Wed, Aug 09, 2017 at 12:17:09PM -0400, jglisse@redhat.com wrote:
> > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> >=20
> > MMU notifiers can sleep, but in try_to_unmap_one() we call
> > mmu_notifier_invalidate_page() under page table lock.
> >=20
> > Let's instead use mmu_notifier_invalidate_range() outside
> > page_vma_mapped_walk() loop.
> >=20
> > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Fixes: c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use
> > page_vma_mapped_walk()")
> > ---
> >  mm/rmap.c | 36 +++++++++++++++++++++---------------
> >  1 file changed, 21 insertions(+), 15 deletions(-)
> >=20
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index aff607d5f7d2..d60e887f1cda 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1329,7 +1329,8 @@ static bool try_to_unmap_one(struct page *page,
> > struct vm_area_struct *vma,
> >  =09};
> >  =09pte_t pteval;
> >  =09struct page *subpage;
> > -=09bool ret =3D true;
> > +=09bool ret =3D true, invalidation_needed =3D false;
> > +=09unsigned long end =3D address + PAGE_SIZE;
>=20
> I think it should be 'address + (1UL << compound_order(page))'.

Can't address point to something else than first page in huge page ?
Also i did use end as an optimization ie maybe not all the pte in the
range are valid and thus they not all need to be invalidated hence by
tracking the last one that needs invalidation i am limiting the range.

But it is a small optimization so i am not attach to it.

J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
