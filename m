Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2117A6B4C89
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 12:06:54 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y46-v6so5006395qth.9
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 09:06:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z20-v6sor2232600qvk.36.2018.08.29.09.06.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 09:06:53 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise ||
 always
Date: Wed, 29 Aug 2018 12:06:48 -0400
Message-ID: <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
In-Reply-To: <20180829154744.GC10223@dhcp22.suse.cz>
References: <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz> <20180822155250.GP13047@redhat.com>
 <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_B1C0315A-C451-40EA-82B6-61E845627729_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_B1C0315A-C451-40EA-82B6-61E845627729_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<snip>
>
> I do not like overwriting gfp flags like that. It is just ugly and erro=
r
> prone. A more proper way would be to handle that at the layer we play
> with __GFP_THISNODE. The resulting diff is larger though.

This makes sense to me.

>
> If there is a general concensus that this is growing too complicated
> then Andrea's patch (the second variant to overwrite gfp mask) is much
> simpler of course but I really detest the subtle gfp rewriting. I still=

> believe that all the nasty details should be covered at the single
> place.
>
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
> index a703c23f8bab..94472bf9a31b 100644
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
> -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | __GFP_THI=
SNODE);
> +		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | this_node=
);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hu=
gepage_flags))
> -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | __GFP_THISNODE;
> +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transp=
arent_hugepage_flags))
>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -							     __GFP_KSWAPD_RECLAIM | __GFP_THISNODE);
> +							     __GFP_KSWAPD_RECLAIM | this_node);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_=
hugepage_flags))
>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -							     __GFP_THISNODE);
> -	return GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
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
> index 9f0800885613..75bbfc3d6233 100644
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

The warning goes away with this change. I am OK with this patch (plus the=
 original one you sent out,
which could be merged with this one).

Thanks.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_B1C0315A-C451-40EA-82B6-61E845627729_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluGxJgWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzE3YB/4rhPY0b6SWym0VwgHkBbcHIhb+
/mcksAZpEyFqUJ9fXdLxjo9gdhkqt+xFBnphKJhDOTylRbtPOtfe33BG7/GcAzZ5
sLJl57ojNb3mDVBCYI2BQyLDCvwZcDJpFPKZiFgtaMoFinlna2S85Q6iFiX/HE0y
uXwySecdPslMVer2vsmvb9mQO7AiyoblhZvVHGQlSlqwsYDM9wEKiQGHltfICHt3
7g3cm9QBP7CJbIGyvb1vQ7yoLQTj+gPGzkWs5BpxVqdau8fZrb4YyiXGE1C1Fd27
+J8QvSoFHr4SpxPpS4p5TOp+25sUUm+VX5ZUDIoQ1ke2A0I8214U/FMAlMS3
=4diO
-----END PGP SIGNATURE-----

--=_MailMate_B1C0315A-C451-40EA-82B6-61E845627729_=--
