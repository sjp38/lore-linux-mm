Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7CD6B0010
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 17:51:44 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id m1-v6so10001399qtb.18
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 14:51:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22-v6sor3069617qtg.98.2018.10.04.14.51.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 14:51:43 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
Date: Thu, 04 Oct 2018 17:49:47 -0400
Message-ID: <EA62D612-B537-435A-AF5B-96E49E878E0F@cs.rutgers.edu>
In-Reply-To: <alpine.DEB.2.21.1810041317010.16935@chino.kir.corp.google.com>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-3-mhocko@kernel.org>
 <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
 <alpine.DEB.2.21.1810041317010.16935@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_B0E3F981-2CAE-4D98-A298-416090ED4D89_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_B0E3F981-2CAE-4D98-A298-416090ED4D89_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 4 Oct 2018, at 16:17, David Rientjes wrote:

> On Wed, 26 Sep 2018, Kirill A. Shutemov wrote:
>
>> On Tue, Sep 25, 2018 at 02:03:26PM +0200, Michal Hocko wrote:
>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>> index c3bc7e9c9a2a..c0bcede31930 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -629,21 +629,40 @@ static vm_fault_t __do_huge_pmd_anonymous_page(=
struct vm_fault *vmf,
>>>   *	    available
>>>   * never: never stall for any thp allocation
>>>   */
>>> -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_str=
uct *vma)
>>> +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_str=
uct *vma, unsigned long addr)
>>>  {
>>>  	const bool vma_madvised =3D !!(vma->vm_flags & VM_HUGEPAGE);
>>> +	gfp_t this_node =3D 0;
>>> +
>>> +#ifdef CONFIG_NUMA
>>> +	struct mempolicy *pol;
>>> +	/*
>>> +	 * __GFP_THISNODE is used only when __GFP_DIRECT_RECLAIM is not
>>> +	 * specified, to express a general desire to stay on the current
>>> +	 * node for optimistic allocation attempts. If the defrag mode
>>> +	 * and/or madvise hint requires the direct reclaim then we prefer
>>> +	 * to fallback to other node rather than node reclaim because that
>>> +	 * can lead to excessive reclaim even though there is free memory
>>> +	 * on other nodes. We expect that NUMA preferences are specified
>>> +	 * by memory policies.
>>> +	 */
>>> +	pol =3D get_vma_policy(vma, addr);
>>> +	if (pol->mode !=3D MPOL_BIND)
>>> +		this_node =3D __GFP_THISNODE;
>>> +	mpol_cond_put(pol);
>>> +#endif
>>
>> I'm not very good with NUMA policies. Could you explain in more detail=
s how
>> the code above is equivalent to the code below?
>>
>
> It breaks mbind() because new_page() is now using numa_node_id() to
> allocate migration targets for instead of using the mempolicy.  I'm not=

> sure that this patch was tested for mbind().

I do not see mbind() is broken. With both patches applied, I ran
"numactl -N 0 memhog -r1 4096m membind 1" and saw all pages are allocated=

in Node 1 not Node 0, which is returned by numa_node_id().

=46rom the source code, in alloc_pages_vma(), the nodemask is generated
from the memory policy (i.e. mbind in the case above), which only has
the nodes specified by mbind(). Then, __alloc_pages_nodemask() only uses
the zones from the nodemask. The numa_node_id() return value will be
ignored in the actual page allocation process if mbind policy is applied.=


Let me know if I miss anything.


--
Best Regards
Yan Zi

--=_MailMate_B0E3F981-2CAE-4D98-A298-416090ED4D89_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlu2ivsWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzCkeB/0c9VbvakI//1xIB6mRu1v+Rr3R
T2SzbshLuiKaJ0+PdjXaTYKbXamD0UoPpKrqic908yd9lx4rdGKpKuiMUclQTlQN
d792YKyiSFO3hEB1EJGPbeEhHEl8Inf28rJCtleJRrBkPqWj9+w1FHxzlk8bayif
oKaxQC8lZ17UoLxdtm40te5onbrkHg6dsfctWpGiqzJo02VNWaAkVWDbVztFA1mp
cJXIyB+XwlraxyOKLR90cUh+0u7s4mjaF82Pfbl1NOCjjlcMB/3yMnXHSEMLzlqh
JcM977Gr0fbWJouDKsOBQaW11NnqL/Tv7CnbrDmuqHlijeF3KGXcXvsK7jKU
=0fQi
-----END PGP SIGNATURE-----

--=_MailMate_B0E3F981-2CAE-4D98-A298-416090ED4D89_=--
