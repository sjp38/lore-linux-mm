Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38E546B78C4
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:35:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u45-v6so10769949qte.12
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:35:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o30-v6sor2131215qtj.151.2018.09.06.05.35.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 05:35:25 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Date: Thu, 06 Sep 2018 08:35:22 -0400
Message-ID: <87733522-2EFD-4A17-AE8B-6DABE8B9BFAB@cs.rutgers.edu>
In-Reply-To: <20180906112546.GP14951@dhcp22.suse.cz>
References: <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <20180830070021.GB2656@dhcp22.suse.cz>
 <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu>
 <20180830134549.GI2656@dhcp22.suse.cz>
 <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
 <20180830164057.GK2656@dhcp22.suse.cz> <20180905034403.GN4762@redhat.com>
 <20180905070803.GZ14951@dhcp22.suse.cz>
 <99ee1104-9258-e801-2ba3-a643892cc6c1@suse.cz>
 <d339247b-18a5-e26d-d402-c44c8cca6cee@suse.cz>
 <20180906112546.GP14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_D9E5D2C2-827E-48AC-B838-A1431C8687DE_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_D9E5D2C2-827E-48AC-B838-A1431C8687DE_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 6 Sep 2018, at 7:25, Michal Hocko wrote:

> On Thu 06-09-18 13:16:00, Vlastimil Babka wrote:
>> On 09/06/2018 01:10 PM, Vlastimil Babka wrote:
>>>> We can and should think about this much more but I would like to hav=
e
>>>> this regression closed. So can we address GFP_THISNODE part first an=
d
>>>> build more complex solution on top?
>>>>
>>>> Is there any objection to my patch which does the similar thing to y=
our
>>>> patch v2 in a different location?
>>>
>>> Similar but not the same. It fixes the madvise case, but I wonder abo=
ut
>>> the no-madvise defrag=3Ddefer case, where Zi Yan reports it still cau=
ses
>>> swapping.
>>
>> Ah, but that should be the same with Andrea's variant 2) patch. There
>> should only be difference with defrag=3Dalways, which is direct reclai=
m
>> with __GFP_NORETRY, Andrea's patch would drop __GFP_THISNODE and your
>> not. Maybe Zi Yan can do the same kind of tests with Andrea's patch [1=
]
>> to confirm?
>
> Yes, that is the only difference and that is why I've said those patche=
s
> are mostly similar. I do not want to touch defrag=3Dalways case because=

> this one has always been stall prone and we have replaced it as a
> default just because of that. We should discuss what should be done wit=
h
> that case separately IMHO.

Vlastimil, my test using Andrea=E2=80=99s patch confirms your statement.
My test result of Andrea=E2=80=99s patch shows that it gives the same out=
comes as
Michal=E2=80=99s patch except that when no madvise is used, THP is on by =
default
+ defrag =3D {always}, instead of swapping pages to disk, Adndrea=E2=80=99=
s patch
causes no swapping and THPs are allocated in the fallback node.

As I said before, the fundamental issue that causes swapping pages to dis=
k
when allocating THPs in a filled node is __GFP_THISNODE removes all fallb=
ack
zone/node options, thus,  __GFP_KSWAPD_RECLAIM or __GFP_DIRECT_RECLAIM
can only swap pages out to satisfy the THP allocation request.

__GFP_THISNODE can be seen as a kernel-version MPOL_BIND policy, which
overwrites any user space memory policy and should be removed or limited
to kernel-only page allocations. But, as Michal said, we could discuss
this further but do not make this discussion on the critical path of merg=
ing
the patch.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_D9E5D2C2-827E-48AC-B838-A1431C8687DE_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluRHwoWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzAOiB/9isGau2KC2dEMv/AzYGsJqAmh3
0pBDPs5aNVj4S9W+E7y+1tGmRpCmwXC3q/Q5dJemcSb0qYMay3g3E6XnGV8XbwLS
dx6buvrZCU6P1/0u9C2PNIJDphmyk2PqmkRF4rF5paap/SYa1yJdW0iqWW9bGQ+x
yhDUDwN+oXtMpXCzqgX9fDegRkP5dg53UOe6Eu2bCvn3KJVOGIJfOXwkAnWZ3K19
zrl1vimnY1vA9dq9Q5aiV3Va79yGRuxIyx8EOvZWLIMR5IP9Kz1gO8EJXWSB6GkL
inApHpsOIavAgdd54GkthljflS9wuLa51BiFprQhThqlPusmlLL8whn9YXOh
=qq0J
-----END PGP SIGNATURE-----

--=_MailMate_D9E5D2C2-827E-48AC-B838-A1431C8687DE_=--
