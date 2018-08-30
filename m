Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8309C6B51E3
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:02:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z44-v6so7897153qtg.5
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:02:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k84-v6sor3456342qkh.117.2018.08.30.07.02.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 07:02:27 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Date: Thu, 30 Aug 2018 10:02:23 -0400
Message-ID: <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
In-Reply-To: <20180830134549.GI2656@dhcp22.suse.cz>
References: <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <20180830070021.GB2656@dhcp22.suse.cz>
 <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu>
 <20180830134549.GI2656@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_B5CB7FF7-11E9-48B2-A98D-D464233EFFA4_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_B5CB7FF7-11E9-48B2-A98D-D464233EFFA4_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 30 Aug 2018, at 9:45, Michal Hocko wrote:

> On Thu 30-08-18 09:22:21, Zi Yan wrote:
>> On 30 Aug 2018, at 3:00, Michal Hocko wrote:
>>
>>> On Wed 29-08-18 18:54:23, Zi Yan wrote:
>>> [...]
>>>> I tested it against Linus=E2=80=99s tree with =E2=80=9Cmemhog -r3 13=
0g=E2=80=9D in a two-socket machine with 128GB memory on
>>>> each node and got the results below. I expect this test should fill =
one node, then fall back to the other.
>>>>
>>>> 1. madvise(MADV_HUGEPAGE) + defrag =3D {always, madvise, defer+madvi=
se}:
>>>> no swap, THPs are allocated in the fallback node.
>>>> 2. madvise(MADV_HUGEPAGE) + defrag =3D defer: pages got swapped to t=
he
>>>> disk instead of being allocated in the fallback node.
>>>> 3. no madvise, THP is on by default + defrag =3D {always, defer,
>>>> defer+madvise}: pages got swapped to the disk instead of being
>>>> allocated in the fallback node.
>>>> 4. no madvise, THP is on by default + defrag =3D madvise: no swap, b=
ase
>>>> pages are allocated in the fallback node.
>>>>
>>>> The result 2 and 3 seems unexpected, since pages should be allocated=
 in the fallback node.
>>>>
>>>> The reason, as Andrea mentioned in his email, is that the combinatio=
n
>>>> of __THIS_NODE and __GFP_DIRECT_RECLAIM (plus __GFP_KSWAPD_RECLAIM
>>>> from this experiment).
>>>
>>> But we do not set __GFP_THISNODE along with __GFP_DIRECT_RECLAIM AFAI=
CS.
>>> We do for __GFP_KSWAPD_RECLAIM though and I guess that it is expected=
 to
>>> see kswapd do the reclaim to balance the node. If the node is full of=

>>> anonymous pages then there is no other way than swap out.
>>
>> GFP_TRANSHUGE implies __GFP_DIRECT_RECLAIM. When no madvise is given, =
THP is on
>> + defrag=3Dalways, gfp_mask has __GFP_THISNODE and __GFP_DIRECT_RECLAI=
M, so swapping
>> can be triggered.
>
> Yes, but the setup tells that you are willing to pay price to get a THP=
=2E
> defered=3Dalways uses that special __GFP_NORETRY (unless it is madvised=

> mapping) that should back off if the compaction failed recently. How
> much that reduces the reclaim is not really clear to me right now to be=

> honest.
>
>> The key issue here is that =E2=80=9Cmemhog -r3 130g=E2=80=9D uses the =
default memory policy (MPOL_DEFAULT),
>> which should allow page allocation fallback to other nodes, but as sho=
wn in
>> result 3, swapping is triggered instead of page allocation fallback.
>
> Well, I guess this really depends. Fallback to a different node might b=
e
> seen as a bad thing and worse than the reclaim on the local node.
>
>>>> __THIS_NODE uses ZONELIST_NOFALLBACK, which
>>>> removes the fallback possibility and __GFP_*_RECLAIM triggers page
>>>> reclaim in the first page allocation node when fallback nodes are
>>>> removed by ZONELIST_NOFALLBACK.
>>>
>>> Yes but the point is that the allocations which use __GFP_THISNODE ar=
e
>>> optimistic so they shouldn't fallback to remote NUMA nodes.
>>
>> This can be achieved by using MPOL_BIND memory policy which restricts
>> nodemask in struct alloc_context for user space memory allocations.
>
> Yes, but that requires and explicit NUMA handling. And we are trying to=

> handle those cases which do not really give a damn and just want to use=

> THP if it is available or try harder when they ask by using madvise.
>
>>>> IMHO, __THIS_NODE should not be used for user memory allocation at
>>>> all, since it fights against most of memory policies.  But kernel
>>>> memory allocation would need it as a kernel MPOL_BIND memory policy.=

>>>
>>> __GFP_THISNODE is indeed an ugliness. I would really love to get rid =
of
>>> it here. But the problem is that optimistic THP allocations should
>>> prefer a local node because a remote node might easily offset the
>>> advantage of the THP. I do not have a great idea how to achieve that
>>> without __GFP_THISNODE though.
>>
>> MPOL_PREFERRED memory policy can be used to achieve this optimistic
>> THP allocation for user space. Even with the default memory policy,
>> local memory node will be used first until it is full. It seems to
>> me that __GFP_THISNODE is not necessary if a proper memory policy is
>> used.
>>
>> Let me know if I miss anything. Thanks.
>
> You are missing that we are trying to define a sensible model for those=

> who do not really care about mempolicies. THP shouldn't cause more harm=

> than good for those.
>
> I wish we could come up with a remotely sane and comprehensible model.
> That means that you know how hard the allocator tries to get a THP for
> you depending on the defrag configuration, your memory policy and your
> madvise setting. The easiest one I can think of is to
> - always follow mempolicy when specified because you asked for it
>   explicitly
> - stay node local and low latency for the light THP defrag mode (defrag=
,
>   madvise without hint and none) because THP is a nice to have
> - if the defrag mode is always then you are willing to pay the latency
>   price but off-node might be still a no-no.
> - allow fallback for madvised mappings because you really want THP. If
>   you care about specific numa placement then combine with the
>   mempolicy.
>
> As you can see I do not really mention anything about the direct reclai=
m
> because that is just an implementation detail of the page allocator and=

> compaction interaction.
>
> Maybe you can formulate a saner matrix with all the available modes tha=
t
> we have.
>
> Anyway, I guess we can agree that (almost) unconditional __GFP_THISNODE=

> is clearly wrong and we should address that first. Either Andrea's
> option 2) patch or mine which does the similar thing except at the
> proper layer (I believe). We can continue discussing other odd cases on=

> top I guess. Unless somebody has much brighter idea, of course.

Thanks for your explanation. It makes sense to me. I am fine with your pa=
tch.
You can add my Tested-by: Zi Yan <zi.yan@cs.rutgers.edu>, since
my test result 1 shows that the problem mentioned in your changelog is so=
lved.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_B5CB7FF7-11E9-48B2-A98D-D464233EFFA4_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluH+O8WHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzJpXCACb+k2paZHZ4BoInEOskGHJDj+8
Dvk7NXpYD7DoyHvRG+kuMr62bYM3W4yUg5s42zAlTBroEXIL98AA3VjMFm9UXt5T
LumKzPKRMTr+1kFFNFzjDs1uSiAmIss3MDGjD1PWrrNAz0PNQXIhHo0TlN1SrPLU
J7JkoBUEVDuTjYgLzCY8Ud5UN35401AqeRfw0tIVm6WYSLE6wQXYbFaRCUmEgPBf
iT0zq5K+cpNHpy0TpRiHoQvTXSReB51oTspCF5sn3SzIlzywtpV5BO7BE7Y72NBL
1u5TBc3MTJU/kAGCAxJPHMRJWuuLIDQIPsb5IoxSiSmpbhja1rSwFOgd2lim
=auSw
-----END PGP SIGNATURE-----

--=_MailMate_B5CB7FF7-11E9-48B2-A98D-D464233EFFA4_=--
