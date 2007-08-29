Subject: Re: Selective swap out of processes
From: Javier Cabezas =?ISO-8859-1?Q?Rodr=EDguez?= <jcabezas@ac.upc.edu>
In-Reply-To: <46D4DBF7.7060102@yahoo.com.au>
References: <1188320070.11543.85.camel@bastion-laptop>
	 <46D4DBF7.7060102@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-9dxvcTzJh5vhekMB9KVE"
Date: Wed, 29 Aug 2007 12:37:07 +0200
Message-Id: <1188383827.11270.36.camel@bastion-laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-9dxvcTzJh5vhekMB9KVE
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

El mi=C3=A9, 29-08-2007 a las 12:37 +1000, Nick Piggin escribi=C3=B3:
> Simplest will be just to set referenced to 0 right after calling
> page_referenced, in the case you want to forcefully swap out the
> page.
>=20
> try_to_unmap will get called later in the same function.

I have tried this solution, but 0 pages are freed...

- RO/EXEC pages mapped from the executable are now skipped due to this
check:

if (!mapping || !remove_mapping(mapping, page))
	goto keep_locked;

The offender is this check in remove_mapping:

if (unlikely(page_count(page) !=3D 2))
	goto cannot_free;

- RW pages mapped from the executable are skipped because pageout
returns PAGE_KEEP.

- Other pages are skipped because try_to_unmap returns SWAP_FAIL.


I also added a call ptep_clear_flush_young for each pte, to satisfy this
check in try_to_unmap_one:

if (!migration && ((vma->vm_flags & VM_LOCKED) ||
      (ptep_clear_flush_young(vma, address, pte)))) {
	ret =3D SWAP_FAIL;
	goto out_unmap;
}

My code calls the following function for each VMA of the process.  Are
there errors in the function?:

int my_free_pages(struct vm_area_struct * vma, struct mm_struct * mm)
{
	LIST_HEAD(page_list);
	unsigned long nr_taken;
	struct zone * zone =3D NULL;
	int ret;
	pte_t *pte_k;
	pud_t *pud;
	pmd_t *pmd;
	unsigned long addr;
	struct page * p;
	struct scan_control sc;

	sc.gfp_mask =3D __GFP_FS;
	sc.may_swap =3D 1;
	sc.may_writepage =3D 1;

	for (addr =3D vma->vm_start, nr_taken =3D 0; addr < vma->vm_end; addr +=3D
PAGE_SIZE, nr_taken++) {
		pgd_t *pgd =3D pgd_offset(mm, addr);
		if (pgd_none(*pgd))
			return;
		pud =3D pud_offset(pgd, addr);
		if (pud_none(*pud))
			return;
		pmd =3D pmd_offset(pud, addr);
		if (pmd_none(*pmd))
			return;
		if (pmd_large(*pmd))
			pte_k =3D (pte_t *)pmd;
		else
			pte_k =3D pte_offset_kernel(pmd, addr);

		if (pte_k && pte_present(*pte_k)) {
			p =3D pte_page(*pte_k);
			if (!zone)
				zone =3D page_zone(p);

			ptep_clear_flush_young(vma, addr, pte_k);
			del_page_from_lru(zone, p);
			list_add(&p->lru, &page_list);
		}
	}

	spin_lock_irq(&zone->lru_lock);
	__mod_zone_page_state(zone, NR_INACTIVE, -nr_taken);
	zone->pages_scanned +=3D nr_taken;
	spin_unlock_irq(&zone->lru_lock);
}


Thanks


Javi

--=20
Javier Cabezas Rodr=C3=ADguez
Phd. Student - DAC (UPC)
jcabezas@ac.upc.edu

--=-9dxvcTzJh5vhekMB9KVE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Esta parte del mensaje =?ISO-8859-1?Q?est=E1?= firmada
	digitalmente

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG1UxT7q9eX0wTM/URAnvGAJ9gX1NJnDgh14R9745WnhzAH17uJACdFf+o
9xv+blTy7+IfQwWe/QKFZ5g=
=YIn/
-----END PGP SIGNATURE-----

--=-9dxvcTzJh5vhekMB9KVE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
