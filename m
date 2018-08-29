Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 846566B4E1D
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 18:54:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l7-v6so6108023qte.2
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 15:54:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6-v6sor2852825qka.101.2018.08.29.15.54.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 15:54:27 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Date: Wed, 29 Aug 2018 18:54:23 -0400
Message-ID: <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
In-Reply-To: <20180829192451.GG10223@dhcp22.suse.cz>
References: <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_FE2862A9-325D-4704-B31B-BB2D3F69E64D_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_FE2862A9-325D-4704-B31B-BB2D3F69E64D_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Michal,

<snip>
>
> Fixes: 5265047ac301 ("mm, thp: really limit transparent hugepage alloca=
tion to local node")
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Debugged-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/mempolicy.h |  2 ++
>  mm/huge_memory.c          | 25 +++++++++++++++++--------
>  mm/mempolicy.c            | 28 +---------------------------
>  3 files changed, 20 insertions(+), 35 deletions(-)
>
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5228c62af416..bac395f1d00a 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -139,6 +139,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct =
shared_policy *sp,
>  struct mempolicy *get_task_policy(struct task_struct *p);
>  struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
>  		unsigned long addr);
> +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> +						unsigned long addr);
>  bool vma_policy_mof(struct vm_area_struct *vma);
>
>  extern void numa_default_policy(void);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c3bc7e9c9a2a..94472bf9a31b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -629,21 +629,30 @@ static vm_fault_t __do_huge_pmd_anonymous_page(st=
ruct vm_fault *vmf,
>   *	    available
>   * never: never stall for any thp allocation
>   */
> -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struc=
t *vma)
> +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struc=
t *vma, unsigned long addr)
>  {
>  	const bool vma_madvised =3D !!(vma->vm_flags & VM_HUGEPAGE);
> +	gfp_t this_node =3D 0;
> +	struct mempolicy *pol;
> +
> +#ifdef CONFIG_NUMA
> +	/* __GFP_THISNODE makes sense only if there is no explicit binding */=

> +	pol =3D get_vma_policy(vma, addr);
> +	if (pol->mode !=3D MPOL_BIND)
> +		this_node =3D __GFP_THISNODE;
> +#endif
>
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hu=
gepage_flags))
> -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
> +		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | this_node=
);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hu=
gepage_flags))
> -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transp=
arent_hugepage_flags))
>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -							     __GFP_KSWAPD_RECLAIM);
> +							     __GFP_KSWAPD_RECLAIM | this_node);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_=
hugepage_flags))
>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -							     0);
> -	return GFP_TRANSHUGE_LIGHT;
> +							     this_node);
> +	return GFP_TRANSHUGE_LIGHT | this_node;
>  }
>
>  /* Caller must hold page table lock. */
> @@ -715,7 +724,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fau=
lt *vmf)
>  			pte_free(vma->vm_mm, pgtable);
>  		return ret;
>  	}
> -	gfp =3D alloc_hugepage_direct_gfpmask(vma);
> +	gfp =3D alloc_hugepage_direct_gfpmask(vma, haddr);
>  	page =3D alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
>  	if (unlikely(!page)) {
>  		count_vm_event(THP_FAULT_FALLBACK);
> @@ -1290,7 +1299,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *v=
mf, pmd_t orig_pmd)
>  alloc:
>  	if (transparent_hugepage_enabled(vma) &&
>  	    !transparent_hugepage_debug_cow()) {
> -		huge_gfp =3D alloc_hugepage_direct_gfpmask(vma);
> +		huge_gfp =3D alloc_hugepage_direct_gfpmask(vma, haddr);
>  		new_page =3D alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDE=
R);
>  	} else
>  		new_page =3D NULL;
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index da858f794eb6..75bbfc3d6233 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1648,7 +1648,7 @@ struct mempolicy *__get_vma_policy(struct vm_area=
_struct *vma,
>   * freeing by another task.  It is the caller's responsibility to free=
 the
>   * extra reference for shared policies.
>   */
> -static struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
>  						unsigned long addr)
>  {
>  	struct mempolicy *pol =3D __get_vma_policy(vma, addr);
> @@ -2026,32 +2026,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_=
area_struct *vma,
>  		goto out;
>  	}
>
> -	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
> -		int hpage_node =3D node;
> -
> -		/*
> -		 * For hugepage allocation and non-interleave policy which
> -		 * allows the current node (or other explicitly preferred
> -		 * node) we only try to allocate from the current/preferred
> -		 * node and don't fall back to other nodes, as the cost of
> -		 * remote accesses would likely offset THP benefits.
> -		 *
> -		 * If the policy is interleave, or does not allow the current
> -		 * node in its nodemask, we allocate the standard way.
> -		 */
> -		if (pol->mode =3D=3D MPOL_PREFERRED &&
> -						!(pol->flags & MPOL_F_LOCAL))
> -			hpage_node =3D pol->v.preferred_node;
> -
> -		nmask =3D policy_nodemask(gfp, pol);
> -		if (!nmask || node_isset(hpage_node, *nmask)) {
> -			mpol_cond_put(pol);
> -			page =3D __alloc_pages_node(hpage_node,
> -						gfp | __GFP_THISNODE, order);
> -			goto out;
> -		}
> -	}
> -
>  	nmask =3D policy_nodemask(gfp, pol);
>  	preferred_nid =3D policy_node(gfp, pol, node);
>  	page =3D __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
> -- =

> 2.18.0
>

Thanks for your patch.

I tested it against Linus=E2=80=99s tree with =E2=80=9Cmemhog -r3 130g=E2=
=80=9D in a two-socket machine with 128GB memory on
each node and got the results below. I expect this test should fill one n=
ode, then fall back to the other.

1. madvise(MADV_HUGEPAGE) + defrag =3D {always, madvise, defer+madvise}: =
no swap, THPs are allocated in the fallback node.
2. madvise(MADV_HUGEPAGE) + defrag =3D defer: pages got swapped to the di=
sk instead of being allocated in the fallback node.
3. no madvise, THP is on by default + defrag =3D {always, defer, defer+ma=
dvise}: pages got swapped to the disk instead of
being allocated in the fallback node.
4. no madvise, THP is on by default + defrag =3D madvise: no swap, base p=
ages are allocated in the fallback node.

The result 2 and 3 seems unexpected, since pages should be allocated in t=
he fallback node.

The reason, as Andrea mentioned in his email, is that the combination of =
__THIS_NODE and __GFP_DIRECT_RECLAIM (plus __GFP_KSWAPD_RECLAIM from this=
 experiment). __THIS_NODE uses ZONELIST_NOFALLBACK, which removes the fal=
lback possibility
and __GFP_*_RECLAIM triggers page reclaim in the first page allocation no=
de when fallback nodes are removed by
ZONELIST_NOFALLBACK.

IMHO, __THIS_NODE should not be used for user memory allocation at all, s=
ince it fights against most of memory policies.
But kernel memory allocation would need it as a kernel MPOL_BIND memory p=
olicy.

Comments?

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_FE2862A9-325D-4704-B31B-BB2D3F69E64D_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluHJB8WHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzOxHB/983iITcDg04Zp1mrbbay5O5YZn
Ii3e1/DdMh7S4LufCvZJ/EhJ23ypz7MZpVG/MYog6JlIjdXpxn//3nDUmARrgck+
fMGTICyMlSPudNonlHmRk36rWva4zXhh9kIAWuvutkf1kj3OnUvkH4VaBM/CA+VM
zgmj+i12vr3vni0Nw8VmjyXKeXMJSG3xPfaTgFgBJpKUPEqX5h0nPUSOlE4+5WEH
896KdI3nGIth+70DbK7eed571ASDZgzWSUj/stv8FuBNscqFjOYbGDfLB9tYXCH4
+5JVMv8OMoNw+4dnZsMkHZEP9zyXGRopJBh3bFaYLwTv600+iFTYu76rYt9b
=tmnF
-----END PGP SIGNATURE-----

--=_MailMate_FE2862A9-325D-4704-B31B-BB2D3F69E64D_=--
