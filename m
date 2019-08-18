Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89999C3A59F
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 17:58:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2409520B7C
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 17:58:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cB/T8JxD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2409520B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A77EF6B0007; Sun, 18 Aug 2019 13:58:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A02C76B000A; Sun, 18 Aug 2019 13:58:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C8276B000C; Sun, 18 Aug 2019 13:58:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64A1A6B0007
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 13:58:34 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 105CB181AC9AE
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 17:58:34 +0000 (UTC)
X-FDA: 75836308548.15.flesh89_1083846560635
X-HE-Tag: flesh89_1083846560635
X-Filterd-Recvd-Size: 10057
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 17:58:33 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id c2so4659795plz.13
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 10:58:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=lpXT5jgyPqX3dLnOucpewMYDw91Zhangu/vs1bm1UA4=;
        b=cB/T8JxD2gaPLDiZ4yWgXIiaf2c6ezdTY081pE3OHA/Zlm7wJPNHeuajM3+bw4yJ04
         U8MNrjAWLrpzd36kDlJBQYe5Z/7GwjHeJnfvP0/FGRl8OIDhuBf0ul9UrE3NXa6PrMr5
         jFOrzjxwI3hgBM3H3yt7Y0E00PzJJ5mvQ35UPtkyZzYmLPt0mNr0tNroO7DQysctYYVZ
         xtP1iL36KbJCkqgEtqZzHZK+MmAUIkGx36jXc75M9MMaKKm7eEeo8ZJSCo07iLq7aQgm
         o11FVO60WbRgdBCHK9mk6HAHu2Gr3/JoYBVyfrWwJ/SFB0qzOfVemBbSEUXvdPN0XRMN
         SI8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=lpXT5jgyPqX3dLnOucpewMYDw91Zhangu/vs1bm1UA4=;
        b=brfF76+zFhBuf+C+5sbDMyltFqq8lXSd1fhSiuXNK0SJ6PKRgl9mpVoKp3GdrcUw6W
         37IvD3WlEtI6OtbL+505ryhHIneYp/rLQqWmh3iuFxqHu3Pqaub17mCY38HXfSafYD9z
         yaobeO7YUKJcDaL/J8sExB7n7kO+B+eu88ZrzEDfRVcRd8SPtAevESlGz1CMGcTD4geo
         5t4wV9iZUxSnRCJuwv5DfMs2H9GRgWtWG1oL7lcnf30H+S7DGJQaRc1iRdYOhnntiQKt
         0cgoou2CKcjkH+99WUx7eVpObm9f7sYidLvdQVFBlQNgbuNwpSGD3cjnOMkiKTFx5mXQ
         uwww==
X-Gm-Message-State: APjAAAVbjFgY3fzDkiJerUTsWUE2DQKQomntVSIatup2aZgtxK2fy2pt
	vG5nIrK/NBltINNUogFU7/Y=
X-Google-Smtp-Source: APXvYqxOdwwV8NfH7Oea0jEcmCO7jmM2+yqmPAgrMcod0AxVkHlQVyZ4TVsvabcTYNtA8Rqjcdppew==
X-Received: by 2002:a17:902:7842:: with SMTP id e2mr18407716pln.49.1566151112258;
        Sun, 18 Aug 2019 10:58:32 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.36])
        by smtp.gmail.com with ESMTPSA id j15sm12983313pfe.3.2019.08.18.10.58.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Aug 2019 10:58:31 -0700 (PDT)
Date: Sun, 18 Aug 2019 23:28:24 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: jhubbard@nvidia.com, gregkh@linuxfoundation.org, sivanich@sgi.com,
	arnd@arndb.de
Cc: ira.weiny@intel.com, jglisse@redhat.com, william.kucharski@oracle.com,
	hch@lst.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v5 1/1] sgi-gru: Remove *pte_lookup
 functions, Convert to get_user_page*()
Message-ID: <20190818175824.GA6635@bharath12345-Inspiron-5559>
References: <1565379497-29266-1-git-send-email-linux.bhar@gmail.com>
 <1565379497-29266-2-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1565379497-29266-2-git-send-email-linux.bhar@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dimitri,

Can you confirm that this driver will run gru_vtop() in interrupt
context?

If so, I ll send you another set of patches in which I don't change the
*pte_lookup functions but only change put_page to put_user_page and
remove the ifdef for CONFIG_HUGETLB_PAGE.

Thank you for your time.

Thank you
Bharath

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

