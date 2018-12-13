Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id E21078E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 03:25:09 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id t17so764833ywc.23
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 00:25:09 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t82-v6si606390yba.217.2018.12.13.00.25.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 00:25:08 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v3] mm: thp: fix flags for pmd migration when split
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181213051510.20306-1-peterx@redhat.com>
Date: Thu, 13 Dec 2018 01:24:27 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <6B1C6409-E855-47E4-9D33-3D7C634A47F6@oracle.com>
References: <20181213051510.20306-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org



> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f2d19e4fe854..aebade83cec9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2145,23 +2145,25 @@ static void __split_huge_pmd_locked(struct =
vm_area_struct *vma, pmd_t *pmd,
> 	 */
> 	old_pmd =3D pmdp_invalidate(vma, haddr, pmd);
>=20
> -#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> 	pmd_migration =3D is_pmd_migration_entry(old_pmd);
> -	if (pmd_migration) {
> +	if (unlikely(pmd_migration)) {
> 		swp_entry_t entry;
>=20
> 		entry =3D pmd_to_swp_entry(old_pmd);
> 		page =3D pfn_to_page(swp_offset(entry));
> -	} else
> -#endif
> +		write =3D is_write_migration_entry(entry);
> +		young =3D false;
> +		soft_dirty =3D pmd_swp_soft_dirty(old_pmd);
> +	} else {
> 		page =3D pmd_page(old_pmd);
> +		if (pmd_dirty(old_pmd))
> +			SetPageDirty(page);
> +		write =3D pmd_write(old_pmd);
> +		young =3D pmd_young(old_pmd);
> +		soft_dirty =3D pmd_soft_dirty(old_pmd);
> +	}
> 	VM_BUG_ON_PAGE(!page_count(page), page);
> 	page_ref_add(page, HPAGE_PMD_NR - 1);
> -	if (pmd_dirty(old_pmd))
> -		SetPageDirty(page);
> -	write =3D pmd_write(old_pmd);
> -	young =3D pmd_young(old_pmd);
> -	soft_dirty =3D pmd_soft_dirty(old_pmd);
>=20
> 	/*
> 	 * Withdraw the table only after we mark the pmd entry invalid.
> --=20

Looks good.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>
