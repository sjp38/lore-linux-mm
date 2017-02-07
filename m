Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78B106B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 12:15:36 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so157657027pfy.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 09:15:36 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0100.outbound.protection.outlook.com. [104.47.41.100])
        by mx.google.com with ESMTPS id d2si4623039pgf.249.2017.02.07.09.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 09:15:35 -0800 (PST)
Message-ID: <589A0090.3050406@cs.rutgers.edu>
Date: Tue, 7 Feb 2017 11:14:56 -0600
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in zap_pmd_range()
References: <20170205161252.85004-1-zi.yan@sent.com> <20170205161252.85004-4-zi.yan@sent.com> <20170207141956.GA4789@node.shutemov.name> <5899E389.3040801@cs.rutgers.edu> <20170207163734.GA5578@node.shutemov.name>
In-Reply-To: <20170207163734.GA5578@node.shutemov.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enig12A575DBDA3D22B8D2E4BE74"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Zi Yan <zi.yan@sent.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

--------------enig12A575DBDA3D22B8D2E4BE74
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Kirill A. Shutemov wrote:
> On Tue, Feb 07, 2017 at 09:11:05AM -0600, Zi Yan wrote:
>>>> This causes memory leak or kernel crashing, if VM_BUG_ON() is enable=
d.
>>> The problem is that numabalancing calls change_huge_pmd() under
>>> down_read(mmap_sem), not down_write(mmap_sem) as the rest of users do=
=2E
>>> It makes numabalancing the only code path beyond page fault that can =
turn
>>> pmd_none() into pmd_trans_huge() under down_read(mmap_sem).
>>>
>>> This can lead to race when MADV_DONTNEED miss THP. That's not critica=
l for
>>> pagefault vs. MADV_DONTNEED race as we will end up with clear page in=
 that
>>> case. Not so much for change_huge_pmd().
>>>
>>> Looks like we need pmdp_modify() or something to modify protection bi=
ts
>>> inplace, without clearing pmd.
>>>
>>> Not sure how to get crash scenario.
>>>
>>> BTW, Zi, have you observed the crash? Or is it based on code inspecti=
on?
>>> Any backtraces?
>> The problem should be very rare in the upstream kernel. I discover the=

>> problem in my customized kernel which does very frequent page migratio=
n
>> and uses numa_protnone.
>>
>> The crash scenario I guess is like:
>> 1. A huge page pmd entry is in the middle of being changed into either=
 a
>> pmd_protnone or a pmd_migration_entry. It is cleared to pmd_none.
>>
>> 2. At the same time, the application frees the vma this page belongs t=
o.
>=20
> Em... no.
>=20
> This shouldn't be possible: your 1. must be done under down_read(mmap_s=
em).
> And we only be able to remove vma under down_write(mmap_sem), so the
> scenario should be excluded.
>=20
> What do I miss?

You are right. This problem will not happen in the upstream kernel.

The problem comes from my customized kernel, where I migrate pages away
instead of reclaiming them when memory is under pressure. I did not take
any mmap_sem when I migrate pages. So I got this error.

It is a false alarm. Sorry about that. Thanks for clarifying the problem.=



--=20
Best Regards,
Yan Zi


--------------enig12A575DBDA3D22B8D2E4BE74
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJYmgCtAAoJEEGLLxGcTqbMZ4MH+gL1ffwmLMamJAA2C6JQWJep
Eg7dlxR5s+qx9qn9eHFM+7nBfqYaB+zajW3gvoLruFqbn4jRBgaq+KxWAgqRH+Ul
WiFu53nsBoAZMe1U8MWEdOJWRuOH+m2ex9T0JZ2cI7U7318BbGpzPQ/W41Wf1c/y
A86z/mXJO0bw+1R6OvZuGK++zoLv0kTwgaMmazRbcPxfTHlNRoTMcJO9cqNe8eik
MNtLeAOeYdqSnaJJSp5LXNnlhfmmbUqGsfPxvfnZdHFBVRYSPg4hosKZwUduVWT+
R3JuLD+RMrdhE9+IB06syAlIWNIGuQszHxt10wYh3f8iYrOn7wN66CoSWqNeWRA=
=k5dq
-----END PGP SIGNATURE-----

--------------enig12A575DBDA3D22B8D2E4BE74--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
