Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B937D6B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 04:10:36 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so187998pab.18
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 01:10:36 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id sl5si1664937pbc.164.2014.11.19.01.10.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 01:10:35 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 17/19] mlock, thp: HACK: split all pages in VM_LOCKED vma
Date: Wed, 19 Nov 2014 09:02:42 +0000
Message-ID: <20141119090318.GA3974@hori1.linux.bs1.fc.nec.co.jp>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-18-git-send-email-kirill.shutemov@linux.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F008A993104C57428C50578DFE24451F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Nov 05, 2014 at 04:49:52PM +0200, Kirill A. Shutemov wrote:
> We don't yet handle mlocked pages properly with new THP refcounting.
> For now we split all pages in VMA on mlock and disallow khugepaged
> collapse pages in the VMA. If split failed on mlock() we fail the
> syscall with -EBUSY.
> ---
...

> @@ -542,6 +530,60 @@ next:
>  	}
>  }
> =20
> +static int thp_split(pmd_t *pmd, unsigned long addr, unsigned long end,
> +		struct mm_walk *walk)
> +{
> +	spinlock_t *ptl;
> +	struct page *page =3D NULL;
> +	pte_t *pte;
> +	int err =3D 0;
> +
> +retry:
> +	if (pmd_none(*pmd))
> +		return 0;
> +	if (pmd_trans_huge(*pmd)) {
> +		if (is_huge_zero_pmd(*pmd)) {
> +			split_huge_pmd(walk->vma, pmd, addr);
> +			return 0;
> +		}
> +		ptl =3D pmd_lock(walk->mm, pmd);
> +		if (!pmd_trans_huge(*pmd)) {
> +			spin_unlock(ptl);
> +			goto retry;
> +		}
> +		page =3D pmd_page(*pmd);
> +		VM_BUG_ON_PAGE(!PageHead(page), page);
> +		get_page(page);
> +		spin_unlock(ptl);
> +		err =3D split_huge_page(page);
> +		put_page(page);
> +		return err;
> +	}
> +	pte =3D pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
> +	do {
> +		if (!pte_present(*pte))
> +			continue;
> +		page =3D vm_normal_page(walk->vma, addr, *pte);
> +		if (!page)
> +			continue;
> +		if (PageTransCompound(page)) {
> +			page =3D compound_head(page);
> +			get_page(page);
> +			spin_unlock(ptl);
> +			err =3D split_huge_page(page);
> +			spin_lock(ptl);
> +			put_page(page);
> +			if (!err) {
> +				VM_BUG_ON_PAGE(compound_mapcount(page), page);
> +				VM_BUG_ON_PAGE(PageTransCompound(page), page);

If split_huge_page() succeeded, we don't have to continue the iteration,
so break this loop here?

Thanks,
Naoya Horiguchi

> +			} else
> +				break;
> +		}
> +	} while (pte++, addr +=3D PAGE_SIZE, addr !=3D end);
> +	pte_unmap_unlock(pte - 1, ptl);
> +	return err;
> +}
> +
>  /*
>   * mlock_fixup  - handle mlock[all]/munlock[all] requests.
>   *=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
