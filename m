Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 996CB6B0273
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 21:31:04 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c16so8608930qke.17
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 18:31:04 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0094.outbound.protection.outlook.com. [104.47.33.94])
        by mx.google.com with ESMTPS id n33si182193qtn.47.2017.11.06.18.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 18:31:03 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC -mm] mm, userfaultfd, THP: Avoid waiting when PMD under THP
 migration
Date: Mon, 06 Nov 2017 21:30:54 -0500
Message-ID: <AA90DD1E-A077-484C-B7B6-738D76CC2F91@cs.rutgers.edu>
In-Reply-To: <20171106203527.GB26645@redhat.com>
References: <20171103075231.25416-1-ying.huang@intel.com>
 <D3FBD1E2-FC24-46B1-9CFF-B73295292675@cs.rutgers.edu>
 <CAC=cRTPCw4gBLCequmo6+osqGOrV_+n8puXn=R7u+XOVHLQxxA@mail.gmail.com>
 <AC486A3D-F3D4-403D-B3EB-DB2A14CF4042@cs.rutgers.edu>
 <20171106203527.GB26645@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_38156A7B-D9D7-4A8F-B960-D3F2C5442256_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: huang ying <huang.ying.caritas@gmail.com>, "Huang, Ying" <ying.huang@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_38156A7B-D9D7-4A8F-B960-D3F2C5442256_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 6 Nov 2017, at 15:35, Andrea Arcangeli wrote:

> On Mon, Nov 06, 2017 at 10:53:48AM -0500, Zi Yan wrote:
>> Thanks for clarifying it. We both agree that !pmd_present(), which mea=
ns
>> PMD migration entry, does not get into userfaultfd_must_wait(),
>> then there seems to be no issue with current code yet.
>>
>> However, the if (!pmd_present(_pmd)) in userfaultfd_must_wait() does n=
ot
>> match
>> the exact condition. How about the patch below? It can catch pmd
>> migration entries,
>> which are only possible in x86_64 at the moment.
>>
>> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
>> index 1c713fd5b3e6..dda25444a6ee 100644
>> --- a/fs/userfaultfd.c
>> +++ b/fs/userfaultfd.c
>> @@ -294,9 +294,11 @@ static inline bool userfaultfd_must_wait(struct
>> userfaultfd_ctx *ctx,
>>           * pmd_trans_unstable) of the pmd.
>>           */
>>          _pmd =3D READ_ONCE(*pmd);
>> -       if (!pmd_present(_pmd))
>> +       if (pmd_none(_pmd))
>>                  goto out;
>>
>> +       VM_BUG_ON(thp_migration_supported() && is_pmd_migration_entry(=
_pmd));
>> +
>
> As I wrote in prev email I'm not sure about this invariant to be
> correct 100% of the time (plus we'd want a VM_WARN_ON only
> here). Specifically, what does prevent try_to_unmap to run on a THP
> backed mapping with only the mmap_sem for reading?
>

Right. I missed the part that the page table lock is released before
entering handle_userfault(). The pmd_none() can be mapped elsewhere
and migrated, !pmd_present() but not pmd_none() is possible here when
THP migration is enabled.

> I know what prevents to ever reproduce this in practice though (aside
> from the fact the race between the is_swap_pmd() check in the main
> page fault and the above check is small) and it's because compaction
> won't migrate THP and even the numa faults will not use the migration
> entry. So it'd require some more explicit migration numactl while
> userfaults are running to ever see an hang in there.
>
> I think it's a regression since the introduction of THP migration
> around commits 84c3fc4e9c563d8fb91cfdf5948da48fe1af34d3 /
> 616b8371539a6c487404c3b8fb04078016dab4ba /
> 9c670ea37947a82cb6d4df69139f7e46ed71a0ac etc.. before that pmd_none or
> !pmd_present used to be equivalent, not the case any longer. Of course
> pmd_none would have been better before too.
>

Right. Ying=E2=80=99s patch is a fix of the regression.

Fixes: 84c3fc4e9c563 ("mm: thp: check pmd migration entry in common path"=
)

Thanks for pointing all these out.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_38156A7B-D9D7-4A8F-B960-D3F2C5442256_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAloBGt4WHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzBasB/0S76/3qBUPYvT36zi5DsQV0klJ
6rNaitKGr1BBRtXNgYCsg83awMpf9YUS6thgWEQ3XijGq9HCfIYytSgwXnxYAyiI
Abb1KIMtsdm93llj4+Bk0Cos4h5CX2sYbTnbTwQi0Bi3ggl2DF2CF2Djs/8YREpi
WSCdb2lcCJFAfahTuSRzJi8bGTVjjwr9gYqDVdO62E6zDwI681ySQk1KJSqPf8Ws
hZev+rl//yFm/qK1BKVhoGC1UIbu5m5J3BrWHrpvOzS+ajSfcYc21iy0nNrwgdPM
jM/xA0l9JysZnFhWHohhZpkQKlkPwcI/4Q2EXgolF9gATeO3vygLI5b4kvLm
=oNMz
-----END PGP SIGNATURE-----

--=_MailMate_38156A7B-D9D7-4A8F-B960-D3F2C5442256_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
