Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 87AA16B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 22:59:30 -0500 (EST)
Received: by widem10 with SMTP id em10so19714336wid.1
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 19:59:30 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id iz2si21696837wic.87.2015.03.02.19.59.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 19:59:29 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 3 Mar 2015 11:59:17 +0800
Subject: RE: [RFC V3] mm: change mm_advise_free to clear page dirty
Message-ID: <35FD53F367049845BC99AC72306C23D10458D6173BE8@CNBJMBX05.corpusers.net>
References: <20150303032537.GA25015@blaptop>
In-Reply-To: <20150303032537.GA25015@blaptop>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: 'Michal Hocko' <mhocko@suse.cz>, 'Andrew Morton' <akpm@linux-foundation.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Shaohua Li' <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>

> -----Original Message-----
> From: Minchan Kim [mailto:minchan.kim@gmail.com] On Behalf Of Minchan Kim
> Sent: Tuesday, March 03, 2015 11:26 AM
> To: Wang, Yalin
> Cc: 'Michal Hocko'; 'Andrew Morton'; 'linux-kernel@vger.kernel.org';
> 'linux-mm@kvack.org'; 'Rik van Riel'; 'Johannes Weiner'; 'Mel Gorman';
> 'Shaohua Li'; Hugh Dickins; Cyrill Gorcunov
> Subject: Re: [RFC V3] mm: change mm_advise_free to clear page dirty
>=20
> Could you separte this patch in this patchset thread?
> It's tackling differnt problem.
>=20
> As well, I had a question to previous thread about why shared page
> has a problem now but you didn't answer and send a new patchset.
> It makes reviewers/maintainer time waste/confuse. Please, don't
> hurry to send a code. Before that, resolve reviewers's comments.
>=20
> On Tue, Mar 03, 2015 at 10:06:40AM +0800, Wang, Yalin wrote:
> > This patch add ClearPageDirty() to clear AnonPage dirty flag,
> > if not clear page dirty for this anon page, the page will never be
> > treated as freeable. We also make sure the shared AnonPage is not
> > freeable, we implement it by dirty all copyed AnonPage pte,
> > so that make sure the Anonpage will not become freeable, unless
> > all process which shared this page call madvise_free syscall.
>=20
> Please, spend more time to make description clear. I really doubt
> who understand this description without code inspection. :(
> Of course, I'm not a person to write description clear like native
> , either but just I'm sure I spend a more time to write description
> rather than coding, at least. :)
>=20
I see, I will send another mail for file private map pages.
Sorry for my English expressions.
I think your solution is ok,
Your patch will make sure the anonpage pte will always be dirty.
I add some comments for your patch:

> ---
>  mm/madvise.c | 1 -
>  mm/memory.c  | 9 +++++++--
>  mm/rmap.c    | 2 +-
>  mm/vmscan.c  | 3 +--
>  4 files changed, 9 insertions(+), 6 deletions(-)
>=20
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 6d0fcb8..d64200e 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -309,7 +309,6 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigne=
d
> long addr,
>  				continue;
>  			}
>=20
> -			ClearPageDirty(page);
>  			unlock_page(page);
>  		}
>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index 8ae52c9..2f45e77 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2460,9 +2460,14 @@ static int do_swap_page(struct mm_struct *mm, stru=
ct
> vm_area_struct *vma,
>=20
>  	inc_mm_counter_fast(mm, MM_ANONPAGES);
>  	dec_mm_counter_fast(mm, MM_SWAPENTS);
> -	pte =3D mk_pte(page, vma->vm_page_prot);
> +
> +	/*
> +	 * Every page swapped-out was pte_dirty so we makes pte dirty again.
> +	 * MADV_FREE relys on it.
> +	 */
> +	pte =3D mk_pte(pte_mkdirty(page), vma->vm_page_prot);
pte_mkdirty() usage seems wrong here.

>  	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
> -		pte =3D maybe_mkwrite(pte_mkdirty(pte), vma);
> +		pte =3D maybe_mkwrite(pte, vma);
>  		flags &=3D ~FAULT_FLAG_WRITE;
>  		ret |=3D VM_FAULT_WRITE;
>  		exclusive =3D 1;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 47b3ba8..34c1d66 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1268,7 +1268,7 @@ static int try_to_unmap_one(struct page *page, stru=
ct
> vm_area_struct *vma,
>=20
>  		if (flags & TTU_FREE) {
>  			VM_BUG_ON_PAGE(PageSwapCache(page), page);
> -			if (!dirty && !PageDirty(page)) {
> +			if (!dirty) {
>  				/* It's a freeable page by MADV_FREE */
>  				dec_mm_counter(mm, MM_ANONPAGES);
>  				goto discard;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 671e47e..7f520c9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -805,8 +805,7 @@ static enum page_references
> page_check_references(struct page *page,
>  		return PAGEREF_KEEP;
>  	}
>=20
> -	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page) &&
> -			!PageDirty(page))
> +	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page))
>  		*freeable =3D true;
>=20
>  	/* Reclaim if clean, defer dirty pages to writeback */
> --
> 1.9.3
Could we remove SetPageDirty(page); in try_to_free_swap() function based on=
 this patch?
Because your patch will make sure the pte is always dirty,
We don't need setpagedirty(),
The try_to_unmap() path will re-dirty the page during reclaim path,
Isn't it?

Thanks







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
