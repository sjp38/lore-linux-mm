Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 167816B02B7
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 14:45:52 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x18-v6so5374615qts.11
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 11:45:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5-v6sor5030150qkc.6.2018.10.25.11.45.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 11:45:50 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Date: Thu, 25 Oct 2018 14:45:46 -0400
Message-ID: <B26B3F91-BA46-479E-8030-D581F4D90D47@cs.rutgers.edu>
In-Reply-To: <dcd972a6-a508-1fab-4ba9-04043ca9992c@arm.com>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
 <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
 <1968F276-5D96-426B-823F-38F6A51FB465@cs.rutgers.edu>
 <5e0e772c-7eef-e75c-2921-e80d4fbe8324@arm.com>
 <2398C491-E1DA-4B3C-B60A-377A09A02F1A@cs.rutgers.edu>
 <796cb545-7376-16a2-db3e-bc9a6ca9894d@arm.com>
 <5A0A88EF-4B86-4173-A506-DE19BDB786B8@cs.rutgers.edu>
 <dcd972a6-a508-1fab-4ba9-04043ca9992c@arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_5C556047-7D19-4D0F-B8E7-1368D2F5421C_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_5C556047-7D19-4D0F-B8E7-1368D2F5421C_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 25 Oct 2018, at 4:10, Anshuman Khandual wrote:

> On 10/16/2018 08:01 PM, Zi Yan wrote:
>> On 15 Oct 2018, at 0:06, Anshuman Khandual wrote:
>>
>>> On 10/15/2018 06:23 AM, Zi Yan wrote:
>>>> On 12 Oct 2018, at 4:00, Anshuman Khandual wrote:
>>>>
>>>>> On 10/10/2018 06:13 PM, Zi Yan wrote:
>>>>>> On 10 Oct 2018, at 0:05, Anshuman Khandual wrote:
>>>>>>
>>>>>>> On 10/09/2018 07:28 PM, Zi Yan wrote:
>>>>>>>> cc: Naoya Horiguchi (who proposed to use !_PAGE_PRESENT && !_PAG=
E_PSE for x86
>>>>>>>> PMD migration entry check)
>>>>>>>>
>>>>>>>> On 8 Oct 2018, at 23:58, Anshuman Khandual wrote:
>>>>>>>>
>>>>>>>>> A normal mapped THP page at PMD level should be correctly diffe=
rentiated
>>>>>>>>> from a PMD migration entry while walking the page table. A mapp=
ed THP would
>>>>>>>>> additionally check positive for pmd_present() along with pmd_tr=
ans_huge()
>>>>>>>>> as compared to a PMD migration entry. This just adds a new cond=
itional test
>>>>>>>>> differentiating the two while walking the page table.
>>>>>>>>>
>>>>>>>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic=
 path")
>>>>>>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>>>>>>> ---
>>>>>>>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are alway=
s mutually
>>>>>>>>> exclusive which makes the current conditional block work for bo=
th mapped
>>>>>>>>> and migration entries. This is not same with arm64 where pmd_tr=
ans_huge()
>>>>>>>>
>>>>>>>> !pmd_present() && pmd_trans_huge() is used to represent THPs und=
er splitting,
>>>>>>>
>>>>>>> Not really if we just look at code in the conditional blocks.
>>>>>>
>>>>>> Yeah, I explained it wrong above. Sorry about that.
>>>>>>
>>>>>> In x86, pmd_present() checks (_PAGE_PRESENT | _PAGE_PROTNONE | _PA=
GE_PSE),
>>>>>> thus, it returns true even if the present bit is cleared but PSE b=
it is set.
>>>>>
>>>>> Okay.
>>>>>
>>>>>> This is done so, because THPs under splitting are regarded as pres=
ent in the kernel
>>>>>> but not present when a hardware page table walker checks it.
>>>>>
>>>>> Okay.
>>>>>
>>>>>>
>>>>>> For PMD migration entry, which should be regarded as not present, =
if PSE bit
>>>>>> is set, which makes pmd_trans_huge() returns true, like ARM64 does=
, all
>>>>>> PMD migration entries will be regarded as present
>>>>>
>>>>> Okay to make pmd_present() return false pmd_trans_huge() has to ret=
urn false
>>>>> as well. Is there anything which can be done to get around this pro=
blem on
>>>>> X86 ? pmd_trans_huge() returning true for a migration entry sounds =
logical.
>>>>> Otherwise we would revert the condition block order to accommodate =
both the
>>>>> implementation for pmd_trans_huge() as suggested by Kirill before o=
r just
>>>>> consider this patch forward.
>>>>>
>>>>> Because I am not really sure yet about the idea of getting pmd_pres=
ent()
>>>>> check into pmd_trans_huge() on arm64 just to make it fit into this =
semantics
>>>>> as suggested by Will. If a PMD is trans huge page or not should not=
 depend on
>>>>> whether it is present or not.
>>>>
>>>> In terms of THPs, we have three cases: a present THP, a THP under sp=
litting,
>>>> and a THP under migration. pmd_present() and pmd_trans_huge() both r=
eturn true
>>>> for a present THP and a THP under splitting, because they discover _=
PAGE_PSE bit
>>>
>>> Then how do we differentiate between a mapped THP and a splitting THP=
=2E
>>
>> AFAIK, in x86, there is no distinction between a mapped THP and a spli=
tting THP
>> using helper functions.
>>
>> A mapped THP has _PAGE_PRESENT bit and _PAGE_PSE bit set, whereas a sp=
litting THP
>> has only _PAGE_PSE bit set. But both pmd_present() and pmd_trans_huge(=
) return
>> true as long as _PAGE_PSE bit is set.
>
> I understand that. What I was wondering was since there is a need to di=
fferentiate
> between a mapped THP and a splitting THP at various places in generic T=
HP, we would
> need to way to identify each of them unambiguously some how. Is that pa=
rticular
> assumption wrong ? Dont we need to differentiate between a mapped THP a=
nd THP under
> splitting ?

According to Andrea's explanation here: https://lore.kernel.org/patchwork=
/patch/997412/#1184298,
we do not distinguish between a mapped THP and a splitting THP, because p=
md_to_page()
can return valid pages for both cases.

>>
>>>
>>>> is set for both cases, whereas they both return false for a THP unde=
r migration.
>>>> You want to change them to make pmd_trans_huge() returns true for a =
THP under migration
>>>> instead of false to help ARM64=E2=80=99s support for THP migration.
>>> I am just trying to understand the rationale behind this semantics an=
d see where
>>> it should be fixed.
>>>
>>> I think the fundamental problem here is that THP under split has been=
 difficult
>>> to be re-presented through the available helper functions and in turn=
 PTE bits.
>>>
>>> The following checks
>>>
>>> 1) pmd_present()
>>> 2) pmd_trans_huge()
>>>
>>> Represent three THP states
>>>
>>> 1) Mapped THP		(pmd_present && pmd_trans_huge)
>>> 2) Splitting THP	(pmd_present && pmd_trans_huge)
>>> 3) Migrating THP	(!pmd_present && !pmd_trans_huge)
>>>
>>> The problem is if we make pmd_trans_huge() return true for all the th=
ree states
>>> which sounds logical because they are all still trans huge PMD, then =
pmd_present()
>>> can only represent two states not three as required.
>>
>> We are on the same page about representing three THP states in x86.
>> I also agree with you that it is logical to use three distinct represe=
ntations
>> for these three states, i.e. splitting THP could be changed to (!pmd_p=
resent && pmd_trans_huge
>
> Right. Also we need clear wrapper around them in line with is_pmd_migra=
tion_entry() to
> represent three states all of which calling pmd_present() and pmd_trans=
_huge() which
> are exported by various architectures with exact same semantics without=
 any ambiguity.
>
> 1) is_pmd_mapped_entry()
> 2) is_pmd_splitting_entry()
> 3) is_pmd_migration_entry()

I think the semantics of pmd_trans_huge() is that the pmd entry is pointi=
ng to
a huge page. So is_pmd_mapped_entry() is the same as is_pmd_splitting_ent=
ry()
in terms of that.

According to Andrea's explanation:https://lore.kernel.org/patchwork/patch=
/997412/#1184298,
the semantics can avoid pmd_lock serializations on all VM fast paths, whi=
ch
is valid IMHO.


>>
>>
>>>>
>>>> For x86, this change requires:
>>>> 1. changing the condition in pmd_trans_huge(), so that it returns tr=
ue for
>>>> PMD migration entries;
>>>> 2. changing the code, which calls pmd_trans_huge(), to match the new=
 logic.
>>> Can those be fixed with an additional check for pmd_present() as sugg=
ested here
>>> in this patch ? Asking because in case we could not get common semant=
ics for
>>> these helpers on all arch that would be a fall back option for the mo=
ment.
>>
>> It would be OK for x86, since pmd_trans_huge() implies pmd_present() a=
nd hence
>> adding pmd_present() to pmd_trans_huge() makes no difference. But for =
ARM64,
>> from my understanding of the code described below, adding pmd_present(=
) to
>> pmd_trans_huge() seems to exclude splitting THPs from the original sem=
antic.
>>
>>
>>>>
>>>> Another problem I see is that x86=E2=80=99s pmd_present() returns tr=
ue for a THP under
>>>> splitting but ARM64=E2=80=99s pmd_present() returns false for a THP =
under splitting.
>>>
>>> But how did you conclude this ? I dont see any explicit helper for sp=
litting
>>> THP. Could you please point me in the code ?
>>
>> From the code I read for ARM64
>> (https://elixir.bootlin.com/linux/v4.19-rc8/source/arch/arm64/include/=
asm/pgtable.h#L360
>> and https://elixir.bootlin.com/linux/v4.19-rc8/source/arch/arm64/inclu=
de/asm/pgtable.h#L86),
>> pmd_present() only checks _PAGE_PRESENT and _PAGE_PROTONE. During a TH=
P splitting,
>
> These are PTE_VALID and PTE_PROT_NONE instead on arm64. But yes, they a=
re equivalent
> to __PAGE_PRESENT and __PAGE_PROTNONE on other archs.
>
> #define pmd_present(pmd)        pte_present(pmd_pte(pmd))
> #define pte_present(pte)        (!!(pte_val(pte) & (PTE_VALID | PTE_PRO=
T_NONE)))
>
>> pmdp_invalidate() clears _PAGE_PRESENT (https://elixir.bootlin.com/lin=
ux/v4.19-rc8/source/mm/huge_memory.c#L2130). So pmd_present() returns fal=
se in ARM64. Let me know
>> if I got anything wrong.
>>
>
> old_pmd =3D pmdp_invalidate(vma, haddr, pmd);
>
> __split_huge_pmd_locked -> pmdp_invalidate (the above mentioned instanc=
e)
> pmdp_invalidate -> pmd_mknotpresent
>
> #define pmd_mknotpresent(pmd)   (__pmd(pmd_val(pmd) & ~PMD_SECT_VALID)
>
> Generic pmdp invalidation removes PMD_SECT_VALID from a mapped PMD entr=
y.
> PMD_SECT_VALID is similar to PTE_VALID through identified separately. S=
o you
> are right, on arm64 pmd_present() return false for THP under splitting.=


This may actually cause problems in arm64, since the kernel will miss all=
 splitting THPs.

In sum, according to Andrea's explanation, I think it is better to adjust=

arm64's pmd_present() and pmd_trans_huge() to match what x86's semantics.=

Otherwise, arm64 might hit bugs while handling THPs.

--
Best Regards
Yan Zi

--=_MailMate_5C556047-7D19-4D0F-B8E7-1368D2F5421C_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlvSD1oWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzLOmB/48B7fd/ribPF2FMH95EdDY+fyP
H+Hh45bCZMAoTyC5gq2jlhCZ7XdvRp5o7XmfYXcgTaA9PIQuagfBBwqqlpYio0Y+
V96aPJ/Vy6poHTwRg78mJmagSZUm1QHoUrTiHEf8J7d29WIKF/hhKzQbaqOtK53R
Gf6j3xyayNbv7icfefrnUbfCCKApx5IzLdXNVcC/p2s9s77eJ9JaYKecFeA6en60
pzORJHYpmZkxeCFBxNpiH/E+2TaZTsUTBX5zzsPvpV0jlKs4QxFGXEplABpO1MTA
URUVsDE+jRmExnqqGzfntBHqgAtDHIVD/32Zdu3iX3wMA7BKT7TpDzet0AnC
=oNb4
-----END PGP SIGNATURE-----

--=_MailMate_5C556047-7D19-4D0F-B8E7-1368D2F5421C_=--
