Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 334946B0008
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 10:00:56 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z26-v6so48461971qtz.4
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 07:00:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor14043207qvf.24.2018.10.22.07.00.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 07:00:54 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Date: Mon, 22 Oct 2018 10:00:53 -0400
Message-ID: <781B64F4-99AA-4771-B1E7-5B71896D4006@cs.rutgers.edu>
In-Reply-To: <20181017020930.GN30832@redhat.com>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
 <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
 <1968F276-5D96-426B-823F-38F6A51FB465@cs.rutgers.edu>
 <5e0e772c-7eef-e75c-2921-e80d4fbe8324@arm.com>
 <2398C491-E1DA-4B3C-B60A-377A09A02F1A@cs.rutgers.edu>
 <20181017020930.GN30832@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_D856A4E0-C8A9-4444-BE45-64A95EE50944_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_D856A4E0-C8A9-4444-BE45-64A95EE50944_=
Content-Type: text/plain; charset=utf-8; markup=markdown
Content-Transfer-Encoding: quoted-printable

Hi Andrea,

On 16 Oct 2018, at 22:09, Andrea Arcangeli wrote:

> Hello Zi,
>
> On Sun, Oct 14, 2018 at 08:53:55PM -0400, Zi Yan wrote:
>> Hi Andrea, what is the purpose/benefit of making x86=E2=80=99s pmd_pre=
sent() returns true
>> for a THP under splitting? Does it cause problems when ARM64=E2=80=99s=
 pmd_present()
>> returns false in the same situation?
>
> !pmd_present means it's a migration entry or swap entry and doesn't
> point to RAM. It means if you do pmd_to_page(*pmd) it will return you
> an undefined result.
>
> During splitting the physical page is still very well pointed by the
> pmd as long as pmd_trans_huge returns true and you hold the
> pmd_lock.
>
> pmd_trans_huge must be true at all times for a transhuge pmd that
> points to a hugepage, or all VM fast paths won't serialize with the
> pmd_lock, that is the only reason why, and it's a very good reason
> because it avoids to take the pmd_lock when walking over non transhuge
> pmds (i.e. when there are no THP allocated).
>
> Now if we've to keep _PAGE_PSE set and return true in pmd_trans_huge
> at all times, why would you want to make pmd_present return false? How
> could it help if pmd_trans_huge returns true, but pmd_present returns
> false despite pmd_to_page works fine and the pmd is really still
> pointing to the page?
>
> When userland faults on such pmd !pmd_present it will make the page
> fault take a swap or migration path, but that's the wrong path if the
> pmd points to RAM.
>
> What we need to do during split is an invalidate of the huge TLB.
> There's no pmd_trans_splitting anymore, so we only clear the present
> bit in the PTE despite pmd_present still returns true (just like
> PROT_NONE, nothing new in this respect). pmd_present never meant the
> real present bit in the pte was set, it just means the pmd points to
> RAM. It means it doesn't point to swap or migration entry and you can
> do pmd_to_page and it works fine.
>
> We need to invalidate the TLB by clearing the present bit and by
> flushing the TLB before overwriting the transhuge pmd with the regular
> pte (i.e. to make it non huge). That is actually required by an errata
> (l1 cache aliasing of the same mapping through two different TLB of
> two different sizes broke some old CPU and triggered machine checks).
> It's not something fundamentally necessary from a common code point of
> view. It's more risky from an hardware (not software) standpoint and
> before you can get rid of the pmd you need to do a TLB flush anyway to
> be sure CPUs stops using it, so better clear the present bit before
> doing the real costly thing (the tlb flush with IPIs). Clearing the
> present bit during the TLB flush is a cost that gets lost in the noise.=

>
> The clear of the real present bit during pmd (virtual) splitting is
> done with pmdp_invalidate, that is created specifically to keeps
> pmd_trans_huge=3Dtrue, pmd_present=3Dtrue despite the present bit is no=
t
> set. So you could imagine _PAGE_PSE as the real present bit.
>
> Before the physical split was deferred and decoupled from the virtual
> memory pmd split, pmd_trans_splitting allowed to wait the split to
> finish and to keep all gup_fast at bay during it (while the page was
> still mapped readable and writable in userland by other CPUs). Now the
> physical split is deferred so you just split the pmd locally and only
> a physical split invoked on the page (not the virtual split invoked on
> the pmd with split_huge_pmd) has to keep gup at bay, and it does so by
> freezing the refcount so all gup_fast fail with the
> page_cache_get_speculative during the freeze. This removed the need of
> the pmd_splitting flag in gup_fast (when pmd_splitting was set gup
> fast had to go through the non-fast gup), but it means that now a
> hugepage cannot be physically splitted if it's gup pinned. The main
> difference is that freezing the refcount can fail, so the code must
> learn to cope with such failure and defer it. Decoupling the physical
> and virtual splits introduced the need of tracking the doublemap case
> with a new PG_double_map flag too. It makes the refcounting of
> hugepages trivial in comparison (identical to hugetlbfs in fact), but
> it requires total_mapcount to account for all those huge and non huge
> mappings. It primarily pays off to add THP to tmpfs where the physical
> split may have to be deferred for pagecache reasons anyway.

Thanks for your detailed explanation!

Do you think it is worth documenting what you have said? At least on
why we want pmd_present() and pmd_trans_huge() both return true when
a THP is under splitting, so that we can avoid some confusion in the futu=
re.
I can send a patch to add it to Document/vm/transhuge.rst.

--
Best Regards
Yan Zi

--=_MailMate_D856A4E0-C8A9-4444-BE45-64A95EE50944_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlvN2BUWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzKijCACXzk7Z7ghLl/WE6OAInRORCuUL
3TrfdqnHY2Qr8qOUF5MPq9Blwe9oTXLlByAq1zUUeo+mQaHBDOZTjBSvBOgGOtYN
w0O+uWkJwwKfp71K2FPqcOLX76he6U8M09bBIoRlstz55TMtxkm2E/s+PtR0dfxD
fETDmJ54d5wyI+La0VB+g9c1vRBRDVgWBft7kcIhtdRBTVl/RF8QMlP/Jp2lEhZ9
0xWpvA9htEpBU11S/2mjE04zxAQxK1+LK6S1OVsJfeVIl3twEnOdMkZp4IzhYcj4
JtmihDCROp1d2ps2IM9hnuYXieYB0q3dzAo5O5dHPaILKKGLxmese6rRNDlU
=qKvb
-----END PGP SIGNATURE-----

--=_MailMate_D856A4E0-C8A9-4444-BE45-64A95EE50944_=--
