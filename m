Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 785DB6B0032
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:57:57 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id bm13so16235808qab.0
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 05:57:57 -0800 (PST)
Received: from BLU004-OMC2S5.hotmail.com (blu004-omc2s5.hotmail.com. [65.55.111.80])
        by mx.google.com with ESMTPS id 16si6073473qab.57.2015.01.28.05.57.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Jan 2015 05:57:56 -0800 (PST)
Message-ID: <BLU436-SMTP153779ECFE274421F0F82DF83330@phx.gbl>
Date: Wed, 28 Jan 2015 21:57:40 +0800
From: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: incorporate read-only pages into transparent huge
 pages
References: <1422380353-4407-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1422380353-4407-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com, zhangyanfei.linux@aliyun.com

Hello

=E5=9C=A8 2015/1/28 1:39=2C Ebru Akagunduz =E5=86=99=E9=81=93:
> This patch aims to improve THP collapse rates=2C by allowing
> THP collapse in the presence of read-only ptes=2C like those
> left in place by do_swap_page after a read fault.
>
> Currently THP can collapse 4kB pages into a THP when
> there are up to khugepaged_max_ptes_none pte_none ptes
> in a 2MB range. This patch applies the same limit for
> read-only ptes.
>
> The patch was tested with a test program that allocates
> 800MB of memory=2C writes to it=2C and then sleeps. I force
> the system to swap out all but 190MB of the program by
> touching other memory. Afterwards=2C the test program does
> a mix of reads and writes to its memory=2C and the memory
> gets swapped back in.
>
> Without the patch=2C only the memory that did not get
> swapped out remained in THPs=2C which corresponds to 24% of
> the memory of the program. The percentage did not increase
> over time.
>
> With this patch=2C after 5 minutes of waiting khugepaged had
> collapsed 50% of the program's memory back into THPs.
>
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Please feel free to add:

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
> Changes in v2:
>  - Remove extra code indent (Vlastimil Babka)
>  - Add comment line for check condition of page_count() (Vlastimil Babka)
>  - Add fast path optimistic check to
>    __collapse_huge_page_isolate() (Andrea Arcangeli)
>  - Move check condition of page_count() below to trylock_page() (Andrea A=
rcangeli)
>
> Changes in v3:
>  - Add a at-least-one-writable-pte check (Zhang Yanfei)
>  - Debug page count (Vlastimil Babka=2C Andrea Arcangeli)
>  - Increase read-only pte counter if pte is none (Andrea Arcangeli)
>
> I've written down test results:
> With the patch:
> After swapped out:
> cat /proc/pid/smaps:
> Anonymous:      100464 kB
> AnonHugePages:  100352 kB
> Swap:           699540 kB
> Fraction:       99=2C88
>
> cat /proc/meminfo:
> AnonPages:      1754448 kB
> AnonHugePages:  1716224 kB
> Fraction:       97=2C82
>
> After swapped in:
> In a few seconds:
> cat /proc/pid/smaps:
> Anonymous:      800004 kB
> AnonHugePages:  145408 kB
> Swap:           0 kB
> Fraction:       18=2C17
>
> cat /proc/meminfo:
> AnonPages:      2455016 kB
> AnonHugePages:  1761280 kB
> Fraction:       71=2C74
>
> In 5 minutes:
> cat /proc/pid/smaps
> Anonymous:      800004 kB
> AnonHugePages:  407552 kB
> Swap:           0 kB
> Fraction:       50=2C94
>
> cat /proc/meminfo:
> AnonPages:      2456872 kB
> AnonHugePages:  2023424 kB
> Fraction:       82=2C35
>
> Without the patch:
> After swapped out:
> cat /proc/pid/smaps:
> Anonymous:      190660 kB
> AnonHugePages:  190464 kB
> Swap:           609344 kB
> Fraction:       99=2C89
>
> cat /proc/meminfo:
> AnonPages:      1740456 kB
> AnonHugePages:  1667072 kB
> Fraction:       95=2C78
>
> After swapped in:
> cat /proc/pid/smaps:
> Anonymous:      800004 kB
> AnonHugePages:  190464 kB
> Swap:           0 kB
> Fraction:       23=2C80
>
> cat /proc/meminfo:
> AnonPages:      2350032 kB
> AnonHugePages:  1667072 kB
> Fraction:       70=2C93
>
> I waited 10 minutes the fractions
> did not change without the patch.
>
>  mm/huge_memory.c | 60 +++++++++++++++++++++++++++++++++++++++++++++-----=
------
>  1 file changed=2C 49 insertions(+)=2C 11 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 817a875..17d6e59 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2148=2C17 +2148=2C18 @@ static int __collapse_huge_page_isolate(struc=
t vm_area_struct *vma=2C
>  {
>  	struct page *page=3B
>  	pte_t *_pte=3B
> -	int referenced =3D 0=2C none =3D 0=3B
> +	int referenced =3D 0=2C none =3D 0=2C ro =3D 0=2C writable =3D 0=3B
>  	for (_pte =3D pte=3B _pte < pte+HPAGE_PMD_NR=3B
>  	     _pte++=2C address +=3D PAGE_SIZE) {
>  		pte_t pteval =3D *_pte=3B
>  		if (pte_none(pteval)) {
> +			ro++=3B
>  			if (++none <=3D khugepaged_max_ptes_none)
>  				continue=3B
>  			else
>  				goto out=3B
>  		}
> -		if (!pte_present(pteval) || !pte_write(pteval))
> +		if (!pte_present(pteval))
>  			goto out=3B
>  		page =3D vm_normal_page(vma=2C address=2C pteval)=3B
>  		if (unlikely(!page))
> @@ -2168=2C9 +2169=2C6 @@ static int __collapse_huge_page_isolate(struct =
vm_area_struct *vma=2C
>  		VM_BUG_ON_PAGE(!PageAnon(page)=2C page)=3B
>  		VM_BUG_ON_PAGE(!PageSwapBacked(page)=2C page)=3B
> =20
> -		/* cannot use mapcount: can't collapse if there's a gup pin */
> -		if (page_count(page) !=3D 1)
> -			goto out=3B
>  		/*
>  		 * We can do it before isolate_lru_page because the
>  		 * page can't be freed from under us. NOTE: PG_lock
> @@ -2179=2C6 +2177=2C34 @@ static int __collapse_huge_page_isolate(struct=
 vm_area_struct *vma=2C
>  		 */
>  		if (!trylock_page(page))
>  			goto out=3B
> +
> +		/*
> +		 * cannot use mapcount: can't collapse if there's a gup pin.
> +		 * The page must only be referenced by the scanned process
> +		 * and page swap cache.
> +		 */
> +		if (page_count(page) !=3D 1 + !!PageSwapCache(page)) {
> +			unlock_page(page)=3B
> +			goto out=3B
> +		}
> +		if (!pte_write(pteval)) {
> +			if (++ro > khugepaged_max_ptes_none) {
> +				unlock_page(page)=3B
> +				goto out=3B
> +			}
> +			if (PageSwapCache(page) && !reuse_swap_page(page)) {
> +				unlock_page(page)=3B
> +				goto out=3B
> +			}
> +			/*
> +			 * Page is not in the swap cache=2C and page count is
> +			 * one (see above). It can be collapsed into a THP.
> +			 */
> +			VM_BUG_ON(page_count(page) !=3D 1)=3B
> +		} else {
> +			writable =3D 1=3B
> +		}
> +
>  		/*
>  		 * Isolate the page to avoid collapsing an hugepage
>  		 * currently in use by the VM.
> @@ -2197=2C7 +2223=2C7 @@ static int __collapse_huge_page_isolate(struct =
vm_area_struct *vma=2C
>  		    mmu_notifier_test_young(vma->vm_mm=2C address))
>  			referenced =3D 1=3B
>  	}
> -	if (likely(referenced))
> +	if (likely(referenced && writable))
>  		return 1=3B
>  out:
>  	release_pte_pages(pte=2C _pte)=3B
> @@ -2550=2C7 +2576=2C7 @@ static int khugepaged_scan_pmd(struct mm_struct=
 *mm=2C
>  {
>  	pmd_t *pmd=3B
>  	pte_t *pte=2C *_pte=3B
> -	int ret =3D 0=2C referenced =3D 0=2C none =3D 0=3B
> +	int ret =3D 0=2C referenced =3D 0=2C none =3D 0=2C ro =3D 0=2C writable=
 =3D 0=3B
>  	struct page *page=3B
>  	unsigned long _address=3B
>  	spinlock_t *ptl=3B
> @@ -2568=2C13 +2594=2C21 @@ static int khugepaged_scan_pmd(struct mm_stru=
ct *mm=2C
>  	     _pte++=2C _address +=3D PAGE_SIZE) {
>  		pte_t pteval =3D *_pte=3B
>  		if (pte_none(pteval)) {
> +			ro++=3B
>  			if (++none <=3D khugepaged_max_ptes_none)
>  				continue=3B
>  			else
>  				goto out_unmap=3B
>  		}
> -		if (!pte_present(pteval) || !pte_write(pteval))
> +		if (!pte_present(pteval))
>  			goto out_unmap=3B
> +		if (!pte_write(pteval)) {
> +			if (++ro > khugepaged_max_ptes_none)
> +				goto out_unmap=3B
> +		} else {
> +			writable =3D 1=3B
> +		}
> +
>  		page =3D vm_normal_page(vma=2C _address=2C pteval)=3B
>  		if (unlikely(!page))
>  			goto out_unmap=3B
> @@ -2591=2C14 +2625=2C18 @@ static int khugepaged_scan_pmd(struct mm_stru=
ct *mm=2C
>  		VM_BUG_ON_PAGE(PageCompound(page)=2C page)=3B
>  		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
>  			goto out_unmap=3B
> -		/* cannot use mapcount: can't collapse if there's a gup pin */
> -		if (page_count(page) !=3D 1)
> +		/*
> +		 * cannot use mapcount: can't collapse if there's a gup pin.
> +		 * The page must only be referenced by the scanned process
> +		 * and page swap cache.
> +		 */
> +		if (page_count(page) !=3D 1 + !!PageSwapCache(page))
>  			goto out_unmap=3B
>  		if (pte_young(pteval) || PageReferenced(page) ||
>  		    mmu_notifier_test_young(vma->vm_mm=2C address))
>  			referenced =3D 1=3B
>  	}
> -	if (referenced)
> +	if (referenced && writable)
>  		ret =3D 1=3B
>  out_unmap:
>  	pte_unmap_unlock(pte=2C ptl)=3B

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
