Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3FA76B0008
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 22:18:58 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d34so20965269otb.10
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 19:18:58 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id l18si11747592otb.47.2018.10.17.19.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 19:18:57 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Date: Thu, 18 Oct 2018 02:17:42 +0000
Message-ID: <20181018021741.GA3603@hori1.linux.bs1.fc.nec.co.jp>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
 <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
 <1968F276-5D96-426B-823F-38F6A51FB465@cs.rutgers.edu>
 <5e0e772c-7eef-e75c-2921-e80d4fbe8324@arm.com>
 <2398C491-E1DA-4B3C-B60A-377A09A02F1A@cs.rutgers.edu>
 <796cb545-7376-16a2-db3e-bc9a6ca9894d@arm.com>
 <5A0A88EF-4B86-4173-A506-DE19BDB786B8@cs.rutgers.edu>
In-Reply-To: <5A0A88EF-4B86-4173-A506-DE19BDB786B8@cs.rutgers.edu>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6B718953A26B454C82B906162E76979F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "will.deacon@arm.com" <will.deacon@arm.com>

On Tue, Oct 16, 2018 at 10:31:50AM -0400, Zi Yan wrote:
> On 15 Oct 2018, at 0:06, Anshuman Khandual wrote:
>=20
> > On 10/15/2018 06:23 AM, Zi Yan wrote:
> >> On 12 Oct 2018, at 4:00, Anshuman Khandual wrote:
> >>
> >>> On 10/10/2018 06:13 PM, Zi Yan wrote:
> >>>> On 10 Oct 2018, at 0:05, Anshuman Khandual wrote:
> >>>>
> >>>>> On 10/09/2018 07:28 PM, Zi Yan wrote:
> >>>>>> cc: Naoya Horiguchi (who proposed to use !_PAGE_PRESENT && !_PAGE_=
PSE for x86
> >>>>>> PMD migration entry check)
> >>>>>>
> >>>>>> On 8 Oct 2018, at 23:58, Anshuman Khandual wrote:
> >>>>>>
> >>>>>>> A normal mapped THP page at PMD level should be correctly differe=
ntiated
> >>>>>>> from a PMD migration entry while walking the page table. A mapped=
 THP would
> >>>>>>> additionally check positive for pmd_present() along with pmd_tran=
s_huge()
> >>>>>>> as compared to a PMD migration entry. This just adds a new condit=
ional test
> >>>>>>> differentiating the two while walking the page table.
> >>>>>>>
> >>>>>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic p=
ath")
> >>>>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> >>>>>>> ---
> >>>>>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always =
mutually
> >>>>>>> exclusive which makes the current conditional block work for both=
 mapped
> >>>>>>> and migration entries. This is not same with arm64 where pmd_tran=
s_huge()
> >>>>>>
> >>>>>> !pmd_present() && pmd_trans_huge() is used to represent THPs under=
 splitting,
> >>>>>
> >>>>> Not really if we just look at code in the conditional blocks.
> >>>>
> >>>> Yeah, I explained it wrong above. Sorry about that.
> >>>>
> >>>> In x86, pmd_present() checks (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE=
_PSE),
> >>>> thus, it returns true even if the present bit is cleared but PSE bit=
 is set.
> >>>
> >>> Okay.
> >>>
> >>>> This is done so, because THPs under splitting are regarded as presen=
t in the kernel
> >>>> but not present when a hardware page table walker checks it.
> >>>
> >>> Okay.
> >>>
> >>>>
> >>>> For PMD migration entry, which should be regarded as not present, if=
 PSE bit
> >>>> is set, which makes pmd_trans_huge() returns true, like ARM64 does, =
all
> >>>> PMD migration entries will be regarded as present
> >>>
> >>> Okay to make pmd_present() return false pmd_trans_huge() has to retur=
n false
> >>> as well. Is there anything which can be done to get around this probl=
em on
> >>> X86 ? pmd_trans_huge() returning true for a migration entry sounds lo=
gical.
> >>> Otherwise we would revert the condition block order to accommodate bo=
th the
> >>> implementation for pmd_trans_huge() as suggested by Kirill before or =
just
> >>> consider this patch forward.
> >>>
> >>> Because I am not really sure yet about the idea of getting pmd_presen=
t()
> >>> check into pmd_trans_huge() on arm64 just to make it fit into this se=
mantics
> >>> as suggested by Will. If a PMD is trans huge page or not should not d=
epend on
> >>> whether it is present or not.
> >>
> >> In terms of THPs, we have three cases: a present THP, a THP under spli=
tting,
> >> and a THP under migration. pmd_present() and pmd_trans_huge() both ret=
urn true
> >> for a present THP and a THP under splitting, because they discover _PA=
GE_PSE bit
> >
> > Then how do we differentiate between a mapped THP and a splitting THP.
>=20
> AFAIK, in x86, there is no distinction between a mapped THP and a splitti=
ng THP
> using helper functions.
>=20
> A mapped THP has _PAGE_PRESENT bit and _PAGE_PSE bit set, whereas a split=
ting THP
> has only _PAGE_PSE bit set. But both pmd_present() and pmd_trans_huge() r=
eturn
> true as long as _PAGE_PSE bit is set.
>=20
> >
> >> is set for both cases, whereas they both return false for a THP under =
migration.
> >> You want to change them to make pmd_trans_huge() returns true for a TH=
P under migration
> >> instead of false to help ARM64=1B$B!G=1B(Bs support for THP migration.
> > I am just trying to understand the rationale behind this semantics and =
see where
> > it should be fixed.
> >
> > I think the fundamental problem here is that THP under split has been d=
ifficult
> > to be re-presented through the available helper functions and in turn P=
TE bits.
> >
> > The following checks
> >
> > 1) pmd_present()
> > 2) pmd_trans_huge()
> >
> > Represent three THP states
> >
> > 1) Mapped THP		(pmd_present && pmd_trans_huge)
> > 2) Splitting THP	(pmd_present && pmd_trans_huge)
> > 3) Migrating THP	(!pmd_present && !pmd_trans_huge)
> >
> > The problem is if we make pmd_trans_huge() return true for all the thre=
e states
> > which sounds logical because they are all still trans huge PMD, then pm=
d_present()
> > can only represent two states not three as required.
>=20
> We are on the same page about representing three THP states in x86.
> I also agree with you that it is logical to use three distinct representa=
tions
> for these three states, i.e. splitting THP could be changed to (!pmd_pres=
ent && pmd_trans_huge).

I think that the behavior of pmd_trans_huge() for non-present pmd is
undefined by its nature. IOW, it's no use determining whether it's thp or
not for non-existing pages because it does not exist :)

So I think that the right direction is to make sure that pmd_trans_huge() i=
s
never checked for non-present pmd, just like Kirill's suggestion.  And mayb=
e
we have some room for engineering to ensure it (rather than just commenting=
 it).

Thanks,
Naoya Horiguchi=
