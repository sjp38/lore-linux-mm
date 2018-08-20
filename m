Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5AA6B1914
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 08:35:21 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c22-v6so8921797qkb.18
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 05:35:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h49-v6sor4042983qvi.50.2018.08.20.05.35.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 05:35:20 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise ||
 always
Date: Mon, 20 Aug 2018 08:35:17 -0400
Message-ID: <6D0E157B-3ECC-4642-BF98-FEB884D49854@cs.rutgers.edu>
In-Reply-To: <20180820032204.9591-3-aarcange@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_C090D5E4-E7CC-487A-B14D-FA060FC3E069_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_C090D5E4-E7CC-487A-B14D-FA060FC3E069_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 19 Aug 2018, at 23:22, Andrea Arcangeli wrote:

<snip>
>
> Reported-by: Alex Williamson <alex.williamson@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/gfp.h | 18 ++++++++++++++++++
>  mm/mempolicy.c      | 12 +++++++++++-
>  mm/page_alloc.c     |  4 ++++
>  3 files changed, 33 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index a6afcec53795..3c04d5d90e6d 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -44,6 +44,7 @@ struct vm_area_struct;
>  #else
>  #define ___GFP_NOLOCKDEP	0
>  #endif
> +#define ___GFP_ONLY_COMPACT	0x1000000u
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>
>  /*
> @@ -178,6 +179,21 @@ struct vm_area_struct;
>   *   definitely preferable to use the flag rather than opencode endles=
s
>   *   loop around allocator.
>   *   Using this flag for costly allocations is _highly_ discouraged.
> + *
> + * __GFP_ONLY_COMPACT: Only invoke compaction. Do not try to succeed
> + * the allocation by freeing memory. Never risk to free any
> + * "PAGE_SIZE" memory unit even if compaction failed specifically
> + * because of not enough free pages in the zone. This only makes sense=

> + * only in combination with __GFP_THISNODE (enforced with a
> + * VM_WARN_ON), to restrict the THP allocation in the local node that
> + * triggered the page fault and fallback into PAGE_SIZE allocations in=

> + * the same node. We don't want to invoke reclaim because there may be=

> + * plenty of free memory already in the local node. More importantly
> + * there may be even plenty of free THP available in remote nodes so
> + * we should allocate those if something instead of reclaiming any
> + * memory in the local node. Implementation detail: set ___GFP_NORETRY=

> + * too so that ___GFP_ONLY_COMPACT only needs to be checked in a slow
> + * path.
>   */
>  #define __GFP_IO	((__force gfp_t)___GFP_IO)
>  #define __GFP_FS	((__force gfp_t)___GFP_FS)
> @@ -187,6 +203,8 @@ struct vm_area_struct;
>  #define __GFP_RETRY_MAYFAIL	((__force gfp_t)___GFP_RETRY_MAYFAIL)
>  #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
>  #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
> +#define __GFP_ONLY_COMPACT	((__force gfp_t)(___GFP_NORETRY | \
> +						 ___GFP_ONLY_COMPACT))
>
>  /*
>   * Action modifiers
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index d6512ef28cde..6bf839f20dcc 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2047,8 +2047,18 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_=
area_struct *vma,
>
>  		if (!nmask || node_isset(hpage_node, *nmask)) {
>  			mpol_cond_put(pol);
> +			/*
> +			 * We restricted the allocation to the
> +			 * hpage_node so we must use
> +			 * __GFP_ONLY_COMPACT to allow at most a
> +			 * compaction attempt and not ever get into
> +			 * reclaim or it'll swap heavily with
> +			 * transparent_hugepage/defrag =3D always (or
> +			 * madvise under MADV_HUGEPAGE).
> +			 */
>  			page =3D __alloc_pages_node(hpage_node,
> -						gfp | __GFP_THISNODE, order);
> +						  gfp | __GFP_THISNODE |
> +						  __GFP_ONLY_COMPACT, order);
>  			goto out;
>  		}
>  	}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a790ef4be74e..01a5c2bd0860 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4144,6 +4144,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned =
int order,
>  			 */
>  			if (compact_result =3D=3D COMPACT_DEFERRED)
>  				goto nopage;
> +			if (gfp_mask & __GFP_ONLY_COMPACT) {
> +				VM_WARN_ON(!(gfp_mask & __GFP_THISNODE));
> +				goto nopage;
> +			}
>
>  			/*
>  			 * Looks like reclaim/compaction is worth trying, but


I think this can also be triggered in khugepaged. In collapse_huge_page()=
, khugepaged_alloc_page()
would also cause DIRECT_RECLAIM if defrag=3D=3Dalways, since GFP_TRANSHUG=
E implies __GFP_DIRECT_RECLAIM.

But is it an expected behavior of khugepaged?


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_C090D5E4-E7CC-487A-B14D-FA060FC3E069_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlt6tYUWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzDdXCACzEbXRWtcqe4+Kmys6C79vB0hJ
801V1puagz17O2sFclOSH6HXQFEdGzw/O/QsewkvJRWKZkerL5qUkkZSfpqI4RND
MmwFx8OOAulfp4LN5fwjnmogvRO8Lw11nlPkDDhwPeyDMowt8kBHMN68z/1m3gNQ
fb06beOG06Z79kRtRP71t0akdSOvZKVD61OpE+W25Jle7ikTtnCQv5DquNLPo1sL
9t61V42OhwXEBwmdqOWpIMOUs4TdFZUzvmvhhFULFtUFnuvdDkReSTl9+BO22qlP
nzoQgL29BRWSqaau10rjDHmpFcsFVpUmtiukicx3EzbIwOLmxo+mzXGf5SFj
=panB
-----END PGP SIGNATURE-----

--=_MailMate_C090D5E4-E7CC-487A-B14D-FA060FC3E069_=--
