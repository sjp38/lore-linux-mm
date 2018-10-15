Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 818D66B0007
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 20:54:00 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b55-v6so19242505qtb.5
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 17:54:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u48-v6sor10121555qta.13.2018.10.14.17.53.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Oct 2018 17:53:59 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Date: Sun, 14 Oct 2018 20:53:55 -0400
Message-ID: <2398C491-E1DA-4B3C-B60A-377A09A02F1A@cs.rutgers.edu>
In-Reply-To: <5e0e772c-7eef-e75c-2921-e80d4fbe8324@arm.com>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
 <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
 <1968F276-5D96-426B-823F-38F6A51FB465@cs.rutgers.edu>
 <5e0e772c-7eef-e75c-2921-e80d4fbe8324@arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_AD919029-6940-4A68-A8C5-3D329E786D25_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_AD919029-6940-4A68-A8C5-3D329E786D25_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12 Oct 2018, at 4:00, Anshuman Khandual wrote:

> On 10/10/2018 06:13 PM, Zi Yan wrote:
>> On 10 Oct 2018, at 0:05, Anshuman Khandual wrote:
>>
>>> On 10/09/2018 07:28 PM, Zi Yan wrote:
>>>> cc: Naoya Horiguchi (who proposed to use !_PAGE_PRESENT && !_PAGE_PS=
E for x86
>>>> PMD migration entry check)
>>>>
>>>> On 8 Oct 2018, at 23:58, Anshuman Khandual wrote:
>>>>
>>>>> A normal mapped THP page at PMD level should be correctly different=
iated
>>>>> from a PMD migration entry while walking the page table. A mapped T=
HP would
>>>>> additionally check positive for pmd_present() along with pmd_trans_=
huge()
>>>>> as compared to a PMD migration entry. This just adds a new conditio=
nal test
>>>>> differentiating the two while walking the page table.
>>>>>
>>>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic pat=
h")
>>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>>> ---
>>>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mu=
tually
>>>>> exclusive which makes the current conditional block work for both m=
apped
>>>>> and migration entries. This is not same with arm64 where pmd_trans_=
huge()
>>>>
>>>> !pmd_present() && pmd_trans_huge() is used to represent THPs under s=
plitting,
>>>
>>> Not really if we just look at code in the conditional blocks.
>>
>> Yeah, I explained it wrong above. Sorry about that.
>>
>> In x86, pmd_present() checks (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_P=
SE),
>> thus, it returns true even if the present bit is cleared but PSE bit i=
s set.
>
> Okay.
>
>> This is done so, because THPs under splitting are regarded as present =
in the kernel
>> but not present when a hardware page table walker checks it.
>
> Okay.
>
>>
>> For PMD migration entry, which should be regarded as not present, if P=
SE bit
>> is set, which makes pmd_trans_huge() returns true, like ARM64 does, al=
l
>> PMD migration entries will be regarded as present
>
> Okay to make pmd_present() return false pmd_trans_huge() has to return =
false
> as well. Is there anything which can be done to get around this problem=
 on
> X86 ? pmd_trans_huge() returning true for a migration entry sounds logi=
cal.
> Otherwise we would revert the condition block order to accommodate both=
 the
> implementation for pmd_trans_huge() as suggested by Kirill before or ju=
st
> consider this patch forward.
>
> Because I am not really sure yet about the idea of getting pmd_present(=
)
> check into pmd_trans_huge() on arm64 just to make it fit into this sema=
ntics
> as suggested by Will. If a PMD is trans huge page or not should not dep=
end on
> whether it is present or not.

In terms of THPs, we have three cases: a present THP, a THP under splitti=
ng,
and a THP under migration. pmd_present() and pmd_trans_huge() both return=
 true
for a present THP and a THP under splitting, because they discover _PAGE_=
PSE bit
is set for both cases, whereas they both return false for a THP under mig=
ration.
You want to change them to make pmd_trans_huge() returns true for a THP u=
nder migration
instead of false to help ARM64=E2=80=99s support for THP migration.

For x86, this change requires:
1. changing the condition in pmd_trans_huge(), so that it returns true fo=
r
PMD migration entries;
2. changing the code, which calls pmd_trans_huge(), to match the new logi=
c.

Another problem I see is that x86=E2=80=99s pmd_present() returns true fo=
r a THP under
splitting but ARM64=E2=80=99s pmd_present() returns false for a THP under=
 splitting.
I do not know if there is any correctness issue with this. So I copy Andr=
ea
here, since he made x86=E2=80=99s pmd_present() returns true for a THP un=
der splitting
as an optimization. I want to understand more about it and potentially ma=
ke
x86 and ARM64 (maybe all other architectures, too) return the same value
for all three cases mentioned above.


Hi Andrea, what is the purpose/benefit of making x86=E2=80=99s pmd_presen=
t() returns true
for a THP under splitting? Does it cause problems when ARM64=E2=80=99s pm=
d_present()
returns false in the same situation?


>>
>> My concern is that if ARM64=E2=80=99s pmd_trans_huge() returns true fo=
r migration
>> entries, unlike x86, there might be bugs triggered in the kernel when
>> THP migration is enabled in ARM64.
>
> Right and that is exactly what we are trying to fix with this patch.
>

I am not sure this patch can fix the problem in ARM64, because many other=
 places
in the kernel, pmd_trans_huge() still returns false for a THP under migra=
tion.
We may need more comprehensive fixes for ARM64.

Thanks.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_AD919029-6940-4A68-A8C5-3D329E786D25_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlvD5SMWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzKLSB/9sR9Qa73Z6WjuW/A12z6IgIjKm
7U4ya99nvECvbrYrQae95N6YPqsOKwRKC0OvkiqD2nSK4tHHlFkBIunAfw1TRpnu
ANHAq9z7NHDXSEWYdyHZZoEKDKBZxPN6hDWnfJEB4HtbLnnNL7ojpxDrzBucTRxb
OA1FpnNJN5zyh80tYA9AioSLaLGAIQqR503nX0IIAKISHOCZNb80Ke6pyN+mu7QT
FU71anP0hT+USh+BJVJr0aJqLwBKF0kHuZp9fVAVAjauUKCe4DQjaGEqrvPZUeIb
+9XPwQCHMnWEM80qAhj8cfkzxUsiwN/bpBdhm5rezVSCb9riIS8GvQkXOc2A
=UDuJ
-----END PGP SIGNATURE-----

--=_MailMate_AD919029-6940-4A68-A8C5-3D329E786D25_=--
