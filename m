Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C068D6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:28:23 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s2so1077234pge.19
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 02:28:23 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g71si5203255pgc.308.2017.10.17.02.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 02:28:22 -0700 (PDT)
Date: Tue, 17 Oct 2017 17:21:32 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH 2/2] mm: rename page dtor functions to
 {compound,huge,transhuge}_page__dtor
Message-ID: <20171017092131.GB7748@intel.com>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-3-git-send-email-changbin.du@intel.com>
 <4911ff99-ac77-0344-8696-a15ca9f3e763@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mojUlQ0s9EVzWg2t"
Content-Disposition: inline
In-Reply-To: <4911ff99-ac77-0344-8696-a15ca9f3e763@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: changbin.du@intel.com, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--mojUlQ0s9EVzWg2t
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Khandual,
> >  						long freed);
> >  bool isolate_huge_page(struct page *page, struct list_head *list);
> >  void putback_active_hugepage(struct page *page);
> > -void free_huge_page(struct page *page);
> > +void huge_page_dtor(struct page *page);
> >  void hugetlb_fix_reserve_counts(struct inode *inode);
> >  extern struct mutex *hugetlb_fault_mutex_table;
> >  u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 065d99d..adfa906 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -616,7 +616,7 @@ void split_page(struct page *page, unsigned int ord=
er);
> >   * prototype for that function and accessor functions.
> >   * These are _only_ valid on the head of a compound page.
> >   */
> > -typedef void compound_page_dtor(struct page *);
> > +typedef void compound_page_dtor_t(struct page *);
>=20
> Why changing this ? I understand _t kind of specifies it more
> like a type def but this patch is just to rename the compound
> page destructor functions. Not sure we should change datatype
> here as well in this patch.
>
It is because of name conflict. I think you already get it per below commen=
ts.
I will describe it in commit message.

> > =20
> >  /* Keep the enum in sync with compound_page_dtors array in mm/page_all=
oc.c */
> >  enum compound_dtor_id {
> > @@ -630,7 +630,7 @@ enum compound_dtor_id {
> >  #endif
> >  	NR_COMPOUND_DTORS,
> >  };
> > -extern compound_page_dtor * const compound_page_dtors[];
> > +extern compound_page_dtor_t * const compound_page_dtors[];
> > =20
> >  static inline void set_compound_page_dtor(struct page *page,
> >  		enum compound_dtor_id compound_dtor)
> > @@ -639,7 +639,7 @@ static inline void set_compound_page_dtor(struct pa=
ge *page,
> >  	page[1].compound_dtor =3D compound_dtor;
> >  }
> > =20
> > -static inline compound_page_dtor *get_compound_page_dtor(struct page *=
page)
> > +static inline compound_page_dtor_t *get_compound_page_dtor(struct page=
 *page)
>=20
> Which is adding these kind of changes to the patch without
> having a corresponding description in the commit message.
>=20
> >  {
> >  	VM_BUG_ON_PAGE(page[1].compound_dtor >=3D NR_COMPOUND_DTORS, page);
> >  	return compound_page_dtors[page[1].compound_dtor];
> > @@ -657,7 +657,7 @@ static inline void set_compound_order(struct page *=
page, unsigned int order)
> >  	page[1].compound_order =3D order;
> >  }
> > =20
> > -void free_compound_page(struct page *page);
> > +void compound_page_dtor(struct page *page);
> > =20
> >  #ifdef CONFIG_MMU
> >  /*
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index e267488..a01125b 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2717,7 +2717,7 @@ fail:		if (mapping)
> >  	return ret;
> >  }
> > =20
> > -void free_transhuge_page(struct page *page)
> > +void transhuge_page_dtor(struct page *page)
> >  {
> >  	struct pglist_data *pgdata =3D NODE_DATA(page_to_nid(page));
> >  	unsigned long flags;
> > @@ -2728,7 +2728,7 @@ void free_transhuge_page(struct page *page)
> >  		list_del(page_deferred_list(page));
> >  	}
> >  	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
> > -	free_compound_page(page);
> > +	compound_page_dtor(page);
> >  }
> > =20
> >  void deferred_split_huge_page(struct page *page)
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 424b0ef..1af2c4e7 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1250,7 +1250,7 @@ static void clear_page_huge_active(struct page *p=
age)
> >  	ClearPagePrivate(&page[1]);
> >  }
> > =20
> > -void free_huge_page(struct page *page)
> > +void huge_page_dtor(struct page *page)
> >  {
> >  	/*
> >  	 * Can't pass hstate in here because it is called from the
> > @@ -1363,7 +1363,7 @@ int PageHeadHuge(struct page *page_head)
> >  	if (!PageHead(page_head))
> >  		return 0;
> > =20
> > -	return get_compound_page_dtor(page_head) =3D=3D free_huge_page;
> > +	return get_compound_page_dtor(page_head) =3D=3D huge_page_dtor;
> >  }
> > =20
> >  pgoff_t __basepage_index(struct page *page)
> > @@ -1932,11 +1932,11 @@ static long vma_add_reservation(struct hstate *=
h,
> >   * specific error paths, a huge page was allocated (via alloc_huge_pag=
e)
> >   * and is about to be freed.  If a reservation for the page existed,
> >   * alloc_huge_page would have consumed the reservation and set PagePri=
vate
> > - * in the newly allocated page.  When the page is freed via free_huge_=
page,
> > + * in the newly allocated page.  When the page is freed via huge_page_=
dtor,
> >   * the global reservation count will be incremented if PagePrivate is =
set.
> > - * However, free_huge_page can not adjust the reserve map.  Adjust the
> > + * However, huge_page_dtor can not adjust the reserve map.  Adjust the
> >   * reserve map here to be consistent with global reserve count adjustm=
ents
> > - * to be made by free_huge_page.
> > + * to be made by huge_page_dtor.
> >   */
> >  static void restore_reserve_on_error(struct hstate *h,
> >  			struct vm_area_struct *vma, unsigned long address,
> > @@ -1950,7 +1950,7 @@ static void restore_reserve_on_error(struct hstat=
e *h,
> >  			 * Rare out of memory condition in reserve map
> >  			 * manipulation.  Clear PagePrivate so that
> >  			 * global reserve count will not be incremented
> > -			 * by free_huge_page.  This will make it appear
> > +			 * by huge_page_dtor.  This will make it appear
> >  			 * as though the reservation for this page was
> >  			 * consumed.  This may prevent the task from
> >  			 * faulting in the page at a later time.  This
> > @@ -2304,7 +2304,7 @@ static unsigned long set_max_huge_pages(struct hs=
tate *h, unsigned long count,
> >  	while (count > persistent_huge_pages(h)) {
> >  		/*
> >  		 * If this allocation races such that we no longer need the
> > -		 * page, free_huge_page will handle it by freeing the page
> > +		 * page, huge_page_dtor will handle it by freeing the page
> >  		 * and reducing the surplus.
> >  		 */
> >  		spin_unlock(&hugetlb_lock);
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 77e4d3c..b31205c 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -248,14 +248,14 @@ char * const migratetype_names[MIGRATE_TYPES] =3D=
 {
> >  #endif
> >  };
> > =20
> > -compound_page_dtor * const compound_page_dtors[] =3D {
> > +compound_page_dtor_t * const compound_page_dtors[] =3D {
>=20
> Adding this chunk as well.
>=20
Sure.

> >  	NULL,
> > -	free_compound_page,
> > +	compound_page_dtor,
> >  #ifdef CONFIG_HUGETLB_PAGE
> > -	free_huge_page,
> > +	huge_page_dtor,
> >  #endif
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > -	free_transhuge_page,
> > +	transhuge_page_dtor,
> >  #endif
> >  };
>=20
> Having *dtor* in the destructor functions for the huge pages
> (all of them) actually makes sense. It wont be confused with
> a lot other free_* functions and some of them dealing with
> THP/HugeTLB as well.
>=20
echo!

> > =20
> > @@ -586,7 +586,7 @@ static void bad_page(struct page *page, const char =
*reason,
> >   * This usage means that zero-order pages may not be compound.
> >   */
> > =20
> > -void free_compound_page(struct page *page)
> > +void compound_page_dtor(struct page *page)
> >  {
> >  	__free_pages_ok(page, compound_order(page));
> >  }
> > diff --git a/mm/swap.c b/mm/swap.c
> > index a77d68f..8f98caf 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -81,7 +81,7 @@ static void __put_single_page(struct page *page)
> > =20
> >  static void __put_compound_page(struct page *page)
> >  {
> > -	compound_page_dtor *dtor;
> > +	compound_page_dtor_t *dtor;
>=20
> If the typedef change needs to be retained then the commit message
> must include a line.
>=20
will do it. Thanks.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--=20
Thanks,
Changbin Du

--mojUlQ0s9EVzWg2t
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ5cubAAoJEAanuZwLnPNUyZcH/3daudI4SJeVAmJ1D0K4oPTz
m5y4ZiKSC4D3aL8TlgyAKPtqxndHseiKpsVIJ72lEbI+AZQiIPyrg49kO58erk72
vwsxuE6cyufEPZj6X3DhjuHyQXuseVozwr/UAkfX+P7jyaOho5QvRwEID2wWDv5P
PYTuA284IMRxt0qA3AZEsrzse616Ynu5wh+1mtLlcPS1qhisS4OoR5OpMZafp5e8
hQmY//SytrqFYecZLeKiHf7oDjly6ncSLqZD8NFtfJGioZDN9CPg8fGQb3yekiep
u4WIlW9Cqo8j07MTw+vTXNLGSjBaH5zGJkUy9QUc3X85LOBLYW2i54KolG5bLGk=
=9dRe
-----END PGP SIGNATURE-----

--mojUlQ0s9EVzWg2t--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
