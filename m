Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D92BC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:23:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 161C520663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:23:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VtwUJ1g0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 161C520663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A75CB6B0006; Tue, 13 Aug 2019 13:23:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A26E56B0007; Tue, 13 Aug 2019 13:23:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EFA56B0008; Tue, 13 Aug 2019 13:23:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0086.hostedemail.com [216.40.44.86])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB6A6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:23:14 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2543C181AC9BA
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:23:14 +0000 (UTC)
X-FDA: 75818075508.24.grade51_908fbcdd76e1b
X-HE-Tag: grade51_908fbcdd76e1b
X-Filterd-Recvd-Size: 11081
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:23:13 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id 129so5064834pfa.4
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:23:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=if9i7zh0Qit/yKhgw7AU3xUn9wMFS6+DPvFYQ9IzgUM=;
        b=VtwUJ1g07ZQGByWFKuFyL++/c5nvno1F4aqLKJsYQmfBbQ5MTGe71PomB52/lhGyX8
         uFNnn55FnmpYekD06mwP82wA498ldCCstGkbdaamkBCd03VpR1Cdf2g9o8C8AXT+lK7Z
         KUOTBBk75tdbOXLAxSmE6tNsIAiAQzMozIj7Z/sRUFBSmEPytowcgm7Cd5wsbJtckLvU
         rgOGzjR2hjix3JREkZz33D+kHPb8P1RCjZ2aWsn2x+8x8s6ABhsu7kssG9ScCIDr9Xlr
         34Ox28ouhz+EwKjuBgKJ6btSZssQtWmp/y4Qmguw5rovtIF0DD/I4NiGpogBjG0bDnzA
         Y1sQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=if9i7zh0Qit/yKhgw7AU3xUn9wMFS6+DPvFYQ9IzgUM=;
        b=T99dS6PmQiXHnxvkSjWZVv4U+crVAsj/zCAk2K9jlzccTIELdf3tn+aJI4MqJHMmmE
         twDTDS8ulI/oaG19cY1V7z/iU7Um5csk7HMxx9MALHn39xv0V8lm4TGmBY6b33vnY71s
         VCE1bXEyPaEFOGCy8y3kAhiASRASN5QrTPRNW8shF8JxG+KS8NpiEpadD6k7e6s46Ijo
         Tvo72gDj8KBJbaHeLQr+H0jXZ0GyoBTy1KP0jWWqw+wVqmDIUmeHZQ5VS8OyzTowriOm
         pSqI7Ihws4CeKq4Zr5hXsXtGyhkAZuLbzzy+dXDRrxu+ifo7cJTPwSTAGWg4MFI/bXkx
         ohIA==
X-Gm-Message-State: APjAAAWoNLivVRvnfJ1TfQi9LvM/crVbkK7WlS+ZfCDPBmS+jGm3ifKI
	26qVACI8E4xFvIeHgvFrSlw=
X-Google-Smtp-Source: APXvYqwn4i2MuuhDE5aBojeK0YnwZSTVlstqtU4zNM2IkkD6QM4+wPBwPpEmI9B/lSG2uWedifx5Xg==
X-Received: by 2002:a17:90a:71ca:: with SMTP id m10mr3264191pjs.27.1565716992214;
        Tue, 13 Aug 2019 10:23:12 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id 203sm15071517pfz.107.2019.08.13.10.23.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 10:23:11 -0700 (PDT)
Date: Tue, 13 Aug 2019 22:53:01 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Dimitri Sivanich <sivanich@hpe.com>
Cc: jhubbard@nvidia.com, gregkh@linuxfoundation.org, arnd@arndb.de,
	ira.weiny@intel.com, jglisse@redhat.com,
	william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v5 1/1] sgi-gru: Remove *pte_lookup
 functions, Convert to get_user_page*()
Message-ID: <20190813172301.GA10228@bharath12345-Inspiron-5559>
References: <1565379497-29266-1-git-send-email-linux.bhar@gmail.com>
 <1565379497-29266-2-git-send-email-linux.bhar@gmail.com>
 <20190813145029.GA32451@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190813145029.GA32451@hpe.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 09:50:29AM -0500, Dimitri Sivanich wrote:
> Bharath,
>=20
> I do not believe that __get_user_pages_fast will work for the atomic ca=
se, as
> there is no guarantee that the 'current->mm' will be the correct one fo=
r the
> process in question, as the process might have moved away from the cpu =
that is
> handling interrupts for it's context.
So what your saying is, there may be cases where current->mm !=3D gts->ts=
_mm
right? __get_user_pages_fast and get_user_pages do assume current->mm.

These changes were inspired a bit from kvm. In kvm/kvm_main.c,
hva_to_pfn_fast uses __get_user_pages_fast. THe comment above the
function states it runs in atomic context.

Just curious, get_user_pages also uses current->mm. Do you think that is
also an issue?=20

Do you feel using get_user_pages_remote would be a better idea? We can
specify the mm_struct in get_user_pages_remote?

Thank you
Bharath
> On Sat, Aug 10, 2019 at 01:08:17AM +0530, Bharath Vedartham wrote:
> > For pages that were retained via get_user_pages*(), release those pag=
es
> > via the new put_user_page*() routines, instead of via put_page() or
> > release_pages().
> >=20
> > This is part a tree-wide conversion, as described in commit fc1d8e7cc=
a2d
> > ("mm: introduce put_user_page*(), placeholder versions").
> >=20
> > As part of this conversion, the *pte_lookup functions can be removed =
and
> > be easily replaced with get_user_pages_fast() functions. In the case =
of
> > atomic lookup, __get_user_pages_fast() is used, because it does not f=
all
> > back to the slow path: get_user_pages(). get_user_pages_fast(), on th=
e other
> > hand, first calls __get_user_pages_fast(), but then falls back to the
> > slow path if __get_user_pages_fast() fails.
> >=20
> > Also: remove unnecessary CONFIG_HUGETLB ifdefs.
> >=20
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: J=E9r=F4me Glisse <jglisse@redhat.com>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Dimitri Sivanich <sivanich@sgi.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: William Kucharski <william.kucharski@oracle.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: linux-kernel-mentees@lists.linuxfoundation.org
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> > Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > ---
> > This is a fold of the 3 patches in the v2 patch series.
> > The review tags were given to the individual patches.
> >=20
> > Changes since v3
> > 	- Used gup flags in get_user_pages_fast rather than
> > 	boolean flags.
> > Changes since v4
> > 	- Updated changelog according to John Hubbard.
> > ---
> >  drivers/misc/sgi-gru/grufault.c | 112 +++++++++---------------------=
----------
> >  1 file changed, 24 insertions(+), 88 deletions(-)
> >=20
> > diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/g=
rufault.c
> > index 4b713a8..304e9c5 100644
> > --- a/drivers/misc/sgi-gru/grufault.c
> > +++ b/drivers/misc/sgi-gru/grufault.c
> > @@ -166,96 +166,20 @@ static void get_clear_fault_map(struct gru_stat=
e *gru,
> >  }
> > =20
> >  /*
> > - * Atomic (interrupt context) & non-atomic (user context) functions =
to
> > - * convert a vaddr into a physical address. The size of the page
> > - * is returned in pageshift.
> > - * 	returns:
> > - * 		  0 - successful
> > - * 		< 0 - error code
> > - * 		  1 - (atomic only) try again in non-atomic context
> > - */
> > -static int non_atomic_pte_lookup(struct vm_area_struct *vma,
> > -				 unsigned long vaddr, int write,
> > -				 unsigned long *paddr, int *pageshift)
> > -{
> > -	struct page *page;
> > -
> > -#ifdef CONFIG_HUGETLB_PAGE
> > -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> > -#else
> > -	*pageshift =3D PAGE_SHIFT;
> > -#endif
> > -	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=
=3D 0)
> > -		return -EFAULT;
> > -	*paddr =3D page_to_phys(page);
> > -	put_page(page);
> > -	return 0;
> > -}
> > -
> > -/*
> > - * atomic_pte_lookup
> > + * mmap_sem is already helod on entry to this function. This guarant=
ees
> > + * existence of the page tables.
> >   *
> > - * Convert a user virtual address to a physical address
> >   * Only supports Intel large pages (2MB only) on x86_64.
> > - *	ZZZ - hugepage support is incomplete
> > - *
> > - * NOTE: mmap_sem is already held on entry to this function. This
> > - * guarantees existence of the page tables.
> > + *	ZZZ - hugepage support is incomplete.
> >   */
> > -static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned lo=
ng vaddr,
> > -	int write, unsigned long *paddr, int *pageshift)
> > -{
> > -	pgd_t *pgdp;
> > -	p4d_t *p4dp;
> > -	pud_t *pudp;
> > -	pmd_t *pmdp;
> > -	pte_t pte;
> > -
> > -	pgdp =3D pgd_offset(vma->vm_mm, vaddr);
> > -	if (unlikely(pgd_none(*pgdp)))
> > -		goto err;
> > -
> > -	p4dp =3D p4d_offset(pgdp, vaddr);
> > -	if (unlikely(p4d_none(*p4dp)))
> > -		goto err;
> > -
> > -	pudp =3D pud_offset(p4dp, vaddr);
> > -	if (unlikely(pud_none(*pudp)))
> > -		goto err;
> > -
> > -	pmdp =3D pmd_offset(pudp, vaddr);
> > -	if (unlikely(pmd_none(*pmdp)))
> > -		goto err;
> > -#ifdef CONFIG_X86_64
> > -	if (unlikely(pmd_large(*pmdp)))
> > -		pte =3D *(pte_t *) pmdp;
> > -	else
> > -#endif
> > -		pte =3D *pte_offset_kernel(pmdp, vaddr);
> > -
> > -	if (unlikely(!pte_present(pte) ||
> > -		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
> > -		return 1;
> > -
> > -	*paddr =3D pte_pfn(pte) << PAGE_SHIFT;
> > -#ifdef CONFIG_HUGETLB_PAGE
> > -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> > -#else
> > -	*pageshift =3D PAGE_SHIFT;
> > -#endif
> > -	return 0;
> > -
> > -err:
> > -	return 1;
> > -}
> > -
> >  static int gru_vtop(struct gru_thread_state *gts, unsigned long vadd=
r,
> >  		    int write, int atomic, unsigned long *gpa, int *pageshift)
> >  {
> >  	struct mm_struct *mm =3D gts->ts_mm;
> >  	struct vm_area_struct *vma;
> >  	unsigned long paddr;
> > -	int ret, ps;
> > +	int ret;
> > +	struct page *page;
> > =20
> >  	vma =3D find_vma(mm, vaddr);
> >  	if (!vma)
> > @@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gt=
s, unsigned long vaddr,
> > =20
> >  	/*
> >  	 * Atomic lookup is faster & usually works even if called in non-at=
omic
> > -	 * context.
> > +	 * context. get_user_pages_fast does atomic lookup before falling b=
ack to
> > +	 * slow gup.
> >  	 */
> >  	rmb();	/* Must/check ms_range_active before loading PTEs */
> > -	ret =3D atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
> > -	if (ret) {
> > -		if (atomic)
> > +	if (atomic) {
> > +		ret =3D __get_user_pages_fast(vaddr, 1, write, &page);
> > +		if (!ret)
> >  			goto upm;
> > -		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
> > +	} else {
> > +		ret =3D get_user_pages_fast(vaddr, 1, write ? FOLL_WRITE : 0, &pag=
e);
> > +		if (!ret)
> >  			goto inval;
> >  	}
> > +
> > +	paddr =3D page_to_phys(page);
> > +	put_user_page(page);
> > +
> > +	if (unlikely(is_vm_hugetlb_page(vma)))
> > +		*pageshift =3D HPAGE_SHIFT;
> > +	else
> > +		*pageshift =3D PAGE_SHIFT;
> > +
> >  	if (is_gru_paddr(paddr))
> >  		goto inval;
> > -	paddr =3D paddr & ~((1UL << ps) - 1);
> > +	paddr =3D paddr & ~((1UL << *pageshift) - 1);
> >  	*gpa =3D uv_soc_phys_ram_to_gpa(paddr);
> > -	*pageshift =3D ps;
> > +
> >  	return VTOP_SUCCESS;
> > =20
> >  inval:
> > --=20
> > 2.7.4
> >=20

