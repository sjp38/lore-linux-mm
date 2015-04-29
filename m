Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f41.google.com (mail-vn0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1BBF76B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 12:11:17 -0400 (EDT)
Received: by vnbg190 with SMTP id g190so3885285vnb.12
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:11:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id yn14si41340602vdb.73.2015.04.29.09.11.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 09:11:16 -0700 (PDT)
Message-ID: <5541029C.60207@redhat.com>
Date: Wed, 29 Apr 2015 18:11:08 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 16/28] mm, thp: remove compound_lock
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-17-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="RASj1PwBrQ8btWvopfh4g1jPWTkiUJ3BL"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RASj1PwBrQ8btWvopfh4g1jPWTkiUJ3BL
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> We are going to use migration entries to stabilize page counts. It mean=
s

By "stabilize" do you mean "protect" from concurrent access? I've seen
that you use the same term in seemingly the same sense several times (at
least in patches 15, 16, 23, 24 and 28).

Jerome

> we don't need compound_lock() for that.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  include/linux/mm.h         | 35 -----------------------------------
>  include/linux/page-flags.h | 12 +-----------
>  mm/debug.c                 |  3 ---
>  3 files changed, 1 insertion(+), 49 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index dd1b5f2b1966..dad667d99304 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -393,41 +393,6 @@ static inline int is_vmalloc_or_module_addr(const =
void *x)
> =20
>  extern void kvfree(const void *addr);
> =20
> -static inline void compound_lock(struct page *page)
> -{
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	VM_BUG_ON_PAGE(PageSlab(page), page);
> -	bit_spin_lock(PG_compound_lock, &page->flags);
> -#endif
> -}
> -
> -static inline void compound_unlock(struct page *page)
> -{
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	VM_BUG_ON_PAGE(PageSlab(page), page);
> -	bit_spin_unlock(PG_compound_lock, &page->flags);
> -#endif
> -}
> -
> -static inline unsigned long compound_lock_irqsave(struct page *page)
> -{
> -	unsigned long uninitialized_var(flags);
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	local_irq_save(flags);
> -	compound_lock(page);
> -#endif
> -	return flags;
> -}
> -
> -static inline void compound_unlock_irqrestore(struct page *page,
> -					      unsigned long flags)
> -{
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	compound_unlock(page);
> -	local_irq_restore(flags);
> -#endif
> -}
> -
>  /*
>   * The atomic page->_mapcount, starts from -1: so that transitions
>   * both from it and to it can be tracked, using atomic_inc_and_test
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 91b7f9b2b774..74b7cece1dfa 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -106,9 +106,6 @@ enum pageflags {
>  #ifdef CONFIG_MEMORY_FAILURE
>  	PG_hwpoison,		/* hardware poisoned page. Don't touch */
>  #endif
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	PG_compound_lock,
> -#endif
>  	__NR_PAGEFLAGS,
> =20
>  	/* Filesystems */
> @@ -683,12 +680,6 @@ static inline void ClearPageSlabPfmemalloc(struct =
page *page)
>  #define __PG_MLOCKED		0
>  #endif
> =20
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -#define __PG_COMPOUND_LOCK		(1 << PG_compound_lock)
> -#else
> -#define __PG_COMPOUND_LOCK		0
> -#endif
> -
>  /*
>   * Flags checked when a page is freed.  Pages being freed should not h=
ave
>   * these flags set.  It they are, there is a problem.
> @@ -698,8 +689,7 @@ static inline void ClearPageSlabPfmemalloc(struct p=
age *page)
>  	 1 << PG_private | 1 << PG_private_2 | \
>  	 1 << PG_writeback | 1 << PG_reserved | \
>  	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
> -	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
> -	 __PG_COMPOUND_LOCK)
> +	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON )
> =20
>  /*
>   * Flags checked when a page is prepped for return by the page allocat=
or.
> diff --git a/mm/debug.c b/mm/debug.c
> index 3eb3ac2fcee7..9dfcd77e7354 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -45,9 +45,6 @@ static const struct trace_print_flags pageflag_names[=
] =3D {
>  #ifdef CONFIG_MEMORY_FAILURE
>  	{1UL << PG_hwpoison,		"hwpoison"	},
>  #endif
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	{1UL << PG_compound_lock,	"compound_lock"	},
> -#endif
>  };
> =20
>  static void dump_flags(unsigned long flags,
>=20



--RASj1PwBrQ8btWvopfh4g1jPWTkiUJ3BL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQQKcAAoJEHTzHJCtsuoCqAYH+wREHT26pjunMcFq9mEt8Ugg
r25N+EVlCNGa4/opsLRk9EeUqPtrDNsvSAYtN3gM0FUh9+HjeQZitJlDsWLlvW+k
KgwPEMe6g+TwGYNcPaQDmLreeGVoiaLtFcCVJ/U5Sr2jTa7q4+Fe2DEkHBKu8KzW
+TQz5h+VqWLt9xcLPD7WgrSWRbdlEqGtb1CrGoRBINO+Yyz04qiGQn+AAF/L5csr
D0m4+HZM0ZdGi8/ORTzMZnxwZQ4gLBMNfkZVIQAkFmsMgo/0H4YAt5sLSCGfjUP8
M/pYTkVbwuzxVMtJTgffp+7+vlKl2DLEBUC/j6Smj4sudSF7baKcmGlY7F3mLSc=
=dY0Y
-----END PGP SIGNATURE-----

--RASj1PwBrQ8btWvopfh4g1jPWTkiUJ3BL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
