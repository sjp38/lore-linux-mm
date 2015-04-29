Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 315856B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 12:20:31 -0400 (EDT)
Received: by wgso17 with SMTP id o17so34125251wgs.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:20:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f4si44702473wjn.5.2015.04.29.09.20.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 09:20:28 -0700 (PDT)
Message-ID: <554104B3.3030503@redhat.com>
Date: Wed, 29 Apr 2015 18:20:03 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 20/28] mm: differentiate page_mapped() from page_mapcount()
 for compound pages
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-21-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="kp43hwMlLOIcJENbL7UHTuXx52O5hKOGI"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kp43hwMlLOIcJENbL7UHTuXx52O5hKOGI
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> Let's define page_mapped() to be true for compound pages if any
> sub-pages of the compound page is mapped (with PMD or PTE).
>=20
> On other hand page_mapcount() return mapcount for this particular small=

> page.
>=20
> This will make cases like page_get_anon_vma() behave correctly once we
> allow huge pages to be mapped with PTE.
>=20
> Most users outside core-mm should use page_mapcount() instead of
> page_mapped().
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  arch/arc/mm/cache_arc700.c |  4 ++--
>  arch/arm/mm/flush.c        |  2 +-
>  arch/mips/mm/c-r4k.c       |  3 ++-
>  arch/mips/mm/cache.c       |  2 +-
>  arch/mips/mm/init.c        |  6 +++---
>  arch/sh/mm/cache-sh4.c     |  2 +-
>  arch/sh/mm/cache.c         |  8 ++++----
>  arch/xtensa/mm/tlb.c       |  2 +-
>  fs/proc/page.c             |  4 ++--
>  include/linux/mm.h         | 11 ++++++++++-
>  mm/filemap.c               |  2 +-
>  11 files changed, 28 insertions(+), 18 deletions(-)
>=20
> diff --git a/arch/arc/mm/cache_arc700.c b/arch/arc/mm/cache_arc700.c
> index 8c3a3e02ba92..1baa4d23314b 100644
> --- a/arch/arc/mm/cache_arc700.c
> +++ b/arch/arc/mm/cache_arc700.c
> @@ -490,7 +490,7 @@ void flush_dcache_page(struct page *page)
>  	 */
>  	if (!mapping_mapped(mapping)) {
>  		clear_bit(PG_dc_clean, &page->flags);
> -	} else if (page_mapped(page)) {
> +	} else if (page_mapcount(page)) {
> =20
>  		/* kernel reading from page with U-mapping */
>  		void *paddr =3D page_address(page);
> @@ -675,7 +675,7 @@ void copy_user_highpage(struct page *to, struct pag=
e *from,
>  	 * Note that while @u_vaddr refers to DST page's userspace vaddr, it =
is
>  	 * equally valid for SRC page as well
>  	 */
> -	if (page_mapped(from) && addr_not_cache_congruent(kfrom, u_vaddr)) {
> +	if (page_mapcount(from) && addr_not_cache_congruent(kfrom, u_vaddr)) =
{
>  		__flush_dcache_page(kfrom, u_vaddr);
>  		clean_src_k_mappings =3D 1;
>  	}
> diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
> index 34b66af516ea..8f972fc8933d 100644
> --- a/arch/arm/mm/flush.c
> +++ b/arch/arm/mm/flush.c
> @@ -315,7 +315,7 @@ void flush_dcache_page(struct page *page)
>  	mapping =3D page_mapping(page);
> =20
>  	if (!cache_ops_need_broadcast() &&
> -	    mapping && !page_mapped(page))
> +	    mapping && !page_mapcount(page))
>  		clear_bit(PG_dcache_clean, &page->flags);
>  	else {
>  		__flush_dcache_page(mapping, page);
> diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
> index dd261df005c2..c4960b2d6682 100644
> --- a/arch/mips/mm/c-r4k.c
> +++ b/arch/mips/mm/c-r4k.c
> @@ -578,7 +578,8 @@ static inline void local_r4k_flush_cache_page(void =
*args)
>  		 * another ASID than the current one.
>  		 */
>  		map_coherent =3D (cpu_has_dc_aliases &&
> -				page_mapped(page) && !Page_dcache_dirty(page));
> +				page_mapcount(page) &&
> +				!Page_dcache_dirty(page));
>  		if (map_coherent)
>  			vaddr =3D kmap_coherent(page, addr);
>  		else
> diff --git a/arch/mips/mm/cache.c b/arch/mips/mm/cache.c
> index 7e3ea7766822..e695b28dc32c 100644
> --- a/arch/mips/mm/cache.c
> +++ b/arch/mips/mm/cache.c
> @@ -106,7 +106,7 @@ void __flush_anon_page(struct page *page, unsigned =
long vmaddr)
>  	unsigned long addr =3D (unsigned long) page_address(page);
> =20
>  	if (pages_do_alias(addr, vmaddr)) {
> -		if (page_mapped(page) && !Page_dcache_dirty(page)) {
> +		if (page_mapcount(page) && !Page_dcache_dirty(page)) {
>  			void *kaddr;
> =20
>  			kaddr =3D kmap_coherent(page, vmaddr);
> diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
> index 448cde372af0..2c8e44aa536e 100644
> --- a/arch/mips/mm/init.c
> +++ b/arch/mips/mm/init.c
> @@ -156,7 +156,7 @@ void copy_user_highpage(struct page *to, struct pag=
e *from,
> =20
>  	vto =3D kmap_atomic(to);
>  	if (cpu_has_dc_aliases &&
> -	    page_mapped(from) && !Page_dcache_dirty(from)) {
> +	    page_mapcount(from) && !Page_dcache_dirty(from)) {
>  		vfrom =3D kmap_coherent(from, vaddr);
>  		copy_page(vto, vfrom);
>  		kunmap_coherent();
> @@ -178,7 +178,7 @@ void copy_to_user_page(struct vm_area_struct *vma,
>  	unsigned long len)
>  {
>  	if (cpu_has_dc_aliases &&
> -	    page_mapped(page) && !Page_dcache_dirty(page)) {
> +	    page_mapcount(page) && !Page_dcache_dirty(page)) {
>  		void *vto =3D kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
>  		memcpy(vto, src, len);
>  		kunmap_coherent();
> @@ -196,7 +196,7 @@ void copy_from_user_page(struct vm_area_struct *vma=
,
>  	unsigned long len)
>  {
>  	if (cpu_has_dc_aliases &&
> -	    page_mapped(page) && !Page_dcache_dirty(page)) {
> +	    page_mapcount(page) && !Page_dcache_dirty(page)) {
>  		void *vfrom =3D kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
>  		memcpy(dst, vfrom, len);
>  		kunmap_coherent();
> diff --git a/arch/sh/mm/cache-sh4.c b/arch/sh/mm/cache-sh4.c
> index 51d8f7f31d1d..58aaa4f33b81 100644
> --- a/arch/sh/mm/cache-sh4.c
> +++ b/arch/sh/mm/cache-sh4.c
> @@ -241,7 +241,7 @@ static void sh4_flush_cache_page(void *args)
>  		 */
>  		map_coherent =3D (current_cpu_data.dcache.n_aliases &&
>  			test_bit(PG_dcache_clean, &page->flags) &&
> -			page_mapped(page));
> +			page_mapcount(page));
>  		if (map_coherent)
>  			vaddr =3D kmap_coherent(page, address);
>  		else
> diff --git a/arch/sh/mm/cache.c b/arch/sh/mm/cache.c
> index f770e3992620..e58cfbf45150 100644
> --- a/arch/sh/mm/cache.c
> +++ b/arch/sh/mm/cache.c
> @@ -59,7 +59,7 @@ void copy_to_user_page(struct vm_area_struct *vma, st=
ruct page *page,
>  		       unsigned long vaddr, void *dst, const void *src,
>  		       unsigned long len)
>  {
> -	if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
> +	if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
>  	    test_bit(PG_dcache_clean, &page->flags)) {
>  		void *vto =3D kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
>  		memcpy(vto, src, len);
> @@ -78,7 +78,7 @@ void copy_from_user_page(struct vm_area_struct *vma, =
struct page *page,
>  			 unsigned long vaddr, void *dst, const void *src,
>  			 unsigned long len)
>  {
> -	if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
> +	if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
>  	    test_bit(PG_dcache_clean, &page->flags)) {
>  		void *vfrom =3D kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
>  		memcpy(dst, vfrom, len);
> @@ -97,7 +97,7 @@ void copy_user_highpage(struct page *to, struct page =
*from,
> =20
>  	vto =3D kmap_atomic(to);
> =20
> -	if (boot_cpu_data.dcache.n_aliases && page_mapped(from) &&
> +	if (boot_cpu_data.dcache.n_aliases && page_mapcount(from) &&
>  	    test_bit(PG_dcache_clean, &from->flags)) {
>  		vfrom =3D kmap_coherent(from, vaddr);
>  		copy_page(vto, vfrom);
> @@ -153,7 +153,7 @@ void __flush_anon_page(struct page *page, unsigned =
long vmaddr)
>  	unsigned long addr =3D (unsigned long) page_address(page);
> =20
>  	if (pages_do_alias(addr, vmaddr)) {
> -		if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
> +		if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
>  		    test_bit(PG_dcache_clean, &page->flags)) {
>  			void *kaddr;
> =20
> diff --git a/arch/xtensa/mm/tlb.c b/arch/xtensa/mm/tlb.c
> index 5ece856c5725..35c822286bbe 100644
> --- a/arch/xtensa/mm/tlb.c
> +++ b/arch/xtensa/mm/tlb.c
> @@ -245,7 +245,7 @@ static int check_tlb_entry(unsigned w, unsigned e, =
bool dtlb)
>  						page_mapcount(p));
>  				if (!page_count(p))
>  					rc |=3D TLB_INSANE;
> -				else if (page_mapped(p))
> +				else if (page_mapcount(p))
>  					rc |=3D TLB_SUSPICIOUS;
>  			} else {
>  				rc |=3D TLB_INSANE;
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 7eee2d8b97d9..e99c059339f6 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -97,9 +97,9 @@ u64 stable_page_flags(struct page *page)
>  	 * pseudo flags for the well known (anonymous) memory mapped pages
>  	 *
>  	 * Note that page->_mapcount is overloaded in SLOB/SLUB/SLQB, so the
> -	 * simple test in page_mapped() is not enough.
> +	 * simple test in page_mapcount() is not enough.
>  	 */
> -	if (!PageSlab(page) && page_mapped(page))
> +	if (!PageSlab(page) && page_mapcount(page))
>  		u |=3D 1 << KPF_MMAP;
>  	if (PageAnon(page))
>  		u |=3D 1 << KPF_ANON;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 33cb3aa647a6..8ddc184c55d6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -909,7 +909,16 @@ static inline pgoff_t page_file_index(struct page =
*page)
>   */
>  static inline int page_mapped(struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >=3D=
 0;
> +	int i;
> +	if (likely(!PageCompound(page)))
> +		return atomic_read(&page->_mapcount) >=3D 0;
> +	if (compound_mapcount(page))
> +		return 1;
> +	for (i =3D 0; i < hpage_nr_pages(page); i++) {
> +		if (atomic_read(&page[i]._mapcount) >=3D 0)
> +			return 1;
> +	}
> +	return 0;
>  }

page_mapped() won't work with tail pages. Maybe I'm missing something
that makes it impossible. Otherwise, have you checked that this
condition is true for all call site?  Should we add some check at the
beginning of the function? Something like:

VM_BUG_ON_PAGE(PageTail(page), page)?

> =20
>  /*
> diff --git a/mm/filemap.c b/mm/filemap.c
> index ce4d6e3d740f..c25ba3b4e7a2 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -200,7 +200,7 @@ void __delete_from_page_cache(struct page *page, vo=
id *shadow)
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  	if (PageSwapBacked(page))
>  		__dec_zone_page_state(page, NR_SHMEM);
> -	BUG_ON(page_mapped(page));
> +	VM_BUG_ON_PAGE(page_mapped(page), page);
> =20
>  	/*
>  	 * At this point page must be either written or cleaned by truncate.
>=20



--kp43hwMlLOIcJENbL7UHTuXx52O5hKOGI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQQSzAAoJEHTzHJCtsuoCbAoH+wT7udiQiki4riVZ8SnlSX+w
c3zmK4WITfPpwwLcQPDIxIUB0UPd/IIkEwBeolnK3s6s/wcNLKb+Tr80jr/Vvcnt
1lZr74WTDTnIlZbqCsnFYRKPupmaEnK8geuNRjn/h8gDfP907a5M0Z5nNMQe6kSZ
y3s7koN66wvVrkm/LrbFdRIn+LZf5b3DStdzSsFMhLiB8ptkFd6rHJeSOZgTPvWo
cImK+8BJNKk0bz7Xw6cjnGBKkddxXA7D+hkYqD51VyDCxr9MAWF9akwVEGz4kVEc
9zNPMhrl4yyfuHd3mTjX8Du+imfdREQiptU/7L4mOwvZ3QGENW7QoHhQqNebo5U=
=jU/E
-----END PGP SIGNATURE-----

--kp43hwMlLOIcJENbL7UHTuXx52O5hKOGI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
