Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 827406B009B
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:28:30 -0500 (EST)
Date: Thu, 15 Nov 2012 10:29:36 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 04/11] thp: do_huge_pmd_wp_page(): handle huge zero
 page
Message-ID: <20121115082936.GB9676@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-5-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141442590.22537@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H1spWtNR+x+ondvy"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211141442590.22537@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--H1spWtNR+x+ondvy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 14, 2012 at 03:08:45PM -0800, David Rientjes wrote:
> On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index fa06804..fe329da 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -516,6 +516,14 @@ static inline pte_t maybe_mkwrite(pte_t pte, struc=
t vm_area_struct *vma)
> >  }
> >  #endif
> > =20
> > +#ifndef my_zero_pfn
> > +static inline unsigned long my_zero_pfn(unsigned long addr)
> > +{
> > +	extern unsigned long zero_pfn;
>=20
> I don't think you should be declaring this inside an inlined function, yo=
u=20
> probably should be protecting the declarations of the variable and the=20
> function instead.  Perhaps by CONFIG_MMU?

mips and s390 use declaration inside inline function to implement
is_zero_pfn(). I wanted to be consistent with that.

I have patch to cleanup zero page helpers a bit. It's on top of
this patchset.

http://article.gmane.org/gmane.linux.kernel.mm/87387

> > +	return zero_pfn;
> > +}
> > +#endif
> > +
> >  /*
> >   * Multiple processes may "see" the same page. E.g. for untouched
> >   * mappings of /dev/null, all processes see the same page full of
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 0d903bf..d767a7c 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -824,6 +824,88 @@ out:
> >  	return ret;
> >  }
> > =20
> > +/* no "address" argument so destroys page coloring of some arch */
> > +pgtable_t get_pmd_huge_pte(struct mm_struct *mm)
> > +{
>=20
> Umm, this is a copy and paste of pgtable_trans_huge_withdraw() from the=
=20
> generic page table handling.  Why can't you reuse that and support (and/o=
r=20
> modify) the s390 and sparc code?

My bad. It's mistake on conflict solving. I'll fix that.

> > +	pgtable_t pgtable;
> > +
> > +	assert_spin_locked(&mm->page_table_lock);
> > +
> > +	/* FIFO */
> > +	pgtable =3D mm->pmd_huge_pte;
> > +	if (list_empty(&pgtable->lru))
> > +		mm->pmd_huge_pte =3D NULL;
> > +	else {
> > +		mm->pmd_huge_pte =3D list_entry(pgtable->lru.next,
> > +					      struct page, lru);
> > +		list_del(&pgtable->lru);
> > +	}
> > +	return pgtable;
> > +}
> > +
> > +static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
> > +		struct vm_area_struct *vma, unsigned long address,
> > +		pmd_t *pmd, unsigned long haddr)
>=20
> This whole function is extremely similar to the implementation of=20
> do_huge_pmd_wp_page_fallback(), there really is no way to fold the two? =
=20

It's similar by structure (I used do_huge_pmd_wp_page_fallback() as a
template) but details are different in many places and I fail to see how
to combine them without making result ugly.

> Typically in cases like this it's helpful to split out different logical=
=20
> segments of a function into smaller functions that would handle both =20
> page and !page accordingly.
>=20
> > +{
> > +	pgtable_t pgtable;
> > +	pmd_t _pmd;
> > +	struct page *page;
> > +	int i, ret =3D 0;
> > +	unsigned long mmun_start;	/* For mmu_notifiers */
> > +	unsigned long mmun_end;		/* For mmu_notifiers */
> > +
> > +	page =3D alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> > +	if (!page) {
> > +		ret |=3D VM_FAULT_OOM;
> > +		goto out;
> > +	}
> > +
> > +	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
> > +		put_page(page);
> > +		ret |=3D VM_FAULT_OOM;
> > +		goto out;
> > +	}
> > +
> > +	clear_user_highpage(page, address);
> > +	__SetPageUptodate(page);
> > +
> > +	mmun_start =3D haddr;
> > +	mmun_end   =3D haddr + HPAGE_PMD_SIZE;
> > +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> > +
> > +	spin_lock(&mm->page_table_lock);
> > +	pmdp_clear_flush(vma, haddr, pmd);
> > +	/* leave pmd empty until pte is filled */
> > +
> > +	pgtable =3D get_pmd_huge_pte(mm);
> > +	pmd_populate(mm, &_pmd, pgtable);
> > +
> > +	for (i =3D 0; i < HPAGE_PMD_NR; i++, haddr +=3D PAGE_SIZE) {
> > +		pte_t *pte, entry;
> > +		if (haddr =3D=3D (address & PAGE_MASK)) {
> > +			entry =3D mk_pte(page, vma->vm_page_prot);
> > +			entry =3D maybe_mkwrite(pte_mkdirty(entry), vma);
> > +			page_add_new_anon_rmap(page, vma, haddr);
> > +		} else {
> > +			entry =3D pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
> > +			entry =3D pte_mkspecial(entry);
> > +		}
> > +		pte =3D pte_offset_map(&_pmd, haddr);
> > +		VM_BUG_ON(!pte_none(*pte));
> > +		set_pte_at(mm, haddr, pte, entry);
> > +		pte_unmap(pte);
> > +	}
> > +	smp_wmb(); /* make pte visible before pmd */
> > +	pmd_populate(mm, pmd, pgtable);
> > +	spin_unlock(&mm->page_table_lock);
> > +
> > +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> > +
> > +	ret |=3D VM_FAULT_WRITE;
> > +out:
> > +	return ret;
> > +}
> > +
> >  static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
> >  					struct vm_area_struct *vma,
> >  					unsigned long address,
> > @@ -930,19 +1012,21 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
> >  			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
> >  {
> >  	int ret =3D 0;
> > -	struct page *page, *new_page;
> > +	struct page *page =3D NULL, *new_page;
> >  	unsigned long haddr;
> >  	unsigned long mmun_start;	/* For mmu_notifiers */
> >  	unsigned long mmun_end;		/* For mmu_notifiers */
> > =20
> >  	VM_BUG_ON(!vma->anon_vma);
> > +	haddr =3D address & HPAGE_PMD_MASK;
> > +	if (is_huge_zero_pmd(orig_pmd))
> > +		goto alloc;
> >  	spin_lock(&mm->page_table_lock);
> >  	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> >  		goto out_unlock;
> > =20
> >  	page =3D pmd_page(orig_pmd);
> >  	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
> > -	haddr =3D address & HPAGE_PMD_MASK;
> >  	if (page_mapcount(page) =3D=3D 1) {
> >  		pmd_t entry;
> >  		entry =3D pmd_mkyoung(orig_pmd);
> > @@ -954,7 +1038,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
> >  	}
> >  	get_page(page);
> >  	spin_unlock(&mm->page_table_lock);
> > -
> > +alloc:
>=20
> This could all use a minor restructuring to make it much more cleaner,=20
> perhaps by extracting the page_mapcount(page) =3D=3D 1 case to be a separ=
ate=20
> function that deals with non-copying writes?

Makes sense. I'll do it as a separate patch on top of the series.

>=20
> >  	if (transparent_hugepage_enabled(vma) &&
> >  	    !transparent_hugepage_debug_cow())
> >  		new_page =3D alloc_hugepage_vma(transparent_hugepage_defrag(vma),
> > @@ -964,24 +1048,34 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
> > =20
> >  	if (unlikely(!new_page)) {
> >  		count_vm_event(THP_FAULT_FALLBACK);
> > -		ret =3D do_huge_pmd_wp_page_fallback(mm, vma, address,
> > -						   pmd, orig_pmd, page, haddr);
> > -		if (ret & VM_FAULT_OOM)
> > -			split_huge_page(page);
> > -		put_page(page);
> > +		if (is_huge_zero_pmd(orig_pmd)) {
> > +			ret =3D do_huge_pmd_wp_zero_page_fallback(mm, vma,
> > +					address, pmd, haddr);
> > +		} else {
> > +			ret =3D do_huge_pmd_wp_page_fallback(mm, vma, address,
> > +					pmd, orig_pmd, page, haddr);
> > +			if (ret & VM_FAULT_OOM)
> > +				split_huge_page(page);
> > +			put_page(page);
> > +		}
> >  		goto out;
> >  	}
> >  	count_vm_event(THP_FAULT_ALLOC);
> > =20
> >  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> >  		put_page(new_page);
> > -		split_huge_page(page);
> > -		put_page(page);
> > +		if (page) {
> > +			split_huge_page(page);
> > +			put_page(page);
> > +		}
> >  		ret |=3D VM_FAULT_OOM;
> >  		goto out;
> >  	}
> > =20
> > -	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
> > +	if (is_huge_zero_pmd(orig_pmd))
> > +		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
> > +	else
> > +		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
> >  	__SetPageUptodate(new_page);
> > =20
> >  	mmun_start =3D haddr;
> > @@ -989,7 +1083,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
> >  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> > =20
> >  	spin_lock(&mm->page_table_lock);
> > -	put_page(page);
> > +	if (page)
> > +		put_page(page);
> >  	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
> >  		spin_unlock(&mm->page_table_lock);
> >  		mem_cgroup_uncharge_page(new_page);
> > @@ -997,7 +1092,6 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
> >  		goto out_mn;
> >  	} else {
> >  		pmd_t entry;
> > -		VM_BUG_ON(!PageHead(page));
> >  		entry =3D mk_pmd(new_page, vma->vm_page_prot);
> >  		entry =3D maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> >  		entry =3D pmd_mkhuge(entry);
> > @@ -1005,8 +1099,13 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
> >  		page_add_new_anon_rmap(new_page, vma, haddr);
> >  		set_pmd_at(mm, haddr, pmd, entry);
> >  		update_mmu_cache_pmd(vma, address, pmd);
> > -		page_remove_rmap(page);
> > -		put_page(page);
> > +		if (is_huge_zero_pmd(orig_pmd))
> > +			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
> > +		if (page) {
>=20
> Couldn't this be an "else" instead?

Yes. I'll update.

> > +			VM_BUG_ON(!PageHead(page));
> > +			page_remove_rmap(page);
> > +			put_page(page);
> > +		}
> >  		ret |=3D VM_FAULT_WRITE;
> >  	}
> >  	spin_unlock(&mm->page_table_lock);

--=20
 Kirill A. Shutemov

--H1spWtNR+x+ondvy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpKfwAAoJEAd+omnVudOMwZ8QAIUfIvh32wtmerwebeqbOOl3
cX1jblpYiJz/R7jaBJeqWELT0sUFc3Ym8EA3L/S1zr2PsnoG50uEaIEV9ia9Ztgm
3Ij/qnKj+E29haYhJsKhYFj/NNyhUUjsJQ64nQ/ov3OWJhQR6dC8SJHftQmIJ00n
3+KJ1vO+XXajOvIkQe1L+29ICqnzZRiV49jCRrcLrPrUOm66UsQCCdprw7HJNby+
VkpBz3wKkjkf019qV8Xp8zTJRLwj6SK0Qgw5oQZGMUibgUL5p1cXoSzkq0FVVZyi
p5dbsK5ymSAU0wvD0IdNcwXDOC3vfs/ZKMe16mrvtBZnlc3p0QUP7A9XjgxQFhTb
OTGjXMkvdYIoqATZdzG21nAOH/fgi131L9uj/M/tcBbsyyfpNJb4I0+L9IMKemFF
zAUwAep/H7/ZGUeqWeP5vlxYQu5dHVOjwC3tTc3zOa+oP4mJx9PeKDPdFfZ8+6A2
n/b91PY8qEaPyPV6vtuUpvpKS/69OaS6P7Ftde//wtoMVOR8mqystStaV1FEGZx3
q09xXYTkm7nYj4sUAIzzTcjjs/CH++RMWkCBf1s7dMFLkhhGflp3+C5ZfAKiwRp9
PYLGpHwiF1SjPasNSMOWTadDcwCHR95xhyhTUW9x0nI3h4kz/drG8BBDCEk0+Yol
2Cdl2jxIdWAA8LW/g+IU
=qmus
-----END PGP SIGNATURE-----

--H1spWtNR+x+ondvy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
