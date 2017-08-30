Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB10B6B049D
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 22:46:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r25so9329033pfk.11
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:46:12 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id m2si3392798pfb.548.2017.08.29.19.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 19:46:11 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id t3so4041703pgt.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:46:11 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170829235447.10050-3-jglisse@redhat.com>
Date: Tue, 29 Aug 2017 19:46:07 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:

> Replacing all mmu_notifier_invalidate_page() by =
mmu_notifier_invalidat_range()
> and making sure it is bracketed by call to =
mmu_notifier_invalidate_range_start/
> end.
>=20
> Note that because we can not presume the pmd value or pte value we =
have to
> assume the worse and unconditionaly report an invalidation as =
happening.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Bernhard Held <berny156@gmx.de>
> Cc: Adam Borowski <kilobyte@angband.pl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Wanpeng Li <kernellwp@gmail.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Takashi Iwai <tiwai@suse.de>
> Cc: Nadav Amit <nadav.amit@gmail.com>
> Cc: Mike Galbraith <efault@gmx.de>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: axie <axie@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> mm/rmap.c | 44 +++++++++++++++++++++++++++++++++++++++++---
> 1 file changed, 41 insertions(+), 3 deletions(-)
>=20
> diff --git a/mm/rmap.c b/mm/rmap.c
> index c8993c63eb25..da97ed525088 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -887,11 +887,21 @@ static bool page_mkclean_one(struct page *page, =
struct vm_area_struct *vma,
> 		.address =3D address,
> 		.flags =3D PVMW_SYNC,
> 	};
> +	unsigned long start =3D address, end;
> 	int *cleaned =3D arg;
>=20
> +	/*
> +	 * We have to assume the worse case ie pmd for invalidation. =
Note that
> +	 * the page can not be free from this function.
> +	 */
> +	end =3D min(vma->vm_end, (start & PMD_MASK) + PMD_SIZE);
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> +
> 	while (page_vma_mapped_walk(&pvmw)) {
> +		unsigned long cstart, cend;
> 		int ret =3D 0;
> -		address =3D pvmw.address;
> +
> +		cstart =3D address =3D pvmw.address;
> 		if (pvmw.pte) {
> 			pte_t entry;
> 			pte_t *pte =3D pvmw.pte;
> @@ -904,6 +914,7 @@ static bool page_mkclean_one(struct page *page, =
struct vm_area_struct *vma,
> 			entry =3D pte_wrprotect(entry);
> 			entry =3D pte_mkclean(entry);
> 			set_pte_at(vma->vm_mm, address, pte, entry);
> +			cend =3D cstart + PAGE_SIZE;
> 			ret =3D 1;
> 		} else {
> #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
> @@ -918,6 +929,8 @@ static bool page_mkclean_one(struct page *page, =
struct vm_area_struct *vma,
> 			entry =3D pmd_wrprotect(entry);
> 			entry =3D pmd_mkclean(entry);
> 			set_pmd_at(vma->vm_mm, address, pmd, entry);
> +			cstart &=3D PMD_MASK;
> +			cend =3D cstart + PMD_SIZE;
> 			ret =3D 1;
> #else
> 			/* unexpected pmd-mapped page? */
> @@ -926,11 +939,13 @@ static bool page_mkclean_one(struct page *page, =
struct vm_area_struct *vma,
> 		}
>=20
> 		if (ret) {
> -			mmu_notifier_invalidate_page(vma->vm_mm, =
address);
> +			mmu_notifier_invalidate_range(vma->vm_mm, =
cstart, cend);
> 			(*cleaned)++;
> 		}
> 	}
>=20
> +	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> +
> 	return true;
> }
>=20
> @@ -1324,6 +1339,7 @@ static bool try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
> 	pte_t pteval;
> 	struct page *subpage;
> 	bool ret =3D true;
> +	unsigned long start =3D address, end;
> 	enum ttu_flags flags =3D (enum ttu_flags)arg;
>=20
> 	/* munlock has nothing to gain from examining un-locked vmas */
> @@ -1335,6 +1351,14 @@ static bool try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
> 				flags & TTU_MIGRATION, page);
> 	}
>=20
> +	/*
> +	 * We have to assume the worse case ie pmd for invalidation. =
Note that
> +	 * the page can not be free in this function as call of =
try_to_unmap()
> +	 * must hold a reference on the page.
> +	 */
> +	end =3D min(vma->vm_end, (start & PMD_MASK) + PMD_SIZE);
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> +
> 	while (page_vma_mapped_walk(&pvmw)) {
> 		/*
> 		 * If the page is mlock()d, we cannot swap it out.
> @@ -1408,6 +1432,8 @@ static bool try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
> 				set_huge_swap_pte_at(mm, address,
> 						     pvmw.pte, pteval,
> 						     =
vma_mmu_pagesize(vma));
> +				mmu_notifier_invalidate_range(mm, =
address,
> +					address + =
vma_mmu_pagesize(vma));

I don=E2=80=99t think that the notifier should be called after the PTE =
is set, but
after the PTE is cleared, PTE permissions are demoted (e.g., RW->RO) or
access/dirty bits are cleared. [There is an exception: if the PFN in the =
PTE
is changed without clearing the PTE before, but it does not apply here, =
and
there is a different notifier for this case.]

Therefore, IIUC, try_to_umap_one() should only call
mmu_notifier_invalidate_range() after ptep_get_and_clear() and
ptep_clear_flush() are called. All the other calls to
mmu_notifier_invalidate_range() in this function can be removed.

Regards,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
