Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id BAB7E6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 00:46:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Wed, 10 Apr 2013 14:37:56 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 28EF33578050
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:46:33 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A4jvwE42598548
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:45:57 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A4k2qx013521
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:46:02 +1000
Date: Wed, 10 Apr 2013 14:46:11 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 06/25] powerpc: Reduce PTE table memory wastage
Message-ID: <20130410044611.GF8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jt0yj30bxbg11sci"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--jt0yj30bxbg11sci
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:44AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> We allocate one page for the last level of linux page table. With THP and
> large page size of 16MB, that would mean we are wasting large part
> of that page. To map 16MB area, we only need a PTE space of 2K with 64K
> page size. This patch reduce the space wastage by sharing the page
> allocated for the last level of linux page table with multiple pmd
> entries. We call these smaller chunks PTE page fragments and allocated
> page, PTE page.
>=20
> In order to support systems which doesn't have 64K HPTE support, we also
> add another 2K to PTE page fragment. The second half of the PTE fragments
> is used for storing slot and secondary bit information of an HPTE. With t=
his
> we now have a 4K PTE fragment.
>=20
> We use a simple approach to share the PTE page. On allocation, we bump the
> PTE page refcount to 16 and share the PTE page with the next 16 pte alloc
> request. This should help in the node locality of the PTE page fragment,
> assuming that the immediate pte alloc request will mostly come from the
> same NUMA node. We don't try to reuse the freed PTE page fragment. Hence
> we could be waisting some space.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/mmu-book3e.h |    4 +
>  arch/powerpc/include/asm/mmu-hash64.h |    4 +
>  arch/powerpc/include/asm/page.h       |    4 +
>  arch/powerpc/include/asm/pgalloc-64.h |   72 ++++-------------
>  arch/powerpc/kernel/setup_64.c        |    4 +-
>  arch/powerpc/mm/mmu_context_hash64.c  |   35 +++++++++
>  arch/powerpc/mm/pgtable_64.c          |  137 +++++++++++++++++++++++++++=
++++++
>  7 files changed, 202 insertions(+), 58 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/mmu-book3e.h b/arch/powerpc/include=
/asm/mmu-book3e.h
> index 99d43e0..affbd68 100644
> --- a/arch/powerpc/include/asm/mmu-book3e.h
> +++ b/arch/powerpc/include/asm/mmu-book3e.h
> @@ -231,6 +231,10 @@ typedef struct {
>  	u64 high_slices_psize;  /* 4 bits per slice for now */
>  	u16 user_psize;         /* page size index */
>  #endif
> +#ifdef CONFIG_PPC_64K_PAGES
> +	/* for 4K PTE fragment support */
> +	struct page *pgtable_page;
> +#endif
>  } mm_context_t;
> =20
>  /* Page size definitions, common between 32 and 64-bit
> diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include=
/asm/mmu-hash64.h
> index 35bb51e..300ac3c 100644
> --- a/arch/powerpc/include/asm/mmu-hash64.h
> +++ b/arch/powerpc/include/asm/mmu-hash64.h
> @@ -498,6 +498,10 @@ typedef struct {
>  	unsigned long acop;	/* mask of enabled coprocessor types */
>  	unsigned int cop_pid;	/* pid value used with coprocessors */
>  #endif /* CONFIG_PPC_ICSWX */
> +#ifdef CONFIG_PPC_64K_PAGES
> +	/* for 4K PTE fragment support */
> +	struct page *pgtable_page;
> +#endif
>  } mm_context_t;
> =20
> =20
> diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/p=
age.h
> index f072e97..38e7ff6 100644
> --- a/arch/powerpc/include/asm/page.h
> +++ b/arch/powerpc/include/asm/page.h
> @@ -378,7 +378,11 @@ void arch_free_page(struct page *page, int order);
> =20
>  struct vm_area_struct;
> =20
> +#ifdef CONFIG_PPC_64K_PAGES
> +typedef pte_t *pgtable_t;
> +#else
>  typedef struct page *pgtable_t;
> +#endif

Ugh, that's pretty horrible, though I don't see an easy way around it.

>  #include <asm-generic/memory_model.h>
>  #endif /* __ASSEMBLY__ */
> diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include=
/asm/pgalloc-64.h
> index cdbf555..3418989 100644
> --- a/arch/powerpc/include/asm/pgalloc-64.h
> +++ b/arch/powerpc/include/asm/pgalloc-64.h
> @@ -150,6 +150,13 @@ static inline void __pte_free_tlb(struct mmu_gather =
*tlb, pgtable_t table,
> =20
>  #else /* if CONFIG_PPC_64K_PAGES */
> =20
> +extern pte_t *page_table_alloc(struct mm_struct *, unsigned long, int);
> +extern void page_table_free(struct mm_struct *, unsigned long *, int);
> +extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int sh=
ift);
> +#ifdef CONFIG_SMP
> +extern void __tlb_remove_table(void *_table);
> +#endif
> +
>  #define pud_populate(mm, pud, pmd)	pud_set(pud, (unsigned long)pmd)
> =20
>  static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
> @@ -161,90 +168,42 @@ static inline void pmd_populate_kernel(struct mm_st=
ruct *mm, pmd_t *pmd,
>  static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
>  				pgtable_t pte_page)
>  {
> -	pmd_populate_kernel(mm, pmd, page_address(pte_page));
> +	pmd_set(pmd, (unsigned long)pte_page);
>  }
> =20
>  static inline pgtable_t pmd_pgtable(pmd_t pmd)
>  {
> -	return pmd_page(pmd);
> +	return (pgtable_t)(pmd_val(pmd) & -sizeof(pte_t)*PTRS_PER_PTE);
>  }
> =20
>  static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
>  					  unsigned long address)
>  {
> -	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
> +	return (pte_t *)page_table_alloc(mm, address, 1);
>  }
> =20
>  static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
> -				      unsigned long address)
> +					unsigned long address)
>  {
> -	struct page *page;
> -	pte_t *pte;
> -
> -	pte =3D pte_alloc_one_kernel(mm, address);
> -	if (!pte)
> -		return NULL;
> -	page =3D virt_to_page(pte);
> -	pgtable_page_ctor(page);
> -	return page;
> +	return (pgtable_t)page_table_alloc(mm, address, 0);
>  }
> =20
>  static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
>  {
> -	free_page((unsigned long)pte);
> +	page_table_free(mm, (unsigned long *)pte, 1);
>  }
> =20
>  static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
>  {
> -	pgtable_page_dtor(ptepage);
> -	__free_page(ptepage);
> -}
> -
> -static inline void pgtable_free(void *table, unsigned index_size)
> -{
> -	if (!index_size)
> -		free_page((unsigned long)table);
> -	else {
> -		BUG_ON(index_size > MAX_PGTABLE_INDEX_SIZE);
> -		kmem_cache_free(PGT_CACHE(index_size), table);
> -	}
> +	page_table_free(mm, (unsigned long *)ptepage, 0);
>  }
> =20
> -#ifdef CONFIG_SMP
> -static inline void pgtable_free_tlb(struct mmu_gather *tlb,
> -				    void *table, int shift)
> -{
> -	unsigned long pgf =3D (unsigned long)table;
> -	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
> -	pgf |=3D shift;
> -	tlb_remove_table(tlb, (void *)pgf);
> -}
> -
> -static inline void __tlb_remove_table(void *_table)
> -{
> -	void *table =3D (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZ=
E);
> -	unsigned shift =3D (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
> -
> -	pgtable_free(table, shift);
> -}
> -#else /* !CONFIG_SMP */
> -static inline void pgtable_free_tlb(struct mmu_gather *tlb,
> -				    void *table, int shift)
> -{
> -	pgtable_free(table, shift);
> -}
> -#endif /* CONFIG_SMP */
> -
>  static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t tabl=
e,
>  				  unsigned long address)
>  {
> -	struct page *page =3D page_address(table);
> -
>  	tlb_flush_pgtable(tlb, address);
> -	pgtable_page_dtor(page);
> -	pgtable_free_tlb(tlb, page, 0);
> +	pgtable_free_tlb(tlb, table, 0);
>  }
> -
>  #endif /* CONFIG_PPC_64K_PAGES */
> =20
>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long a=
ddr)
> @@ -258,7 +217,6 @@ static inline void pmd_free(struct mm_struct *mm, pmd=
_t *pmd)
>  	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
>  }
> =20
> -
>  #define __pmd_free_tlb(tlb, pmd, addr)		      \
>  	pgtable_free_tlb(tlb, pmd, PMD_INDEX_SIZE)
>  #ifndef CONFIG_PPC_64K_PAGES
> diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_6=
4.c
> index 6da881b..04d833c 100644
> --- a/arch/powerpc/kernel/setup_64.c
> +++ b/arch/powerpc/kernel/setup_64.c
> @@ -575,7 +575,9 @@ void __init setup_arch(char **cmdline_p)
>  	init_mm.end_code =3D (unsigned long) _etext;
>  	init_mm.end_data =3D (unsigned long) _edata;
>  	init_mm.brk =3D klimit;
> -=09
> +#ifdef CONFIG_PPC_64K_PAGES
> +	init_mm.context.pgtable_page =3D NULL;
> +#endif
>  	irqstack_early_init();
>  	exc_lvl_early_init();
>  	emergency_stack_init();
> diff --git a/arch/powerpc/mm/mmu_context_hash64.c b/arch/powerpc/mm/mmu_c=
ontext_hash64.c
> index 59cd773..fbfdca2 100644
> --- a/arch/powerpc/mm/mmu_context_hash64.c
> +++ b/arch/powerpc/mm/mmu_context_hash64.c
> @@ -86,6 +86,9 @@ int init_new_context(struct task_struct *tsk, struct mm=
_struct *mm)
>  	spin_lock_init(mm->context.cop_lockp);
>  #endif /* CONFIG_PPC_ICSWX */
> =20
> +#ifdef CONFIG_PPC_64K_PAGES
> +	mm->context.pgtable_page =3D NULL;
> +#endif
>  	return 0;
>  }
> =20
> @@ -97,13 +100,45 @@ void __destroy_context(int context_id)
>  }
>  EXPORT_SYMBOL_GPL(__destroy_context);
> =20
> +#ifdef CONFIG_PPC_64K_PAGES
> +static void destroy_pagetable_page(struct mm_struct *mm)
> +{
> +	int count;
> +	struct page *page;
> +
> +	page =3D mm->context.pgtable_page;
> +	if (!page)
> +		return;
> +
> +	/* drop all the pending references */
> +	count =3D atomic_read(&page->_mapcount) + 1;
> +	/* We allow PTE_FRAG_NR(16) fragments from a PTE page */
> +	count =3D atomic_sub_return(16 - count, &page->_count);

You should really move PTE_FRAG_NR to a header so you can actually use
it here rather than hard coding 16.

It took me a fair while to convince myself that there is no race here
with something altering mapcount and count between the atomic_read()
and the atomic_sub_return().  It could do with a comment to explain
why that is safe.

Re-using the mapcount field for your index also seems odd, and it took
me a while to convince myself that that's safe too.  Wouldn't it be
simpler to store a pointer to the next sub-page in the mm_context
instead? You can get from that to the struct page easily enough with a
shift and pfn_to_page().

> +	if (!count) {
> +		pgtable_page_dtor(page);
> +		reset_page_mapcount(page);
> +		free_hot_cold_page(page, 0);

It would be nice to use put_page() somehow instead of duplicating its
logic, though I realise the sparc code you've based this on does the
same thing.

> +	}
> +}
> +
> +#else
> +static inline void destroy_pagetable_page(struct mm_struct *mm)
> +{
> +	return;
> +}
> +#endif
> +
> +
>  void destroy_context(struct mm_struct *mm)
>  {
> +
>  #ifdef CONFIG_PPC_ICSWX
>  	drop_cop(mm->context.acop, mm);
>  	kfree(mm->context.cop_lockp);
>  	mm->context.cop_lockp =3D NULL;
>  #endif /* CONFIG_PPC_ICSWX */
> +
> +	destroy_pagetable_page(mm);
>  	__destroy_context(mm->context.id);
>  	subpage_prot_free(mm);
>  	mm->context.id =3D MMU_NO_CONTEXT;
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
> index e212a27..e79840b 100644
> --- a/arch/powerpc/mm/pgtable_64.c
> +++ b/arch/powerpc/mm/pgtable_64.c
> @@ -337,3 +337,140 @@ EXPORT_SYMBOL(__ioremap_at);
>  EXPORT_SYMBOL(iounmap);
>  EXPORT_SYMBOL(__iounmap);
>  EXPORT_SYMBOL(__iounmap_at);
> +
> +#ifdef CONFIG_PPC_64K_PAGES
> +/*
> + * we support 16 fragments per PTE page. This is limited by how many
> + * bits we can pack in page->_mapcount. We use the first half for
> + * tracking the usage for rcu page table free.
> + */
> +#define PTE_FRAG_NR	16
> +/*
> + * We use a 2K PTE page fragment and another 2K for storing
> + * real_pte_t hash index
> + */
> +#define PTE_FRAG_SIZE (2 * PTRS_PER_PTE * sizeof(pte_t))
> +
> +static pte_t *get_from_cache(struct mm_struct *mm)
> +{
> +	int index;
> +	pte_t *ret =3D NULL;
> +	struct page *page;
> +
> +	spin_lock(&mm->page_table_lock);
> +	page =3D mm->context.pgtable_page;
> +	if (page) {
> +		void *p =3D page_address(page);
> +		index =3D atomic_add_return(1, &page->_mapcount);
> +		ret =3D (pte_t *) (p + (index * PTE_FRAG_SIZE));
> +		/*
> +		 * If we have taken up all the fragments mark PTE page NULL
> +		 */
> +		if (index =3D=3D PTE_FRAG_NR - 1)
> +			mm->context.pgtable_page =3D NULL;
> +	}
> +	spin_unlock(&mm->page_table_lock);
> +	return ret;
> +}
> +
> +static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
> +{
> +	pte_t *ret =3D NULL;
> +	struct page *page =3D alloc_page(GFP_KERNEL | __GFP_NOTRACK |
> +				       __GFP_REPEAT | __GFP_ZERO);
> +	if (!page)
> +		return NULL;
> +
> +	spin_lock(&mm->page_table_lock);
> +	/*
> +	 * If we find pgtable_page set, we return
> +	 * the allocated page with single fragement
> +	 * count.
> +	 */
> +	if (likely(!mm->context.pgtable_page)) {
> +		atomic_set(&page->_count, PTE_FRAG_NR);
> +		atomic_set(&page->_mapcount, 0);
> +		mm->context.pgtable_page =3D page;
> +	}

=2E. and in the unlikely case where there *is* a pgtable_page already
set, what then?  Seems like you should BUG_ON, or at least return NULL
- as it is you will return the first sub-page of that page again,
which is very likely in use.

> +	spin_unlock(&mm->page_table_lock);
> +
> +	ret =3D (unsigned long *)page_address(page);
> +	if (!kernel)
> +		pgtable_page_ctor(page);
> +
> +	return ret;
> +}
> +
> +pte_t *page_table_alloc(struct mm_struct *mm, unsigned long vmaddr, int =
kernel)
> +{
> +	pte_t *pte;
> +
> +	pte =3D get_from_cache(mm);
> +	if (pte)
> +		return pte;
> +
> +	return __alloc_for_cache(mm, kernel);
> +}
> +
> +void page_table_free(struct mm_struct *mm, unsigned long *table, int ker=
nel)
> +{
> +	struct page *page =3D virt_to_page(table);
> +	if (put_page_testzero(page)) {
> +		if (!kernel)
> +			pgtable_page_dtor(page);
> +		reset_page_mapcount(page);
> +		free_hot_cold_page(page, 0);
> +	}
> +}
> +
> +#ifdef CONFIG_SMP
> +static void page_table_free_rcu(void *table)
> +{
> +	struct page *page =3D virt_to_page(table);
> +	if (put_page_testzero(page)) {
> +		pgtable_page_dtor(page);
> +		reset_page_mapcount(page);
> +		free_hot_cold_page(page, 0);
> +	}
> +}
> +
> +void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
> +{
> +	unsigned long pgf =3D (unsigned long)table;
> +
> +	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
> +	pgf |=3D shift;
> +	tlb_remove_table(tlb, (void *)pgf);
> +}
> +
> +void __tlb_remove_table(void *_table)
> +{
> +	void *table =3D (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZ=
E);
> +	unsigned shift =3D (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
> +
> +	if (!shift)
> +		/* PTE page needs special handling */
> +		page_table_free_rcu(table);
> +	else {
> +		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
> +		kmem_cache_free(PGT_CACHE(shift), table);
> +	}
> +}
> +#else
> +void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
> +{
> +	if (!shift) {
> +		/* PTE page needs special handling */
> +		struct page *page =3D virt_to_page(table);
> +		if (put_page_testzero(page)) {
> +			pgtable_page_dtor(page);
> +			reset_page_mapcount(page);
> +			free_hot_cold_page(page, 0);
> +		}
> +	} else {
> +		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
> +		kmem_cache_free(PGT_CACHE(shift), table);
> +	}
> +}
> +#endif
> +#endif /* CONFIG_PPC_64K_PAGES */

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--jt0yj30bxbg11sci
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFk7pMACgkQaILKxv3ab8YJ2QCeKeqx1+njlMH3dlGu6e4am6UO
q+oAn1GFimGvwkAPhLaDfRM4TpjuLHMD
=wwtd
-----END PGP SIGNATURE-----

--jt0yj30bxbg11sci--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
