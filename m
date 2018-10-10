Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 294536B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:43:24 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id j60-v6so4926719qtb.8
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:43:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b54-v6sor15468083qtk.58.2018.10.10.05.43.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 05:43:23 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Date: Wed, 10 Oct 2018 08:43:19 -0400
Message-ID: <1968F276-5D96-426B-823F-38F6A51FB465@cs.rutgers.edu>
In-Reply-To: <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
 <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_4BF4EE0F-22CE-41BB-A287-C2806B1CA675_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_4BF4EE0F-22CE-41BB-A287-C2806B1CA675_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10 Oct 2018, at 0:05, Anshuman Khandual wrote:

> On 10/09/2018 07:28 PM, Zi Yan wrote:
>> cc: Naoya Horiguchi (who proposed to use !_PAGE_PRESENT && !_PAGE_PSE =
for x86
>> PMD migration entry check)
>>
>> On 8 Oct 2018, at 23:58, Anshuman Khandual wrote:
>>
>>> A normal mapped THP page at PMD level should be correctly differentia=
ted
>>> from a PMD migration entry while walking the page table. A mapped THP=
 would
>>> additionally check positive for pmd_present() along with pmd_trans_hu=
ge()
>>> as compared to a PMD migration entry. This just adds a new conditiona=
l test
>>> differentiating the two while walking the page table.
>>>
>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path"=
)
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutu=
ally
>>> exclusive which makes the current conditional block work for both map=
ped
>>> and migration entries. This is not same with arm64 where pmd_trans_hu=
ge()
>>
>> !pmd_present() && pmd_trans_huge() is used to represent THPs under spl=
itting,
>
> Not really if we just look at code in the conditional blocks.

Yeah, I explained it wrong above. Sorry about that.

In x86, pmd_present() checks (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE)=
,
thus, it returns true even if the present bit is cleared but PSE bit is s=
et.
This is done so, because THPs under splitting are regarded as present in =
the kernel
but not present when a hardware page table walker checks it.

For PMD migration entry, which should be regarded as not present, if PSE =
bit
is set, which makes pmd_trans_huge() returns true, like ARM64 does, all
PMD migration entries will be regarded as present.

My concern is that if ARM64=E2=80=99s pmd_trans_huge() returns true for m=
igration
entries, unlike x86, there might be bugs triggered in the kernel when
THP migration is enabled in ARM64.

Let me know if I explain this clear to you.

>
>> since _PAGE_PRESENT is cleared during THP splitting but _PAGE_PSE is n=
ot.
>> See the comment in pmd_present() for x86, in arch/x86/include/asm/pgta=
ble.h
>
>
>         if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
>                 pvmw->ptl =3D pmd_lock(mm, pvmw->pmd);
>                 if (likely(pmd_trans_huge(*pvmw->pmd))) {
>                         if (pvmw->flags & PVMW_MIGRATION)
>                                 return not_found(pvmw);
>                         if (pmd_page(*pvmw->pmd) !=3D page)
>                                 return not_found(pvmw);
>                         return true;
>                 } else if (!pmd_present(*pvmw->pmd)) {
>                         if (thp_migration_supported()) {
>                                 if (!(pvmw->flags & PVMW_MIGRATION))
>                                         return not_found(pvmw);
>                                 if (is_migration_entry(pmd_to_swp_entry=
(*pvmw->pmd))) {
>                                         swp_entry_t entry =3D pmd_to_sw=
p_entry(*pvmw->pmd);
>
>                                         if (migration_entry_to_page(ent=
ry) !=3D page)
>                                                 return not_found(pvmw);=

>                                         return true;
>                                 }
>                         }
>                         return not_found(pvmw);
>                 } else {
>                         /* THP pmd was split under us: handle on pte le=
vel */
>                         spin_unlock(pvmw->ptl);
>                         pvmw->ptl =3D NULL;
>                 }
>         } else if (!pmd_present(pmde)) { ---> Outer 'else if'
>                 return false;
>         }
>
> Looking at the above code, it seems the conditional check for a THP
> splitting case would be (!pmd_trans_huge && pmd_present) instead as
> it has skipped the first two conditions. But THP splitting must have
> been initiated once it has cleared the outer check (else it would not
> have cleared otherwise)
>
> if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)).

If a THP is under splitting, both pmd_present() and pmd_trans_huge() retu=
rn
true in x86. The else part (/* THP pmd was split under us =E2=80=A6 */) h=
appens
after splitting is done.

> BTW what PMD state does the outer 'else if' block identify which must
> have cleared the following condition to get there.
>
> (!pmd_present && !pmd_trans_huge && !is_pmd_migration_entry)

I think it is the case that the PMD is gone or equivalently pmd_none().
This PMD entry is not in use.


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_4BF4EE0F-22CE-41BB-A287-C2806B1CA675_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlu98+cWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzHf4B/9Zq3cNxo/Ps/MeVzdtQUraPazX
PQWV701fhnHQdTrn8pQptfJRCpc+OrZABmE3Z+pnp6WUySeZpFgelYTJZvEQ6hBC
bUwG81h0sINfFvVWTEZVPYkafXaO2LeFaX2jN/9pYIqImmW3itof9IXe+o4ui03H
PNBuIYl4I8JJEicSgHCSRu4cZkoP1z1iq4UGr0ylolfTbYa7mrGK9bnhVyqQq1Sc
wngicjTtfzPMROeGbiauivOxPEW56niO3fZo34DEpxF+KQ1AcX6XhMRcTnLiOmIN
r65PQVdYeYjm40q7MxCh224swyrYU55MW3L8r51Xed0kCdU3wxKeM4pZ35gA
=jN1N
-----END PGP SIGNATURE-----

--=_MailMate_4BF4EE0F-22CE-41BB-A287-C2806B1CA675_=--
