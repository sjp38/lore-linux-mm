Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 06A4A6B0005
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 02:38:06 -0500 (EST)
Date: Wed, 27 Feb 2013 02:36:04 -0500
From: Chen Gong <gong.chen@linux.intel.com>
Subject: Re: [PATCH 8/9] memory-hotplug: enable memory hotplug to handle
 hugepage
Message-ID: <20130227073604.GB30971@gchen.bj.intel.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hHWLQfXTYDoKhP50"
Content-Disposition: inline
In-Reply-To: <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 21, 2013 at 02:41:47PM -0500, Naoya Horiguchi wrote:
> Date: Thu, 21 Feb 2013 14:41:47 -0500
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> To: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>,
>  Hugh Dickins <hughd@google.com>, KOSAKI Motohiro
>  <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>,
>  linux-kernel@vger.kernel.org
> Subject: [PATCH 8/9] memory-hotplug: enable memory hotplug to handle
>  hugepage
>=20
> Currently we can't offline memory blocks which contain hugepages because
> a hugepage is considered as an unmovable page. But now with this patch
> series, a hugepage has become movable, so by using hugepage migration we
> can offline such memory blocks.
>=20
> What's different from other users of hugepage migration is that we need
> to decompose all the hugepages inside the target memory block into free
> buddy pages after hugepage migration, because otherwise free hugepages
> remaining in the memory block intervene the memory offlining.
> For this reason we introduce new functions dissolve_free_huge_page() and
> dissolve_free_huge_pages().
>=20
> Other than that, what this patch does is straightforwardly to add hugepage
> migration code, that is, adding hugepage code to the functions which scan
> over pfn and collect hugepages to be migrated, and adding a hugepage
> allocation function to alloc_migrate_target().
>=20
> As for larger hugepages (1GB for x86_64), it's not easy to do hotremove
> over them because it's larger than memory block. So we now simply leave
> it to fail as it is.
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/hugetlb.h |  8 ++++++++
>  mm/hugetlb.c            | 43 +++++++++++++++++++++++++++++++++++++++++
>  mm/memory_hotplug.c     | 51 ++++++++++++++++++++++++++++++++++++++++---=
------
>  mm/migrate.c            | 12 +++++++++++-
>  mm/page_alloc.c         | 12 ++++++++++++
>  mm/page_isolation.c     |  5 +++++
>  6 files changed, 121 insertions(+), 10 deletions(-)
>=20
> diff --git v3.8.orig/include/linux/hugetlb.h v3.8/include/linux/hugetlb.h
> index 86a4d78..e33f07f 100644
> --- v3.8.orig/include/linux/hugetlb.h
> +++ v3.8/include/linux/hugetlb.h
> @@ -70,6 +70,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
>  void putback_active_hugepage(struct page *page);
>  void putback_active_hugepages(struct list_head *l);
>  void migrate_hugepage_add(struct page *page, struct list_head *list);
> +int is_hugepage_movable(struct page *page);
>  void copy_huge_page(struct page *dst, struct page *src);
> =20
>  extern unsigned long hugepages_treat_as_movable;
> @@ -136,6 +137,7 @@ static inline int dequeue_hwpoisoned_huge_page(struct=
 page *page)
>  #define putback_active_hugepage(p) 0
>  #define putback_active_hugepages(l) 0
>  #define migrate_hugepage_add(p, l) 0
> +#define is_hugepage_movable(x) 0
>  static inline void copy_huge_page(struct page *dst, struct page *src)
>  {
>  }
> @@ -358,6 +360,10 @@ static inline int hstate_index(struct hstate *h)
>  	return h - hstates;
>  }
> =20
> +extern void dissolve_free_huge_page(struct page *page);
> +extern void dissolve_free_huge_pages(unsigned long start_pfn,
> +				     unsigned long end_pfn);
> +
>  #else
>  struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
> @@ -378,6 +384,8 @@ static inline unsigned int pages_per_huge_page(struct=
 hstate *h)
>  }
>  #define hstate_index_to_shift(index) 0
>  #define hstate_index(h) 0
> +#define dissolve_free_huge_page(p) 0
> +#define dissolve_free_huge_pages(s, e) 0
>  #endif
> =20
>  #endif /* _LINUX_HUGETLB_H */
> diff --git v3.8.orig/mm/hugetlb.c v3.8/mm/hugetlb.c
> index ccf9995..c28e6c9 100644
> --- v3.8.orig/mm/hugetlb.c
> +++ v3.8/mm/hugetlb.c
> @@ -843,6 +843,30 @@ static int free_pool_huge_page(struct hstate *h, nod=
emask_t *nodes_allowed,
>  	return ret;
>  }
> =20
> +/* Dissolve a given free hugepage into free pages. */
> +void dissolve_free_huge_page(struct page *page)
> +{
> +	if (PageHuge(page) && !page_count(page)) {
> +		struct hstate *h =3D page_hstate(page);
> +		int nid =3D page_to_nid(page);
> +		spin_lock(&hugetlb_lock);
> +		list_del(&page->lru);
> +		h->free_huge_pages--;
> +		h->free_huge_pages_node[nid]--;
> +		update_and_free_page(h, page);
> +		spin_unlock(&hugetlb_lock);
> +	}
> +}
> +
> +/* Dissolve free hugepages in a given pfn range. Used by memory hotplug.=
 */
> +void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end=
_pfn)
> +{
> +	unsigned long pfn;
> +	unsigned int step =3D 1 << (HUGETLB_PAGE_ORDER);
> +	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D step)
> +		dissolve_free_huge_page(pfn_to_page(pfn));
> +}
> +
>  static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>  {
>  	struct page *page;
> @@ -3158,6 +3182,25 @@ static int is_hugepage_on_freelist(struct page *hp=
age)
>  	return 0;
>  }
> =20
> +/* Returns true for head pages of in-use hugepages, otherwise returns fa=
lse. */
> +int is_hugepage_movable(struct page *hpage)
> +{
> +	struct page *page;
> +	struct page *tmp;
> +	struct hstate *h =3D page_hstate(hpage);
> +	int ret =3D 0;
> +
> +	VM_BUG_ON(!PageHuge(hpage));
> +	if (PageTail(hpage))
> +		return 0;
> +	spin_lock(&hugetlb_lock);
> +	list_for_each_entry_safe(page, tmp, &h->hugepage_activelist, lru)
> +		if (page =3D=3D hpage)
> +			ret =3D 1;

I don't understand the logic here. 1) page is not removed why tmp is used?
2) why hitting (page =3D=3Dhpage) but not breaking from the loop?

> +	spin_unlock(&hugetlb_lock);
> +	return ret;
> +}
> +
> [...]

--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRLbdkAAoJEI01n1+kOSLHBqgP/jz3zpOJ5p+PdkX1nSbYjUsJ
l0g1K6eNehbXRaAGlQ+2Za3yQkdMt1zSLl22CGx+l30bBtHX5q+xDBaR1QgmRp2A
JUzwDotyzqapL/99VeCMABXAzZy06ZWplXN7r8S2MuQnE+nxhrOlVt8iC9wPRiPv
K+hBsszUySNfe32Gsqy09HFL/CInOu5DbkK8ByXUn6pNmDn4R7jr89Rv7I0X2Rr9
nAk8gZyb86M+0ZQfSGvHI/ZpF4QixtFjkyVTUcgHMkR817CnDD0WqJqJt17nEjxN
nKjgjZs/4ybx1vjtsuXw7qGzW4Du642IIw/kGatk+pspjLvJtZDd8528p2o6lihB
qRRWyQQMIfjmDdHDvnmToQU5Hwpx+RotHGxGpxGmyOvFT3v9vXY9fpN8IzQnrXcw
rGsyddEb5QwPXADKefZythcpUWrifvmO1cuzV1Sx98flYGa3Xokf5EvXRIhiuSrL
Bw6NXSPnH20mDqP/ZnTIpIx9j2td2plCWUlTQGz+2Fwhw0ro+vrWeFovjkc5UAvO
9lo65UhfLD3hSfF49KEXNwJY5pFVyK148ZP3aC6mSw5GYf9V+Xql0gNBQdWrUUBP
A0horNqv9Qvo/zFCMmJwpucS8l8EukJPMg4k0LsBO3ucfc1I+OiNqx0lFnDYLVjH
H2On4eWMtFB+qN/Ok8w6
=JLBD
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
