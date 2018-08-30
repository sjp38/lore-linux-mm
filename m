Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 152586B51B3
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:22:26 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u195-v6so7564827qka.14
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 06:22:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t29-v6sor3898160qtc.55.2018.08.30.06.22.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 06:22:25 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Date: Thu, 30 Aug 2018 09:22:21 -0400
Message-ID: <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu>
In-Reply-To: <20180830070021.GB2656@dhcp22.suse.cz>
References: <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <20180830070021.GB2656@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_B4B7C5F3-0291-40A0-8DE4-135C38397D8E_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_B4B7C5F3-0291-40A0-8DE4-135C38397D8E_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 30 Aug 2018, at 3:00, Michal Hocko wrote:

> On Wed 29-08-18 18:54:23, Zi Yan wrote:
> [...]
>> I tested it against Linus=E2=80=99s tree with =E2=80=9Cmemhog -r3 130g=
=E2=80=9D in a two-socket machine with 128GB memory on
>> each node and got the results below. I expect this test should fill on=
e node, then fall back to the other.
>>
>> 1. madvise(MADV_HUGEPAGE) + defrag =3D {always, madvise, defer+madvise=
}:
>> no swap, THPs are allocated in the fallback node.
>> 2. madvise(MADV_HUGEPAGE) + defrag =3D defer: pages got swapped to the=

>> disk instead of being allocated in the fallback node.
>> 3. no madvise, THP is on by default + defrag =3D {always, defer,
>> defer+madvise}: pages got swapped to the disk instead of being
>> allocated in the fallback node.
>> 4. no madvise, THP is on by default + defrag =3D madvise: no swap, bas=
e
>> pages are allocated in the fallback node.
>>
>> The result 2 and 3 seems unexpected, since pages should be allocated i=
n the fallback node.
>>
>> The reason, as Andrea mentioned in his email, is that the combination
>> of __THIS_NODE and __GFP_DIRECT_RECLAIM (plus __GFP_KSWAPD_RECLAIM
>> from this experiment).
>
> But we do not set __GFP_THISNODE along with __GFP_DIRECT_RECLAIM AFAICS=
=2E
> We do for __GFP_KSWAPD_RECLAIM though and I guess that it is expected t=
o
> see kswapd do the reclaim to balance the node. If the node is full of
> anonymous pages then there is no other way than swap out.

GFP_TRANSHUGE implies __GFP_DIRECT_RECLAIM. When no madvise is given, THP=
 is on
+ defrag=3Dalways, gfp_mask has __GFP_THISNODE and __GFP_DIRECT_RECLAIM, =
so swapping
can be triggered.

The key issue here is that =E2=80=9Cmemhog -r3 130g=E2=80=9D uses the def=
ault memory policy (MPOL_DEFAULT),
which should allow page allocation fallback to other nodes, but as shown =
in
result 3, swapping is triggered instead of page allocation fallback.

>
>> __THIS_NODE uses ZONELIST_NOFALLBACK, which
>> removes the fallback possibility and __GFP_*_RECLAIM triggers page
>> reclaim in the first page allocation node when fallback nodes are
>> removed by ZONELIST_NOFALLBACK.
>
> Yes but the point is that the allocations which use __GFP_THISNODE are
> optimistic so they shouldn't fallback to remote NUMA nodes.

This can be achieved by using MPOL_BIND memory policy which restricts
nodemask in struct alloc_context for user space memory allocations.

>
>> IMHO, __THIS_NODE should not be used for user memory allocation at
>> all, since it fights against most of memory policies.  But kernel
>> memory allocation would need it as a kernel MPOL_BIND memory policy.
>
> __GFP_THISNODE is indeed an ugliness. I would really love to get rid of=

> it here. But the problem is that optimistic THP allocations should
> prefer a local node because a remote node might easily offset the
> advantage of the THP. I do not have a great idea how to achieve that
> without __GFP_THISNODE though.

MPOL_PREFERRED memory policy can be used to achieve this optimistic THP a=
llocation
for user space. Even with the default memory policy, local memory node wi=
ll be used
first until it is full. It seems to me that __GFP_THISNODE is not necessa=
ry
if a proper memory policy is used.

Let me know if I miss anything. Thanks.


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_B4B7C5F3-0291-40A0-8DE4-135C38397D8E_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluH740WHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzKvnB/9iCios47tFp6xIXvp3SIb4bZNy
heWhz6G5xK3aLMwu3Lna7WECUZdk4I50ioeaZxF+CjbTaMRFyQRjvcjQQ5nYfUFe
bPknPKSWX2Nsh0nN1PWmKtTKHWlP3+b9J0LgsHWbcb5q76LhKQgP0i/D76eC4yxz
SBZW4LH/fXwDkiBwYVJi6cnnUlS3b+5A5zUzfolOqSzZMpWwz0GDL6n+qoQ5w0qJ
NfzlxPE+/NBOt2VnHhsQpBxCAyMnlIkfvRvXpcqYptpg2Eu9A1s2uEAkihXTDYDT
+YrQY2CRQ2Xsr5cJGxmxik5jLaoWWYKKkFsovKCQ11m/TVcM2XXnlQZR4NEo
=khvl
-----END PGP SIGNATURE-----

--=_MailMate_B4B7C5F3-0291-40A0-8DE4-135C38397D8E_=--
