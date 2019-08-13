Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FF27C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:50:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFABE20844
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:50:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFABE20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DA0B6B000A; Tue, 13 Aug 2019 10:50:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78AA86B000C; Tue, 13 Aug 2019 10:50:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 679456B000D; Tue, 13 Aug 2019 10:50:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0076.hostedemail.com [216.40.44.76])
	by kanga.kvack.org (Postfix) with ESMTP id 421606B000A
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:50:37 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D8D7B8248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:50:36 +0000 (UTC)
X-FDA: 75817690872.16.salt43_79b1185617043
X-HE-Tag: salt43_79b1185617043
X-Filterd-Recvd-Size: 9078
Received: from mx0b-002e3701.pphosted.com (mx0b-002e3701.pphosted.com [148.163.143.35])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:50:36 +0000 (UTC)
Received: from pps.filterd (m0150245.ppops.net [127.0.0.1])
	by mx0b-002e3701.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7DEfI83009101;
	Tue, 13 Aug 2019 14:50:31 GMT
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com [15.233.44.27])
	by mx0b-002e3701.pphosted.com with ESMTP id 2ubwwp8qrs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 13 Aug 2019 14:50:31 +0000
Received: from g2t2360.austin.hpecorp.net (g2t2360.austin.hpecorp.net [16.196.225.135])
	by g2t2354.austin.hpe.com (Postfix) with ESMTP id B3DF9AE;
	Tue, 13 Aug 2019 14:50:30 +0000 (UTC)
Received: from hpe.com (teo-eag.americas.hpqcorp.net [10.33.152.10])
	by g2t2360.austin.hpecorp.net (Postfix) with ESMTP id E0DF13B;
	Tue, 13 Aug 2019 14:50:29 +0000 (UTC)
Date: Tue, 13 Aug 2019 09:50:29 -0500
From: Dimitri Sivanich <sivanich@hpe.com>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: jhubbard@nvidia.com, gregkh@linuxfoundation.org, sivanich@hpe.com,
        arnd@arndb.de, ira.weiny@intel.com, jglisse@redhat.com,
        william.kucharski@oracle.com, hch@lst.de, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v5 1/1] sgi-gru: Remove *pte_lookup
 functions, Convert to get_user_page*()
Message-ID: <20190813145029.GA32451@hpe.com>
References: <1565379497-29266-1-git-send-email-linux.bhar@gmail.com>
 <1565379497-29266-2-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1565379497-29266-2-git-send-email-linux.bhar@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-13_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908130156
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Bharath,

I do not believe that __get_user_pages_fast will work for the atomic case=
, as
there is no guarantee that the 'current->mm' will be the correct one for =
the
process in question, as the process might have moved away from the cpu th=
at is
handling interrupts for it's context.

On Sat, Aug 10, 2019 at 01:08:17AM +0530, Bharath Vedartham wrote:
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
>=20
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2=
d
> ("mm: introduce put_user_page*(), placeholder versions").
>=20
> As part of this conversion, the *pte_lookup functions can be removed an=
d
> be easily replaced with get_user_pages_fast() functions. In the case of
> atomic lookup, __get_user_pages_fast() is used, because it does not fal=
l
> back to the slow path: get_user_pages(). get_user_pages_fast(), on the =
other
> hand, first calls __get_user_pages_fast(), but then falls back to the
> slow path if __get_user_pages_fast() fails.
>=20
> Also: remove unnecessary CONFIG_HUGETLB ifdefs.
>=20
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: J=E9r=F4me Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: William Kucharski <william.kucharski@oracle.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel-mentees@lists.linuxfoundation.org
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
> This is a fold of the 3 patches in the v2 patch series.
> The review tags were given to the individual patches.
>=20
> Changes since v3
> 	- Used gup flags in get_user_pages_fast rather than
> 	boolean flags.
> Changes since v4
> 	- Updated changelog according to John Hubbard.
> ---
>  drivers/misc/sgi-gru/grufault.c | 112 +++++++++-----------------------=
--------
>  1 file changed, 24 insertions(+), 88 deletions(-)
>=20
> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/gru=
fault.c
> index 4b713a8..304e9c5 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -166,96 +166,20 @@ static void get_clear_fault_map(struct gru_state =
*gru,
>  }
> =20
>  /*
> - * Atomic (interrupt context) & non-atomic (user context) functions to
> - * convert a vaddr into a physical address. The size of the page
> - * is returned in pageshift.
> - * 	returns:
> - * 		  0 - successful
> - * 		< 0 - error code
> - * 		  1 - (atomic only) try again in non-atomic context
> - */
> -static int non_atomic_pte_lookup(struct vm_area_struct *vma,
> -				 unsigned long vaddr, int write,
> -				 unsigned long *paddr, int *pageshift)
> -{
> -	struct page *page;
> -
> -#ifdef CONFIG_HUGETLB_PAGE
> -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> -#else
> -	*pageshift =3D PAGE_SHIFT;
> -#endif
> -	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=3D=
 0)
> -		return -EFAULT;
> -	*paddr =3D page_to_phys(page);
> -	put_page(page);
> -	return 0;
> -}
> -
> -/*
> - * atomic_pte_lookup
> + * mmap_sem is already helod on entry to this function. This guarantee=
s
> + * existence of the page tables.
>   *
> - * Convert a user virtual address to a physical address
>   * Only supports Intel large pages (2MB only) on x86_64.
> - *	ZZZ - hugepage support is incomplete
> - *
> - * NOTE: mmap_sem is already held on entry to this function. This
> - * guarantees existence of the page tables.
> + *	ZZZ - hugepage support is incomplete.
>   */
> -static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long=
 vaddr,
> -	int write, unsigned long *paddr, int *pageshift)
> -{
> -	pgd_t *pgdp;
> -	p4d_t *p4dp;
> -	pud_t *pudp;
> -	pmd_t *pmdp;
> -	pte_t pte;
> -
> -	pgdp =3D pgd_offset(vma->vm_mm, vaddr);
> -	if (unlikely(pgd_none(*pgdp)))
> -		goto err;
> -
> -	p4dp =3D p4d_offset(pgdp, vaddr);
> -	if (unlikely(p4d_none(*p4dp)))
> -		goto err;
> -
> -	pudp =3D pud_offset(p4dp, vaddr);
> -	if (unlikely(pud_none(*pudp)))
> -		goto err;
> -
> -	pmdp =3D pmd_offset(pudp, vaddr);
> -	if (unlikely(pmd_none(*pmdp)))
> -		goto err;
> -#ifdef CONFIG_X86_64
> -	if (unlikely(pmd_large(*pmdp)))
> -		pte =3D *(pte_t *) pmdp;
> -	else
> -#endif
> -		pte =3D *pte_offset_kernel(pmdp, vaddr);
> -
> -	if (unlikely(!pte_present(pte) ||
> -		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
> -		return 1;
> -
> -	*paddr =3D pte_pfn(pte) << PAGE_SHIFT;
> -#ifdef CONFIG_HUGETLB_PAGE
> -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> -#else
> -	*pageshift =3D PAGE_SHIFT;
> -#endif
> -	return 0;
> -
> -err:
> -	return 1;
> -}
> -
>  static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>  		    int write, int atomic, unsigned long *gpa, int *pageshift)
>  {
>  	struct mm_struct *mm =3D gts->ts_mm;
>  	struct vm_area_struct *vma;
>  	unsigned long paddr;
> -	int ret, ps;
> +	int ret;
> +	struct page *page;
> =20
>  	vma =3D find_vma(mm, vaddr);
>  	if (!vma)
> @@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gts,=
 unsigned long vaddr,
> =20
>  	/*
>  	 * Atomic lookup is faster & usually works even if called in non-atom=
ic
> -	 * context.
> +	 * context. get_user_pages_fast does atomic lookup before falling bac=
k to
> +	 * slow gup.
>  	 */
>  	rmb();	/* Must/check ms_range_active before loading PTEs */
> -	ret =3D atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
> -	if (ret) {
> -		if (atomic)
> +	if (atomic) {
> +		ret =3D __get_user_pages_fast(vaddr, 1, write, &page);
> +		if (!ret)
>  			goto upm;
> -		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
> +	} else {
> +		ret =3D get_user_pages_fast(vaddr, 1, write ? FOLL_WRITE : 0, &page)=
;
> +		if (!ret)
>  			goto inval;
>  	}
> +
> +	paddr =3D page_to_phys(page);
> +	put_user_page(page);
> +
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		*pageshift =3D HPAGE_SHIFT;
> +	else
> +		*pageshift =3D PAGE_SHIFT;
> +
>  	if (is_gru_paddr(paddr))
>  		goto inval;
> -	paddr =3D paddr & ~((1UL << ps) - 1);
> +	paddr =3D paddr & ~((1UL << *pageshift) - 1);
>  	*gpa =3D uv_soc_phys_ram_to_gpa(paddr);
> -	*pageshift =3D ps;
> +
>  	return VTOP_SUCCESS;
> =20
>  inval:
> --=20
> 2.7.4
>=20

