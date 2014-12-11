Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id C14946B0071
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 08:56:39 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id l89so3786555qgf.13
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 05:56:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c9si1351986qci.18.2014.12.11.05.56.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 05:56:38 -0800 (PST)
Message-ID: <5489A284.6030702@redhat.com>
Date: Thu, 11 Dec 2014 14:56:20 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add fields for compound destructor and order into
 struct page
References: <1418304027-154173-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1418304027-154173-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="iwN5tiefGvVJUGPTtOTn1Q5kPM45bQjlB"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org
Cc: cl@linux.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iwN5tiefGvVJUGPTtOTn1Q5kPM45bQjlB
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/11/2014 02:20 PM, Kirill A. Shutemov wrote:
> Currently, we use lru.next/lru.prev plus cast to access or set
> destructor and order of compound page.
>=20
> Let's replace it with explicit fields in struct page.

Thanks! That made everything much clearer: the complexity of page struct
should not be swept under the carpet.

>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/mm.h       | 9 ++++-----
>  include/linux/mm_types.h | 8 ++++++++
>  2 files changed, 12 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5bfd9b9756fa..a8de6fe11d0a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -525,29 +525,28 @@ int split_free_page(struct page *page);
>   * prototype for that function and accessor functions.
>   * These are _only_ valid on the head of a PG_compound page.
>   */
> -typedef void compound_page_dtor(struct page *);
> =20
>  static inline void set_compound_page_dtor(struct page *page,
>  						compound_page_dtor *dtor)
>  {
> -	page[1].lru.next =3D (void *)dtor;
> +	page[1].compound_dtor =3D dtor;
>  }
> =20
>  static inline compound_page_dtor *get_compound_page_dtor(struct page *=
page)
>  {
> -	return (compound_page_dtor *)page[1].lru.next;
> +	return page[1].compound_dtor;
>  }
> =20
>  static inline int compound_order(struct page *page)
>  {
>  	if (!PageHead(page))
>  		return 0;
> -	return (unsigned long)page[1].lru.prev;
> +	return page[1].compound_order;
>  }
> =20
>  static inline void set_compound_order(struct page *page, unsigned long=
 order)
>  {
> -	page[1].lru.prev =3D (void *)order;
> +	page[1].compound_order =3D order;
>  }
> =20
>  #ifdef CONFIG_MMU
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 03945eef1350..cbc71f32a53c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -28,6 +28,8 @@ struct mem_cgroup;
>  		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
>  #define ALLOC_SPLIT_PTLOCKS	(SPINLOCK_SIZE > BITS_PER_LONG/8)
> =20
> +typedef void compound_page_dtor(struct page *);
> +
>  /*
>   * Each physical page in the system has a struct page associated with
>   * it to keep track of whatever it is we are using the page for at the=

> @@ -131,6 +133,12 @@ struct page {
>  		struct rcu_head rcu_head;	/* Used by SLAB
>  						 * when destroying via RCU
>  						 */
> +		/* First tail page of compound page */
> +		struct {
> +			compound_page_dtor *compound_dtor;
> +			unsigned long compound_order;
> +		};
> +
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
>  		pgtable_t pmd_huge_pte; /* protected by page->ptl */
>  #endif
>=20



--iwN5tiefGvVJUGPTtOTn1Q5kPM45bQjlB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUiaKEAAoJEHTzHJCtsuoCs9YH/RVB8pVXvqIjyuPqAfHiwJ2n
t169lG/kRZNszJwsT86L5QhmAFtGWW7WS+GU+STSVZOXB5rqYZLselsCa/pQVWlb
GAq1AXm2X0NPj9ioRZK+kPxu64+PUT0005qOuyFFkhLxd5JkNWdSQ/rANE7JYdqr
jh32u+53svlLogwZ5CnE2eliQdXcrRCAE7xFN3asMz2N1zLhc7oTxeO7IkhCkg1O
mcIJx+0O8nw8uPf45QeqzZhHRXkSfDqHPzH6kkomakp2YgIdO4XmPrPCDFN/hvFE
oN+rVPraZPouPb7Z1tbn+C7Cd/ykb/Qfs78AmLU0Ag9ZGsrxx+1r5QXrZqlakdE=
=+mLO
-----END PGP SIGNATURE-----

--iwN5tiefGvVJUGPTtOTn1Q5kPM45bQjlB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
