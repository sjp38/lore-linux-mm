Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 2858A6B005D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 20:22:58 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON, hugetlbfs: fix RSS-counter warning
Date: Thu,  6 Dec 2012 20:22:42 -0500
Message-Id: <1354843362-3680-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121206144008.9b376ec7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 06, 2012 at 02:40:08PM -0800, Andrew Morton wrote:
...
> > On Wed, Dec 05, 2012 at 10:04:50PM +0000, Luck, Tony wrote:
> > > 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> > > -		if (PageAnon(page))
> > > +		if (PageHuge(page))
> > > +			;
> > > +		else if (PageAnon(page))
> > >  			dec_mm_counter(mm, MM_ANONPAGES);
> > >  		else
> > >  			dec_mm_counter(mm, MM_FILEPAGES);
> > > 
> > > This style minimizes the "diff" ... but wouldn't it be nicer to say:
> > > 
> > > 		if (!PageHuge(page)) {
> > > 			old code in here
> > > 		}
> > > 
> > 
> > I think this need more lines in diff because old code should be
> > indented without any logical change.
> 
> I do agree with Tony on this.  While it is nice to keep the diff
> looking simple, it is more important that the resulting code be clean
> and idiomatic.

OK, I agree.

> --- a/mm/rmap.c~hwpoison-hugetlbfs-fix-rss-counter-warning-fix
> +++ a/mm/rmap.c
> @@ -1249,14 +1249,14 @@ int try_to_unmap_one(struct page *page, 
>  	update_hiwater_rss(mm);
>  
>  	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> -		if (PageHuge(page))
> -			;
> -		else if (PageAnon(page))
> -			dec_mm_counter(mm, MM_ANONPAGES);
> -		else
> -			dec_mm_counter(mm, MM_FILEPAGES);
> -		set_pte_at(mm, address, pte,
> -				swp_entry_to_pte(make_hwpoison_entry(page)));
> +		if (!PageHuge(page)) {
> +			if (PageAnon(page))
> +				dec_mm_counter(mm, MM_ANONPAGES);
> +			else
> +				dec_mm_counter(mm, MM_FILEPAGES);
> +			set_pte_at(mm, address, pte,
> +				   swp_entry_to_pte(make_hwpoison_entry(page)));
> +		}

This set_pte_at() should come outside the if-block, or error containment
does not work.

Thanks,
Naoya

>  	} else if (PageAnon(page)) {
>  		swp_entry_t entry = { .val = page_private(page) };
>  
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
