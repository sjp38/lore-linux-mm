Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF1B8E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 14:07:56 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id g22so14028914qke.15
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:07:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x24sor16763840qvc.47.2018.12.11.11.07.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 11:07:54 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v2] mm: thp: fix flags for pmd migration when split
Date: Tue, 11 Dec 2018 14:07:49 -0500
Message-ID: <2B8D97F1-6E87-4556-ADBF-102D3C386478@cs.rutgers.edu>
In-Reply-To: <1fc103f7-3164-007d-bcfd-7ad7c60bb6ec@yandex-team.ru>
References: <20181211051254.16633-1-peterx@redhat.com>
 <1fc103f7-3164-007d-bcfd-7ad7c60bb6ec@yandex-team.ru>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_966F3666-67DE-420C-A1F0-C9DF558AF115_=";
 micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_966F3666-67DE-420C-A1F0-C9DF558AF115_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 11 Dec 2018, at 3:21, Konstantin Khlebnikov wrote:
>
> Write/read-only is encoded into migration entry.
> I suppose there should be something like this:
>
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2151,16 +2151,21 @@ static void __split_huge_pmd_locked(struct vm_a=
rea_struct *vma, pmd_t *pmd,
>
>                 entry =3D pmd_to_swp_entry(old_pmd);
>                 page =3D pfn_to_page(swp_offset(entry));
> +               write =3D is_write_migration_entry(entry);
> +               young =3D false;
> +               soft_dirty =3D pmd_swp_soft_dirty(old_pmd);
>         } else
>  #endif
> +       {
>                 page =3D pmd_page(old_pmd);
> +               if (pmd_dirty(old_pmd))
> +                       SetPageDirty(page);
> +               write =3D pmd_write(old_pmd);
> +               young =3D pmd_young(old_pmd);
> +               soft_dirty =3D pmd_soft_dirty(old_pmd);
> +       }
>         VM_BUG_ON_PAGE(!page_count(page), page);
>         page_ref_add(page, HPAGE_PMD_NR - 1);
> -       if (pmd_dirty(old_pmd))
> -               SetPageDirty(page);
> -       write =3D pmd_write(old_pmd);
> -       young =3D pmd_young(old_pmd);
> -       soft_dirty =3D pmd_soft_dirty(old_pmd);
>
>         /*
>          * Withdraw the table only after we mark the pmd entry invalid.=

>

This one should fix the issue. Thanks.

Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>
Fixes 84c3fc4e9c563 ("mm: thp: check pmd migration entry in common path")=


Do we need to cc: stable@vger.kernel.org # 4.14+ ?


--
Best Regards,
Yan Zi

--=_MailMate_966F3666-67DE-420C-A1F0-C9DF558AF115_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBAgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlwQCwUWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzH95CACtq8kT1f0THn0zc/TqyPkJ0QQj
DFahFGDPc9r9blvsMOHKL+a5isU7Roe+E0G92FV7ylWvLzemN2Ec2rzNyxLHG8az
GtsVBW+J50Ke3cTprbRqbstQESMfsrSN6odygXQUD/WuPH9oWOAeFrObWAFahzfT
0n9sBv6I1EXUFC5hvb7LIzuKAo8Gly2+OjZiWbS+2lPOgmOTFEBzm9d1D8rZ82FA
Vp8b+2+5QFaDrBq8QnBli+oxH+gulTrWVbs9XNupkYBO02pi3iwUt4QyBCn5bfrJ
WTyjRZtb55gqWrmlTf53QL1msEyqLo2RTPbUsoctktaUpW1j/8vjffgjAzBe
=/u5Q
-----END PGP SIGNATURE-----

--=_MailMate_966F3666-67DE-420C-A1F0-C9DF558AF115_=--
